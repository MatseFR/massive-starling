package massive.particle;

import massive.data.ImageData;
import openfl.Vector;

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
	
	public var timeCurrent:Float;
	public var timeTotal:Float;
	
	public var colorRedStart:Float;
	public var colorGreenStart:Float;
	public var colorBlueStart:Float;
	public var colorAlphaStart:Float;
	
	public var colorRedDelta:Float;
	public var colorGreenDelta:Float;
	public var colorBlueDelta:Float;
	public var colorAlphaDelta:Float;
	
	public var colorRedEnd:Float;
	public var colorGreenEnd:Float;
	public var colorBlueEnd:Float;
	public var colorAlphaEnd:Float;
	
	public var startX:Float;
	public var startY:Float;
	public var angle:Float;
	public var speed:Float;
	public var velocityX:Float;
	public var velocityY:Float;
	public var radialAcceleration:Float;
	public var tangentialAcceleration:Float;
	public var emitRadius:Float;
	public var emitRadiusDelta:Float;
	public var emitRotation:Float;
	public var emitRotationDelta:Float;
	public var rotationDelta:Float;
	
	public var scaleXStart:Float;
	public var scaleYStart:Float;
	public var scaleXEnd:Float;
	public var scaleYEnd:Float;
	public var scaleXDelta:Float;
	public var scaleYDelta:Float;
	
	// NEW
	public var isFadingIn:Bool;
	public var xBase:Float;
	public var yBase:Float;
	public var rotationBase:Float;
	
	public var colorRedBase:Float;
	public var colorGreenBase:Float;
	public var colorBlueBase:Float;
	public var colorAlphaBase:Float;
	
	public var dragForce:Float;
	
	// oscillation position
	public var oscillationPositionAngle:Float;
	public var oscillationPositionRadius:Float;
	public var oscillationPositionStep:Float;
	public var oscillationPositionFrequency:Float;
	public var oscillationPositionX:Float;
	public var oscillationPositionY:Float;
	
	// oscillation position 2
	public var oscillationPosition2Angle:Float;
	public var oscillationPosition2Radius:Float;
	public var oscillationPosition2Step:Float;
	public var oscillationPosition2Frequency:Float;
	public var oscillationPosition2X:Float;
	public var oscillationPosition2Y:Float;
	
	// oscillation rotation
	public var oscillationRotationAngle:Float;
	public var oscillationRotationStep:Float;
	public var oscillationRotationFrequency:Float;
	public var oscillationRotation:Float;
	
	// oscillation scale
	public var oscillationScaleX:Float;
	public var oscillationScaleY:Float;
	public var oscillationScaleXStep:Float;
	public var oscillationScaleYStep:Float;
	public var oscillationScaleXFrequency:Float;
	public var oscillationScaleYFrequency:Float;
	public var scaleXOscillation:Float;
	public var scaleYOscillation:Float;
	
	// oscillation color
	public var oscillationColorRedFactor:Float;
	public var oscillationColorGreenFactor:Float;
	public var oscillationColorBlueFactor:Float;
	public var oscillationColorAlphaFactor:Float;
	public var oscillationColorStep:Float;
	public var oscillationColorFrequency:Float;
	
	public var oscillationColorRed:Float;
	public var oscillationColorGreen:Float;
	public var oscillationColorBlue:Float;
	public var oscillationColorAlpha:Float;
	
	public var scaleXBase:Float;
	public var scaleYBase:Float;
	
	public var scaleXVelocity:Float;
	public var scaleYVelocity:Float;
	//\NEW
	
	public var sizeXStart:Float;
	public var sizeYStart:Float;
	public var sizeXEnd:Float;
	public var sizeYEnd:Float;
	
	public var fadeInTime:Float;
	public var fadeOutTime:Float;
	public var fadeOutDuration:Float;
	
	public function new() 
	{
		super();
		//this.visible = false;
	}
	
	override public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}