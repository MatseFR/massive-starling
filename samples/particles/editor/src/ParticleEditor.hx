package;

import feathers.data.ArrayCollection;
import haxe.Json;
import haxe.io.Path;
import massive.data.Frame;
import massive.display.MassiveDisplay;
import massive.particle.Particle;
import massive.particle.ParticleSystem;
import massive.particle.ParticleSystemOptions;
import openfl.Assets;
import openfl.Vector;
import openfl.utils.AssetType;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.events.Event;
import starling.textures.Texture;
import starling.utils.Align;
import valedit.ExposedCollection;
import valeditor.ValEditor;
import valeditor.data.Data;
import valeditor.editor.base.ValEditorSimpleStarling;
import valeditor.editor.file.FileController;
import valeditor.ui.feathers.data.MenuItem;
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
	private var _massive:MassiveDisplay;
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
	private var _autoCenterItem:MenuItem;
	private var _centerItem:MenuItem;
	
	// presets menu
	private var _presetsMenuCollection:ArrayCollection<MenuItem>;
	
	private var _fileName:String = "particle.json";
	private var _filePath:String;
	private var _fullPath:String;
	#if (desktop || air)
	private var _fileStream:FileStream = new FileStream();
	#end
	
	private var _autoCenter:Bool = true;
	private var _presetConfigs:Map<String, ParticleConfig> = new Map<String, ParticleConfig>();

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
	
	override function ready():Void 
	{
		super.ready();
		
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
		this._autoCenterItem = new MenuItem("auto_center", "Auto center enabled", true);
		this._centerItem = new MenuItem("center", "Center", true);
		this._optionsMenuCollection = new ArrayCollection<MenuItem>([
			this._autoCenterItem,
			this._centerItem
		]);
		this.editView.addMenu("options", "Options", onOptionsMenuCallback, onOptionsMenuOpen, this._optionsMenuCollection);
		
		// presets menu
		this._presetsMenuCollection = new ArrayCollection<MenuItem>([
			
		]);
		this.editView.addMenu("presets", "Presets", onPresetsMenuCallback, onPresetsMenuOpen, this._presetsMenuCollection);
		
		var texture:Texture;
		var frame:Frame;
		#if flash
		var frames:Vector<Frame>;
		#else
		var frames:Array<Frame>;
		#end
		
		texture = Texture.fromColor(2, 2);
		frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
		#if flash
		frames = new Vector<Frame>();
		#else
		frames = new Array<Frame>();
		#end
		frames[0] = frame;
		
		var config:ParticleConfig;
		var options:ParticleSystemOptions;
		var json:Dynamic;
		var str:String;
		
		// "none" preset
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = texture;
		config.options = new ParticleSystemOptions();
		config.addFrames(frames);
		registerPreset("none", config);
		
		// "fireball" preset
		str = Assets.getText("presets/fireball.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.ADD;
		config.texture = texture;
		config.options = options;
		config.addFrames(frames);
		registerPreset("fireball", config);
		
		// "hyperspace" preset
		str = Assets.getText("presets/hyperspace.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.ADD;
		config.texture = texture;
		config.options = options;
		config.addFrames(frames);
		registerPreset("hyperspace", config);
		
		// "space worms" preset
		str = Assets.getText("presets/space_worms.json");
		json = Json.parse(str);
		options = new ParticleSystemOptions();
		options.fromJSON(json);
		config = new ParticleConfig();
		config.blendMode = BlendMode.NORMAL;
		config.texture = texture;
		config.options = options;
		config.addFrames(frames);
		registerPreset("space worms", config);
		
		this._massive = new MassiveDisplay();
		//this._massive.blendMode = BlendMode.ADD;
		this._massive.texture = texture;
		addChild(this._massive);
		
		this._ps = new ParticleSystem<Particle>();
		#if flash
		this._ps.particlesFromPoolFunction = Particle.fromPoolVector;
		this._ps.particlesToPoolFunction = Particle.toPoolVector;
		#else
		this._ps.particlesFromPoolFunction = Particle.fromPoolArray;
		this._ps.particlesToPoolFunction = Particle.toPoolArray;
		#end
		//this._ps.addFrames(frames);
		this._massive.addLayer(this._ps);
		
		//this._ps.start();
		this._psCollection = ValEditor.edit(this._ps);
		
		applyPreset("fireball");
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
		this._psCollection.read();
		this._ps.start();
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
	
	@:access(starling.core.Starling)
	private function updateStarlingStats(evt:Event):Void
	{
		Starling.current.removeEventListener(Event.RENDER, updateStarlingStats);
		
		Starling.current.__statsDisplay.x = this.editView.displayRect.x;
		Starling.current.__statsDisplay.y = this.editView.displayRect.y;
	}
	
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
		var json:Dynamic;
		var options:ParticleSystemOptions;
		
		switch (item.id)
		{
			case "file_open" :
				FileController.open(fileOpen);
			
			case "file_save" :
				options = ParticleSystemOptions.fromPool();
				this._ps.writeSystemOptions(options);
				json = options.toJSON();
				options.pool();
				#if (desktop || air)
				FileController.save(Json.stringify(json), fileSaveComplete, null, this._fullPath, this._filePath == null);
				#else
				FileController.save(Json.stringify(json), fileSaveComplete, null, this._fileName);
				#end
			
			case "file_save_as" :
				options = ParticleSystemOptions.fromPool();
				this._ps.writeSystemOptions(options);
				json = options.toJSON();
				options.pool();
				#if (desktop || air)
				FileController.save(Json.stringify(json), fileSaveComplete, null, this._fullPath, true);
				#else
				FileController.save(Json.stringify(json), fileSaveComplete, null, this._fileName);
				#end
		}
	}
	//\FILE MENU
	
	// OPTIONS MENU
	private function onOptionsMenuOpen(evt:openfl.events.Event):Void
	{
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
	
}