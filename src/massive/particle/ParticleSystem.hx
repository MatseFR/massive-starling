package massive.particle;

import massive.animation.Animator;
import massive.data.Frame;
import massive.display.ImageLayer;
import massive.util.MassiveTint;
import massive.util.MathUtils;
#if flash
import openfl.Vector;
#end
import openfl.errors.Error;
import openfl.geom.Rectangle;
import starling.events.Event;

/**
 * ...
 * @author Matse
 */
@:generic
class ParticleSystem<T:Particle = Particle> extends ImageLayer<T>
{
	public var autoClearOnComplete:Bool = ParticleSystemDefaults.AUTO_CLEAR_ON_COMPLETE;
	public var randomSeed:Int = ParticleSystemDefaults.RANDOM_SEED;
	
	#if flash
	public var particlesFromPoolFunction:Int->Vector<T>->Vector<T>;
	public var particlesToPoolFunction:Vector<T>->Void;
	#else
	public var particlesFromPoolFunction:Int->Array<T>->Array<T>;
	public var particlesToPoolFunction:Array<T>->Void;
	#end
	
	//##################################################
	// EMITTER
	//##################################################
	private var _isTypeGravity:Bool = true;
	private var _isTypeRadial:Bool = false;
	/**
	   Possible values :
	   - 0 for gravity
	   - 1 for radial
	   @default 0
	**/
	public var emitterType(get, set):Int;
	private var _emitterType:Int = EmitterType.GRAVITY;
	private function get_emitterType():Int { return this._emitterType; }
	private function set_emitterType(value:Int):Int
	{
		if (value == EmitterType.GRAVITY)
		{
			this._isTypeGravity = true;
			this._isTypeRadial = false;
		}
		else
		{
			this._isTypeGravity = false;
			this._isTypeRadial = true;
		}
		return this._emitterType = value;
	}
	
	private var _isModeBurst:Bool = false;
	private var _isModeStream:Bool = true;
	
	/**
	   Possible values :
	   - 0 for burst
	   - 1 for stream
	   @default 1
	**/
	public var emitterMode(get, set):Int;
	private var _emitterMode:Int = EmitterMode.STREAM;
	private function get_emitterMode():Int { return this._emitterMode; }
	private function set_emitterMode(value:Int):Int
	{
		if (value == EmitterMode.BURST)
		{
			this._isModeBurst = true;
			this._isModeStream = false;
		}
		else
		{
			this._isModeBurst = false;
			this._isModeStream = true;
		}
		if (this._autoSetEmissionRate) updateEmissionRate();
		return this._emitterMode = value;
	}
	
	/**
	   Maximum number of particles used by the system
	   @default 1000
	**/
	public var maxNumParticles(get, set):Int;
	private var _maxNumParticles:Int = 1000;
	private function get_maxNumParticles():Int { return this._maxNumParticles; }
	private function set_maxNumParticles(value:Int):Int
	{
		if (this._maxNumParticles == value) return value;
		returnParticlesToPool();
		this._maxNumParticles = value;
		if (this.particlesFromPoolFunction != null && this._frames.length != 0)
		{
			getParticlesFromPool();
		}
		else
		{
			this._isParticlePoolUpdatePending = true;
		}
		if (this._autoSetEmissionRate) updateEmissionRate();
		return this._maxNumParticles;
	}
	
	private var _particleAmountEnabled:Bool = false;
	
	/**
	   The amount of particles this system can create over time, 0 = infinite
	   @default 0
	**/
	public var particleAmount(get, set):Int ;
	private var _particleAmount:Int = 0;
	private function get_particleAmount():Int { return this._particleAmount; }
	private function set_particleAmount(value:Int):Int
	{
		this._particleAmountEnabled = value != 0;
		return this._particleAmount = value;
	}
	
	private var _burstsInfinite:Bool;
	
	/**
	   How many bursts before completing, 0 = infinite
	   @default	1
	**/
	public var numBursts(get, set):Int;
	private var _numBursts:Int = 1;
	private function get_numBursts():Int { return this._numBursts; }
	private function set_numBursts(value:Int):Int
	{
		this._numBursts = value;
		this._burstsInfinite = this._numBursts == 0;
		this._burstRemaining = this._burstsInfinite || this._burstTotal < this._numBursts;
		if (this._isModeBurst && this._autoSetEmissionRate) updateEmissionRate();
		return this._numBursts;
	}
	
	private var _burstsInstant:Bool = true;
	
	/**
	   Burst duration, 0 = instant
	   @default	0
	**/
	public var burstDuration(get, set):Float;
	private var _burstDuration:Float = 0.0;
	private function get_burstDuration():Float { return this._burstDuration; }
	private function set_burstDuration(value:Float):Float
	{
		this._burstDuration = value;
		this._burstsInstant = this._burstDuration == 0.0;
		if (this._isModeBurst && this._autoSetEmissionRate) updateEmissionRate();
		return this._burstDuration;
	}
	
	/**
	   How much time between 2 bursts
	**/
	public var burstInterval:Float;
	private var _burstInterval:Float = 1.0;
	private function get_burstInterval():Float { return this._burstInterval; }
	private function set_burstInterval(value:Float):Float
	{
		this._burstInterval = value;
		if (this._isModeBurst && this._autoSetEmissionRate) updateEmissionRate();
		return this._burstInterval;
	}
	
	/**
	   How much time variance between 2 bursts
	**/
	public var burstIntervalVariance:Float = 0.0;
	
	/**
	   Tells whether the particle system should automatically set its emission rate or not
	   @default true
	**/
	public var autoSetEmissionRate(get, set):Bool;
	private var _autoSetEmissionRate:Bool = true;
	private function get_autoSetEmissionRate():Bool { return this._autoSetEmissionRate; }
	private function set_autoSetEmissionRate(value:Bool):Bool
	{
		if (this._autoSetEmissionRate == value) return value;
		if (value) updateEmissionRate();
		return this._autoSetEmissionRate = value;
	}
	
	private var _timeBetweenParticles:Float = 0.01;
	
	/**
	   How many particles are created per second
	   @default 100
	**/
	public var emissionRate(get, set):Float;
	private var _emissionRate:Float = 100;
	private function get_emissionRate():Float { return this._emissionRate; }
	private function set_emissionRate(value:Float):Float
	{
		this._timeBetweenParticles = 1.0 / value;
		return this._emissionRate = value;
	}
	
	/**
	   Percentage of max particles to consider when automatically setting emission rate
	   @default 1.0
	**/
	public var emissionRatio(get, set):Float;
	private var _emissionRatio:Float = 1.0;
	private function get_emissionRatio():Float { return this._emissionRatio; }
	private function set_emissionRatio(value:Float):Float
	{
		if (this._emissionRatio == value) return value;
		this._emissionRatio = value;
		if (this._autoSetEmissionRate) updateEmissionRate();
		return this._emissionRatio;
	}
	
	/**
	   Horizontal emitter position
	   @default 0
	**/
	public var emitterX:Float = 0;
	
	/**
	   Horizontal emitter position variance
	   @default 0
	**/
	public var emitterXVariance:Float = 0;
	
	/**
	   Vertical emitter position
	   @default 0
	**/
	public var emitterY:Float = 0;
	
	/**
	   Vertical emitter position variance
	   @default 0
	**/
	public var emitterYVariance:Float = 0;
	
	private var _useEmitterRadius:Bool = false;
	
	/**
	   @default 0
	**/
	public var emitterRadiusMax(get, set):Float;
	private var _emitterRadiusMax:Float = 0;
	private function get_emitterRadiusMax():Float { return this._emitterRadiusMax; }
	private function set_emitterRadiusMax(value:Float):Float
	{
		this._emitterRadiusMax = value;
		checkEmitterRadius();
		return this._emitterRadiusMax;
	}
	
	/**
	   @default 0
	**/
	public var emitterRadiusMaxVariance(get, set):Float;
	private var _emitterRadiusMaxVariance:Float = 0;
	private function get_emitterRadiusMaxVariance():Float { return this._emitterRadiusMaxVariance; }
	private function set_emitterRadiusMaxVariance(value:Float):Float
	{
		this._emitterRadiusMaxVariance = value;
		checkEmitterRadius();
		return this._emitterRadiusMaxVariance;
	}
	
	/**
	   @default 0
	**/
	public var emitterRadiusMin(get, set):Float;
	private var _emitterRadiusMin:Float = 0;
	private function get_emitterRadiusMin():Float { return this._emitterRadiusMin; }
	private function set_emitterRadiusMin(value:Float):Float
	{
		this._emitterRadiusMin = value;
		checkEmitterRadius();
		return this._emitterRadiusMin;
	}
	
	/**
	   @default 0
	**/
	public var emitterRadiusMinVariance(get, set):Float;
	private var _emitterRadiusMinVariance:Float = 0;
	private function get_emitterRadiusMinVariance():Float { return this._emitterRadiusMinVariance; }
	private function set_emitterRadiusMinVariance(value:Float):Float
	{
		this._emitterRadiusMinVariance = value;
		checkEmitterRadius();
		return this._emitterRadiusMinVariance;
	}
	
	/**
	   @default	false
	**/
	public var emitterRadiusOverridesParticleAngle:Bool = false;
	
	/**
	   @default	0
	**/
	public var emitterRadiusParticleAngleOffset:Float = 0.0;
	
	/**
	   @default	0
	**/
	public var emitterRadiusParticleAngleOffsetVariance:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var emitAngle:Float = 0;
	
	/**
	   @default Math.PI
	**/
	public var emitAngleVariance:Float = Math.PI;
	
	/**
	   Aligns the particles to their emit angle at birth
	   @default false
	**/
	public var emitAngleAlignedRotation:Bool = false;
	
	/**
	   Rotation offset when emitAngleAlignedRotation is set to true
	   @default	0
	**/
	public var emitAngleAlignedRotationOffset:Float = 0.0;
	
	//public var progressiveBirth(get, set):Bool;
	//private var _progressiveBirth:Bool = false;
	//private function get_progressiveBirth():Bool { return this._progressiveBirth; }
	//private function set_progressiveBirth(value:Bool):Bool
	//{
		//return this._progressiveBirth = value;
	//}
	//
	//private var _progressiveBirthAngleStart:Float;
	//private var _progressiveBirthAngleEnd:Float;
	//private var _progressiveBirthAngleCurrent:Float;
	//private var _progressiveBirthAngleStep:Float;
	//
	//private var _progressiveBirthXCurrent:Float;
	//private var _progressiveBirthXStep:Float;
	//
	//private var _progressiveBirthYCurrent:Float;
	//private var _progressiveBirthYStep:Float;
	
	private var _emissionTime:Float;
	private var _emissionTimePredefined:Float = MathUtils.FLOAT_MAX;
	
	/**
	   @default null
	**/
	public var emitterObject(get, set):ParticleEmitter;
	private var _emitterObject:ParticleEmitter;
	private function get_emitterObject():ParticleEmitter { return this._emitterObject; }
	private function set_emitterObject(value:ParticleEmitter):ParticleEmitter
	{
		this._updateEmitter = value != null;
		return this._emitterObject = value;
	}
	
	/**
	   @default	false
	**/
	public var useDisplayRect:Bool = false;
	
	/**
	   
	**/
	public var displayRect:Rectangle = new Rectangle();
	//##################################################
	//\EMITTER
	//##################################################
	
	//##################################################
	// PARTICLE
	//##################################################
	/**
	   Limits particle life to texture animation duration (including loops)
	   @default false
	**/
	public var useAnimationLifeSpan(get, set):Bool;
	private var _useAnimationLifeSpan:Bool = false;
	private function get_useAnimationLifeSpan():Bool { return this._useAnimationLifeSpan; }
	private function set_useAnimationLifeSpan(value:Bool):Bool
	{
		if (this._useAnimationLifeSpan == value) return value;
		this._useAnimationLifeSpan = value;
		if (this._autoSetEmissionRate) updateEmissionRate();
		return this._useAnimationLifeSpan;
	}
	
	/**
	   @default 1
	**/
	public var lifeSpan(get, set):Float;
	private var _lifeSpan:Float = 1.0;
	private function get_lifeSpan():Float { return this._lifeSpan; }
	private function set_lifeSpan(value:Float):Float
	{
		this._lifeSpan = MathUtils.max(0.01, value);
		this._lifeSpanVariance = MathUtils.min(this._lifeSpan, this._lifeSpanVariance);
		if (this._autoSetEmissionRate) updateEmissionRate();
		return this._lifeSpan;
	}
	
	/**
	   @default 0
	**/
	public var lifeSpanVariance(get, set):Float;
	private var _lifeSpanVariance:Float = 0.0;
	private function get_lifeSpanVariance():Float { return this._lifeSpanVariance; }
	private function set_lifeSpanVariance(value:Float):Float
	{
		return this._lifeSpanVariance = MathUtils.min(this._lifeSpan, value);
	}
	
	private var _useFadeInOut:Bool = false;
	private var _useFadeIn:Bool = false;
	
	/**
	   if > 0 the particle alpha will be interpolated from 0 to starting alpha
	   @default 0
	**/
	public var fadeInTime(get, set):Float;
	private var _fadeInTime:Float = 0.0;
	private function get_fadeInTime():Float { return this._fadeInTime; }
	private function set_fadeInTime(value:Float):Float
	{
		this._useFadeIn = value > 0.0;
		this._useFadeInOut = this._useFadeIn || this._useFadeOut;
		return this._fadeInTime = value;
	}
	
	private var _useFadeOut:Bool = false;
	
	/**
	   if > 0 the particle alpha will be interpolated from current value to end alpha
	   @default 0
	**/
	public var fadeOutTime(get, set):Float;
	private var _fadeOutTime:Float = 0.0;
	private function get_fadeOutTime():Float { return this._fadeOutTime; }
	private function set_fadeOutTime(value:Float):Float
	{
		this._useFadeOut = value > 0.0;
		this._useFadeInOut = this._useFadeIn || this._useFadeOut;
		return this._fadeOutTime = value;
	}
	
	private var _useSizeX:Bool = false;
	private var _useSizeY:Bool = false;
	
	/**
	   sets both sizeXStart and sizeYStart
	**/
	public var sizeStart(get, set):Float;
	private function get_sizeStart():Float { return this._sizeXStart; }
	private function set_sizeStart(value:Float):Float
	{
		return this.sizeXStart = this.sizeYStart = value;
	}
	
	/**
	   sets both sizeXStartVariance and sizeYStartVariance
	**/
	public var sizeStartVariance(get, set):Float;
	private function get_sizeStartVariance():Float { return this._sizeXStartVariance; }
	private function set_sizeStartVariance(value:Float):Float
	{
		return this.sizeXStartVariance = this.sizeYStartVariance = value;
	}
	
	/**
	   @default 20
	**/
	public var sizeXStart(get, set):Float;
	private var _sizeXStart:Float = 20.0;
	private function get_sizeXStart():Float { return this._sizeXStart; }
	private function set_sizeXStart(value:Float):Float
	{
		this._sizeXStart = value;
		checkSizeX();
		return this._sizeXStart;
	}
	
	/**
	   @default 0
	**/
	public var sizeXStartVariance(get, set):Float;
	private var _sizeXStartVariance:Float = 0.0;
	private function get_sizeXStartVariance():Float { return this._sizeXStartVariance; }
	private function set_sizeXStartVariance(value:Float):Float
	{
		this._sizeXStartVariance = value;
		checkSizeX();
		return this._sizeXStartVariance;
	}
	
	/**
	   @default 20
	**/
	public var sizeYStart(get, set):Float;
	private var _sizeYStart:Float = 20.0;
	private function get_sizeYStart():Float { return this._sizeYStart; }
	private function set_sizeYStart(value:Float):Float
	{
		this._sizeYStart = value;
		checkSizeY();
		return this._sizeYStart;
	}
	
	/**
	   @default 0
	**/
	public var sizeYStartVariance(get, set):Float;
	private var _sizeYStartVariance:Float = 0.0;
	private function get_sizeYStartVariance():Float { return this._sizeYStartVariance; }
	private function set_sizeYStartVariance(value:Float):Float
	{
		this._sizeYStartVariance = value;
		checkSizeY();
		return this._sizeYStartVariance;
	}
	
	/**
	   sets both sizeXEnd and sizeYEnd
	**/
	public var sizeEnd(get, set):Float;
	private function get_sizeEnd():Float { return this.sizeXEnd; }
	private function set_sizeEnd(value:Float):Float
	{
		return this.sizeXEnd = this.sizeYEnd = value;
	}
	
	/**
	   sets both sizeXEndVariance and sizeYEndVariance
	**/
	public var sizeEndVariance(get, set):Float;
	private function get_sizeEndVariance():Float { return this.sizeXEndVariance; }
	private function set_sizeEndVariance(value:Float):Float
	{
		return this.sizeXEndVariance = this.sizeYEndVariance = value;
	}
	
	/**
	   @default 20
	**/
	public var sizeXEnd(get, set):Float;
	private var _sizeXEnd:Float = 20.0;
	private function get_sizeXEnd():Float { return this._sizeXEnd; }
	private function set_sizeXEnd(value:Float):Float
	{
		this._sizeXEnd = value;
		checkSizeX();
		return this._sizeXEnd;
	}
	
	/**
	   @default 0
	**/
	public var sizeXEndVariance(get, set):Float;
	private var _sizeXEndVariance:Float = 0.0;
	private function get_sizeXEndVariance():Float { return this._sizeXEndVariance; }
	private function set_sizeXEndVariance(value:Float):Float
	{
		this._sizeXEndVariance = value;
		checkSizeX();
		return this._sizeXEndVariance;
	}
	
	/**
	   @default 20
	**/
	public var sizeYEnd(get, set):Float;
	private var _sizeYEnd:Float = 20.0;
	private function get_sizeYEnd():Float { return this._sizeYEnd; }
	private function set_sizeYEnd(value:Float):Float
	{
		this._sizeYEnd = value;
		checkSizeY();
		return this._sizeYEnd;
	}
	
	/**
	   @default 0
	**/
	public var sizeYEndVariance(get, set):Float;
	private var _sizeYEndVariance:Float = 0.0;
	private function get_sizeYEndVariance():Float { return this._sizeYEndVariance; }
	private function set_sizeYEndVariance(value:Float):Float
	{
		this._sizeYEndVariance = value;
		checkSizeY();
		return this._sizeYEndVariance;
	}
	
	/**
	   @default	false
	**/
	public var sizeXEndRelativeToStart(get, set):Bool;
	private var _sizeXEndRelativeToStart:Bool = false;
	private function get_sizeXEndRelativeToStart():Bool { return this._sizeXEndRelativeToStart; }
	private function set_sizeXEndRelativeToStart(value:Bool):Bool
	{
		this._sizeXEndRelativeToStart = value;
		checkSizeX();
		return this._sizeXEndRelativeToStart;
	}
	
	/**
	   @default	false
	**/
	public var sizeYEndRelativeToStart(get, set):Bool;
	private var _sizeYEndRelativeToStart:Bool = false;
	private function get_sizeYEndRelativeToStart():Bool { return this._sizeYEndRelativeToStart; }
	private function set_sizeYEndRelativeToStart(value:Bool):Bool
	{
		this._sizeYEndRelativeToStart = value;
		checkSizeY();
		return this._sizeYEndRelativeToStart;
	}
	
	private var _useRotation:Bool = false;
	
	/**
	   @default 0
	**/
	public var rotationStart(get, set):Float;
	private var _rotationStart:Float = 0.0;
	private function get_rotationStart():Float { return this._rotationStart; }
	private function set_rotationStart(value:Float):Float
	{
		this._rotationStart = value;
		checkRotation();
		return this._rotationStart;
	}
	
	/**
	   @default 0
	**/
	public var rotationStartVariance(get, set):Float;
	private var _rotationStartVariance:Float = 0.0;
	private function get_rotationStartVariance():Float { return this._rotationStartVariance; }
	private function set_rotationStartVariance(value:Float):Float
	{
		this._rotationStartVariance = value;
		checkRotation();
		return this._rotationStartVariance;
	}
	
	/**
	   @default 0
	**/
	public var rotationEnd(get, set):Float;
	private var _rotationEnd:Float = 0.0;
	private function get_rotationEnd():Float { return this._rotationEnd; }
	private function set_rotationEnd(value:Float):Float
	{
		this._rotationEnd = value;
		checkRotation();
		return this._rotationEnd;
	}
	
	/**
	   @default 0
	**/
	public var rotationEndVariance(get, set):Float;
	private var _rotationEndVariance:Float = 0.0;
	private function get_rotationEndVariance():Float { return this._rotationEndVariance; }
	private function set_rotationEndVariance(value:Float):Float
	{
		this._rotationEndVariance = value;
		checkRotation();
		return this._rotationEndVariance;
	}
	
	/**
	   @default	false
	**/
	public var rotationEndRelativeToStart(get, set):Bool;
	private var _rotationEndRelativeToStart:Bool = false;
	private function get_rotationEndRelativeToStart():Bool { return this._rotationEndRelativeToStart; }
	private function set_rotationEndRelativeToStart(value:Bool):Bool
	{
		this._rotationEndRelativeToStart = value;
		checkRotation();
		return this._rotationEndRelativeToStart;
	}
	
	private var _hasSkewX:Bool = false;
	private var _hasSkewY:Bool = false;
	private var _useSkewX:Bool = false;
	private var _useSkewY:Bool = false;
	
	/**
	   @default	0
	**/
	public var skewXStart(get, set):Float;
	private var _skewXStart:Float = 0.0;
	private function get_skewXStart():Float { return this._skewXStart; }
	private function set_skewXStart(value:Float):Float
	{
		this._skewXStart = value;
		checkSkewX();
		return this._skewXStart;
	}
	
	/**
	   @default	0
	**/
	public var skewXStartVariance(get, set):Float;
	private var _skewXStartVariance:Float = 0.0;
	private function get_skewXStartVariance():Float { return this._skewXStartVariance; }
	private function set_skewXStartVariance(value:Float):Float
	{
		this._skewXStartVariance = value;
		checkSkewX();
		return this._skewXStartVariance;
	}
	
	/**
	   @default	0
	**/
	public var skewYStart(get, set):Float;
	private var _skewYStart:Float = 0.0;
	private function get_skewYStart():Float { return this._skewYStart; }
	private function set_skewYStart(value:Float):Float
	{
		this._skewYStart = value;
		checkSkewY();
		return this._skewYStart;
	}
	
	/**
	   @default	0
	**/
	public var skewYStartVariance(get, set):Float;
	private var _skewYStartVariance:Float = 0.0;
	private function get_skewYStartVariance():Float { return this._skewYStartVariance; }
	private function set_skewYStartVariance(value:Float):Float
	{
		this._skewYStartVariance = value;
		checkSkewY();
		return this._skewYStartVariance;
	}
	
	/**
	   @default	0
	**/
	public var skewXEnd(get, set):Float;
	private var _skewXEnd:Float = 0.0;
	private function get_skewXEnd():Float { return this._skewXEnd; }
	private function set_skewXEnd(value:Float):Float
	{
		this._skewXEnd = value;
		checkSkewX();
		return this._skewXEnd;
	}
	
