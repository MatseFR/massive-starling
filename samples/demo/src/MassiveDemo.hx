package;

import openfl.Vector;
import openfl.system.Capabilities;
import openfl.utils.Assets;
import scene.ClassicQuads;
import scene.MassiveImages;
import scene.MassiveQuads;
import scene.MovieClips;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.Button;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
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
	
	private var _sceneList:Array<Sprite>;
	
	private var menuSprite:Sprite;
	private var backButton:Button;
	
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
		
		var btn:Button;
		var gap:Float = 8;
		var tY:Float = 0;
		
		menuSprite = new Sprite();
		btn = new Button(textureUP, "1000 Massive birds", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveBirds);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "1000 MovieClip birds", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, mcBirds);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "3000 Massive zombies", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveZombies);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "3000 MovieClip zombies", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, mcZombies);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "5000 Massive quads", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, massiveQuads);
		menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(textureUP, "5000 classic quads", null, textureOVER);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, classicQuads);
		menuSprite.addChild(btn);
		
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
		
		//for (i in 0...4)
		//{
			//trace(i + " << 2 = " + (i << 2));
			//trace(i + " << 3 = " + (i << 3));
			//trace(i + " << 4 = " + (i << 4));
			//trace(i + " << 5 = " + (i << 5));
			//trace(i + " << 6 = " + (i << 6));
		//}
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		//trace("resize");
		updateViewPort(evt.width, evt.height);
		updateUIPositions();
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
	
	private function showSceneList(scenes:Array<Sprite>):Void
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
		
		backButton.removeFromParent();
		
		showMenu();
	}
	
	private function massiveBirds(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("starling_bird");
		var textures:Vector<Texture> = atlas.getTextures("0");
		
		var birds:MassiveImages = new MassiveImages();
		birds.atlasTexture = atlas.texture;
		birds.textures = textures;
		birds.numImages = 1000;
		birds.imgScale = 0.2;
		birds.useColor = false;
		birds.useByteArray = false;
		showSceneList([birds]);
	}
	
	private function massiveQuads(evt:Event):Void
	{
		var quads:MassiveQuads = new MassiveQuads();
		quads.numQuads = 5000;
		quads.useByteArray = false;
		showSceneList([quads]);
	}
	
	private function massiveZombies(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("zombi_walk");
		var textures:Vector<Texture> = atlas.getTextures("character");
		
		var zombies:MassiveImages = new MassiveImages();
		zombies.atlasTexture = atlas.texture;
		zombies.textures = textures;
		zombies.numImages = 3000;
		zombies.useColor = false;
		zombies.useByteArray = false;
		showSceneList([zombies]);
	}
	
	private function mcBirds():Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("starling_bird");
		var textures:Vector<Texture> = atlas.getTextures("0");
		
		var birds:MovieClips = new MovieClips();
		birds.textures = textures;
		birds.numClips = 1000;
		birds.clipScale = 0.2;
		showSceneList([birds]);
	}
	
	private function mcZombies(evt:Event):Void
	{
		var atlas:TextureAtlas = assetManager.getTextureAtlas("zombi_walk");
		var textures:Vector<Texture> = atlas.getTextures("character");
		
		var zombies:MovieClips = new MovieClips();
		zombies.textures = textures;
		zombies.numClips = 3000;
		showSceneList([zombies]);
	}
	
	private function classicQuads(evt:Event):Void
	{
		var quads:ClassicQuads = new ClassicQuads();
		quads.numQuads = 5000;
		showSceneList([quads]);
	}
	
}