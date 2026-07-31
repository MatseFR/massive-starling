package massive.animation;
import massive.data.Frame;
#if flash
import openfl.Vector;
#end

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
	
	#if flash
	public var animationFrames:Vector<BasicAnimationFrame> = new Vector<BasicAnimationFrame>();
	#else
	public var animationFrames:Array<BasicAnimationFrame> = new Array<BasicAnimationFrame>();
	#end
	public var duration(default, null):Float = 0.0;
	public var id:String;
	public var lastFrameIndex(default, null):Int = -1;
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
	
	#if flash
	private var _frames:Vector<Frame> = new Vector<Frame>();
	#else
	private var _frames:Array<Frame> = new Array<Frame>();
	#end
	private var _timings:Array<Float> = new Array<Float>();

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.duration = this.loopDuration = 0.0;
		#if flash
		this.animationFrames.length = 0;
		#else
		this.animationFrames.resize(0);
		#end
		this.id = null;
		this.lastFrameIndex = -1;
		this.loop = false;
		this.loopFrame = this.numFrames = this.numLoops = 0;
		
		#if flash
		this._frames.length = 0;
		#else
		this._frames.resize(0);
		#end
		this._timings.resize(0);
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addFrame(frame:BasicAnimationFrame):Void
	{
		this.animationFrames[this.animationFrames.length] = frame;
	}
	
	public function addFrameAt(frame:BasicAnimationFrame, index:Int):Void
	{
		#if flash
		this.animationFrames.insertAt(index, frame);
		#else
		this.animationFrames.insert(index, frame);
		#end
	}
	
	public function removeFrame(frame:BasicAnimationFrame, pool:Bool = true):Void
	{
		if (pool) frame.pool();
		#if flash
		this.animationFrames.removeAt(this.animationFrames.indexOf(frame));
		#else
		this.animationFrames.splice(this.animationFrames.indexOf(frame), 1);
		#end
	}
	
	public function removeFrameAt(index:Int, pool:Bool = true):Void
	{
		if (pool) this.animationFrames[index].pool();
		#if flash
		this.animationFrames.removeAt(index);
		#else
		this.animationFrames.splice(index, 1);
		#end
	}
	
	public function ready():Void
	{
		this.numFrames = this.animationFrames.length;
		this.lastFrameIndex = this.numFrames - 1;
		this.duration = this.lastFrameIndex != -1 ? this.animationFrames[this.lastFrameIndex].timing : 0.0;
		if (this.loopFrame == 0 || this.numFrames == 0)
		{
			this.loopDuration = this.duration;
		}
		else
		{
			this.loopDuration = this.duration - this.animationFrames[this.loopFrame - 1].timing;
		}
		
		#if flash
		this._frames.length = 0;
		#else
		this._frames.resize(0);
		#end
		this._timings.resize(0);
		for (i in 0...this.numFrames)
		{
			this._frames[i] = this.animationFrames[i].frame;
			this._timings[i] = this.animationFrames[i].timing;
		}
	}
	
}