package scene;
import massive.display.Clip;
import scene.massive.MovingClip;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class MassiveClips extends MassiveClipsBase 
{
	#if flash
	private var _clips:Vector<Clip> = new Vector<Clip>();
	private var _clipList:Vector<MovingClip> = new Vector<MovingClip>();
	#else
	private var _clips:Array<Clip> = new Array<Clip>();
	private var _clipList:Array<MovingClip> = new Array<MovingClip>();
	#end

	public function new() 
	{
		super();
	}
	
	override private function init():Void
	{
		super.init();
		
		var clip:MovingClip;
		
		for (i in 0...this.numObjects)
		{
			clip = new MovingClip();
			initClip(clip);
			this._clips[this._clips.length] = clip;
			this._clipList[this._clipList.length] = clip;
		}
		
		if (this.clipType == ClipType.CLIP_BASIC)
		{
			this._animator.addBasicClipList(this._clips);
		}
		else
		{
			this._animator.addClipList(this._clips);
		}
	}
	
	override public function advanceTime(time:Float):Void 
	{
		super.advanceTime(time);
		
		if (this._movement)
		{
			var clip:MovingClip;
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