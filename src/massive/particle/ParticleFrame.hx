package massive.particle;
import massive.data.Frame;

/**
 * ...
 * @author Matse
 */
class ParticleFrame 
{
	static private var _POOL:Array<ParticleFrame> = new Array<ParticleFrame>();
	
	static public function fromPool(frame:Frame, weight:Float = 1.0, textureIndex:Int = 0):ParticleFrame
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(frame, weight, textureIndex);
		return new ParticleFrame(frame, weight, textureIndex);
	}
	
	public var frame:Frame;
	public var textureIndex:Int;
	public var weight:Float;
	
	public function new(frame:Frame, weight:Float = 1.0, textureIndex:Int = 0) 
	{
		this.frame = frame;
		this.weight = weight;
		this.textureIndex = textureIndex;
	}
	
	public function clear():Void
	{
		this.frame = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(frame:Frame, weight:Float, textureIndex:Int):ParticleFrame
	{
		this.frame = frame;
		this.weight = weight;
		this.textureIndex = textureIndex;
		return this;
	}
	
}