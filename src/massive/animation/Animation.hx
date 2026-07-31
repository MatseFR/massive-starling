package massive.animation;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;

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
	
	#if flash
	public var animationFrames:Vector<AnimationFrame> = new Vector<AnimationFrame>();
	#else
	public var animationFrames:Array<AnimationFrame> = new Array<AnimationFrame>();
	#end
	public var duration(default, null):Float = 0.0;
	public var hasVertexPosition(default, null):Bool;
	public var hasVertexColor(default, null):Bool;
	public var hasVertexColorOffset(default, null):Bool;
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
	public var nextAnimationID:String;
	public var numFrames(default, null):Int = 0;
	public var numLoops:Int = 0;
	
	#if flash
	private var _frames:Vector<Frame> = new Vector<Frame>();
	private var _events:Vector<String> = new Vector<String>();
	private var _eventParams:Vector<Dynamic> = new Vector<Dynamic>();
	private var _vertexPositions:Vector<VertexPositionData> = new Vector<VertexPositionData>();
	private var _vertexColors:Vector<VertexColorData> = new Vector<VertexColorData>();
	private var _vertexColorOffsets:Vector<VertexColorData> = new Vector<VertexColorData>();
	#else
	private var _frames:Array<Frame> = new Array<Frame>();
	private var _events:Array<String> = new Array<String>();
	private var _eventParams:Array<Dynamic> = new Array<Dynamic>();
	private var _vertexPositions:Array<VertexPositionData> = new Array<VertexPositionData>();
	private var _vertexColors:Array<VertexColorData> = new Array<VertexColorData>();
	private var _vertexColorOffsets:Array<VertexColorData> = new Array<VertexColorData>();
	#end
	private var _timings:Array<Float> = new Array<Float>();
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		for (i in 0...this.numFrames)
		{
			this.animationFrames[i].pool();
		}
		#if flash
		this.animationFrames.length = 0;
		#else
		this.animationFrames.resize(0);
		#end
		
		this.duration = this.loopDuration = 0.0;
		this.id = this.nextAnimationID = null;
		this.loop = false;
		this.lastFrameIndex = -1;
		this.loopFrame = this.numFrames = this.numLoops = 0;
		
		#if flash
		this._frames.length = 0;
		this._events.length = 0;
		this._eventParams.length = 0;
		this._vertexPositions.length = 0;
		this._vertexColors.length = 0;
		this._vertexColorOffsets.length = 0;
		#else
		this._frames.resize(0);
		this._events.resize(0);
		this._eventParams.resize(0);
		this._vertexPositions.resize(0);
		this._vertexColors.resize(0);
		this._vertexColorOffsets.resize(0);
		#end
		this._timings.resize(0);
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addFrame(frame:AnimationFrame):Void
	{
		this.animationFrames[this.animationFrames.length] = frame;
	}
	
	public function addFrameAt(frame:AnimationFrame, index:Int):Void
	{
		#if flash
		this.animationFrames.insertAt(index, frame);
		#else
		this.animationFrames.insert(index, frame);
		#end
	}
	
	public function removeFrame(frame:AnimationFrame, pool:Bool = true):Void
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
		
		this.hasVertexPosition = false;
		this.hasVertexColor = false;
		this.hasVertexColorOffset = false;
		
		#if flash
		this._frames.length = 0;
		this._events.length = 0;
		this._eventParams.length = 0;
		this._vertexPositions.length = 0;
		this._vertexColors.length = 0;
		this._vertexColorOffsets.length = 0;
		#else
		this._frames.resize(0);
		this._events.resize(0);
		this._eventParams.resize(0);
		this._vertexPositions.resize(0);
		this._vertexColors.resize(0);
		this._vertexColorOffsets.resize(0);
		#end
		this._timings.resize(0);
		
		var frame:AnimationFrame;
		var count:Int = this.animationFrames.length;
		for (i in 0...count)
		{
			frame = this.animationFrames[i];
			if (!this.hasVertexPosition && frame.vertexPosition != null) this.hasVertexPosition = true;
			if (!this.hasVertexColor && frame.vertexColor != null) this.hasVertexColor = true;
			if (!this.hasVertexColorOffset && frame.vertexColorOffset != null) this.hasVertexColorOffset = true;
			
			//if (this.hasVertexPosition && this.hasVertexColor && this.hasVertexColorOffset) break;
			this._frames[i] = frame.frame;
			this._timings[i] = frame.timing;
			this._events[i] = frame.event;
			this._eventParams[i] = frame.eventParams;
			this._vertexPositions[i] = frame.vertexPosition;
			this._vertexColors[i] = frame.vertexColor;
			this._vertexColorOffsets[i] = frame.vertexColorOffset;
		}
	}
	
}