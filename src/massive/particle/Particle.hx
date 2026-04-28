package massive.particle;

import massive.data.ImageData;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class Particle extends ImageData 
{
	static private var _POOL:Array<Particle> = new Array<Particle>();
	
	static public function fromPool():Particle
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new Particle();
	}
	
	#if flash
	static public function fromPoolVector(numParticles:Int, particles:Vector<Particle> = null):Vector<Particle>
	{
		if (particles == null) particles = new Vector<Particle>();
		
		var count:Int = _POOL.length;
		var particleIndex:Int = particles.length;
		var poolIndex:Int = count - 1;
		if (count > numParticles) count = numParticles;
		for (i in 0...count)
		{
			particles[particleIndex++] = _POOL[poolIndex--];
		}
		_POOL.resize(_POOL.length - count);
		count = numParticles - count;
		for (i in 0...count)
		{
			particles[particleIndex++] = new Particle();
		}
		
		return particles;
	}
	
	static public function toPoolVector(particles:Vector<Particle>):Void
	{
		var count:Int = particles.length;
		for (i in 0...count)
		{
			particles[i].pool();
		}
	}
	#else
	static public function fromPoolArray(numParticles:Int, particles:Array<Particle> = null):Array<Particle>
	{
		if (particles == null) particles = new Array<Particle>();
		
		var count:Int = _POOL.length;
		var particleIndex:Int = particles.length;
		var poolIndex:Int = count - 1;
		if (count > numParticles) count = numParticles;
		for (i in 0...count)
		{
			particles[particleIndex++] = _POOL[poolIndex--];
		}
		_POOL.resize(_POOL.length - count);
		count = numParticles - count;
		for (i in 0...count)
		{
			particles[particleIndex++] = new Particle();
		}
		
		return particles;
	}
	
	static public function toPoolArray(particles:Array<Particle>):Void
	{
		var count:Int = particles.length;
		for (i in 0...count)
		{
			particles[i].pool();
		}
	}
	#end
	
	public var timeCurrent:Float;
	public var timeTotal:Float;
	
	public var redBase:Float;
	public var greenBase:Float;
	public var blueBase:Float;
	public var alphaBase:Float;
	
	public var alphaStart:Float;
	public var alphaEnd:Float;
	
	public var redDelta:Float = 0.0;
	public var greenDelta:Float = 0.0;
	public var blueDelta:Float = 0.0;
	public var alphaDelta:Float = 0.0;
	
	public var redOffsetBase:Float;
	public var greenOffsetBase:Float;
	public var blueOffsetBase:Float;
	public var alphaOffsetBase:Float;
	
	public var alphaOffsetStart:Float;
	public var alphaOffsetEnd:Float;
	
	public var redOffsetDelta:Float = 0.0;
	public var greenOffsetDelta:Float = 0.0;
	public var blueOffsetDelta:Float = 0.0;
	public var alphaOffsetDelta:Float = 0.0;
	
	public var startX:Float;
	public var startY:Float;
	public var angle:Float;
	public var speed:Float;
	public var velocityX:Float;
	public var velocityY:Float;
	public var radialAcceleration:Float = 0.0;
	public var tangentialAcceleration:Float = 0.0;
	public var emitRadius:Float;
	public var emitRadiusDelta:Float;
	public var emitRotation:Float;
	public var emitRotationDelta:Float;
	public var radialRotationOffset:Float = 0.0;
	public var rotationDelta:Float = 0.0;
	
	public var scaleXStart:Float;
	public var scaleYStart:Float;
	public var scaleXEnd:Float;
	public var scaleYEnd:Float;
	public var scaleXDelta:Float = 0.0;
	public var scaleYDelta:Float = 0.0;
	
	public var skewXBase:Float;
	public var skewYBase:Float;
	public var skewXStart:Float;
	public var skewYStart:Float;
	public var skewXEnd:Float;
	public var skewYEnd:Float;
	public var skewXDelta:Float;
	public var skewYDelta:Float;
	
	public var xBase:Float;
	public var yBase:Float;
	public var rotationBase:Float;
	public var rotationVelocity:Float;
	
	public var dragForce:Float;
	
	// oscillation position
	public var positionOscillationAngle:Float;
	public var positionOscillationRadius:Float;
	public var positionOscillationRadiusOffset:Float = 0.0;
	public var positionOscillationStep:Float;
	public var positionOscillationFrequency:Float;
	public var positionXOscillation:Float;
	public var positionYOscillation:Float;
	
	// oscillation position 2
	public var position2OscillationAngle:Float;
	public var position2OscillationRadius:Float;
	public var position2OscillationRadiusOffset:Float = 0.0;
	public var position2OscillationStep:Float;
	public var position2OscillationFrequency:Float;
	public var position2XOscillation:Float;
	public var position2YOscillation:Float;
	
	// oscillation rotation
	public var rotationOscillationAngle:Float;
	public var rotationOscillationAngleOffset:Float = 0.0;
	public var rotationOscillationStep:Float;
	public var rotationOscillationFrequency:Float;
	public var rotationOscillation:Float;
	
	// oscillation scale
	public var scaleXOscillationFactor:Float;
	public var scaleXOscillationOffset:Float = 0.0;
	public var scaleXOscillationFrequency:Float;
	public var scaleXOscillationStep:Float;
	public var scaleXOscillation:Float;
	
	public var scaleYOscillationFactor:Float;
	public var scaleYOscillationOffset:Float = 0.0;
	public var scaleYOscillationFrequency:Float;
	public var scaleYOscillationStep:Float;
	public var scaleYOscillation:Float;
	
	// oscillation skew
	public var skewXOscillationFactor:Float;
	public var skewXOscillationOffset:Float = 0.0;
	public var skewXOscillationFrequency:Float;
	public var skewXOscillationStep:Float;
	public var skewXOscillation:Float;
	
	public var skewYOscillationFactor:Float;
	public var skewYOscillationOffset:Float = 0.0;
	public var skewYOscillationFrequency:Float;
	public var skewYOscillationStep:Float;
	public var skewYOscillation:Float;
	
	// oscillation color
	public var redOscillationFactor:Float;
	public var greenOscillationFactor:Float;
	public var blueOscillationFactor:Float;
	public var alphaOscillationFactor:Float;
	
	public var redOscillationOffset:Float = 0.0;
	public var greenOscillationOffset:Float = 0.0;
	public var blueOscillationOffset:Float = 0.0;
	public var alphaOscillationOffset:Float = 0.0;
	
	public var colorOscillationStep:Float;
	public var colorOscillationFrequency:Float;
	
	public var redOscillation:Float;
	public var greenOscillation:Float;
	public var blueOscillation:Float;
	public var alphaOscillation:Float;
	
	// oscillation color offset
	public var redOffsetOscillationFactor:Float;
	public var greenOffsetOscillationFactor:Float;
	public var blueOffsetOscillationFactor:Float;
	public var alphaOffsetOscillationFactor:Float;
	
	public var redOffsetOscillationOffset:Float = 0.0;
	public var greenOffsetOscillationOffset:Float = 0.0;
	public var blueOffsetOscillationOffset:Float = 0.0;
	public var alphaOffsetOscillationOffset:Float = 0.0;
	
	public var colorOffsetOscillationStep:Float;
	public var colorOffsetOscillationFrequency:Float;
	
	public var redOffsetOscillation:Float;
	public var greenOffsetOscillation:Float;
	public var blueOffsetOscillation:Float;
	public var alphaOffsetOscillation:Float;
	
	public var scaleXBase:Float;
	public var scaleYBase:Float;
	
	public var scaleXVelocity:Float;
	public var scaleYVelocity:Float;
	
	public var skewXVelocity:Float;
	public var skewYVelocity:Float;
	
	public var sizeXStart:Float;
	public var sizeYStart:Float;
	public var sizeXEnd:Float;
	public var sizeYEnd:Float;
	
	public var isFadingIn:Bool;
	public var fadeInTime:Float;
	public var fadeOutTime:Float;
	public var fadeOutDuration:Float;
	
	#if debug
	public var updateCount:Int;
	#end
	
	public function new() 
	{
		super();
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}