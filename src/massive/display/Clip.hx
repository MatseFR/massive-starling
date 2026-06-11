package massive.display;
import massive.animation.Animation;
#if flash
import openfl.Vector;
#end
import massive.animation.AnimationFrame;
import massive.animation.QueuedAnimation;
import massive.display.Img;
import massive.event.MassiveEvent;

/**
 * ...
 * @author Matse
 */
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
	   
	**/
	public var animation(default, null):Animation;
	/**
	   
	**/
	public var animationFrame(default, null):AnimationFrame;
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
	   How many frames
	   @default	0
	**/
	public var numFrames(default, null):Int = 0;
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
		this.animationFrame = this.animation.frames[value];
		this.frame = this.animationFrame.frame;
		this.frameTimingCurrent = this.animationFrame.timing;
		return this._frameIndex = value;
	}
	
	private var _animationComplete:Bool;
	private var _animationMap:Map<String, Animation> = new Map<String, Animation>();
	private var _animationQueue:Array<QueuedAnimation> = new Array<QueuedAnimation>();
	
	#if flash
	private var _frames:Vector<AnimationFrame>;
	#else
	private var _frames:Array<AnimationFrame>;
	#end
	
	private var _playIndex:Int;
	
	private var __tempFrame:AnimationFrame;
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		clearAnimation();
		this.frameDelta = 1.0;
		this.loop = true;
		
		super.clear();
		
		//this.animate = false;
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function clearAnimation():Void
	{
		this.animation = null;
		this.animationFrame = null;
		this._animationComplete = false;
		this._animationMap.clear();
		this._animationQueue.resize(0);
		this._frameIndex = -1;
		this._frames = null;
		this.frameTime = 0.0;
		this.loopCount = this.numLoops = this.numFrames = 0;
		this.animate = false;
	}
	
	public function play(animation:Animation, frameIndex:Int = 0):Void
	{
		this.animation = animation;
		this._frames = this.animation.frames;
		this.numFrames = this.animation.lastFrame;
		this.loop = this.animation.loop;
		this.numLoops = this.animation.numLoops;
		this.frameIndex = frameIndex;
		this.animate = true;
		this._animationComplete = false;
	}
	
	public function playWithID(animationID:String, frameIndex:Int = 0):Void
	{
		play(this._animationMap.get(animationID), frameIndex);
	}
	
	public function resume():Void
	{
		this.animate = true;
	}
	
	public function stop():Void
	{
		this.animate = false;
	}
	
	public function registerAnimation(animation:Animation):Void
	{
		this._animationMap.set(animation.id, animation);
	}
	
	public function unregisterAnimation(animation:Animation):Void
	{
		this._animationMap.remove(animation.id);
	}
	
	public function unregisterAnimationWithID(animationID:String):Void
	{
		this._animationMap.remove(animationID);
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
	
	public function queueWithID(animationID:String, frameIndex:Int = 0):Void
	{
		queue(this._animationMap.get(animationID), frameIndex);
	}
	
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
	
	public function advanceTime(time:Float):Void
	{
		this._playIndex = this._frameIndex;
		this.frameTime += time * this.frameDelta;
		while (this.frameTime > this.frameTimingCurrent)
		{
			if (this._playIndex < this.numFrames)
			{
				++this._playIndex;
				this.__tempFrame = this._frames[this._playIndex];
				this.frameTimingCurrent = this.__tempFrame.timing;
				if (this.__tempFrame.event != null) dispatchEventWith(this.__tempFrame.event, false, this.__tempFrame.eventParams);
			}
			else
			{
				if (this.loop && (this.numLoops == 0 || this.loopCount < this.numLoops))
				{
					this._playIndex = this.animation.loopFrame;
					++this.loopCount;
					//this.frameTime -= this.frameTimingCurrent;
					this.frameTime -= this.animation.loopDuration;
					this.frameTimingCurrent = this._frames[this._playIndex].timing;
				}
				else
				{
					// animation complete
					this._animationComplete = true;
					dispatchEventWith(MassiveEvent.ANIMATION_COMPLETE);
					if (this.animation.nextAnimationID != null)
					{
						playWithID(this.animation.nextAnimationID);
					}
					else
					{
						nextFromQueue();
					}
					if (this._animationComplete) this.animate = false;
					return;
				}
			}
		}
		this.frameIndex = this._playIndex;
	}
	
}