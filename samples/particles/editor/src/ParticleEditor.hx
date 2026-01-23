package;

import feathers.data.ArrayCollection;
import feathers.layout.AutoSizeMode;
import haxe.Json;
import haxe.io.Path;
import inputAction.InputAction;
import inputAction.controllers.KeyAction;
import inputAction.events.InputActionEvent;
import massive.animation.Animator;
import massive.data.Frame;
import massive.display.MassiveDisplay;
import massive.particle.Particle;
import massive.particle.ParticleSystem;
import massive.particle.ParticleSystemDefaults;
import massive.particle.ParticleSystemOptions;
import openfl.Assets;
import openfl.Vector;
import openfl.ui.Keyboard;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.events.Event;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Align;
import valedit.ExposedCollection;
import valedit.value.ExposedColor;
import valedit.value.ExposedFloatDrag;
import valedit.value.ExposedSelect;
import valeditor.ValEditor;
import valeditor.data.Data;
import valeditor.editor.base.ValEditorSimpleStarling;
import valeditor.editor.file.FileController;
import valeditor.input.InputActionID;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.WindowSize;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.view.SimpleEditViewToggleGroups;
#if (desktop || air)
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
#else
import openfl.net.FileReference;
#end

/**
 * ...
 * @author Matse
 */
class ParticleEditor extends ValEditorSimpleStarling
{
	private var _assetManager:AssetManager;
	
	private var _massive:MassiveDisplay;
	private var _massiveCollection:ExposedCollection;
	private var _ps:ParticleSystem<Particle>;
	private var _psCollection:ExposedCollection;
	
	// file menu
	private var _fileMenuCollection:ArrayCollection<MenuItem>;
	private var _fileOpenItem:MenuItem;
	private var _fileSaveItem:MenuItem;
	private var _fileSaveAsItem:MenuItem;
	
	// edit menu
	private var _editMenuCollection:ArrayCollection<MenuItem>;
	private var _undoItem:MenuItem;
	private var _redoItem:MenuItem;
	
	// options menu
	private var _optionsMenuCollection:ArrayCollection<MenuItem>;
	private var _backgroundColorItem:MenuItem;
	private var _uiSkinItem:MenuItem;
	private var _autoCenterItem:MenuItem;
	private var _centerItem:MenuItem;
	
	// texture menu
	private var _textureMenuCollection:ArrayCollection<MenuItem>;
	
	// presets menu
	private var _presetsMenuCollection:ArrayCollection<MenuItem>;
	
	private var _fileName:String = "particle.json";
	private var _filePath:String = null;
	private var _fullPath:String = null;
	#if (desktop || air)
	private var _fileStream:FileStream = new FileStream();
	#end
	
	private var _autoCenter:Bool = true;
	private var _backgroundColorCollection:ExposedCollection;
	private var _presetConfigs:Map<String, ParticleConfig> = new Map<String, ParticleConfig>();
	
	private var _textureMap:Map<String, Texture> = new Map<String, Texture>();
	#if flash
	private var _frameMap:Map<String, Vector<Frame>> = new Map<String, Vector<Frame>>();
	#else
	private var _frameMap:Map<String, Array<Frame>> = new Map<String, Array<Frame>>();
	#end
	private var _timingMap:Map<String, Array<Float>> = new Map<String, Array<Float>>();

	public function new() 
	{
		super();
		this._fullPath = this._fileName;
	}
	
	override function exposeData():Void 
	{
		Data.exposeMassive();
		Data.exposeOpenFL_geom();
		Data.exposeStarling();
	}
	
	override public function start():Void 
	{
		this.stage.color = 0x333333;
		
		this.editView = new SimpleEditViewToggleGroups();
		this.editView.autoSizeMode = AutoSizeMode.STAGE;
		
		super.start();
	}
	
	override function ready():Void 
	{
		super.ready();
		
		this._assetManager = new AssetManager();
		this._assetManager.enqueue([
			Assets.getPath("img/blob.png"),
			Assets.getPath("img/circle.png"),
			Assets.getPath("img/heart.png"),
			Assets.getPath("img/star.png"),
			Assets.getPath("img/animated_fx.png"),
			Assets.getPath("img/animated_fx.xml")
		]);
		this._assetManager.loadQueue(assetsLoaded);
	}
	
