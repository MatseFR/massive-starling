package scene;

import massive.animation.Animator;
import massive.data.Frame;
import massive.data.ImageData;
import massive.display.ImageLayer;
import massive.display.MassiveDisplay;
import massive.util.LookUp;
import massive.util.MathUtils;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.filters.BlurFilter;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class MassiveImages extends Scene implements IAnimatable
{
	public var colorMode:String;
	public var frameDeltaBase:Float = 0.1;
	public var frameDeltaVariance:Float = 0.5;
	public var numObjects:Int = 1000;
	public var renderMode:String;
	public var useBlurFilter:Bool;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	public var useSprite3D:Bool;
	public var imgScale:Float = 1;
	public var atlasTextures:Array<Texture> = new Array<Texture>();
	public var textures:Array<Vector<Texture>>;
	
	override function set_animation(value:Bool):Bool 
	{
		if (this._display != null)
		{
			this._display.animate = value;
		}
		return super.set_animation(value);
	}
	
	override function set_autoUpdateBounds(value:Bool):Bool 
	{
		if (this._display != null)
		{
			this._display.autoUpdateBounds = value;
		}
		return super.set_autoUpdateBounds(value);
	}
	
	private var _display:MassiveDisplay;
	private var _frames:#if flash Array<Vector<Frame>> #else Array<Array<Frame>> #end = new #if flash Array<Vector<Frame>>() #else Array<Array<Frame>>() #end;
	private var _timings:Array<Array<Float>> = new Array<Array<Float>>();
	
	private var _imgList:#if flash Vector<MassiveImage> #else Array<MassiveImage> #end;
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	private var _sprite3D:Sprite3D;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	public function addAtlases(atlases:Array<TextureAtlas>):Void
	{
		for (i in 0...atlases.length)
		{
			this.atlasTextures.push(atlases[i].texture);
		}
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		var numTextures:Int = this.atlasTextures.length;
		
		#if flash
		var frames:Vector<Frame>;
		#else
		var frames:Array<Frame>;
		#end
		var timings:Array<Float>;
		
		for (i in 0...numTextures)
		{
			frames = Frame.fromTextureVectorWithAlign(this.textures[i], Align.CENTER, Align.CENTER);
			this._frames.push(frames);
			timings = Animator.generateTimings(frames);
			this._timings.push(timings);
		}
		
		//this._frames = Frame.fromTextureVectorWithAlign(this.textures, Align.CENTER, Align.CENTER);
		//var frameCount:Int = this._frames.length;
		//this._timings = Animator.generateTimings(this._frames);
		
		var stageWidth:Float = this.stage.stageWidth;
		var stageHeight:Float = this.stage.stageHeight;
		
		updateBounds();
		
		if (this.useSprite3D)
		{
			this._sprite3D = new Sprite3D();
			this._sprite3D.pivotX = this.stage.stageWidth / 2;
			this._sprite3D.pivotY = this.stage.stageHeight / 2;
			this._sprite3D.x = this._sprite3D.pivotX;
			this._sprite3D.y = this._sprite3D.pivotY;
			addChild(this._sprite3D);
		}
		
		var layer:ImageLayer;
		#if flash
		this._imgList = new Vector<MassiveImage>();
		#else
		this._imgList = new Array<MassiveImage>();
		#end
		var img:MassiveImage;
		var speedVariance:Float;
		var variant:Int;
		var velocity:Float;
		
		this._display = new MassiveDisplay(this.atlasTextures, this.renderMode, this.colorMode, this.numObjects);
		this._display.animate = this._animation;
		this._display.autoUpdateBounds = this._autoUpdateBounds;
		
		layer = new ImageLayer();
		this._display.addLayer(layer);
		
		for (j in 0...this.numObjects)
		{
			variant = Std.random(numTextures);
			
			img = new MassiveImage();
			img.textureIndex = variant;
			//img.textureIndex = 0;
			img.setFrames(this._frames[variant], this._timings[variant], true, 0, Std.random(this._frames[variant].length));
			img.x = MathUtils.random() * stageWidth;
			img.y = MathUtils.random() * stageHeight;
			img.scaleX = img.scaleY = this.imgScale;
			if (this.useRandomRotation) img.rotation = MathUtils.random() * MathUtils.PI2;
			
			if (this.useRandomAlpha) img.alpha = MathUtils.random();
			if (this.useRandomColor)
			{
				img.red = MathUtils.random();
				img.green = MathUtils.random();
				img.blue = MathUtils.random();
			}
			
			speedVariance = MathUtils.random();
			img.frameDelta = this.frameDeltaBase + speedVariance * this.frameDeltaVariance;
			
			velocity = this._velocityBase + speedVariance * this._velocityRange;
			img.velocityX = Math.cos(img.rotation) * velocity;
			img.velocityY = Math.sin(img.rotation) * velocity;
			
			this._imgList[this._imgList.length] = img;
			layer.addImage(img);
		}
		
		if (this.useSprite3D)
		{
			this._sprite3D.addChild(this._display);
		}
		else
		{
			addChild(this._display);
		}
		
		if (this.useBlurFilter)
		{
			this.filter = new BlurFilter();
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function updateBounds():Void 
	{
		super.updateBounds();
		
		if (this._sprite3D != null)
		{
			this._sprite3D.pivotX = this.stage.stageWidth / 2;
			this._sprite3D.pivotY = this.stage.stageHeight / 2;
			this._sprite3D.x = this._sprite3D.pivotX;
			this._sprite3D.y = this._sprite3D.pivotY;
		}
		
		if (!this.useRandomRotation && this._imgList != null)
		{
			var stageHeight:Float = this.stage.stageHeight;
			
			for (i in 0...this.numObjects)
			{
				this._imgList[i].y = MathUtils.random() * stageHeight;
			}
		}
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this);
		
		super.dispose();
	}
	
	public function advanceTime(time:Float):Void
	{
		if (this.useSprite3D)
		{
			this._sprite3D.rotationY += 0.01;
		}
		
		var img:MassiveImage;
		for (i in 0...this.numObjects)
		{
			img = this._imgList[i];
			if (this._movement)
			{
				img.x += img.velocityX * time;
				img.y += img.velocityY * time;
				
				if (img.x < this._left)
				{
					img.x = this._right;
				}
				else if (img.x > this._right)
				{
					img.x = this._left;
				}
				
				if (img.y < this._top)
				{
					img.y = this._bottom;
				}
				else if (img.y > this._bottom)
				{
					img.y = this._top;
				}
			}
		}
	}
	
}

class MassiveImage extends ImageData
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new()
	{
		super();
	}
}