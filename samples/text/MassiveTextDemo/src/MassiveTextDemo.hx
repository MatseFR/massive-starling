package;

import feathers.data.ArrayCollection;
import feathers.layout.AutoSizeMode;
import inputAction.InputAction;
import inputAction.controllers.KeyAction;
import inputAction.events.InputActionEvent;
import massive.display.ImgContainer;
import massive.display.MassiveDisplay;
import massive.display.color.ColorMode;
import massive.display.color.ColorOffsetMode;
import massive.display.render.RenderMode;
import massive.text.MassiveFont;
import massive.text.MassiveText;
import massive.text.Text;
import massive.text.TextAlign;
import massive.text.TextField;
import massive.text.TextFormat;
import massive.text.TextOptions;
import massive.text.internal.TextLayoutResult;
import massive.text.lang.LangRules;
import massive.text.lang.LatinDefaultRules;
import openfl.Assets;
import openfl.ui.Keyboard;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.events.Event;
import starling.textures.TextureSmoothing;
import valedit.ExposedCollection;
import valedit.value.ExposedFloatDrag;
import valedit.value.ExposedSelect;
import valeditor.ValEditor;
import valeditor.data.Data;
import valeditor.editor.base.ValEditorSimpleStarling;
import valeditor.input.InputActionID;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.view.SimpleEditViewToggleGroups;

/**
 * ...
 * @author Matse
 */
class MassiveTextDemo extends ValEditorSimpleStarling 
{
	private var _display:MassiveDisplay;
	private var _displayCollection:ExposedCollection;
	private var _container:ImgContainer;
	private var _font:MassiveFont;
	private var _format:TextFormat;
	private var _options:TextOptions;
	private var _langRules:LangRules;
	
	private var _tf:TextField;
	private var _tfCollection:ExposedCollection;
	private var _text:Text;
	private var _result:TextLayoutResult;
	
	private var _assetManager:AssetManager;
	
	private var _autoCenter:Bool = true;
	private var _autoFill:Bool = true;
	
	// edit menu
	private var _editMenuCollection:ArrayCollection<MenuItem>;
	private var _undoItem:MenuItem;
	private var _redoItem:MenuItem;
	
	// options menu
	private var _optionsMenuCollection:ArrayCollection<MenuItem>;
	private var _uiSkinItem:MenuItem;
	private var _autoFillItem:MenuItem;
	private var _autoCenterItem:MenuItem;
	private var _centerItem:MenuItem;

	public function new() 
	{
		super();
	}
	
	override function exposeData():Void 
	{
		Data.exposeMassive();
		Data.exposeStarling();
	}
	
	override public function start():Void 
	{
		this.editView = new SimpleEditViewToggleGroups();
		this.editView.autoSizeMode = AutoSizeMode.STAGE;
		
		super.start();
	}
	
	override function ready():Void 
	{
		super.ready();
		
		this._assetManager = new AssetManager();
		this._assetManager.enqueue([
			Assets.getPath("font/arial/arial_12.fnt"),
			Assets.getPath("font/arial/arial_12.png"),
			Assets.getPath("font/arial/arial_12_bold.fnt"),
			Assets.getPath("font/arial/arial_12_bold.png"),
			Assets.getPath("font/arial/arial_12_italic.fnt"),
			Assets.getPath("font/arial/arial_12_italic.png"),
			
			Assets.getPath("font/arial/arial_16.fnt"),
			Assets.getPath("font/arial/arial_16.png"),
			Assets.getPath("font/arial/arial_16_bold.fnt"),
			Assets.getPath("font/arial/arial_16_bold.png"),
			Assets.getPath("font/arial/arial_16_italic.fnt"),
			Assets.getPath("font/arial/arial_16_italic.png")
		]);
		this._assetManager.loadQueue(assetsLoaded);
	}
	
