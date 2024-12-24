package scene;

import massive.animation.Animator;
import massive.data.Frame;
import massive.data.ImageData;
import massive.display.MassiveDisplay;
import massive.display.MassiveImageLayer;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.events.Event;
import starling.textures.Texture;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class MassiveImages extends Scene implements IAnimatable
{
	public var numImages:Int = 1000;
	public var useByteArray:Bool = true;
	public var useColor:Bool = true;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	public var imgScale:Float = 1;
	public var atlasTexture:Texture;
	public var textures:Vector<Texture>;
	
	private var _display:MassiveDisplay;
	private var _layer:MassiveImageLayer;
	private var _frames:Array<Frame>;
	private var _timings:Array<Float>;
	
	private var _imgList:Array<MassiveImage>;
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
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
		
		this._display = new MassiveDisplay();
		this._display.touchable = false;
		this._display.useColor = this.useColor;
		this._display.texture = this.atlasTexture;
		this._display.bufferSize = this.numImages;
		this._display.useByteArray = this.useByteArray;
		addChild(this._display);
		
		this._layer = new MassiveImageLayer();
		this._display.addLayer(this._layer);
		
		this._imgList = new Array<MassiveImage>();
		var img:MassiveImage;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...this.numImages)
		{
			img = new MassiveImage();
			img.setFrames(this._frames, Std.random(frameCount), true, this._timings);
			img.x = Math.random() * stageWidth;
			img.y = Math.random() * stageHeight;
			img.scaleX = img.scaleY = this.imgScale;
			img.rotation = Math.random() * (Math.PI * 2);
			
			if (this.useRandomAlpha) img.colorAlpha = Math.random();
			if (this.useRandomColor)
			{
				img.colorRed = Math.random();
				img.colorGreen = Math.random();
				img.colorBlue = Math.random();
			}
			
			speedVariance = Math.random();
			img.frameDelta = 0.5 + speedVariance * 5;
			
			velocity = this._velocityBase + speedVariance * this._velocityRange;
			img.velocityX = Math.cos(img.rotation) * velocity;
			img.velocityY = Math.sin(img.rotation) * velocity;
			
			this._imgList[i] = img;
			this._layer.addImage(img);
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this);
		
		super.dispose();
	}
	
	public function advanceTime(time:Float):Void
	{
		for (img in this._imgList)
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

class MassiveImage extends ImageData
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new()
	{
		super();
	}
}