	private function assetsLoaded():Void 
	{
		initInputActions();
		
		// file menu
		this._fileOpenItem = new MenuItem("file_open", "Open", true, "Ctrl+O");
		this._fileSaveItem = new MenuItem("file_save", "Save", true, "Ctrl+S");
		this._fileSaveAsItem = new MenuItem("file_save_as", "Save as", true, "Ctrl+Shift+S");
		this._fileMenuCollection = new ArrayCollection<MenuItem>([
			this._fileOpenItem,
			this._fileSaveItem,
			this._fileSaveAsItem
		]);
		this.editView.addMenu("file", "File", onFileMenuCallback, onFileMenuOpen, this._fileMenuCollection);
		
		// edit menu
		this._undoItem = new MenuItem("undo", "Undo", false, "Ctrl+Z");
		this._redoItem = new MenuItem("redo", "Redo", false, "Ctrl+Y");
		this._editMenuCollection = new ArrayCollection<MenuItem>([
			this._undoItem,
			this._redoItem
		]);
		this.editView.addMenu("edit", "Edit", onEditMenuCallback, onEditMenuOpen, this._editMenuCollection);
		
		// options menu
		this._uiSkinItem = new MenuItem("ui_skin", "", true);
		this._backgroundColorItem = new MenuItem("background_color", "Background color", true);
		this._autoCenterItem = new MenuItem("auto_center", "Auto center enabled", true);
		this._centerItem = new MenuItem("center", "Center", true);
		this._optionsMenuCollection = new ArrayCollection<MenuItem>([
			this._uiSkinItem,
			this._backgroundColorItem,
			this._autoCenterItem,
			this._centerItem
		]);
		this.editView.addMenu("options", "Options", onOptionsMenuCallback, onOptionsMenuOpen, this._optionsMenuCollection);
		
		// texture menu
		this._textureMenuCollection = new ArrayCollection<MenuItem>([
		
		]);
		this.editView.addMenu("texture", "Texture", onTextureMenuCallback, onTextureMenuOpen, this._textureMenuCollection);
		
		// presets menu
		this._presetsMenuCollection = new ArrayCollection<MenuItem>([
			
		]);
		this.editView.addMenu("presets", "Presets", onPresetsMenuCallback, onPresetsMenuOpen, this._presetsMenuCollection);
		
		// ? menu
		
		// create a collection for background color edit
		this._backgroundColorCollection = new ExposedCollection();
		var color:ExposedColor = new ExposedColor("color");
		this._backgroundColorCollection.addValue(color);
		this._backgroundColorCollection.readAndSetObject(this.stage);
		
		cast(this.editView, SimpleEditViewToggleGroups).addToggleGroup("MassiveDisplay", "DISPLAY", true);
		cast(this.editView, SimpleEditViewToggleGroups).addToggleGroup("ParticleSystem", "PARTICLE SYSTEM", true);
		
		var atlas:TextureAtlas;
		var texture:Texture;
		var textures:Vector<Texture>;
		var frame:Frame;
		#if flash
		var frames:Vector<Frame>;
		#else
		var frames:Array<Frame>;
		#end
		var timings:Array<Float>;
		
		atlas = this._assetManager.getTextureAtlas("animated_fx");
		textures = atlas.getTextures("0_");
		frames = Frame.fromTextureVectorWithAlign(textures, Align.CENTER, Align.CENTER);
		timings = Animator.generateTimings(frames, 12);
		registerTexture("animated_fx", atlas.texture, frames, timings);
		
		texture = this._assetManager.getTexture("blob");
		frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
		#if flash
		frames = new Vector<Frame>();
		#else
		frames = new Array<Frame>();
		#end
		frames[0] = frame;
		registerTexture("blob", texture, frames);
		
		texture = this._assetManager.getTexture("circle");
		frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
		#if flash
		frames = new Vector<Frame>();
		#else
		frames = new Array<Frame>();
		#end
		frames[0] = frame;
		registerTexture("circle", texture, frames);
		
		texture = this._assetManager.getTexture("heart");
		frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
		#if flash
		frames = new Vector<Frame>();
		#else
		frames = new Array<Frame>();
		#end
		frames[0] = frame;
		registerTexture("heart", texture, frames);
		
		texture = Texture.fromColor(2, 2);
		frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
		#if flash
		frames = new Vector<Frame>();
		#else
		frames = new Array<Frame>();
		#end
		frames[0] = frame;
		registerTexture("square", texture, frames);
		
		texture = this._assetManager.getTexture("star");
		frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
		#if flash
		frames = new Vector<Frame>();
		#else
		frames = new Array<Frame>();
		#end
		frames[0] = frame;
		registerTexture("star", texture, frames);
		
		var config:ParticleConfig;
		var options:ParticleSystemOptions;
		var json:Dynamic;
		var str:String;
		
		// "none" preset
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = this._textureMap.get("square");
		config.options = new ParticleSystemOptions();
		config.addFrames(this._frameMap.get("square"));
		registerPreset("none", config);
		
		// "animated fx" preset
		str = Assets.getText("presets/animated_fx.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = this._textureMap.get("animated_fx");
		config.options = options;
		config.addFrames(this._frameMap.get("animated_fx"), this._timingMap.get("animated_fx"));
		registerPreset("animated fx", config);
		
		// "cybermancy" preset
		str = Assets.getText("presets/cybermancy.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.ADD;
		config.texture = this._textureMap.get("square");
		config.options = options;
		config.addFrames(this._frameMap.get("square"));
		registerPreset("cybermancy", config);
		
		// "dancing stars" preset
		str = Assets.getText("presets/dancing_stars.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = this._textureMap.get("star");
		config.options = options;
		config.addFrames(this._frameMap.get("star"));
		registerPreset("dancing stars", config);
		
		// "fireball" preset
		str = Assets.getText("presets/fireball.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.ADD;
		config.texture = this._textureMap.get("circle");
		config.options = options;
		config.addFrames(this._frameMap.get("circle"));
		registerPreset("fireball", config);
		
		// "hyperspace" preset
		str = Assets.getText("presets/hyperspace.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.ADD;
		config.texture = this._textureMap.get("square");
		config.options = options;
		config.addFrames(this._frameMap.get("square"));
		registerPreset("hyperspace", config);
		
		// "love cloud" preset
		str = Assets.getText("presets/love_cloud.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = this._textureMap.get("heart");
		config.options = options;
		config.addFrames(this._frameMap.get("heart"));
		registerPreset("love cloud", config);
		
		// "space worms" preset
		str = Assets.getText("presets/space_worms.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = this._textureMap.get("square");
		config.options = options;
		config.addFrames(this._frameMap.get("square"));
		registerPreset("space worms", config);
		
		// "star geyser" preset
		str = Assets.getText("presets/star_geyser.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = this._textureMap.get("star");
		config.options = options;
		config.addFrames(this._frameMap.get("star"));
		registerPreset("star geyser", config);
		
		// "toxic vortex" preset
		str = Assets.getText("presets/toxic_vortex.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.SCREEN;
		config.texture = this._textureMap.get("blob");
		config.options = options;
		config.addFrames(this._frameMap.get("blob"));
		registerPreset("toxic vortex", config);
		
		this._massive = new MassiveDisplay();
		this._massive.texture = texture;
		addChild(this._massive);
		
		// MassiveDisplay collection
		// we're only interested in a few properties so we create a custom collection
		var float:ExposedFloatDrag;
		var select:ExposedSelect;
		
		this._massiveCollection = new ExposedCollection();
		
		select = new ExposedSelect("blendMode");
		select.add(BlendMode.ADD);
		select.add(BlendMode.AUTO);
		select.add(BlendMode.BELOW);
		select.add(BlendMode.ERASE);
		select.add(BlendMode.MASK);
		select.add(BlendMode.MULTIPLY);
		select.add(BlendMode.NONE);
		select.add(BlendMode.NORMAL);
		select.add(BlendMode.SCREEN);
		this._massiveCollection.addValue(select);
		
		float = new ExposedFloatDrag("colorRed", null, 0.0, 10.0, 0.01);
		this._massiveCollection.addValue(float);
		
		float = new ExposedFloatDrag("colorGreen", null, 0.0, 10.0, 0.01);
		this._massiveCollection.addValue(float);
		
		float = new ExposedFloatDrag("colorBlue", null, 0.0, 10.0, 0.01);
		this._massiveCollection.addValue(float);
		
		float = new ExposedFloatDrag("alpha", null, 0, 1.0, 0.01);
		this._massiveCollection.addValue(float);
		
		ValEditor.edit(this._massive, this._massiveCollection, this.editView.getEditContainer("MassiveDisplay"));
		//\MassiveDisplay collection
		
		// create particle system
		this._ps = ParticleSystemDefaults.create();
		// add to massive display
		this._massive.addLayer(this._ps);
		
		// edit particle system and get collection
		this._psCollection = ValEditor.edit(this._ps, null, this.editView.getEditContainer("ParticleSystem"));
		
		applyPreset("love cloud");
	}
	
	private function registerPreset(id:String, config:ParticleConfig):Void
	{
		this._presetConfigs.set(id, config);
		var menuItem:MenuItem = new MenuItem(id, id);
		this.editView.addMenuItem("presets", menuItem);
	}
	
	private function applyPreset(id:String):Void
	{
		this._ps.stop(true);
		
		var config:ParticleConfig = this._presetConfigs.get(id);
		this._massive.blendMode = config.blendMode;
		this._massive.texture = config.texture;
		this._ps.clearFrames();
		this._ps.addFramesMultiple(config.frames, config.frameTimings);
		this._ps.readSystemOptions(config.options);
		
		if (this._autoCenter) centerParticles();
		this._massiveCollection.read();
		this._psCollection.read();
		this._ps.start();
		
		ValEditor.actionStack.clearActions();
	}
	
	private function registerTexture(id:String, texture:Texture, frames:#if flash Vector<Frame> #else Array<Frame> #end, timings:Array<Float> = null):Void
	{
		if (timings == null) timings = Animator.generateTimings(frames);
		
		this._textureMap.set(id, texture);
		this._frameMap.set(id, frames);
		this._timingMap.set(id, timings);
		
		var menuItem:MenuItem = new MenuItem(id, id);
		this.editView.addMenuItem("texture", menuItem);
	}
	
	private function applyTexture(id:String):Void
	{
		this._massive.texture = this._textureMap.get(id);
		this._ps.clearFrames();
		this._ps.addFrames(this._frameMap.get(id), this._timingMap.get(id));
	}
	
	@:access(starling.core.Starling)
	override function onDisplayResize(evt:openfl.events.Event):Void 
	{
		super.onDisplayResize(evt);
		
		if (Starling.current.showStats)
		{
			#if flash
			if (!Starling.current.hasEventListener(Event.RENDER, updateStarlingStats))
			{
				Starling.current.addEventListener(Event.RENDER, updateStarlingStats);
			}
			#else
			Starling.current.__statsDisplay.x = this.editView.displayRect.x;
			Starling.current.__statsDisplay.y = this.editView.displayRect.y;
			#end
		}
		
		if (this._autoCenter) centerParticles();
	}
	
	#if flash
	@:access(starling.core.Starling)
	private function updateStarlingStats(evt:Event):Void
	{
		Starling.current.removeEventListener(Event.RENDER, updateStarlingStats);
		
		Starling.current.__statsDisplay.x = this.editView.displayRect.x;
		Starling.current.__statsDisplay.y = this.editView.displayRect.y;
	}
	#end
	
	private function centerParticles():Void
	{
		if (this._ps == null) return;
		this._ps.emitterX = this.editView.displayCenter.x;
		this._ps.emitterY = this.editView.displayCenter.y;
		this._psCollection.read();
	}
	
	// EDIT MENU
	private function onEditMenuOpen(evt:openfl.events.Event):Void
	{
		this._undoItem.enabled = ValEditor.actionStack.canUndo;
		this._redoItem.enabled = ValEditor.actionStack.canRedo;
		this._editMenuCollection.updateAll();
	}
	
	private function onEditMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "undo" :
				ValEditor.actionStack.undo();
			
			case "redo" :
				ValEditor.actionStack.redo();
		}
	}
	//\EDIT MENU
	
	// FILE MENU
	private function onFileMenuOpen(evt:openfl.events.Event):Void
	{
		
	}
	
	private function onFileMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "file_open" :
				openFile();
			
			case "file_save" :
				saveFile(false);
			
			case "file_save_as" :
				saveFile(true);
		}
	}
	//\FILE MENU
	
	// OPTIONS MENU
	private function onOptionsMenuOpen(evt:openfl.events.Event):Void
	{
		if (ValEditor.theme.darkMode)
		{
			this._uiSkinItem.text = "UI light mode";
		}
		else
		{
			this._uiSkinItem.text = "UI dark mode";
		}
		
		if (this._autoCenter)
		{
			this._autoCenterItem.text = "Auto center enabled";
		}
		else
		{
			this._autoCenterItem.text = "Auto center disabled";
		}
	}
	
	private function onOptionsMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "ui_skin" :
				ValEditor.theme.darkMode = !ValEditor.theme.darkMode;
			
			case "background_color" :
				ValEditor.actionStack.pushSession();
				FeathersWindows.showCollectionEditWindow(this._backgroundColorCollection, onBackgroundColorConfirm, onBackgroundColorCancel, "Background color", WindowSize.SMALL, WindowSize.SMALL);
			
			case "auto_center" :
				this._autoCenter = !this._autoCenter;
				if (this._autoCenter) centerParticles();
			
			case "center" :
				centerParticles();
		}
	}
	//\OPTIONS MENU
	
	// PRESETS MENU
	private function onPresetsMenuOpen(evt:openfl.events.Event):Void
	{
		
	}
	
	private function onPresetsMenuCallback(item:MenuItem):Void
	{
		applyPreset(item.id);
	}
	//\PRESETS MENU
	
	// TEXTURE MENU
	private function onTextureMenuOpen(evt:openfl.events.Event):Void
	{
		
	}
	
	private function onTextureMenuCallback(item:MenuItem):Void
	{
		applyTexture(item.id);
	}
	//\TEXTURE MENU
	
	private function newFile():Void
	{
		applyPreset("none");
		this._fullPath = null;
		this._filePath = null;
		this._fileName = "particle.json";
	}
	
	private function openFile():Void
	{
		FileController.open(fileOpen);
	}
	
	#if (desktop || air)
	private function fileOpen(file:File):Void
	{
		this._fileStream.open(file, FileMode.READ);
		var str:String = this._fileStream.readUTFBytes(this._fileStream.bytesAvailable);
		this._fileStream.close();
		var json:Dynamic = Json.parse(str);
		
		var options:ParticleSystemOptions = ParticleSystemOptions.fromPool();
		options.fromJSON(json);
		this._ps.readSystemOptions(options);
		options.pool();
		this._psCollection.read();
		
		if (this._autoCenter) centerParticles();
		
		this._fullPath = Path.normalize(file.nativePath);
		this._filePath = Path.directory(this._fullPath);
		this._fileName = Path.withoutDirectory(this._fullPath);
	}
	#else
	private function fileOpen(fileRef:FileReference):Void
	{
		var str:String = fileRef.data.readUTFBytes(fileRef.data.bytesAvailable);
		var json:Dynamic = Json.parse(str);
		
		var options:ParticleSystemOptions = ParticleSystemOptions.fromPool();
		options.fromJSON(json);
		this._ps.readSystemOptions(options);
		options.pool();
		this._psCollection.read();
		
		if (this._autoCenter) centerParticles();
		
		this._fileName = fileRef.name;
	}
	#end
	
	private function saveFile(saveAs:Bool):Void
	{
		var options:ParticleSystemOptions = ParticleSystemOptions.fromPool();
		this._ps.writeSystemOptions(options);
		var json:Dynamic = options.toJSON();
		options.pool();
		#if (desktop || air)
		FileController.save(Json.stringify(json), fileSaveComplete, null, this._fullPath, saveAs || this._filePath == null);
		#else
		FileController.save(Json.stringify(json), fileSaveComplete, null, this._fileName);
		#end
	}
	
	#if (desktop || air)
	private function fileSaveComplete(path:String):Void
	{
		this._fullPath = Path.normalize(path);
		this._filePath = Path.directory(this._fullPath);
		this._fileName = Path.withoutDirectory(this._fullPath);
	}
	#else
	private function fileSaveComplete(fileName:String):Void
	{
		this._fileName = fileName;
	}
	#end
	
	private function initInputActions():Void
	{
		var keyAction:KeyAction;
		
		// undo
		keyAction = new KeyAction(InputActionID.UNDO, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.Z, keyAction);
		
		// redo
		keyAction = new KeyAction(InputActionID.REDO, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.Y, keyAction);
		
		// save
		keyAction = new KeyAction(InputActionID.SAVE, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.S, keyAction);
		keyAction = new KeyAction(InputActionID.SAVE_AS, false, true, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.S, keyAction);
		
		// new file
		keyAction = new KeyAction(InputActionID.NEW_FILE, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.N, keyAction);
		
		// open
		keyAction = new KeyAction(InputActionID.OPEN, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.O, keyAction);
		
		ValEditor.input.addEventListener(InputActionEvent.ACTION_BEGIN, onInputActionBegin);
	}
	
	private function onInputActionBegin(evt:InputActionEvent):Void
	{
		var inputAction:InputAction = evt.action;
		
		switch (inputAction.actionID)
		{
			case InputActionID.NEW_FILE :
				
			
			case InputActionID.OPEN :
				openFile();
			
			case InputActionID.REDO :
				ValEditor.actionStack.redo();
			
			case InputActionID.SAVE :
				saveFile(false);
			
			case InputActionID.SAVE_AS :
				saveFile(true);
			
			case InputActionID.UNDO :
				ValEditor.actionStack.undo();
		}
	}
	
	private function onBackgroundColorConfirm():Void
	{
		ValEditor.actionStack.popSession();
	}
	
	private function onBackgroundColorCancel():Void
	{
		ValEditor.actionStack.currentSession.undoAll();
		ValEditor.actionStack.popSession();
	}
	
}