	private function assetsLoaded():Void
	{
		initInputActions();
		
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
		this._autoFillItem = new MenuItem("auto_fill", "Auto fill enabled", true);
		this._autoCenterItem = new MenuItem("auto_center", "Auto center enabled", true);
		this._centerItem = new MenuItem("center", "Center", true);
		this._optionsMenuCollection = new ArrayCollection<MenuItem>([
			this._uiSkinItem,
			this._autoFillItem,
			this._autoCenterItem,
			this._centerItem
		]);
		this.editView.addMenu("options", "Options", onOptionsMenuCallback, onOptionsMenuOpen, this._optionsMenuCollection);
		
		cast(this.editView, SimpleEditViewToggleGroups).addToggleGroup("MassiveDisplay", "DISPLAY", false);
		cast(this.editView, SimpleEditViewToggleGroups).addToggleGroup("TextField", "TEXTFIELD", true);
		cast(this.editView, SimpleEditViewToggleGroups).rightContainer.maxWidth = 600;
		cast(this.editView, SimpleEditViewToggleGroups).rightContainer.width = 450;
		
		MassiveDisplay.init();
		
		this._display = new MassiveDisplay();
		addChild(this._display);
		
		var font:MassiveFont;
		
		font = new MassiveFont("arial 12");
		font.createFontStyle("regular", this._assetManager.getTexture("arial_12"), this._assetManager.getXml("arial_12"));
		font.createFontStyle("bold", this._assetManager.getTexture("arial_12_bold"), this._assetManager.getXml("arial_12_bold"));
		font.createFontStyle("italic", this._assetManager.getTexture("arial_12_italic"), this._assetManager.getXml("arial_12_italic"));
		MassiveText.registerFont(font);
		
		this._display.addTextures(font.textures, true, TextureSmoothing.NONE);
		
		font = new MassiveFont("arial 16");
		font.createFontStyle("regular", this._assetManager.getTexture("arial_16"), this._assetManager.getXml("arial_16"));
		font.createFontStyle("bold", this._assetManager.getTexture("arial_16_bold"), this._assetManager.getXml("arial_16_bold"));
		font.createFontStyle("italic", this._assetManager.getTexture("arial_16_italic"), this._assetManager.getXml("arial_16_italic"));
		MassiveText.registerFont(font);
		
		this._display.addTextures(font.textures, true, TextureSmoothing.NONE);
		
		this._format = new TextFormat(font.name, "regular", font.size, 0xffffff, TextAlign.JUSTIFY);
		//this._format = new TextFormat("mini", "default", this._font.size * 4, 0xffffff, TextAlign.JUSTIFY);
		
		this._options = new TextOptions();
		this._options.padding = 24;
		this._options.wordWrap = false;
		
		this._langRules = new LatinDefaultRules();
		
		var str:String;
		//str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
		//str += "\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?";
		//str = "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?";
		//str += "\n\nOn the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.";
		
		//str = "over-confident master-builder ";
		//for (i in 0...20)
		//{
			//str += "over-confident master-builder ";
		//}
		str = 'Here is some text !{"format":{"color":"0xff0000"}}!and here is some text in !{"format":{"style":"bold"}}!red!{"format":{"style":"regular"}}! which will !{"format":{"style":"italic"}}!suddenly!{"format":{"style":"regular"}}! switch back to !{"format":{"color":"0xffffff"}}!white again and then go!{"format":{"color":"0xffff00", "style":"bold"}}! yellow !{"format":{"style":"regular"}}!because why not... !{"format":{"color":"0x00ffff", "style":"italic"}}!Or electric blue maybe ?';
		
		var textWidth:Float = this.editView.displayRect.width;
		var textHeight:Float = this.editView.displayRect.height;
		this._tf = new TextField(null, this._format, this._options, textWidth, textHeight);
		this._tf.textDataSafeMode = true;
		this._tf.x = this.editView.displayRect.x;
		this._tf.y = this.editView.displayRect.y;
		this._tf.textData = str;
		this._display.addLayer(this._tf);
		
		this._tfCollection = ValEditor.edit(this._tf, null, this.editView.getEditContainer("TextField"));
		
		// MassiveDisplay collection
		// we're only interested in a few properties so we create a custom collection
		var float:ExposedFloatDrag;
		var select:ExposedSelect;
		
		this._displayCollection = new ExposedCollection();
		
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
		this._displayCollection.addValue(select);
		
		select = new ExposedSelect("renderMode");
		select.choiceListFunction = RenderMode.getValues;
		select.valueListFunction = RenderMode.getValues;
		this._displayCollection.addValue(select);
		
		select = new ExposedSelect("colorMode");
		select.choiceListFunction = ColorMode.getValues;
		select.valueListFunction = ColorMode.getValues;
		this._displayCollection.addValue(select);
		
		float = new ExposedFloatDrag("red", null, null, null, 0.01);
		this._displayCollection.addValue(float);
		
		float = new ExposedFloatDrag("green", null, null, null, 0.01);
		this._displayCollection.addValue(float);
		
		float = new ExposedFloatDrag("blue", null, null, null, 0.01);
		this._displayCollection.addValue(float);
		
		float = new ExposedFloatDrag("alpha", null, null, null, 0.01);
		this._displayCollection.addValue(float);
		
		select = new ExposedSelect("colorOffsetMode");
		select.choiceListFunction = ColorOffsetMode.getValues;
		select.valueListFunction = ColorOffsetMode.getValues;
		this._displayCollection.addValue(select);
		
		float = new ExposedFloatDrag("redOffset", null, -10.0, 10.0, 0.01);
		this._displayCollection.addValue(float);
		
		float = new ExposedFloatDrag("greenOffset", null, -10.0, 10.0, 0.01);
		this._displayCollection.addValue(float);
		
		float = new ExposedFloatDrag("blueOffset", null, -10.0, 10.0, 0.01);
		this._displayCollection.addValue(float);
		
		float = new ExposedFloatDrag("alphaOffset", null, -10.0, 10.0, 0.01);
		this._displayCollection.addValue(float);
		
		ValEditor.edit(this._display, this._displayCollection, this.editView.getEditContainer("MassiveDisplay"));
		//\MassiveDisplay collection
	}
	
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
		
