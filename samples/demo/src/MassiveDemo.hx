package;

import massive.util.LookUp;
import openfl.Vector;
import openfl.system.Capabilities;
import openfl.utils.Assets;
import scene.ClassicQuads;
import scene.MassiveImages;
import scene.MassiveQuads;
import scene.MovieClips;
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
	private var bufferSprite:Sprite;
	private var classicSprite:Sprite;
	private var massiveSprite:Sprite;
	private var backButton:Button;
	
	private var atlasID:String;
	private var atlas:TextureAtlas;
	private var textures:Vector<Texture>;
	
	private var displayScale:Float = 1.0;
	private var frameDeltaBase:Float;
	private var frameDeltaVariance:Float;
	private var frameRateBase:Int;
	private var frameRateVariance:Int;
	private var numBuffers:Int = 1;
	private var numObjects:Int;
	private var useBlurFilter:Bool = false;
	private var useByteArray:Bool = false;
	#if !flash
	private var useFloat32Array:Bool = true;
	#end
	private var useColor:Bool = true;
	private var useRandomAlpha:Bool = false;
	private var useRandomColor:Bool = false;
	private var useRandomRotation:Bool = true;
	private var useSprite3D:Bool = false;
	
	private var buttonTextureON:RenderTexture;
	private var buttonTextureOFF:RenderTexture;
	private var mediumButtonTextureON:RenderTexture;
	private var mediumButtonTextureOFF:RenderTexture;
	private var miniButtonTextureON:RenderTexture;
	private var miniButtonTextureOFF:RenderTexture;
	
	private var atlasButtons:Array<Button> = new Array<Button>();
	private var scaleButtons:Array<Button> = new Array<Button>();
	private var buffersButtons:Array<Button> = new Array<Button>();
	private var dataModeButtons:Array<Button> = new Array<Button>();
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		this.stage.color = 0x333333;
		
		assetManager = new AssetManager();
		assetManager.verbose = Capabilities.isDebugger;
		assetManager.enqueue([
			Assets.getPath("img/starling_bird.png"),
			Assets.getPath("img/starling_bird.xml"),
			Assets.getPath("img/zombi_walk.png"),
			Assets.getPath("img/zombi_walk.xml")
			
		]);
		assetManager.loadQueue(assetsLoaded);
	}
	
	private function assetsLoaded():Void
	{
		trace("assetsLoaded");
		
		LookUp.init();
		
		setAtlas("zombi");
		
		var colorUP:Int = 0xcccccc;
		var colorOVER:Int = 0xffffff;
		var quad:Quad = new Quad(250, 20);
		var mediumQuad:Quad = new Quad(90, 20);
		var miniQuad:Quad = new Quad(36, 20);
		//var backQuad:Quad = new Quad(100, 20);
		
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
		
		var btn:Button;
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
		
		btn = new Button(this.atlasID == "zombi" ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "zombi", this.mediumButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleAtlas);
		this.atlasButtons.push(btn);
		this.atlasSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.atlasID == "bird" ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, "bird", this.mediumButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleAtlas);
		this.atlasButtons.push(btn);
		this.atlasSprite.addChild(btn);
		
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
		
		btn = new Button(this.displayScale == 2.0 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "2.0", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
		this.scaleButtons.push(btn);
		this.scaleSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.displayScale == 1.0 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "1.0", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
		this.scaleButtons.push(btn);
		this.scaleSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.displayScale == 0.5 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "0.5", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
		this.scaleButtons.push(btn);
		this.scaleSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.displayScale == 0.2 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "0.2", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
		this.scaleButtons.push(btn);
		this.scaleSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.displayScale == 0.1 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "0.1", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
		this.scaleButtons.push(btn);
		this.scaleSprite.addChild(btn);
		
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
		
		tY += btn.height + gap;
		tf = new TextField(0, 0, "Massive options");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		btn = new Button(this.useColor ? this.buttonTextureON : this.buttonTextureOFF, "use Color", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleColor);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.useByteArray ? this.buttonTextureON : this.buttonTextureOFF, "use ByteArray", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleDataMode);
		this.dataModeButtons.push(btn);
		this.menuSprite.addChild(btn);
		
		#if !flash
		tY += btn.height + gap;
		btn = new Button(this.useFloat32Array ? this.buttonTextureON : this.buttonTextureOFF, "use Float32Array", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleDataMode);
		this.dataModeButtons.push(btn);
		this.menuSprite.addChild(btn);
		#end
		
		tY += btn.height + gap;
		this.bufferSprite = new Sprite();
		this.bufferSprite.y = tY;
		this.menuSprite.addChild(this.bufferSprite);
		tf = new TextField(0, 0, "buffers");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = (btn.height - tf.height) / 2;
		this.bufferSprite.addChild(tf);
		tX = tf.width + gap;
		
		btn = new Button(this.numBuffers == 1 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "1", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleBuffers);
		this.buffersButtons.push(btn);
		this.bufferSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.numBuffers == 2 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "2", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleBuffers);
		this.buffersButtons.push(btn);
		this.bufferSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.numBuffers == 3 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "3", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleBuffers);
		this.buffersButtons.push(btn);
		this.bufferSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = new Button(this.numBuffers == 4 ? this.miniButtonTextureON : this.miniButtonTextureOFF, "4", null, this.miniButtonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btn.height) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleBuffers);
		this.buffersButtons.push(btn);
		this.bufferSprite.addChild(btn);
		
		this.bufferSprite.x = (this.buttonTextureOFF.width - this.bufferSprite.width) / 2;
		
		tY += btn.height + gap * 4;
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
		
		btn = new Button(this.buttonTextureOFF, "4000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, movieClips4k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "8000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, movieClips8k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "16000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, movieClips16k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "32000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, movieClips32k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "64000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, movieClips64k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "128000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, movieClips128k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "256000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, movieClips256k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap * 4;
		btn = new Button(this.buttonTextureOFF, "8000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads8k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "16000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads16k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "32000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads32k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "64000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads64k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "128000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads128k);
		this.classicSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "256000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads256k);
		this.classicSprite.addChild(btn);
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
		
		btn = new Button(this.buttonTextureOFF, "4000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveClips4k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "8000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveClips8k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "16000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveClips16k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "32000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveClips32k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "64000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveClips64k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "128000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveClips128k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "256000 clips", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveClips256k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap * 4;
		btn = new Button(this.buttonTextureOFF, "8000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads8k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "16000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads16k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "32000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads32k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "64000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads64k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "128000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads128k);
		this.massiveSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "256000 quads", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads256k);
		this.massiveSprite.addChild(btn);
		//\MASSIVE STARLING
		
		tY = this.massiveSprite.y + this.massiveSprite.height + gap * 4;
		tf = new TextField(0, 0, "zombi assets from www.kenney.nl");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		
		//quad.width = 100;
		//quad.color = colorUP;
		//textureUP = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		//textureUP.draw(quad);
		//
		//quad.color = colorOVER;
		//textureOVER = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		//textureOVER.draw(quad);
		
		this.backButton = new Button(this.mediumButtonTextureOFF, "Menu", null, this.mediumButtonTextureON);
		this.backButton.addEventListener(Event.TRIGGERED, backToMenu);
		
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
		this.backButton.x = this.stage.stageWidth - this.backButton.width - spacing;
		this.backButton.y = spacing;
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
		
		addChild(this.backButton);
	}
	
	private function backToMenu(evt:Event):Void
	{
		for (scene in this._sceneList)
		{
			scene.removeFromParent(true);
		}
		this._sceneList = null;
		
		this.backButton.removeFromParent();
		
		showMenu();
	}
	
	private function toggleAtlas(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.atlasButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.mediumButtonTextureOFF;
		}
		
		setAtlas(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function setAtlas(id:String):Void
	{
		this.atlasID = id;
		
		switch (this.atlasID)
		{
			case "bird" :
				this.atlas = assetManager.getTextureAtlas("starling_bird");
				this.textures = this.atlas.getTextures("0");
				this.frameDeltaBase = 0.05;
				this.frameDeltaVariance = 0.25;
				this.frameRateBase = 3;
				this.frameRateVariance = 15;
			
			case "zombi" :
				this.atlas = assetManager.getTextureAtlas("zombi_walk");
				this.textures = this.atlas.getTextures("character");
				this.frameDeltaBase = 0.05;
				this.frameDeltaVariance = 0.25;
				this.frameRateBase = 3;
				this.frameRateVariance = 15;
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
	
	private function toggleBuffers(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.buffersButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.miniButtonTextureOFF;
		}
		
		this.numBuffers = Std.parseInt(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function toggleColor(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useColor = !this.useColor;
		if (this.useColor)
		{
			btn.upState = this.buttonTextureON;
		}
		else 
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleDataMode(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.dataModeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.buttonTextureOFF;
		}
		
		switch (btn.text)
		{
			case "use ByteArray" :
				this.useByteArray = !this.useByteArray;
				#if !flash
				this.useFloat32Array = false;
				#end
				btn.upState = this.useByteArray ? this.buttonTextureON : this.buttonTextureOFF;
			
			#if !flash
			case "use Float32Array" :
				this.useFloat32Array = !this.useFloat32Array;
				this.useByteArray = false;
				btn.upState = this.useFloat32Array ? this.buttonTextureON : this.buttonTextureOFF;
			#end
		}
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
		var massive:MassiveImages = new MassiveImages();
		massive.atlasTexture = this.atlas.texture;
		massive.textures = this.textures;
		massive.imgScale = this.displayScale;
		massive.numBuffers = this.numBuffers;
		massive.numObjects = this.numObjects;
		massive.useBlurFilter = this.useBlurFilter;
		massive.useByteArray = this.useByteArray;
		#if !flash
		massive.useFloat32Array = this.useFloat32Array;
		#end
		massive.useColor = this.useColor;
		massive.useRandomAlpha = this.useRandomAlpha;
		massive.useRandomColor = this.useRandomColor;
		massive.useRandomRotation = this.useRandomRotation;
		massive.useSprite3D = this.useSprite3D;
		
		showSceneList([massive]);
	}
	
	private function startMassiveQuads():Void
	{
		var massive:MassiveQuads = new MassiveQuads();
		massive.displayScale = this.displayScale;
		massive.numBuffers = this.numBuffers;
		massive.numObjects = this.numObjects;
		massive.useBlurFilter = this.useBlurFilter;
		massive.useByteArray = this.useByteArray;
		#if !flash
		massive.useFloat32Array = this.useFloat32Array;
		#end
		massive.useColor = this.useColor;
		massive.useRandomAlpha = this.useRandomAlpha;
		massive.useRandomColor = this.useRandomColor;
		massive.useRandomRotation = this.useRandomRotation;
		massive.useSprite3D = this.useSprite3D;
		
		showSceneList([massive]);
	}
	
	private function startMovieClips():Void
	{
		var clips:MovieClips = new MovieClips();
		clips.textures = this.textures;
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
		var quads:ClassicQuads = new ClassicQuads();
		quads.numQuads = this.numObjects;
		quads.displayScale = this.displayScale;
		quads.useBlurFilter = this.useBlurFilter;
		quads.useRandomAlpha = this.useRandomAlpha;
		quads.useRandomColor = this.useRandomColor;
		quads.useRandomRotation = this.useRandomRotation;
		quads.useSprite3D = this.useSprite3D;
		showSceneList([quads]);
	}
	
	private function massiveClips4k(evt:Event):Void
	{
		this.numObjects = 4000;
		startMassiveImages();
	}
	
	private function massiveClips8k(evt:Event):Void
	{
		this.numObjects = 8000;
		startMassiveImages();
	}
	
	private function massiveClips16k(evt:Event):Void
	{
		this.numObjects = 16000;
		startMassiveImages();
	}
	
	private function massiveClips32k(evt:Event):Void
	{
		this.numObjects = 32000;
		startMassiveImages();
	}
	
	private function massiveClips64k(evt:Event):Void
	{
		this.numObjects = 64000;
		startMassiveImages();
	}
	
	private function massiveClips128k(evt:Event):Void
	{
		this.numObjects = 128000;
		startMassiveImages();
	}
	
	private function massiveClips256k(evt:Event):Void
	{
		this.numObjects = 256000;
		startMassiveImages();
	}
	
	private function massiveQuads8k(evt:Event):Void
	{
		this.numObjects = 8000;
		startMassiveQuads();
	}
	
	private function massiveQuads16k(evt:Event):Void
	{
		this.numObjects = 16000;
		startMassiveQuads();
	}
	
	private function massiveQuads32k(evt:Event):Void
	{
		this.numObjects = 32000;
		startMassiveQuads();
	}
	
	private function massiveQuads64k(evt:Event):Void
	{
		this.numObjects = 64000;
		startMassiveQuads();
	}
	
	private function massiveQuads128k(evt:Event):Void
	{
		this.numObjects = 128000;
		startMassiveQuads();
	}
	
	private function massiveQuads256k(evt:Event):Void
	{
		this.numObjects = 256000;
		startMassiveQuads();
	}
	
	private function movieClips4k(evt:Event):Void
	{
		this.numObjects = 4000;
		startMovieClips();
	}
	
	private function movieClips8k(evt:Event):Void
	{
		this.numObjects = 8000;
		startMovieClips();
	}
	
	private function movieClips16k(evt:Event):Void
	{
		this.numObjects = 16000;
		startMovieClips();
	}
	
	private function movieClips32k(evt:Event):Void
	{
		this.numObjects = 32000;
		startMovieClips();
	}
	
	private function movieClips64k(evt:Event):Void
	{
		this.numObjects = 64000;
		startMovieClips();
	}
	
	private function movieClips128k(evt:Event):Void
	{
		this.numObjects = 128000;
		startMovieClips();
	}
	
	private function movieClips256k(evt:Event):Void
	{
		this.numObjects = 256000;
		startMovieClips();
	}
	
	private function classicQuads8k(evt:Event):Void
	{
		this.numObjects = 8000;
		startClassicQuads();
	}
	
	private function classicQuads16k(evt:Event):Void
	{
		this.numObjects = 16000;
		startClassicQuads();
	}
	
	private function classicQuads32k(evt:Event):Void
	{
		this.numObjects = 32000;
		startClassicQuads();
	}
	
	private function classicQuads64k(evt:Event):Void
	{
		this.numObjects = 64000;
		startClassicQuads();
	}
	
	private function classicQuads128k(evt:Event):Void
	{
		this.numObjects = 128000;
		startClassicQuads();
	}
	
	private function classicQuads256k(evt:Event):Void
	{
		this.numObjects = 256000;
		startClassicQuads();
	}
	
}