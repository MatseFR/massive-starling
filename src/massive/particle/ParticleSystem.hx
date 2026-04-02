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
	
	/**
	   The amount of particles this system can create over time, 0 = infinite
	   @default 0
	**/
	public var particleAmount:Int = 0;
	
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
	
	/**
	   How many particles are created per second
	   @default 100
	**/
	public var emissionRate(get, set):Float;
	private var _emissionRate:Float = 100;
	private function get_emissionRate():Float { return this._emissionRate; }
	private function set_emissionRate(value:Float):Float
	{
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
		this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
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
		this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
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
		this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
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
		this._useEmitterRadius = this._emitterRadiusMax != 0.0 || this._emitterRadiusMaxVariance != 0.0 || this._emitterRadiusMin != 0.0 || this._emitterRadiusMinVariance != 0.0;
		return this._emitterRadiusMinVariance;
	}
	
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
		if (this._sizeXEndRelativeToStart)
		{
			this._useSizeX = this._sizeXEnd != 0.0 || this._sizeXEndVariance != 0.0;
		}
		else
		{
			this._useSizeX = this._sizeXStart != this._sizeXEnd || this._sizeXStartVariance != 0.0 || this._sizeXEndVariance != 0.0;
		}
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
		if (this._sizeXEndRelativeToStart)
		{
			this._useSizeX = this._sizeXEnd != 0.0 || this._sizeXEndVariance != 0.0;
		}
		else
		{
			this._useSizeX = this._sizeXStart != this._sizeXEnd || this._sizeXStartVariance != 0.0 || this._sizeXEndVariance != 0.0;
		}
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
		if (this._sizeYEndRelativeToStart)
		{
			this._useSizeY = this._sizeYEnd != 0.0 || this._sizeYEndVariance != 0.0;
		}
		else
		{
			this._useSizeY = this._sizeYStart != this._sizeYEnd || this._sizeYStartVariance != 0.0 || this._sizeYEndVariance != 0.0;
		}
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
		if (this._sizeYEndRelativeToStart)
		{
			this._useSizeY = this._sizeYEnd != 0.0 || this._sizeYEndVariance != 0.0;
		}
		else
		{
			this._useSizeY = this._sizeYStart != this._sizeYEnd || this._sizeYStartVariance != 0.0 || this._sizeYEndVariance != 0.0;
		}
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
		if (this._sizeXEndRelativeToStart)
		{
			this._useSizeX = this._sizeXEnd != 0.0 || this._sizeXEndVariance != 0.0;
		}
		else
		{
			this._useSizeX = this._sizeXStart != this._sizeXEnd || this._sizeXStartVariance != 0.0 || this._sizeXEndVariance != 0.0;
		}
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
		if (this._sizeXEndRelativeToStart)
		{
			this._useSizeX = this._sizeXEnd != 0.0 || this._sizeXEndVariance != 0.0;
		}
		else
		{
			this._useSizeX = this._sizeXStart != this._sizeXEnd || this._sizeXStartVariance != 0.0 || this._sizeXEndVariance != 0.0;
		}
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
		if (this._sizeYEndRelativeToStart)
		{
			this._useSizeY = this._sizeYEnd != 0.0 || this._sizeYEndVariance != 0.0;
		}
		else
		{
			this._useSizeY = this._sizeYStart != this._sizeYEnd || this._sizeYStartVariance != 0.0 || this._sizeYEndVariance != 0.0;
		}
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
		if (this._sizeYEndRelativeToStart)
		{
			this._useSizeY = this._sizeYEnd != 0.0 || this._sizeYEndVariance != 0.0;
		}
		else
		{
			this._useSizeY = this._sizeYStart != this._sizeYEnd || this._sizeYStartVariance != 0.0 || this._sizeYEndVariance != 0.0;
		}
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
		if (this._sizeXEndRelativeToStart)
		{
			this._useSizeX = this._sizeXEnd != 0.0 || this._sizeXEndVariance != 0.0;
		}
		else
		{
			this._useSizeX = this._sizeXStart != this._sizeXEnd || this._sizeXStartVariance != 0.0 || this._sizeXEndVariance != 0.0;
		}
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
		if (this._sizeYEndRelativeToStart)
		{
			this._useSizeY = this._sizeYEnd != 0.0 || this._sizeYEndVariance != 0.0;
		}
		else
		{
			this._useSizeY = this._sizeYStart != this._sizeYEnd || this._sizeYStartVariance != 0.0 || this._sizeYEndVariance != 0.0;
		}
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
		if (this._rotationEndRelativeToStart)
		{
			this._useRotation = this._rotationEnd != 0.0 || this._rotationEndVariance != 0.0;
		}
		else
		{
			this._useRotation = this._rotationEnd != this._rotationStart || this._rotationStartVariance != 0.0 || this._rotationEndVariance != 0.0;
		}
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
		if (this._rotationEndRelativeToStart)
		{
			this._useRotation = this._rotationEnd != 0.0 || this._rotationEndVariance != 0.0;
		}
		else
		{
			this._useRotation = this._rotationEnd != this._rotationStart || this._rotationStartVariance != 0.0 || this._rotationEndVariance != 0.0;
		}
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
		if (this._rotationEndRelativeToStart)
		{
			this._useRotation = this._rotationEnd != 0.0 || this._rotationEndVariance != 0.0;
		}
		else
		{
			this._useRotation = this._rotationEnd != this._rotationStart || this._rotationStartVariance != 0.0 || this._rotationEndVariance != 0.0;
		}
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
		if (this._rotationEndRelativeToStart)
		{
			this._useRotation = this._rotationEnd != 0.0 || this._rotationEndVariance != 0.0;
		}
		else
		{
			this._useRotation = this._rotationEnd != this._rotationStart || this._rotationStartVariance != 0.0 || this._rotationEndVariance != 0.0;
		}
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
		if (this._rotationEndRelativeToStart)
		{
			this._useRotation = this._rotationEnd != 0.0 || this._rotationEndVariance != 0.0;
		}
		else
		{
			this._useRotation = this._rotationEnd != this._rotationStart || this._rotationStartVariance != 0.0 || this._rotationEndVariance != 0.0;
		}
		return this._rotationEndRelativeToStart;
	}
	
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
		if (this._skewXEndRelativeToStart)
		{
			this._useSkewX = this._skewXEnd != 0.0 || this._skewXEndVariance != 0.0;
		}
		else
		{
			this._useSkewX = this._skewXStart != this._skewXEnd || this._skewXStartVariance != 0.0 || this._skewXEndVariance != 0.0;
		}
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
		if (this._skewXEndRelativeToStart)
		{
			this._useSkewX = this._skewXEnd != 0.0 || this._skewXEndVariance != 0.0;
		}
		else
		{
			this._useSkewX = this._skewXStart != this._skewXEnd || this._skewXStartVariance != 0.0 || this._skewXEndVariance != 0.0;
		}
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
		if (this._skewYEndRelativeToStart)
		{
			this._useSkewY = this._skewYEnd != 0.0 || this._skewYEndVariance != 0.0;
		}
		else
		{
			this._useSkewY = this._skewYStart != this._skewYEnd || this._skewYStartVariance != 0.0 || this._skewYEndVariance != 0.0;
		}
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
		if (this._skewYEndRelativeToStart)
		{
			this._useSkewY = this._skewYEnd != 0.0 || this._skewYEndVariance != 0.0;
		}
		else
		{
			this._useSkewY = this._skewYStart != this._skewYEnd || this._skewYStartVariance != 0.0 || this._skewYEndVariance != 0.0;
		}
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
		if (this._skewXEndRelativeToStart)
		{
			this._useSkewX = this._skewXEnd != 0.0 || this._skewXEndVariance != 0.0;
		}
		else
		{
			this._useSkewX = this._skewXStart != this._skewXEnd || this._skewXStartVariance != 0.0 || this._skewXEndVariance != 0.0;
		}
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
		if (this._skewXEndRelativeToStart)
		{
			this._useSkewX = this._skewXEnd != 0.0 || this._skewXEndVariance != 0.0;
		}
		else
		{
			this._useSkewX = this._skewXStart != this._skewXEnd || this._skewXStartVariance != 0.0 || this._skewXEndVariance != 0.0;
		}
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
		if (this._skewYEndRelativeToStart)
		{
			this._useSkewY = this._skewYEnd != 0.0 || this._skewYEndVariance != 0.0;
		}
		else
		{
			this._useSkewY = this._skewYStart != this._skewYEnd || this._skewYStartVariance != 0.0 || this._skewYEndVariance != 0.0;
		}
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
		if (this._skewYEndRelativeToStart)
		{
			this._useSkewY = this._skewYEnd != 0.0 || this._skewYEndVariance != 0.0;
		}
		else
		{
			this._useSkewY = this._skewYStart != this._skewYEnd || this._skewYStartVariance != 0.0 || this._skewYEndVariance != 0.0;
		}
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
		if (this._skewXEndRelativeToStart)
		{
			this._useSkewX = this._skewXEnd != 0.0 || this._skewXEndVariance != 0.0;
		}
		else
		{
			this._useSkewX = this._skewXStart != this._skewXEnd || this._skewXStartVariance != 0.0 || this._skewXEndVariance != 0.0;
		}
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
		if (this._skewYEndRelativeToStart)
		{
			this._useSkewY = this._skewYEnd != 0.0 || this._skewYEndVariance != 0.0;
		}
		else
		{
			this._useSkewY = this._skewYStart != this._skewYEnd || this._skewYStartVariance != 0.0 || this._skewYEndVariance != 0.0;
		}
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
	//##################################################
	//\RADIAL
	//##################################################
	
	//##################################################
	// COLOR
	//##################################################
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
	public var colorEndIsMultiplier:Bool = false;
	//##################################################
	//\COLOR
	//##################################################
	
	//##################################################
	// OSCILLATION
	//##################################################
	private var _useOscillationGlobalFrequency:Bool = false;
	private var _useOscillationUnifiedFrequencyVariance:Bool = false;
	private var _useOscillationUnifiedFrequencyStart:Bool = false;
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
	private var _oscillationPositionEnabled:Bool = false;
	private var _oscillationPositionGroupStep:Float;
	private var _oscillationPositionGroupValue:Float;
	private var _oscillationPositionGlobalFrequencyEnabled:Bool = false;
	private var _oscillationPositionGroupFrequencyEnabled:Bool = false;
	private var _oscillationPositionFrequencyStartRandomized:Bool = false;
	private var _oscillationPositionFrequencyStartUnified:Bool = false;
	private var _oscillationPositionAngleRelativeToRotation:Bool = true;
	private var _oscillationPositionAngleRelativeToVelocity:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationPositionFrequencyMode(get, set):String;
	private var _oscillationPositionFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationPositionFrequencyMode():String { return this._oscillationPositionFrequencyMode; }
	private function set_oscillationPositionFrequencyMode(value:String):String
	{
		if (this._oscillationPositionFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationPositionGlobalFrequencyEnabled = true;
				this._oscillationPositionGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationPositionGlobalFrequencyEnabled = false;
				this._oscillationPositionGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationPositionGlobalFrequencyEnabled = false;
				this._oscillationPositionGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationPositionFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationPositionGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationPositionAngle:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationPositionAngleVariance:Float = 0.0;
	
	/**
	   see AngleRelativeTo for possible values
	   @default	AngleRelativeTo.ROTATION
	**/
	public var oscillationPositionAngleRelativeTo(get, set):String;
	private var _oscillationPositionAngleRelativeTo:String = AngleRelativeTo.ROTATION;
	private function get_oscillationPositionAngleRelativeTo():String { return this._oscillationPositionAngleRelativeTo; }
	private function set_oscillationPositionAngleRelativeTo(value:String):String
	{
		if (this._oscillationPositionAngleRelativeTo == value) return value;
		
		switch (value)
		{
			case AngleRelativeTo.ABSOLUTE :
				this._oscillationPositionAngleRelativeToRotation = false;
				this._oscillationPositionAngleRelativeToVelocity = false;
			
			case AngleRelativeTo.ROTATION :
				this._oscillationPositionAngleRelativeToRotation = true;
				this._oscillationPositionAngleRelativeToVelocity = false;
			
			case AngleRelativeTo.VELOCITY :
				this._oscillationPositionAngleRelativeToRotation = false;
				this._oscillationPositionAngleRelativeToVelocity = true;
			
			default :
				throw new Error("unknown AngleRelativeTo ::: " + value);
		}
		
		return this._oscillationPositionAngleRelativeTo = value;
	}
	
	/**
	   @default 0
	**/
	public var oscillationPositionRadius(get, set):Float;
	private var _oscillationPositionRadius:Float = 0.0;
	private function get_oscillationPositionRadius():Float { return this._oscillationPositionRadius; }
	private function set_oscillationPositionRadius(value:Float):Float
	{
		this._oscillationPositionEnabled = value != 0.0 || this._oscillationPositionRadiusVariance != 0.0;
		return this._oscillationPositionRadius = value;
	}
	
	/**
	   @default 0
	**/
	public var oscillationPositionRadiusVariance(get, set):Float;
	private var _oscillationPositionRadiusVariance:Float = 0.0;
	private function get_oscillationPositionRadiusVariance():Float { return this._oscillationPositionRadiusVariance; }
	private function set_oscillationPositionRadiusVariance(value:Float):Float
	{
		this._oscillationPositionEnabled = value != 0.0 || this._oscillationPositionRadius != 0.0;
		return this._oscillationPositionRadiusVariance = value;
	}
	
	/**
	   @default 0
	**/
	public var oscillationPositionFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var oscillationPositionUnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationPositionUnifiedFrequencyVariance:Bool = false;
	private function get_oscillationPositionUnifiedFrequencyVariance():Bool { return this._oscillationPositionUnifiedFrequencyVariance; }
	private function set_oscillationPositionUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationPositionUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationPositionUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationPositionFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationPositionFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationPositionFrequencyStart(get, set):String;
	private var _oscillationPositionFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationPositionFrequencyStart():String { return this._oscillationPositionFrequencyStart; }
	private function set_oscillationPositionFrequencyStart(value:String):String
	{
		if (this._oscillationPositionFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationPositionFrequencyStartRandomized = false;
				this._oscillationPositionFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationPositionFrequencyStartRandomized = true;
				this._oscillationPositionFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationPositionFrequencyStartRandomized = false;
				this._oscillationPositionFrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._oscillationPositionFrequencyStart = value;
	}
	
	// oscillation position 2
	private var _oscillationPosition2Enabled:Bool = false;
	private var _oscillationPosition2GroupStep:Float;
	private var _oscillationPosition2GroupValue:Float;
	private var _oscillationPosition2GlobalFrequencyEnabled:Bool = false;
	private var _oscillationPosition2GroupFrequencyEnabled:Bool = false;
	private var _oscillationPosition2FrequencyStartRandomized:Bool = false;
	private var _oscillationPosition2FrequencyStartUnified:Bool = false;
	private var _oscillationPosition2AngleRelativeToRotation:Bool = true;
	private var _oscillationPosition2AngleRelativeToVelocity:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationPosition2FrequencyMode(get, set):String;
	private var _oscillationPosition2FrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationPosition2FrequencyMode():String { return this._oscillationPosition2FrequencyMode; }
	private function set_oscillationPosition2FrequencyMode(value:String):String
	{
		if (this._oscillationPosition2FrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationPosition2GlobalFrequencyEnabled = true;
				this._oscillationPosition2GroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationPosition2GlobalFrequencyEnabled = false;
				this._oscillationPosition2GroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationPosition2GlobalFrequencyEnabled = false;
				this._oscillationPosition2GroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationPosition2FrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationPosition2GroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationPosition2Angle:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationPosition2AngleVariance:Float = 0.0;
	
	/**
	   see AngleRelativeTo for possible values
	   @default	AngleRelativeTo.ROTATION
	**/
	public var oscillationPosition2AngleRelativeTo(get, set):String;
	private var _oscillationPosition2AngleRelativeTo:String = AngleRelativeTo.ROTATION;
	private function get_oscillationPosition2AngleRelativeTo():String { return this._oscillationPosition2AngleRelativeTo; }
	private function set_oscillationPosition2AngleRelativeTo(value:String):String
	{
		if (this._oscillationPositionAngleRelativeTo == value) return value;
		
		switch (value)
		{
			case AngleRelativeTo.ABSOLUTE :
				this._oscillationPosition2AngleRelativeToRotation = false;
				this._oscillationPosition2AngleRelativeToVelocity = false;
			
			case AngleRelativeTo.ROTATION :
				this._oscillationPosition2AngleRelativeToRotation = true;
				this._oscillationPosition2AngleRelativeToVelocity = false;
			
			case AngleRelativeTo.VELOCITY :
				this._oscillationPosition2AngleRelativeToRotation = false;
				this._oscillationPosition2AngleRelativeToVelocity = true;
			
			default :
				throw new Error("unknown AngleRelativeTo ::: " + value);
		}
		
		return this._oscillationPosition2AngleRelativeTo = value;
	}
	
	/**
	   @default 0
	**/
	public var oscillationPosition2Radius(get, set):Float;
	private var _oscillationPosition2Radius:Float = 0.0;
	private function get_oscillationPosition2Radius():Float { return this._oscillationPosition2Radius; }
	private function set_oscillationPosition2Radius(value:Float):Float
	{
		this._oscillationPosition2Enabled = value != 0.0 || this._oscillationPosition2RadiusVariance != 0.0;
		return this._oscillationPosition2Radius = value;
	}
	
	/**
	   @default 0
	**/
	public var oscillationPosition2RadiusVariance(get, set):Float;
	private var _oscillationPosition2RadiusVariance:Float = 0.0;
	private function get_oscillationPosition2RadiusVariance():Float { return this._oscillationPosition2RadiusVariance; }
	private function set_oscillationPosition2RadiusVariance(value:Float):Float
	{
		this._oscillationPosition2Enabled = value != 0.0 || this._oscillationPosition2Radius != 0.0;
		return this._oscillationPosition2RadiusVariance = value;
	}
	
	/**
	   @default 1.0
	**/
	public var oscillationPosition2Frequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var oscillationPosition2UnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationPosition2UnifiedFrequencyVariance:Bool = false;
	private function get_oscillationPosition2UnifiedFrequencyVariance():Bool { return this._oscillationPosition2UnifiedFrequencyVariance; }
	private function set_oscillationPosition2UnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationPosition2UnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationPosition2UnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationPosition2FrequencyVariance:Float = 0.0;
	
	/**
	   
	**/
	public var oscillationPosition2FrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationPosition2FrequencyStart(get, set):String;
	private var _oscillationPosition2FrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationPosition2FrequencyStart():String { return this._oscillationPosition2FrequencyStart; }
	private function set_oscillationPosition2FrequencyStart(value:String):String
	{
		if (this._oscillationPosition2FrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationPosition2FrequencyStartRandomized = false;
				this._oscillationPosition2FrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationPosition2FrequencyStartRandomized = true;
				this._oscillationPosition2FrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationPosition2FrequencyStartRandomized = false;
				this._oscillationPosition2FrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._oscillationPosition2FrequencyStart = value;
	}
	
	// oscillation rotation
	private var _oscillationRotationEnabled:Bool = false;
	private var _oscillationRotationGroupStep:Float;
	private var _oscillationRotationGroupValue:Float;
	private var _oscillationRotationGlobalFrequencyEnabled:Bool = false;
	private var _oscillationRotationGroupFrequencyEnabled:Bool = false;
	private var _oscillationRotationFrequencyStartRandomized:Bool = false;
	private var _oscillationRotationFrequencyStartUnified:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationRotationFrequencyMode(get, set):String;
	private var _oscillationRotationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationRotationFrequencyMode():String { return this._oscillationRotationFrequencyMode; }
	private function set_oscillationRotationFrequencyMode(value:String):String
	{
		if (this._oscillationRotationFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationRotationGlobalFrequencyEnabled = true;
				this._oscillationRotationGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationRotationGlobalFrequencyEnabled = false;
				this._oscillationRotationGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationRotationGlobalFrequencyEnabled = false;
				this._oscillationRotationGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationRotationFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationRotationGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationRotationAngle(get, set):Float;
	private var _oscillationRotationAngle:Float = 0.0;
	private function get_oscillationRotationAngle():Float { return this._oscillationRotationAngle; }
	private function set_oscillationRotationAngle(value:Float):Float
	{
		this._oscillationRotationEnabled = value != 0.0 || this._oscillationRotationAngleVariance != 0.0;
		return this._oscillationRotationAngle = value;
	}
	
	/**
	   @default 0
	**/
	public var oscillationRotationAngleVariance(get, set):Float;
	private var _oscillationRotationAngleVariance:Float = 0.0;
	private function get_oscillationRotationAngleVariance():Float { return this._oscillationRotationAngleVariance; }
	private function set_oscillationRotationAngleVariance(value:Float):Float
	{
		this._oscillationRotationEnabled = value != 0.0 || this._oscillationRotationAngle != 0.0;
		return this._oscillationRotationAngleVariance = value;
	}
	
	/**
	   @default	1
	**/
	public var oscillationRotationFrequency:Float = 1.0;
	
	/**
	   @default false
	**/
	public var oscillationRotationUnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationRotationUnifiedFrequencyVariance:Bool = false;
	private function get_oscillationRotationUnifiedFrequencyVariance():Bool { return this._oscillationRotationUnifiedFrequencyVariance; }
	private function set_oscillationRotationUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationRotationUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationRotationUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationRotationFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationRotationFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationRotationFrequencyStart(get, set):String;
	private var _oscillationRotationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationRotationFrequencyStart():String { return this._oscillationRotationFrequencyStart; }
	private function set_oscillationRotationFrequencyStart(value:String):String
	{
		if (this._oscillationRotationFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationRotationFrequencyStartRandomized = false;
				this._oscillationRotationFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationRotationFrequencyStartRandomized = true;
				this._oscillationRotationFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationRotationFrequencyStartRandomized = false;
				this._oscillationRotationFrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._oscillationRotationFrequencyStart = value;
	}
	
	// oscillation scaleX
	private var _oscillationScaleXEnabled:Bool = false;
	private var _oscillationScaleXGroupStep:Float;
	private var _oscillationScaleXGroupValue:Float;
	private var _oscillationScaleXGlobalFrequencyEnabled:Bool = false;
	private var _oscillationScaleXGroupFrequencyEnabled:Bool = false;
	private var _oscillationScaleXFrequencyStartRandomized:Bool = false;
	private var _oscillationScaleXFrequencyStartUnified:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationScaleXFrequencyMode(get, set):String;
	private var _oscillationScaleXFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationScaleXFrequencyMode():String { return this._oscillationScaleXFrequencyMode; }
	private function set_oscillationScaleXFrequencyMode(value:String):String
	{
		if (this._oscillationScaleXFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationScaleXGlobalFrequencyEnabled = true;
				this._oscillationScaleXGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationScaleXGlobalFrequencyEnabled = false;
				this._oscillationScaleXGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationScaleXGlobalFrequencyEnabled = false;
				this._oscillationScaleXGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationScaleXFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationScaleXGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationScaleX(get, set):Float;
	private var _oscillationScaleX:Float = 0.0;
	private function get_oscillationScaleX():Float { return this._oscillationScaleX; }
	private function set_oscillationScaleX(value:Float):Float
	{
		this._oscillationScaleX = value;
		this._oscillationScaleXEnabled = this._oscillationScaleX != 0.0 || this._oscillationScaleXVariance != 0.0;
		return this._oscillationScaleX;
	}
	
	/**
	   @default 0
	**/
	public var oscillationScaleXVariance(get, set):Float;
	private var _oscillationScaleXVariance:Float = 0.0;
	private function get_oscillationScaleXVariance():Float { return this._oscillationScaleXVariance; }
	private function set_oscillationScaleXVariance(value:Float):Float
	{
		this._oscillationScaleXVariance = value;
		this._oscillationScaleXEnabled = this._oscillationScaleX != 0.0 || this._oscillationScaleXVariance != 0.0;
		return this._oscillationScaleXVariance;
	}
	
	/**
	   @default 1
	**/
	public var oscillationScaleXFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var oscillationScaleXUnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationScaleXUnifiedFrequencyVariance:Bool = false;
	private function get_oscillationScaleXUnifiedFrequencyVariance():Bool { return this._oscillationScaleXUnifiedFrequencyVariance; }
	private function set_oscillationScaleXUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationScaleXUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationScaleXUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationScaleXFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationScaleXFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationScaleXFrequencyStart(get, set):String;
	private var _oscillationScaleXFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationScaleXFrequencyStart():String { return this._oscillationScaleXFrequencyStart; }
	private function set_oscillationScaleXFrequencyStart(value:String):String
	{
		if (this._oscillationScaleXFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationScaleXFrequencyStartRandomized = false;
				this._oscillationScaleXFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationScaleXFrequencyStartRandomized = true;
				this._oscillationScaleXFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationScaleXFrequencyStartRandomized = false;
				this._oscillationScaleXFrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._oscillationScaleXFrequencyStart = value;
	}
	
	// oscillation scaleY
	private var _oscillationScaleYEnabled:Bool = false;
	private var _oscillationScaleYGroupStep:Float;
	private var _oscillationScaleYGroupValue:Float;
	private var _oscillationScaleYGlobalFrequencyEnabled:Bool = false;
	private var _oscillationScaleYGroupFrequencyEnabled:Bool = false;
	private var _oscillationScaleYFrequencyStartRandomized:Bool = false;
	private var _oscillationScaleYFrequencyStartUnified:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationScaleYFrequencyMode(get, set):String;
	private var _oscillationScaleYFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationScaleYFrequencyMode():String { return this._oscillationScaleYFrequencyMode; }
	private function set_oscillationScaleYFrequencyMode(value:String):String
	{
		if (this._oscillationScaleYFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationScaleYGlobalFrequencyEnabled = true;
				this._oscillationScaleYGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationScaleYGlobalFrequencyEnabled = false;
				this._oscillationScaleYGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationScaleYGlobalFrequencyEnabled = false;
				this._oscillationScaleYGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationScaleYFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationScaleYGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationScaleY(get, set):Float;
	private var _oscillationScaleY:Float = 0.0;
	private function get_oscillationScaleY():Float { return this._oscillationScaleY; }
	private function set_oscillationScaleY(value:Float):Float
	{
		this._oscillationScaleY = value;
		this._oscillationScaleYEnabled = this._oscillationScaleY != 0.0 || this._oscillationScaleYVariance != 0.0;
		return this._oscillationScaleY;
	}
	
	/**
	   @default 0
	**/
	public var oscillationScaleYVariance(get, set):Float;
	private var _oscillationScaleYVariance:Float = 0.0;
	private function get_oscillationScaleYVariance():Float { return this._oscillationScaleYVariance; }
	private function set_oscillationScaleYVariance(value:Float):Float
	{
		this._oscillationScaleYVariance = value;
		this._oscillationScaleYEnabled = this._oscillationScaleY != 0.0 || this._oscillationScaleYVariance != 0.0;
		return this._oscillationScaleYVariance;
	}
	
	/**
	   @default 1
	**/
	public var oscillationScaleYFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var oscillationScaleYUnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationScaleYUnifiedFrequencyVariance:Bool = false;
	private function get_oscillationScaleYUnifiedFrequencyVariance():Bool { return this._oscillationScaleYUnifiedFrequencyVariance; }
	private function set_oscillationScaleYUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationScaleYUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationScaleYUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationScaleYFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationScaleYFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationScaleYFrequencyStart(get, set):String;
	private var _oscillationScaleYFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationScaleYFrequencyStart():String { return this._oscillationScaleYFrequencyStart; }
	private function set_oscillationScaleYFrequencyStart(value:String):String
	{
		if (this._oscillationScaleYFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationScaleYFrequencyStartRandomized = false;
				this._oscillationScaleYFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationScaleYFrequencyStartRandomized = true;
				this._oscillationScaleYFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationScaleYFrequencyStartRandomized = false;
				this._oscillationScaleYFrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationScaleYFrequencyStart = value;
	}
	
	// oscillation skewX
	private var _oscillationSkewXEnabled:Bool = false;
	private var _oscillationSkewXGroupStep:Float;
	private var _oscillationSkewXGroupValue:Float;
	private var _oscillationSkewXGlobalFrequencyEnabled:Bool = false;
	private var _oscillationSkewXGroupFrequencyEnabled:Bool = false;
	private var _oscillationSkewXFrequencyStartRandomized:Bool = false;
	private var _oscillationSkewXFrequencyStartUnified:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationSkewXFrequencyMode(get, set):String;
	private var _oscillationSkewXFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationSkewXFrequencyMode():String { return this._oscillationSkewXFrequencyMode; }
	private function set_oscillationSkewXFrequencyMode(value:String):String
	{
		if (this._oscillationSkewXFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationSkewXGlobalFrequencyEnabled = true;
				this._oscillationSkewXGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationSkewXGlobalFrequencyEnabled = false;
				this._oscillationSkewXGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationSkewXGlobalFrequencyEnabled = false;
				this._oscillationSkewXGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationSkewXFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationSkewXGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationSkewX(get, set):Float;
	private var _oscillationSkewX:Float = 0.0;
	private function get_oscillationSkewX():Float { return this._oscillationSkewX; }
	private function set_oscillationSkewX(value:Float):Float
	{
		this._oscillationSkewX = value;
		this._oscillationSkewXEnabled = this._oscillationSkewX != 0.0 || this._oscillationSkewXVariance != 0.0;
		return this._oscillationSkewX;
	}
	
	/**
	   @default 0
	**/
	public var oscillationSkewXVariance(get, set):Float;
	private var _oscillationSkewXVariance:Float = 0.0;
	private function get_oscillationSkewXVariance():Float { return this._oscillationSkewXVariance; }
	private function set_oscillationSkewXVariance(value:Float):Float
	{
		this._oscillationSkewXVariance = value;
		this._oscillationSkewXEnabled = this._oscillationSkewX != 0.0 || this._oscillationSkewXVariance != 0.0;
		return this._oscillationSkewXVariance;
	}
	
	/**
	   @default 1
	**/
	public var oscillationSkewXFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var oscillationSkewXUnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationSkewXUnifiedFrequencyVariance:Bool = false;
	private function get_oscillationSkewXUnifiedFrequencyVariance():Bool { return this._oscillationSkewXUnifiedFrequencyVariance; }
	private function set_oscillationSkewXUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationSkewXUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationSkewXUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationSkewXFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationSkewXFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationSkewXFrequencyStart(get, set):String;
	private var _oscillationSkewXFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationSkewXFrequencyStart():String { return this._oscillationSkewXFrequencyStart; }
	private function set_oscillationSkewXFrequencyStart(value:String):String
	{
		if (this._oscillationSkewXFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationSkewXFrequencyStartRandomized = false;
				this._oscillationSkewXFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationSkewXFrequencyStartRandomized = true;
				this._oscillationSkewXFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationSkewXFrequencyStartRandomized = false;
				this._oscillationSkewXFrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._oscillationSkewXFrequencyStart = value;
	}
	
	// oscillation skewY
	private var _oscillationSkewYEnabled:Bool = false;
	private var _oscillationSkewYGroupStep:Float;
	private var _oscillationSkewYGroupValue:Float;
	private var _oscillationSkewYGlobalFrequencyEnabled:Bool = false;
	private var _oscillationSkewYGroupFrequencyEnabled:Bool = false;
	private var _oscillationSkewYFrequencyStartRandomized:Bool = false;
	private var _oscillationSkewYFrequencyStartUnified:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationSkewYFrequencyMode(get, set):String;
	private var _oscillationSkewYFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationSkewYFrequencyMode():String { return this._oscillationSkewYFrequencyMode; }
	private function set_oscillationSkewYFrequencyMode(value:String):String
	{
		if (this._oscillationSkewYFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationSkewYGlobalFrequencyEnabled = true;
				this._oscillationSkewYGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationSkewYGlobalFrequencyEnabled = false;
				this._oscillationSkewYGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationSkewYGlobalFrequencyEnabled = false;
				this._oscillationSkewYGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationSkewYFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationSkewYGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationSkewY(get, set):Float;
	private var _oscillationSkewY:Float = 0.0;
	private function get_oscillationSkewY():Float { return this._oscillationSkewY; }
	private function set_oscillationSkewY(value:Float):Float
	{
		this._oscillationSkewY = value;
		this._oscillationSkewYEnabled = this._oscillationSkewY != 0.0 || this._oscillationSkewYVariance != 0.0;
		return this._oscillationSkewY;
	}
	
	/**
	   @default 0
	**/
	public var oscillationSkewYVariance(get, set):Float;
	private var _oscillationSkewYVariance:Float = 0.0;
	private function get_oscillationSkewYVariance():Float { return this._oscillationSkewYVariance; }
	private function set_oscillationSkewYVariance(value:Float):Float
	{
		this._oscillationSkewYVariance = value;
		this._oscillationSkewYEnabled = this._oscillationSkewY != 0.0 || this._oscillationSkewYVariance != 0.0;
		return this._oscillationSkewYVariance;
	}
	
	/**
	   @default 1
	**/
	public var oscillationSkewYFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var oscillationSkewYUnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationSkewYUnifiedFrequencyVariance:Bool = false;
	private function get_oscillationSkewYUnifiedFrequencyVariance():Bool { return this._oscillationSkewYUnifiedFrequencyVariance; }
	private function set_oscillationSkewYUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationSkewYUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationSkewYUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationSkewYFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationSkewYFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationSkewYFrequencyStart(get, set):String;
	private var _oscillationSkewYFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationSkewYFrequencyStart():String { return this._oscillationSkewYFrequencyStart; }
	private function set_oscillationSkewYFrequencyStart(value:String):String
	{
		if (this._oscillationSkewYFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationSkewYFrequencyStartRandomized = false;
				this._oscillationSkewYFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationSkewYFrequencyStartRandomized = true;
				this._oscillationSkewYFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationSkewYFrequencyStartRandomized = false;
				this._oscillationSkewYFrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._oscillationSkewYFrequencyStart = value;
	}
	
	// oscillation color
	private var _useOscillationColor:Bool = false;
	private var _oscillationColorGroupStep:Float;
	private var _oscillationColorGroupValue:Float;
	private var _oscillationColorGlobalFrequencyEnabled:Bool = false;
	private var _oscillationColorGroupFrequencyEnabled:Bool = false;
	private var _oscillationColorFrequencyStartRandomized:Bool = false;
	private var _oscillationColorFrequencyStartUnified:Bool = false;
	
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationColorFrequencyMode(get, set):String;
	private var _oscillationColorFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	private function get_oscillationColorFrequencyMode():String { return this._oscillationColorFrequencyMode; }
	private function set_oscillationColorFrequencyMode(value:String):String
	{
		if (this._oscillationColorFrequencyMode == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyMode.GLOBAL :
				this._oscillationColorGlobalFrequencyEnabled = true;
				this._oscillationColorGroupFrequencyEnabled = false;
			
			case OscillationFrequencyMode.GROUP :
				this._oscillationColorGlobalFrequencyEnabled = false;
				this._oscillationColorGroupFrequencyEnabled = true;
			
			case OscillationFrequencyMode.SINGLE :
				this._oscillationColorGlobalFrequencyEnabled = false;
				this._oscillationColorGroupFrequencyEnabled = false;
			
			default :
				throw new Error("unknown OscillationFrequencyMode ::: " + value);
		}
		
		checkOscillationGlobalFrequency();
		
		return this._oscillationColorFrequencyMode = value;
	}
	
	/**
	   @default	0
	**/
	public var oscillationColorGroupStartStep:Float = 0.0;
	
	/**
	   @default 0
	**/
	public var oscillationColorRed(get, set):Float;
	private var _oscillationColorRed:Float = 0.0;
	private function get_oscillationColorRed():Float { return this._oscillationColorRed; }
	private function set_oscillationColorRed(value:Float):Float
	{
		this._oscillationColorRed = value;
		this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
									this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		return this._oscillationColorRed;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorGreen(get, set):Float;
	private var _oscillationColorGreen:Float = 0.0;
	private function get_oscillationColorGreen():Float { return this._oscillationColorGreen; }
	private function set_oscillationColorGreen(value:Float):Float
	{
		this._oscillationColorGreen = value;
		this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
									this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		return this._oscillationColorGreen;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorBlue(get, set):Float;
	private var _oscillationColorBlue:Float = 0.0;
	private function get_oscillationColorBlue():Float { return this._oscillationColorBlue; }
	private function set_oscillationColorBlue(value:Float):Float
	{
		this._oscillationColorBlue = value;
		this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
									this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		return this._oscillationColorBlue;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorAlpha(get, set):Float;
	private var _oscillationColorAlpha:Float = 0.0;
	private function get_oscillationColorAlpha():Float { return this._oscillationColorAlpha; }
	private function set_oscillationColorAlpha(value:Float):Float
	{
		this._oscillationColorAlpha = value;
		this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
									this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		return this._oscillationColorAlpha;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorRedVariance(get, set):Float;
	private var _oscillationColorRedVariance:Float = 0.0;
	private function get_oscillationColorRedVariance():Float { return this._oscillationColorRedVariance; }
	private function set_oscillationColorRedVariance(value:Float):Float
	{
		this._oscillationColorRedVariance = value;
		this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
									this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
		return this._oscillationColorRedVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorGreenVariance(get, set):Float;
	private var _oscillationColorGreenVariance:Float = 0.0;
	private function get_oscillationColorGreenVariance():Float { return this._oscillationColorGreenVariance; }
	private function set_oscillationColorGreenVariance(value:Float):Float
	{
		this._oscillationColorGreenVariance = value;
		checkOscillationColor();
		return this._oscillationColorGreenVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorBlueVariance(get, set):Float;
	private var _oscillationColorBlueVariance:Float = 0.0;
	private function get_oscillationColorBlueVariance():Float { return this._oscillationColorBlueVariance; }
	private function set_oscillationColorBlueVariance(value:Float):Float
	{
		this._oscillationColorBlueVariance = value;
		checkOscillationColor();
		return this._oscillationColorBlueVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorAlphaVariance(get, set):Float;
	private var _oscillationColorAlphaVariance:Float = 0.0;
	private function get_oscillationColorAlphaVariance():Float { return this._oscillationColorAlphaVariance; }
	private function set_oscillationColorAlphaVariance(value:Float):Float
	{
		this._oscillationColorAlphaVariance = value;
		checkOscillationColor();
		return this._oscillationColorAlphaVariance;
	}
	
	/**
	   @default 1.0
	**/
	public var oscillationColorFrequency:Float = 1.0;
	
	/**
	   @default	false
	**/
	public var oscillationColorUnifiedFrequencyVariance(get, set):Bool;
	private var _oscillationColorUnifiedFrequencyVariance:Bool = false;
	private function get_oscillationColorUnifiedFrequencyVariance():Bool { return this._oscillationColorUnifiedFrequencyVariance; }
	private function set_oscillationColorUnifiedFrequencyVariance(value:Bool):Bool
	{
		this._oscillationColorUnifiedFrequencyVariance = value;
		checkOscillationUnifiedFrequencyVariance();
		return this._oscillationColorUnifiedFrequencyVariance;
	}
	
	/**
	   @default 0
	**/
	public var oscillationColorFrequencyVariance:Float = 0.0;
	
	/**
	   @default	false
	**/
	public var oscillationColorFrequencyInverted:Bool = false;
	
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationColorFrequencyStart(get, set):String;
	private var _oscillationColorFrequencyStart:String = OscillationFrequencyStart.ZERO;
	private function get_oscillationColorFrequencyStart():String { return this._oscillationColorFrequencyStart; }
	private function set_oscillationColorFrequencyStart(value:String):String
	{
		if (this._oscillationColorFrequencyStart == value) return value;
		
		switch (value)
		{
			case OscillationFrequencyStart.ZERO :
				this._oscillationColorFrequencyStartRandomized = false;
				this._oscillationColorFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.RANDOM :
				this._oscillationColorFrequencyStartRandomized = true;
				this._oscillationColorFrequencyStartUnified = false;
			
			case OscillationFrequencyStart.UNIFIED_RANDOM :
				this._oscillationColorFrequencyStartRandomized = false;
				this._oscillationColorFrequencyStartUnified = true;
			
			default :
				throw new Error("unknown OscillationFrequencyStart ::: " + value);
		}
		
		checkOscillationUnifiedFrequencyStart();
		
		return this._oscillationColorFrequencyStart = value;
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
	
	private var _completed:Bool = false;
	private var _frameTime:Float = 0.0;
	#if flash
	private var _particles:Vector<T>;
	#else
	private var _particles:Array<T>;
	#end
	private var _particleTotal:Int = 0;
	private var _regularSorting:Bool = true;
	private var _updateEmitter:Bool = false;
	
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
		this._emissionTime = 0.0;
		this._frameTime = 0.0;
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
	private var __colorAlphaStart:Float;
	private var __colorAlphaEnd:Float;
	private var __colorBlueStart:Float;
	private var __colorBlueEnd:Float;
	private var __colorGreenStart:Float;
	private var __colorGreenEnd:Float;
	private var __colorRedStart:Float;
	private var __colorRedEnd:Float;
	private var __firstFrameWidth:Float;
	private var __intAngle:Int;
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
	
	private function initParticle(particle:T):Void
	{
		#if debug
		particle.updateCount = 0;
		#end
		
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
				return;
			}
		}
		
		if (this._isTypeGravity)
		{
			this.__speed = this.speed + this.speedVariance * getRandomRatio();
			if (this.adjustLifeSpanToSpeed)
			{
				this.__ratio = this.speed / this.__speed;
				this.__lifeSpan *= this.__ratio;
			}
			particle.speed = this.__speed;
		}
		
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
		
		if (this._useEmitterRadius)
		{
			this.__angle = MathUtils.random() * MathUtils.PI2;
			this.__radiusMin = this._emitterRadiusMin + this._emitterRadiusMinVariance * getRandomRatio();
			this.__radiusMax = this._emitterRadiusMax + this._emitterRadiusMaxVariance * getRandomRatio();
			this.__radius = this.__radiusMin + MathUtils.random() * (this.__radiusMax - this.__radiusMin);
			
			particle.startX = particle.xBase = this.emitterX + this.emitterXVariance * getRandomRatio() + Math.cos(this.__angle) * this.__radius;
			particle.startY = particle.yBase = this.emitterY + this.emitterYVariance * getRandomRatio() + Math.sin(this.__angle) * this.__radius;
		}
		else
		{
			particle.startX = particle.xBase = this.emitterX + this.emitterXVariance * getRandomRatio();
			particle.startY = particle.yBase = this.emitterY + this.emitterYVariance * getRandomRatio();
		}
		
		particle.angle = this.__angle = this.emitAngle + this.emitAngleVariance * getRandomRatio();
		
		if (this._isTypeGravity)
		{
			particle.velocityX = this.__speed * Math.cos(this.__angle);
			particle.velocityY = this.__speed * Math.sin(this.__angle);
		}
		
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
		
		if (this._isTypeRadial)
		{
			particle.emitRadius = this.radiusMax + this.radiusMaxVariance * getRandomRatio();
			particle.emitRadiusDelta = (this.radiusMin + this.radiusMinVariance * getRandomRatio() - particle.emitRadius) / this.__lifeSpan;
			particle.emitRotation = this.emitAngle + this.emitAngleVariance * getRandomRatio();
			particle.emitRotationDelta = this.rotatePerSecond + this.rotatePerSecondVariance * getRandomRatio();
		}
		if (this._useRadialAcceleration) particle.radialAcceleration = this._radialAcceleration + this._radialAccelerationVariance * getRandomRatio();
		if (this._useTangentialAcceleration) particle.tangentialAcceleration = this._tangentialAcceleration + this._tangentialAccelerationVariance * getRandomRatio();
		
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
		else
		{
			particle.skewYBase = 0.0;
		}
		
		// OSCILLATION
		if (this._useOscillationUnifiedFrequencyStart)
		{
			this.__oscillationUnifiedFrequencyStart = MathUtils.random() * MathUtils.PI2;
		}
		if (this._useOscillationUnifiedFrequencyVariance)
		{
			this.__oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance * getRandomRatio();
		}
		
		if (this._oscillationPositionEnabled)
		{
			particle.oscillationPositionAngle = this.oscillationPositionAngle + this.oscillationPositionAngleVariance * getRandomRatio();
			particle.oscillationPositionRadius = this._oscillationPositionRadius + this._oscillationPositionRadiusVariance * getRandomRatio();
			if (!this._oscillationPositionGlobalFrequencyEnabled && !this._oscillationPositionGroupFrequencyEnabled)
			{
				if (this._oscillationPositionUnifiedFrequencyVariance)
				{
					particle.oscillationPositionFrequency = this.oscillationPositionFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationPositionFrequency = this.oscillationPositionFrequency + this.oscillationPositionFrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationPositionFrequencyStartRandomized)
				{
					particle.oscillationPositionStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationPositionFrequencyStartUnified)
				{
					particle.oscillationPositionStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationPositionStep = 0.0;
				}
			}
		}
		else
		{
			particle.oscillationPositionX = particle.oscillationPositionY = 0.0;
		}
		
		if (this._oscillationPosition2Enabled)
		{
			particle.oscillationPosition2Angle = this.oscillationPosition2Angle + this.oscillationPosition2AngleVariance * getRandomRatio();
			particle.oscillationPosition2Radius = this._oscillationPosition2Radius + this._oscillationPosition2RadiusVariance * getRandomRatio();
			if (!this._oscillationPosition2GlobalFrequencyEnabled && !this._oscillationPosition2GroupFrequencyEnabled)
			{
				if (this._oscillationPosition2UnifiedFrequencyVariance)
				{
					particle.oscillationPosition2Frequency = this.oscillationPosition2Frequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationPosition2Frequency = this.oscillationPosition2Frequency + this.oscillationPosition2FrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationPosition2FrequencyStartRandomized)
				{
					particle.oscillationPosition2Step = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationPosition2FrequencyStartUnified)
				{
					particle.oscillationPosition2Step = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationPosition2Step = 0.0;
				}
			}
		}
		else
		{
			particle.oscillationPosition2X = particle.oscillationPosition2Y = 0.0;
		}
		
		if (this._oscillationRotationEnabled)
		{
			particle.oscillationRotationAngle = this._oscillationRotationAngle + this._oscillationRotationAngleVariance * getRandomRatio();
			if (!this._oscillationRotationGlobalFrequencyEnabled && !this._oscillationRotationGroupFrequencyEnabled)
			{
				if (this._oscillationRotationUnifiedFrequencyVariance)
				{
					particle.oscillationRotationFrequency = this.oscillationRotationFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationRotationFrequency = this.oscillationRotationFrequency + this.oscillationRotationFrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationRotationFrequencyStartRandomized)
				{
					particle.oscillationRotationStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationRotationFrequencyStartUnified)
				{
					particle.oscillationRotationStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationRotationStep = 0.0;
				}
			}
		}
		else
		{
			particle.oscillationRotation = 0.0;
		}
		
		if (this._oscillationScaleXEnabled)
		{
			particle.oscillationScaleX = this._oscillationScaleX + this._oscillationScaleXVariance * getRandomRatio();
			if (!this._oscillationScaleXGlobalFrequencyEnabled && !this._oscillationScaleXGroupFrequencyEnabled)
			{
				if (this._oscillationScaleXUnifiedFrequencyVariance)
				{
					particle.oscillationScaleXFrequency = this.oscillationScaleXFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationScaleXFrequency = this.oscillationScaleXFrequency + this.oscillationScaleXFrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationScaleXFrequencyStartRandomized)
				{
					particle.oscillationScaleXStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationScaleXFrequencyStartUnified)
				{
					particle.oscillationScaleXStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationScaleXStep = 0.0;
				}
			}
		}
		else
		{
			particle.scaleXOscillation = 1.0;
		}
		
		if (this._oscillationScaleYEnabled)
		{
			particle.oscillationScaleY = this._oscillationScaleY + this._oscillationScaleYVariance * getRandomRatio();
			if (!this._oscillationScaleYGlobalFrequencyEnabled && !this._oscillationScaleYGroupFrequencyEnabled)
			{
				if (this._oscillationScaleYUnifiedFrequencyVariance)
				{
					particle.oscillationScaleYFrequency = this.oscillationScaleYFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationScaleYFrequency = this.oscillationScaleYFrequency + this.oscillationScaleYFrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationScaleYFrequencyStartRandomized)
				{
					particle.oscillationScaleYStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationScaleYFrequencyStartUnified)
				{
					particle.oscillationScaleYStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationScaleYStep = 0.0;
				}
			}
		}
		else
		{
			particle.scaleYOscillation = 1.0;
		}
		
		if (this._oscillationSkewXEnabled)
		{
			particle.oscillationSkewX = this._oscillationSkewX + this._oscillationSkewXVariance * getRandomRatio();
			if (!this._oscillationSkewXGlobalFrequencyEnabled && !this._oscillationSkewXGroupFrequencyEnabled)
			{
				if (this._oscillationSkewXUnifiedFrequencyVariance)
				{
					particle.oscillationSkewXFrequency = this.oscillationSkewXFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationSkewXFrequency = this.oscillationSkewXFrequency + this.oscillationSkewXFrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationSkewXFrequencyStartRandomized)
				{
					particle.oscillationSkewXStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationSkewXFrequencyStartUnified)
				{
					particle.oscillationSkewXStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationSkewXStep = 0.0;
				}
			}
		}
		else
		{
			particle.skewXOscillation = 0.0;
		}
		
		if (this._oscillationSkewYEnabled)
		{
			particle.oscillationSkewY = this._oscillationSkewY + this._oscillationSkewYVariance * getRandomRatio();
			if (!this._oscillationSkewYGlobalFrequencyEnabled && !this._oscillationSkewYGroupFrequencyEnabled)
			{
				if (this._oscillationSkewYUnifiedFrequencyVariance)
				{
					particle.oscillationSkewYFrequency = this.oscillationSkewYFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationSkewYFrequency = this.oscillationSkewYFrequency + this.oscillationSkewYFrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationSkewYFrequencyStartRandomized)
				{
					particle.oscillationSkewYStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationSkewYFrequencyStartUnified)
				{
					particle.oscillationSkewYStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationSkewYStep = 0.0;
				}
			}
		}
		else
		{
			particle.skewYOscillation = 0.0;
		}
		
		if (this._useOscillationColor)
		{
			particle.oscillationColorRedFactor = this._oscillationColorRed + this._oscillationColorRedVariance * getRandomRatio();
			particle.oscillationColorGreenFactor = this._oscillationColorGreen + this._oscillationColorGreenVariance * getRandomRatio();
			particle.oscillationColorBlueFactor = this._oscillationColorBlue + this._oscillationColorBlueVariance * getRandomRatio();
			particle.oscillationColorAlphaFactor = this._oscillationColorAlpha + this._oscillationColorAlphaVariance * getRandomRatio();
			if (!this._oscillationColorGlobalFrequencyEnabled && !this._oscillationColorGroupFrequencyEnabled)
			{
				if (this._oscillationColorUnifiedFrequencyVariance)
				{
					particle.oscillationColorFrequency = this.oscillationColorFrequency + this.__oscillationUnifiedFrequencyVariance;
				}
				else
				{
					particle.oscillationColorFrequency = this.oscillationColorFrequency + this.oscillationColorFrequencyVariance * getRandomRatio();
				}
				
				if (this._oscillationColorFrequencyStartRandomized)
				{
					particle.oscillationColorStep = MathUtils.random() * MathUtils.PI2;
				}
				else if (this._oscillationColorFrequencyStartUnified)
				{
					particle.oscillationColorStep = this.__oscillationUnifiedFrequencyStart;
				}
				else
				{
					particle.oscillationColorStep = 0.0;
				}
			}
		}
		else
		{
			particle.oscillationColorRed = particle.oscillationColorGreen = particle.oscillationColorBlue = particle.oscillationColorAlpha = 0.0;
		}
		//\OSCILLATION
		
		this.__colorRedStart = this.colorStart.redValue + this.colorStartVariance.redValue * getRandomRatio();
		this.__colorGreenStart = this.colorStart.greenValue + this.colorStartVariance.greenValue * getRandomRatio();
		this.__colorBlueStart = this.colorStart.blueValue + this.colorStartVariance.blueValue * getRandomRatio();
		this.__colorAlphaStart = this.colorStart.alphaValue + this.colorStartVariance.alphaValue * getRandomRatio();
		
		if (this._useColor)
		{
			if (this.colorEndRelativeToStart)
			{
				if (this.colorEndIsMultiplier)
				{
					this.__colorRedEnd = this.__colorRedStart * (this.colorEnd.redValue + this.colorEndVariance.redValue * getRandomRatio());
					this.__colorGreenEnd = this.__colorGreenStart * (this.colorEnd.greenValue + this.colorEndVariance.greenValue * getRandomRatio());
					this.__colorBlueEnd = this.__colorBlueStart * (this.colorEnd.blueValue + this.colorEndVariance.blueValue * getRandomRatio());
					this.__colorAlphaEnd = this.__colorAlphaStart * (this.colorEnd.alphaValue + this.colorEndVariance.alphaValue * getRandomRatio());
				}
				else
				{
					this.__colorRedEnd = this.__colorRedStart + this.colorEnd.redValue + this.colorEndVariance.redValue * getRandomRatio();
					this.__colorGreenEnd = this.__colorGreenStart + this.colorEnd.greenValue + this.colorEndVariance.greenValue * getRandomRatio();
					this.__colorBlueEnd = this.__colorBlueStart + this.colorEnd.blueValue + this.colorEndVariance.blueValue * getRandomRatio();
					this.__colorAlphaEnd = this.__colorAlphaStart + this.colorEnd.alphaValue + this.colorEndVariance.alphaValue * getRandomRatio();
				}
			}
			else
			{
				this.__colorRedEnd = this.colorEnd.redValue + this.colorEndVariance.redValue * getRandomRatio();
				this.__colorGreenEnd = this.colorEnd.greenValue + this.colorEndVariance.greenValue * getRandomRatio();
				this.__colorBlueEnd = this.colorEnd.blueValue + this.colorEndVariance.blueValue * getRandomRatio();
				this.__colorAlphaEnd = this.colorEnd.alphaValue + this.colorEndVariance.alphaValue * getRandomRatio();
			}
			
			particle.colorRedBase = this.__colorRedStart;
			particle.colorGreenBase = this.__colorGreenStart;
			particle.colorBlueBase = this.__colorBlueStart;
			particle.colorAlphaBase = this._useFadeIn ? 0.0 : this.__colorAlphaStart;
			
			particle.colorRedStart = this.__colorRedStart;
			particle.colorGreenStart = this.__colorGreenStart;
			particle.colorBlueStart = this.__colorBlueStart;
			particle.colorAlphaStart = this.__colorAlphaStart;
			
			particle.colorRedEnd = this.__colorRedEnd;
			particle.colorGreenEnd = this.__colorGreenEnd;
			particle.colorBlueEnd = this.__colorBlueEnd;
			particle.colorAlphaEnd = this.__colorAlphaEnd;
			
			particle.colorRedDelta = (this.__colorRedEnd - this.__colorRedStart) / this.__lifeSpan;
			particle.colorGreenDelta = (this.__colorGreenEnd - this.__colorGreenStart) / this.__lifeSpan;
			particle.colorBlueDelta = (this.__colorBlueEnd - this.__colorBlueStart) / this.__lifeSpan;
			particle.colorAlphaDelta = (this.__colorAlphaEnd - this.__colorAlphaStart) / this.__nonFadeTime; // we only interpolate alpha after fade in and before fade out
		}
		else
		{
			particle.colorRedBase = this.__colorRedStart;
			particle.colorGreenBase = this.__colorGreenStart;
			particle.colorBlueBase = this.__colorBlueStart;
			particle.colorAlphaBase = this._useFadeIn ? 0.0 : this.__colorAlphaStart;
			
			particle.colorAlphaStart = particle.colorAlphaEnd = this.__colorAlphaStart; // needed for fade in/out
		}
		
		particle.isFadingIn = this._useFadeIn;
		
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
		
		particle.rotationBase = this.__rotationStart;
		if (this._useRotation) particle.rotationDelta = (this.__rotationEnd - this.__rotationStart) / this.__lifeSpan;
		
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
	
	private function advanceParticle(particle:T, passedTime:Float):Void
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
		if (this._oscillationRotationEnabled)
		{
			if (this._oscillationRotationGlobalFrequencyEnabled)
			{
				if (this.oscillationRotationFrequencyInverted)
				{
					particle.oscillationRotation = this._oscillationGlobalValueInverted * particle.oscillationRotationAngle;
				}
				else
				{
					particle.oscillationRotation = this._oscillationGlobalValue * particle.oscillationRotationAngle;
				}
			}
			else if (this._oscillationRotationGroupFrequencyEnabled)
			{
				particle.oscillationRotation = this._oscillationRotationGroupValue * particle.oscillationRotationAngle;
			}
			else
			{
				particle.oscillationRotationStep += particle.oscillationRotationFrequency * passedTime;
				if (this.oscillationRotationFrequencyInverted)
				{
					particle.oscillationRotation = Math.sin(particle.oscillationRotationStep) * particle.oscillationRotationAngle;
				}
				else
				{
					particle.oscillationRotation = Math.cos(particle.oscillationRotationStep) * particle.oscillationRotationAngle;
				}
			}
			particle.rotation = particle.rotationBase + particle.oscillationRotation;
		}
		else
		{
			particle.rotation = particle.rotationBase;
		}
		
		if (this._oscillationPositionEnabled)
		{
			if (this._oscillationPositionAngleRelativeToRotation)
			{
				this.__refAngle = particle.rotation;
			}
			else if (this._oscillationPositionAngleRelativeToVelocity)
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
			
			if (this._oscillationPositionGlobalFrequencyEnabled)
			{
				if (this.oscillationPositionFrequencyInverted)
				{
					this.__radius = this._oscillationGlobalValueInverted * particle.oscillationPositionRadius;
				}
				else
				{
					this.__radius = this._oscillationGlobalValue * particle.oscillationPositionRadius;
				}
			}
			else if (this._oscillationPositionGroupFrequencyEnabled)
			{
				this.__radius = this._oscillationPositionGroupValue * particle.oscillationPositionRadius;
			}
			else
			{
				particle.oscillationPositionStep += particle.oscillationPositionFrequency * passedTime;
				if (this.oscillationPositionFrequencyInverted)
				{
					this.__radius = Math.sin(particle.oscillationPositionStep) * particle.oscillationPositionRadius;
				}
				else
				{
					this.__radius = Math.cos(particle.oscillationPositionStep) * particle.oscillationPositionRadius;
				}
			}
			this.__angle = this.__refAngle + particle.oscillationPositionAngle;
			particle.oscillationPositionX = Math.cos(this.__angle) * this.__radius;
			particle.oscillationPositionY = Math.sin(this.__angle) * this.__radius;
			
			particle.x += particle.oscillationPositionX;
			particle.y += particle.oscillationPositionY;
		}
		
		if (this._oscillationPosition2Enabled)
		{
			if (this._oscillationPosition2AngleRelativeToRotation)
			{
				this.__refAngle = particle.rotation;
			}
			else if (this._oscillationPosition2AngleRelativeToVelocity)
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
			
			if (this._oscillationPosition2GlobalFrequencyEnabled)
			{
				if (this.oscillationPosition2FrequencyInverted)
				{
					this.__radius = this._oscillationGlobalValueInverted * particle.oscillationPosition2Radius;
				}
				else
				{
					this.__radius = this._oscillationGlobalValue * particle.oscillationPosition2Radius;
				}
			}
			else if (this._oscillationPosition2GroupFrequencyEnabled)
			{
				this.__radius = this._oscillationPosition2GroupValue * particle.oscillationPosition2Radius;
			}
			else
			{
				particle.oscillationPosition2Step += particle.oscillationPosition2Frequency * passedTime;
				if (this.oscillationPosition2FrequencyInverted)
				{
					this.__radius = Math.sin(particle.oscillationPosition2Step) * particle.oscillationPosition2Radius;
				}
				else
				{
					this.__radius = Math.cos(particle.oscillationPosition2Step) * particle.oscillationPosition2Radius;
				}
			}
			this.__angle = this.__refAngle + particle.oscillationPosition2Angle;
			particle.oscillationPosition2X = Math.cos(this.__angle) * this.__radius;
			particle.oscillationPosition2Y = Math.sin(this.__angle) * this.__radius;
			
			particle.x += particle.oscillationPosition2X;
			particle.y += particle.oscillationPosition2Y;
		}
		
		if (this._oscillationScaleXEnabled)
		{
			if (this._oscillationScaleXGlobalFrequencyEnabled)
			{
				if (this.oscillationScaleXFrequencyInverted)
				{
					particle.scaleXOscillation = 1.0 + this._oscillationGlobalValueInverted * particle.oscillationScaleX;
				}
				else
				{
					particle.scaleXOscillation = 1.0 + this._oscillationGlobalValue * particle.oscillationScaleX;
				}
			}
			else if (this._oscillationScaleXGroupFrequencyEnabled)
			{
				particle.scaleXOscillation = 1.0 + this._oscillationScaleXGroupValue * particle.oscillationScaleX;
			}
			else
			{
				particle.oscillationScaleXStep += particle.oscillationScaleXFrequency * passedTime;
				if (this.oscillationScaleXFrequencyInverted)
				{
					particle.scaleXOscillation = 1.0 + Math.sin(particle.oscillationScaleXStep) * particle.oscillationScaleX;
				}
				else
				{
					particle.scaleXOscillation = 1.0 + Math.cos(particle.oscillationScaleXStep) * particle.oscillationScaleX;
				}
			}
		}
		
		if (this._oscillationScaleYEnabled)
		{
			if (this._oscillationScaleYGlobalFrequencyEnabled)
			{
				if (this.oscillationScaleYFrequencyInverted)
				{
					particle.scaleYOscillation = 1.0 + this._oscillationGlobalValueInverted * particle.oscillationScaleY;
				}
				else
				{
					particle.scaleYOscillation = 1.0 + this._oscillationGlobalValue * particle.oscillationScaleY;
				}
			}
			else if (this._oscillationScaleYGroupFrequencyEnabled)
			{
				particle.scaleYOscillation = 1.0 + this._oscillationScaleYGroupValue * particle.oscillationScaleY;
			}
			else
			{
				particle.oscillationScaleYStep += particle.oscillationScaleYFrequency * passedTime;
				if (this.oscillationScaleYFrequencyInverted)
				{
					particle.scaleYOscillation = 1.0 + Math.sin(particle.oscillationScaleYStep) * particle.oscillationScaleY;
				}
				else
				{
					particle.scaleYOscillation = 1.0 + Math.cos(particle.oscillationScaleYStep) * particle.oscillationScaleY;
				}
			}
		}
		
		if (this._oscillationSkewXEnabled)
		{
			if (this._oscillationSkewXGlobalFrequencyEnabled)
			{
				if (this.oscillationSkewXFrequencyInverted)
				{
					particle.skewXOscillation = this._oscillationGlobalValueInverted * particle.oscillationSkewX;
				}
				else
				{
					particle.skewXOscillation = this._oscillationGlobalValue * particle.oscillationSkewX;
				}
			}
			else if (this._oscillationSkewXGroupFrequencyEnabled)
			{
				particle.skewXOscillation = this._oscillationSkewXGroupValue * particle.oscillationSkewX;
			}
			else
			{
				particle.oscillationSkewXStep += particle.oscillationSkewXFrequency * passedTime;
				if (this.oscillationSkewXFrequencyInverted)
				{
					particle.skewXOscillation = Math.sin(particle.oscillationSkewXStep) * particle.oscillationSkewX;
				}
				else
				{
					particle.skewXOscillation = Math.cos(particle.oscillationSkewXStep) * particle.oscillationSkewX;
				}
			}
		}
		
		if (this._oscillationSkewYEnabled)
		{
			if (this._oscillationSkewYGlobalFrequencyEnabled)
			{
				if (this.oscillationSkewYFrequencyInverted)
				{
					particle.skewYOscillation = this._oscillationGlobalValueInverted * particle.oscillationSkewY;
				}
				else
				{
					particle.skewYOscillation = this._oscillationGlobalValue * particle.oscillationSkewY;
				}
			}
			else if (this._oscillationSkewYGroupFrequencyEnabled)
			{
				particle.skewYOscillation = this._oscillationSkewYGroupValue * particle.oscillationSkewY;
			}
			else
			{
				particle.oscillationSkewYStep += particle.oscillationSkewYFrequency * passedTime;
				if (this.oscillationSkewYFrequencyInverted)
				{
					particle.skewYOscillation = Math.sin(particle.oscillationSkewYStep) * particle.oscillationSkewY;
				}
				else
				{
					particle.skewYOscillation = Math.cos(particle.oscillationSkewYStep) * particle.oscillationSkewY;
				}
			}
		}
		//\OSCILLATION
		
		if (this.useDisplayRect)
		{
			if (!this.displayRect.contains(particle.x, particle.y))
			{
				particle.timeCurrent = particle.timeTotal; // "destroy" particle
				particle.visible = false;
				return;
			}
		}
		
		if (this._useVelocityScale || this._useVelocitySkew)
		{
			this.__velocityScalar = Math.sqrt(particle.velocityX * particle.velocityX + particle.velocityY * particle.velocityY);
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
			particle.colorRedBase += particle.colorRedDelta * passedTime;
			particle.colorGreenBase += particle.colorGreenDelta * passedTime;
			particle.colorBlueBase += particle.colorBlueDelta * passedTime;
		}
		
		if (this._useFadeIn && particle.timeCurrent <= particle.fadeInTime)
		{
			particle.colorAlphaBase = particle.colorAlphaStart * (particle.timeCurrent / particle.fadeInTime);
		}
		else if (this._useFadeOut && particle.timeCurrent >= particle.fadeOutTime)
		{
			particle.colorAlphaBase = particle.colorAlphaEnd * (1.0 - (particle.timeCurrent - particle.fadeOutTime) / particle.fadeOutDuration);
		}
		else
		{
			if (particle.isFadingIn)
			{
				particle.colorAlphaBase = particle.colorAlphaStart;
				particle.isFadingIn = false;
			}
			if (this._useColor) particle.colorAlphaBase += particle.colorAlphaDelta * passedTime;
		}
		
		// OSCILLATION COLOR
		if (this._useOscillationColor)
		{
			if (this._oscillationColorGlobalFrequencyEnabled)
			{
				if (this.oscillationColorFrequencyInverted)
				{
					this.__step = this._oscillationGlobalValueInverted;
				}
				else
				{
					this.__step = this._oscillationGlobalValue;
				}
			}
			else if (this._oscillationColorGroupFrequencyEnabled)
			{
				this.__step = this._oscillationColorGroupValue;
			}
			else
			{
				particle.oscillationColorStep += particle.oscillationColorFrequency * passedTime;
				if (this.oscillationColorFrequencyInverted)
				{
					this.__step = Math.sin(particle.oscillationColorStep);
				}
				else
				{
					this.__step = Math.cos(particle.oscillationColorStep);
				}
			}
			
			particle.oscillationColorRed = particle.oscillationColorRedFactor * this.__step;
			particle.oscillationColorGreen = particle.oscillationColorGreenFactor * this.__step;
			particle.oscillationColorBlue = particle.oscillationColorBlueFactor * this.__step;
			particle.oscillationColorAlpha = particle.oscillationColorAlphaFactor * this.__step;
			
			particle.red = particle.colorRedBase + particle.oscillationColorRed;
			particle.green = particle.colorGreenBase + particle.oscillationColorGreen;
			particle.blue = particle.colorBlueBase + particle.oscillationColorBlue;
			particle.alpha = particle.colorAlphaBase + particle.oscillationColorAlpha;
		}
		else
		{
			particle.red = particle.colorRedBase;
			particle.green = particle.colorGreenBase;
			particle.blue = particle.colorBlueBase;
			particle.alpha = particle.colorAlphaBase;
		}
		//\OSCILLATION COLOR
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
		
		if (this._oscillationPositionEnabled && this._oscillationPositionGroupFrequencyEnabled)
		{
			this._oscillationPositionGroupStep += this.oscillationPositionFrequency * time;
			if (this.oscillationPositionFrequencyInverted)
			{
				this._oscillationPositionGroupValue = Math.sin(this._oscillationPositionGroupStep);
			}
			else
			{
				this._oscillationPositionGroupValue = Math.cos(this._oscillationPositionGroupStep);
			}
		}
		
		if (this._oscillationPosition2Enabled && this._oscillationPosition2GroupFrequencyEnabled)
		{
			this._oscillationPosition2GroupStep += this.oscillationPosition2Frequency * time;
			if (this.oscillationPosition2FrequencyInverted)
			{
				this._oscillationPosition2GroupValue = Math.sin(this._oscillationPosition2GroupStep);
			}
			else
			{
				this._oscillationPosition2GroupValue = Math.cos(this._oscillationPosition2GroupStep);
			}
		}
		
		if (this._oscillationRotationEnabled && this._oscillationRotationGroupFrequencyEnabled)
		{
			this._oscillationRotationGroupStep += this.oscillationRotationFrequency * time;
			if (this.oscillationRotationFrequencyInverted)
			{
				this._oscillationRotationGroupValue = Math.sin(this._oscillationRotationGroupStep);
			}
			else
			{
				this._oscillationRotationGroupValue = Math.cos(this._oscillationRotationGroupStep);
			}
		}
		
		if (this._oscillationScaleXEnabled && this._oscillationScaleXGroupFrequencyEnabled)
		{
			this._oscillationScaleXGroupStep += this.oscillationScaleXFrequency * time;
			if (this.oscillationScaleXFrequencyInverted)
			{
				this._oscillationScaleXGroupValue = Math.sin(this._oscillationScaleXGroupStep);
			}
			else
			{
				this._oscillationScaleXGroupValue = Math.cos(this._oscillationScaleXGroupStep);
			}
		}
		
		if (this._oscillationScaleYEnabled && this._oscillationScaleYGroupFrequencyEnabled)
		{
			this._oscillationScaleYGroupStep += this.oscillationScaleYFrequency * time;
			if (this.oscillationScaleYFrequencyInverted)
			{
				this._oscillationScaleYGroupValue = Math.sin(this._oscillationScaleYGroupStep);
			}
			else
			{
				this._oscillationScaleYGroupValue = Math.cos(this._oscillationScaleYGroupStep);
			}
		}
		
		if (this._oscillationSkewXEnabled && this._oscillationSkewXGroupFrequencyEnabled)
		{
			this._oscillationSkewXGroupStep += this.oscillationSkewXFrequency * time;
			if (this.oscillationSkewXFrequencyInverted)
			{
				this._oscillationSkewXGroupValue = Math.sin(this._oscillationSkewXGroupStep);
			}
			else
			{
				this._oscillationSkewXGroupValue = Math.cos(this._oscillationSkewXGroupStep);
			}
		}
		
		if (this._oscillationSkewYEnabled && this._oscillationSkewYGroupFrequencyEnabled)
		{
			this._oscillationSkewYGroupStep += this.oscillationSkewYFrequency * time;
			if (this.oscillationSkewYFrequencyInverted)
			{
				this._oscillationSkewYGroupValue = Math.sin(this._oscillationSkewYGroupStep);
			}
			else
			{
				this._oscillationSkewYGroupValue = Math.cos(this._oscillationSkewYGroupStep);
			}
		}
		
		if (this._useOscillationColor && this._oscillationColorGroupFrequencyEnabled)
		{
			this._oscillationColorGroupStep += this.oscillationColorFrequency * time;
			if (this.oscillationColorFrequencyInverted)
			{
				this._oscillationColorGroupValue = Math.sin(this._oscillationColorGroupStep);
			}
			else
			{
				this._oscillationColorGroupValue = Math.cos(this._oscillationColorGroupStep);
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
		if ((this.particleAmount == 0 || this._particleTotal < this.particleAmount) && this._emissionTime > 0.0 && this._emissionRate > 0.0)
		{
			this._frameTime += time;
			var timeBetweenParticles:Float = 1.0 / this._emissionRate;
			var maxParticles:Int = this.particleAmount == 0 ? this._maxNumParticles : this._numParticles + (this.particleAmount - this._particleTotal);
			
			while (this._frameTime > 0 && this._numParticles < maxParticles)
			{
				particle = this._particles[this._numParticles];
				initParticle(particle);
				advanceParticle(particle, this._frameTime);
				
				++this._numParticles;
				++this._particleTotal;
				
				this._frameTime -= timeBetweenParticles;
			}
			
			if (this._emissionTime != MathUtils.FLOAT_MAX)
			{
				this._emissionTime = MathUtils.max(0.0, this._emissionTime - time);
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
	
	private function updateEmissionRate():Void
	{
		if (this._useAnimationLifeSpan)
		{
			var lifeSpan:Float = 0.0;
			var timingsCount:Int = this._frameTimings.length;
			for (i in 0...timingsCount)
			{
				lifeSpan += this._frameTimings[i][this._frameTimings[i].length - 1] / this._frameDelta;
			}
			lifeSpan /= timingsCount;
			this._emissionRate = this._maxNumParticles * this._emissionRatio / lifeSpan;
		}
		else
		{
			this._emissionRate = this._maxNumParticles * this._emissionRatio / this._lifeSpan;
		}
	}
	
	public function start(duration:Float = 0.0):Void
	{
		if (this._completed)
		{
			reset();
		}
		
		if (this._emissionRate != 0.0 && !this._completed)
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
			this._isPlaying = true;
			this._emissionTime = duration;
			this._frameTime = 0.0;
			this._oscillationGlobalStep = 0.0;
			this._oscillationPositionGroupStep = this.oscillationPositionGroupStartStep;
			this._oscillationPosition2GroupStep = this.oscillationPosition2GroupStartStep;
			this._oscillationRotationGroupStep = this.oscillationRotationGroupStartStep;
			this._oscillationScaleXGroupStep = this.oscillationScaleXGroupStartStep;
			this._oscillationScaleYGroupStep = this.oscillationScaleYGroupStartStep;
			this._oscillationSkewXGroupStep = this.oscillationSkewXGroupStartStep;
			this._oscillationSkewYGroupStep = this.oscillationSkewYGroupStartStep;
			this._oscillationColorGroupStep = this.oscillationColorGroupStartStep;
		}
	}
	
	public function  stop(clear:Bool = false):Void
	{
		this._emissionTime = 0.0;
		
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
		if (this._autoSetEmissionRate) 
		{
			updateEmissionRate();
		}
		this._frameTime = 0.0;
		this._isPlaying = false;
		
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
		// Emitter
		this.emitterType = options.emitterType;
		
		this._maxNumParticles = options.maxNumParticles;
		
		this.particleAmount = options.particleAmount;
		
		this._autoSetEmissionRate = options.autoSetEmissionRate;
		this._emissionRate = options.emissionRate;
		this._emissionRatio = options.emissionRatio;
		
		this.emitterX = options.emitterX;
		this.emitterY = options.emitterY;
		this.emitterXVariance = options.emitterXVariance;
		this.emitterYVariance = options.emitterYVariance;
		
		this.emitterRadiusMax = options.emitterRadiusMax;
		this.emitterRadiusMaxVariance = options.emitterRadiusMaxVariance;
		this.emitterRadiusMin = options.emitterRadiusMin;
		this.emitterRadiusMinVariance = options.emitterRadiusMinVariance;
		
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
		//\Radial
		
		// Color
		this.colorStart.copyFrom(options.colorStart);
		this.colorStartVariance.copyFrom(options.colorStartVariance);
		this.colorEnd.copyFrom(options.colorEnd);
		this.colorEndVariance.copyFrom(options.colorEndVariance);
		this.colorEndRelativeToStart = options.colorEndRelativeToStart;
		this.colorEndIsMultiplier = options.colorEndIsMultiplier;
		//\Color
		
		// Oscillation
		this.oscillationGlobalFrequency = options.oscillationGlobalFrequency;
		this.oscillationUnifiedFrequencyVariance = options.oscillationUnifiedFrequencyVariance;
		
		this.oscillationPositionFrequencyMode = options.oscillationPositionFrequencyMode;
		this.oscillationPositionGroupStartStep = options.oscillationPositionGroupStartStep;
		this.oscillationPositionAngle = options.oscillationPositionAngle;
		this.oscillationPositionAngleVariance = options.oscillationPositionAngleVariance;
		this.oscillationPositionAngleRelativeTo = options.oscillationPositionAngleRelativeTo;
		this.oscillationPositionRadius = options.oscillationPositionRadius;
		this.oscillationPositionRadiusVariance = options.oscillationPositionRadiusVariance;
		this.oscillationPositionFrequency = options.oscillationPositionFrequency;
		this.oscillationPositionUnifiedFrequencyVariance = options.oscillationPositionUnifiedFrequencyVariance;
		this.oscillationPositionFrequencyVariance = options.oscillationPositionFrequencyVariance;
		this.oscillationPositionFrequencyInverted = options.oscillationPositionFrequencyInverted;
		this.oscillationPositionFrequencyStart = options.oscillationPositionFrequencyStart;
		
		this.oscillationPosition2FrequencyMode = options.oscillationPosition2FrequencyMode;
		this.oscillationPosition2GroupStartStep = options.oscillationPosition2GroupStartStep;
		this.oscillationPosition2Angle = options.oscillationPosition2Angle;
		this.oscillationPosition2AngleVariance = options.oscillationPosition2AngleVariance;
		this.oscillationPosition2AngleRelativeTo = options.oscillationPosition2AngleRelativeTo;
		this.oscillationPosition2Radius = options.oscillationPosition2Radius;
		this.oscillationPosition2RadiusVariance = options.oscillationPosition2RadiusVariance;
		this.oscillationPosition2Frequency = options.oscillationPosition2Frequency;
		this.oscillationPosition2UnifiedFrequencyVariance = options.oscillationPosition2UnifiedFrequencyVariance;
		this.oscillationPosition2FrequencyVariance = options.oscillationPosition2FrequencyVariance;
		this.oscillationPosition2FrequencyInverted = options.oscillationPosition2FrequencyInverted;
		this.oscillationPosition2FrequencyStart = options.oscillationPosition2FrequencyStart;
		
		this.oscillationRotationFrequencyMode = options.oscillationRotationFrequencyMode;
		this.oscillationRotationGroupStartStep = options.oscillationRotationGroupStartStep;
		this.oscillationRotationAngle = options.oscillationRotationAngle;
		this.oscillationRotationAngleVariance = options.oscillationRotationAngleVariance;
		this.oscillationRotationFrequency = options.oscillationRotationFrequency;
		this.oscillationRotationUnifiedFrequencyVariance = options.oscillationRotationUnifiedFrequencyVariance;
		this.oscillationRotationFrequencyVariance = options.oscillationRotationFrequencyVariance;
		this.oscillationRotationFrequencyInverted = options.oscillationRotationFrequencyInverted;
		this.oscillationRotationFrequencyStart = options.oscillationRotationFrequencyStart;
		
		this.oscillationScaleXFrequencyMode = options.oscillationScaleXFrequencyMode;
		this.oscillationScaleXGroupStartStep = options.oscillationScaleXGroupStartStep;
		this.oscillationScaleX = options.oscillationScaleX;
		this.oscillationScaleXVariance = options.oscillationScaleXVariance;
		this.oscillationScaleXFrequency = options.oscillationScaleXFrequency;
		this.oscillationScaleXUnifiedFrequencyVariance = options.oscillationScaleXUnifiedFrequencyVariance;
		this.oscillationScaleXFrequencyVariance = options.oscillationScaleXFrequencyVariance;
		this.oscillationScaleXFrequencyInverted = options.oscillationScaleXFrequencyInverted;
		this.oscillationScaleXFrequencyStart = options.oscillationScaleXFrequencyStart;
		
		this.oscillationScaleYFrequencyMode = options.oscillationScaleYFrequencyMode;
		this.oscillationScaleYGroupStartStep = options.oscillationScaleYGroupStartStep;
		this.oscillationScaleY = options.oscillationScaleY;
		this.oscillationScaleYVariance = options.oscillationScaleYVariance;
		this.oscillationScaleYFrequency = options.oscillationScaleYFrequency;
		this.oscillationScaleYUnifiedFrequencyVariance = options.oscillationScaleYUnifiedFrequencyVariance;
		this.oscillationScaleYFrequencyVariance = options.oscillationScaleYFrequencyVariance;
		this.oscillationScaleYFrequencyInverted = options.oscillationScaleYFrequencyInverted;
		this.oscillationScaleYFrequencyStart = options.oscillationScaleYFrequencyStart;
		
		this.oscillationSkewXFrequencyMode = options.oscillationSkewXFrequencyMode;
		this.oscillationSkewXGroupStartStep = options.oscillationSkewXGroupStartStep;
		this.oscillationSkewX = options.oscillationSkewX;
		this.oscillationSkewXVariance = options.oscillationSkewXVariance;
		this.oscillationSkewXFrequency = options.oscillationSkewXFrequency;
		this.oscillationSkewXUnifiedFrequencyVariance = options.oscillationSkewXUnifiedFrequencyVariance;
		this.oscillationSkewXFrequencyVariance = options.oscillationSkewXFrequencyVariance;
		this.oscillationSkewXFrequencyInverted = options.oscillationSkewXFrequencyInverted;
		this.oscillationSkewXFrequencyStart = options.oscillationSkewXFrequencyStart;
		
		this.oscillationSkewYFrequencyMode = options.oscillationSkewYFrequencyMode;
		this.oscillationSkewYGroupStartStep = options.oscillationSkewYGroupStartStep;
		this.oscillationSkewY = options.oscillationSkewY;
		this.oscillationSkewYVariance = options.oscillationSkewYVariance;
		this.oscillationSkewYFrequency = options.oscillationSkewYFrequency;
		this.oscillationSkewYUnifiedFrequencyVariance = options.oscillationSkewYUnifiedFrequencyVariance;
		this.oscillationSkewYFrequencyVariance = options.oscillationSkewYFrequencyVariance;
		this.oscillationSkewYFrequencyInverted = options.oscillationSkewYFrequencyInverted;
		this.oscillationSkewYFrequencyStart = options.oscillationSkewYFrequencyStart;
		
		this.oscillationColorFrequencyMode = options.oscillationColorFrequencyMode;
		this.oscillationColorGroupStartStep = options.oscillationColorGroupStartStep;
		this.oscillationColorRed = options.oscillationColorRed;
		this.oscillationColorGreen = options.oscillationColorGreen;
		this.oscillationColorBlue = options.oscillationColorBlue;
		this.oscillationColorAlpha = options.oscillationColorAlpha;
		this.oscillationColorRedVariance = options.oscillationColorRedVariance;
		this.oscillationColorGreenVariance = options.oscillationColorGreenVariance;
		this.oscillationColorBlueVariance = options.oscillationColorBlueVariance;
		this.oscillationColorAlphaVariance = options.oscillationColorAlphaVariance;
		this.oscillationColorFrequency = options.oscillationColorFrequency;
		this.oscillationColorUnifiedFrequencyVariance = options.oscillationColorUnifiedFrequencyVariance;
		this.oscillationColorFrequencyVariance = options.oscillationColorFrequencyVariance;
		this.oscillationColorFrequencyInverted = options.oscillationColorFrequencyInverted;
		this.oscillationColorFrequencyStart = options.oscillationColorFrequencyStart;
		//\Oscillation
		
		checkColor();
		
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
		
		options.maxNumParticles = this._maxNumParticles;
		
		options.particleAmount = this.particleAmount;
		
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
		//\Radial
		
		// Color
		options.colorStart.copyFrom(this.colorStart);
		options.colorStartVariance.copyFrom(this.colorStartVariance);
		options.colorEnd.copyFrom(this.colorEnd);
		options.colorEndVariance.copyFrom(this.colorEndVariance);
		options.colorEndRelativeToStart = this.colorEndRelativeToStart;
		options.colorEndIsMultiplier = this.colorEndIsMultiplier;
		//\Color
		
		// Oscillation
		options.oscillationGlobalFrequency = this.oscillationGlobalFrequency;
		options.oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance;
		
		options.oscillationPositionFrequencyMode = this._oscillationPositionFrequencyMode;
		options.oscillationPositionGroupStartStep = this.oscillationPositionGroupStartStep;
		options.oscillationPositionAngle = this.oscillationPositionAngle;
		options.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
		options.oscillationPositionAngleRelativeTo = this._oscillationPositionAngleRelativeTo;
		options.oscillationPositionRadius = this._oscillationPositionRadius;
		options.oscillationPositionRadiusVariance = this._oscillationPositionRadiusVariance;
		options.oscillationPositionFrequency = this.oscillationPositionFrequency;
		options.oscillationPositionUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance;
		options.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
		options.oscillationPositionFrequencyInverted = this.oscillationPositionFrequencyInverted;
		options.oscillationPositionFrequencyStart = this._oscillationPositionFrequencyStart;
		
		options.oscillationPosition2FrequencyMode = this._oscillationPosition2FrequencyMode;
		options.oscillationPosition2GroupStartStep = this.oscillationPosition2GroupStartStep;
		options.oscillationPosition2Angle = this.oscillationPosition2Angle;
		options.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
		options.oscillationPosition2AngleRelativeTo = this.oscillationPosition2AngleRelativeTo;
		options.oscillationPosition2Radius = this._oscillationPosition2Radius;
		options.oscillationPosition2RadiusVariance = this._oscillationPosition2RadiusVariance;
		options.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
		options.oscillationPosition2UnifiedFrequencyVariance = this._oscillationPosition2UnifiedFrequencyVariance;
		options.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
		options.oscillationPosition2FrequencyInverted = this.oscillationPosition2FrequencyInverted;
		options.oscillationPosition2FrequencyStart = this._oscillationPosition2FrequencyStart;
		
		options.oscillationRotationFrequencyMode = this._oscillationRotationFrequencyMode;
		options.oscillationRotationGroupStartStep = this.oscillationRotationGroupStartStep;
		options.oscillationRotationAngle = this._oscillationRotationAngle;
		options.oscillationRotationAngleVariance = this._oscillationRotationAngleVariance;
		options.oscillationRotationFrequency = this.oscillationRotationFrequency;
		options.oscillationRotationUnifiedFrequencyVariance = this._oscillationRotationUnifiedFrequencyVariance;
		options.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
		options.oscillationRotationFrequencyInverted = this.oscillationRotationFrequencyInverted;
		options.oscillationRotationFrequencyStart = this._oscillationRotationFrequencyStart;
		
		options.oscillationScaleXFrequencyMode = this._oscillationScaleXFrequencyMode;
		options.oscillationScaleXGroupStartStep = this.oscillationScaleXGroupStartStep;
		options.oscillationScaleX = this._oscillationScaleX;
		options.oscillationScaleXVariance = this._oscillationScaleXVariance;
		options.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
		options.oscillationScaleXUnifiedFrequencyVariance = this._oscillationScaleXUnifiedFrequencyVariance;
		options.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
		options.oscillationScaleXFrequencyInverted = this.oscillationScaleXFrequencyInverted;
		options.oscillationScaleXFrequencyStart = this._oscillationScaleXFrequencyStart;
		
		options.oscillationScaleYFrequencyMode = this._oscillationScaleYFrequencyMode;
		options.oscillationScaleYGroupStartStep = this.oscillationScaleYGroupStartStep;
		options.oscillationScaleY = this._oscillationScaleY;
		options.oscillationScaleYVariance = this._oscillationScaleYVariance;
		options.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
		options.oscillationScaleYUnifiedFrequencyVariance = this._oscillationScaleYUnifiedFrequencyVariance;
		options.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
		options.oscillationScaleYFrequencyInverted = this.oscillationScaleYFrequencyInverted;
		options.oscillationScaleYFrequencyStart = this._oscillationScaleYFrequencyStart;
		
		options.oscillationSkewXFrequencyMode = this._oscillationSkewXFrequencyMode;
		options.oscillationSkewXGroupStartStep = this.oscillationSkewXGroupStartStep;
		options.oscillationSkewX = this._oscillationSkewX;
		options.oscillationSkewXVariance = this._oscillationSkewXVariance;
		options.oscillationSkewXFrequency = this.oscillationSkewXFrequency;
		options.oscillationSkewXUnifiedFrequencyVariance = this._oscillationSkewXUnifiedFrequencyVariance;
		options.oscillationSkewXFrequencyVariance = this.oscillationSkewXFrequencyVariance;
		options.oscillationSkewXFrequencyInverted = this.oscillationSkewXFrequencyInverted;
		options.oscillationSkewXFrequencyStart = this._oscillationSkewXFrequencyStart;
		
		options.oscillationSkewYFrequencyMode = this._oscillationSkewYFrequencyMode;
		options.oscillationSkewYGroupStartStep = this.oscillationSkewYGroupStartStep;
		options.oscillationSkewY = this._oscillationSkewY;
		options.oscillationSkewYVariance = this._oscillationSkewYVariance;
		options.oscillationSkewYFrequency = this.oscillationSkewYFrequency;
		options.oscillationSkewYUnifiedFrequencyVariance = this._oscillationSkewYUnifiedFrequencyVariance;
		options.oscillationSkewYFrequencyVariance = this.oscillationSkewYFrequencyVariance;
		options.oscillationSkewYFrequencyInverted = this.oscillationSkewYFrequencyInverted;
		options.oscillationSkewYFrequencyStart = this._oscillationSkewYFrequencyStart;
		
		options.oscillationColorFrequencyMode = this._oscillationColorFrequencyMode;
		options.oscillationColorGroupStartStep = this.oscillationColorGroupStartStep;
		options.oscillationColorRed = this._oscillationColorRed;
		options.oscillationColorGreen = this._oscillationColorGreen;
		options.oscillationColorBlue = this._oscillationColorBlue;
		options.oscillationColorAlpha = this._oscillationColorAlpha;
		options.oscillationColorRedVariance = this._oscillationColorRedVariance;
		options.oscillationColorGreenVariance = this._oscillationColorGreenVariance;
		options.oscillationColorBlueVariance = this._oscillationColorBlueVariance;
		options.oscillationColorAlphaVariance = this._oscillationColorAlphaVariance;
		options.oscillationColorFrequency = this.oscillationColorFrequency;
		options.oscillationColorUnifiedFrequencyVariance = this._oscillationColorUnifiedFrequencyVariance;
		options.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
		options.oscillationColorFrequencyInverted = this.oscillationColorFrequencyInverted;
		options.oscillationColorFrequencyStart = this._oscillationColorFrequencyStart;
		//\Oscillation
		
		return options;
	}
	
	private function checkOscillationGlobalFrequency():Void
	{
		this._useOscillationGlobalFrequency = this._oscillationPositionGlobalFrequencyEnabled || this._oscillationPosition2GlobalFrequencyEnabled || this._oscillationRotationGlobalFrequencyEnabled ||
											  this._oscillationScaleXGlobalFrequencyEnabled || this._oscillationScaleYGlobalFrequencyEnabled || this._oscillationSkewXGlobalFrequencyEnabled || 
											  this._oscillationSkewYGlobalFrequencyEnabled || this._oscillationColorGlobalFrequencyEnabled;
	}
	
	private function checkOscillationUnifiedFrequencyVariance():Void
	{
		this._useOscillationUnifiedFrequencyVariance = this._oscillationPositionUnifiedFrequencyVariance || this._oscillationPosition2UnifiedFrequencyVariance || this._oscillationRotationUnifiedFrequencyVariance ||
													   this._oscillationScaleXUnifiedFrequencyVariance || this._oscillationScaleYUnifiedFrequencyVariance || this._oscillationSkewXUnifiedFrequencyVariance ||
													   this._oscillationSkewYUnifiedFrequencyVariance || this._oscillationColorUnifiedFrequencyVariance;
	}
	
	private function checkOscillationUnifiedFrequencyStart():Void
	{
		this._useOscillationUnifiedFrequencyStart = this._oscillationPositionFrequencyStartUnified || this._oscillationPosition2FrequencyStartUnified || this._oscillationRotationFrequencyStartUnified ||
													this._oscillationScaleXFrequencyStartUnified || this._oscillationScaleYFrequencyStartUnified || this._oscillationSkewXFrequencyStartUnified ||
													this._oscillationSkewYFrequencyStartUnified || this._oscillationColorFrequencyStartUnified;
	}
	
	private function checkOscillationColor():Void
	{
		this._useOscillationColor = this._oscillationColorRed != 0.0 || this._oscillationColorGreen != 0.0 || this._oscillationColorBlue != 0.0 || this._oscillationColorAlpha != 0.0 ||
									this._oscillationColorRedVariance != 0.0 || this._oscillationColorGreenVariance != 0.0 || this._oscillationColorBlueVariance != 0.0 || this._oscillationColorAlphaVariance != 0.0;
	}
	
	private function colorChange(tint:MassiveTint):Void
	{
		checkColor();
	}
	
	private function checkColor():Void
	{
		if (this._colorEndRelativeToStart)
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
	}
	
}