		if (this._autoFill) fillDisplayArea();
		if (this._autoCenter) centerTextField();
		
		if (this._tfCollection != null) this._tfCollection.read();
	}
	
	private function centerTextField():Void
	{
		if (this._tf != null)
		{
			this._tf.x = Math.fround(this.editView.displayRect.x + (this.editView.displayRect.width - this._tf.width) / 2.0);
			this._tf.y = Math.fround(this.editView.displayRect.y + (this.editView.displayRect.height - this._tf.height) / 2.0);
		}
	}
	
	private function fillDisplayArea():Void
	{
		if (this._tf != null)
		{
			this._tf.x = this.editView.displayRect.x;
			this._tf.y = this.editView.displayRect.y;
			this._tf.width = this.editView.displayRect.width;
			this._tf.height = this.editView.displayRect.height;
		}
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
	
	private function onEditMenuOpen(evt:openfl.events.Event):Void
	{
		this._undoItem.enabled = ValEditor.actionStack.canUndo;
		this._redoItem.enabled = ValEditor.actionStack.canRedo;
		this._editMenuCollection.updateAll();
	}
	
	private function onOptionsMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "ui_skin" :
				ValEditor.theme.darkMode = !ValEditor.theme.darkMode;
			
			case "auto_fill" :
				this._autoFill = !this._autoFill;
				if (this._autoFill) fillDisplayArea();
			
			case "auto_center" :
				this._autoCenter = !this._autoCenter;
				if (this._autoCenter) centerTextField();
			
			case "center" :
				centerTextField();
		}
	}
	
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
		
		if (this._autoFill)
		{
			this._autoFillItem.text = "Auto fill enabled";
		}
		else
		{
			this._autoFillItem.text = "Auto fill disabled";
		}
	}
	
	private function initInputActions():Void
	{
		var keyAction:KeyAction;
		
		// undo
		keyAction = new KeyAction(InputActionID.UNDO, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.Z, keyAction);
		
		// redo
		keyAction = new KeyAction(InputActionID.REDO, false, true);
		ValEditor.keyboardController.addKeyAction(Keyboard.Y, keyAction);
		
		ValEditor.input.addEventListener(InputActionEvent.ACTION_BEGIN, onInputActionBegin);
	}
	
	private function onInputActionBegin(evt:InputActionEvent):Void
	{
		var inputAction:InputAction = evt.action;
		
		switch (inputAction.actionID)
		{
			case InputActionID.REDO :
				ValEditor.actionStack.redo();
			
			case InputActionID.UNDO :
				ValEditor.actionStack.undo();
		}
	}
}