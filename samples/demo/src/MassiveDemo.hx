package;

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
	private var backButton:Button;
	
	private var useByteArray:Bool = false;
	private var useColor:Bool = true;
	private var useRandomAlpha:Bool = false;
	private var useRandomColor:Bool = false;
	
	private var buttonTextureON:Texture;
	private var buttonTextureOFF:Texture;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
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
		
		var colorUP:Int = 0xcccccc;
		var colorOVER:Int = 0xffffff;
		var quad:Quad = new Quad(300, 32);
		
		quad.color = colorUP;
		var textureUP:RenderTexture = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		textureUP.draw(quad);
		
		quad.color = colorOVER;
		var textureOVER:RenderTexture = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		textureOVER.draw(quad);
		
		buttonTextureON = textureOVER;
		buttonTextureOFF = textureUP;
		
		var btn:Button;
		var tf:TextField;
		var gap:Float = 8;
		var tY:Float = 0;
		
		menuSprite = new Sprite();
		
		tf = new TextField(0, 0, "Options");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (textureUP.width - tf.width) / 2;
		menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		btn = new Button(textureUP, "randomize alpha", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomAlpha);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "randomize color", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleRandomColor);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "use ByteArray (Massive)", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, toggleByteArray);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap * 4;
		
		tf = new TextField(0, 0, "Demos");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (textureUP.width - tf.width) / 2;
		menuSprite.addChild(tf);
		tY += tf.height + gap;
		
		btn = new Button(textureUP, "8000 Massive birds (scale 0.2)", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveBirds);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "8000 MovieClip birds (scale 0.2)", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, mcBirds);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "8000 Massive zombies", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveZombies);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "8000 MovieClip zombies", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, mcZombies);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "16000 Massive zombies (scale 0.5)", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveZombies2);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "16000 MovieClip zombies (scale 0.5)", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, mcZombies2);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "16000 Massive quads", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "16000 classic quads", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		tf = new TextField(0, 0, "zombi assets from www.kenney.nl");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (textureUP.width - tf.width) / 2;
		menuSprite.addChild(tf);
		
		quad.width = 100;
		quad.color = colorUP;
		textureUP = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		textureUP.draw(quad);
		
		quad.color = colorOVER;
		textureOVER = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		textureOVER.draw(quad);
		
		backButton = new Button(textureUP, "Menu", null, textureOVER);
		backButton.addEventListener(Event.TRIGGERED, backToMenu);
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
		
		updateUIPositions();
		showMenu();
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
		updateUIPositions();
		
		if (_sceneList != null)
		{
			for (scene in _sceneList)
			{
				scene.updateBounds();
			}
		}
	}
	
	private function updateViewPort(width:Int, height:Int):Void 
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		stage.stageWidth  = Std.int(width  / scale);
		stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width  = stage.stageWidth  * scale;
		current.viewPort.height = stage.stageHeight * scale;
	}
	
	private function updateUIPositions():Void
	{
		menuSprite.x = (stage.stageWidth - menuSprite.width) / 2;
		menuSprite.y = (stage.stageHeight - menuSprite.height) / 2;
		
		var spacing:Float = 8;
		backButton.x = stage.stageWidth - backButton.width - spacing;
		backButton.y = spacing;
	}
	
	private function showMenu():Void
	{
		addChild(menuSprite);
	}
	
	private function hideMenu():Void
	{
		removeChild(menuSprite);
	}
	
	private function showSceneList(scenes:Array<Scene>):Void
	{
		hideMenu();
		
		_sceneList = scenes;
		for (scene in _sceneList)
		{
			addChild(scene);
		}
		
		addChild(backButton);
	}
	
	private function backToMenu(evt:Event):Void
	{
		for (scene in _sceneList)
		{
			scene.removeFromParent(true);
		}
		_sceneList = null;
		
		backButton.removeFromParent();
		
		showMenu();
	}
	
	private function toggleByteArray(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useByteArray = !this.useByteArray;
		if (this.useByteArray)
		{
			btn.upState = buttonTextureON;
		}
		else
		{
			btn.upState = buttonTextureOFF;
		}
	}
	
	private function toggleRandomAlpha(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useRandomAlpha = !this.useRandomAlpha;
		if (this.useRandomAlpha)
		{
			btn.upState = buttonTextureON;
		}
		else
		{
			btn.upState = buttonTextureOFF;
		}
	}
	
	private function toggleRandomColor(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		this.useRandomColor = !this.useRandomColor;
		if (this.useRandomColor)
		{
			btn.upState = buttonTextureON;
		}
		else
		{
			btn.upState = buttonTextureOFF;
		}
	}
	
	private function massiveBirds(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("starling_bird");
		var textures:Vector<Texture> = atlas.getTextures("0");
		
		var birds:MassiveImages = new MassiveImages();
		birds.atlasTexture = atlas.texture;
		birds.textures = textures;
		birds.numImages = 8000;
		birds.imgScale = 0.2;
		birds.useByteArray = useByteArray;
		birds.useColor = useColor;
		birds.useRandomAlpha = useRandomAlpha;
		birds.useRandomColor = useRandomColor;
		showSceneList([birds]);
	}
	
	private function massiveZombies(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("zombi_walk");
		var textures:Vector<Texture> = atlas.getTextures("character");
		
		var zombies:MassiveImages = new MassiveImages();
		zombies.atlasTexture = atlas.texture;
		zombies.textures = textures;
		zombies.numImages = 8000;
		zombies.useByteArray = useByteArray;
		zombies.useColor = useColor;
		zombies.useRandomAlpha = useRandomAlpha;
		zombies.useRandomColor = useRandomColor;
		showSceneList([zombies]);
	}
	
	private function massiveZombies2(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("zombi_walk");
		var textures:Vector<Texture> = atlas.getTextures("character");
		
		var zombies:MassiveImages = new MassiveImages();
		zombies.atlasTexture = atlas.texture;
		zombies.textures = textures;
		zombies.numImages = 16000;
		zombies.imgScale = 0.5;
		zombies.useByteArray = useByteArray;
		zombies.useColor = useColor;
		zombies.useRandomAlpha = useRandomAlpha;
		zombies.useRandomColor = useRandomColor;
		showSceneList([zombies]);
	}
	
	private function massiveQuads(evt:Event):Void
	{
		var quads:MassiveQuads = new MassiveQuads();
		quads.numQuads = 16000;
		quads.useByteArray = useByteArray;
		quads.useRandomAlpha = useRandomAlpha;
		quads.useRandomColor = useRandomColor;
		showSceneList([quads]);
	}
	
	private function mcBirds():Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("starling_bird");
		var textures:Vector<Texture> = atlas.getTextures("0");
		
		var birds:MovieClips = new MovieClips();
		birds.textures = textures;
		birds.numClips = 8000;
		birds.clipScale = 0.2;
		birds.useRandomAlpha = useRandomAlpha;
		birds.useRandomColor = useRandomColor;
		showSceneList([birds]);
	}
	
	private function mcZombies(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("zombi_walk");
		var textures:Vector<Texture> = atlas.getTextures("character");
		
		var zombies:MovieClips = new MovieClips();
		zombies.textures = textures;
		zombies.numClips = 8000;
		zombies.useRandomAlpha = useRandomAlpha;
		zombies.useRandomColor = useRandomColor;
		showSceneList([zombies]);
	}
	
	private function mcZombies2(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("zombi_walk");
		var textures:Vector<Texture> = atlas.getTextures("character");
		
		var zombies:MovieClips = new MovieClips();
		zombies.textures = textures;
		zombies.numClips = 16000;
		zombies.clipScale = 0.5;
		zombies.useRandomAlpha = useRandomAlpha;
		zombies.useRandomColor = useRandomColor;
		showSceneList([zombies]);
	}
	
	private function classicQuads(evt:Event):Void
	{
		var quads:ClassicQuads = new ClassicQuads();
		quads.numQuads = 16000;
		quads.useRandomAlpha = useRandomAlpha;
		quads.useRandomColor = useRandomColor;
		showSceneList([quads]);
	}
	
}