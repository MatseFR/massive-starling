package scene;
import massive.display.EventClip;
import scene.massive.MovingEventClip;
import starling.core.Starling;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class MassiveEventClips extends MassiveClipsBase 
{
	#if flash
	private var _clips:Vector<EventClip> = new Vector<EventClip>();
	private var _clipList:Vector<MovingEventClip> = new Vector<MovingEventClip>();
	#else
	private var _clips:Array<EventClip> = new Array<EventClip>();
	private var _clipList:Array<MovingEventClip> = new Array<MovingEventClip>();
	#end
	
	public function new() 
	{
		super();
	}
	
	override private function init():Void
	{
		super.init();
		
		var clip:MovingEventClip;
		
		for (i in 0...this.numObjects)
		{
			clip = new MovingEventClip();
			initClip(clip);
			this._clips[i] = clip;
			this._clipList[i] = clip;
		}
		
		this._animator.addEventClipList(this._clips);
	}
	
	override public function advanceTime(time:Float):Void 
	{
		super.advanceTime(time);
		
		if (this._movement)
		{
			var clip:MovingEventClip;
			for (i in 0...this.numObjects)
			{
				clip = this._clipList[i];
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
		}
	}
	
}