package scene;
import massive.util.MathUtils;
import openfl.Vector;
import scene.starling.IClassicImage;
import starling.display.MovieClip;
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class ClassicClips extends ClassicSceneBase
{
	public var frameRateBase:Int = 6;
	public var frameRateVariance:Int = 30;
	
	#if flash
	private var _clips:Vector<MovingClip> = new Vector<MovingClip>();
	#else
	private var _clips:Array<MovingClip> = new Array<MovingClip>();
	#end
	

	public function new() 
	{
		super();
	}
	
	private function init():Void
	{
		var numTextures:Int = this.textures.length;
		
		var clip:MovingClip;
		var speedVariance:Float;
		var variant:Int;
		
		for (i in 0...this.numObjects)
		{
			variant = Std.random(numTextures);
			
			speedVariance = MathUtils.random();
			clip = new MovingClip(this.textures[variant], this.frameRateBase + Std.int(this.frameRateVariance * speedVariance));
			clip.currentFrame = Std.random(this.textures[variant].length);
			
			initImage(clip, speedVariance);
			this._clips[i] = clip;
		}
	}
	
	override public function advanceTime(time:Float):Void
	{
		super.advanceTime(time);
		
		if (!this._animation && !this._movement) return;
		
		var clip:MovingClip;
		for (i in 0...this.numObjects)
		{
			clip = this._clips[i];
			if (this._movement)
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
			}
			if (this._animation) clip.advanceTime(time);
		}
	}
	
}

class MovingClip extends MovieClip implements IClassicImage
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new(textures:Vector<Texture>, fps:Int = 24)
	{
		super(textures, fps);
	}
}