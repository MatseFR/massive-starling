package massive.animation;
import massive.display.Clip;

/**
 * ...
 * @author Matse
 */
class QueuedAnimation 
{
	static private var _POOL:Array<QueuedAnimation> = new Array<QueuedAnimation>();
	
	static public function fromPool(animation:Animation, frameIndex:Int = 0, numLoops:Int = -1, animationCompleteCallback:Clip->Void = null, removeOnPlay:Bool = false):QueuedAnimation
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(animation, frameIndex, numLoops, animationCompleteCallback, removeOnPlay);
		return new QueuedAnimation(animation, frameIndex, numLoops, animationCompleteCallback, removeOnPlay);
	}
	
	public var animation:Animation;
	public var animationCompleteCallback:Clip->Void;
	public var frameIndex:Int;
	public var numLoops:Int;
	public var removeOnPlay:Bool;

	/**
	   
	   @param	animation
	   @param	frameIndex
	   @param	numLoops	how many loops : -1 = use animation setting, 0 = infinite
	   @param	removeOnPlay
	**/
	public function new(animation:Animation, frameIndex:Int = 0, numLoops:Int = -1, animationCompleteCallback:Clip->Void = null, removeOnPlay:Bool = false) 
	{
		this.animation = animation;
		this.frameIndex = frameIndex;
		this.numLoops = numLoops;
		this.animationCompleteCallback = animationCompleteCallback;
		this.removeOnPlay = removeOnPlay;
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(animation:Animation, frameIndex:Int, numLoops:Int, animationCompleteCallback:Clip->Void, removeOnPlay:Bool):QueuedAnimation
	{
		this.animation = animation;
		this.frameIndex = frameIndex;
		this.numLoops = numLoops;
		this.animationCompleteCallback = animationCompleteCallback;
		this.removeOnPlay = removeOnPlay;
		return this;
	}
	
}