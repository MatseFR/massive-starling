package massive.particle;

/**
 * ...
 * @author Matse
 */
class ParticleEmitter 
{
	static private var _POOL:Array<ParticleEmitter> = new Array<ParticleEmitter>();
	
	static public function fromPool():ParticleEmitter
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ParticleEmitter();
	}
	
	public var x:Float = 0.0;
	public var y:Float = 0.0;
	public var velocityX:Float = 0.0;
	public var velocityY:Float = 0.0;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.x = this.y = this.velocityX = this.velocityY = 0.0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function advanceSystem(system:ParticleSystem<Dynamic>, passedTime:Float):Void
	{
		system.emitterX = this.x;
		system.emitterY = this.y;
		system.velocityX = this.velocityX;
		system.velocityY = this.velocityY;
	}
	
}