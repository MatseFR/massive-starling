package massive.particle;
import massive.animation.Animation;

/**
 * ...
 * @author Matse
 */
class ParticleAnimation 
{
	static private var _POOL:Array<ParticleAnimation> = new Array<ParticleAnimation>();
	
	static public function fromPool(animation:Animation, weight:Float = 1.0, textureIndex:Int = 0, randomStartFrameMin:Int = -1, randomStartFrameMax:Int = -1, randomLoopMin:Int = -1, randomLoopMax:Int = -1):ParticleAnimation
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(animation, weight, textureIndex, randomStartFrameMin, randomStartFrameMax, randomLoopMin, randomLoopMax);
		return new ParticleAnimation(animation, weight, textureIndex, randomStartFrameMin, randomStartFrameMax, randomLoopMin, randomLoopMax);
	}
	
	public var animation:Animation;
	public var textureIndex:Int;
	public var weight:Float;
	public var randomLoops:Bool;
	public var randomLoopMax:Int;
	public var randomLoopMin:Int;
	public var randomStart:Bool;
	public var randomStartFrameMax:Int;
	public var randomStartFrameMin:Int;

	public function new(animation:Animation, weight:Float = 1.0, textureIndex:Int = 0, randomStartFrameMin:Int = -1, randomStartFrameMax:Int = -1, randomLoopMin:Int = -1, randomLoopMax:Int = -1) 
	{
		this.animation = animation;
		this.weight = weight;
		this.textureIndex = textureIndex;
		this.randomStart = randomStartFrameMin > -1 || randomStartFrameMax > -1;
		if (this.randomStart)
		{
			if (randomStartFrameMin < 0) randomStartFrameMin = 0;
			if (randomStartFrameMax < 0) randomStartFrameMax = animation.lastFrameIndex;
		}
		this.randomStartFrameMin = randomStartFrameMin;
		this.randomStartFrameMax = randomStartFrameMax;
		this.randomLoops = randomLoopMin > -1 && randomLoopMax > -1;
		this.randomLoopMin = randomLoopMin;
		this.randomLoopMax = randomLoopMax;
	}
	
	public function clear():Void
	{
		this.animation = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(animation:Animation, weight:Float, textureIndex:Int, randomStartFrameMin:Int = -1, randomStartFrameMax:Int = -1, randomLoopMin:Int = -1, randomLoopMax:Int = -1):ParticleAnimation
	{
		this.animation = animation;
		this.weight = weight;
		this.textureIndex = textureIndex;
		this.randomStart = randomStartFrameMin > -1 || randomStartFrameMax > -1;
		if (this.randomStart)
		{
			if (randomStartFrameMin < 0) randomStartFrameMin = 0;
			if (randomStartFrameMax < 0) randomStartFrameMax = animation.lastFrameIndex;
		}
		this.randomStartFrameMin = randomStartFrameMin;
		this.randomStartFrameMax = randomStartFrameMax;
		this.randomLoops = randomLoopMin > -1 && randomLoopMax > -1;
		this.randomLoopMin = randomLoopMin;
		this.randomLoopMax = randomLoopMax;
		return this;
	}
	
}