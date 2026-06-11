package massive.animation;
import massive.data.Frame;

/**
 * ...
 * @author Matse
 */
class AnimationFrame 
{
	static private var _POOL:Array<AnimationFrame> = new Array<AnimationFrame>();
	
	static public function fromPool(frame:Frame = null, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null):AnimationFrame
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(frame, timing, event, eventParams);
		return new AnimationFrame(frame, timing, event, eventParams);
	}
	
	public var event:String;
	public var eventParams:Dynamic;
	public var frame:Frame;
	public var timing:Float;

	public function new(frame:Frame = null, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null) 
	{
		this.frame = frame;
		this.timing = timing;
		this.event = event;
		this.eventParams = eventParams;
	}
	
	public function clear():Void
	{
		this.event = null;
		this.eventParams = null;
		this.frame = null;
		this.timing = 0.0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(frame:Frame, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null):AnimationFrame
	{
		this.frame = frame;
		this.timing = timing;
		this.event = event;
		this.eventParams = eventParams;
		return this;
	}
	
}