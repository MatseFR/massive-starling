package massive.display;
import massive.animation.Animation;
import massive.animation.AnimationCollection;
import massive.animation.QueuedAnimation;
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
class Clip extends Img 
{
	static private var _POOL:Array<Clip> = new Array<Clip>();
	
	static public function fromPool():Clip
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new Clip();
	}
	
	/**
	   Tells whether this object is animated or not
	**/
	public var animate:Bool = false;
	/**
	   Current animation, if any
	**/
	public var animation(default, null):Animation;
	/**
	   
	**/
	public var animationCollection:AnimationCollection;
	/**
	   Tells whether current animation is complete or not
	**/
	public var animationComplete(default, null):Bool;
	/**
	   Optionnal function to call on animation complete
	**/
	public var animationCompleteCallback:Clip->Void;
	/**
	   Optionnal function to call when all animations are complete
	**/
	public var completeCallback:Clip->Void;
	/**
	   Playback speed
	   @default	1
	**/
	public var frameDelta:Float = 1.0;
	/**
	   Current frame index, if any
	**/
	public var frameIndex(get, set):Int;
	/**
	   Time elapsed on current animation, if any
	**/
	public var frameTime:Float = 0.0;
	/**
	   Timing to reach before switching to next frame
	**/
	public var frameTimingCurrent(default, null):Float;
	/**
	   Index of the last frame in the current animation
	**/
	public var lastFrameIndex(default, null):Int = -1;
	/**
	   Tells whether to loop animation
	**/
	public var loop:Bool;
	/**
	   Tells how many loops have been played
	   @default	0
	**/
	public var loopCount:Int = 0;
	/**
	   How many loops, 0 == infinite
	   @default	0
	**/
	public var numLoops:Int = 0;
	
	private var _frameIndex:Int = -1;
	private inline function get_frameIndex():Int { return this._frameIndex; }
	private inline function set_frameIndex(value:Int):Int
	{
		if (this._frameIndex == value) return value;
		this.frame = this._frames[value];
		this.frameTimingCurrent = this._timings[value];
		if (this.__useVertexPositionData) this.vertexPosition = this._vertexPositions[value];
		if (this.__useVertexColorData) this.vertexColor = this._vertexColors[value];
		if (this.__useVertexColorOffsetData) this.vertexColorOffset = this._vertexColorOffsets[value];
		return this._frameIndex = value;
	}
	
	#if flash
	private var _animationQueue:Vector<QueuedAnimation> = new Vector<QueuedAnimation>();
	private var _frames:Vector<Frame>;
	private var _vertexPositions:Vector<VertexPositionData> = new Vector<VertexPositionData>();
	private var _vertexColors:Vector<VertexColorData> = new Vector<VertexColorData>();
	private var _vertexColorOffsets:Vector<VertexColorData> = new Vector<VertexColorData>();
	#else
	private var _animationQueue:Array<QueuedAnimation> = new Array<QueuedAnimation>();
	private var _frames:Array<Frame>;
	private var _vertexPositions:Array<VertexPositionData> = new Array<VertexPositionData>();
	private var _vertexColors:Array<VertexColorData> = new Array<VertexColorData>();
	private var _vertexColorOffsets:Array<VertexColorData> = new Array<VertexColorData>();
	#end
	private var _timings:Array<Float>;
	
	private var _animationQueueIndex:Int = -1;
	
	private var __useVertexPositionData:Bool;
	private var __useVertexColorData:Bool;
	private var __useVertexColorOffsetData:Bool;

	public function new() 
	{
		super();
		
	}
	
	override public function clear():Void
	{
		clearAnimation();
		clearQueue();
		this.animationCompleteCallback = null;
		this.frameDelta = 1.0;
		
		super.clear();
	}
	
	override public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function clearAnimation():Void
	{
		this.animation = null;
		this.animationComplete = false;
		this.completeCallback = null;
		this._frameIndex = this.lastFrameIndex = -1;
		this.frameTime = 0.0;
		this.loop = false;
		this.loopCount = this.numLoops = 0;
		this.animate = false;
		
		this._frames = null;
		this._timings = null;
		this._vertexPositions = null;
		this._vertexColors = null;
		this._vertexColorOffsets = null;
	}
	
	@:access(massive.animation.Animation)
	public function play(animation:Animation, frameIndex:Int = 0, numLoops:Int = -1, animationCompleteCallback:Clip->Void = null):Void
	{
		this.animation = animation;
		this.animationComplete = false;
		this.animationCompleteCallback = animationCompleteCallback;
		this._frames = this.animation._frames;
		this._timings = this.animation._timings;
		this._vertexPositions = this.animation._vertexPositions;
		this._vertexColors = this.animation._vertexColors;
		this._vertexColorOffsets = this.animation._vertexColorOffsets;
		this.lastFrameIndex = this.animation.lastFrameIndex;
		if (numLoops == -1)
		{
			this.loop = this.animation.loop;
			this.numLoops = this.animation.numLoops;
		}
		else
		{
			this.loop = true;
			this.numLoops = numLoops;
		}
		
		if (this.__useVertexPositionData) this.vertexPosition = null;
		if (this.__useVertexColorData) this.vertexColor = null;
		if (this.__useVertexColorOffsetData) this.vertexColorOffset = null;
		
		this.__useVertexPositionData = this.animation.hasVertexPosition;
		this.__useVertexColorData = this.animation.hasVertexColor;
		this.__useVertexColorOffsetData = this.animation.hasVertexColorOffset;
		
		this.frameIndex = frameIndex;
		this.frameTime = this._frameIndex == 0 ? 0.0 : this._timings[this._frameIndex - 1];
		
		this.animate = true;
	}
	
	public function playWithID(animationID:String, frameIndex:Int = 0, numLoops:Int = -1, animationCompleteCallback:Clip->Void = null):Void
	{
		play(this.animationCollection.get(animationID), frameIndex, numLoops, animationCompleteCallback);
	}
	
	public function pause():Void
	{
		this.animate = false;
	}
	
	public function resume():Void
	{
		this.animate = true;
	}
	
	public function clearQueue():Void
	{
		var count:Int = this._animationQueue.length;
		for (i in 0...count)
		{
			this._animationQueue[i].pool();
		}
		#if flash
		this._animationQueue.length = 0;
		#else
		this._animationQueue.resize(0);
		#end
		this._animationQueueIndex = -1;
	}
	
	public function playNextFromQueue():Void
	{
		if (++this._animationQueueIndex >= this._animationQueue.length) this._animationQueueIndex = 0;
		var anim:QueuedAnimation = this._animationQueue[this._animationQueueIndex];
		if (anim.removeOnPlay)
		{
			#if flash
			this._animationQueue.removeAt(this._animationQueueIndex--);
			#else
			this._animationQueue.splice(this._animationQueueIndex--, 1);
			#end
			anim.pool();
		}
		play(anim.animation, anim.frameIndex, anim.numLoops, anim.animationCompleteCallback);
	}
	
	public function queue(animation:Animation, frameIndex:Int = 0, numLoops:Int = -1, animationCompleteCallback:Clip->Void, removeOnPlay:Bool = true):Void
	{
		var anim:QueuedAnimation = QueuedAnimation.fromPool(animation, frameIndex, numLoops, animationCompleteCallback, removeOnPlay);
		this._animationQueue[this._animationQueue.length] = anim;
	}
	
	public function removeFromQueue(animation:Animation):Void
	{
		var count:Int = this._animationQueue.length;
		for (i in 0...count)
		{
			if (this._animationQueue[i].animation == animation)
			{
				this._animationQueue[i].pool();
				#if flash
				this._animationQueue.removeAt(i);
				#else
				this._animationQueue.splice(i, 1);
				#end
				break;
			}
		}
	}
	
	public function removeFromQueueWithID(animationID:String):Void
	{
		var count:Int = this._animationQueue.length;
		for (i in 0...count)
		{
			if (this._animationQueue[i].animation.id == animationID)
			{
				this._animationQueue[i].pool();
				#if flash
				this._animationQueue.removeAt(i);
				#else
				this._animationQueue.splice(i, 1);
				#end
				break;
			}
		}
	}
	
}