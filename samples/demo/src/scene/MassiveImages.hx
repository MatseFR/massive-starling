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
	public var imgScale:Float = 1;
	public var atlasTexture:Texture;
	public var textures:Vector<Texture>;
	
	private var _display:MassiveDisplay;
	private var _layer:MassiveImageLayer;
	private var _frames:Array<Frame>;
	private var _timings:Array<Float>;
	
	private var _imgList:Array<Img>;
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
		
		_frames = Frame.fromTextureVectorWithAlign(textures, Align.CENTER, Align.CENTER);
		var frameCount:Int = _frames.length - 1;
		_timings = Animator.generateTimings(_frames);
		
		var stageWidth:Float = stage.stageWidth;
		var stageHeight:Float = stage.stageHeight;
		
		updateBounds();
		
		_display = new MassiveDisplay();
		_display.touchable = false;
		_display.useColor = useColor;
		_display.texture = atlasTexture;
		_display.bufferSize = numImages;
		_display.useByteArray = useByteArray;
		addChild(_display);
		
		_layer = new MassiveImageLayer();
		_display.addLayer(_layer);
		
		_imgList = new Array<Img>();
		var img:Img;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...numImages)
		{
			img = new Img();
			img.setFrames(_frames, _timings, Std.random(frameCount));
			img.x = Math.random() * stageWidth;
			img.y = Math.random() * stageHeight;
			img.scaleX = img.scaleY = imgScale;
			img.rotation = Math.random() * Math.PI;
			
			speedVariance = Math.random();
			img.frameDelta = 0.5 + speedVariance * 5;
			
			velocity = _velocityBase + speedVariance * _velocityRange;
			img.velocityX = Math.cos(img.rotation) * velocity;
			img.velocityY = Math.sin(img.rotation) * velocity;
			
			_imgList[i] = img;
			_layer.addImage(img);
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
	}
	
	public function advanceTime(time:Float):Void
	{
		for (img in _imgList)
		{
			img.x += img.velocityX * time;
			img.y += img.velocityY * time;
			
			if (img.x < _left)
			{
				img.x = _right;
			}
			else if (img.x > _right)
			{
				img.x = _left;
			}
			
			if (img.y < _top)
			{
				img.y = _bottom;
			}
			else if (img.y > _bottom)
			{
				img.y = _top;
			}
		}
	}
	
}

class Img extends ImageData
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new()
	{
		super();
	}
}