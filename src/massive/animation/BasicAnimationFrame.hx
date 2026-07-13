package massive.animation;
import massive.data.Frame;

/**
 * ...
 * @author Matse
 */
class BasicAnimationFrame 
{
	static private var _POOL:Array<BasicAnimationFrame> = new Array<BasicAnimationFrame>();
	
	static public function fromPool(frame:Frame, timing:Float):BasicAnimationFrame
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(frame, timing);
		return new BasicAnimationFrame(frame, timing);
	}
	
	public var frame:Frame;
	public var timing:Float;
	
	public function new(frame:Frame = null, timing:Float = 0.0) 
	{
		this.frame = frame;
		this.timing = timing;
	}
	
	public function clear():Void
	{
		this.frame = null;
		this.timing = 0.0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(frame:Frame, timing:Float):BasicAnimationFrame
	{
		this.frame = frame;
		this.timing = timing;
		return this;
	}
	
}