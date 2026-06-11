package massive.particle;
import massive.animation.Animation;

/**
 * ...
 * @author Matse
 */
class ParticleAnimation 
{
	static private var _POOL:Array<ParticleAnimation> = new Array<ParticleAnimation>();
	
	static public function fromPool(animation:Animation, weight:Float = 1.0, textureIndex:Int = 0):ParticleAnimation
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ParticleAnimation(animation, weight, textureIndex);
	}
	
	public var animation:Animation;
	public var textureIndex:Int;
	public var weight:Float;

	public function new(animation:Animation, weight:Float = 1.0, textureIndex:Int = 0) 
	{
		this.animation = animation;
		this.weight = weight;
		this.textureIndex = textureIndex;
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
	
	private function setFromPool(animation:Animation, weight:Float, textureIndex:Int):ParticleAnimation
	{
		this.animation = animation;
		this.weight = weight;
		this.textureIndex = textureIndex;
		return this;
	}
	
}