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
class EventClip extends Clip 
{
	static private var _POOL:Array<EventClip> = new Array<EventClip>();
	
	/**
	   
	   @return
	**/
	static public function fromPool():EventClip
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new EventClip();
	}
	
	/**
	   
	   @param	numClips
	   @param	clips
	   @return
	**/
	static public function fromPoolArray(numClips:Int, clips:Array<EventClip> = null):Array<EventClip>
	{
		if (clips == null) clips = new Array<EventClip>();
		
		while (numClips != 0)
		{
			if (_POOL.length == 0) break;
			clips[clips.length] = _POOL.pop();
			numClips--;
		}
		
		while (numClips != 0)
		{
			clips[clips.length] = new EventClip();
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
	static public function fromPoolVector(numClips:Int, clips:Vector<EventClip> = null):Vector<EventClip>
	{
		if (clips == null) clips = new Vector<EventClip>();
		
		while (numClips != 0)
		{
			if (_POOL.length == 0) break;
			clips[clips.length] = _POOL.pop();
			numClips--;
		}
		
		while (numClips != 0)
		{
			clips[clips.length] = new EventClip();
			numClips--;
		}
		
		return clips;
	}
	#end
	
	static public function toPool(clip:EventClip):Void
	{
		clip.clear();
		_POOL[_POOL.length] = clip;
	}
	
	static public function toPoolArray(clips:Array<EventClip>):Void
	{
		var count:Int = clips.length;
		for (i in 0...count)
		{
			clips[i].pool();
		}
	}
	
	#if flash
	static public function toPoolVector(clips:Vector<EventClip>):Void
	{
		var count:Int = clips.length;
		for (i in 0...count)
		{
			clips[i].pool();
		}
	}
	#end
	
	private var _eventDispatcher:EventDispatcher = new EventDispatcher();
	
	#if flash
	private var _events:Vector<String>;
	private var _eventParams:Vector<Dynamic>;
	#else
	private var _events:Array<String>;
	private var _eventParams:Array<Dynamic>;
	#end
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		clearAnimation();
		
		super.clear();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override public function clearAnimation():Void
	{
		this._events = null;
		this._eventParams = null;
		
		super.clearAnimation();
	}
	
	override public function play(animation:Animation, frameIndex:Int = 0, numLoops:Int = -1, completeCallback:Clip->Void = null):Void
	{
		this._events = animation._events;
		this._eventParams = animation._eventParams;
		
		super.play(animation, frameIndex, numLoops, completeCallback);
	}
	
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