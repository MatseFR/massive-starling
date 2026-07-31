package massive.display;
import haxe.Constraints.Function;
import massive.animation.Animation;
#if flash
import openfl.Vector;
#end
import massive.animation.AnimationFrame;
import massive.animation.QueuedAnimation;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;
import massive.display.Img;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * ...
 * @author Matse
 */
@:access(massive.animation.Animation)
class Clip extends Img 
{
	static private var _POOL:Array<Clip> = new Array<Clip>();
	
	/**
	   
	   @return
	**/
	static public function fromPool():Clip
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new Clip();
	}
	
	/**
	   
	   @param	numClips
	   @param	clips
	   @return
	**/
	static public function fromPoolArray(numClips:Int, clips:Array<Clip> = null):Array<Clip>
	{
		if (clips == null) clips = new Array<Clip>();
		
		while (numClips != 0)
		{
			if (_POOL.length == 0) break;
			clips[clips.length] = _POOL.pop();
			numClips--;
		}
		
		while (numClips != 0)
		{
			clips[clips.length] = new Clip();
			numClips--;
		}
		
		return clips;
	}
	
	#if flash
	/**
	   
	   @param	numClips
	   @param	clips
	   @return
	**/
	static public function fromPoolVector(numClips:Int, clips:Vector<Clip> = null):Vector<Clip>
	{
		if (clips == null) clips = new Vector<Clip>();
		
		while (numClips != 0)
		{
			if (_POOL.length == 0) break;
			clips[clips.length] = _POOL.pop();
			numClips--;
		}
		
		while (numClips != 0)
		{
			clips[clips.length] = new Clip();
			numClips--;
		}
		
		return clips;
	}
	#end
	
	static public function toPool(clip:Clip):Void
	{
		clip.clear();
		_POOL[_POOL.length] = clip;
	}
	
	static public function toPoolArray(clips:Array<Clip>):Void
	{
		var count:Int = clips.length;
		for (i in 0...count)
		{
			clips[i].pool();
		}
	}
	
	#if flash
	static public function toPoolVector(clips:Vector<Clip>):Void
	{
		var count:Int = clips.length;
		for (i in 0...count)
		{
			clips[i].pool();
		}
	}
	#end
	
	/**
	   Tells whether this object is animated or not
	**/
	public var animate:Bool = false;
	/**
	   
	**/
	public var animation(default, null):Animation;
	/**
	   Playback speed
	   @default	1
	**/
	public var frameDelta:Float = 1.0;
	/**
	   Index of the current frame
	   @default	0
	**/
	public var frameIndex(get, set):Int;
	/**
	   Time elapsed on current frame
	   @default	0
	**/
	public var frameTime:Float = 0.0;
	/**
	   Timing of the current frame
	**/
	public var frameTimingCurrent(default, null):Float;
	/**
	   Index of the last frame in the current animation
	**/
	public var lastFrameIndex:Int = -1;
	/**
	   Tells whether to loop frames
	   @default	true
	**/
	public var loop:Bool = true;
	/**
	   Tells how many loops have been done
	   @default	0
	**/
	public var loopCount:Int = 0;
	/**
	   How many loops, 0 == infinite
	   @default	0
	**/
	public var numLoops:Int = 0;
	
	private var _frameIndex:Int = -1;
	inline private function get_frameIndex():Int { return this._frameIndex; }
	inline private function set_frameIndex(value:Int):Int
	{
		if (this._frameIndex == value) return value;
		this.frame = this._frames[value];
		this.frameTimingCurrent = this._timings[value];
		if (this.__useVertexPositionData) this.vertexPosition = this._vertexPositions[value];
		if (this.__useVertexColorData) this.vertexColor = this._vertexColors[value];
		if (this.__useVertexColorOffsetData) this.vertexColorOffset = this._vertexColorOffsets[value];
		return this._frameIndex = value;
	}
	
	private var _animationComplete:Bool;
	private var _animationQueue:Array<QueuedAnimation> = new Array<QueuedAnimation>();
	
	private var _eventDispatcher:EventDispatcher = new EventDispatcher();
	
	#if flash
	private var _animationFrames:Vector<AnimationFrame>;
	private var _frames:Vector<Frame>;
	private var _events:Vector<String>;
	private var _eventParams:Vector<Dynamic>;
	private var _vertexPositions:Vector<VertexPositionData> = new Vector<VertexPositionData>();
	private var _vertexColors:Vector<VertexColorData> = new Vector<VertexColorData>();
	private var _vertexColorOffsets:Vector<VertexColorData> = new Vector<VertexColorData>();
	#else
	private var _animationFrames:Array<AnimationFrame>;
	private var _frames:Array<Frame>;
	private var _events:Array<String>;
	private var _eventParams:Array<Dynamic>;
	private var _vertexPositions:Array<VertexPositionData> = new Array<VertexPositionData>();
	private var _vertexColors:Array<VertexColorData> = new Array<VertexColorData>();
	private var _vertexColorOffsets:Array<VertexColorData> = new Array<VertexColorData>();
	#end
	private var _timings:Array<Float>;
	
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
		this._animationComplete = false;
		this._animationQueue.resize(0);
		this._frameIndex = this.lastFrameIndex = -1;
		this._animationFrames = null;
		this.frameTime = 0.0;
		this.loop = false;
		this.loopCount = this.numLoops = 0;
		this.animate = false;
		
		this._frames = null;
		this._timings = null;
		this._events = null;
		this._eventParams = null;
		this._vertexPositions = null;
		this._vertexColors = null;
		this._vertexColorOffsets = null;
	}
	
	public function play(animation:Animation, frameIndex:Int = 0):Void
	{
		this.animation = animation;
		this._animationFrames = this.animation.animationFrames;
		this._frames = this.animation._frames;
		this._timings = this.animation._timings;
		this._events = this.animation._events;
		this._eventParams = this.animation._eventParams;
		this._vertexPositions = this.animation._vertexPositions;
		this._vertexColors = this.animation._vertexColors;
		this._vertexColorOffsets = this.animation._vertexColorOffsets;
		this.lastFrameIndex = this.animation.lastFrameIndex;
		this.loop = this.animation.loop;
		this.numLoops = this.animation.numLoops;
		this.frameIndex = frameIndex;
		this.frameTime = this._frameIndex == 0 ? 0.0 : this._timings[this._frameIndex - 1];
		this.animate = true;
		this._animationComplete = false;
		
		this.__useVertexPositionData = this.animation.hasVertexPosition;
		this.__useVertexColorData = this.animation.hasVertexColor;
		this.__useVertexColorOffsetData = this.animation.hasVertexColorOffset;
	}
	
	//public function playWithID(animationID:String, frameIndex:Int = 0):Void
	//{
		//play(this._animationMap.get(animationID), frameIndex);
	//}
	
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
		this._animationQueue.resize(0);
	}
	
	public function nextFromQueue():Void
	{
		if (this._animationQueue.length == 0) return;
		var anim:QueuedAnimation = this._animationQueue.shift();
		play(anim.animation, anim.frameIndex);
	}
	
	public function queue(animation:Animation, frameIndex:Int = 0):Void
	{
		var anim:QueuedAnimation = QueuedAnimation.fromPool(animation, frameIndex);
		this._animationQueue[this._animationQueue.length] = anim;
	}
	
	//public function queueWithID(animationID:String, frameIndex:Int = 0):Void
	//{
		//queue(this._animationMap.get(animationID), frameIndex);
	//}
	
	public function removeFromQueue(animation:Animation):Void
	{
		var count:Int = this._animationQueue.length;
		for (i in 0...count)
		{
			if (this._animationQueue[i].animation == animation)
			{
				this._animationQueue[i].pool();
				this._animationQueue.splice(i, 1);
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
				this._animationQueue.splice(i, 1);
				break;
			}
		}
	}
	
	//override public function advanceTime(time:Float):Void
	//{
		//this._playIndex = this._frameIndex;
		//this.frameTime += time * this.frameDelta;
		//while (this.frameTime > this.frameTimingCurrent)
		//{
			//if (this._playIndex < this.lastFrameIndex)
			//{
				//++this._playIndex;
				//this.__tempFrame = this._frames[this._playIndex];
				//this.frameTimingCurrent = this.__tempFrame.timing;
				////if (this.__tempFrame.event != null) dispatchEventWith(this.__tempFrame.event, false, this.__tempFrame.eventParams);
			//}
			//else
			//{
				//if (this.loop && (this.numLoops == 0 || this.loopCount < this.numLoops))
				//{
					//this._playIndex = this.animation.loopFrame;
					//++this.loopCount;
					////this.frameTime -= this.frameTimingCurrent;
					//this.frameTime -= this.animation.loopDuration;
					//this.frameTimingCurrent = this._frames[this._playIndex].timing;
				//}
				//else
				//{
					//// animation complete
					//this._animationComplete = true;
					////dispatchEventWith(MassiveEvent.ANIMATION_COMPLETE);
					//if (this.animation.nextAnimationID != null)
					//{
						////playWithID(this.animation.nextAnimationID);
					//}
					//else
					//{
						//nextFromQueue();
					//}
					//if (this._animationComplete) this.animate = false;
					////return;
				//}
			//}
		//}
		//this.frameIndex = this._playIndex;
	//}
	
	inline public function addEventListener(type:String, listener:Function):Void
	{
		this._eventDispatcher.addEventListener(type, listener);
	}
	
	inline public function removeEventListener(type:String, listener:Function):Void
	{
		this._eventDispatcher.removeEventListener(type, listener);
	}
	
	inline public function removeEventListeners(type:String = null):Void
	{
		this._eventDispatcher.removeEventListeners(type);
	}
	
	inline public function dispatchEvent(event:Event):Void
	{
		this._eventDispatcher.dispatchEvent(event);
	}
	
	inline public function dispatchEventWith(type:String, bubbles:Bool = false, data:Dynamic = null):Void
	{
		this._eventDispatcher.dispatchEventWith(type, bubbles, data);
	}
	
	inline public function hasEventListener(type:String, listener:Function = null):Bool
	{
		return this._eventDispatcher.hasEventListener(type, listener);
	}
	
}