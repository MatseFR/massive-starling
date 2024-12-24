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
	
	private var _clips:Array<MovingClip>;
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
		
		var frameCount:Int = this.textures.length;
		var stageWidth:Float = this.stage.stageWidth;
		var stageHeight:Float = this.stage.stageHeight;
		
		updateBounds();
		
		this._clips = new Array<MovingClip>();
		var clip:MovingClip;
		var velocity:Float;
		for (i in 0...this.numClips)
		{
			clip = new MovingClip(this.textures, 12 + Std.random(48));
			clip.currentFrame = Std.random(frameCount);
			clip.touchable = false;
			clip.alignPivot();
			if (this.useRandomAlpha) clip.alpha = Math.random();
			if (this.useRandomColor) clip.color = Color.rgb(Std.random(256), Std.random(256), Std.random(256));
			clip.x = Math.random() * stageWidth;
			clip.y = Math.random() * stageHeight;
			clip.scaleX = clip.scaleY = this.clipScale;
			clip.rotation = Math.random() * Math.PI;
			
			velocity = this._velocityBase + Math.random() * _velocityRange;
			clip.velocityX = Math.cos(clip.rotation) * velocity;
			clip.velocityY = Math.sin(clip.rotation) * velocity;
			
			this._clips[i] = clip;
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
		for (clip in this._clips)
		{
			clip.x += clip.velocityX * time;
			clip.y += clip.velocityY * time;
			
			if (clip.x < this._left)
			{
				clip.x = this._right;
			}
			else if (clip.x > this._right)
			{
				clip.x = this._left;
			}
			
			if (clip.y < this._top)
			{
				clip.y = this._bottom;
			}
			else if (clip.y > this._bottom)
			{
				clip.y = this._top;
			}
			clip.advanceTime(time);
		}
	}
	
}

class MovingClip extends MovieClip
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new(textures:Vector<Texture>, fps:Int = 24)
	{
		super(textures, fps);
	}
}