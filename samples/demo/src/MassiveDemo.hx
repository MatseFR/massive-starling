package;

import massive.display.MassiveColorMode;
import massive.display.MassiveDisplay;
import massive.display.MassiveRenderMode;
import openfl.Vector;
import openfl.system.Capabilities;
import openfl.utils.Assets;
import scene.ClassicClips;
import scene.ClassicQuads;
import scene.MassiveImages;
import scene.MassiveQuads;
import scene.Scene;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.Button;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.textures.ConcreteTexture;
import starling.textures.RenderTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;

/**
 * ...
 * @author Matse
 */
class MassiveDemo extends Sprite 
{
	static public var assetManager:AssetManager;
	
	private var _sceneList:Array<Scene>;
	
	private var menuSprite:Sprite;
	private var atlasSprite:Sprite;
	private var scaleSprite:Sprite;
	private var colorModeSprite:Sprite;
	private var renderModeSprite:Sprite;
	private var classicSprite:Sprite;
	private var massiveSprite:Sprite;
	
	private var demoMenuSprite:Sprite;
	private var movementButton:Button;
	private var animationButton:Button;
	private var autoUpdateBoundsButton:Button;
	
	private var atlasIDs:Array<String> = new Array<String>();
	private var atlases:Array<TextureAtlas> = new Array<TextureAtlas>();
	private var textures:Array<Vector<Texture>> = new Array<Vector<Texture>>();
	
	private var animation:Bool = true;
	private var autoUpdateBounds:Bool = false;
	private var colorMode:String;
	private var displayScale:Float = 1.0;
	private var frameDeltaBase:Float;
	private var frameDeltaVariance:Float;
	private var frameRateBase:Int;
	private var frameRateVariance:Int;
	private var movement:Bool = true;
	private var multiTextureStyle:Bool = false;
	private var numObjects:Int;
	private var renderMode:String;
	private var useBlurFilter:Bool = false;
	private var useRandomAlpha:Bool = false;
	private var useRandomColor:Bool = false;
	private var useRandomRotation:Bool = true;
	private var useSprite3D:Bool = false;
	
	private var buttonTextureON:RenderTexture;
	private var buttonTextureOFF:RenderTexture;
	private var menuButtonTextureON:RenderTexture;
	private var menuButtonTextureOFF:RenderTexture;
	private var mediumButtonTextureON:RenderTexture;
	private var mediumButtonTextureOFF:RenderTexture;
	private var miniButtonTextureON:RenderTexture;
	private var miniButtonTextureOFF:RenderTexture;
	
	private var atlasButtons:Array<Button> = new Array<Button>();
	private var scaleButtons:Array<Button> = new Array<Button>();
	private var colorModeButtons:Array<Button> = new Array<Button>();
	private var renderModeButtons:Array<Button> = new Array<Button>();
	
	private var numAtlases:Int = 8;
	private var numClips:Array<Int> = [4000, 8000, 16000, 32000, 64000, 128000, 256000, 512000];
	private var numQuads:Array<Int> = [8000, 16000, 32000, 64000, 128000, 256000, 512000];
	private var scales:Array<Float> = [2.0, 1.0, 0.5, 0.2, 0.1];
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		this.colorMode = MassiveDisplay.defaultColorMode;
		this.renderMode = MassiveDisplay.defaultRenderMode;
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		this.stage.color = 0x333333;
		
		var assets:Array<Dynamic> = [];
		for (i in 0...numAtlases)
		{
			assets[assets.length] = Assets.getPath("img/zombi" + i + ".png");
			assets[assets.length] = Assets.getPath("img/zombi" + i + ".xml");
		}
		