	/**
	   @default	0
	**/
	public var skewXEndVariance(get, set):Float;
	private var _skewXEndVariance:Float = 0.0;
	private function get_skewXEndVariance():Float { return this._skewXEndVariance; }
	private function set_skewXEndVariance(value:Float):Float
	{
		this._skewXEndVariance = value;
		checkSkewX();
		return this._skewXEndVariance;
	}
	
	/**
	   @default	0
	**/
	public var skewYEnd(get, set):Float;
	private var _skewYEnd:Float = 0.0;
	private function get_skewYEnd():Float { return this._skewYEnd; }
	private function set_skewYEnd(value:Float):Float
	{
		this._skewYEnd = value;
		checkSkewY();
		return this._skewYEnd;
	}
	
	/**
	   @default	0
	**/
	public var skewYEndVariance(get, set):Float;
	private var _skewYEndVariance:Float = 0.0;
	private function get_skewYEndVariance():Float { return this._skewYEndVariance; }
	private function set_skewYEndVariance(value:Float):Float
	{
		this._skewYEndVariance = value;
		checkSkewY();
		return this._skewYEndVariance;
	}
	
	/**
	   @default	false
	**/
	public var skewXEndRelativeToStart(get, set):Bool;
	private var _skewXEndRelativeToStart:Bool = false;
	private function get_skewXEndRelativeToStart():Bool { return this._skewXEndRelativeToStart; }
	private function set_skewXEndRelativeToStart(value:Bool):Bool
	{
		this._skewXEndRelativeToStart = value;
		checkSkewX();
		return this._skewXEndRelativeToStart;
	}
	
	/**
	   @default	false
	**/
	public var skewYEndRelativeToStart(get, set):Bool;
	private var _skewYEndRelativeToStart:Bool = false;
	private function get_skewYEndRelativeToStart():Bool { return this._skewYEndRelativeToStart; }
	private function set_skewYEndRelativeToStart(value:Bool):Bool
	{
		this._skewYEndRelativeToStart = value;
		checkSkewY();
		return this._skewYEndRelativeToStart;
	}
	//##################################################
	//\PARTICLE
	//##################################################
	
	//##################################################
	// VELOCITY
	//##################################################
	private var _useVelocityInheritanceX:Bool = false;
	private var _useVelocityInheritanceY:Bool = false;
	
	/**
	   @default 0
	**/
	public var velocityXInheritRatio(get, set):Float;
	private var _velocityXInheritRatio:Float = 0.0;
	private function get_velocityXInheritRatio():Float { return this._velocityXInheritRatio; }
	private function set_velocityXInheritRatio(value:Float):Float
	{
		this._velocityXInheritRatio = value;
		this._useVelocityInheritanceX = this._velocityXInheritRatio != 0.0 || this._velocityXInheritRatioVariance != 0.0;
		return this._velocityXInheritRatio;
	}
	
	/**
	   @default 0
	**/
	public var velocityXInheritRatioVariance(get, set):Float;
	private var _velocityXInheritRatioVariance:Float = 0.0;
	private function get_velocityXInheritRatioVariance():Float { return this._velocityXInheritRatioVariance; }
	private function set_velocityXInheritRatioVariance(value:Float):Float
	{
		this._velocityXInheritRatioVariance = value;
		this._useVelocityInheritanceX = this._velocityXInheritRatio != 0.0 || this._velocityXInheritRatioVariance != 0.0;
		return this._velocityXInheritRatioVariance;
	}
	
	/**
	   @default 0
	**/
	public var velocityYInheritRatio(get, set):Float;
	private var _velocityYInheritRatio:Float = 0.0;
	private function get_velocityYInheritRatio():Float { return this._velocityYInheritRatio; }
	private function set_velocityYInheritRatio(value:Float):Float
	{
		this._velocityYInheritRatio = value;
		this._useVelocityInheritanceY = this._velocityYInheritRatio != 0.0 || this._velocityYInheritRatioVariance != 0.0;
		return this._velocityYInheritRatio;
	}
	
	/**
	   @default 0
	**/
	public var velocityYInheritRatioVariance(get, set):Float;
	private var _velocityYInheritRatioVariance:Float = 0.0;
	private function get_velocityYInheritRatioVariance():Float { return this._velocityYInheritRatioVariance; }
	private function set_velocityYInheritRatioVariance(value:Float):Float
	{
		this._velocityYInheritRatioVariance = value;
		this._useVelocityInheritanceY = this._velocityYInheritRatio != 0.0 || this._velocityYInheritRatioVariance != 0.0;
		return this._velocityYInheritRatioVariance;
	}
	
	/**
	   @default 0
	**/
	public var velocityX:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var velocityY:Float = 0.0;
	
	/**
	   @default false
	**/
	public var linkRotationToVelocity:Bool = false;
	
	/**
	   @default 0
	**/
	public var velocityRotationOffset:Float = 0.0;
	
	private var _useVelocityRotation:Bool = false;
	
	/**
	   @default	0
	**/
	public var velocityRotationFactor(get, set):Float;
	private var _velocityRotationFactor:Float = 0.0;
	private function get_velocityRotationFactor():Float { return this._velocityRotationFactor; }
	private function set_velocityRotationFactor(value:Float):Float
	{
		this._useVelocityRotation = value != 0.0;
		checkAnyVelocityEffect();
		return this._velocityRotationFactor = value;
	}
	
	private var _useVelocityScale:Bool = false;
	private var _useVelocityScaleX:Bool = false;
	private var _useVelocityScaleY:Bool = false;
	
	/**
	   @default 0
	**/
	public var velocityScaleFactorX(get, set):Float;
	private var _velocityScaleFactorX:Float = 0.0;
	private function get_velocityScaleFactorX():Float { return this._velocityScaleFactorX; }
	private function set_velocityScaleFactorX(value:Float):Float
	{
		this._useVelocityScaleX = value != 0.0;
		this._useVelocityScale = this._useVelocityScaleX || this._useVelocityScaleY;
		checkAnyVelocityEffect();
		return this._velocityScaleFactorX = value;
	}
	
	/**
	   @default 0
	**/
	public var velocityScaleFactorY(get, set):Float;
	private var _velocityScaleFactorY:Float = 0.0;
	private function get_velocityScaleFactorY():Float { return this._velocityScaleFactorY; }
	private function set_velocityScaleFactorY(value:Float):Float
	{
		this._useVelocityScaleY = value != 0.0;
		this._useVelocityScale = this._useVelocityScaleX || this._useVelocityScaleY;
		checkAnyVelocityEffect();
		return this._velocityScaleFactorY = value;
	}
	
	private var _useVelocitySkew:Bool = false;
	private var _useVelocitySkewX:Bool = false;
	private var _useVelocitySkewY:Bool = false;
	
	/**
	   @default	0
	**/
	public var velocitySkewFactorX(get, set):Float;
	private var _velocitySkewFactorX:Float = 0.0;
	private function get_velocitySkewFactorX():Float { return this._velocitySkewFactorX; }
	private function set_velocitySkewFactorX(value:Float):Float
	{
		this._useVelocitySkewX = value != 0.0;
		this._useVelocitySkew = this._useVelocitySkewX || this._useVelocitySkewY;
		checkAnyVelocityEffect();
		return this._velocitySkewFactorX = value;
	}
	
	/**
	   @default	0
	**/
	public var velocitySkewFactorY(get, set):Float;
	private var _velocitySkewFactorY:Float = 0.0;
	private function get_velocitySkewFactorY():Float { return this._velocitySkewFactorY; }
	private function set_velocitySkewFactorY(value:Float):Float
	{
		this._useVelocitySkewY = value != 0.0;
		this._useVelocitySkew = this._useVelocitySkewX || this._useVelocitySkewY;
		checkAnyVelocityEffect();
		return this._velocitySkewFactorY = value;
	}
	//##################################################
	//\VELOCITY
	//##################################################
	
	//##################################################
	// ANIMATION
	//##################################################
	/**
	   
	   @default	1.0
	**/
	public var frameDelta(get, set):Float;
	private var _frameDelta:Float = 1.0;
	private function get_frameDelta():Float { return this._frameDelta; }
	private function set_frameDelta(value:Float):Float
	{
		if (this._frameDelta == value) return value;
		this._frameDelta = value;
		if (this._useAnimationLifeSpan) updateEmissionRate();
		return this._frameDelta;
	}
	
	/**
	   @default	0.0
	**/
	public var frameDeltaVariance:Float = 0.0;
	
	/**
	   Tells whether texture animation should loop or not
	   @default false
	**/
	public var loopAnimation(get, set):Bool;
	private var _loopAnimation:Bool = false;
	private function get_loopAnimation():Bool { return this._loopAnimation; }
	private function set_loopAnimation(value:Bool):Bool
	{
		if (this._loopAnimation == value) return value;
		
		var count:Int = this._particles.length;
		for (i in 0...count)
		{
			this._particles[i].loop = value;
		}
		return this._loopAnimation = value;
	}
	
	/**
	   Number of loops if loopAnimation is true, 0 = infinite
	   @default 0
	**/
	public var animationLoops(get, set):Int;
	private var _animationLoops:Int = 0;
	private function get_animationLoops():Int { return this._animationLoops; }
	private function set_animationLoops(value:Int):Int
	{
		if (this._animationLoops == value) return value;
		
		var count:Int = this._particles.length;
		for (i in 0...count)
		{
			this._particles[i].numLoops = this._animationLoops;
		}
		return this._animationLoops = value;
	}
	
	/**
	   Tells  whether the initial frame should be chosen randomly
	   @default false
	**/
	public var randomStartFrame:Bool = false;
	//##################################################
	//\ANIMATION
	//##################################################
	
	//##################################################
	// GRAVITY
	//##################################################
	/**
	   Particle speed (pixels per second)
	   @default 100
	**/
	public var speed:Float = 100.0;
	
	/**
	   @default 0
	**/
	public var speedVariance:Float = 0.0;
	
	/**
	   @default false
	**/
	public var adjustLifeSpanToSpeed:Bool = false;
	
	private var _useGravity:Bool = false;
	
	/**
	   @default 0
	**/
	public var gravityX(get, set):Float;
	private var _gravityX:Float = 0.0;
	private function get_gravityX():Float { return this._gravityX; }
	private function set_gravityX(value:Float):Float
	{
		this._gravityX = value;
		this._useGravity = this._gravityX != 0.0 || this._gravityY != 0.0;
		return this._gravityX;
	}
	
	/**
	   @default 0
	**/
	public var gravityY(get, set):Float;
	private var _gravityY:Float = 0.0;
	private function get_gravityY():Float { return this._gravityY; }
	private function set_gravityY(value:Float):Float
	{
		this._gravityY = value;
		this._useGravity = this._gravityX != 0.0 || this._gravityY != 0.0;
		return this._gravityY;
	}
	
	private var _useRadialAcceleration:Bool = false;
	
	/**
	   @default 0
	**/
	public var radialAcceleration(get, set):Float;
	private var _radialAcceleration:Float = 0.0;
	private function get_radialAcceleration():Float { return this._radialAcceleration; }
	private function set_radialAcceleration(value:Float):Float
	{
		this._radialAcceleration = value;
		this._useRadialAcceleration = this._radialAcceleration != 0.0 || this._radialAccelerationVariance != 0.0;
		return this._radialAcceleration;
	}
	
	/**
	   @default 0
	**/
	public var radialAccelerationVariance(get, set):Float;
	private var _radialAccelerationVariance:Float = 0.0;
	private function get_radialAccelerationVariance():Float { return this._radialAccelerationVariance; }
	private function set_radialAccelerationVariance(value:Float):Float
	{
		this._radialAccelerationVariance = value;
		this._useRadialAcceleration = this._radialAcceleration != 0.0 || this._radialAccelerationVariance != 0.0;
		return this._radialAccelerationVariance;
	}
	
	private var _useTangentialAcceleration:Bool = false;
	
	/**
	   @default 0
	**/
	public var tangentialAcceleration(get, set):Float;
	private var _tangentialAcceleration:Float = 0.0;
	private function get_tangentialAcceleration():Float { return this._tangentialAcceleration; }
	private function set_tangentialAcceleration(value:Float):Float
	{
		this._tangentialAcceleration = value;
		this._useTangentialAcceleration = this._tangentialAcceleration != 0.0 || this._tangentialAccelerationVariance != 0.0;
		return this._tangentialAcceleration;
	}
	
	/**
	   @default 0
	**/
	public var tangentialAccelerationVariance(get, set):Float;
	private var _tangentialAccelerationVariance:Float = 0.0;
	private function get_tangentialAccelerationVariance():Float { return this._tangentialAccelerationVariance; }
	private function set_tangentialAccelerationVariance(value:Float):Float
	{
		this._tangentialAccelerationVariance = value;
		this._useTangentialAcceleration = this._tangentialAcceleration != 0.0 || this._tangentialAccelerationVariance != 0.0;
		return this._tangentialAccelerationVariance;
	}
	
	private var _useDrag:Bool = false;
	
	/**
	   @default 0
	**/
	public var drag(get, set):Float;
	private var _drag:Float = 0.0;
	private function get_drag():Float { return this._drag; }
	private function set_drag(value:Float):Float
	{
		this._useDrag = value != 0.0 || this._dragVariance != 0.0;
		return this._drag = value;
	}
	
	/**
	   @default 0
	**/
	public var dragVariance(get, set):Float;
	private var _dragVariance:Float = 0.0;
	private function get_dragVariance():Float { return this._dragVariance; }
	private function set_dragVariance(value:Float):Float
	{
		this._useDrag = this._drag != 0.0 || value != 0.0;
		return this._dragVariance = value;
	}
	
	private var _useRepellentForce:Bool = false;
	
	/**
	   @default 0
	**/
	public var repellentForce(get, set):Float;
	private var _repellentForce:Float = 0.0;
	private function get_repellentForce():Float { return this._repellentForce; }
	private function set_repellentForce(value:Float):Float
	{
		this._useRepellentForce = value != 0.0;
		return this._repellentForce = value;
	}
	//##################################################
	//\GRAVITY
	//##################################################
	
	//##################################################
	// RADIAL
	//##################################################
	/**
	   @default 50
	**/
	public var radiusMax:Float = 50.0;
	
	/**
	   @default 0
	**/
	public var radiusMaxVariance:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var radiusMin:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var radiusMinVariance:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var rotatePerSecond:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var rotatePerSecondVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var alignRadialRotation:Bool = false;
	
	/**
	   @default	0
	**/
	public var alignRadialRotationOffset:Float = 0.0;
	
	/**
	   @default	0
	**/
	public var alignRadialRotationOffsetVariance:Float = 0.0;
	//##################################################
	//\RADIAL
	//##################################################
	
	//##################################################
	// COLOR
	//##################################################
	private var _hasColorStartVariance:Bool = false;
	private var _hasColorEndVariance:Bool = false;
	private var _useColor:Bool = false;
	
