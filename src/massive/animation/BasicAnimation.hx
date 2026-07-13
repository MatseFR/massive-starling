package massive.animation;
import openfl.Vector;

/**
 * ...
 * @author Matse
 */
class BasicAnimation 
{
	static private var _POOL:Array<BasicAnimation> = new Array<BasicAnimation>();
	
	static public function fromPool():BasicAnimation
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new BasicAnimation();
	}
	
	public var duration(default, null):Float = 0.0;
	#if flash
	public var frames:Vector<BasicAnimationFrame> = new Vector<BasicAnimationFrame>();
	#else
	public var frames:Array<BasicAnimationFrame> = new Array<BasicAnimationFrame>();
	#end
	public var id:String;
	public var lastFrame(default, null):Int = 0;
	public var loop:Bool = false;
	/**
	   duration of a loop, different from `duration` if `loopFrame` != 0
	**/
	public var loopDuration(default, null):Float = 0.0;
	/**
	   frame index when looping
	   allows to skip first frames
	   @default	0
	**/
	public var loopFrame:Int = 0;
	public var numFrames(default, null):Int = 0;
	public var numLoops:Int = 0;

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.duration = 0.0;
		#if flash
		this.frames.length = 0;
		#else
		this.frames.resize(0);
		#end
		this.id = null;
		this.lastFrame = 0;
		this.loop = false;
		this.loopDuration = 0.0;
		this.loopFrame = 0;
		this.numFrames = 0;
		this.numLoops = 0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addFrame(frame:BasicAnimationFrame):Void
	{
		this.frames[this.frames.length] = frame;
	}
	
	public function addFrameAt(frame:BasicAnimationFrame, index:Int):Void
	{
		#if flash
		this.frames.insertAt(index, frame);
		#else
		this.frames.insert(index, frame);
		#end
	}
	
	public function removeFrame(frame:BasicAnimationFrame, pool:Bool = true):Void
	{
		if (pool) frame.pool();
		#if flash
		this.frames.removeAt(this.frames.indexOf(frame));
		#else
		this.frames.splice(this.frames.indexOf(frame), 1);
		#end
	}
	
	public function removeFrameAt(index:Int, pool:Bool = true):Void
	{
		if (pool) this.frames[index].pool();
		#if flash
		this.frames.removeAt(index);
		#else
		this.frames.splice(index, 1);
		#end
	}
	
	public function ready():Void
	{
		this.numFrames = this.frames.length;
		this.lastFrame = this.numFrames - 1;
		this.duration = this.lastFrame != -1 ? this.frames[this.lastFrame].timing : 0.0;
		if (this.loopFrame == 0 || this.numFrames == 0)
		{
			this.loopDuration = this.duration;
		}
		else
		{
			this.loopDuration = this.duration - this.frames[this.loopFrame - 1].timing;
		}
	}
	
}