		assetManager = new AssetManager();
		assetManager.verbose = Capabilities.isDebugger;
		assetManager.enqueue(assets);
		assetManager.loadQueue(assetsLoaded);
	}
	
	private function assetsLoaded():Void
	{
		trace("assetsLoaded");
		
		setAtlas("zombi0");
		
		//trace(GL.getParameter(GL.MAX_TEXTURE_SIZE));
		//trace(GL.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS));
		
		var colorUP:Int = 0xcccccc;
		var colorOVER:Int = 0xffffff;
		var quad:Quad = new Quad(230, 20);
		var menuQuad:Quad = new Quad(140, 20);
		var mediumQuad:Quad = new Quad(90, 20);
		var miniQuad:Quad = new Quad(36, 20);
		
		quad.color = colorUP;
		this.buttonTextureOFF = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		this.buttonTextureOFF.draw(quad);
		this.buttonTextureOFF.root.onRestore = function(tex:ConcreteTexture):Void
		{
			quad.color = colorUP;
			this.buttonTextureOFF.clear();
			this.buttonTextureOFF.draw(quad);
		}
		
		quad.color = colorOVER;
		this.buttonTextureON = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		this.buttonTextureON.draw(quad);
		this.buttonTextureON.root.onRestore = function(tex:ConcreteTexture):Void
		{
			quad.color = colorOVER;
			this.buttonTextureON.clear();
			this.buttonTextureON.draw(quad);
		}
		
		menuQuad.color = colorUP;
		this.menuButtonTextureOFF = new RenderTexture(Std.int(menuQuad.width), Std.int(menuQuad.height));
		this.menuButtonTextureOFF.draw(menuQuad);
		this.menuButtonTextureOFF.root.onRestore = function(tex:ConcreteTexture):Void
		{
			menuQuad.color = colorUP;
			this.menuButtonTextureOFF.clear();
			this.menuButtonTextureOFF.draw(menuQuad);
		}
		
		menuQuad.color = colorOVER;
		this.menuButtonTextureON = new RenderTexture(Std.int(menuQuad.width), Std.int(menuQuad.height));
		this.menuButtonTextureON.draw(menuQuad);
		this.menuButtonTextureON.root.onRestore = function(tex:ConcreteTexture):Void
		{
			menuQuad.color = colorOVER;
			this.menuButtonTextureON.clear();
			this.menuButtonTextureON.draw(menuQuad);
		}
		
		mediumQuad.color = colorUP;
		this.mediumButtonTextureOFF = new RenderTexture(Std.int(mediumQuad.width), Std.int(mediumQuad.height));
		this.mediumButtonTextureOFF.draw(mediumQuad);
		this.mediumButtonTextureOFF.root.onRestore = function(tex:ConcreteTexture):Void
		{
			mediumQuad.color = colorUP;
			this.mediumButtonTextureOFF.clear();
			this.mediumButtonTextureOFF.draw(mediumQuad);
		}
		
		mediumQuad.color = colorOVER;
		this.mediumButtonTextureON = new RenderTexture(Std.int(mediumQuad.width), Std.int(mediumQuad.height));
		this.mediumButtonTextureON.draw(mediumQuad);
		this.mediumButtonTextureON.root.onRestore = function(tex:ConcreteTexture):Void
		{
			mediumQuad.color = colorOVER;
			this.mediumButtonTextureON.clear();
			this.mediumButtonTextureON.draw(mediumQuad);
		}
		
		miniQuad.color = colorUP;
		this.miniButtonTextureOFF = new RenderTexture(Std.int(miniQuad.width), Std.int(miniQuad.height));
		this.miniButtonTextureOFF.draw(miniQuad);
		this.miniButtonTextureOFF.root.onRestore = function(tex:ConcreteTexture):Void
		{
			miniQuad.color = colorUP;
			this.miniButtonTextureOFF.clear();
			this.miniButtonTextureOFF.draw(miniQuad);
		}
		
		miniQuad.color = colorOVER;
		this.miniButtonTextureON = new RenderTexture(Std.int(miniQuad.width), Std.int(miniQuad.height));
		this.miniButtonTextureON.draw(miniQuad);
		this.miniButtonTextureON.root.onRestore = function(tex:ConcreteTexture):Void
		{
			miniQuad.color = colorOVER;
			this.miniButtonTextureON.clear();
			this.miniButtonTextureON.draw(miniQuad);
		}
		
		var btn:Button = null;
		var tf:TextField;
		var gap:Float = 2;
		var tX:Float;
		var tY:Float = 0;
		var demoY:Float;
		var demoGap:Float = 64;
		
		this.menuSprite = new Sprite();
		
		tf = new TextField(0, 0, "Options");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		this.atlasSprite = new Sprite();
		this.atlasSprite.y = tY;
		this.menuSprite.addChild(this.atlasSprite);
		tf = new TextField(0, 0, "atlas");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = (this.mediumButtonTextureOFF.height - tf.height) / 2;
		this.atlasSprite.addChild(tf);
		tX = tf.width + gap;
		
		var atlasID:String;
		for (i in 0...this.numAtlases)
		{
			atlasID = "zombi" + i;
			btn = new Button(this.atlasIDs.indexOf(atlasID) != -1 ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, atlasID, this.mediumButtonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btn.height) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleAtlas);
			this.atlasButtons.push(btn);
			this.atlasSprite.addChild(btn);
			tX += btn.width + gap;
		}
		
		this.atlasSprite.x = (this.buttonTextureOFF.width - this.atlasSprite.width) / 2;
		
		tY += btn.height + gap;
		btn = new Button(this.useRandomAlpha ? this.buttonTextureON : this.buttonTextureOFF, "randomize alpha", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomAlpha);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.useRandomColor ? this.buttonTextureON : this.buttonTextureOFF, "randomize color", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomColor);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.useRandomRotation ? this.buttonTextureON : this.buttonTextureOFF, "randomize rotation", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomRotation);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		this.scaleSprite = new Sprite();
		this.scaleSprite.y = tY;
		this.menuSprite.addChild(this.scaleSprite);
		tf = new TextField(0, 0, "scale");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = (btn.height - tf.height) / 2;
		this.scaleSprite.addChild(tf);
		tX = tf.width + gap;
		
		var scaleFactor:Float;
		for (i in 0...this.scales.length)
		{
			scaleFactor = this.scales[i];
			
			btn = new Button(this.displayScale == scaleFactor ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(scaleFactor), null, this.miniButtonTextureON);
			btn.x = tX;
			btn.y = tf.y + (tf.height - btn.height) / 2;
			btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
			this.scaleButtons.push(btn);
			this.scaleSprite.addChild(btn);
			tX += btn.width + gap;
		}
		
		tY += btn.height + gap;
		btn = new Button(this.useSprite3D ? this.buttonTextureON : this.buttonTextureOFF, "Sprite3D", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleSprite3D);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.useBlurFilter ? this.buttonTextureON : this.buttonTextureOFF, "BlurFilter", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleBlurFilter);
		this.menuSprite.addChild(btn);
		
		this.scaleSprite.x = (this.buttonTextureOFF.width - this.scaleSprite.width) / 2;
		
		tY += btn.height + gap * 2;
		tf = new TextField(0, 0, "Massive options");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		this.renderModeSprite = new Sprite();
		this.renderModeSprite.y = tY;
		this.menuSprite.addChild(this.renderModeSprite);
		tf = new TextField(0, 0, "renderMode");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = (btn.height - tf.height) / 2;
		this.renderModeSprite.addChild(tf);
		tX = tf.width + gap;
		
		btn = new Button(this.renderMode == MassiveRenderMode.BYTEARRAY ? this.buttonTextureON : this.buttonTextureOFF, "ByteArray", null, this.buttonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
		this.renderModeButtons.push(btn);
		this.renderModeSprite.addChild(btn);
		
		#if flash
		tX += btn.width + gap;
		btn = new Button(this.renderMode == MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY ? this.buttonTextureON : this.buttonTextureOFF, "DomainMemoryByteArray", null, this.buttonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
		this.renderModeButtons.push(btn);
		this.renderModeSprite.addChild(btn);
		#end
		
		#if !flash
		tX += btn.width + gap;
		btn = new Button(this.renderMode == MassiveRenderMode.FLOAT32ARRAY ? this.buttonTextureON : this.buttonTextureOFF, "Float32Array", null, this.buttonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
		this.renderModeButtons.push(btn);
		this.renderModeSprite.addChild(btn);
		#end
		
		tX += btn.width + gap;
		btn = new Button(this.renderMode == MassiveRenderMode.VECTOR ? this.buttonTextureON : this.buttonTextureOFF, "Vector", null, this.buttonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
		this.renderModeButtons.push(btn);
		this.renderModeSprite.addChild(btn);
		
		this.renderModeSprite.x = (this.buttonTextureOFF.width - this.renderModeSprite.width) / 2;
		
		tY += btn.height + gap;
		this.colorModeSprite = new Sprite();
		this.colorModeSprite.y = tY;
		this.menuSprite.addChild(this.colorModeSprite);
		tf = new TextField(0, 0, "colorMode");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = (btn.height - tf.height) / 2;
		this.colorModeSprite.addChild(tf);
		tX = tf.width + gap;
		
		btn = new Button(this.colorMode == MassiveColorMode.NONE ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "none", null, this.mediumButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleColorMode);
		this.colorModeButtons.push(btn);
		this.colorModeSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.colorMode == MassiveColorMode.REGULAR ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "regular", null, this.mediumButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleColorMode);
		this.colorModeButtons.push(btn);
		this.colorModeSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.colorMode == MassiveColorMode.EXTENDED ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "extended", null, this.mediumButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleColorMode);
		this.colorModeButtons.push(btn);
		this.colorModeSprite.addChild(btn);
		
		this.colorModeSprite.x = (this.buttonTextureOFF.width - this.colorModeSprite.width) / 2;
		
		tY += btn.height + gap * 2;
		tf = new TextField(0, 0, "Starling options");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		btn = new Button(this.multiTextureStyle ? this.buttonTextureON : this.buttonTextureOFF, "MultiTextureStyle", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleMultiTextureStyle);
		this.menuSprite.addChild(btn);
		
		tY += btn.height * 2 + gap * 4;
		demoY = tY + btn.height + gap * 2;
		
		// CLASSIC STARLING
		this.classicSprite = new Sprite();
		this.classicSprite.y = demoY;
		this.classicSprite.x = -this.buttonTextureOFF.width / 2 - demoGap;
		this.menuSprite.addChild(this.classicSprite);
		tY = 0;
		
		tf = new TextField(0, 0, "Classic Starling");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.classicSprite.addChild(tf);
		tY += tf.height + gap;
		
		for (i in 0...this.numClips.length)
		{
			if (i != 0) tY += btn.height + gap;
			btn = new Button(this.buttonTextureOFF, this.numClips[i] + " clips", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, classicClips);
			this.classicSprite.addChild(btn);
		}
		
		tY += btn.height + gap * 4;
		
		for (i in 0...this.numQuads.length)
		{
			if (i != 0) tY += btn.height + gap;
			btn = new Button(this.buttonTextureOFF, this.numQuads[i] + " quads", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, classicQuads);
			this.classicSprite.addChild(btn);
		}
		//\CLASSIC STARLING
		
		// MASSIVE STARLING
		this.massiveSprite = new Sprite();
		this.massiveSprite.y = demoY;
		this.massiveSprite.x = this.buttonTextureOFF.width / 2 + demoGap;
		this.menuSprite.addChild(this.massiveSprite);
		tY = 0;
		
		tf = new TextField(0, 0, "Massive Starling");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.massiveSprite.addChild(tf);
		tY += tf.height + gap;
		
		for (i in 0...this.numClips.length)
		{
			if (i != 0) tY += btn.height + gap;
			btn = new Button(this.buttonTextureOFF, this.numClips[i] + " clips", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, massiveClips);
			this.massiveSprite.addChild(btn);
		}
		
		tY += btn.height + gap * 4;
		
		for (i in 0...this.numQuads.length)
		{
			if (i != 0) tY += btn.height + gap;
			btn = new Button(this.buttonTextureOFF, this.numQuads[i] + " quads", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, massiveQuads);
			this.massiveSprite.addChild(btn);
		}
		//\MASSIVE STARLING
		
		tY = this.massiveSprite.y + this.massiveSprite.height + gap * 4;
		tf = new TextField(0, 0, "zombi assets from www.kenney.nl");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		
		this.demoMenuSprite = new Sprite();
		
		tY = 0;
		btn = new Button(this.menuButtonTextureOFF, "Menu", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, backToMenu);
		this.demoMenuSprite.addChild(btn);
		
		tY += btn.height + gap * 4;
		btn = new Button(this.movement ? this.menuButtonTextureON : this.menuButtonTextureOFF, "Movement", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleMovement);
		this.demoMenuSprite.addChild(btn);
		this.movementButton = btn;
		
		tY += btn.height + gap;
		btn = new Button(this.animation ? this.menuButtonTextureON : this.menuButtonTextureOFF, "Animation", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleAnimation);
		this.demoMenuSprite.addChild(btn);
		this.animationButton = btn;
		
		tY += btn.height + gap;
		btn = new Button(this.autoUpdateBounds ? this.menuButtonTextureON : this.menuButtonTextureOFF, "autoUpdateBounds", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleAutoUpdateBounds);
		this.demoMenuSprite.addChild(btn);
		this.autoUpdateBoundsButton = btn;
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
		
		updateUIPositions();
		showMenu();
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
		updateUIPositions();
		
		if (this._sceneList != null)
		{
			for (scene in this._sceneList)
			{
				scene.updateBounds();
			}
		}
	}

	private function updateViewPort(width:Int, height:Int):Void 
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		this.stage.stageWidth  = Std.int(width  / scale);
		this.stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width  = this.stage.stageWidth  * scale;
		current.viewPort.height = this.stage.stageHeight * scale;
	}
	
	private function updateUIPositions():Void
	{
		this.menuSprite.x = (this.stage.stageWidth - this.buttonTextureON.width) / 2;
		this.menuSprite.y = (this.stage.stageHeight - this.menuSprite.height) / 2;
		
		var spacing:Float = 8;
		this.demoMenuSprite.x = this.stage.stageWidth - this.demoMenuSprite.width - spacing;
		this.demoMenuSprite.y = spacing;
	}
	
	private function showMenu():Void
	{
		addChild(this.menuSprite);
	}
	
	private function hideMenu():Void
	{
		removeChild(this.menuSprite);
	}
	
	private function showSceneList(scenes:Array<Scene>):Void
	{
		hideMenu();
		
		this._sceneList = scenes;
		for (scene in this._sceneList)
		{
			addChild(scene);
		}
		
		addChild(this.demoMenuSprite);
	}
	
	private function backToMenu(evt:Event):Void
	{
		for (scene in this._sceneList)
		{
			scene.removeFromParent(true);
		}
		this._sceneList = null;
		
		this.demoMenuSprite.removeFromParent();
		
		showMenu();
	}
	
	private function toggleAnimation(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.animation = !this.animation;
		if (this._sceneList.length != 0)
		{
			this._sceneList[0].animation = this.animation;
		}
		if (this.animation)
		{
			btn.upState = this.menuButtonTextureON;
		}
		else
		{
			btn.upState = this.menuButtonTextureOFF;
		}
	}
	
	private function toggleAtlas(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		var index:Int = this.atlasIDs.indexOf(btn.text);
		if (index == -1)
		{
			setAtlas(btn.text);
			btn.upState = this.miniButtonTextureON;
		}
		else if (this.atlasIDs.length > 1)
		{
			this.atlasIDs.splice(index, 1);
			this.atlases.splice(index, 1);
			this.textures.splice(index, 1);
			btn.upState = this.miniButtonTextureOFF;
		}
	}
	
	private function setAtlas(id:String):Void
	{
		this.atlasIDs.push(id);
		var atlas:TextureAtlas;
		
		switch (id)
		{
			case "bird" :
				atlas = assetManager.getTextureAtlas("starling_bird");
				this.atlases.push(atlas);
				this.textures.push(atlas.getTextures("0"));
				this.frameDeltaBase = 0.05;
				this.frameDeltaVariance = 0.25;
				this.frameRateBase = 3;
				this.frameRateVariance = 15;
			
			default :
				atlas = assetManager.getTextureAtlas(id);
				this.atlases.push(atlas);
				this.textures.push(atlas.getTextures("character"));
				this.frameDeltaBase = 0.05;
				this.frameDeltaVariance = 0.25;
				this.frameRateBase = 3;
				this.frameRateVariance = 15;
		}
	}
	
	private function toggleAutoUpdateBounds(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.autoUpdateBounds = !this.autoUpdateBounds;
		if (this._sceneList.length != 0)
		{
			this._sceneList[0].autoUpdateBounds = this.autoUpdateBounds;
		}
		if (this.autoUpdateBounds)
		{
			btn.upState = this.menuButtonTextureON;
		}
		else
		{
			btn.upState = this.menuButtonTextureOFF;
		}
	}
	
	private function toggleBlurFilter(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useBlurFilter = !this.useBlurFilter;
		if (this.useBlurFilter)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleColorMode(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.colorModeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.mediumButtonTextureOFF;
		}
		
		switch (btn.text)
		{
			case "extended" :
				this.colorMode = MassiveColorMode.EXTENDED;
			
			case "none" :
				this.colorMode = MassiveColorMode.NONE;
			
			case "regular" :
				this.colorMode = MassiveColorMode.REGULAR;
		}
		btn.upState = this.mediumButtonTextureON;
	}
	
	private function toggleDisplayScale(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.scaleButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.miniButtonTextureOFF;
		}
		
		this.displayScale = Std.parseFloat(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function toggleMovement(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.movement = !this.movement;
		if (this._sceneList.length != 0)
		{
			this._sceneList[0].movement = this.movement;
		}
		if (this.movement)
		{
			btn.upState = this.menuButtonTextureON;
		}
		else
		{
			btn.upState = this.menuButtonTextureOFF;
		}
	}
	
	private function toggleMultiTextureStyle(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.multiTextureStyle = !this.multiTextureStyle;
		if (this.multiTextureStyle)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleRandomAlpha(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useRandomAlpha = !this.useRandomAlpha;
		if (this.useRandomAlpha)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleRandomColor(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useRandomColor = !this.useRandomColor;
		if (this.useRandomColor)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleRandomRotation(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useRandomRotation = !this.useRandomRotation;
		if (this.useRandomRotation)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleRenderMode(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.renderModeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.buttonTextureOFF;
		}
		
		switch (btn.text)
		{
			case "ByteArray" :
				this.renderMode = MassiveRenderMode.BYTEARRAY;
			
			#if flash
			case "DomainMemoryByteArray" :
				this.renderMode = MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY;
			#end
			
			#if !flash
			case "Float32Array" :
				this.renderMode = MassiveRenderMode.FLOAT32ARRAY;
			#end
			
			case "Vector" :
				this.renderMode = MassiveRenderMode.VECTOR;
		}
		btn.upState = this.buttonTextureON;
	}
	
	private function toggleSprite3D(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useSprite3D = !this.useSprite3D;
		if (this.useSprite3D)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function startMassiveImages():Void
	{
		this.movementButton.enabled = true;
		this.animationButton.enabled = true;
		this.autoUpdateBoundsButton.enabled = true;
		
		var massive:MassiveImages = new MassiveImages();
		massive.animation = this.animation;
		massive.movement = this.movement;
		massive.autoUpdateBounds = this.autoUpdateBounds;
		massive.addAtlases(this.atlases);
		massive.textures = this.textures;
		massive.imgScale = this.displayScale;
		massive.numObjects = this.numObjects;
		massive.colorMode = this.colorMode;
		massive.renderMode = this.renderMode;
		massive.useBlurFilter = this.useBlurFilter;
		massive.useRandomAlpha = this.useRandomAlpha;
		massive.useRandomColor = this.useRandomColor;
		massive.useRandomRotation = this.useRandomRotation;
		massive.useSprite3D = this.useSprite3D;
		
		showSceneList([massive]);
	}
	
	private function startMassiveQuads():Void
	{
		this.movementButton.enabled = true;
		this.animationButton.enabled = false;
		this.autoUpdateBoundsButton.enabled = true;
		
		var massive:MassiveQuads = new MassiveQuads();
		massive.animation = this.animation;
		massive.movement = this.movement;
		massive.autoUpdateBounds = this.autoUpdateBounds;
		massive.displayScale = this.displayScale;
		massive.numObjects = this.numObjects;
		massive.colorMode = this.colorMode;
		massive.renderMode = this.renderMode;
		massive.useBlurFilter = this.useBlurFilter;
		massive.useRandomAlpha = this.useRandomAlpha;
		massive.useRandomColor = this.useRandomColor;
		massive.useRandomRotation = this.useRandomRotation;
		massive.useSprite3D = this.useSprite3D;
		
		showSceneList([massive]);
	}
	
	private function startClassicClips():Void
	{
		this.movementButton.enabled = true;
		this.animationButton.enabled = true;
		this.autoUpdateBoundsButton.enabled = false;
		
		var clips:ClassicClips = new ClassicClips();
		clips.animation = this.animation;
		clips.movement = this.movement;
		clips.textures = this.textures;
		clips.multiTextureStyle = this.multiTextureStyle;
		clips.numClips = this.numObjects;
		clips.clipScale = this.displayScale;
		clips.useBlurFilter = this.useBlurFilter;
		clips.useRandomAlpha = this.useRandomAlpha;
		clips.useRandomColor = this.useRandomColor;
		clips.useRandomRotation = this.useRandomRotation;
		clips.useSprite3D = this.useSprite3D;
		showSceneList([clips]);
	}
	
	private function startClassicQuads():Void
	{
		this.movementButton.enabled = true;
		this.animationButton.enabled = false;
		this.autoUpdateBoundsButton.enabled = false;
		
		var quads:ClassicQuads = new ClassicQuads();
		quads.animation = this.animation;
		quads.movement = this.movement;
		quads.numQuads = this.numObjects;
		quads.displayScale = this.displayScale;
		quads.useBlurFilter = this.useBlurFilter;
		quads.useRandomAlpha = this.useRandomAlpha;
		quads.useRandomColor = this.useRandomColor;
		quads.useRandomRotation = this.useRandomRotation;
		quads.useSprite3D = this.useSprite3D;
		showSceneList([quads]);
	}
	
	private function classicClips(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		var index:Int = btn.text.indexOf(" ");
		this.numObjects = Std.parseInt(btn.text.substring(0, index));
		startClassicClips();
	}
	
	private function classicQuads(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		var index:Int = btn.text.indexOf(" ");
		this.numObjects = Std.parseInt(btn.text.substring(0, index));
		startClassicQuads();
	}
	
	private function massiveClips(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		var index:Int = btn.text.indexOf(" ");
		this.numObjects = Std.parseInt(btn.text.substring(0, index));
		startMassiveImages();
	}
	
	private function massiveQuads(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		var index:Int = btn.text.indexOf(" ");
		this.numObjects = Std.parseInt(btn.text.substring(0, index));
		startMassiveQuads();
	}
	
}