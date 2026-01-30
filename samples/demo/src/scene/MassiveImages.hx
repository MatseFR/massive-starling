package scene;

import massive.animation.Animator;
import massive.data.Frame;
import massive.data.ImageData;
import massive.util.LookUp;
import massive.data.MassiveConstants;
import massive.display.MassiveDisplay;
import massive.display.ImageLayer;
import massive.util.MathUtils;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.filters.BlurFilter;
import starling.textures.Texture;
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
	public var numBuffers:Int = 2;
	public var numObjects:Int = 1000;
	public var renderMode:String;
	public var useBlurFilter:Bool;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	public var useSprite3D:Bool;
	public var imgScale:Float = 1;
	public var atlasTexture:Texture;
	public var textures:Vector<Texture>;
	
	private var _displayList:Array<MassiveDisplay> = new Array<MassiveDisplay>();
	private var _frames:#if flash Vector<Frame> #else Array<Frame> #end;
	private var _timings:Array<Float>;
	
	private var _imgList:#if flash Vector<MassiveImage> #else Array<MassiveImage> #end;
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	private var _sprite3D:Sprite3D;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		this._frames = Frame.fromTextureVectorWithAlign(this.textures, Align.CENTER, Align.CENTER);
		var frameCount:Int = this._frames.length;
		this._timings = Animator.generateTimings(this._frames);
		
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
		
		var numDisplays:Int = MathUtils.ceil(this.numObjects / MassiveConstants.MAX_QUADS);
		var display:MassiveDisplay;
		var layer:ImageLayer;
		var numImages:Int;
		#if flash
		this._imgList = new Vector<MassiveImage>();
		#else
		this._imgList = new Array<MassiveImage>();
		#end
		var img:MassiveImage;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...numDisplays)
		{
			numImages = i == numDisplays - 1 ? this.numObjects % MassiveConstants.MAX_QUADS : MassiveConstants.MAX_QUADS;
			
			display = new MassiveDisplay(this.atlasTexture, this.renderMode, this.colorMode, numImages, this.numBuffers);
			
			layer = new ImageLayer();
			display.addLayer(layer);
			
			for (j in 0...numImages)
			{
				img = new MassiveImage();
				img.setFrames(this._frames, this._timings, true, 0, Std.random(frameCount));
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
				img.velocityX = LookUp.cos(img.rotation) * velocity;
				img.velocityY = LookUp.sin(img.rotation) * velocity;
				
				this._imgList[this._imgList.length] = img;
				layer.addImage(img);
			}
			
			if (this.useSprite3D)
			{
				this._sprite3D.addChild(display);
			}
			else
			{
				addChild(display);
			}
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

class MassiveImage extends ImageData
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new()
	{
		super();
	}
}