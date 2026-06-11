package massive.animation;

/**
 * ...
 * @author Matse
 */
class QueuedAnimation 
{
	static private var _POOL:Array<QueuedAnimation> = new Array<QueuedAnimation>();
	
	static public function fromPool(animation:Animation, frameIndex:Int = 0):QueuedAnimation
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new QueuedAnimation(animation, frameIndex);
	}
	
	public var animation:Animation;
	public var frameIndex:Int;

	public function new(animation:Animation, frameIndex:Int = 0) 
	{
		this.animation = animation;
		this.frameIndex = frameIndex;
	}
	
	public function clear():Void
	{
		this.animation = null;
		this.frameIndex = 0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(animation:Animation, frameIndex:Int):QueuedAnimation
	{
		this.animation = animation;
		this.frameIndex = frameIndex;
		return this;
	}
	
}