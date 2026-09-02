package;

import massive.display.MassiveDisplay;
import massive.display.color.ColorMode;
import massive.display.color.ColorOffsetMode;
import massive.display.render.RenderMode;
import massive.util.MathUtils;
import openfl.Vector;
import openfl.system.Capabilities;
import openfl.system.System;
import openfl.utils.Assets;
import scene.ClassicClips;
import scene.ClassicImages;
import scene.ClassicSceneBase;
import scene.MassiveClips;
import scene.MassiveClipsBase;
import scene.MassiveEventClips;
import scene.MassiveImgs;
import scene.MassiveSceneBase;
import scene.Scene;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.Button;
import starling.display.Mesh;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.styles.MeshStyle;
import starling.styles.MultiTextureStyle;
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
	
	private var _allButtons:Array<Button> = new Array<Button>();
	private var _allTextFields:Array<TextField> = new Array<TextField>();
	
	public var colorRangeEnabled:Bool = false;
	public var colorOffsetRangeEnabled:Bool = false;
	
	private var menuSprite:Sprite;
	private var objectTypeSprite:Sprite;
	private var atlasSprite:Sprite;
	private var scaleSprite:Sprite;
	private var colorModeSprite:Sprite;
	private var colorRangeSprite:Sprite;
	private var colorAlphaRangeSprite:Sprite;
	private var colorOffsetModeSprite:Sprite;
	private var colorOffsetRangeSprite:Sprite;
	private var colorOffsetAlphaRangeSprite:Sprite;
	private var renderModeSprite:Sprite;
	private var clipTypeSprite:Sprite;
	private var containerTypeSprite:Sprite;
	private var numObjectsPerContainerSprite:Sprite;
	private var vertexAnimationSprite:Sprite;
	private var maxTextureSprite:Sprite;
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
	private var clipType:String = ClipType.CLIP;
	private var containerType:String = ContainerType.IMG;
	private var colorMode:String;
	private var colorRange:Float = 1.0;
	private var colorAlphaRange:Float = 1.0;
	private var colorOffsetMode:String;
	private var colorOffsetRange:Float = 1.0;
	private var colorOffsetAlphaRange:Float = 0.0;
	private var displayScale:Float = 1.0;
	private var frameDeltaBase:Float;
	private var frameDeltaVariance:Float;
	private var frameRateBase:Int;
	private var frameRateVariance:Int;
	private var movement:Bool = true;
	private var multiTextureStyle:Bool = false;
	private var numObjects:Int;
	private var numObjectsPerContainer:Int = 100;
	private var objectType:String = ObjectType.CLIP;
	private var renderMode:String;
	private var useBlurFilter:Bool = false;
	private var useRandomAlpha:Bool = false;
	private var useRandomColor:Bool = false;
	private var useRandomAlphaOffset:Bool = false;
	private var useRandomColorOffset:Bool = false;
	private var useRandomRotation:Bool = true;
	private var useSprite3D:Bool = false;
	private var vertexColorAnimation:Bool = false;
	private var vertexColorOffsetAnimation:Bool = false;
	private var vertexPositionAnimation:Bool = false;
	
	private var buttonTextureON:RenderTexture;
	private var buttonTextureOFF:RenderTexture;
	private var menuButtonTextureON:RenderTexture;
	private var menuButtonTextureOFF:RenderTexture;
	private var mediumButtonTextureON:RenderTexture;
	private var mediumButtonTextureOFF:RenderTexture;
	private var miniButtonTextureON:RenderTexture;
	private var miniButtonTextureOFF:RenderTexture;
	
	private var objectTypeButtons:Array<Button> = new Array<Button>();
	private var atlasButtons:Array<Button> = new Array<Button>();
	private var scaleButtons:Array<Button> = new Array<Button>();
	private var colorModeButtons:Array<Button> = new Array<Button>();
	private var colorRangeButtons:Array<Button> = new Array<Button>();
	private var colorAlphaRangeButtons:Array<Button> = new Array<Button>();
	private var colorOffsetModeButtons:Array<Button> = new Array<Button>();
	private var colorOffsetRangeButtons:Array<Button> = new Array<Button>();
	private var colorOffsetAlphaRangeButtons:Array<Button> = new Array<Button>();
	private var clipTypeButtons:Array<Button> = new Array<Button>();
	private var containerTypeButtons:Array<Button> = new Array<Button>();
	private var numObjectsPerContainerButtons:Array<Button> = new Array<Button>();
	private var renderModeButtons:Array<Button> = new Array<Button>();
	private var maxTextureButtons:Array<Button> = new Array<Button>();
	private var classicObjectsButtons:Array<Button> = new Array<Button>();
	
	private var colorRanges:Array<Float> = [-1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 3.0, 5.0];
	private var colorAlphaRanges:Array<Float> = [-1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 3.0, 5.0];
	private var colorOffsetRanges:Array<Float> = [-1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 3.0, 5.0];
	private var colorOffsetAlphaRanges:Array<Float> = [-1.0, -0.5, 0.0, 0.5, 1.0, 5.0];
	private var numAtlases:Int = 16;
	private var objectNums:Array<Int> = [1000, 2000, 4000, 8000, 16000, 32000, 64000, 128000, 256000, 512000];
	private var objectPerContainerNums:Array<Int> = [500, 100, 50, 10, 5, 1];
	private var scales:Array<Float> = [2.0, 1.0, 0.5, 0.2, 0.1];
	
	private var maxClipsWithoutMultiTextureStyle:Int = #if flash 2000 #else 8000 #end;
	
	private var maxTextures:Int;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		this.colorMode = MassiveDisplay.defaultColorMode;
		this.colorOffsetMode = MassiveDisplay.defaultColorOffsetMode;
		this.renderMode = MassiveDisplay.defaultRenderMode;
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		MassiveDisplay.init();
		this.maxTextures = MassiveDisplay.maxNumTextures;
		
		this.stage.color = 0x333333;
		
		var assets:Array<Dynamic> = [];
		for (i in 0...this.numAtlases)
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
		
		this.multiTextureStyle = Mesh.defaultStyle == MultiTextureStyle;
		
		var btnHeight:Float = 19;
		
		var colorUP:Int = 0xcccccc;
		var colorOVER:Int = 0xffffff;
		var quad:Quad = new Quad(230, btnHeight);
		var menuQuad:Quad = new Quad(140, btnHeight);
		var mediumQuad:Quad = new Quad(90, btnHeight);
		var miniQuad:Quad = new Quad(36, btnHeight);
		
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
		
		tf = createTitleTextField("Common options");
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		// Object type
		this.objectTypeSprite = new Sprite();
		this.objectTypeSprite.y = tY;
		this.menuSprite.addChild(this.objectTypeSprite);
		tf = createTextField("object type");
		tf.y = (btnHeight - tf.height) / 2;
		this.objectTypeSprite.addChild(tf);
		tX = tf.width + gap;
		
		var objectTypes:Array<String> = ObjectType.getValues();
		for (i in 0...objectTypes.length)
		{
			btn = createButton(objectTypes[i] == this.objectType ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, objectTypes[i], null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleObjectType);
			this.objectTypeButtons.push(btn);
			this.objectTypeSprite.addChild(btn);
			tX += btn.width + gap;
		}
		centerSprite(this.objectTypeSprite);
		tY += btnHeight + gap;
		
		// Atlases
		this.atlasSprite = new Sprite();
		this.atlasSprite.y = tY;
		this.menuSprite.addChild(this.atlasSprite);
		tf = createTextField("atlas(es)");
		tf.y = (btnHeight * 2 + gap - tf.height) / 2;
		this.atlasSprite.addChild(tf);
		tX = tf.width + gap;
		tY = 0;
		
		var atlasID:String;
		for (i in 0...this.numAtlases)
		{
			if (i == 8)
			{
				tX = tf.width + gap;
				tY += btnHeight + gap;
			}
			atlasID = "zombi" + i;
			btn = createButton(this.atlasIDs.indexOf(atlasID) != -1 ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, atlasID, null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleAtlas);
			this.atlasButtons.push(btn);
			this.atlasSprite.addChild(btn);
			tX += btn.width + gap;
		}
		
		centerSprite(this.atlasSprite);
		
		// Randomize alpha
		tY = this.atlasSprite.y + this.atlasSprite.height + gap;
		btn = createButton(this.useRandomAlpha ? this.buttonTextureON : this.buttonTextureOFF, "randomize alpha", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomAlpha);
		this.menuSprite.addChild(btn);
		
		// Randomize color
		tY += btnHeight + gap;
		btn = createButton(this.useRandomColor ? this.buttonTextureON : this.buttonTextureOFF, "randomize color", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomColor);
		this.menuSprite.addChild(btn);
		
		// Randomize rotation
		tY += btnHeight + gap;
		btn = createButton(this.useRandomRotation ? this.buttonTextureON : this.buttonTextureOFF, "randomize rotation", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomRotation);
		this.menuSprite.addChild(btn);
		
		// Scale factor
		tY += btnHeight + gap;
		this.scaleSprite = new Sprite();
		this.scaleSprite.y = tY;
		this.menuSprite.addChild(this.scaleSprite);
		tf = createTextField("scale");
		tf.y = (btnHeight - tf.height) / 2;
		this.scaleSprite.addChild(tf);
		tX = tf.width + gap;
		
		var scaleFactor:Float;
		for (i in 0...this.scales.length)
		{
			scaleFactor = this.scales[i];
			
			btn = createButton(this.displayScale == scaleFactor ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(scaleFactor), null, this.miniButtonTextureON);
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleDisplayScale);
			this.scaleButtons.push(btn);
			this.scaleSprite.addChild(btn);
			tX += btn.width + gap;
		}
		
		// Sprite 3D
		tY += btnHeight + gap;
		btn = createButton(this.useSprite3D ? this.buttonTextureON : this.buttonTextureOFF, "Sprite3D", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleSprite3D);
		this.menuSprite.addChild(btn);
		
		// Blur filter
		tY += btnHeight + gap;
		btn = createButton(this.useBlurFilter ? this.buttonTextureON : this.buttonTextureOFF, "BlurFilter", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleBlurFilter);
		this.menuSprite.addChild(btn);
		
		centerSprite(this.scaleSprite);
		
		tY += btnHeight + gap * 2;
		tf = createTitleTextField("Massive options");
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		// Render mode
		this.renderModeSprite = new Sprite();
		this.renderModeSprite.y = tY;
		this.menuSprite.addChild(this.renderModeSprite);
		tf = createTextField("renderMode");
		tf.y = (btnHeight - tf.height) / 2;
		this.renderModeSprite.addChild(tf);
		tX = tf.width + gap;
		
		var renderModes:Array<String> = RenderMode.getValues();
		for (i in 0...renderModes.length)
		{
			btn = createButton(this.renderMode == renderModes[i] ? this.buttonTextureON : this.buttonTextureOFF, renderModes[i], null, this.buttonTextureON);
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleRenderMode);
			this.renderModeButtons.push(btn);
			this.renderModeSprite.addChild(btn);
			
			tX += btn.width + gap;
		}
		
		centerSprite(this.renderModeSprite);
		
		// Color mode
		tY += btnHeight + gap;
		this.colorModeSprite = new Sprite();
		this.colorModeSprite.y = tY;
		this.menuSprite.addChild(this.colorModeSprite);
		tf = createTextField("colorMode");
		tf.y = (btnHeight - tf.height) / 2;
		this.colorModeSprite.addChild(tf);
		tX = tf.width + gap;
		
		var colorModes:Array<String> = ColorMode.getValues();
		for (i in 0...colorModes.length)
		{
			btn = createButton(this.colorMode == colorModes[i] ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, colorModes[i], null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleColorMode);
			this.colorModeButtons.push(btn);
			this.colorModeSprite.addChild(btn);
			
			tX += btn.width + gap;
		}
		
		centerSprite(this.colorModeSprite);
		
		if (this.colorRangeEnabled)
		{
			// Color range
			tY += btnHeight + gap;
			this.colorRangeSprite = new Sprite();
			this.colorRangeSprite.y = tY;
			this.menuSprite.addChild(this.colorRangeSprite);
			tf = createTextField("color range");
			tf.y = (btnHeight - tf.height) / 2;
			this.colorRangeSprite.addChild(tf);
			tX = tf.width + gap;
			
			for (i in 0...this.colorRanges.length)
			{
				btn = createButton(this.colorRange == this.colorRanges[i] ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(this.colorRanges[i]), null, this.miniButtonTextureON);
				btn.x = tX;
				btn.addEventListener(Event.TRIGGERED, toggleColorRange);
				this.colorRangeButtons.push(btn);
				this.colorRangeSprite.addChild(btn);
				
				tX += btn.width + gap;
			}
			
			centerSprite(this.colorRangeSprite);
			
			// Color alpha range
			tY += btnHeight + gap;
			this.colorAlphaRangeSprite = new Sprite();
			this.colorAlphaRangeSprite.y = tY;
			this.menuSprite.addChild(this.colorAlphaRangeSprite);
			tf = createTextField("alpha range");
			tf.y = (btnHeight - tf.height) / 2;
			this.colorAlphaRangeSprite.addChild(tf);
			tX = tf.width + gap;
			
			for (i in 0...this.colorAlphaRanges.length)
			{
				btn = createButton(this.colorAlphaRange == this.colorAlphaRanges[i] ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(this.colorAlphaRanges[i]), null, this.miniButtonTextureON);
				btn.x = tX;
				btn.addEventListener(Event.TRIGGERED, toggleColorAlphaRange);
				this.colorAlphaRangeButtons.push(btn);
				this.colorAlphaRangeSprite.addChild(btn);
				
				tX += btn.width + gap;
			}
			
			centerSprite(this.colorAlphaRangeSprite);
		}
		
		// Color offset mode
		tY += btnHeight + gap;
		this.colorOffsetModeSprite = new Sprite();
		this.colorOffsetModeSprite.y = tY;
		this.menuSprite.addChild(this.colorOffsetModeSprite);
		tf = createTextField("colorOffsetMode");
		tf.y = (btnHeight - tf.height) / 2;
		this.colorOffsetModeSprite.addChild(tf);
		tX = tf.width + gap;
		
		var colorOffsetModes:Array<String> = ColorOffsetMode.getValues();
		for (i in 0...colorModes.length)
		{
			btn = createButton(this.colorOffsetMode == colorOffsetModes[i] ? this.buttonTextureON : this.buttonTextureOFF, colorOffsetModes[i], null, this.buttonTextureON);
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleColorOffsetMode);
			this.colorOffsetModeButtons.push(btn);
			this.colorOffsetModeSprite.addChild(btn);
			
			tX += btn.width + gap;
		}
		
		centerSprite(this.colorOffsetModeSprite);
		
		if (this.colorOffsetRangeEnabled)
		{
			// Color offset range
			tY += btnHeight + gap;
			this.colorOffsetRangeSprite = new Sprite();
			this.colorOffsetRangeSprite.y = tY;
			this.menuSprite.addChild(this.colorOffsetRangeSprite);
			tf = createTextField("color offset range");
			tf.y = (btnHeight - tf.height) / 2;
			this.colorOffsetRangeSprite.addChild(tf);
			tX = tf.width + gap;
			
			for (i in 0...this.colorOffsetRanges.length)
			{
				btn = createButton(this.colorOffsetRange == this.colorOffsetRanges[i] ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(this.colorOffsetRanges[i]), null, this.miniButtonTextureON);
				btn.x = tX;
				btn.addEventListener(Event.TRIGGERED, toggleColorOffsetRange);
				this.colorOffsetRangeButtons.push(btn);
				this.colorOffsetRangeSprite.addChild(btn);
				
				tX += btn.width + gap;
			}
			
			centerSprite(this.colorOffsetRangeSprite);
			
			// Color offset alpha range
			tY += btnHeight + gap;
			this.colorOffsetAlphaRangeSprite = new Sprite();
			this.colorOffsetAlphaRangeSprite.y = tY;
			this.menuSprite.addChild(this.colorOffsetAlphaRangeSprite);
			tf = createTextField("alpha offset range");
			tf.y = (btnHeight - tf.height) / 2;
			this.colorOffsetAlphaRangeSprite.addChild(tf);
			tX = tf.width + gap;
			
			for (i in 0...this.colorOffsetAlphaRanges.length)
			{
				btn = createButton(this.colorOffsetAlphaRange == this.colorOffsetAlphaRanges[i] ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(this.colorOffsetAlphaRanges[i]), null, this.miniButtonTextureON);
				btn.x = tX;
				btn.addEventListener(Event.TRIGGERED, toggleColorOffsetAlphaRange);
				this.colorOffsetAlphaRangeButtons.push(btn);
				this.colorOffsetAlphaRangeSprite.addChild(btn);
				
				tX += btn.width + gap;
			}
			
			centerSprite(this.colorOffsetAlphaRangeSprite);
		}
		
		// Random color offset
		tY += btnHeight + gap;
		btn = createButton(this.useRandomColorOffset ? this.buttonTextureON : this.buttonTextureOFF, "randomize color offset", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomColorOffset);
		this.menuSprite.addChild(btn);
		
		if (this.colorOffsetRangeEnabled)
		{
			// Random alpha offset
			tY += btnHeight + gap;
			btn = createButton(this.useRandomAlphaOffset ? this.buttonTextureON : this.buttonTextureOFF, "randomize alpha offset", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleRandomAlphaOffset);
			this.menuSprite.addChild(btn);
		}
		
		// Clip type
		tY += btnHeight + gap;
		this.clipTypeSprite = new Sprite();
		this.clipTypeSprite.y = tY;
		this.menuSprite.addChild(this.clipTypeSprite);
		tf = createTextField("clip type");
		tf.y = (btnHeight - tf.height) / 2;
		this.clipTypeSprite.addChild(tf);
		tX = tf.width + gap;
		
		var clipTypes:Array<String> = ClipType.getValues();
		for (i in 0...clipTypes.length)
		{
			btn = createButton(this.clipType == clipTypes[i] ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, clipTypes[i], null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleClipType);
			this.clipTypeButtons.push(btn);
			this.clipTypeSprite.addChild(btn);
			
			tX += btn.width + gap;
		}
		
		centerSprite(this.clipTypeSprite);
		
		// Container type
		tY += btnHeight + gap;
		this.containerTypeSprite = new Sprite();
		this.containerTypeSprite.y = tY;
		this.menuSprite.addChild(this.containerTypeSprite);
		tf = createTextField("container type");
		tf.y = (btnHeight - tf.height) / 2;
		this.containerTypeSprite.addChild(tf);
		tX = tf.width + gap;
		
		var containerTypes:Array<String> = ContainerType.getValues();
		for (i in 0...containerTypes.length)
		{
			btn = createButton(this.containerType == containerTypes[i] ? this.mediumButtonTextureON : this.mediumButtonTextureOFF, containerTypes[i], null, this.mediumButtonTextureON);
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleContainerType);
			this.containerTypeButtons.push(btn);
			this.containerTypeSprite.addChild(btn);
			
			tX += btn.width + gap;
		}
		
		centerSprite(this.containerTypeSprite);
		
		// Num objects per container
		tY += btnHeight + gap;
		this.numObjectsPerContainerSprite = new Sprite();
		this.numObjectsPerContainerSprite.y = tY;
		this.menuSprite.addChild(this.numObjectsPerContainerSprite);
		tf = createTextField("objects per container");
		tf.y = (btnHeight - tf.height) / 2;
		this.numObjectsPerContainerSprite.addChild(tf);
		tX = tf.width + gap;
		
		for (i in 0...this.objectPerContainerNums.length)
		{
			btn = createButton(this.numObjectsPerContainer == this.objectPerContainerNums[i] ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(this.objectPerContainerNums[i]), null, this.miniButtonTextureON);
			btn.enabled = this.containerType == ContainerType.MULTIPLE;
			btn.x = tX;
			btn.addEventListener(Event.TRIGGERED, toggleNumObjectsPerContainer);
			this.numObjectsPerContainerButtons.push(btn);
			this.numObjectsPerContainerSprite.addChild(btn);
			
			tX += btn.width + gap;
		}
		
		this.numObjectsPerContainerSprite.alpha = this.containerType == ContainerType.MULTIPLE ? 1.0 : 0.5;
		centerSprite(this.numObjectsPerContainerSprite);
		
		// Vertex animation
		tY += btnHeight + gap;
		this.vertexAnimationSprite = new Sprite();
		this.vertexAnimationSprite.y = tY;
		this.menuSprite.addChild(this.vertexAnimationSprite);
		tf = createTextField("vertex animation");
		tf.y = (btnHeight - tf.height) / 2;
		this.vertexAnimationSprite.addChild(tf);
		tX = tf.width + gap;
		
		btn = createButton(this.vertexPositionAnimation ? this.buttonTextureON : this.buttonTextureOFF, "Position", null, this.buttonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btnHeight) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleVertexPositionAnimation);
		this.vertexAnimationSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = createButton(this.vertexColorAnimation ? this.buttonTextureON : this.buttonTextureOFF, "Color", null, this.buttonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btnHeight) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleVertexColorAnimation);
		this.vertexAnimationSprite.addChild(btn);
		
		tX += btn.width + gap;
		btn = createButton(this.vertexColorOffsetAnimation ? this.buttonTextureON : this.buttonTextureOFF, "Color Offset", null, this.buttonTextureON);
		btn.x = tX;
		btn.y = tf.y + (tf.height - btnHeight) / 2;
		btn.addEventListener(Event.TRIGGERED, toggleVertexColorOffsetAnimation);
		this.vertexAnimationSprite.addChild(btn);
		
		centerSprite(this.vertexAnimationSprite);
		
		// Starling options
		tY += btnHeight + gap * 2;
		tf = createTitleTextField("Starling options");
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		btn = createButton(Starling.current.skipUnchangedFrames ? this.buttonTextureON : this.buttonTextureOFF, "skipUnchangedFrames", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleSkipUnchangedFrames);
		this.menuSprite.addChild(btn);
		
		tY += btnHeight + gap;
		btn = createButton(this.multiTextureStyle ? this.buttonTextureON : this.buttonTextureOFF, "MultiTextureStyle", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleMultiTextureStyle);
		this.menuSprite.addChild(btn);
		
		tY += btnHeight + gap;
		this.maxTextureSprite = new Sprite();
		this.maxTextureSprite.y = tY;
		this.menuSprite.addChild(this.maxTextureSprite);
		tf = createTextField("MultiTextureStyle max textures");
		tf.y = (btnHeight * 2 + gap - tf.height) / 2;
		this.maxTextureSprite.addChild(tf);
		tX = tf.width + gap;
		tY = 0;
		
		for (i in 1...17)
		{
			if (i == 9)
			{
				tX = tf.width + gap;
				tY += btnHeight + gap;
			}
			btn = createButton(i == MultiTextureStyle.maxTextures ? this.miniButtonTextureON : this.miniButtonTextureOFF, Std.string(i), null, this.miniButtonTextureON);
			btn.enabled = i <= MultiTextureStyle.MAX_NUM_TEXTURES;
			btn.x = tX;
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, toggleMultiTextureStyleMaxTexture);
			this.maxTextureSprite.addChild(btn);
			this.maxTextureButtons.push(btn);
			tX += btn.width + gap;
		}
		
		centerSprite(this.maxTextureSprite);
		tY = this.maxTextureSprite.y + this.maxTextureSprite.height + gap;
		
		demoY = tY + btn.height + gap * 2;
		
		// CLASSIC STARLING
		this.classicSprite = new Sprite();
		this.classicSprite.y = demoY;
		this.classicSprite.x = -this.buttonTextureOFF.width / 2 - demoGap;
		this.menuSprite.addChild(this.classicSprite);
		tY = 0;
		
		tf = createTitleTextField("Classic Starling");
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.classicSprite.addChild(tf);
		tY += tf.height + gap;
		
		for (i in 0...this.objectNums.length)
		{
			if (i != 0) tY += btnHeight + gap;
			btn = createButton(this.buttonTextureOFF, this.objectNums[i] + " objects", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, classicScene);
			this.classicSprite.addChild(btn);
			this.classicObjectsButtons.push(btn);
		}
		//\CLASSIC STARLING
		
		// MASSIVE STARLING
		this.massiveSprite = new Sprite();
		this.massiveSprite.y = demoY;
		this.massiveSprite.x = this.buttonTextureOFF.width / 2 + demoGap;
		this.menuSprite.addChild(this.massiveSprite);
		tY = 0;
		
		tf = createTitleTextField("Massive Starling");
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.massiveSprite.addChild(tf);
		tY += tf.height + gap;
		
		for (i in 0...this.objectNums.length)
		{
			if (i != 0) tY += btnHeight + gap;
			btn = createButton(this.buttonTextureOFF, this.objectNums[i] + " objects", null, this.buttonTextureON);
			btn.y = tY;
			btn.addEventListener(Event.TRIGGERED, massiveScene);
			this.massiveSprite.addChild(btn);
		}
		//\MASSIVE STARLING
		
		tY = this.massiveSprite.y + this.massiveSprite.height + gap * 4;
		tf = createTextField("zombi assets from www.kenney.nl");
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		
		this.demoMenuSprite = new Sprite();
		
		tY = 0;
		btn = createButton(this.menuButtonTextureOFF, "Menu", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, backToMenu);
		this.demoMenuSprite.addChild(btn);
		
		tY += btnHeight + gap * 4;
		btn = createButton(this.movement ? this.menuButtonTextureON : this.menuButtonTextureOFF, "Movement", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleMovement);
		this.demoMenuSprite.addChild(btn);
		this.movementButton = btn;
		
		tY += btnHeight + gap;
		btn = createButton(this.animation ? this.menuButtonTextureON : this.menuButtonTextureOFF, "Animation", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleAnimation);
		this.demoMenuSprite.addChild(btn);
		this.animationButton = btn;
		
		tY += btnHeight + gap;
		btn = createButton(this.autoUpdateBounds ? this.menuButtonTextureON : this.menuButtonTextureOFF, "autoUpdateBounds", null, this.menuButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleAutoUpdateBounds);
		this.demoMenuSprite.addChild(btn);
		this.autoUpdateBoundsButton = btn;
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
		
		var count:Int = MathUtils.minInt(this.numAtlases, this.maxTextures);
		for (i in 0...count)
		{
			setAtlas("zombi" + i);
		}
		
		updateUIPositions();
		showMenu();
	}
	
	private function centerSprite(sprite:Sprite):Void
	{
		sprite.x = (this.buttonTextureOFF.width - sprite.width) / 2;
	}
	
	private function createButton(upState:Texture, text:String, downState:Texture, overState:Texture, disabledState:Texture = null):Button
	{
		var btn:Button = new Button(upState, text, downState, overState, disabledState);
		btn.textFormat.setTo("_sans", 12);
		this._allButtons[this._allButtons.length] = btn;
		return btn;
	}
	
	private function createTextField(text:String = ""):TextField
	{
		var tf:TextField = new TextField(0, 0, text);
		tf.format.setTo("_sans", 12, 0xffffff);
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.batchable = true;
		tf.pixelSnapping = true;
		this._allTextFields[this._allTextFields.length] = tf;
		return tf;
	}
	
	private function createTitleTextField(text:String = ""):TextField
	{
		var tf:TextField = new TextField(0, 0, text);
		tf.format.setTo("_sans", 14, 0xffd400);
		tf.format.bold = true;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.batchable = true;
		tf.pixelSnapping = true;
		this._allTextFields[this._allTextFields.length] = tf;
		return tf;
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
		
		System.gc();
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
			if (this.atlases.length < this.maxTextures)
			{
				setAtlas(btn.text);
			}
		}
		else if (this.atlasIDs.length > 1)
		{
			this.atlasIDs.splice(index, 1);
			this.atlases.splice(index, 1);
			this.textures.splice(index, 1);
			btn.upState = this.miniButtonTextureOFF;
			
			updateClassicStarling();
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
		
		for (i in 0...this.atlasButtons.length)
		{
			if (this.atlasButtons[i].text == id)
			{
				this.atlasButtons[i].upState = this.miniButtonTextureON;
				break;
			}
		}
		
		updateClassicStarling();
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
	
	private function toggleClipType(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.clipTypeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.mediumButtonTextureOFF;
		}
		
		this.clipType = btn.text;
		btn.upState = this.mediumButtonTextureON;
	}
	
	private function toggleColorMode(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.colorModeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.mediumButtonTextureOFF;
		}
		
		this.colorMode = btn.text;
		btn.upState = this.mediumButtonTextureON;
	}
	
	private function toggleColorOffsetMode(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.colorOffsetModeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.buttonTextureOFF;
		}
		
		this.colorOffsetMode = btn.text;
		btn.upState = this.buttonTextureON;
	}
	
	private function toggleColorOffsetRange(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.colorOffsetRangeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.miniButtonTextureOFF;
		}
		
		this.colorOffsetRange = Std.parseFloat(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function toggleColorOffsetAlphaRange(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.colorOffsetAlphaRangeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.miniButtonTextureOFF;
		}
		
		this.colorOffsetAlphaRange = Std.parseFloat(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function toggleColorRange(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.colorRangeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.miniButtonTextureOFF;
		}
		
		this.colorRange = Std.parseFloat(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function toggleColorAlphaRange(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.colorAlphaRangeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.miniButtonTextureOFF;
		}
		
		this.colorAlphaRange = Std.parseFloat(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function toggleContainerType(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.containerTypeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.mediumButtonTextureOFF;
		}
		
		this.containerType = btn.text;
		btn.upState = this.mediumButtonTextureON;
		
		if (this.containerType == ContainerType.MULTIPLE)
		{
			this.numObjectsPerContainerSprite.alpha = 1.0;
			for (i in 0...this.numObjectsPerContainerButtons.length)
			{
				this.numObjectsPerContainerButtons[i].enabled = true;
			}
		}
		else
		{
			this.numObjectsPerContainerSprite.alpha = 1.0;
			for (i in 0...this.numObjectsPerContainerButtons.length)
			{
				this.numObjectsPerContainerButtons[i].enabled = false;
			}
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
			Mesh.defaultStyle = MultiTextureStyle;
			btn.upState = this.buttonTextureON;
		}
		else
		{
			Mesh.defaultStyle = MeshStyle;
			btn.upState = this.buttonTextureOFF;
		}
		
		updateClassicStarling();
		updateMeshStyle();
	}
	
	private function toggleMultiTextureStyleMaxTexture(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (i in 0...this.maxTextureButtons.length)
		{
			if (this.maxTextureButtons[i] == btn) continue;
			this.maxTextureButtons[i].upState = this.miniButtonTextureOFF;
		}
		
		MultiTextureStyle.maxTextures = Std.parseInt(btn.text);
		btn.upState = this.miniButtonTextureON;
		
		updateClassicStarling();
		updateMeshStyle();
	}
	
	private function toggleNumObjectsPerContainer(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (i in 0...this.numObjectsPerContainerButtons.length)
		{
			if (this.numObjectsPerContainerButtons[i] == btn) continue;
			this.numObjectsPerContainerButtons[i].upState = this.miniButtonTextureOFF;
		}
		
		this.numObjectsPerContainer = Std.parseInt(btn.text);
		btn.upState = this.miniButtonTextureON;
	}
	
	private function toggleObjectType(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (i in 0...this.objectTypeButtons.length)
		{
			if (this.objectTypeButtons[i] == btn) continue;
			this.objectTypeButtons[i].upState = this.mediumButtonTextureOFF;
		}
		
		this.objectType = btn.text;
		btn.upState = this.mediumButtonTextureON;
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
	
	private function toggleRandomAlphaOffset(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useRandomAlphaOffset = !this.useRandomAlphaOffset;
		if (this.useRandomAlphaOffset)
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
	
	private function toggleRandomColorOffset(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useRandomColorOffset = !this.useRandomColorOffset;
		if (this.useRandomColorOffset)
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
		
		this.renderMode = btn.text;
		btn.upState = this.buttonTextureON;
	}
	
	private function toggleSkipUnchangedFrames(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		Starling.current.skipUnchangedFrames = !Starling.current.skipUnchangedFrames;
		if (Starling.current.skipUnchangedFrames)
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
	
	private function toggleVertexColorAnimation(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.vertexColorAnimation = !this.vertexColorAnimation;
		if (this.vertexColorAnimation)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleVertexColorOffsetAnimation(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.vertexColorOffsetAnimation = !this.vertexColorOffsetAnimation;
		if (this.vertexColorOffsetAnimation)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function toggleVertexPositionAnimation(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.vertexPositionAnimation = !this.vertexPositionAnimation;
		if (this.vertexPositionAnimation)
		{
			btn.upState = this.buttonTextureON;
		}
		else
		{
			btn.upState = this.buttonTextureOFF;
		}
	}
	
	private function updateClassicStarling():Void
	{
		var numAtlases:Int = this.atlases.length;
		var maxDrawCalls:Int = 2000;
		var maxTextures:Int = this.multiTextureStyle ? MultiTextureStyle.maxTextures : 1;
		
		var count:Int = this.objectNums.length;
		if (numAtlases > maxTextures)
		{
			for (i in 0...count)
			{
				this.classicObjectsButtons[i].enabled = (this.objectNums[i] / maxTextures) <= maxDrawCalls;
			}
		}
		else
		{
			for (i in 0...count)
			{
				this.classicObjectsButtons[i].enabled = true;
			}
		}
	}
	
	private function updateMeshStyle():Void
	{
		var count:Int = this._allButtons.length;
		for (i in 0...count)
		{
			if (this.multiTextureStyle)
			{
				this._allButtons[i].style = new MultiTextureStyle();
				this._allButtons[i].textStyle = new MultiTextureStyle();
			}
			else
			{
				this._allButtons[i].style = new MeshStyle();
				this._allButtons[i].textStyle = new MeshStyle();
			}
		}
		
		count = this._allTextFields.length;
		for (i in 0...count)
		{
			if (this.multiTextureStyle)
			{
				this._allTextFields[i].style = new MultiTextureStyle();
			}
			else
			{
				this._allTextFields[i].style = new MeshStyle();
			}
		}
	}
	
	private function startMassiveScene():Void
	{
		this.movementButton.enabled = true;
		this.animationButton.enabled = this.objectType == ObjectType.CLIP;
		this.autoUpdateBoundsButton.enabled = true;
		
		var scene:MassiveSceneBase;
		if (this.objectType == ObjectType.CLIP)
		{
			if (this.clipType == ClipType.CLIP || this.clipType == ClipType.CLIP_BASIC)
			{
				scene = new MassiveClips();
			}
			else
			{
				scene = new MassiveEventClips();
			}
			cast(scene, MassiveClipsBase).clipType = this.clipType;
		}
		else
		{
			scene = new MassiveImgs();
		}
		
		scene.containerType = this.containerType;
		scene.animation = this.animation;
		scene.movement = this.movement;
		scene.autoUpdateBounds = this.autoUpdateBounds;
		scene.addAtlases(this.atlases);
		scene.objectScale = this.displayScale;
		scene.numObjects = this.numObjects;
		scene.numObjectsPerContainer = this.numObjectsPerContainer;
		scene.colorMode = this.colorMode;
		scene.colorRange = this.colorRange;
		scene.colorAlphaRange = this.colorAlphaRange;
		scene.colorOffsetMode = this.colorOffsetMode;
		scene.colorOffsetRange = this.colorOffsetRange;
		scene.colorOffsetAlphaRange = this.colorOffsetAlphaRange;
		scene.renderMode = this.renderMode;
		scene.textures = this.textures;
		scene.useBlurFilter = this.useBlurFilter;
		scene.useRandomAlpha = this.useRandomAlpha;
		scene.useRandomColor = this.useRandomColor;
		scene.useRandomAlphaOffset = this.useRandomAlphaOffset;
		scene.useRandomColorOffset = this.useRandomColorOffset;
		scene.useRandomRotation = this.useRandomRotation;
		scene.useSprite3D = this.useSprite3D;
		scene.vertexColorAnimation = this.vertexColorAnimation && (this.objectType == ObjectType.IMAGE || (this.objectType == ObjectType.CLIP && this.clipType != ClipType.CLIP_BASIC));
		scene.vertexColorOffsetAnimation = this.vertexColorOffsetAnimation && (this.objectType == ObjectType.IMAGE || (this.objectType == ObjectType.CLIP && this.clipType != ClipType.CLIP_BASIC));
		scene.vertexPositionAnimation = this.vertexPositionAnimation && (this.objectType == ObjectType.IMAGE || (this.objectType == ObjectType.CLIP && this.clipType != ClipType.CLIP_BASIC));
		
		showSceneList([scene]);
	}
	
	private function startClassicScene():Void
	{
		this.movementButton.enabled = true;
		this.animationButton.enabled = this.objectType == ObjectType.CLIP;
		this.autoUpdateBoundsButton.enabled = false;
		
		var scene:ClassicSceneBase;
		if (this.objectType == ObjectType.CLIP)
		{
			scene = new ClassicClips();
		}
		else
		{
			scene = new ClassicImages();
		}
		
		scene.animation = this.animation;
		scene.movement = this.movement;
		scene.textures = this.textures;
		scene.multiTextureStyle = this.multiTextureStyle;
		scene.numObjects = this.numObjects;
		scene.objectScale = this.displayScale;
		scene.useBlurFilter = this.useBlurFilter;
		scene.useRandomAlpha = this.useRandomAlpha;
		scene.useRandomColor = this.useRandomColor;
		scene.useRandomRotation = this.useRandomRotation;
		scene.useSprite3D = this.useSprite3D;
		showSceneList([scene]);
	}
	
	private function classicScene(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		var index:Int = btn.text.indexOf(" ");
		this.numObjects = Std.parseInt(btn.text.substring(0, index));
		startClassicScene();
	}
	
	private function massiveScene(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		var index:Int = btn.text.indexOf(" ");
		this.numObjects = Std.parseInt(btn.text.substring(0, index));
		startMassiveScene();
	}
	
}