package scene;
import massive.data.LookUp;
import massive.util.MathUtils;
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
	public var frameRateBase:Int = 6;
	public var frameRateVariance:Int = 30;
	public var numClips:Int = 1000;
	public var textures:Vector<Texture>;
	public var clipScale:Float = 1;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	
	private var _clips:#if flash Vector<MovingClip> #else Array<MovingClip> #end;
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
		
		#if flash
		this._clips = new Vector<MovingClip>();
		#else
		this._clips = new Array<MovingClip>();
		#end
		var clip:MovingClip;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...this.numClips)
		{
			speedVariance = MathUtils.random();
			clip = new MovingClip(this.textures, this.frameRateBase + Std.int(this.frameRateVariance * speedVariance));
			clip.currentFrame = Std.random(frameCount);
			clip.touchable = false;
			clip.alignPivot();
			if (this.useRandomAlpha) clip.alpha = MathUtils.random();
			if (this.useRandomColor) clip.color = Color.rgb(Std.random(256), Std.random(256), Std.random(256));
			clip.x = MathUtils.random() * stageWidth;
			clip.y = MathUtils.random() * stageHeight;
			clip.scaleX = clip.scaleY = this.clipScale;
			if (this.useRandomRotation)	clip.rotation = MathUtils.random() * MathUtils.PI2;
			
			velocity = this._velocityBase + speedVariance * this._velocityRange;
			clip.velocityX = LookUp.cos(clip.rotation) * velocity;
			clip.velocityY = LookUp.sin(clip.rotation) * velocity;
			
			this._clips[i] = clip;
			addChild(clip);
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function updateBounds():Void 
	{
		super.updateBounds();
		
		if (!this.useRandomRotation && this._clips != null)
		{
			var stageHeight:Float = this.stage.stageHeight;
			
			for (i in 0...this.numClips)
			{
				this._clips[i].y = MathUtils.random() * stageHeight;
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
		var clip:MovingClip;
		for (i in 0...this.numClips)
		{
			clip = this._clips[i];
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