	/**
	   
	**/
	public var colorStart(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorStartVariance(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorEnd(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorEndVariance(default, null):MassiveTint;
	
	/**
	   @default	false
	**/
	public var colorEndRelativeToStart(get, set):Bool;
	private var _colorEndRelativeToStart:Bool = false;
	private function get_colorEndRelativeToStart():Bool { return this._colorEndRelativeToStart; }
	private function set_colorEndRelativeToStart(value:Bool):Bool
	{
		if (this._colorEndRelativeToStart == value) return value;
		this._colorEndRelativeToStart = value;
		checkColor();
		return this._colorEndRelativeToStart;
	}
	
	/**
	   @default	false
	**/
	public var colorEndIsMultiplier(get, set):Bool;
	private var _colorEndIsMultiplier:Bool = false;
	private function get_colorEndIsMultiplier():Bool { return this._colorEndIsMultiplier; }
	private function set_colorEndIsMultiplier(value:Bool):Bool
	{
		if (this._colorEndIsMultiplier == value) return value;
		this._colorEndIsMultiplier = value;
		checkColor();
		return this._colorEndIsMultiplier;
	}
	//##################################################
	//\COLOR
	//##################################################
	
	//##################################################
	// COLOR OFFSET
	//##################################################
	private var _hasColorOffset:Bool = false;
	private var _hasColorOffsetStartVariance:Bool = false;
	private var _hasColorOffsetEndVariance:Bool = false;
	private var _useColorOffset:Bool = false;
	
	/**
	   
	**/
	public var colorOffsetStart(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorOffsetStartVariance(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorOffsetEnd(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorOffsetEndVariance(default, null):MassiveTint;
	
	/**
	   @default	false
	**/
	public var colorOffsetEndRelativeToStart(get, set):Bool;
	private var _colorOffsetEndRelativeToStart:Bool = false;
	private function get_colorOffsetEndRelativeToStart():Bool { return this._colorOffsetEndRelativeToStart; }
	private function set_colorOffsetEndRelativeToStart(value:Bool):Bool
	{
		if (this._colorOffsetEndRelativeToStart == value) return value;
		this._colorOffsetEndRelativeToStart = value;
		checkColorOffset();
		return this._colorOffsetEndRelativeToStart = value;
	}
	
	public var colorOffsetEndIsMultiplier(get, set):Bool;
	private var _colorOffsetEndIsMultiplier:Bool = false;
	private function get_colorOffsetEndIsMultiplier():Bool { return this._colorOffsetEndIsMultiplier; }
	private function set_colorOffsetEndIsMultiplier(value:Bool):Bool
	{
		if (this._colorOffsetEndIsMultiplier == value) return value;
		this._colorOffsetEndIsMultiplier = value;
		checkColorOffset();
		return this._colorOffsetEndIsMultiplier;
	}
	//##################################################
	//\COLOR OFFSET
	//##################################################
	
	//##################################################
	// OSCILLATION
	//##################################################
	private var _useOscillationGlobalFrequency:Bool = false;
	private var _useOscillationUnifiedFrequencyVariance:Bool = false;
	//private var _useOscillationUnifiedIncrementalFrequencyStart:Bool = false;
	private var _useOscillationUnifiedRandomFrequencyStart:Bool = false;
	private var _oscillationGlobalStep:Float;
	private var _oscillationGlobalValue:Float;
	private var _oscillationGlobalValueInverted:Float;
	
	/**
	   @default	1
	**/
	public var oscillationGlobalFrequency:Float = 1.0;
	
	/**
	   @default 0
	**/
	public var oscillationUnifiedFrequencyVariance:Float = 0.0;
	
	// oscillation position
	private var _positionOscillationEnabled:Bool = false;
	private var _positionOscillationGroupStep:Float;
	private var _positionOscillationGroupValue:Float;
	private var _positionOscillationGlobalFrequencyEnabled:Bool = false;
	private var _positionOscillationGroupFrequencyEnabled:Bool = false;
	private var _positionOscillationFrequencyStartRandom:Bool = false;
	private var _positionOscillationFrequencyStartUnifiedRandom:Bool = false;
	private var _positionOscillationAngleRelativeToRotation:Bool = true;
	private var _positionOscillationAngleRelativeToVelocity:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var positionOscillationFrequencyMode(get, set):String;
	private var _positionOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_positionOscillationFrequencyMode():String { return this._positionOscillationFrequencyMode; }
	private function set_positionOscillationFrequencyMode(value:String):String
	{
		if (this._positionOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._positionOscillationGlobalFrequencyEnabled = true;
				this._positionOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._positionOscillationGlobalFrequencyEnabled = false;
				this._positionOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._positionOscillationGlobalFrequencyEnabled = false;
				this._positionOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._positionOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var positionOscillationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var positionOscillationAngle:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var positionOscillationAngleVariance:Float = 0.0;
	
	/**
	   see AngleRelativeTo for possible values
	   @default	AngleRelativeTo.ROTATION
	**/
	public var positionOscillationAngleRelativeTo(get, set):String;
	private var _positionOscillationAngleRelativeTo:String = AngleRelativeTo.ROTATION;
	private function get_positionOscillationAngleRelativeTo():String { return this._positionOscillationAngleRelativeTo; }
	private function set_positionOscillationAngleRelativeTo(value:String):String
	{
		if (this._positionOscillationAngleRelativeTo == value) return value;
		
		switch (value)
		{
			case AngleRelativeTo.ABSOLUTE :
				this._positionOscillationAngleRelativeToRotation = false;
				this._positionOscillationAngleRelativeToVelocity = false;
			
			case AngleRelativeTo.ROTATION :
				this._positionOscillationAngleRelativeToRotation = true;
				this._positionOscillationAngleRelativeToVelocity = false;
			
			case AngleRelativeTo.VELOCITY :
				this._positionOscillationAngleRelativeToRotation = false;
				this._positionOscillationAngleRelativeToVelocity = true;
			
			default :
				throw new Error("unknown AngleRelativeTo ::: " + value);
		}
		
		return this._positionOscillationAngleRelativeTo = value;
	}
	
	/**
	   @default 0
	**/
	public var positionOscillationRadius(get, set):Float;
	private var _positionOscillationRadius:Float = 0.0;
	private function get_positionOscillationRadius():Float { return this._positionOscillationRadius; }
	private function set_positionOscillationRadius(value:Float):Float
	{
		this._positionOscillationEnabled = value != 0.0 || this._positionOscillationRadiusVariance != 0.0;
		return this._positionOscillationRadius = value;
	}
	
	/**
	   @default 0
	**/
	public var positionOscillationRadiusVariance(get, set):Float;
	private var _positionOscillationRadiusVariance:Float = 0.0;
	private function get_positionOscillationRadiusVariance():Float { return this._positionOscillationRadiusVariance; }
	private function set_positionOscillationRadiusVariance(value:Float):Float
	{
		this._positionOscillationEnabled = value != 0.0 || this._positionOscillationRadius != 0.0;
		return this._positionOscillationRadiusVariance = value;
	}
	
	/**
	   @default 0
	**/
	public var positionOscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var positionOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _positionOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_positionOscillationUnifiedFrequencyVariance():Bool { return this._positionOscillationUnifiedFrequencyVariance; }
	private function set_positionOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._positionOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._positionOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var positionOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationPositionFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var positionOscillationFrequencyStart(get, set):String;
	private var _positionOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_positionOscillationFrequencyStart():String { return this._positionOscillationFrequencyStart; }
	private function set_positionOscillationFrequencyStart(value:String):String
	{
		if (this._positionOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._positionOscillationFrequencyStartRandom = false;
				this._positionOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._positionOscillationFrequencyStartRandom = true;
				this._positionOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._positionOscillationFrequencyStartRandom = false;
				this._positionOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._positionOscillationFrequencyStart = value;
	}
	
	// oscillation position 2
	private var _position2OscillationEnabled:Bool = false;
	private var _position2OscillationGroupStep:Float;
	private var _position2OscillationGroupValue:Float;
	private var _position2OscillationGlobalFrequencyEnabled:Bool = false;
	private var _position2OscillationGroupFrequencyEnabled:Bool = false;
	private var _position2OscillationFrequencyStartRandom:Bool = false;
	private var _position2OscillationFrequencyStartUnifiedRandom:Bool = false;
	private var _position2OscillationAngleRelativeToRotation:Bool = true;
	private var _position2OscillationAngleRelativeToVelocity:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var position2OscillationFrequencyMode(get, set):String;
	private var _position2OscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_position2OscillationFrequencyMode():String { return this._position2OscillationFrequencyMode; }
	private function set_position2OscillationFrequencyMode(value:String):String
	{
		if (this._position2OscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._position2OscillationGlobalFrequencyEnabled = true;
				this._position2OscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._position2OscillationGlobalFrequencyEnabled = false;
				this._position2OscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._position2OscillationGlobalFrequencyEnabled = false;
				this._position2OscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._position2OscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var position2OscillationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var position2OscillationAngle:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var position2OscillationAngleVariance:Float = 0.0;
	
	/**
	   see AngleRelativeTo for possible values
	   @default	AngleRelativeTo.ROTATION
	**/
	public var position2OscillationAngleRelativeTo(get, set):String;
	private var _position2OscillationAngleRelativeTo:String = AngleRelativeTo.ROTATION;
	private function get_position2OscillationAngleRelativeTo():String { return this._position2OscillationAngleRelativeTo; }
	private function set_position2OscillationAngleRelativeTo(value:String):String
	{
		if (this._positionOscillationAngleRelativeTo == value) return value;
		
		switch (value)
		{
			case AngleRelativeTo.ABSOLUTE :
				this._position2OscillationAngleRelativeToRotation = false;
				this._position2OscillationAngleRelativeToVelocity = false;
			
			case AngleRelativeTo.ROTATION :
				this._position2OscillationAngleRelativeToRotation = true;
				this._position2OscillationAngleRelativeToVelocity = false;
			
			case AngleRelativeTo.VELOCITY :
				this._position2OscillationAngleRelativeToRotation = false;
				this._position2OscillationAngleRelativeToVelocity = true;
			
			default :
				throw new Error("unknown AngleRelativeTo ::: " + value);
		}
		
		return this._position2OscillationAngleRelativeTo = value;
	}
	
	/**
	   @default 0
	**/
	public var position2OscillationRadius(get, set):Float;
	private var _position2OscillationRadius:Float = 0.0;
	private function get_position2OscillationRadius():Float { return this._position2OscillationRadius; }
	private function set_position2OscillationRadius(value:Float):Float
	{
		this._position2OscillationEnabled = value != 0.0 || this._position2OscillationRadiusVariance != 0.0;
		return this._position2OscillationRadius = value;
	}
	
	/**
	   @default 0
	**/
	public var position2OscillationRadiusVariance(get, set):Float;
	private var _position2OscillationRadiusVariance:Float = 0.0;
	private function get_position2OscillationRadiusVariance():Float { return this._position2OscillationRadiusVariance; }
	private function set_position2OscillationRadiusVariance(value:Float):Float
	{
		this._position2OscillationEnabled = value != 0.0 || this._position2OscillationRadius != 0.0;
		return this._position2OscillationRadiusVariance = value;
	}
	
	/**
	   @default 1.0
	**/
	public var position2OscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var position2OscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _position2OscillationUnifiedFrequencyVariance:Bool = false;
	private function get_position2OscillationUnifiedFrequencyVariance():Bool { return this._position2OscillationUnifiedFrequencyVariance; }
	private function set_position2OscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._position2OscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._position2OscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var position2OscillationFrequencyVariance:Float = 0.0;
	
	/**
	   
	**/
	public var position2OscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var position2OscillationFrequencyStart(get, set):String;
	private var _position2OscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_position2OscillationFrequencyStart():String { return this._position2OscillationFrequencyStart; }
	private function set_position2OscillationFrequencyStart(value:String):String
	{
		if (this._position2OscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._position2OscillationFrequencyStartRandom = false;
				this._position2OscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._position2OscillationFrequencyStartRandom = true;
				this._position2OscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._position2OscillationFrequencyStartRandom = false;
				this._position2OscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._position2OscillationFrequencyStart = value;
	}
	
	// oscillation rotation
	private var _rotationOscillationEnabled:Bool = false;
	private var _rotationOscillationGroupStep:Float;
	private var _rotationOscillationGroupValue:Float;
	private var _rotationOscillationGlobalFrequencyEnabled:Bool = false;
	private var _rotationOscillationGroupFrequencyEnabled:Bool = false;
	private var _rotationOscillationFrequencyStartRandom:Bool = false;
	private var _rotationOscillationFrequencyStartUnifiedRandom:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var rotationOscillationFrequencyMode(get, set):String;
	private var _rotationOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_rotationOscillationFrequencyMode():String { return this._rotationOscillationFrequencyMode; }
	private function set_rotationOscillationFrequencyMode(value:String):String
	{
		if (this._rotationOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._rotationOscillationGlobalFrequencyEnabled = true;
				this._rotationOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._rotationOscillationGlobalFrequencyEnabled = false;
				this._rotationOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._rotationOscillationGlobalFrequencyEnabled = false;
				this._rotationOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._rotationOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var rotationOscillationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var rotationOscillationAngle(get, set):Float;
	private var _rotationOscillationAngle:Float = 0.0;
	private function get_rotationOscillationAngle():Float { return this._rotationOscillationAngle; }
	private function set_rotationOscillationAngle(value:Float):Float
	{
		this._rotationOscillationEnabled = value != 0.0 || this._rotationOscillationAngleVariance != 0.0;
		return this._rotationOscillationAngle = value;
	}
	
	/**
	   @default 0
	**/
	public var rotationOscillationAngleVariance(get, set):Float;
	private var _rotationOscillationAngleVariance:Float = 0.0;
	private function get_rotationOscillationAngleVariance():Float { return this._rotationOscillationAngleVariance; }
	private function set_rotationOscillationAngleVariance(value:Float):Float
	{
		this._rotationOscillationEnabled = value != 0.0 || this._rotationOscillationAngle != 0.0;
		return this._rotationOscillationAngleVariance = value;
	}
	
	/**
	   @default	1
	**/
	public var rotationOscillationFrequency:Float = 1.0;
	
	/**
	   @default false
	**/
	public var rotationOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _rotationOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_rotationOscillationUnifiedFrequencyVariance():Bool { return this._rotationOscillationUnifiedFrequencyVariance; }
	private function set_rotationOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._rotationOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._rotationOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var rotationOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var rotationOscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var rotationOscillationFrequencyStart(get, set):String;
	private var _rotationOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_rotationOscillationFrequencyStart():String { return this._rotationOscillationFrequencyStart; }
	private function set_rotationOscillationFrequencyStart(value:String):String
	{
		if (this._rotationOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._rotationOscillationFrequencyStartRandom = false;
				this._rotationOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._rotationOscillationFrequencyStartRandom = true;
				this._rotationOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._rotationOscillationFrequencyStartRandom = false;
				this._rotationOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._rotationOscillationFrequencyStart = value;
	}
	
	// oscillation scaleX
	private var _scaleXOscillationEnabled:Bool = false;
	private var _scaleXOscillationGroupStep:Float;
	private var _scaleXOscillationGroupValue:Float;
	private var _scaleXOscillationGlobalFrequencyEnabled:Bool = false;
	private var _scaleXOscillationGroupFrequencyEnabled:Bool = false;
	private var _scaleXOscillationFrequencyStartRandom:Bool = false;
	private var _scaleXOscillationFrequencyStartUnifiedRandom:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var scaleXOscillationFrequencyMode(get, set):String;
	private var _scaleXOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_scaleXOscillationFrequencyMode():String { return this._scaleXOscillationFrequencyMode; }
	private function set_scaleXOscillationFrequencyMode(value:String):String
	{
		if (this._scaleXOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._scaleXOscillationGlobalFrequencyEnabled = true;
				this._scaleXOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._scaleXOscillationGlobalFrequencyEnabled = false;
				this._scaleXOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._scaleXOscillationGlobalFrequencyEnabled = false;
				this._scaleXOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._scaleXOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var scaleXOscillationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var scaleXOscillation(get, set):Float;
	private var _scaleXOscillation:Float = 0.0;
	private function get_scaleXOscillation():Float { return this._scaleXOscillation; }
	private function set_scaleXOscillation(value:Float):Float
	{
		this._scaleXOscillation = value;
		this._scaleXOscillationEnabled = this._scaleXOscillation != 0.0 || this._scaleXOscillationVariance != 0.0;
		return this._scaleXOscillation;
	}
	
	/**
	   @default 0
	**/
	public var scaleXOscillationVariance(get, set):Float;
	private var _scaleXOscillationVariance:Float = 0.0;
	private function get_scaleXOscillationVariance():Float { return this._scaleXOscillationVariance; }
	private function set_scaleXOscillationVariance(value:Float):Float
	{
		this._scaleXOscillationVariance = value;
		this._scaleXOscillationEnabled = this._scaleXOscillation != 0.0 || this._scaleXOscillationVariance != 0.0;
		return this._scaleXOscillationVariance;
	}
	
	/**
	   @default 1
	**/
	public var scaleXOscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var scaleXOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _scaleXOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_scaleXOscillationUnifiedFrequencyVariance():Bool { return this._scaleXOscillationUnifiedFrequencyVariance; }
	private function set_scaleXOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._scaleXOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._scaleXOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var scaleXOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var scaleXOscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var scaleXOscillationFrequencyStart(get, set):String;
	private var _scaleXOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_scaleXOscillationFrequencyStart():String { return this._scaleXOscillationFrequencyStart; }
	private function set_scaleXOscillationFrequencyStart(value:String):String
	{
		if (this._scaleXOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._scaleXOscillationFrequencyStartRandom = false;
				this._scaleXOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._scaleXOscillationFrequencyStartRandom = true;
				this._scaleXOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._scaleXOscillationFrequencyStartRandom = false;
				this._scaleXOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._scaleXOscillationFrequencyStart = value;
	}
	
	// oscillation scaleY
	private var _scaleYOscillationEnabled:Bool = false;
	private var _scaleYOscillationGroupStep:Float;
	private var _scaleYOscillationGroupValue:Float;
	private var _scaleYOscillationGlobalFrequencyEnabled:Bool = false;
	private var _scaleYOscillationGroupFrequencyEnabled:Bool = false;
	private var _scaleYOscillationFrequencyStartRandom:Bool = false;
	private var _scaleYOscillationFrequencyStartUnifiedRandom:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var scaleYOscillationFrequencyMode(get, set):String;
	private var _scaleYOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_scaleYOscillationFrequencyMode():String { return this._scaleYOscillationFrequencyMode; }
	private function set_scaleYOscillationFrequencyMode(value:String):String
	{
		if (this._scaleYOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._scaleYOscillationGlobalFrequencyEnabled = true;
				this._scaleYOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._scaleYOscillationGlobalFrequencyEnabled = false;
				this._scaleYOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._scaleYOscillationGlobalFrequencyEnabled = false;
				this._scaleYOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._scaleYOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var scaleYOscillationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var scaleYOscillation(get, set):Float;
	private var _scaleYOscillation:Float = 0.0;
	private function get_scaleYOscillation():Float { return this._scaleYOscillation; }
	private function set_scaleYOscillation(value:Float):Float
	{
		this._scaleYOscillation = value;
		this._scaleYOscillationEnabled = this._scaleYOscillation != 0.0 || this._scaleYOscillationVariance != 0.0;
		return this._scaleYOscillation;
	}
	
	/**
	   @default 0
	**/
	public var scaleYOscillationVariance(get, set):Float;
	private var _scaleYOscillationVariance:Float = 0.0;
	private function get_scaleYOscillationVariance():Float { return this._scaleYOscillationVariance; }
	private function set_scaleYOscillationVariance(value:Float):Float
	{
		this._scaleYOscillationVariance = value;
		this._scaleYOscillationEnabled = this._scaleYOscillation != 0.0 || this._scaleYOscillationVariance != 0.0;
		return this._scaleYOscillationVariance;
	}
	
	/**
	   @default 1
	**/
	public var scaleYOscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var scaleYOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _scaleYOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_scaleYOscillationUnifiedFrequencyVariance():Bool { return this._scaleYOscillationUnifiedFrequencyVariance; }
	private function set_scaleYOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._scaleYOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._scaleYOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var scaleYOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var scaleYOscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var scaleYOscillationFrequencyStart(get, set):String;
	private var _scaleYOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_scaleYOscillationFrequencyStart():String { return this._scaleYOscillationFrequencyStart; }
	private function set_scaleYOscillationFrequencyStart(value:String):String
	{
		if (this._scaleYOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._scaleYOscillationFrequencyStartRandom = false;
				this._scaleYOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._scaleYOscillationFrequencyStartRandom = true;
				this._scaleYOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._scaleYOscillationFrequencyStartRandom = false;
				this._scaleYOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._scaleYOscillationFrequencyStart = value;
	}
	
	// oscillation skewX
	private var _skewXOscillationEnabled:Bool = false;
	private var _skewXOscillationGroupStep:Float;
	private var _skewXOscillationGroupValue:Float;
	private var _skewXOscillationGlobalFrequencyEnabled:Bool = false;
	private var _skewXOscillationGroupFrequencyEnabled:Bool = false;
	private var _skewXOscillationFrequencyStartRandom:Bool = false;
	private var _skewXOscillationFrequencyStartUnifiedRandom:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var skewXOscillationFrequencyMode(get, set):String;
	private var _skewXOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_skewXOscillationFrequencyMode():String { return this._skewXOscillationFrequencyMode; }
	private function set_skewXOscillationFrequencyMode(value:String):String
	{
		if (this._skewXOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._skewXOscillationGlobalFrequencyEnabled = true;
				this._skewXOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._skewXOscillationGlobalFrequencyEnabled = false;
				this._skewXOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._skewXOscillationGlobalFrequencyEnabled = false;
				this._skewXOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._skewXOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var skewXOscillationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var skewXOscillation(get, set):Float;
	private var _skewXOscillation:Float = 0.0;
	private function get_skewXOscillation():Float { return this._skewXOscillation; }
	private function set_skewXOscillation(value:Float):Float
	{
		this._skewXOscillation = value;
		this._skewXOscillationEnabled = this._skewXOscillation != 0.0 || this._skewXOscillationVariance != 0.0;
		return this._skewXOscillation;
	}
	
	/**
	   @default 0
	**/
	public var skewXOscillationVariance(get, set):Float;
	private var _skewXOscillationVariance:Float = 0.0;
	private function get_skewXOscillationVariance():Float { return this._skewXOscillationVariance; }
	private function set_skewXOscillationVariance(value:Float):Float
	{
		this._skewXOscillationVariance = value;
		this._skewXOscillationEnabled = this._skewXOscillation != 0.0 || this._skewXOscillationVariance != 0.0;
		return this._skewXOscillationVariance;
	}
	
	/**
	   @default 1
	**/
	public var skewXOscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var skewXOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _skewXOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_skewXOscillationUnifiedFrequencyVariance():Bool { return this._skewXOscillationUnifiedFrequencyVariance; }
	private function set_skewXOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._skewXOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._skewXOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var skewXOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var skewXOscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var skewXOscillationFrequencyStart(get, set):String;
	private var _skewXOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_skewXOscillationFrequencyStart():String { return this._skewXOscillationFrequencyStart; }
	private function set_skewXOscillationFrequencyStart(value:String):String
	{
		if (this._skewXOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._skewXOscillationFrequencyStartRandom = false;
				this._skewXOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._skewXOscillationFrequencyStartRandom = true;
				this._skewXOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._skewXOscillationFrequencyStartRandom = false;
				this._skewXOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._skewXOscillationFrequencyStart = value;
	}
	
	// oscillation skewY
	private var _skewYOscillationEnabled:Bool = false;
	private var _skewYOscillationGroupStep:Float;
	private var _skewYOscillationGroupValue:Float;
	private var _skewYOscillationGlobalFrequencyEnabled:Bool = false;
	private var _skewYOscillationGroupFrequencyEnabled:Bool = false;
	private var _skewYOscillationFrequencyStartRandom:Bool = false;
	private var _skewYOscillationFrequencyStartUnifiedRandom:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var skewYOscillationFrequencyMode(get, set):String;
	private var _skewYOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_skewYOscillationFrequencyMode():String { return this._skewYOscillationFrequencyMode; }
	private function set_skewYOscillationFrequencyMode(value:String):String
	{
		if (this._skewYOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._skewYOscillationGlobalFrequencyEnabled = true;
				this._skewYOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._skewYOscillationGlobalFrequencyEnabled = false;
				this._skewYOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._skewYOscillationGlobalFrequencyEnabled = false;
				this._skewYOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._skewYOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var skewYOscillationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var skewYOscillation(get, set):Float;
	private var _skewYOscillation:Float = 0.0;
	private function get_skewYOscillation():Float { return this._skewYOscillation; }
	private function set_skewYOscillation(value:Float):Float
	{
		this._skewYOscillation = value;
		this._skewYOscillationEnabled = this._skewYOscillation != 0.0 || this._skewYOscillationVariance != 0.0;
		return this._skewYOscillation;
	}
	
	/**
	   @default 0
	**/
	public var skewYOscillationVariance(get, set):Float;
	private var _skewYOscillationVariance:Float = 0.0;
	private function get_skewYOscillationVariance():Float { return this._skewYOscillationVariance; }
	private function set_skewYOscillationVariance(value:Float):Float
	{
		this._skewYOscillationVariance = value;
		this._skewYOscillationEnabled = this._skewYOscillation != 0.0 || this._skewYOscillationVariance != 0.0;
		return this._skewYOscillationVariance;
	}
	
	/**
	   @default 1
	**/
	public var skewYOscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var skewYOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _skewYOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_skewYOscillationUnifiedFrequencyVariance():Bool { return this._skewYOscillationUnifiedFrequencyVariance; }
	private function set_skewYOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._skewYOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._skewYOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var skewYOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var skewYOscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var skewYOscillationFrequencyStart(get, set):String;
	private var _skewYOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_skewYOscillationFrequencyStart():String { return this._skewYOscillationFrequencyStart; }
	private function set_skewYOscillationFrequencyStart(value:String):String
	{
		if (this._skewYOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._skewYOscillationFrequencyStartRandom = false;
				this._skewYOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._skewYOscillationFrequencyStartRandom = true;
				this._skewYOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._skewYOscillationFrequencyStartRandom = false;
				this._skewYOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._skewYOscillationFrequencyStart = value;
	}
	
	// oscillation color
	private var _useColorOscillation:Bool = false;
	private var _colorOscillationGroupStep:Float;
	private var _colorOscillationGroupValue:Float;
	private var _colorOscillationGlobalFrequencyEnabled:Bool = false;
	private var _colorOscillationGroupFrequencyEnabled:Bool = false;
	private var _colorOscillationFrequencyStartRandom:Bool = false;
	private var _colorOscillationFrequencyStartUnifiedRandom:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var colorOscillationFrequencyMode(get, set):String;
	private var _colorOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_colorOscillationFrequencyMode():String { return this._colorOscillationFrequencyMode; }
	private function set_colorOscillationFrequencyMode(value:String):String
	{
		if (this._colorOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._colorOscillationGlobalFrequencyEnabled = true;
				this._colorOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._colorOscillationGlobalFrequencyEnabled = false;
				this._colorOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._colorOscillationGlobalFrequencyEnabled = false;
				this._colorOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._colorOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var colorOscillationGroupStartStep:Float = 0.0;
	
	/**
	   
	**/
	public var colorOscillation(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorOscillationVariance(default, null):MassiveTint;
	
	/**
	   @default 1.0
	**/
	public var colorOscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var colorOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _colorOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_colorOscillationUnifiedFrequencyVariance():Bool { return this._colorOscillationUnifiedFrequencyVariance; }
	private function set_colorOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._colorOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._colorOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var colorOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var colorOscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var colorOscillationFrequencyStart(get, set):String;
	private var _colorOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_colorOscillationFrequencyStart():String { return this._colorOscillationFrequencyStart; }
	private function set_colorOscillationFrequencyStart(value:String):String
	{
		if (this._colorOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._colorOscillationFrequencyStartRandom = false;
				this._colorOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._colorOscillationFrequencyStartRandom = true;
				this._colorOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._colorOscillationFrequencyStartRandom = false;
				this._colorOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._colorOscillationFrequencyStart = value;
	}
	
	// oscillation color offset
	private var _useColorOffsetOscillation:Bool = false;
	private var _colorOffsetOscillationGroupStep:Float;
	private var _colorOffsetOscillationGroupValue:Float;
	private var _colorOffsetOscillationGlobalFrequencyEnabled:Bool = false;
	private var _colorOffsetOscillationGroupFrequencyEnabled:Bool = false;
	private var _colorOffsetOscillationFrequencyStartRandom:Bool = false;
	private var _colorOffsetOscillationFrequencyStartUnifiedRandom:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var colorOffsetOscillationFrequencyMode(get, set):String;
	private var _colorOffsetOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_colorOffsetOscillationFrequencyMode():String { return this._colorOffsetOscillationFrequencyMode; }
	private function set_colorOffsetOscillationFrequencyMode(value:String):String
	{
		if (this._colorOffsetOscillationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._colorOffsetOscillationGlobalFrequencyEnabled = true;
				this._colorOffsetOscillationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._colorOffsetOscillationGlobalFrequencyEnabled = false;
				this._colorOffsetOscillationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._colorOffsetOscillationGlobalFrequencyEnabled = false;
				this._colorOffsetOscillationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._colorOffsetOscillationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var colorOffsetOscillationGroupStartStep:Float = 0.0;
	
	/**
	   
	**/
	public var colorOffsetOscillation(default, null):MassiveTint;
	
	/**
	   
	**/
	public var colorOffsetOscillationVariance(default, null):MassiveTint;
	
	/**
	   @default 1.0
	**/
	public var colorOffsetOscillationFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var colorOffsetOscillationUnifiedFrequencyVariance(get, set):Bool;
	private var _colorOffsetOscillationUnifiedFrequencyVariance:Bool = false;
	private function get_colorOffsetOscillationUnifiedFrequencyVariance():Bool { return this._colorOffsetOscillationUnifiedFrequencyVariance; }
	private function set_colorOffsetOscillationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._colorOffsetOscillationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._colorOffsetOscillationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var colorOffsetOscillationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var colorOffsetOscillationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var colorOffsetOscillationFrequencyStart(get, set):String;
	private var _colorOffsetOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_colorOffsetOscillationFrequencyStart():String { return this._colorOffsetOscillationFrequencyStart; }
	private function set_colorOffsetOscillationFrequencyStart(value:String):String
	{
		if (this._colorOffsetOscillationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._colorOffsetOscillationFrequencyStartRandom = false;
				this._colorOffsetOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._colorOffsetOscillationFrequencyStartRandom = true;
				this._colorOffsetOscillationFrequencyStartUnifiedRandom = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._colorOffsetOscillationFrequencyStartRandom = false;
				this._colorOffsetOscillationFrequencyStartUnifiedRandom = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._colorOffsetOscillationFrequencyStart = value;
	}
	//##################################################
	//\OSCILLATION
	//##################################################
	/**
	   @default false
	**/
	public var forceSortFlag:Bool = false;
	
	/**
	   @default null
	**/
	#if flash
	public var customFunction:Vector<T>->Int->Void;
	#else
	public var customFunction:Array<T>->Int->Void;
	#end
	
	/**
	   
	**/
	public var isPlaying(get, never):Bool;
	private var _isPlaying:Bool = false;
	private function get_isPlaying():Bool { return this._isPlaying; }
	
	/**
	   
	**/
	public var numParticles(get, never):Int;
	private var _numParticles:Int = 0;
	private function get_numParticles():Int { return this._numParticles; }
	
	/**
	   @default null
	**/
	public var sortFunction(get, set):T->T->Int;
	private var _sortFunction:T->T->Int;
	private function get_sortFunction():T->T->Int { return this._sortFunction; }
	private function set_sortFunction(value:T->T->Int):T->T->Int
	{
		this._regularSorting = value == null;
		return this._sortFunction = value;
	}
	
	private var _completed:Bool = true;
	private var _frameTime:Float = 0.0;
	#if flash
	private var _particles:Vector<T>;
	#else
	private var _particles:Array<T>;
	#end
	private var _particleTotal:Int;
	private var _regularSorting:Bool = true;
	private var _updateEmitter:Bool = false;
	private var _burstInProgress:Bool;
	private var _burstRemaining:Bool;
	private var _burstTime:Float;
	private var _burstTotal:Int;
	private var _nextBurstTime:Float;
	private var _emissionEnabled:Bool;
	private var _emissionInfinite:Bool;
	
	#if flash
	private var _frames:Vector<Vector<Frame>> = new Vector<Vector<Frame>>();
	#else
	private var _frames:Array<Array<Frame>> = new Array<Array<Frame>>();
	#end
	private var _frameTimings:Array<Array<Float>> = new Array<Array<Float>>();
	private var _numFrameSets:Int = 0;
	private var _useMultipleFrameSets:Bool = false;
	
	private var _isParticlePoolUpdatePending:Bool = false;

	public function new(options:ParticleSystemOptions = null) 
	{
		super();
		
		this.colorStart = new MassiveTint(1.0, 1.0, 1.0, 1.0, colorChange);
		this.colorStartVariance = new MassiveTint(0.0, 0.0, 0.0, 0.0, colorChange);
		this.colorEnd = new MassiveTint(1.0, 1.0, 1.0, 1.0, colorChange);
		this.colorEndVariance = new MassiveTint(0.0, 0.0, 0.0, 0.0, colorChange);
		
		this.colorOffsetStart = new MassiveTint(0.0, 0.0, 0.0, 0.0, colorOffsetChange);
		this.colorOffsetStartVariance = new MassiveTint(0.0, 0.0, 0.0, 0.0, colorOffsetChange);
		this.colorOffsetEnd = new MassiveTint(0.0, 0.0, 0.0, 0.0, colorOffsetChange);
		this.colorOffsetEndVariance = new MassiveTint(0.0, 0.0, 0.0, 0.0, colorOffsetChange);
		
		this.colorOscillation = new MassiveTint(0.0, 0.0, 0.0, 0.0, oscillationColorChange);
		this.colorOscillationVariance = new MassiveTint(0.0, 0.0, 0.0, 0.0, oscillationColorChange);
		
		this.colorOffsetOscillation = new MassiveTint(0.0, 0.0, 0.0, 0.0, oscillationColorOffsetChange);
		this.colorOffsetOscillationVariance = new MassiveTint(0.0, 0.0, 0.0, 0.0, oscillationColorOffsetChange);
		
		this.animate = true;
		this.autoHandleNumDatas = false;
		this._particles = this._datas;
		
		init();
		
		if (options != null)
		{
			readSystemOptions(options);
		}
	}
	
	public function clear():Void
	{
		
	}
	
	private function init():Void
	{
		this._emissionRate = this._maxNumParticles / this._lifeSpan;
		//this._emissionTime = 0.0;
		//this._frameTime = 0.0;
	}
	
	public function addFrames(frames:#if flash Vector<Frame> #else Array<Frame>#end, timings:Array<Float> = null, refreshParticles:Bool = true):Void
	{
		if (timings == null) timings = Animator.generateTimings(frames);
		
		this._frames[this._frames.length] = frames;
		this._frameTimings[this._frameTimings.length] = timings;
		this._numFrameSets++;
		this._useMultipleFrameSets = this._numFrameSets > 1;
		
		if (refreshParticles)
		{
			returnParticlesToPool();
			if (this.particlesFromPoolFunction != null)
			{
				getParticlesFromPool();
			}
			else
			{
				this._isParticlePoolUpdatePending = true;
			}
		}
	}
	
	public function addFramesMultiple(frames:#if flash Vector<Vector<Frame>> #else Array<Array<Frame>>#end, timings:Array<Array<Float>> = null, refreshParticles:Bool = true):Void
	{
		var count:Int = frames.length;
		for (i in 0...count)
		{
			addFrames(frames[i], timings != null ? timings[i] : null, false);
		}
		
		if (refreshParticles)
		{
			returnParticlesToPool();
			if (this.particlesFromPoolFunction != null)
			{
				getParticlesFromPool();
			}
			else
			{
				this._isParticlePoolUpdatePending = true;
			}
		}
	}
	
	public function clearFrames():Void
	{
		returnParticlesToPool();
		
		#if flash
		this._frames.length = 0;
		#else
		this._frames.resize(0);
		#end
		this._frameTimings.resize(0);
		
		this._numFrameSets = 0;
		this._useMultipleFrameSets = false;
	}
	
	inline private function getRandomRatio():Float
	{
		return (((this.randomSeed = (this.randomSeed * 16807) & 0x7FFFFFFF) / 0x40000000) - 1.0);
	}
	
	private var __angle:Float;
	private var __angleCos:Float;
	private var __angleSin:Float;
	private var __colorAlphaStart:Float;
	private var __colorAlphaEnd:Float;
	private var __colorBlueStart:Float;
	private var __colorBlueEnd:Float;
	private var __colorGreenStart:Float;
	private var __colorGreenEnd:Float;
	private var __colorRedStart:Float;
	private var __colorRedEnd:Float;
	private var __redOffsetStart:Float;
	private var __redOffsetEnd:Float;
	private var __greenOffsetStart:Float;
	private var __greenOffsetEnd:Float;
	private var __blueOffsetStart:Float;
	private var __blueOffsetEnd:Float;
	private var __alphaOffsetStart:Float;
	private var __alphaOffsetEnd:Float;
	private var __firstFrameWidth:Float;
	private var __lifeSpan:Float;
	private var __nonFadeTime:Float;
	private var __oscillationUnifiedFrequencyStart:Float;
	private var __oscillationUnifiedFrequencyVariance:Float;
	private var __radius:Float;
	private var __radiusMax:Float;
	private var __radiusMin:Float;
	private var __random:Float;
	private var __ratio:Float;
	private var __rotationStart:Float;
	private var __rotationEnd:Float;
	private var __sizeXStart:Float;
	private var __sizeXEnd:Float;
	private var __sizeYStart:Float;
	private var __sizeYEnd:Float;
	private var __skewXStart:Float;
	private var __skewXEnd:Float;
	private var __skewYStart:Float;
	private var __skewYEnd:Float;
	private var __speed:Float;
	private var __velocityXInheritRatio:Float;
	private var __velocityYInheritRatio:Float;
	
	private var __deadParticle:Bool;
	
	#if !debug inline #end private function initParticle(particle:T):Void
	{
		#if debug
		particle.updateCount = 0;
		#end
		
		this.__deadParticle = false;
		
		particle.frameDelta = this._frameDelta + this.frameDeltaVariance * getRandomRatio();
		particle.frameTime = 0.0;
		particle.loopCount = 0;
		
		if (this._useAnimationLifeSpan)
		{
			if (this._loopAnimation)
			{
				if (this._animationLoops == 0)
				{
					this.__lifeSpan = MathUtils.FLOAT_MAX;
				}
				else
				{
					this.__lifeSpan = (particle.frameTimings[particle.frameTimings.length-1] / particle.frameDelta) * this._animationLoops;
				}
			}
			else
			{
				this.__lifeSpan = particle.frameTimings[particle.frameTimings.length-1] / particle.frameDelta;
			}
		}
		else
		{
			this.__lifeSpan = this._lifeSpan + this._lifeSpanVariance * getRandomRatio();
			if (this.__lifeSpan <= 0.0)
			{
				//return;
				this.__deadParticle = true;
			}
		}
		
		if (this.__deadParticle) return;
		
		if (this._useFadeIn)
		{
			particle.fadeInTime = this._fadeInTime;
		}
		else
		{
			particle.fadeInTime = 0.0;
		}
		
		if (this._useFadeOut)
		{
			particle.fadeOutTime = this.__lifeSpan - this._fadeOutTime;
			particle.fadeOutDuration = this._fadeOutTime;
		}
		else
		{
			particle.fadeOutTime = this.__lifeSpan;
			particle.fadeOutDuration = 0.0;
		}
		
		this.__nonFadeTime = particle.fadeOutTime - particle.fadeInTime;
		
		particle.visible = true;
		particle.timeCurrent = 0.0;
		particle.timeTotal = this.__lifeSpan;
		
		if (this._isTypeGravity)
		{
			// GRAVITY type
			this.__speed = this.speed + this.speedVariance * getRandomRatio();
			if (this.adjustLifeSpanToSpeed)
			{
				this.__ratio = this.speed / this.__speed;
				this.__lifeSpan *= this.__ratio;
			}
			particle.speed = this.__speed;
			
			if (this._useEmitterRadius)
			{
				this.__angle = this.emitAngle + this.emitAngleVariance * getRandomRatio();
				this.__radiusMin = this._emitterRadiusMin + this._emitterRadiusMinVariance * getRandomRatio();
				this.__radiusMax = this._emitterRadiusMax + this._emitterRadiusMaxVariance * getRandomRatio();
				this.__radius = this.__radiusMin + MathUtils.random() * (this.__radiusMax - this.__radiusMin);
				
				particle.startX = particle.xBase = this.emitterX + this.emitterXVariance * getRandomRatio() + Math.cos(this.__angle) * this.__radius;
				particle.startY = particle.yBase = this.emitterY + this.emitterYVariance * getRandomRatio() + Math.sin(this.__angle) * this.__radius;
				
				if (this.emitterRadiusOverridesParticleAngle)
				{
					particle.angle = this.__angle = this.__angle + this.emitterRadiusParticleAngleOffset + this.emitterRadiusParticleAngleOffsetVariance * getRandomRatio();
				}
				else
				{
					particle.angle = this.__angle = this.emitAngle + this.emitAngleVariance * getRandomRatio();
				}
			}
			else
			{
				particle.startX = particle.xBase = this.emitterX + this.emitterXVariance * getRandomRatio();
				particle.startY = particle.yBase = this.emitterY + this.emitterYVariance * getRandomRatio();
				
				particle.angle = this.__angle = this.emitAngle + this.emitAngleVariance * getRandomRatio();
			}
			
			particle.velocityX = this.__speed * Math.cos(this.__angle);
			particle.velocityY = this.__speed * Math.sin(this.__angle);
			
			if (this._useVelocityInheritanceX)
			{
				this.__velocityXInheritRatio = this._velocityXInheritRatio + this._velocityXInheritRatioVariance * getRandomRatio();
				particle.velocityX += this.velocityX * this.__velocityXInheritRatio;
			}
			
			if (this._useVelocityInheritanceY)
			{
				this.__velocityYInheritRatio = this._velocityYInheritRatio + this._velocityYInheritRatioVariance * getRandomRatio();
				particle.velocityY += this.velocityY * this.__velocityYInheritRatio;
			}
			
			if (this._useDrag)
			{
				particle.dragForce = this._drag + this._dragVariance * getRandomRatio();
			}
			
			if (this._useRadialAcceleration)
			{
				particle.radialAcceleration = this._radialAcceleration + this._radialAccelerationVariance * getRandomRatio();
			}
			else
			{
				particle.radialAcceleration = 0.0;
			}
			if (this._useTangentialAcceleration)
			{
				particle.tangentialAcceleration = this._tangentialAcceleration + this._tangentialAccelerationVariance * getRandomRatio();
			}
			else
			{
				particle.tangentialAcceleration = 0.0;
			}
		}
		else
		{
			// RADIAL type
			particle.emitRadius = this.radiusMax + this.radiusMaxVariance * getRandomRatio();
			particle.emitRadiusDelta = (this.radiusMin + this.radiusMinVariance * getRandomRatio() - particle.emitRadius) / this.__lifeSpan;
			particle.emitRotation = this.__angle = this.emitAngle + this.emitAngleVariance * getRandomRatio();
			particle.emitRotationDelta = this.rotatePerSecond + this.rotatePerSecondVariance * getRandomRatio();
			
			if (this.alignRadialRotation)
			{
				particle.radialRotationOffset = this.alignRadialRotationOffset + this.alignRadialRotationOffsetVariance * getRandomRatio();
			}
		}
		
		if (this._useSizeX)
		{
			particle.sizeXStart = this.__sizeXStart = this._sizeXStart + this._sizeXStartVariance * getRandomRatio();
			particle.sizeXEnd = this.__sizeXEnd = this._sizeXEnd + this._sizeXEndVariance * getRandomRatio();
		}
		else
		{
			particle.sizeXStart = this.__sizeXStart = this._sizeXStart;
		}
		
		if (this._useSizeY)
		{
			particle.sizeYStart = this.__sizeYStart = this._sizeYStart + this._sizeYStartVariance * getRandomRatio();
			particle.sizeYEnd = this.__sizeYEnd = this._sizeYEnd + this._sizeYEndVariance * getRandomRatio();
		}
		else
		{
			particle.sizeYStart = this.__sizeYStart = this._sizeYStart;
		}
		
		this.__firstFrameWidth = particle.frameList[0].width;
		particle.scaleXBase = particle.scaleXStart = this.__sizeXStart / this.__firstFrameWidth;
		particle.scaleYBase = particle.scaleYStart = this.__sizeYStart / this.__firstFrameWidth;
		if (this._useSizeX)
		{
			particle.scaleXEnd = this.__sizeXEnd / this.__firstFrameWidth;
			particle.scaleXDelta = (particle.scaleXEnd - particle.scaleXStart) / this.__lifeSpan;
		}
		if (this._useSizeY)
		{
			particle.scaleYEnd = this.__sizeYEnd / this.__firstFrameWidth;
			particle.scaleYDelta = (particle.scaleYEnd - particle.scaleYStart) / this.__lifeSpan;
		}
		
		particle.rotationVelocity = 0.0;
		particle.scaleXVelocity = particle.scaleYVelocity = 1.0;
		particle.skewXVelocity = particle.skewYVelocity = 0.0;
		
		if (this._useSkewX)
		{
			particle.skewXBase = particle.skewXStart = this.__skewXStart = this._skewXStart + this._skewXStartVariance * getRandomRatio();
			if (this.skewXEndRelativeToStart)
			{
				particle.skewXEnd = this.__skewXEnd = this.__skewXStart + this._skewXEnd + this._skewXEndVariance * getRandomRatio();
			}
			else
			{
				particle.skewXEnd = this.__skewXEnd = this._skewXEnd + this._skewXEndVariance * getRandomRatio();
			}
			particle.skewXDelta = (this.__skewXEnd - this.__skewXStart) / this.__lifeSpan;
		}
		else if (this._hasSkewX)
		{
			particle.skewXBase = particle.skewXStart = this.__skewXStart = this._skewXStart + this._skewXStartVariance * getRandomRatio();
		}
		else
		{
			particle.skewXBase = 0.0;
		}
		
		if (this._useSkewY)
		{
			particle.skewYBase = particle.skewYStart = this.__skewYStart = this._skewYStart + this._skewYStartVariance * getRandomRatio();
			if (this.skewYEndRelativeToStart)
			{
				particle.skewYEnd = this.__skewYEnd = this.__skewYStart + this._skewYEnd + this._skewYEndVariance * getRandomRatio();
			}
			else
			{
				particle.skewYEnd = this.__skewYEnd = this._skewYEnd + this._skewYEndVariance * getRandomRatio();
			}
			particle.skewYDelta = (this.__skewYEnd - this.__skewYStart) / this.__lifeSpan;
		}
		else if (this._hasSkewY)
		{
			particle.skewYBase = particle.skewYStart = this.__skewYStart = this._skewYStart + this._skewYStartVariance * getRandomRatio();
		}
		else
		{
			particle.skewYBase = 0.0;
		}
		
		// OSCILLATION
		if (this._useOscillationUnifiedRandomFrequencyStart)
		{
			this.__oscillationUnifiedFrequencyStart = MathUtils.random() * MathUtils.PI2;
		}
		if (this._useOscillationUnifiedFrequencyVariance)
		{
			this.__oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance * getRandomRatio();
		}
		
		if (this._positionOscillationEnabled)
		{
			particle.positionOscillationAngle = this.positionOscillationAngle + this.positionOscillationAngleVariance * getRandomRatio();
			particle.positionOscillationRadius = this._positionOscillationRadius + this._positionOscillationRadiusVariance * getRandomRatio();
			if (!this._positionOscillationGlobalFrequencyEnabled && !this._positionOscillationGroupFrequencyEnabled)
			{
				if (this._positionOscillationUnifiedFrequencyVariance)
				{
					particle.positionOscillationFrequency = this.positionOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.positionOscillationFrequency = this.positionOscillationFrequency + this.positionOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._positionOscillationFrequencyStartRandom)
				{
					particle.positionOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._positionOscillationFrequencyStartUnifiedRandom)
				{
					particle.positionOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.positionOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.positionXOscillation = particle.positionYOscillation = 0.0;
		}
		
		if (this._position2OscillationEnabled)
		{
			particle.position2OscillationAngle = this.position2OscillationAngle + this.position2OscillationAngleVariance * getRandomRatio();
			particle.position2OscillationRadius = this._position2OscillationRadius + this._position2OscillationRadiusVariance * getRandomRatio();
			if (!this._position2OscillationGlobalFrequencyEnabled && !this._position2OscillationGroupFrequencyEnabled)
			{
				if (this._position2OscillationUnifiedFrequencyVariance)
				{
					particle.position2OscillationFrequency = this.position2OscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.position2OscillationFrequency = this.position2OscillationFrequency + this.position2OscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._position2OscillationFrequencyStartRandom)
				{
					particle.position2OscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._position2OscillationFrequencyStartUnifiedRandom)
				{
					particle.position2OscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.position2OscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.position2XOscillation = particle.position2YOscillation = 0.0;
		}
		
		if (this._rotationOscillationEnabled)
		{
			particle.rotationOscillationAngle = this._rotationOscillationAngle + this._rotationOscillationAngleVariance * getRandomRatio();
			if (!this._rotationOscillationGlobalFrequencyEnabled && !this._rotationOscillationGroupFrequencyEnabled)
			{
				if (this._rotationOscillationUnifiedFrequencyVariance)
				{
					particle.rotationOscillationFrequency = this.rotationOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.rotationOscillationFrequency = this.rotationOscillationFrequency + this.rotationOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._rotationOscillationFrequencyStartRandom)
				{
					particle.rotationOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._rotationOscillationFrequencyStartUnifiedRandom)
				{
					particle.rotationOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.rotationOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.rotationOscillation = 0.0;
		}
		
		if (this._scaleXOscillationEnabled)
		{
			particle.scaleXOscillationFactor = this._scaleXOscillation + this._scaleXOscillationVariance * getRandomRatio();
			if (!this._scaleXOscillationGlobalFrequencyEnabled && !this._scaleXOscillationGroupFrequencyEnabled)
			{
				if (this._scaleXOscillationUnifiedFrequencyVariance)
				{
					particle.scaleXOscillationFrequency = this.scaleXOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.scaleXOscillationFrequency = this.scaleXOscillationFrequency + this.scaleXOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._scaleXOscillationFrequencyStartRandom)
				{
					particle.scaleXOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._scaleXOscillationFrequencyStartUnifiedRandom)
				{
					particle.scaleXOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.scaleXOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.scaleXOscillation = 1.0;
		}
		
		if (this._scaleYOscillationEnabled)
		{
			particle.scaleYOscillationFactor = this._scaleYOscillation + this._scaleYOscillationVariance * getRandomRatio();
			if (!this._scaleYOscillationGlobalFrequencyEnabled && !this._scaleYOscillationGroupFrequencyEnabled)
			{
				if (this._scaleYOscillationUnifiedFrequencyVariance)
				{
					particle.scaleYOscillationFrequency = this.scaleYOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.scaleYOscillationFrequency = this.scaleYOscillationFrequency + this.scaleYOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._scaleYOscillationFrequencyStartRandom)
				{
					particle.scaleYOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._scaleYOscillationFrequencyStartUnifiedRandom)
				{
					particle.scaleYOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.scaleYOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.scaleYOscillation = 1.0;
		}
		
		if (this._skewXOscillationEnabled)
		{
			particle.skewXOscillationFactor = this._skewXOscillation + this._skewXOscillationVariance * getRandomRatio();
			if (!this._skewXOscillationGlobalFrequencyEnabled && !this._skewXOscillationGroupFrequencyEnabled)
			{
				if (this._skewXOscillationUnifiedFrequencyVariance)
				{
					particle.skewXOscillationFrequency = this.skewXOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.skewXOscillationFrequency = this.skewXOscillationFrequency + this.skewXOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._skewXOscillationFrequencyStartRandom)
				{
					particle.skewXOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._skewXOscillationFrequencyStartUnifiedRandom)
				{
					particle.skewXOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.skewXOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.skewXOscillation = 0.0;
		}
		
		if (this._skewYOscillationEnabled)
		{
			particle.skewYOscillationFactor = this._skewYOscillation + this._skewYOscillationVariance * getRandomRatio();
			if (!this._skewYOscillationGlobalFrequencyEnabled && !this._skewYOscillationGroupFrequencyEnabled)
			{
				if (this._skewYOscillationUnifiedFrequencyVariance)
				{
					particle.skewYOscillationFrequency = this.skewYOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.skewYOscillationFrequency = this.skewYOscillationFrequency + this.skewYOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._skewYOscillationFrequencyStartRandom)
				{
					particle.skewYOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._skewYOscillationFrequencyStartUnifiedRandom)
				{
					particle.skewYOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.skewYOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.skewYOscillation = 0.0;
		}
		
		if (this._useColorOscillation)
		{
			particle.redOscillationFactor = this.colorOscillation.redValue + this.colorOscillationVariance.redValue * getRandomRatio();
			particle.greenOscillationFactor = this.colorOscillation.greenValue + this.colorOscillationVariance.greenValue * getRandomRatio();
			particle.blueOscillationFactor = this.colorOscillation.blueValue + this.colorOscillationVariance.blueValue * getRandomRatio();
			particle.alphaOscillationFactor = this.colorOscillation.alphaValue + this.colorOscillationVariance.alphaValue * getRandomRatio();
			if (!this._colorOscillationGlobalFrequencyEnabled && !this._colorOscillationGroupFrequencyEnabled)
			{
				if (this._colorOscillationUnifiedFrequencyVariance)
				{
					particle.colorOscillationFrequency = this.colorOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.colorOscillationFrequency = this.colorOscillationFrequency + this.colorOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._colorOscillationFrequencyStartRandom)
				{
					particle.colorOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._colorOscillationFrequencyStartUnifiedRandom)
				{
					particle.colorOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.colorOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.redOscillation = particle.greenOscillation = particle.blueOscillation = particle.alphaOscillation = 0.0;
		}
		
		if (this._useColorOffsetOscillation)
		{
			particle.redOffsetOscillationFactor = this.colorOffsetOscillation.redValue + this.colorOffsetOscillationVariance.redValue * getRandomRatio();
			particle.greenOffsetOscillationFactor = this.colorOffsetOscillation.greenValue + this.colorOffsetOscillationVariance.greenValue * getRandomRatio();
			particle.blueOffsetOscillationFactor = this.colorOffsetOscillation.blueValue + this.colorOffsetOscillationVariance.blueValue * getRandomRatio();
			particle.alphaOffsetOscillationFactor = this.colorOffsetOscillation.alphaValue + this.colorOffsetOscillationVariance.alphaValue * getRandomRatio();
			if (!this._colorOffsetOscillationGlobalFrequencyEnabled && !this._colorOffsetOscillationGroupFrequencyEnabled)
			{
				if (this._colorOffsetOscillationUnifiedFrequencyVariance)
				{
					particle.colorOffsetOscillationFrequency = this.colorOffsetOscillationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.colorOffsetOscillationFrequency = this.colorOffsetOscillationFrequency + this.colorOffsetOscillationFrequencyVariance * getRandomRatio();
				}
				
				if (this._colorOffsetOscillationFrequencyStartRandom)
				{
					particle.colorOffsetOscillationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._colorOffsetOscillationFrequencyStartUnifiedRandom)
				{
					particle.colorOffsetOscillationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.colorOffsetOscillationStep = 0.0;
				}
			}
		}
		else
		{
			particle.redOffsetOscillation = particle.greenOffsetOscillation = particle.blueOffsetOscillation = particle.alphaOffsetOscillation = 0.0;
		}
		//\OSCILLATION
		
		if (this._hasColorStartVariance)
		{
			this.__colorRedStart = this.colorStart.redValue + this.colorStartVariance.redValue * getRandomRatio();
			this.__colorGreenStart = this.colorStart.greenValue + this.colorStartVariance.greenValue * getRandomRatio();
			this.__colorBlueStart = this.colorStart.blueValue + this.colorStartVariance.blueValue * getRandomRatio();
			this.__colorAlphaStart = this.colorStart.alphaValue + this.colorStartVariance.alphaValue * getRandomRatio();
		}
		else
		{
			this.__colorRedStart = this.colorStart.redValue;
			this.__colorGreenStart = this.colorStart.greenValue;
			this.__colorBlueStart = this.colorStart.blueValue;
			this.__colorAlphaStart = this.colorStart.alphaValue;
		}
		
		if (this._useColor)
		{
			if (this._colorEndRelativeToStart)
			{
				if (this._colorEndIsMultiplier)
				{
					if (this._hasColorEndVariance)
					{
						this.__colorRedEnd = this.__colorRedStart * (this.colorEnd.redValue + this.colorEndVariance.redValue * getRandomRatio());
						this.__colorGreenEnd = this.__colorGreenStart * (this.colorEnd.greenValue + this.colorEndVariance.greenValue * getRandomRatio());
						this.__colorBlueEnd = this.__colorBlueStart * (this.colorEnd.blueValue + this.colorEndVariance.blueValue * getRandomRatio());
						this.__colorAlphaEnd = this.__colorAlphaStart * (this.colorEnd.alphaValue + this.colorEndVariance.alphaValue * getRandomRatio());
					}
					else
					{
						this.__colorRedEnd = this.__colorRedStart * this.colorEnd.redValue;
						this.__colorGreenEnd = this.__colorGreenStart * this.colorEnd.greenValue;
						this.__colorBlueEnd = this.__colorBlueStart * this.colorEnd.blueValue;
						this.__colorAlphaEnd = this.__colorAlphaStart * this.colorEnd.alphaValue;
					}
				}
				else
				{
					if (this._hasColorEndVariance)
					{
						this.__colorRedEnd = this.__colorRedStart + this.colorEnd.redValue + this.colorEndVariance.redValue * getRandomRatio();
						this.__colorGreenEnd = this.__colorGreenStart + this.colorEnd.greenValue + this.colorEndVariance.greenValue * getRandomRatio();
						this.__colorBlueEnd = this.__colorBlueStart + this.colorEnd.blueValue + this.colorEndVariance.blueValue * getRandomRatio();
						this.__colorAlphaEnd = this.__colorAlphaStart + this.colorEnd.alphaValue + this.colorEndVariance.alphaValue * getRandomRatio();
					}
					else
					{
						this.__colorRedEnd = this.__colorRedStart + this.colorEnd.redValue;
						this.__colorGreenEnd = this.__colorGreenStart + this.colorEnd.greenValue;
						this.__colorBlueEnd = this.__colorBlueStart + this.colorEnd.blueValue;
						this.__colorAlphaEnd = this.__colorAlphaStart + this.colorEnd.alphaValue;
					}
				}
			}
			else
			{
				if (this._hasColorEndVariance)
				{
					this.__colorRedEnd = this.colorEnd.redValue + this.colorEndVariance.redValue * getRandomRatio();
					this.__colorGreenEnd = this.colorEnd.greenValue + this.colorEndVariance.greenValue * getRandomRatio();
					this.__colorBlueEnd = this.colorEnd.blueValue + this.colorEndVariance.blueValue * getRandomRatio();
					this.__colorAlphaEnd = this.colorEnd.alphaValue + this.colorEndVariance.alphaValue * getRandomRatio();
				}
				else
				{
					this.__colorRedEnd = this.colorEnd.redValue;
					this.__colorGreenEnd = this.colorEnd.greenValue;
					this.__colorBlueEnd = this.colorEnd.blueValue;
					this.__colorAlphaEnd = this.colorEnd.alphaValue;
				}
			}
			
			particle.redBase = this.__colorRedStart;
			particle.greenBase = this.__colorGreenStart;
			particle.blueBase = this.__colorBlueStart;
			particle.alphaBase = this._useFadeIn ? 0.0 : this.__colorAlphaStart;
			
			particle.alphaStart = this.__colorAlphaStart;
			particle.alphaEnd = this.__colorAlphaEnd;
			
			particle.redDelta = (this.__colorRedEnd - this.__colorRedStart) / this.__lifeSpan;
			particle.greenDelta = (this.__colorGreenEnd - this.__colorGreenStart) / this.__lifeSpan;
			particle.blueDelta = (this.__colorBlueEnd - this.__colorBlueStart) / this.__lifeSpan;
			particle.alphaDelta = (this.__colorAlphaEnd - this.__colorAlphaStart) / this.__nonFadeTime; // we only interpolate alpha after fade in and before fade out
		}
		else
		{
			particle.redBase = this.__colorRedStart;
			particle.greenBase = this.__colorGreenStart;
			particle.blueBase = this.__colorBlueStart;
			particle.alphaBase = this._useFadeIn ? 0.0 : this.__colorAlphaStart;
			particle.alphaStart = particle.alphaEnd = this.__colorAlphaStart; // needed for fade in/out
		}
		
		if (!this._hasAnyColor)
		{
			particle.red = particle.redBase;
			particle.green = particle.greenBase;
			particle.blue = particle.blueBase;
			particle.alpha = particle.alphaBase;
		}
		
		if (this._hasColorOffset || this._useColorOffset)
		{
			if (this._hasColorOffsetStartVariance)
			{
				this.__redOffsetStart = this.colorOffsetStart.redValue + this.colorOffsetStartVariance.redValue * getRandomRatio();
				this.__greenOffsetStart = this.colorOffsetStart.greenValue + this.colorOffsetStartVariance.greenValue * getRandomRatio();
				this.__blueOffsetStart = this.colorOffsetStart.blueValue + this.colorOffsetStartVariance.blueValue * getRandomRatio();
				this.__alphaOffsetStart = this.colorOffsetStart.alphaValue + this.colorOffsetStartVariance.alphaValue * getRandomRatio();
			}
			else
			{
				this.__redOffsetStart = this.colorOffsetStart.redValue;
				this.__greenOffsetStart = this.colorOffsetStart.greenValue;
				this.__blueOffsetStart = this.colorOffsetStart.blueValue;
				this.__alphaOffsetStart = this.colorOffsetStart.alphaValue;
			}
			
			if (this._useColorOffset)
			{
				if (this._colorOffsetEndRelativeToStart)
				{
					if (this._colorOffsetEndIsMultiplier)
					{
						if (this._hasColorOffsetEndVariance)
						{
							this.__redOffsetEnd = this.__redOffsetStart * (this.colorOffsetEnd.redValue + this.colorOffsetEndVariance.redValue * getRandomRatio());
							this.__greenOffsetEnd = this.__greenOffsetStart * (this.colorOffsetEnd.greenValue + this.colorOffsetEndVariance.greenValue * getRandomRatio());
							this.__blueOffsetEnd = this.__blueOffsetStart * (this.colorOffsetEnd.blueValue + this.colorOffsetEndVariance.blueValue * getRandomRatio());
							this.__alphaOffsetEnd = this.__alphaOffsetStart * (this.colorOffsetEnd.alphaValue + this.colorOffsetEndVariance.alphaValue * getRandomRatio());
						}
						else
						{
							this.__redOffsetEnd = this.__redOffsetStart * this.colorOffsetEnd.redValue;
							this.__greenOffsetEnd = this.__greenOffsetStart * this.colorOffsetEnd.greenValue;
							this.__blueOffsetEnd = this.__blueOffsetStart * this.colorOffsetEnd.blueValue;
							this.__alphaOffsetEnd = this.__alphaOffsetStart * this.colorOffsetEnd.alphaValue;
						}
					}
					else
					{
						if (this._hasColorOffsetEndVariance)
						{
							this.__redOffsetEnd = this.__redOffsetStart + this.colorOffsetEnd.redValue + this.colorOffsetEndVariance.redValue * getRandomRatio();
							this.__greenOffsetEnd = this.__greenOffsetStart + this.colorOffsetEnd.greenValue + this.colorOffsetEndVariance.greenValue * getRandomRatio();
							this.__blueOffsetEnd = this.__blueOffsetStart + this.colorOffsetEnd.blueValue + this.colorOffsetEndVariance.blueValue * getRandomRatio();
							this.__alphaOffsetEnd = this.__alphaOffsetStart + this.colorOffsetEnd.alphaValue + this.colorOffsetEndVariance.alphaValue * getRandomRatio();
						}
						else
						{
							this.__redOffsetEnd = this.__redOffsetStart + this.colorOffsetEnd.redValue;
							this.__greenOffsetEnd = this.__greenOffsetStart + this.colorOffsetEnd.greenValue;
							this.__blueOffsetEnd = this.__blueOffsetStart + this.colorOffsetEnd.blueValue;
							this.__alphaOffsetEnd = this.__alphaOffsetStart + this.colorOffsetEnd.alphaValue;
						}
					}
				}
				else
				{
					if (this._hasColorOffsetEndVariance)
					{
						this.__redOffsetEnd = this.colorOffsetEnd.redValue + this.colorOffsetEndVariance.redValue * getRandomRatio();
						this.__greenOffsetEnd = this.colorOffsetEnd.greenValue + this.colorOffsetEndVariance.greenValue * getRandomRatio();
						this.__blueOffsetEnd = this.colorOffsetEnd.blueValue + this.colorOffsetEndVariance.blueValue * getRandomRatio();
						this.__alphaOffsetEnd = this.colorOffsetEnd.alphaValue + this.colorOffsetEndVariance.alphaValue * getRandomRatio();
					}
					else
					{
						this.__redOffsetEnd = this.colorOffsetEnd.redValue;
						this.__greenOffsetEnd = this.colorOffsetEnd.greenValue;
						this.__blueOffsetEnd = this.colorOffsetEnd.blueValue;
						this.__alphaOffsetEnd = this.colorOffsetEnd.alphaValue;
					}
				}
				
				particle.redOffsetBase = this.__redOffsetStart;
				particle.greenOffsetBase = this.__greenOffsetStart;
				particle.blueOffsetBase = this.__blueOffsetStart;
				particle.alphaOffsetBase = this._useFadeIn ? 0.0 : this.__alphaOffsetStart;
				
				particle.alphaOffsetStart = this.__alphaOffsetStart;
				particle.alphaOffsetEnd = this.__alphaOffsetEnd;
				
				particle.redOffsetDelta = (this.__redOffsetEnd - this.__redOffsetStart) / this.__lifeSpan;
				particle.greenOffsetDelta = (this.__greenOffsetEnd - this.__greenOffsetStart) / this.__lifeSpan;
				particle.blueOffsetDelta = (this.__blueOffsetEnd - this.__blueOffsetStart) / this.__lifeSpan;
				particle.alphaOffsetDelta = (this.__alphaOffsetEnd - this.__alphaOffsetStart) / this.__nonFadeTime; // we only interpolate alpha after fade in and before fade out
			}
			else
			{
				particle.redOffsetBase = this.__redOffsetStart;
				particle.greenOffsetBase = this.__greenOffsetStart;
				particle.blueOffsetBase = this.__blueOffsetStart;
				particle.alphaOffsetBase = this._useFadeIn ? 0.0 : this.__alphaOffsetStart;
				
				particle.alphaOffsetStart = particle.alphaOffsetEnd = this.__alphaOffsetStart; // needed for fade in/out
			}
		}
		else
		{
			particle.redOffsetBase = particle.greenOffsetBase = particle.blueOffsetBase = particle.alphaOffsetBase = particle.alphaOffsetStart = particle.alphaOffsetEnd = 0.0;
		}
		
		if (!this._hasAnyColorOffset)
		{
			particle.redOffset = particle.redOffsetBase;
			particle.greenOffset = particle.greenOffsetBase;
			particle.blueOffset = particle.blueOffsetBase;
			particle.alphaOffset = particle.alphaOffsetBase;
		}
		
		particle.isFadingIn = this._useFadeIn;
		
		if (!this._isTypeRadial || !this.alignRadialRotation)
		{
			if (this.emitAngleAlignedRotation)
			{
				this.__rotationStart = this.__angle + this.emitAngleAlignedRotationOffset + this._rotationStart + this._rotationStartVariance * getRandomRatio();
				if (this._useRotation)
				{
					if (this.rotationEndRelativeToStart)
					{
						this.__rotationEnd = this.__rotationStart + this._rotationEnd + this._rotationEndVariance * getRandomRatio();
					}
					else
					{
						this.__rotationEnd = this.__angle + this._rotationEnd + this._rotationEndVariance * getRandomRatio();
					}
				}
			}
			else
			{
				this.__rotationStart = this._rotationStart + this._rotationStartVariance * getRandomRatio();
				if (this._rotationEndRelativeToStart)
				{
					this.__rotationEnd = this.__rotationStart + this._rotationEnd + this._rotationEndVariance * getRandomRatio();
				}
				else
				{
					this.__rotationEnd = this._rotationEnd + this._rotationEndVariance * getRandomRatio();
				}
			}
			
			if (this._useRotation) particle.rotationDelta = (this.__rotationEnd - this.__rotationStart) / this.__lifeSpan;
			
			particle.rotationBase = this.__rotationStart;
		}
		else
		{
			if (this._useRotation) particle.rotationDelta = 0.0;
		}
		
		if (this.randomStartFrame)
		{
			particle.frameIndex = MathUtils.floor(MathUtils.random() * particle.frameCount);
		}
		else
		{
			particle.frameIndex = 0;
		}
	}
	
	private var __restTime:Float;
	private var __distanceX:Float;
	private var __distanceY:Float;
	private var __distanceScalar:Float;
	private var __dragX:Float;
	private var __dragY:Float;
	private var __newY:Float;
	private var __radialX:Float;
	private var __radialY:Float;
	private var __refAngle:Float;
	private var __repellentDistanceX:Float;
	private var __repellentDistanceY:Float;
	private var __repellentDistanceScalar:Float;
	private var __repellentRadialX:Float;
	private var __repellentRadialY:Float;
	private var __step:Float;
	private var __tangentialX:Float;
	private var __tangentialY:Float;
	private var __velocityAngle:Float;
	private var __velocityAngleCalculated:Bool;
	private var __velocityScalar:Float;
	
	#if !debug inline #end private function advanceParticle(particle:T, passedTime:Float):Void
	{
		#if debug
		particle.updateCount++;
		#end
		
		this.__restTime = particle.timeTotal - particle.timeCurrent;
		passedTime = this.__restTime > passedTime ? passedTime : this.__restTime;
		particle.timeCurrent += passedTime;
		
		this.__velocityAngleCalculated = false;
		
		if (this._isTypeRadial)
		{
			// RADIAL
			particle.emitRotation += particle.emitRotationDelta * passedTime;
			particle.emitRadius += particle.emitRadiusDelta * passedTime;
			particle.xBase = this.emitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
			particle.yBase = this.emitterY - Math.sin(particle.emitRotation) * particle.emitRadius;
			
			if (this.alignRadialRotation)
			{
				particle.rotationBase = particle.emitRotation + particle.radialRotationOffset;
			}
		}
		else
		{
			// GRAVITY
			if (this._useRadialAcceleration || this._useTangentialAcceleration)
			{
				this.__distanceX = particle.x - particle.startX;
				this.__distanceY = particle.y - particle.startY;
				this.__distanceScalar = Math.sqrt(this.__distanceX * this.__distanceX + this.__distanceY * this.__distanceY);
				if (this.__distanceScalar < 0.01) this.__distanceScalar = 0.01;
				
				this.__radialX = this.__distanceX / this.__distanceScalar;
				this.__radialY = this.__distanceY / this.__distanceScalar;
				this.__tangentialX = this.__radialX;
				this.__tangentialY = this.__radialY;
				
				this.__radialX *= particle.radialAcceleration;
				this.__radialY *= particle.radialAcceleration;
				
				this.__newY = this.__tangentialX;
				this.__tangentialX = - this.__tangentialY * particle.tangentialAcceleration;
				this.__tangentialY = this.__newY * particle.tangentialAcceleration;
				
				particle.velocityX += passedTime * (this._gravityX + this.__radialX + this.__tangentialX);
				particle.velocityY += passedTime * (this._gravityY + this.__radialY + this.__tangentialY);
			}
			else if (this._useGravity)
			{
				particle.velocityX += passedTime * this._gravityX;
				particle.velocityY += passedTime * this._gravityY;
			}
			
			if (this._useRepellentForce)
			{
				this.__repellentDistanceX = particle.x - this.emitterX;
				this.__repellentDistanceY = particle.y - this.emitterY;
				this.__repellentDistanceScalar = Math.sqrt(this.__repellentDistanceX * this.__repellentDistanceX + this.__repellentDistanceY * this.__repellentDistanceY);
				if (this.__repellentDistanceScalar < 0.01) this.__repellentDistanceScalar = 0.01;
				
				this.__repellentRadialX = this.__repellentDistanceX / this.__repellentDistanceScalar * this._repellentForce;
				this.__repellentRadialY = this.__repellentDistanceY / this.__repellentDistanceScalar * this._repellentForce;
				
				particle.velocityX += passedTime * this.__repellentRadialX;
				particle.velocityY += passedTime * this.__repellentRadialY;
			}
			
			if (this._useDrag)
			{
				this.__dragX = particle.velocityX * particle.dragForce;
				this.__dragY = particle.velocityY * particle.dragForce;
				
				particle.velocityX -= passedTime * this.__dragX;
				particle.velocityY -= passedTime * this.__dragY;
			}
			
			particle.xBase += particle.velocityX * passedTime;
			particle.yBase += particle.velocityY * passedTime;
		}
		
		particle.x = particle.xBase;
		particle.y = particle.yBase;
		
		if (this.linkRotationToVelocity)
		{
			if (!this.__velocityAngleCalculated)
			{
				if (particle.velocityX == 0.0 && particle.velocityY == 0.0)
				{
					this.__velocityAngle = 0.0;
				}
				else
				{
					this.__velocityAngle = Math.atan2(particle.velocityY, particle.velocityX);
				}
				this.__velocityAngleCalculated = true;
			}
			particle.rotationBase = this.__velocityAngle + this.velocityRotationOffset;
		}
		else if (this._useRotation)
		{
			particle.rotationBase += particle.rotationDelta * passedTime;
		}
		
		// OSCILLATION
		if (this._rotationOscillationEnabled)
		{
			if (this._rotationOscillationGlobalFrequencyEnabled)
			{
				if (this.rotationOscillationFrequencyInverted)
				{
					particle.rotationOscillation = this._oscillationGlobalValueInverted * particle.rotationOscillationAngle;
				}
				else
				{
					particle.rotationOscillation = this._oscillationGlobalValue * particle.rotationOscillationAngle;
				}
			}
			else if (this._rotationOscillationGroupFrequencyEnabled)
			{
				particle.rotationOscillation = this._rotationOscillationGroupValue * particle.rotationOscillationAngle;
			}
			else
			{
				particle.rotationOscillationStep += particle.rotationOscillationFrequency * passedTime;
				if (this.rotationOscillationFrequencyInverted)
				{
					particle.rotationOscillation = Math.sin(particle.rotationOscillationStep) * particle.rotationOscillationAngle;
				}
				else
				{
					particle.rotationOscillation = Math.cos(particle.rotationOscillationStep) * particle.rotationOscillationAngle;
				}
			}
		}
		
		if (this._positionOscillationEnabled)
		{
			if (this._positionOscillationAngleRelativeToRotation)
			{
				this.__refAngle = particle.rotation;
			}
			else if (this._positionOscillationAngleRelativeToVelocity)
			{
				if (!this.__velocityAngleCalculated)
				{
					if (particle.velocityX == 0.0 && particle.velocityY == 0.0)
					{
						this.__velocityAngle = 0.0;
					}
					else
					{
						this.__velocityAngle = Math.atan2(particle.velocityY, particle.velocityX);
					}
					this.__velocityAngleCalculated = true;
				}
				this.__refAngle = this.__velocityAngle;
			}
			else
			{
				this.__refAngle = 0.0;
			}
			
			if (this._positionOscillationGlobalFrequencyEnabled)
			{
				if (this.oscillationPositionFrequencyInverted)
				{
					this.__radius = this._oscillationGlobalValueInverted * particle.positionOscillationRadius;
				}
				else
				{
					this.__radius = this._oscillationGlobalValue * particle.positionOscillationRadius;
				}
			}
			else if (this._positionOscillationGroupFrequencyEnabled)
			{
				this.__radius = this._positionOscillationGroupValue * particle.positionOscillationRadius;
			}
			else
			{
				particle.positionOscillationStep += particle.positionOscillationFrequency * passedTime;
				if (this.oscillationPositionFrequencyInverted)
				{
					this.__radius = Math.sin(particle.positionOscillationStep) * particle.positionOscillationRadius;
				}
				else
				{
					this.__radius = Math.cos(particle.positionOscillationStep) * particle.positionOscillationRadius;
				}
			}
			this.__angle = this.__refAngle + particle.positionOscillationAngle;
			particle.positionXOscillation = Math.cos(this.__angle) * this.__radius;
			particle.positionYOscillation = Math.sin(this.__angle) * this.__radius;
			
			particle.x += particle.positionXOscillation;
			particle.y += particle.positionYOscillation;
		}
		
		if (this._position2OscillationEnabled)
		{
			if (this._position2OscillationAngleRelativeToRotation)
			{
				this.__refAngle = particle.rotation;
			}
			else if (this._position2OscillationAngleRelativeToVelocity)
			{
				if (!this.__velocityAngleCalculated)
				{
					if (particle.velocityX == 0.0 && particle.velocityY == 0.0)
					{
						this.__velocityAngle = 0.0;
					}
					else
					{
						this.__velocityAngle = Math.atan2(particle.velocityY, particle.velocityX);
					}
					this.__velocityAngleCalculated = true;
				}
				this.__refAngle = this.__velocityAngle;
			}
			else
			{
				this.__refAngle = 0.0;
			}
			
			if (this._position2OscillationGlobalFrequencyEnabled)
			{
				if (this.position2OscillationFrequencyInverted)
				{
					this.__radius = this._oscillationGlobalValueInverted * particle.position2OscillationRadius;
				}
				else
				{
					this.__radius = this._oscillationGlobalValue * particle.position2OscillationRadius;
				}
			}
			else if (this._position2OscillationGroupFrequencyEnabled)
			{
				this.__radius = this._position2OscillationGroupValue * particle.position2OscillationRadius;
			}
			else
			{
				particle.position2OscillationStep += particle.position2OscillationFrequency * passedTime;
				if (this.position2OscillationFrequencyInverted)
				{
					this.__radius = Math.sin(particle.position2OscillationStep) * particle.position2OscillationRadius;
				}
				else
				{
					this.__radius = Math.cos(particle.position2OscillationStep) * particle.position2OscillationRadius;
				}
			}
			this.__angle = this.__refAngle + particle.position2OscillationAngle;
			particle.position2XOscillation = Math.cos(this.__angle) * this.__radius;
			particle.position2YOscillation = Math.sin(this.__angle) * this.__radius;
			
			particle.x += particle.position2XOscillation;
			particle.y += particle.position2YOscillation;
		}
		
		if (this.useDisplayRect)
		{
			if (!this.displayRect.contains(particle.x, particle.y))
			{
				particle.timeCurrent = particle.timeTotal; // "destroy" particle
				particle.visible = false;
				//return;
			}
		}
		
		if (this._scaleXOscillationEnabled)
		{
			if (this._scaleXOscillationGlobalFrequencyEnabled)
			{
				if (this.scaleXOscillationFrequencyInverted)
				{
					particle.scaleXOscillation = 1.0 + this._oscillationGlobalValueInverted * particle.scaleXOscillationFactor;
				}
				else
				{
					particle.scaleXOscillation = 1.0 + this._oscillationGlobalValue * particle.scaleXOscillationFactor;
				}
			}
			else if (this._scaleXOscillationGroupFrequencyEnabled)
			{
				particle.scaleXOscillation = 1.0 + this._scaleXOscillationGroupValue * particle.scaleXOscillationFactor;
			}
			else
			{
				particle.scaleXOscillationStep += particle.scaleXOscillationFrequency * passedTime;
				if (this.scaleXOscillationFrequencyInverted)
				{
					particle.scaleXOscillation = 1.0 + Math.sin(particle.scaleXOscillationStep) * particle.scaleXOscillationFactor;
				}
				else
				{
					particle.scaleXOscillation = 1.0 + Math.cos(particle.scaleXOscillationStep) * particle.scaleXOscillationFactor;
				}
			}
		}
		
		if (this._scaleYOscillationEnabled)
		{
			if (this._scaleYOscillationGlobalFrequencyEnabled)
			{
				if (this.scaleYOscillationFrequencyInverted)
				{
					particle.scaleYOscillation = 1.0 + this._oscillationGlobalValueInverted * particle.scaleYOscillationFactor;
				}
				else
				{
					particle.scaleYOscillation = 1.0 + this._oscillationGlobalValue * particle.scaleYOscillationFactor;
				}
			}
			else if (this._scaleYOscillationGroupFrequencyEnabled)
			{
				particle.scaleYOscillation = 1.0 + this._scaleYOscillationGroupValue * particle.scaleYOscillationFactor;
			}
			else
			{
				particle.scaleYOscillationStep += particle.scaleYOscillationFrequency * passedTime;
				if (this.scaleYOscillationFrequencyInverted)
				{
					particle.scaleYOscillation = 1.0 + Math.sin(particle.scaleYOscillationStep) * particle.scaleYOscillationFactor;
				}
				else
				{
					particle.scaleYOscillation = 1.0 + Math.cos(particle.scaleYOscillationStep) * particle.scaleYOscillationFactor;
				}
			}
		}
		
		if (this._skewXOscillationEnabled)
		{
			if (this._skewXOscillationGlobalFrequencyEnabled)
			{
				if (this.skewXOscillationFrequencyInverted)
				{
					particle.skewXOscillation = this._oscillationGlobalValueInverted * particle.skewXOscillationFactor;
				}
				else
				{
					particle.skewXOscillation = this._oscillationGlobalValue * particle.skewXOscillationFactor;
				}
			}
			else if (this._skewXOscillationGroupFrequencyEnabled)
			{
				particle.skewXOscillation = this._skewXOscillationGroupValue * particle.skewXOscillationFactor;
			}
			else
			{
				particle.skewXOscillationStep += particle.skewXOscillationFrequency * passedTime;
				if (this.skewXOscillationFrequencyInverted)
				{
					particle.skewXOscillation = Math.sin(particle.skewXOscillationStep) * particle.skewXOscillationFactor;
				}
				else
				{
					particle.skewXOscillation = Math.cos(particle.skewXOscillationStep) * particle.skewXOscillationFactor;
				}
			}
		}
		
		if (this._skewYOscillationEnabled)
		{
			if (this._skewYOscillationGlobalFrequencyEnabled)
			{
				if (this.skewYOscillationFrequencyInverted)
				{
					particle.skewYOscillation = this._oscillationGlobalValueInverted * particle.skewYOscillationFactor;
				}
				else
				{
					particle.skewYOscillation = this._oscillationGlobalValue * particle.skewYOscillationFactor;
				}
			}
			else if (this._skewYOscillationGroupFrequencyEnabled)
			{
				particle.skewYOscillation = this._skewYOscillationGroupValue * particle.skewYOscillationFactor;
			}
			else
			{
				particle.skewYOscillationStep += particle.skewYOscillationFrequency * passedTime;
				if (this.skewYOscillationFrequencyInverted)
				{
					particle.skewYOscillation = Math.sin(particle.skewYOscillationStep) * particle.skewYOscillationFactor;
				}
				else
				{
					particle.skewYOscillation = Math.cos(particle.skewYOscillationStep) * particle.skewYOscillationFactor;
				}
			}
		}
		//\OSCILLATION
		
		if (this._hasAnyVelocityEffect)
		{
			this.__velocityScalar = Math.sqrt(particle.velocityX * particle.velocityX + particle.velocityY * particle.velocityY);
			if (this._useVelocityRotation)
			{
				particle.rotationVelocity = this.__velocityScalar * this._velocityRotationFactor;
			}
			if (this._useVelocityScaleX)
			{
				particle.scaleXVelocity = 1.0 + (this.__velocityScalar * this._velocityScaleFactorX);
			}
			if (this._useVelocityScaleY)
			{
				particle.scaleYVelocity = 1.0 + (this.__velocityScalar * this._velocityScaleFactorY);
			}
			if (this._useVelocitySkewX)
			{
				particle.skewXVelocity = this.__velocityScalar * this._velocitySkewFactorX;
			}
			if (this._useVelocitySkewY)
			{
				particle.skewYVelocity = this.__velocityScalar * this._velocitySkewFactorY;
			}
		}
		
		particle.rotation = particle.rotationBase + particle.rotationVelocity + particle.rotationOscillation;
		
		if (this._useSkewX)
		{
			particle.skewXBase += particle.skewXDelta * passedTime;
		}
		
		if (this._useSkewY)
		{
			particle.skewYBase += particle.skewYDelta * passedTime;
		}
		
		particle.skewX = particle.skewXBase + particle.skewXOscillation + particle.skewXVelocity;
		particle.skewY = particle.skewYBase + particle.skewYOscillation + particle.skewYVelocity;
		
		if (this._useSizeX)	particle.scaleXBase += particle.scaleXDelta * passedTime;
		if (this._useSizeY) particle.scaleYBase += particle.scaleYDelta * passedTime;
		particle.scaleX = particle.scaleXBase * particle.scaleXVelocity * particle.scaleXOscillation;
		particle.scaleY = particle.scaleYBase * particle.scaleYVelocity * particle.scaleYOscillation;
		
		if (this._useColor)
		{
			particle.redBase += particle.redDelta * passedTime;
			particle.greenBase += particle.greenDelta * passedTime;
			particle.blueBase += particle.blueDelta * passedTime;
		}
		
		if (this._useColorOffset)
		{
			particle.redOffsetBase += particle.redOffsetDelta * passedTime;
			particle.greenOffsetBase += particle.greenOffsetDelta * passedTime;
			particle.blueOffsetBase += particle.blueOffsetDelta * passedTime;
		}
		
		if (this._useFadeInOut)
		{
			if (this._useFadeIn && particle.timeCurrent <= particle.fadeInTime)
			{
				if (this._hasAnyColor)
				{
					particle.alphaBase = particle.alphaStart * (particle.timeCurrent / particle.fadeInTime);
				}
				else
				{
					particle.alpha = particle.alphaStart * (particle.timeCurrent / particle.fadeInTime);
				}
				if (this._hasAnyColorOffset)
				{
					particle.alphaOffsetBase = particle.alphaOffsetStart * (particle.timeCurrent / particle.fadeInTime);
				}
				else if (this._hasColorOffset)
				{
					particle.alphaOffset = particle.alphaOffsetStart * (particle.timeCurrent / particle.fadeInTime);
				}
			}
			else if (this._useFadeOut && particle.timeCurrent >= particle.fadeOutTime)
			{
				if (this._hasAnyColor)
				{
					particle.alphaBase = particle.alphaEnd * (1.0 - (particle.timeCurrent - particle.fadeOutTime) / particle.fadeOutDuration);
				}
				else
				{
					particle.alpha = particle.alphaEnd * (1.0 - (particle.timeCurrent - particle.fadeOutTime) / particle.fadeOutDuration);
				}
				if (this._hasAnyColorOffset)
				{
					particle.alphaOffsetBase = particle.alphaOffsetEnd * (1.0 - (particle.timeCurrent - particle.fadeOutTime) / particle.fadeOutDuration);
				}
				else if (this._hasColorOffset)
				{
					particle.alphaOffset = particle.alphaOffsetEnd * (1.0 - (particle.timeCurrent - particle.fadeOutTime) / particle.fadeOutDuration);
				}
			}
			else
			{
				if (particle.isFadingIn)
				{
					if (this._hasAnyColor)
					{
						particle.alphaBase = particle.alphaStart;
					}
					else
					{
						particle.alpha = particle.alphaStart;
					}
					if (this._hasAnyColorOffset)
					{
						particle.alphaOffsetBase = particle.alphaOffsetStart;
					}
					else
					{
						particle.alphaOffset = particle.alphaOffsetStart;
					}
					particle.isFadingIn = false;
				}
				if (this._useColor) particle.alphaBase += particle.alphaDelta * passedTime;
				if (this._useColorOffset) particle.alphaOffsetBase += particle.alphaOffsetDelta * passedTime;
			}
		}
		else
		{
			if (this._useColor) particle.alphaBase += particle.alphaDelta * passedTime;
			if (this._useColorOffset) particle.alphaOffsetBase += particle.alphaOffsetDelta * passedTime;
		}
		
		// OSCILLATION COLOR
		if (this._useColorOscillation)
		{
			if (this._colorOscillationGlobalFrequencyEnabled)
			{
				if (this.colorOscillationFrequencyInverted)
				{
					this.__step = this._oscillationGlobalValueInverted;
				}
				else
				{
					this.__step = this._oscillationGlobalValue;
				}
			}
			else if (this._colorOscillationGroupFrequencyEnabled)
			{
				this.__step = this._colorOscillationGroupValue;
			}
			else
			{
				particle.colorOscillationStep += particle.colorOscillationFrequency * passedTime;
				if (this.colorOscillationFrequencyInverted)
				{
					this.__step = Math.sin(particle.colorOscillationStep);
				}
				else
				{
					this.__step = Math.cos(particle.colorOscillationStep);
				}
			}
			
			particle.redOscillation = particle.redOscillationFactor * this.__step;
			particle.greenOscillation = particle.greenOscillationFactor * this.__step;
			particle.blueOscillation = particle.blueOscillationFactor * this.__step;
			particle.alphaOscillation = particle.alphaOscillationFactor * this.__step;
		}
		//\OSCILLATION COLOR
		
		// OSCILLATION COLOR OFFSET
		if (this._useColorOffsetOscillation)
		{
			if (this._colorOffsetOscillationGlobalFrequencyEnabled)
			{
				if (this.colorOffsetOscillationFrequencyInverted)
				{
					this.__step = this._oscillationGlobalValueInverted;
				}
				else
				{
					this.__step = this._oscillationGlobalValue;
				}
			}
			else if (this._colorOffsetOscillationGroupFrequencyEnabled)
			{
				this.__step = this._colorOffsetOscillationGroupValue;
			}
			else
			{
				particle.colorOffsetOscillationStep += particle.colorOffsetOscillationFrequency * passedTime;
				if (this.colorOffsetOscillationFrequencyInverted)
				{
					this.__step = Math.sin(particle.colorOffsetOscillationStep);
				}
				else
				{
					this.__step = Math.cos(particle.colorOffsetOscillationStep);
				}
			}
			
			particle.redOffsetOscillation = particle.redOffsetOscillationFactor * this.__step;
			particle.greenOffsetOscillation = particle.greenOffsetOscillationFactor * this.__step;
			particle.blueOffsetOscillation = particle.blueOffsetOscillationFactor * this.__step;
			particle.alphaOffsetOscillation = particle.alphaOffsetOscillationFactor * this.__step;
		}
		//\OSCILLATION COLOR OFFSET
		
		if (this._hasAnyColor)
		{
			particle.red = particle.redBase + particle.redOscillation;
			particle.green = particle.greenBase + particle.greenOscillation;
			particle.blue = particle.blueBase + particle.blueOscillation;
			particle.alpha = particle.alphaBase + particle.alphaOscillation;
		}
		
		if (this._hasAnyColorOffset)
		{
			particle.redOffset = particle.redOffsetBase + particle.redOffsetOscillation;
			particle.greenOffset = particle.greenOffsetBase + particle.greenOffsetOscillation;
			particle.blueOffset = particle.blueOffsetBase + particle.blueOffsetOscillation;
			particle.alphaOffset = particle.alphaOffsetBase + particle.alphaOffsetOscillation;
		}
	}
	
	override public function advanceTime(time:Float):Void 
	{
		var sortFlag:Bool = this.forceSortFlag;
		
		if (this._updateEmitter)
		{
			#if !cpp // TODO : fix bug when building for cpp
			this._emitterObject.advanceSystem(this, time);
			#end
		}
		
		if (this._useOscillationGlobalFrequency)
		{
			this._oscillationGlobalStep += this.oscillationGlobalFrequency * time;
			this._oscillationGlobalValue = Math.cos(this._oscillationGlobalStep);
			this._oscillationGlobalValueInverted = Math.sin(this._oscillationGlobalStep);
		}
		
		if (this._positionOscillationEnabled && this._positionOscillationGroupFrequencyEnabled)
		{
			this._positionOscillationGroupStep += this.positionOscillationFrequency * time;
			if (this.oscillationPositionFrequencyInverted)
			{
				this._positionOscillationGroupValue = Math.sin(this._positionOscillationGroupStep);
			}
			else
			{
				this._positionOscillationGroupValue = Math.cos(this._positionOscillationGroupStep);
			}
		}
		
		if (this._position2OscillationEnabled && this._position2OscillationGroupFrequencyEnabled)
		{
			this._position2OscillationGroupStep += this.position2OscillationFrequency * time;
			if (this.position2OscillationFrequencyInverted)
			{
				this._position2OscillationGroupValue = Math.sin(this._position2OscillationGroupStep);
			}
			else
			{
				this._position2OscillationGroupValue = Math.cos(this._position2OscillationGroupStep);
			}
		}
		
		if (this._rotationOscillationEnabled && this._rotationOscillationGroupFrequencyEnabled)
		{
			this._rotationOscillationGroupStep += this.rotationOscillationFrequency * time;
			if (this.rotationOscillationFrequencyInverted)
			{
				this._rotationOscillationGroupValue = Math.sin(this._rotationOscillationGroupStep);
			}
			else
			{
				this._rotationOscillationGroupValue = Math.cos(this._rotationOscillationGroupStep);
			}
		}
		
		if (this._scaleXOscillationEnabled && this._scaleXOscillationGroupFrequencyEnabled)
		{
			this._scaleXOscillationGroupStep += this.scaleXOscillationFrequency * time;
			if (this.scaleXOscillationFrequencyInverted)
			{
				this._scaleXOscillationGroupValue = Math.sin(this._scaleXOscillationGroupStep);
			}
			else
			{
				this._scaleXOscillationGroupValue = Math.cos(this._scaleXOscillationGroupStep);
			}
		}
		
		if (this._scaleYOscillationEnabled && this._scaleYOscillationGroupFrequencyEnabled)
		{
			this._scaleYOscillationGroupStep += this.scaleYOscillationFrequency * time;
			if (this.scaleYOscillationFrequencyInverted)
			{
				this._scaleYOscillationGroupValue = Math.sin(this._scaleYOscillationGroupStep);
			}
			else
			{
				this._scaleYOscillationGroupValue = Math.cos(this._scaleYOscillationGroupStep);
			}
		}
		
		if (this._skewXOscillationEnabled && this._skewXOscillationGroupFrequencyEnabled)
		{
			this._skewXOscillationGroupStep += this.skewXOscillationFrequency * time;
			if (this.skewXOscillationFrequencyInverted)
			{
				this._skewXOscillationGroupValue = Math.sin(this._skewXOscillationGroupStep);
			}
			else
			{
				this._skewXOscillationGroupValue = Math.cos(this._skewXOscillationGroupStep);
			}
		}
		
		if (this._skewYOscillationEnabled && this._skewYOscillationGroupFrequencyEnabled)
		{
			this._skewYOscillationGroupStep += this.skewYOscillationFrequency * time;
			if (this.skewYOscillationFrequencyInverted)
			{
				this._skewYOscillationGroupValue = Math.sin(this._skewYOscillationGroupStep);
			}
			else
			{
				this._skewYOscillationGroupValue = Math.cos(this._skewYOscillationGroupStep);
			}
		}
		
		if (this._useColorOscillation && this._colorOscillationGroupFrequencyEnabled)
		{
			this._colorOscillationGroupStep += this.colorOscillationFrequency * time;
			if (this.colorOscillationFrequencyInverted)
			{
				this._colorOscillationGroupValue = Math.sin(this._colorOscillationGroupStep);
			}
			else
			{
				this._colorOscillationGroupValue = Math.cos(this._colorOscillationGroupStep);
			}
		}
		
		if (this._useColorOffsetOscillation && this._colorOffsetOscillationGroupFrequencyEnabled)
		{
			this._colorOffsetOscillationGroupStep += this.colorOffsetOscillationFrequency * time;
			if (this.colorOffsetOscillationFrequencyInverted)
			{
				this._colorOffsetOscillationGroupValue = Math.sin(this._colorOffsetOscillationGroupStep);
			}
			else
			{
				this._colorOffsetOscillationGroupValue = Math.cos(this._colorOffsetOscillationGroupStep);
			}
		}
		
		var particleIndex:Int = 0;
		var currentIndex:Int = 0;
		var particle:T;
		
		// advance existing particles
		if (this._regularSorting)
		{
			while (particleIndex < this._numParticles)
			{
				particle = this._particles[particleIndex];
				if (particle != null)
				{
					if (particle.timeCurrent < particle.timeTotal)
					{
						if (currentIndex != particleIndex)
						{
							this._particles[particleIndex] = null;
							this._particles[currentIndex] = particle;
						}
						
						advanceParticle(particle, time);
						++currentIndex;
					}
					else
					{
						particle.visible = false;
						this._particles[this._particles.length] = particle;
						this._particles[particleIndex] = null;
					}
				}
				++particleIndex;
			}
			this._numParticles = currentIndex;
			
			if (particleIndex != currentIndex)
			{
				var count:Int = this._particles.length;
				for (particleIndex in particleIndex...count)
				{
					particle = this._particles[particleIndex];
					if (particle != null)
					{
						this._particles[particleIndex] = null;
						this._particles[currentIndex] = particle;
						++currentIndex;
					}
				}
				#if flash
				this._particles.length = this._maxNumParticles;
				#else
				this._particles.resize(this._maxNumParticles);
				#end
			}
		}
		else
		{
			while (particleIndex < this._numParticles)
			{
				particle = this._particles[particleIndex];
				
				if (particle.timeCurrent < particle.timeTotal)
				{
					advanceParticle(particle, time);
					++particleIndex;
				}
				else
				{
					particle.visible = false;
					if (particleIndex != --this._numParticles)
					{
						var nextParticle:T = this._particles[this._numParticles];
						this._particles[this._numParticles] = particle;
						this._particles[particleIndex] = nextParticle;
						sortFlag = true;
					}
					
					if (this._numParticles == 0 && this._emissionTime < 0)
					{
						stop(this.autoClearOnComplete);
						complete();
						break;
					}
				}
			}
		}
		
		// create and advance new particles
		if (this._emissionEnabled)
		{
			this._frameTime += time;
			
			var maxParticles:Int;
			if (this._isModeBurst)
			{
				if (this._burstsInstant)
				{
					if (this._frameTime >= this._nextBurstTime)
					{
						maxParticles = this._particleAmountEnabled ? MathUtils.minInt(this._numParticles + (this.particleAmount - this._particleTotal), this._maxNumParticles) : this._maxNumParticles;
						maxParticles = MathUtils.minInt(maxParticles, this._numParticles + Math.floor(this._emissionRate));
						
						while (this._numParticles < maxParticles)
						{
							particle = this._particles[this._numParticles];
							initParticle(particle);
							
							++this._numParticles;
							++this._particleTotal;
						}
						
						++this._burstTotal;
						this._burstRemaining = this._burstsInfinite || this._burstTotal < this._numBursts;
						if (this._burstRemaining)
						{
							this._nextBurstTime = this._burstInterval + this.burstIntervalVariance * getRandomRatio();
							this._frameTime = 0.0;
						}
						else
						{
							this._emissionEnabled = false;
						}
					}
				}
				else
				{
					if (!this._burstInProgress && this._burstRemaining && this._frameTime >= this._nextBurstTime)// && (this._emissionInfinite || this._particleTotal < this.particleAmount))
					{
						this._burstInProgress = true;
						this._burstTime = this._burstDuration;
					}
					
					if (this._burstInProgress)
					{
						this._frameTime = Math.min(time, this._burstTime);
						this._burstTime -= this._frameTime;
						maxParticles = this._particleAmountEnabled ? MathUtils.minInt(this._numParticles + (this._particleAmount - this._particleTotal), this._maxNumParticles) : this._maxNumParticles;
						
						while (this._frameTime > 0.0 && this._numParticles < maxParticles)
						{
							particle = this._particles[this._numParticles];
							initParticle(particle);
							
							++this._numParticles;
							++this._particleTotal;
							
							this._frameTime -= this._timeBetweenParticles;
						}
						this._burstTime += this._frameTime;
						
						if (this._burstTime <= 0.0)
						{
							this._burstInProgress = false;
							++this._burstTotal;
							this._burstRemaining = this._burstsInfinite || this._burstTotal < this._numBursts;
							if (this._burstRemaining)
							{
								this._nextBurstTime = this._burstInterval + this.burstIntervalVariance * getRandomRatio();
							}
							else
							{
								this._emissionEnabled = false;
							}
						}
					}
				}
			}
			else
			{
				maxParticles = this.particleAmount == 0 ? this._maxNumParticles : MathUtils.minInt(this._numParticles + (this.particleAmount - this._particleTotal), this._maxNumParticles);
				
				while (this._frameTime > 0.0 && this._numParticles < maxParticles)
				{
					particle = this._particles[this._numParticles];
					initParticle(particle);
					advanceParticle(particle, this._frameTime);
					
					++this._numParticles;
					++this._particleTotal;
					
					this._frameTime -= this._timeBetweenParticles;
				}
			}
			
			if (!this._emissionInfinite)
			{
				this._emissionTime -= time;
				if (this._emissionTime <= 0.0)
				{
					this._emissionEnabled = false;
				}
			}
		}
		else if (!this._completed && this._numParticles == 0)
		{
			stop(this.autoClearOnComplete);
			complete();
			return;
		}
		
		
		this.numDatas = this._numParticles;
		
		if (this.customFunction != null)
		{
			customFunction(this._particles, this._numParticles);
		}
		
		if (sortFlag && this.sortFunction != null)
		{
			this._particles.sort(this.sortFunction);
		}
		
		super.advanceTime(time);
	}
	
	public function updateEmissionRate():Void
	{
		var lifeSpan:Float;
		var timingsCount:Int;
		if (this._isModeBurst)
		{
			if (this._numBursts == 0)
			{
				if (this._useAnimationLifeSpan)
				{
					lifeSpan = 0.0;
					timingsCount = this._frameTimings.length;
					for (i in 0...timingsCount)
					{
						lifeSpan += this._frameTimings[i][this._frameTimings[i].length - 1] / this._frameDelta;
					}
					lifeSpan /= timingsCount;
				}
				else
				{
					lifeSpan = this._lifeSpan;
				}
				var burstTime:Float = this._burstInterval + this._burstDuration;
				if (burstTime <= 0) burstTime = 0.02;
				var numBursts:Float = lifeSpan / burstTime + 1.0;
				
				if (this._burstsInstant)
				{
					this.emissionRate = this._maxNumParticles * this._emissionRatio / numBursts;
				}
				else
				{
					this.emissionRate = (this._maxNumParticles * this._emissionRatio / numBursts) / this._burstDuration;
				}
			}
			else
			{
				if (this._burstsInstant)
				{
					this.emissionRate = this._maxNumParticles * this._emissionRatio / (this._numBursts + 1);
				}
				else
				{
					this.emissionRate = (this._maxNumParticles * this._emissionRatio / (this._numBursts + 1)) / this._burstDuration;
				}
			}
		}
		else
		{
			if (this._useAnimationLifeSpan)
			{
				lifeSpan = 0.0;
				timingsCount = this._frameTimings.length;
				for (i in 0...timingsCount)
				{
					lifeSpan += this._frameTimings[i][this._frameTimings[i].length - 1] / this._frameDelta;
				}
				lifeSpan /= timingsCount;
				this.emissionRate = this._maxNumParticles * this._emissionRatio / lifeSpan;
			}
			else
			{
				this.emissionRate = this._maxNumParticles * this._emissionRatio / this._lifeSpan;
			}
		}
	}
	
	public function start(duration:Float = 0.0):Void
	{
		if (this._completed)
		{
			reset();
		}
		
		if ((this._isModeBurst || this._emissionRate != 0.0))
		{
			if (this._isParticlePoolUpdatePending)
			{
				getParticlesFromPool();
			}
			if (duration == 0.0)
			{
				duration = this._emissionTimePredefined;
			}
			else if (duration < 0.0)
			{
				duration = MathUtils.FLOAT_MAX;
			}
			
			this._emissionEnabled = true;
			this._emissionTime = duration;
			this._emissionInfinite = this._emissionTime == MathUtils.FLOAT_MAX;
			this._isPlaying = true;
			
			this._oscillationGlobalStep = 0.0;
			this._positionOscillationGroupStep = this.positionOscillationGroupStartStep;
			this._position2OscillationGroupStep = this.position2OscillationGroupStartStep;
			this._rotationOscillationGroupStep = this.rotationOscillationGroupStartStep;
			this._scaleXOscillationGroupStep = this.scaleXOscillationGroupStartStep;
			this._scaleYOscillationGroupStep = this.scaleYOscillationGroupStartStep;
			this._skewXOscillationGroupStep = this.skewXOscillationGroupStartStep;
			this._skewYOscillationGroupStep = this.skewYOscillationGroupStartStep;
			this._colorOscillationGroupStep = this.colorOscillationGroupStartStep;
			this._colorOffsetOscillationGroupStep = this.colorOffsetOscillationGroupStartStep;
		}
	}
	
	public function  stop(clear:Bool = false):Void
	{
		//this._emissionTime = 0.0;
		this._emissionEnabled = false;
		
		if (clear)
		{
			for (i in 0...this._numParticles)
			{
				this._particles[i].visible = false;
			}
			this._numParticles = 0;
			this._isPlaying = false;
			dispatchEventWith(Event.CANCEL);
		}
	}
	
	public function resume():Void
	{
		this._isPlaying = true;
	}
	
	public function reset():Void
	{
		if (this._isModeStream && this._autoSetEmissionRate) 
		{
			updateEmissionRate();
		}
		this._frameTime = 0.0;
		this._isPlaying = false;
		this._burstInProgress = false;
		this._particleTotal = 0;
		this._burstTotal = 0;
		this._burstRemaining = true;
		this._nextBurstTime = 0.0;
		
		this._completed = false;
		if (this._particles.length == 0)
		{
			getParticlesFromPool();
		}
	}
	
	private function complete():Void
	{
		if (!this._completed)
		{
			this._completed = true;
			dispatchEventWith(Event.COMPLETE);
		}
	}
	
	private function getParticlesFromPool():Void
	{
		if (this._particles.length != 0)
		{
			return;
		}
		
		if (this.particlesFromPoolFunction != null)
		{
			particlesFromPoolFunction(this._maxNumParticles, this._particles);
		}
		else
		{
			throw new Error("ParticleSystem.getParticlesFromPool ::: null particlesFromPoolFunction");
		}
		
		if (this._useMultipleFrameSets)
		{
			var r:Int;
			for (i in 0...this._maxNumParticles)
			{
				r = MathUtils.floor(MathUtils.random() * this._numFrameSets);
				this._particles[i].setFrames(this._frames[r], this._frameTimings[r], this._loopAnimation, this._animationLoops);
			}
		}
		else
		{
			for (i in 0...this._maxNumParticles)
			{
				this._particles[i].setFrames(this._frames[0], this._frameTimings[0], this._loopAnimation, this._animationLoops);
			}
		}
		
		this._isParticlePoolUpdatePending = false;
	}
	
	private function returnParticlesToPool():Void
	{
		this._numParticles = this.numDatas = 0;
		
		if (this._particles != null)
		{
			if (this.particlesToPoolFunction != null)
			{
				this.particlesToPoolFunction(this._particles);
			}
			else
			{
				var count:Int = this._particles.length;
				for (i in 0...count)
				{
					this._particles[i].pool();
				}
			}
			#if flash
			this._particles.length = 0;
			#else
			this._particles.resize(0);
			#end
		}
	}
	
	public function readSystemOptions(options:ParticleSystemOptions):Void
	{
		this._autoSetEmissionRate = false; // avoid multiple useless updateEmissionRate() calls
		
		// Emitter
		this.emitterType = options.emitterType;
		this.emitterMode = options.emitterMode;
		
		this._maxNumParticles = options.maxNumParticles;
		
		this.particleAmount = options.particleAmount;
		
		this.numBursts = options.numBursts;
		this.burstDuration = options.burstDuration;
		this.burstInterval = options.burstInterval;
		this.burstIntervalVariance = options.burstIntervalVariance;
		
		this.emissionRate = options.emissionRate;
		this._emissionRatio = options.emissionRatio;
		this._autoSetEmissionRate = options.autoSetEmissionRate;
		
		this.emitterX = options.emitterX;
		this.emitterY = options.emitterY;
		this.emitterXVariance = options.emitterXVariance;
		this.emitterYVariance = options.emitterYVariance;
		
		this.emitterRadiusMax = options.emitterRadiusMax;
		this.emitterRadiusMaxVariance = options.emitterRadiusMaxVariance;
		this.emitterRadiusMin = options.emitterRadiusMin;
		this.emitterRadiusMinVariance = options.emitterRadiusMinVariance;
		this.emitterRadiusOverridesParticleAngle = options.emitterRadiusOverridesParticleAngle;
		this.emitterRadiusParticleAngleOffset = options.emitterRadiusParticleAngleOffset;
		this.emitterRadiusParticleAngleOffsetVariance = options.emitterRadiusParticleAngleOffsetVariance;
		
		this.emitAngle = options.emitAngle;
		this.emitAngleVariance = options.emitAngleVariance;
		this.emitAngleAlignedRotation = options.emitAngleAlignedRotation;
		this.emitAngleAlignedRotationOffset = options.emitAngleAlignedRotationOffset;
		
		this._emissionTimePredefined = options.duration;
		this._emissionTimePredefined = this._emissionTimePredefined < 0 ? MathUtils.FLOAT_MAX : this._emissionTimePredefined;
		
		this.useDisplayRect = options.useDisplayRect;
		this.displayRect.copyFrom(options.displayRect);
		//\Emitter
		
		// Particle
		this.useAnimationLifeSpan = options.useAnimationLifeSpan;
		this._lifeSpan = options.lifeSpan;
		this.lifeSpanVariance = options.lifeSpanVariance;
		
		this.fadeInTime = options.fadeInTime;
		this.fadeOutTime = options.fadeOutTime;
		
		this.sizeXStart = options.sizeXStart;
		this.sizeYStart = options.sizeYStart;
		this.sizeXStartVariance = options.sizeXStartVariance;
		this.sizeYStartVariance = options.sizeYStartVariance;
		
		this.sizeXEnd = options.sizeXEnd;
		this.sizeYEnd = options.sizeYEnd;
		this.sizeXEndVariance = options.sizeXEndVariance;
		this.sizeYEndVariance = options.sizeYEndVariance;
		this.sizeXEndRelativeToStart = options.sizeXEndRelativeToStart;
		this.sizeYEndRelativeToStart = options.sizeYEndRelativeToStart;
		
		this.rotationStart = options.rotationStart;
		this.rotationStartVariance = options.rotationStartVariance;
		this.rotationEnd = options.rotationEnd;
		this.rotationEndVariance = options.rotationEndVariance;
		this.rotationEndRelativeToStart = options.rotationEndRelativeToStart;
		
		this.skewXStart = options.skewXStart;
		this.skewXStartVariance = options.skewXStartVariance;
		this.skewYStart = options.skewYStart;
		this.skewYStartVariance = options.skewYStartVariance;
		
		this.skewXEnd = options.skewXEnd;
		this.skewXEndVariance = options.skewXEndVariance;
		this.skewYEnd = options.skewYEnd;
		this.skewYEndVariance = options.skewYEndVariance;
		this.skewXEndRelativeToStart = options.skewXEndRelativeToStart;
		this.skewYEndRelativeToStart = options.skewYEndRelativeToStart;
		//\Particle
		
		// Velocity
		this.velocityXInheritRatio = options.velocityXInheritRatio;
		this.velocityXInheritRatioVariance = options.velocityXInheritRatioVariance;
		this.velocityYInheritRatio = options.velocityYInheritRatio;
		this.velocityYInheritRatioVariance = options.velocityYInheritRatioVariance;
		
		this.linkRotationToVelocity = options.linkRotationToVelocity;
		this.velocityRotationOffset = options.velocityRotationOffset;
		
		this.velocityRotationFactor = options.velocityRotationFactor;
		
		this.velocityScaleFactorX = options.velocityScaleFactorX;
		this.velocityScaleFactorY = options.velocityScaleFactorY;
		
		this.velocitySkewFactorX = options.velocitySkewFactorX;
		this.velocitySkewFactorY = options.velocitySkewFactorY;
		//\Velocity
		
		// Animation
		this.textureAnimation = options.textureAnimation;
		this.frameDelta = options.frameDelta;
		this.frameDeltaVariance = options.frameDeltaVariance;
		this.loopAnimation = options.loopAnimation;
		this.animationLoops = options.animationLoops;
		this.randomStartFrame = options.randomStartFrame;
		//\Animation
		
		// Gravity
		this.speed = options.speed;
		this.speedVariance = options.speedVariance;
		this.adjustLifeSpanToSpeed = options.adjustLifeSpanToSpeed;
		
		this.gravityX = options.gravityX;
		this.gravityY = options.gravityY;
		
		this.radialAcceleration = options.radialAcceleration;
		this.radialAccelerationVariance = options.radialAccelerationVariance;
		
		this.tangentialAcceleration = options.tangentialAcceleration;
		this.tangentialAccelerationVariance = options.tangentialAccelerationVariance;
		
		this.drag = options.drag;
		this.dragVariance = options.dragVariance;
		
		this.repellentForce = options.repellentForce;
		//\Gravity
		
		// Radial
		this.radiusMax = options.radiusMax;
		this.radiusMaxVariance = options.radiusMaxVariance;
		
		this.radiusMin = options.radiusMin;
		this.radiusMinVariance = options.radiusMinVariance;
		
		this.rotatePerSecond = options.rotatePerSecond;
		this.rotatePerSecondVariance = options.rotatePerSecondVariance;
		
		this.alignRadialRotation = options.alignRadialRotation;
		this.alignRadialRotationOffset = options.alignRadialRotationOffset;
		this.alignRadialRotationOffsetVariance = options.alignRadialRotationOffsetVariance;
		//\Radial
		
		// Color
		this.colorStart.copyFrom(options.colorStart);
		this.colorStartVariance.copyFrom(options.colorStartVariance);
		
		this.colorEnd.copyFrom(options.colorEnd);
		this.colorEndVariance.copyFrom(options.colorEndVariance);
		
		this.colorEndRelativeToStart = options.colorEndRelativeToStart;
		this.colorEndIsMultiplier = options.colorEndIsMultiplier;
		//\Color
		
		// Color Offset
		this.colorOffsetStart.copyFrom(options.colorOffsetStart);
		this.colorOffsetStartVariance.copyFrom(options.colorOffsetStartVariance);
		
		this.colorOffsetEnd.copyFrom(options.colorOffsetEnd);
		this.colorOffsetEndVariance.copyFrom(options.colorOffsetEndVariance);
		
		this.colorOffsetEndRelativeToStart = options.colorOffsetEndRelativeToStart;
		this.colorOffsetEndIsMultiplier = options.colorOffsetEndIsMultiplier;
		//\Color Offset
		
		// Oscillation
		this.oscillationGlobalFrequency = options.oscillationGlobalFrequency;
		this.oscillationUnifiedFrequencyVariance = options.oscillationUnifiedFrequencyVariance;
		
		this.positionOscillationFrequencyMode = options.positionOscillationFrequencyMode;
		this.positionOscillationGroupStartStep = options.positionOscillationGroupStartStep;
		this.positionOscillationAngle = options.positionOscillationAngle;
		this.positionOscillationAngleVariance = options.positionOscillationAngleVariance;
		this.positionOscillationAngleRelativeTo = options.positionOscillationAngleRelativeTo;
		this.positionOscillationRadius = options.positionOscillationRadius;
		this.positionOscillationRadiusVariance = options.positionOscillationRadiusVariance;
		this.positionOscillationFrequency = options.positionOscillationFrequency;
		this.positionOscillationUnifiedFrequencyVariance = options.positionOscillationUnifiedFrequencyVariance;
		this.positionOscillationFrequencyVariance = options.positionOscillationFrequencyVariance;
		this.oscillationPositionFrequencyInverted = options.positionOscillationFrequencyInverted;
		this.positionOscillationFrequencyStart = options.positionOscillationFrequencyStart;
		
		this.position2OscillationFrequencyMode = options.position2OscillationFrequencyMode;
		this.position2OscillationGroupStartStep = options.position2OscillationGroupStartStep;
		this.position2OscillationAngle = options.position2OscillationAngle;
		this.position2OscillationAngleVariance = options.position2OscillationAngleVariance;
		this.position2OscillationAngleRelativeTo = options.position2OscillationAngleRelativeTo;
		this.position2OscillationRadius = options.position2OscillationRadius;
		this.position2OscillationRadiusVariance = options.position2OscillationRadiusVariance;
		this.position2OscillationFrequency = options.position2OscillationFrequency;
		this.position2OscillationUnifiedFrequencyVariance = options.position2OscillationUnifiedFrequencyVariance;
		this.position2OscillationFrequencyVariance = options.position2OscillationFrequencyVariance;
		this.position2OscillationFrequencyInverted = options.position2OscillationFrequencyInverted;
		this.position2OscillationFrequencyStart = options.position2OscillationFrequencyStart;
		
		this.rotationOscillationFrequencyMode = options.rotationOscillationFrequencyMode;
		this.rotationOscillationGroupStartStep = options.rotationOscillationGroupStartStep;
		this.rotationOscillationAngle = options.rotationOscillationAngle;
		this.rotationOscillationAngleVariance = options.rotationOscillationAngleVariance;
		this.rotationOscillationFrequency = options.rotationOscillationFrequency;
		this.rotationOscillationUnifiedFrequencyVariance = options.rotationOscillationUnifiedFrequencyVariance;
		this.rotationOscillationFrequencyVariance = options.rotationOscillationFrequencyVariance;
		this.rotationOscillationFrequencyInverted = options.rotationOscillationFrequencyInverted;
		this.rotationOscillationFrequencyStart = options.rotationOscillationFrequencyStart;
		
		this.scaleXOscillationFrequencyMode = options.scaleXOscillationFrequencyMode;
		this.scaleXOscillationGroupStartStep = options.scaleXOscillationGroupStartStep;
		this.scaleXOscillation = options.scaleXOscillation;
		this.scaleXOscillationVariance = options.scaleXOscillationVariance;
		this.scaleXOscillationFrequency = options.scaleXOscillationFrequency;
		this.scaleXOscillationUnifiedFrequencyVariance = options.scaleXOscillationUnifiedFrequencyVariance;
		this.scaleXOscillationFrequencyVariance = options.scaleXOscillationFrequencyVariance;
		this.scaleXOscillationFrequencyInverted = options.scaleXOscillationFrequencyInverted;
		this.scaleXOscillationFrequencyStart = options.scaleXOscillationFrequencyStart;
		
		this.scaleYOscillationFrequencyMode = options.scaleYOscillationFrequencyMode;
		this.scaleYOscillationGroupStartStep = options.scaleYOscillationGroupStartStep;
		this.scaleYOscillation = options.scaleYOscillation;
		this.scaleYOscillationVariance = options.scaleYOscillationVariance;
		this.scaleYOscillationFrequency = options.scaleYOscillationFrequency;
		this.scaleYOscillationUnifiedFrequencyVariance = options.scaleYOscillationUnifiedFrequencyVariance;
		this.scaleYOscillationFrequencyVariance = options.scaleYOscillationFrequencyVariance;
		this.scaleYOscillationFrequencyInverted = options.scaleYOscillationFrequencyInverted;
		this.scaleYOscillationFrequencyStart = options.scaleYOscillationFrequencyStart;
		
		this.skewXOscillationFrequencyMode = options.skewXOscillationFrequencyMode;
		this.skewXOscillationGroupStartStep = options.skewXOscillationGroupStartStep;
		this.skewXOscillation = options.skewXOscillation;
		this.skewXOscillationVariance = options.skewXOscillationVariance;
		this.skewXOscillationFrequency = options.skewXOscillationFrequency;
		this.skewXOscillationUnifiedFrequencyVariance = options.skewXOscillationUnifiedFrequencyVariance;
		this.skewXOscillationFrequencyVariance = options.skewXOscillationFrequencyVariance;
		this.skewXOscillationFrequencyInverted = options.skewXOscillationFrequencyInverted;
		this.skewXOscillationFrequencyStart = options.skewXOscillationFrequencyStart;
		
		this.skewYOscillationFrequencyMode = options.skewYOscillationFrequencyMode;
		this.skewYOscillationGroupStartStep = options.skewYOscillationGroupStartStep;
		this.skewYOscillation = options.skewYOscillation;
		this.skewYOscillationVariance = options.skewYOscillationVariance;
		this.skewYOscillationFrequency = options.skewYOscillationFrequency;
		this.skewYOscillationUnifiedFrequencyVariance = options.skewYOscillationUnifiedFrequencyVariance;
		this.skewYOscillationFrequencyVariance = options.skewYOscillationFrequencyVariance;
		this.skewYOscillationFrequencyInverted = options.skewYOscillationFrequencyInverted;
		this.skewYOscillationFrequencyStart = options.skewYOscillationFrequencyStart;
		
		this.colorOscillationFrequencyMode = options.colorOscillationFrequencyMode;
		this.colorOscillationGroupStartStep = options.colorOscillationGroupStartStep;
		this.colorOscillation.copyFrom(options.colorOscillation);
		this.colorOscillationVariance.copyFrom(options.colorOscillationVariance);
		this.colorOscillationFrequency = options.colorOscillationFrequency;
		this.colorOscillationUnifiedFrequencyVariance = options.colorOscillationUnifiedFrequencyVariance;
		this.colorOscillationFrequencyVariance = options.colorOscillationFrequencyVariance;
		this.colorOscillationFrequencyInverted = options.colorOscillationFrequencyInverted;
		this.colorOscillationFrequencyStart = options.colorOscillationFrequencyStart;
		
		this.colorOffsetOscillationFrequencyMode = options.colorOffsetOscillationFrequencyMode;
		this.colorOffsetOscillationGroupStartStep = options.colorOffsetOscillationGroupStartStep;
		this.colorOffsetOscillation.copyFrom(options.colorOffsetOscillation);
		this.colorOffsetOscillationVariance.copyFrom(options.colorOffsetOscillationVariance);
		this.colorOffsetOscillationFrequency = options.colorOffsetOscillationFrequency;
		this.colorOffsetOscillationUnifiedFrequencyVariance = options.colorOffsetOscillationUnifiedFrequencyVariance;
		this.colorOffsetOscillationFrequencyVariance = options.colorOffsetOscillationFrequencyVariance;
		this.colorOffsetOscillationFrequencyInverted = options.colorOffsetOscillationFrequencyInverted;
		this.colorOffsetOscillationFrequencyStart = options.colorOffsetOscillationFrequencyStart;
		//\Oscillation
		
		checkColor();
		checkColorOffset();
		checkOscillationColor();
		checkOscillationColorOffset();
		
		if (this._autoSetEmissionRate)
		{
			updateEmissionRate();
		}
		returnParticlesToPool();
		if (this.particlesFromPoolFunction != null && this._frames.length != 0)
		{
			getParticlesFromPool();
		}
		else
		{
			this._isParticlePoolUpdatePending = true;
		}
	}
	
	public function writeSystemOptions(options:ParticleSystemOptions = null):ParticleSystemOptions
	{
		if (options == null) options = ParticleSystemOptions.fromPool();
		
		// Emitter
		options.emitterType = this._emitterType;
		options.emitterMode = this._emitterMode;
		
		options.maxNumParticles = this._maxNumParticles;
		
		options.particleAmount = this.particleAmount;
		
		options.numBursts = this._numBursts;
		options.burstDuration = this._burstDuration;
		options.burstInterval = this._burstInterval;
		options.burstIntervalVariance = this.burstIntervalVariance;
		
		options.autoSetEmissionRate = this._autoSetEmissionRate;
		options.emissionRate = this._emissionRate;
		options.emissionRatio = this._emissionRatio;
		
		options.emitterX = this.emitterX;
		options.emitterY = this.emitterY;
		options.emitterXVariance = this.emitterXVariance;
		options.emitterYVariance = this.emitterYVariance;
		
		options.emitterRadiusMax = this._emitterRadiusMax;
		options.emitterRadiusMaxVariance = this._emitterRadiusMaxVariance;
		options.emitterRadiusMin = this._emitterRadiusMin;
		options.emitterRadiusMinVariance = this._emitterRadiusMinVariance;
		options.emitterRadiusOverridesParticleAngle = this.emitterRadiusOverridesParticleAngle;
		options.emitterRadiusParticleAngleOffset = this.emitterRadiusParticleAngleOffset;
		options.emitterRadiusParticleAngleOffsetVariance = this.emitterRadiusParticleAngleOffsetVariance;
		
		options.emitAngle = this.emitAngle;
		options.emitAngleVariance = this.emitAngleVariance;
		options.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
		
		options.duration = this._emissionTimePredefined == MathUtils.FLOAT_MAX ? -1 : this._emissionTimePredefined;
		
		options.useDisplayRect = this.useDisplayRect;
		options.displayRect.copyFrom(this.displayRect);
		//\Emitter
		
		// Particle
		options.useAnimationLifeSpan = this._useAnimationLifeSpan;
		options.lifeSpan = this._lifeSpan;
		options.lifeSpanVariance = this._lifeSpanVariance;
		
		options.fadeInTime = this._fadeInTime;
		options.fadeOutTime = this._fadeOutTime;
		
		options.sizeXStart = this._sizeXStart;
		options.sizeYStart = this._sizeYStart;
		options.sizeXStartVariance = this._sizeXStartVariance;
		options.sizeYStartVariance = this._sizeYStartVariance;
		
		options.sizeXEnd = this._sizeXEnd;
		options.sizeYEnd = this._sizeYEnd;
		options.sizeXEndVariance = this._sizeXEndVariance;
		options.sizeYEndVariance = this._sizeYEndVariance;
		options.sizeXEndRelativeToStart = this.sizeXEndRelativeToStart;
		options.sizeYEndRelativeToStart = this.sizeYEndRelativeToStart;
		
		options.rotationStart = this._rotationStart;
		options.rotationStartVariance = this._rotationStartVariance;
		options.rotationEnd = this._rotationEnd;
		options.rotationEndVariance = this._rotationEndVariance;
		options.rotationEndRelativeToStart = this.rotationEndRelativeToStart;
		
		options.skewXStart = this._skewXStart;
		options.skewYStart = this._skewYStart;
		options.skewXStartVariance = this._skewXStartVariance;
		options.skewYStartVariance = this._skewYStartVariance;
		
		options.skewXEnd = this._skewXEnd;
		options.skewYEnd = this._skewYEnd;
		options.skewXEndVariance = this._skewXEndVariance;
		options.skewYEndVariance = this._skewYEndVariance;
		options.skewXEndRelativeToStart = this._skewXEndRelativeToStart;
		options.skewYEndRelativeToStart = this._skewYEndRelativeToStart;
		//\Particle
		
		// Velocity
		options.velocityXInheritRatio = this._velocityXInheritRatio;
		options.velocityXInheritRatioVariance = this._velocityXInheritRatioVariance;
		options.velocityYInheritRatio = this._velocityYInheritRatio;
		options.velocityYInheritRatioVariance = this._velocityYInheritRatioVariance;
		
		options.linkRotationToVelocity = this.linkRotationToVelocity;
		options.velocityRotationOffset = this.velocityRotationOffset;
		
		options.velocityRotationFactor = this._velocityRotationFactor;
		
		options.velocityScaleFactorX = this._velocityScaleFactorX;
		options.velocityScaleFactorY = this._velocityScaleFactorY;
		
		options.velocitySkewFactorX = this._velocitySkewFactorX;
		options.velocitySkewFactorY = this._velocitySkewFactorY;
		//\Velocity
		
		// Animation
		options.textureAnimation = this.textureAnimation;
		options.frameDelta = this._frameDelta;
		options.frameDeltaVariance = this.frameDeltaVariance;
		options.loopAnimation = this._loopAnimation;
		options.animationLoops = this._animationLoops;
		options.randomStartFrame = this.randomStartFrame;
		//\Animation
		
		// Gravity
		options.speed = this.speed;
		options.speedVariance = this.speedVariance;
		
		options.adjustLifeSpanToSpeed = this.adjustLifeSpanToSpeed;
		
		options.gravityX = this._gravityX;
		options.gravityY = this._gravityY;
		
		options.radialAcceleration = this._radialAcceleration;
		options.radialAccelerationVariance = this._radialAccelerationVariance;
		
		options.tangentialAcceleration = this._tangentialAcceleration;
		options.tangentialAccelerationVariance = this._tangentialAccelerationVariance;
		
		options.drag = this._drag;
		
		options.repellentForce = this._repellentForce;
		//\Gravity
		
		// Radial
		options.radiusMax = this.radiusMax;
		options.radiusMaxVariance = this.radiusMaxVariance;
		
		options.radiusMin = this.radiusMin;
		options.radiusMinVariance = this.radiusMinVariance;
		
		options.rotatePerSecond = this.rotatePerSecond;
		options.rotatePerSecondVariance = this.rotatePerSecondVariance;
		
		options.alignRadialRotation = this.alignRadialRotation;
		options.alignRadialRotationOffset = this.alignRadialRotationOffset;
		options.alignRadialRotationOffsetVariance = this.alignRadialRotationOffsetVariance;
		//\Radial
		
		// Color
		options.colorStart.copyFrom(this.colorStart);
		options.colorStartVariance.copyFrom(this.colorStartVariance);
		
		options.colorEnd.copyFrom(this.colorEnd);
		options.colorEndVariance.copyFrom(this.colorEndVariance);
		
		options.colorEndRelativeToStart = this._colorEndRelativeToStart;
		options.colorEndIsMultiplier = this.colorEndIsMultiplier;
		//\Color
		
		// Color Offset
		options.colorOffsetStart.copyFrom(this.colorOffsetStart);
		options.colorOffsetStartVariance.copyFrom(this.colorOffsetStartVariance);
		
		options.colorOffsetEnd.copyFrom(this.colorOffsetEnd);
		options.colorOffsetEndVariance.copyFrom(this.colorOffsetEndVariance);
		
		options.colorOffsetEndRelativeToStart = this._colorOffsetEndRelativeToStart;
		options.colorOffsetEndIsMultiplier = this.colorOffsetEndIsMultiplier;
		//\Color Offset
		
		// Oscillation
		options.oscillationGlobalFrequency = this.oscillationGlobalFrequency;
		options.oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance;
		
		options.positionOscillationFrequencyMode = this._positionOscillationFrequencyMode;
		options.positionOscillationGroupStartStep = this.positionOscillationGroupStartStep;
		options.positionOscillationAngle = this.positionOscillationAngle;
		options.positionOscillationAngleVariance = this.positionOscillationAngleVariance;
		options.positionOscillationAngleRelativeTo = this._positionOscillationAngleRelativeTo;
		options.positionOscillationRadius = this._positionOscillationRadius;
		options.positionOscillationRadiusVariance = this._positionOscillationRadiusVariance;
		options.positionOscillationFrequency = this.positionOscillationFrequency;
		options.positionOscillationUnifiedFrequencyVariance = this._positionOscillationUnifiedFrequencyVariance;
		options.positionOscillationFrequencyVariance = this.positionOscillationFrequencyVariance;
		options.positionOscillationFrequencyInverted = this.oscillationPositionFrequencyInverted;
		options.positionOscillationFrequencyStart = this._positionOscillationFrequencyStart;
		
		options.position2OscillationFrequencyMode = this._position2OscillationFrequencyMode;
		options.position2OscillationGroupStartStep = this.position2OscillationGroupStartStep;
		options.position2OscillationAngle = this.position2OscillationAngle;
		options.position2OscillationAngleVariance = this.position2OscillationAngleVariance;
		options.position2OscillationAngleRelativeTo = this.position2OscillationAngleRelativeTo;
		options.position2OscillationRadius = this._position2OscillationRadius;
		options.position2OscillationRadiusVariance = this._position2OscillationRadiusVariance;
		options.position2OscillationFrequency = this.position2OscillationFrequency;
		options.position2OscillationUnifiedFrequencyVariance = this._position2OscillationUnifiedFrequencyVariance;
		options.position2OscillationFrequencyVariance = this.position2OscillationFrequencyVariance;
		options.position2OscillationFrequencyInverted = this.position2OscillationFrequencyInverted;
		options.position2OscillationFrequencyStart = this._position2OscillationFrequencyStart;
		
		options.rotationOscillationFrequencyMode = this._rotationOscillationFrequencyMode;
		options.rotationOscillationGroupStartStep = this.rotationOscillationGroupStartStep;
		options.rotationOscillationAngle = this._rotationOscillationAngle;
		options.rotationOscillationAngleVariance = this._rotationOscillationAngleVariance;
		options.rotationOscillationFrequency = this.rotationOscillationFrequency;
		options.rotationOscillationUnifiedFrequencyVariance = this._rotationOscillationUnifiedFrequencyVariance;
		options.rotationOscillationFrequencyVariance = this.rotationOscillationFrequencyVariance;
		options.rotationOscillationFrequencyInverted = this.rotationOscillationFrequencyInverted;
		options.rotationOscillationFrequencyStart = this._rotationOscillationFrequencyStart;
		
		options.scaleXOscillationFrequencyMode = this._scaleXOscillationFrequencyMode;
		options.scaleXOscillationGroupStartStep = this.scaleXOscillationGroupStartStep;
		options.scaleXOscillation = this._scaleXOscillation;
		options.scaleXOscillationVariance = this._scaleXOscillationVariance;
		options.scaleXOscillationFrequency = this.scaleXOscillationFrequency;
		options.scaleXOscillationUnifiedFrequencyVariance = this._scaleXOscillationUnifiedFrequencyVariance;
		options.scaleXOscillationFrequencyVariance = this.scaleXOscillationFrequencyVariance;
		options.scaleXOscillationFrequencyInverted = this.scaleXOscillationFrequencyInverted;
		options.scaleXOscillationFrequencyStart = this._scaleXOscillationFrequencyStart;
		
		options.scaleYOscillationFrequencyMode = this._scaleYOscillationFrequencyMode;
		options.scaleYOscillationGroupStartStep = this.scaleYOscillationGroupStartStep;
		options.scaleYOscillation = this._scaleYOscillation;
		options.scaleYOscillationVariance = this._scaleYOscillationVariance;
		options.scaleYOscillationFrequency = this.scaleYOscillationFrequency;
		options.scaleYOscillationUnifiedFrequencyVariance = this._scaleYOscillationUnifiedFrequencyVariance;
		options.scaleYOscillationFrequencyVariance = this.scaleYOscillationFrequencyVariance;
		options.scaleYOscillationFrequencyInverted = this.scaleYOscillationFrequencyInverted;
		options.scaleYOscillationFrequencyStart = this._scaleYOscillationFrequencyStart;
		
		options.skewXOscillationFrequencyMode = this._skewXOscillationFrequencyMode;
		options.skewXOscillationGroupStartStep = this.skewXOscillationGroupStartStep;
		options.skewXOscillation = this._skewXOscillation;
		options.skewXOscillationVariance = this._skewXOscillationVariance;
		options.skewXOscillationFrequency = this.skewXOscillationFrequency;
		options.skewXOscillationUnifiedFrequencyVariance = this._skewXOscillationUnifiedFrequencyVariance;
		options.skewXOscillationFrequencyVariance = this.skewXOscillationFrequencyVariance;
		options.skewXOscillationFrequencyInverted = this.skewXOscillationFrequencyInverted;
		options.skewXOscillationFrequencyStart = this._skewXOscillationFrequencyStart;
		
		options.skewYOscillationFrequencyMode = this._skewYOscillationFrequencyMode;
		options.skewYOscillationGroupStartStep = this.skewYOscillationGroupStartStep;
		options.skewYOscillation = this._skewYOscillation;
		options.skewYOscillationVariance = this._skewYOscillationVariance;
		options.skewYOscillationFrequency = this.skewYOscillationFrequency;
		options.skewYOscillationUnifiedFrequencyVariance = this._skewYOscillationUnifiedFrequencyVariance;
		options.skewYOscillationFrequencyVariance = this.skewYOscillationFrequencyVariance;
		options.skewYOscillationFrequencyInverted = this.skewYOscillationFrequencyInverted;
		options.skewYOscillationFrequencyStart = this._skewYOscillationFrequencyStart;
		
		options.colorOscillationFrequencyMode = this._colorOscillationFrequencyMode;
		options.colorOscillationGroupStartStep = this.colorOscillationGroupStartStep;
		options.colorOscillation.copyFrom(this.colorOscillation);
		options.colorOscillationVariance.copyFrom(this.colorOscillationVariance);
		options.colorOscillationFrequency = this.colorOscillationFrequency;
		options.colorOscillationUnifiedFrequencyVariance = this._colorOscillationUnifiedFrequencyVariance;
		options.colorOscillationFrequencyVariance = this.colorOscillationFrequencyVariance;
		options.colorOscillationFrequencyInverted = this.colorOscillationFrequencyInverted;
		options.colorOscillationFrequencyStart = this._colorOscillationFrequencyStart;
		
		options.colorOffsetOscillationFrequencyMode = this._colorOffsetOscillationFrequencyMode;
		options.colorOffsetOscillationGroupStartStep = this.colorOffsetOscillationGroupStartStep;
		options.colorOffsetOscillation.copyFrom(this.colorOffsetOscillation);
		options.colorOffsetOscillationVariance.copyFrom(this.colorOffsetOscillationVariance);
		options.colorOffsetOscillationFrequency = this.colorOffsetOscillationFrequency;
		options.colorOffsetOscillationUnifiedFrequencyVariance = this._colorOffsetOscillationUnifiedFrequencyVariance;
		options.colorOffsetOscillationFrequencyVariance = this.colorOffsetOscillationFrequencyVariance;
		options.colorOffsetOscillationFrequencyInverted = this.colorOffsetOscillationFrequencyInverted;
		options.colorOffsetOscillationFrequencyStart = this.colorOffsetOscillationFrequencyStart;
		//\Oscillation
		
		return options;
	}
	
	private function checkEmitterRadius():Void
	{
		this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
	}
	
	private function checkSizeX():Void
	{
		if (this._sizeXEndRelativeToStart)
		{
			this._useSizeX = this._sizeXEnd != 0.0 || this._sizeXEndVariance != 0.0;
		}
		else
		{
			this._useSizeX = this._sizeXStart != this._sizeXEnd || this._sizeXStartVariance != 0.0 || this._sizeXEndVariance != 0.0;
		}
	}
	
	private function checkSizeY():Void
	{
		if (this._sizeYEndRelativeToStart)
		{
			this._useSizeY = this._sizeYEnd != 0.0 || this._sizeYEndVariance != 0.0;
		}
		else
		{
			this._useSizeY = this._sizeYStart != this._sizeYEnd || this._sizeYStartVariance != 0.0 || this._sizeYEndVariance != 0.0;
		}
	}
	
	private function checkRotation():Void
	{
		if (this._rotationEndRelativeToStart)
		{
			this._useRotation = this._rotationEnd != 0.0 || this._rotationEndVariance != 0.0;
		}
		else
		{
			this._useRotation = this._rotationEnd != this._rotationStart || this._rotationStartVariance != 0.0 || this._rotationEndVariance != 0.0;
		}
	}
	
	private function checkSkewX():Void
	{
		this._hasSkewX = this._skewXStart != 0.0 || this._skewXStartVariance != 0.0;
		if (this._skewXEndRelativeToStart)
		{
			this._useSkewX = this._skewXEnd != 0.0 || this._skewXEndVariance != 0.0;
		}
		else
		{
			this._useSkewX = this._skewXStart != this._skewXEnd || this._skewXStartVariance != 0.0 || this._skewXEndVariance != 0.0;
		}
	}
	
	private function checkSkewY():Void
	{
		this._hasSkewY = this._skewYStart != 0.0 || this._skewYStartVariance != 0.0;
		if (this._skewYEndRelativeToStart)
		{
			this._useSkewY = this._skewYEnd != 0.0 || this._skewYEndVariance != 0.0;
		}
		else
		{
			this._useSkewY = this._skewYStart != this._skewYEnd || this._skewYStartVariance != 0.0 || this._skewYEndVariance != 0.0;
		}
	}
	
	private function colorChange(tint:MassiveTint):Void
	{
		checkColor();
	}
	
	private function checkColor():Void
	{
		this._hasColorStartVariance = this.colorStartVariance.hasValue();
		this._hasColorEndVariance = this.colorEndVariance.hasValue();
		if (this._colorEndRelativeToStart)
		{
			if (this._colorEndIsMultiplier)
			{
				if (this.colorEnd.hasValueDifferentThan(1.0) || this.colorEndVariance.hasValue())
				{
					this._useColor = true;
				}
				else
				{
					this._useColor = false;
				}
			}
			else
			{
				if (this.colorEnd.hasValue() || this.colorEndVariance.hasValue())
				{
					this._useColor = true;
				}
				else
				{
					this._useColor = false;
				}
			}
		}
		else
		{
			if (!this.colorStart.isSameAs(this.colorEnd) || this.colorStartVariance.hasValue() || this.colorEndVariance.hasValue())
			{
				this._useColor = true;
			}
			else
			{
				this._useColor = false;
			}
		}
		checkAnyColor();
	}
	
	private function colorOffsetChange(tint:MassiveTint):Void
	{
		checkColorOffset();
	}
	
	private function checkColorOffset():Void
	{
		this._hasColorOffset = this.colorOffsetStart.hasValue();
		this._hasColorOffsetStartVariance = this.colorOffsetStartVariance.hasValue();
		this._hasColorOffsetEndVariance = this.colorOffsetEndVariance.hasValue();
		if (this._colorOffsetEndRelativeToStart)
		{
			if (this._colorOffsetEndIsMultiplier)
			{
				if (this.colorOffsetEnd.hasValueDifferentThan(1.0) || this.colorOffsetEndVariance.hasValue())
				{
					this._useColorOffset = true;
				}
				else
				{
					this._useColorOffset = false;
				}
			}
			else
			{
				if (this.colorOffsetEnd.hasValue() || this.colorOffsetEndVariance.hasValue())
				{
					this._useColorOffset = true;
				}
				else
				{
					this._useColorOffset = false;
				}
			}
		}
		else
		{
			if (!this.colorOffsetStart.isSameAs(this.colorOffsetEnd) || this.colorOffsetStartVariance.hasValue() || this.colorOffsetEndVariance.hasValue())
			{
				this._useColorOffset = true;
			}
			else
			{
				this._useColorOffset = false;
			}
		}
		checkAnyColorOffset();
	}
	
	private function oscillationColorChange(tint:MassiveTint):Void
	{
		checkOscillationColor();
	}
	
	private function checkOscillationColor():Void
	{
		this._useColorOscillation = this.colorOscillation.hasValue() || this.colorOscillationVariance.hasValue();
		checkAnyColor();
	}
	
	private function oscillationColorOffsetChange(tint:MassiveTint):Void
	{
		checkOscillationColorOffset();
	}
	
	private function checkOscillationColorOffset():Void
	{
		this._useColorOffsetOscillation = this.colorOffsetOscillation.hasValue() || this.colorOffsetOscillationVariance.hasValue();
		checkAnyColorOffset();
	}
	
	private var _hasAnyColor:Bool;
	
	private function checkAnyColor():Void
	{
		this._hasAnyColor = this._useColor || this._useColorOscillation;
	}
	
	private var _hasAnyColorOffset:Bool;
	
	private function checkAnyColorOffset():Void
	{
		this._hasAnyColorOffset = this._useColorOffset || this._useColorOffsetOscillation;
	}
	
	private var _hasAnyVelocityEffect:Bool;
	
	private function checkAnyVelocityEffect():Void
	{
		this._hasAnyVelocityEffect = this._useVelocityScale || this._useVelocitySkew || this._useVelocityRotation;
	}
	
	private function checkOscillationGlobalFrequency():Void
	{
		this._useOscillationGlobalFrequency = this._positionOscillationGlobalFrequencyEnabled || this._position2OscillationGlobalFrequencyEnabled || this._rotationOscillationGlobalFrequencyEnabled ||
											  this._scaleXOscillationGlobalFrequencyEnabled || this._scaleYOscillationGlobalFrequencyEnabled || this._skewXOscillationGlobalFrequencyEnabled || 
											  this._skewYOscillationGlobalFrequencyEnabled || this._colorOscillationGlobalFrequencyEnabled || this._colorOffsetOscillationGlobalFrequencyEnabled;
	}
	
	private function checkOscillationUnifiedFrequencyVariance():Void
	{
		this._useOscillationUnifiedFrequencyVariance = this._positionOscillationUnifiedFrequencyVariance || this._position2OscillationUnifiedFrequencyVariance || this._rotationOscillationUnifiedFrequencyVariance ||
													   this._scaleXOscillationUnifiedFrequencyVariance || this._scaleYOscillationUnifiedFrequencyVariance || this._skewXOscillationUnifiedFrequencyVariance ||
													   this._skewYOscillationUnifiedFrequencyVariance || this._colorOscillationUnifiedFrequencyVariance || this._colorOffsetOscillationUnifiedFrequencyVariance;
	}
	
	private function checkOscillationUnifiedFrequencyStart():Void
	{
		this._useOscillationUnifiedRandomFrequencyStart = this._positionOscillationFrequencyStartUnifiedRandom || this._position2OscillationFrequencyStartUnifiedRandom || this._rotationOscillationFrequencyStartUnifiedRandom ||
													this._scaleXOscillationFrequencyStartUnifiedRandom || this._scaleYOscillationFrequencyStartUnifiedRandom || this._skewXOscillationFrequencyStartUnifiedRandom ||
													this._skewYOscillationFrequencyStartUnifiedRandom || this._colorOscillationFrequencyStartUnifiedRandom || this._colorOffsetOscillationFrequencyStartUnifiedRandom;
	}
	
}