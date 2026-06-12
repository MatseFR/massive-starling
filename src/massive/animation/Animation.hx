package massive.animation;
import massive.data.Frame;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class Animation 
{
	static private var _POOL:Array<Animation> = new Array<Animation>();
	
	static public function fromPool():Animation
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new Animation();
	}
	
	public var duration(default, null):Float = 0.0;
	#if flash
	public var frames:Vector<AnimationFrame> = new Vector<AnimationFrame>();
	#else
	public var frames:Array<AnimationFrame> = new Array<AnimationFrame>();
	#end
	public var hasVertexData(default, null):Bool;
	public var hasVertexColorData(default, null):Bool;
	public var hasVertexColorExData(default, null):Bool;
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
	public var nextAnimationID:String;
	public var numFrames(default, null):Int = 0;
	public var numLoops:Int = 0;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		for (i in 0...this.numFrames)
		{
			this.frames[i].pool();
		}
		#if flash
		this.frames.length = 0;
		#else
		this.frames.resize(0);
		#end
		
		this.duration = this.loopDuration = 0.0;
		this.id = this.nextAnimationID = null;
		this.loop = false;
		this.lastFrame = this.loopFrame = this.numFrames = this.numLoops = 0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addFrame(frame:AnimationFrame):Void
	{
		this.frames[this.frames.length] = frame;
	}
	
	public function addFrameAt(frame:AnimationFrame, index:Int):Void
	{
		#if flash
		this.frames.insertAt(index, frame);
		#else
		this.frames.insert(index, frame);
		#end
	}
	
	public function removeFrame(frame:AnimationFrame, pool:Bool = true):Void
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
		
		this.hasVertexData = false;
		this.hasVertexColorData = false;
		this.hasVertexColorExData = false;
		
		var frame:AnimationFrame;
		var count:Int = this.frames.length;
		for (i in 0...count)
		{
			frame = this.frames[i];
			if (!this.hasVertexData && frame.vertexData != null) this.hasVertexData = true;
			if (!this.hasVertexColorData && frame.vertexColorData != null) this.hasVertexColorData = true;
			if (!this.hasVertexColorExData && frame.vertexColorExData != null) this.hasVertexColorExData = true;
			
			if (this.hasVertexData && this.hasVertexColorData && this.hasVertexColorExData) break;
		}
	}
	
}