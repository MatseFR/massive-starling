package scene;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.MovieClip;
import starling.events.Event;
import starling.textures.Texture;
import starling.utils.Color;

/**
 * ...
 * @author Matse
 */
class MovieClips extends Scene implements IAnimatable
{
	public var numClips:Int = 1000;
	public var textures:Vector<Texture>;
	public var clipScale:Float = 1;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	
	private var _clips:Array<Clip>;
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
		
		var frameCount:Int = textures.length - 1;
		var stageWidth:Float = stage.stageWidth;
		var stageHeight:Float = stage.stageHeight;
		
		updateBounds();
		
		_clips = new Array<Clip>();
		var clip:Clip;
		var velocity:Float;
		for (i in 0...numClips)
		{
			clip = new Clip(textures, 12 + Std.random(48));
			clip.currentFrame = Std.random(frameCount);
			clip.touchable = false;
			clip.alignPivot();
			if (useRandomAlpha) clip.alpha = Math.random();
			if (useRandomColor) clip.color = Color.rgb(Std.random(256), Std.random(256), Std.random(256));
			clip.x = Math.random() * stageWidth;
			clip.y = Math.random() * stageHeight;
			clip.scaleX = clip.scaleY = clipScale;
			clip.rotation = Math.random() * Math.PI;
			
			velocity = _velocityBase + Math.random() * _velocityRange;
			clip.velocityX = Math.cos(clip.rotation) * velocity;
			clip.velocityY = Math.sin(clip.rotation) * velocity;
			
			_clips[i] = clip;
			addChild(clip);
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
		for (clip in _clips)
		{
			clip.x += clip.velocityX * time;
			clip.y += clip.velocityY * time;
			
			if (clip.x < _left)
			{
				clip.x = _right;
			}
			else if (clip.x > _right)
			{
				clip.x = _left;
			}
			
			if (clip.y < _top)
			{
				clip.y = _bottom;
			}
			else if (clip.y > _bottom)
			{
				clip.y = _top;
			}
			clip.advanceTime(time);
		}
	}
	
}

class Clip extends MovieClip
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new(textures:Vector<Texture>, fps:Int = 24)
	{
		super(textures, fps);
	}
}