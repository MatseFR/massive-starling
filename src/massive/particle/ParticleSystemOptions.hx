package massive.particle;
import haxe.xml.Access;
import massive.util.MassiveTint;
import massive.util.MathUtils;
import openfl.display3D.Context3DBlendFactor;
import openfl.errors.ArgumentError;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Matse
 */
class ParticleSystemOptions 
{
	static private var _POOL:Array<ParticleSystemOptions> = new Array<ParticleSystemOptions>();
	
	static public function fromPool():ParticleSystemOptions
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ParticleSystemOptions();
	}
	
	//##################################################
	// EMITTER
	//##################################################
	/**
	   Possible values :
	   - 0 for gravity
	   - 1 for radial
	   @default 0
	**/
	public var emitterType:Int = 0;
	/**
	   Maximum number of particles used by the system
	   @default 1000
	**/
	public var maxNumParticles:Int = 1000;
	/**
	   The amount of particles this system can create over time, 0 = infinite
	   @default 0
	**/
	public var particleAmount:Int = 0;
	/**
	   Tells whether the particle system should automatically set its emission rate or not
	   @default true
	**/
	public var autoSetEmissionRate:Bool = true;
	/**
	   How many particles are created per second
	   @default 100
	**/
	public var emissionRate:Float = 100.0;
	/**
	   Percentage of max particles to consider when automatically setting emission rate
	   @default 1.0
	**/
	public var emissionRatio:Float = 1.0;
	/**
	   Horizontal emitter position
	   @default 0
	**/
	public var emitterX:Float = 0.0;
	/**
	   Horizontal emitter position variance
	   @default 0
	**/
	public var emitterXVariance:Float = 0.0;
	/**
	   Vertical emitter position
	   @default 0
	**/
	public var emitterY:Float = 0.0;
	/**
	   Vertical emitter position variance
	   @default 0
	**/
	public var emitterYVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var emitterRadiusMax:Float = 0.0;
	/**
	   @default 0
	**/
	public var emitterRadiusMaxVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var emitterRadiusMin:Float = 0.0;
	/**
	   @default 0
	**/
	public var emitterRadiusMinVariance:Float = 0.0;
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
	public var emitAngle:Float = 0.0;
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
	   @default	0
	**/
	public var emitAngleAlignedRotationOffset:Float = 0.0;
	/**
	   Emission time span, -1 = infinite
	**/
	public var duration:Float = -1.0;
	/**
	   @default false
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
	public var useAnimationLifeSpan:Bool = false;
	/**
	   @default 1
	**/
	public var lifeSpan:Float = 1.0;
	/**
	   @default 0
	**/
	public var lifeSpanVariance:Float = 0.0;
	/**
	   if > 0 the particle alpha will be interpolated from 0 to starting alpha
	   @default 0
	**/
	public var fadeInTime:Float = 0.0;
	/**
	   if > 0 the particle alpha will be interpolated from current value to end alpha
	   @default 0
	**/
	public var fadeOutTime:Float = 0.0;
	/**
	   sets both sizeXStart and sizeYStart
	**/
	public var sizeStart(get, set):Float;
	private function get_sizeStart():Float { return this.sizeXStart; }
	private function set_sizeStart(value:Float):Float
	{
		return this.sizeXStart = this.sizeYStart = value;
	}
	/**
	   sets both sizeXStartVariance and sizeYStartVariance
	**/
	public var sizeStartVariance(get, set):Float;
	private function get_sizeStartVariance():Float { return this.sizeXStartVariance; }
	private function set_sizeStartVariance(value:Float):Float
	{
		return this.sizeXStartVariance = this.sizeYStartVariance = value;
	}
	/**
	   @default 20
	**/
	public var sizeXStart:Float = 20.0;
	/**
	   @default 0
	**/
	public var sizeXStartVariance:Float = 0.0;
	/**
	   @default 20
	**/
	public var sizeYStart:Float = 20.0;
	/**
	   @default 0
	**/
	public var sizeYStartVariance:Float = 0.0;
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
	public var sizeXEnd:Float = 20.0;
	/**
	   @default 0
	**/
	public var sizeXEndVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var sizeXEndRelativeToStart:Bool = false;
	/**
	   @default 20
	**/
	public var sizeYEnd:Float = 20.0;
	/**
	   @default 0
	**/
	public var sizeYEndVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var sizeYEndRelativeToStart:Bool = false;
	/**
	   @default 0
	**/
	public var rotationStart:Float = 0.0;
	/**
	   @default 0
	**/
	public var rotationStartVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var rotationEnd:Float = 0.0;
	/**
	   @default 0
	**/
	public var rotationEndVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var rotationEndRelativeToStart:Bool = false;
	/**
	   @default	0
	**/
	public var skewXStart:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewXStartVariance:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewYStart:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewYStartVariance:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewXEnd:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewXEndVariance:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewYEnd:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewYEndVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var skewXEndRelativeToStart:Bool = false;
	/**
	   @default	false
	**/
	public var skewYEndRelativeToStart:Bool = false;
	//##################################################
	//\PARTICLE
	//##################################################
	
	//##################################################
	// VELOCITY
	//##################################################
	/**
	   @default 0
	**/
	public var velocityXInheritRatio:Float = 0.0;
	/**
	   @default 0
	**/
	public var velocityXInheritRatioVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var velocityYInheritRatio:Float = 0.0;
	/**
	   @default 0
	**/
	public var velocityYInheritRatioVariance:Float = 0.0;
	/**
	   @default false
	**/
	public var linkRotationToVelocity:Bool = false;
	/**
	   @default 0
	**/
	public var velocityRotationOffset:Float = 0.0;
	/**
	   @default	0
	**/
	public var velocityRotationFactor:Float = 0.0;
	/**
	   @default 0
	**/
	public var velocityScaleFactorX:Float = 0.0;
	/**
	   @default 0
	**/
	public var velocityScaleFactorY:Float = 0.0;
	/**
	   @default	0
	**/
	public var velocitySkewFactorX:Float = 0.0;
	/**
	   @default	0
	**/
	public var velocitySkewFactorY:Float = 0.0;
	//##################################################
	//\VELOCITY
	//##################################################
	
	//##################################################
	// ANIMATION
	//##################################################
	/**
	   Tells whether textures should be animated or not
	   @default true
	**/
	public var textureAnimation:Bool = true;
	/**
	   texture animation play speed ratio
	   @default 1
	**/
	public var frameDelta:Float = 1.0;
	/**
	   texture animation play speed ratio variance
	   @default 0
	**/
	public var frameDeltaVariance:Float = 0.0;
	/**
	   Tells whether texture animation should loop or not
	   @default false
	**/
	public var loopAnimation:Bool = false;
	/**
	   Number of loops if textureAnimation is on, 0 = infinite
	   @default 0
	**/
	public var animationLoops:Int = 0;
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
	   @default 20
	**/
	public var speedVariance:Float = 20.0;
	/**
	   @default false
	**/
	public var adjustLifeSpanToSpeed:Bool = false;
	/**
	   @default 0
	**/
	public var gravityX:Float = 0.0;
	/**
	   @default 0
	**/
	public var gravityY:Float = 0.0;
	/**
	   @default 0
	**/
	public var radialAcceleration:Float = 0.0;
	/**
	   @default 0
	**/
	public var radialAccelerationVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var tangentialAcceleration:Float = 0.0;
	/**
	   @default 0
	**/
	public var tangentialAccelerationVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var drag:Float = 0.0;
	/**
	   @default 0
	**/
	public var dragVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var repellentForce:Float = 0.0;
	//##################################################
	//\GRAVITY
	//##################################################
	
	//##################################################
	// RADIAL
	//##################################################
	/**
	   @default 300
	**/
	public var radiusMax:Float = 300.0;
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
	   @default	0
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
	/**
	   
	**/
	public var colorStart:MassiveTint = new MassiveTint(1.0, 1.0, 1.0, 1.0);
	/**
	   
	**/
	public var colorStartVariance:MassiveTint = new MassiveTint(0.0, 0.0, 0.0, 0.0);
	/**
	   
	**/
	public var colorEnd:MassiveTint = new MassiveTint(1.0, 1.0, 1.0, 1.0);
	/**
	   
	**/
	public var colorEndVariance:MassiveTint = new MassiveTint(0.0, 0.0, 0.0, 0.0);
	/**
	   @default	false
	**/
	public var colorEndRelativeToStart:Bool = false;
	/**
	   @default	false
	**/
	public var colorEndIsMultiplier:Bool = false;
	//##################################################
	//\COLOR
	//##################################################
	
	//##################################################
	// COLOR OFFSET
	//##################################################
	/**
	   
	**/
	public var colorOffsetStart:MassiveTint = new MassiveTint();
	/**
	   
	**/
	public var colorOffsetStartVariance:MassiveTint = new MassiveTint();
	/**
	   
	**/
	public var colorOffsetEnd:MassiveTint = new MassiveTint();
	/**
	   
	**/
	public var colorOffsetEndVariance:MassiveTint = new MassiveTint();
	/**
	   @default	false
	**/
	public var colorOffsetEndRelativeToStart:Bool = false;
	/**
	   @default	false
	**/
	public var colorOffsetEndIsMultiplier:Bool = false;
	//##################################################
	//\COLOR OFFSET
	//##################################################
	
	//##################################################
	// OSCILLATION
	//##################################################
	/**
	   @default	1
	**/
	public var oscillationGlobalFrequency:Float = 1.0;
	/**
	   @default	0
	**/
	public var oscillationUnifiedFrequencyVariance:Float = 0.0;
	
	// Position
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var positionOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
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
	public var positionOscillationAngleRelativeTo:String = AngleRelativeTo.ROTATION;
	/**
	   @default 0
	**/
	public var positionOscillationRadius:Float = 0.0;
	/**
	   @default 0
	**/
	public var positionOscillationRadiusVariance:Float = 0.0;
	/**
	   @default 1
	**/
	public var positionOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var positionOscillationUnifiedFrequencyVariance:Bool = false;
	/**
	   @default 0
	**/
	public var positionOscillationFrequencyVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var positionOscillationFrequencyInverted:Bool = false;
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var positionOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// Position2
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var position2OscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
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
	public var position2OscillationAngleRelativeTo:String = AngleRelativeTo.ROTATION;
	/**
	   @default 0
	**/
	public var position2OscillationRadius:Float = 0.0;
	/**
	   @default 0
	**/
	public var position2OscillationRadiusVariance:Float = 0.0;
	/**
	   @default 1
	**/
	public var position2OscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var position2OscillationUnifiedFrequencyVariance:Bool = false;
	/**
	   @default 0
	**/
	public var position2OscillationFrequencyVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var position2OscillationFrequencyInverted:Bool = false;
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var position2OscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// Rotation
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var rotationOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var rotationOscillationGroupStartStep:Float = 0.0;
	/**
	   @default 0
	**/
	public var rotationOscillationAngle:Float = 0.0;
	/**
	   @default 0
	**/
	public var rotationOscillationAngleVariance:Float = 0.0;
	/**
	   @default 1
	**/
	public var rotationOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var rotationOscillationUnifiedFrequencyVariance:Bool = false;
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
	public var rotationOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// ScaleX
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var scaleXOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var scaleXOscillationGroupStartStep:Float = 0.0;
	/**
	   @default 0
	**/
	public var scaleXOscillation:Float = 0.0;
	/**
	   @default 0
	**/
	public var scaleXOscillationVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var scaleXOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var scaleXOscillationUnifiedFrequencyVariance:Bool = false;
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
	public var scaleXOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// ScaleY
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var scaleYOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var scaleYOscillationGroupStartStep:Float = 0.0;
	/**
	   @default 0
	**/
	public var scaleYOscillation:Float = 0.0;
	/**
	   @default 0
	**/
	public var scaleYOscillationVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var scaleYOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var scaleYOscillationUnifiedFrequencyVariance:Bool = false;
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
	public var scaleYOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// SkewX
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var skewXOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var skewXOscillationGroupStartStep:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewXOscillation:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewXOscillationVariance:Float = 0.0;
	/**
	   @default	1
	**/
	public var skewXOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var skewXOscillationUnifiedFrequencyVariance:Bool = false;
	/**
	   @default	0
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
	public var skewXOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// SkewY
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var skewYOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var skewYOscillationGroupStartStep:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewYOscillation:Float = 0.0;
	/**
	   @default	0
	**/
	public var skewYOscillationVariance:Float = 0.0;
	/**
	   @default	1
	**/
	public var skewYOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var skewYOscillationUnifiedFrequencyVariance:Bool = false;
	/**
	   @default	0
	**/
	public var skewYOscillationFrequencyVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var skewYOscillationFrequencyInverted:Bool = false;
	/**
	   
	**/
	public var skewYOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// Color
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var colorOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var colorOscillationGroupStartStep:Float = 0.0;
	/**
	   
	**/
	public var colorOscillation:MassiveTint = new MassiveTint();
	/**
	   
	**/
	public var colorOscillationVariance:MassiveTint = new MassiveTint();
	/**
	   @default 1
	**/
	public var colorOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var colorOscillationUnifiedFrequencyVariance:Bool = false;
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
	public var colorOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// Color Offset
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var colorOffsetOscillationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var colorOffsetOscillationGroupStartStep:Float = 0.0;
	/**
	   
	**/
	public var colorOffsetOscillation:MassiveTint = new MassiveTint();
	/**
	   
	**/
	public var colorOffsetOscillationVariance:MassiveTint = new MassiveTint();
	/**
	   @default 1
	**/
	public var colorOffsetOscillationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var colorOffsetOscillationUnifiedFrequencyVariance:Bool = false;
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
	public var colorOffsetOscillationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	//##################################################
	//\OSCILLATION
	//##################################################
	
	/**
	   @default	null
	**/
	public var customFunction:Array<Particle>->Int->Void;
	/**
	   @default	null
	**/
	public var sortFunction:Particle->Particle->Int;
	public var forceSortFlag:Bool = false;
	/**
	   Tells whether the particle system should calculate its exact bounds or return stage dimensions
	**/
	public var exactBounds:Bool = false;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		// EMITTER
		this.emitterType = 0;
		
		this.maxNumParticles = 1000;
		
		this.particleAmount = 0;
		
		this.autoSetEmissionRate = true;
		this.emissionRate = 100.0;
		this.emissionRatio = 1.0;
		
		this.emitterX = 0.0;
		this.emitterY = 0.0;
		this.emitterXVariance = 0.0;
		this.emitterYVariance = 0.0;
		
		this.emitterRadiusMax = 0.0;
		this.emitterRadiusMaxVariance = 0.0;
		this.emitterRadiusMin = 0.0;
		this.emitterRadiusMinVariance = 0.0;
		this.emitterRadiusOverridesParticleAngle = false;
		this.emitterRadiusParticleAngleOffset = 0.0;
		this.emitterRadiusParticleAngleOffsetVariance = 0.0;
		
		this.emitAngle = 0.0;
		this.emitAngleVariance = Math.PI;
		
		this.emitAngleAlignedRotation = false;
		this.emitAngleAlignedRotationOffset = 0.0;
		
		this.duration = -1.0;
		
		this.useDisplayRect = false;
		this.displayRect.setEmpty();
		//\EMITTER
		
		// PARTICLE
		this.useAnimationLifeSpan = false;
		this.lifeSpan = 1.0;
		this.lifeSpanVariance = 0.0;
		
		this.fadeInTime = 0.0;
		this.fadeOutTime = 0.0;
		
		this.sizeXStart = 20.0;
		this.sizeXStartVariance = 0.0;
		this.sizeYStart = 20.0;
		this.sizeYStartVariance = 0.0;
		this.sizeXEndRelativeToStart = false;
		
		this.sizeXEnd = 20.0;
		this.sizeXEndVariance = 0.0;
		this.sizeYEnd = 20.0;
		this.sizeYEndVariance = 0.0;
		this.sizeYEndRelativeToStart = false;
		
		this.rotationStart = 0.0;
		this.rotationStartVariance = 0.0;
		this.rotationEnd = 0.0;
		this.rotationEndVariance = 0.0;
		this.rotationEndRelativeToStart = false;
		
		this.skewXStart = 0.0;
		this.skewXStartVariance = 0.0;
		this.skewXEnd = 0.0;
		this.skewXEndVariance = 0.0;
		this.skewXEndRelativeToStart = false;
		
		this.skewYStart = 0.0;
		this.skewYStartVariance = 0.0;
		this.skewYEnd = 0.0;
		this.skewYEndVariance = 0.0;
		this.skewYEndRelativeToStart = false;
		//\PARTICLE
		
		// VELOCITY
		this.velocityXInheritRatio = 0.0;
		this.velocityXInheritRatioVariance = 0.0;
		this.velocityYInheritRatio = 0.0;
		this.velocityYInheritRatioVariance = 0.0;
		
		this.linkRotationToVelocity = false;
		this.velocityRotationOffset = 0.0;
		
		this.velocityRotationFactor = 0.0;
		
		this.velocityScaleFactorX = 0.0;
		this.velocityScaleFactorY = 0.0;
		
		this.velocitySkewFactorX = 0.0;
		this.velocitySkewFactorY = 0.0;
		//\VELOCITY
		
		// ANIMATION
		this.textureAnimation = true;
		this.frameDelta = 1.0;
		this.frameDeltaVariance = 0.0;
		this.loopAnimation = false;
		this.animationLoops = 0;
		this.randomStartFrame = false;
		//\ANIMATION
		
		// GRAVITY
		this.speed = 100.0;
		this.speedVariance = 20.0;
		this.adjustLifeSpanToSpeed = false;
		
		this.gravityX = 0.0;
		this.gravityY = 0.0;
		
		this.radialAcceleration = 0.0;
		this.radialAccelerationVariance = 0.0;
		
		this.tangentialAcceleration = 0.0;
		this.tangentialAccelerationVariance = 0.0;
		
		this.drag = 0.0;
		this.dragVariance = 0.0;
		
		this.repellentForce = 0.0;
		//\GRAVITY
		
		// RADIAL
		this.radiusMax = 300.0;
		this.radiusMaxVariance = 0.0;
		
		this.radiusMin = 0.0;
		this.radiusMinVariance = 0.0;
		
		this.rotatePerSecond = 0.0;
		this.rotatePerSecondVariance = 0.0;
		
		this.alignRadialRotation = false;
		this.alignRadialRotationOffset = 0.0;
		this.alignRadialRotationOffsetVariance = 0.0;
		//\RADIAL
		
		// COLOR
		this.colorStart.setTo(1.0, 1.0, 1.0, 1.0);
		this.colorStartVariance.setTo(0.0, 0.0, 0.0, 0.0);
		
		this.colorEnd.setTo(1.0, 1.0, 1.0, 1.0);
		this.colorEndVariance.setTo(0.0, 0.0, 0.0, 0.0);
		
		this.colorEndRelativeToStart = false;
		this.colorEndIsMultiplier = false;
		//\COLOR
		
		// COLOR OFFSET
		this.colorOffsetStart.setTo(0.0, 0.0, 0.0, 0.0);
		this.colorOffsetStartVariance.setTo(0.0, 0.0, 0.0, 0.0);
		
		this.colorOffsetEnd.setTo(0.0, 0.0, 0.0, 0.0);
		this.colorOffsetEndVariance.setTo(0.0, 0.0, 0.0, 0.0);
		
		this.colorOffsetEndRelativeToStart = false;
		this.colorOffsetEndIsMultiplier = false;
		//\COLOR OFFSET
		
		// OSCILLATION
		this.oscillationGlobalFrequency = 1.0;
		this.oscillationUnifiedFrequencyVariance = 0.0;
		
		// position
		this.positionOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.positionOscillationGroupStartStep = 0.0;
		this.positionOscillationAngle = 0.0;
		this.positionOscillationAngleVariance = 0.0;
		this.positionOscillationAngleRelativeTo = AngleRelativeTo.ROTATION;
		this.positionOscillationRadius = 0.0;
		this.positionOscillationRadiusVariance = 0.0;
		this.positionOscillationFrequency = 1.0;
		this.positionOscillationUnifiedFrequencyVariance = false;
		this.positionOscillationFrequencyVariance = 0.0;
		this.positionOscillationFrequencyInverted = false;
		this.positionOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// position2
		this.position2OscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.position2OscillationGroupStartStep = 0.0;
		this.position2OscillationAngle = 0.0;
		this.position2OscillationAngleVariance = 0.0;
		this.position2OscillationAngleRelativeTo = AngleRelativeTo.ROTATION;
		this.position2OscillationRadius = 0.0;
		this.position2OscillationRadiusVariance = 0.0;
		this.position2OscillationFrequency = 1.0;
		this.position2OscillationUnifiedFrequencyVariance = false;
		this.position2OscillationFrequencyVariance = 0.0;
		this.position2OscillationFrequencyInverted = false;
		this.position2OscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// rotation
		this.rotationOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.rotationOscillationGroupStartStep = 0.0;
		this.rotationOscillationAngle = 0.0;
		this.rotationOscillationAngleVariance = 0.0;
		this.rotationOscillationFrequency = 1.0;
		this.rotationOscillationUnifiedFrequencyVariance = false;
		this.rotationOscillationFrequencyVariance = 0.0;
		this.rotationOscillationFrequencyInverted = false;
		this.rotationOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// scaleX
		this.scaleXOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.scaleXOscillationGroupStartStep = 0.0;
		this.scaleXOscillation = 0.0;
		this.scaleXOscillationVariance = 0.0;
		this.scaleXOscillationFrequency = 1.0;
		this.scaleXOscillationUnifiedFrequencyVariance = false;
		this.scaleXOscillationFrequencyVariance = 0.0;
		this.scaleXOscillationFrequencyInverted = false;
		this.scaleXOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// scaleY
		this.scaleYOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.scaleYOscillationGroupStartStep = 0.0;
		this.scaleYOscillation = 0.0;
		this.scaleYOscillationVariance = 0.0;
		this.scaleYOscillationFrequency = 1.0;
		this.scaleYOscillationUnifiedFrequencyVariance = false;
		this.scaleYOscillationFrequencyVariance = 0.0;
		this.scaleYOscillationFrequencyInverted = false;
		this.scaleYOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// skewX
		this.skewXOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.skewXOscillationGroupStartStep = 0.0;
		this.skewXOscillation = 0.0;
		this.skewXOscillationVariance = 0.0;
		this.skewXOscillationFrequency = 1.0;
		this.skewXOscillationUnifiedFrequencyVariance = false;
		this.skewXOscillationFrequencyVariance = 0.0;
		this.skewXOscillationFrequencyInverted = false;
		this.skewXOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// slewY
		this.skewYOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.skewYOscillationGroupStartStep = 0.0;
		this.skewYOscillation = 0.0;
		this.skewYOscillationVariance = 0.0;
		this.skewYOscillationFrequency = 1.0;
		this.skewYOscillationUnifiedFrequencyVariance = false;
		this.skewYOscillationFrequencyVariance = 0.0;
		this.skewYOscillationFrequencyInverted = false;
		this.skewYOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// color
		this.colorOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.colorOscillationGroupStartStep = 0.0;
		this.colorOscillation.setTo(0.0, 0.0, 0.0, 0.0);
		this.colorOscillationVariance.setTo(0.0, 0.0, 0.0, 0.0);
		this.colorOscillationFrequency = 1.0;
		this.colorOscillationUnifiedFrequencyVariance = false;
		this.colorOscillationFrequencyVariance = 0.0;
		this.colorOscillationFrequencyInverted = false;
		this.colorOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// color offset
		this.colorOffsetOscillationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.colorOffsetOscillationGroupStartStep = 0.0;
		this.colorOffsetOscillation.setTo(0.0, 0.0, 0.0, 0.0);
		this.colorOffsetOscillationVariance.setTo(0.0, 0.0, 0.0, 0.0);
		this.colorOffsetOscillationFrequency = 1.0;
		this.colorOffsetOscillationUnifiedFrequencyVariance = false;
		this.colorOffsetOscillationFrequencyVariance = 0.0;
		this.colorOffsetOscillationFrequencyInverted = false;
		this.colorOffsetOscillationFrequencyStart = OscillationFrequencyStart.ZERO;
		//\OSCILLATION
		
		this.customFunction = null;
		this.sortFunction = null;
		this.forceSortFlag = false;
		
		this.exactBounds = false;
	}
	
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function clone(target:ParticleSystemOptions = null):ParticleSystemOptions
	{
		if (target == null) target = fromPool();
		
		// EMITTER
		target.emitterType = this.emitterType;
		
		target.maxNumParticles = this.maxNumParticles;
		
		target.particleAmount = this.particleAmount;
		
		target.autoSetEmissionRate = this.autoSetEmissionRate;
		target.emissionRate = this.emissionRate;
		target.emissionRatio = this.emissionRatio;
		
		target.emitterX = this.emitterX;
		target.emitterY = this.emitterY;
		target.emitterXVariance = this.emitterXVariance;
		target.emitterYVariance = this.emitterYVariance;
		
		target.emitterRadiusMax = this.emitterRadiusMax;
		target.emitterRadiusMaxVariance = this.emitterRadiusMaxVariance;
		target.emitterRadiusMin = this.emitterRadiusMin;
		target.emitterRadiusMinVariance = this.emitterRadiusMinVariance;
		target.emitterRadiusOverridesParticleAngle = this.emitterRadiusOverridesParticleAngle;
		target.emitterRadiusParticleAngleOffset = this.emitterRadiusParticleAngleOffset;
		target.emitterRadiusParticleAngleOffsetVariance = this.emitterRadiusParticleAngleOffsetVariance;
		
		target.emitAngle = this.emitAngle;
		target.emitAngleVariance = this.emitAngleVariance;
		target.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
		target.emitAngleAlignedRotationOffset = this.emitAngleAlignedRotationOffset;
		
		target.duration = this.duration;
		
		target.useDisplayRect = this.useDisplayRect;
		target.displayRect.copyFrom(this.displayRect);
		//\EMITTER
		
		// PARTICLE
		target.useAnimationLifeSpan = this.useAnimationLifeSpan;
		target.lifeSpan = this.lifeSpan;
		target.lifeSpanVariance = this.lifeSpanVariance;
		
		target.fadeInTime = this.fadeInTime;
		target.fadeOutTime = this.fadeOutTime;
		
		target.sizeXStart = this.sizeXStart;
		target.sizeXStartVariance = this.sizeXStartVariance;
		target.sizeYStart = this.sizeYStart;
		target.sizeYStartVariance = this.sizeYStartVariance;
		
		target.sizeXEnd = this.sizeXEnd;
		target.sizeXEndVariance = this.sizeXEndVariance;
		target.sizeYEnd = this.sizeYEnd;
		target.sizeYEndVariance = this.sizeYEndVariance;
		target.sizeXEndRelativeToStart = this.sizeXEndRelativeToStart;
		target.sizeYEndRelativeToStart = this.sizeYEndRelativeToStart;
		
		target.rotationStart = this.rotationStart;
		target.rotationStartVariance = this.rotationStartVariance;
		target.rotationEnd = this.rotationEnd;
		target.rotationEndVariance = this.rotationEndVariance;
		target.rotationEndRelativeToStart = this.rotationEndRelativeToStart;
		
		target.skewXStart = this.skewXStart;
		target.skewXStartVariance = this.skewXStartVariance;
		target.skewYStart = this.skewYStart;
		target.skewYStartVariance = this.skewYStartVariance;
		
		target.skewXEnd = this.skewXEnd;
		target.skewXEndVariance = this.skewXEndVariance;
		target.skewYEnd = this.skewYEnd;
		target.skewYEndVariance = this.skewYEndVariance;
		target.skewXEndRelativeToStart = this.skewXEndRelativeToStart;
		target.skewYEndRelativeToStart = this.skewYEndRelativeToStart;
		//\PARTICLE
		
		// VELOCITY
		target.velocityXInheritRatio = this.velocityXInheritRatio;
		target.velocityXInheritRatioVariance = this.velocityXInheritRatioVariance;
		target.velocityYInheritRatio = this.velocityYInheritRatio;
		target.velocityYInheritRatioVariance = this.velocityYInheritRatioVariance;
		
		target.linkRotationToVelocity = this.linkRotationToVelocity;
		target.velocityRotationOffset = this.velocityRotationOffset;
		
		target.velocityRotationFactor = this.velocityRotationFactor;
		
		target.velocityScaleFactorX = this.velocityScaleFactorX;
		target.velocityScaleFactorY = this.velocityScaleFactorY;
		
		target.velocitySkewFactorX = this.velocitySkewFactorX;
		target.velocitySkewFactorY = this.velocitySkewFactorY;
		//\VELOCITY
		
		// ANIMATION
		target.textureAnimation = this.textureAnimation;
		target.frameDelta = this.frameDelta;
		target.frameDeltaVariance = this.frameDeltaVariance;
		target.loopAnimation = this.loopAnimation;
		target.animationLoops = this.animationLoops;
		target.randomStartFrame = this.randomStartFrame;
		//\ANIMATION
		
		// GRAVITY
		target.speed = this.speed;
		target.speedVariance = this.speedVariance;
		
		target.adjustLifeSpanToSpeed = this.adjustLifeSpanToSpeed;
		
		target.gravityX = this.gravityX;
		target.gravityY = this.gravityY;
		
		target.radialAcceleration = this.radialAcceleration;
		target.radialAccelerationVariance = this.radialAccelerationVariance;
		
		target.tangentialAcceleration = this.tangentialAcceleration;
		target.tangentialAccelerationVariance = this.tangentialAccelerationVariance;
		
		target.drag = this.drag;
		target.dragVariance = this.dragVariance;
		
		target.repellentForce = this.repellentForce;
		//\GRAVITY
		
		// RADIAL
		target.radiusMax = this.radiusMax;
		target.radiusMaxVariance = this.radiusMaxVariance;
		
		target.radiusMin = this.radiusMin;
		target.radiusMinVariance = this.radiusMinVariance;
		
		target.rotatePerSecond = this.rotatePerSecond;
		target.rotatePerSecondVariance = this.rotatePerSecondVariance;
		
		target.alignRadialRotation = this.alignRadialRotation;
		target.alignRadialRotationOffset = this.alignRadialRotationOffset;
		target.alignRadialRotationOffsetVariance = this.alignRadialRotationOffsetVariance;
		//\RADIAL
		
		// COLOR
		target.colorStart.copyFrom(this.colorStart);
		target.colorStartVariance.copyFrom(this.colorStartVariance);
		
		target.colorEnd.copyFrom(this.colorEnd);
		target.colorEndVariance.copyFrom(this.colorEndVariance);
		
		target.colorEndRelativeToStart = this.colorEndRelativeToStart;
		target.colorEndIsMultiplier = this.colorEndIsMultiplier;
		//\COLOR
		
		// COLOR OFFSET
		target.colorOffsetStart.copyFrom(this.colorOffsetStart);
		target.colorOffsetStartVariance.copyFrom(this.colorOffsetStartVariance);
		
		target.colorOffsetEnd.copyFrom(this.colorOffsetEnd);
		target.colorOffsetEndVariance.copyFrom(this.colorOffsetEndVariance);
		
		target.colorOffsetEndRelativeToStart = this.colorOffsetEndRelativeToStart;
		target.colorOffsetEndIsMultiplier = this.colorOffsetEndIsMultiplier;
		//\COLOR OFFSET
		
		// OSCILLATION
		target.oscillationGlobalFrequency = this.oscillationGlobalFrequency;
		target.oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance;
		
		target.positionOscillationFrequencyMode = this.positionOscillationFrequencyMode;
		target.positionOscillationGroupStartStep = this.positionOscillationGroupStartStep;
		target.positionOscillationAngle = this.positionOscillationAngle;
		target.positionOscillationAngleVariance = this.positionOscillationAngleVariance;
		target.positionOscillationAngleRelativeTo = this.positionOscillationAngleRelativeTo;
		target.positionOscillationRadius = this.positionOscillationRadius;
		target.positionOscillationRadiusVariance = this.positionOscillationRadiusVariance;
		target.positionOscillationFrequency = this.positionOscillationFrequency;
		target.positionOscillationUnifiedFrequencyVariance = this.positionOscillationUnifiedFrequencyVariance;
		target.positionOscillationFrequencyVariance = this.positionOscillationFrequencyVariance;
		target.positionOscillationFrequencyInverted = this.positionOscillationFrequencyInverted;
		target.positionOscillationFrequencyStart = this.positionOscillationFrequencyStart;
		
		target.position2OscillationFrequencyMode = this.position2OscillationFrequencyMode;
		target.position2OscillationGroupStartStep = this.position2OscillationGroupStartStep;
		target.position2OscillationAngle = this.position2OscillationAngle;
		target.position2OscillationAngleVariance = this.position2OscillationAngleVariance;
		target.position2OscillationAngleRelativeTo = this.position2OscillationAngleRelativeTo;
		target.position2OscillationRadius = this.position2OscillationRadius;
		target.position2OscillationRadiusVariance = this.position2OscillationRadiusVariance;
		target.position2OscillationFrequency = this.position2OscillationFrequency;
		target.position2OscillationUnifiedFrequencyVariance = this.position2OscillationUnifiedFrequencyVariance;
		target.position2OscillationFrequencyVariance = this.position2OscillationFrequencyVariance;
		target.position2OscillationFrequencyInverted = this.position2OscillationFrequencyInverted;
		target.position2OscillationFrequencyStart = this.position2OscillationFrequencyStart;
		
		target.rotationOscillationFrequencyMode = this.rotationOscillationFrequencyMode;
		target.rotationOscillationGroupStartStep = this.rotationOscillationGroupStartStep;
		target.rotationOscillationAngle = this.rotationOscillationAngle;
		target.rotationOscillationAngleVariance = this.rotationOscillationAngleVariance;
		target.rotationOscillationFrequency = this.rotationOscillationFrequency;
		target.rotationOscillationUnifiedFrequencyVariance = this.rotationOscillationUnifiedFrequencyVariance;
		target.rotationOscillationFrequencyVariance = this.rotationOscillationFrequencyVariance;
		target.rotationOscillationFrequencyInverted = this.rotationOscillationFrequencyInverted;
		target.rotationOscillationFrequencyStart = this.rotationOscillationFrequencyStart;
		
		target.scaleXOscillationFrequencyMode = this.scaleXOscillationFrequencyMode;
		target.scaleXOscillationGroupStartStep = this.scaleXOscillationGroupStartStep;
		target.scaleXOscillation = this.scaleXOscillation;
		target.scaleXOscillationVariance = this.scaleXOscillationVariance;
		target.scaleXOscillationFrequency = this.scaleXOscillationFrequency;
		target.scaleXOscillationUnifiedFrequencyVariance = this.scaleXOscillationUnifiedFrequencyVariance;
		target.scaleXOscillationFrequencyVariance = this.scaleXOscillationFrequencyVariance;
		target.scaleXOscillationFrequencyInverted = this.scaleXOscillationFrequencyInverted;
		target.scaleXOscillationFrequencyStart = this.scaleXOscillationFrequencyStart;
		
		target.scaleYOscillationFrequencyMode = this.scaleYOscillationFrequencyMode;
		target.scaleYOscillationGroupStartStep = this.scaleYOscillationGroupStartStep;
		target.scaleYOscillation = this.scaleYOscillation;
		target.scaleYOscillationVariance = this.scaleYOscillationVariance;
		target.scaleYOscillationFrequency = this.scaleYOscillationFrequency;
		target.scaleYOscillationUnifiedFrequencyVariance = this.scaleYOscillationUnifiedFrequencyVariance;
		target.scaleYOscillationFrequencyVariance = this.scaleYOscillationFrequencyVariance;
		target.scaleYOscillationFrequencyInverted = this.scaleYOscillationFrequencyInverted;
		target.scaleYOscillationFrequencyStart = this.scaleYOscillationFrequencyStart;
		
		target.skewXOscillationFrequencyMode = this.skewXOscillationFrequencyMode;
		target.skewXOscillationGroupStartStep = this.skewXOscillationGroupStartStep;
		target.skewXOscillation = this.skewXOscillation;
		target.skewXOscillationVariance = this.skewXOscillationVariance;
		target.skewXOscillationFrequency = this.skewXOscillationFrequency;
		target.skewXOscillationUnifiedFrequencyVariance = this.skewXOscillationUnifiedFrequencyVariance;
		target.skewXOscillationFrequencyVariance = this.skewXOscillationFrequencyVariance;
		target.skewXOscillationFrequencyInverted = this.skewXOscillationFrequencyInverted;
		target.skewXOscillationFrequencyStart = this.skewXOscillationFrequencyStart;
		
		target.skewYOscillationFrequencyMode = this.skewYOscillationFrequencyMode;
		target.skewYOscillationGroupStartStep = this.skewYOscillationGroupStartStep;
		target.skewYOscillation = this.skewYOscillation;
		target.skewYOscillationVariance = this.skewYOscillationVariance;
		target.skewYOscillationFrequency = this.skewYOscillationFrequency;
		target.skewYOscillationUnifiedFrequencyVariance = this.skewYOscillationUnifiedFrequencyVariance;
		target.skewYOscillationFrequencyVariance = this.skewYOscillationFrequencyVariance;
		target.skewYOscillationFrequencyInverted = this.skewYOscillationFrequencyInverted;
		target.skewYOscillationFrequencyStart = this.skewYOscillationFrequencyStart;
		
		target.colorOscillationFrequencyMode = this.colorOscillationFrequencyMode;
		target.colorOscillationGroupStartStep = this.colorOscillationGroupStartStep;
		target.colorOscillation.copyFrom(this.colorOscillation);
		target.colorOscillationVariance.copyFrom(this.colorOscillationVariance);
		target.colorOscillationFrequency = this.colorOscillationFrequency;
		target.colorOscillationUnifiedFrequencyVariance = this.colorOscillationUnifiedFrequencyVariance;
		target.colorOscillationFrequencyVariance = this.colorOscillationFrequencyVariance;
		target.colorOscillationFrequencyInverted = this.colorOscillationFrequencyInverted;
		target.colorOscillationFrequencyStart = this.colorOscillationFrequencyStart;
		
		target.colorOffsetOscillationFrequencyMode = this.colorOffsetOscillationFrequencyMode;
		target.colorOffsetOscillationGroupStartStep = this.colorOffsetOscillationGroupStartStep;
		target.colorOffsetOscillation.copyFrom(this.colorOffsetOscillation);
		target.colorOffsetOscillationVariance.copyFrom(this.colorOffsetOscillationVariance);
		target.colorOffsetOscillationFrequency = this.colorOffsetOscillationFrequency;
		target.colorOffsetOscillationUnifiedFrequencyVariance = this.colorOffsetOscillationUnifiedFrequencyVariance;
		target.colorOffsetOscillationFrequencyVariance = this.colorOffsetOscillationFrequencyVariance;
		target.colorOffsetOscillationFrequencyInverted = this.colorOffsetOscillationFrequencyInverted;
		target.colorOffsetOscillationFrequencyStart = this.colorOffsetOscillationFrequencyStart;
		//\OSCILLATION
		
		target.exactBounds = this.exactBounds;
		
		target.customFunction = this.customFunction;
		target.sortFunction = this.sortFunction;
		target.forceSortFlag = this.forceSortFlag;
		
		return target;
	}
	
	/**
	   
	   @param	json
	**/
	@:access(massive.util.MassiveTint)
	public function fromJSON(json:Dynamic):Void
	{
		// EMITTER
		this.emitterType = json.emitterType;
		
		this.maxNumParticles = json.maxNumParticles;
		
		this.particleAmount = json.particleAmount;
		
		this.autoSetEmissionRate = json.autoSetEmissionRate;
		this.emissionRate = json.emissionRate;
		this.emissionRatio = json.emissionRatio;
		
		this.emitterX = json.emitterX;
		this.emitterY = json.emitterY;
		this.emitterXVariance = json.emitterXVariance;
		this.emitterYVariance = json.emitterYVariance;
		
		this.emitterRadiusMax = json.emitterRadiusMax;
		this.emitterRadiusMaxVariance = json.emitterRadiusMaxVariance;
		this.emitterRadiusMin = json.emitterRadiusMin;
		this.emitterRadiusMinVariance = json.emitterRadiusMinVariance;
		this.emitterRadiusOverridesParticleAngle = json.emitterRadiusOverridesParticleAngle;
		this.emitterRadiusParticleAngleOffset = json.emitterRadiusParticleAngleOffset;
		this.emitterRadiusParticleAngleOffsetVariance = json.emitterRadiusParticleAngleOffsetVariance;
		
		this.emitAngle = json.emitAngle;
		this.emitAngleVariance = json.emitAngleVariance;
		this.emitAngleAlignedRotation = json.emitAngleAlignedRotation;
		if (json.emitAngleAlignedRotationOffset != null) this.emitAngleAlignedRotationOffset = json.emitAngleAlignedRotationOffset;
		
		this.duration = json.duration;
		
		this.useDisplayRect = json.useDisplayRect;
		if (json.displayRect != null)
		{
			this.displayRect.setTo(json.displayRect.x, json.displayRect.y, json.displayRect.w, json.displayRect.h);
		}
		else
		{
			this.displayRect.setEmpty();
		}
		//\EMITTER
		
		// PARTICLE
		this.useAnimationLifeSpan = json.useAnimationLifeSpan;
		this.lifeSpan = json.lifeSpan;
		this.lifeSpanVariance = json.lifeSpanVariance;
		
		this.fadeInTime = json.fadeInTime;
		this.fadeOutTime = json.fadeOutTime;
		
		this.sizeXStart = json.sizeXStart;
		this.sizeXStartVariance = json.sizeXStartVariance;
		this.sizeYStart = json.sizeYStart;
		this.sizeYStartVariance = json.sizeYStartVariance;
		
		this.sizeXEnd = json.sizeXEnd;
		this.sizeXEndVariance = json.sizeXEndVariance;
		this.sizeYEnd = json.sizeYEnd;
		this.sizeYEndVariance = json.sizeYEndVariance;
		this.sizeXEndRelativeToStart = json.sizeXEndRelativeToStart;
		this.sizeYEndRelativeToStart = json.sizeYEndRelativeToStart;
		
		this.rotationStart = json.rotationStart;
		this.rotationStartVariance = json.rotationStartVariance;
		this.rotationEnd = json.rotationEnd;
		this.rotationEndVariance = json.rotationEndVariance;
		this.rotationEndRelativeToStart = json.rotationEndRelativeToStart;
		
		this.skewXStart = json.skewXStart;
		this.skewXStartVariance = json.skewXStartVariance;
		this.skewYStart = json.skewYStart;
		this.skewYStartVariance = json.skewYStartVariance;
		
		this.skewXEnd = json.skewXEnd;
		this.skewXEndVariance = json.skewXEndVariance;
		this.skewYEnd = json.skewYEnd;
		this.skewYEndVariance = json.skewYEndVariance;
		this.skewXEndRelativeToStart = json.skewXEndRelativeToStart;
		this.skewYEndRelativeToStart = json.skewYEndRelativeToStart;
		//\PARTICLE
		
		// VELOCITY
		this.velocityXInheritRatio = json.velocityXInheritRatio;
		this.velocityXInheritRatioVariance = json.velocityXInheritRatioVariance;
		this.velocityYInheritRatio = json.velocityYInheritRatio;
		this.velocityYInheritRatioVariance = json.velocityYInheritRatioVariance;
		
		this.linkRotationToVelocity = json.linkRotationToVelocity;
		this.velocityRotationOffset = json.velocityRotationOffset;
		
		this.velocityRotationFactor = json.velocityRotationFactor;
		
		this.velocityScaleFactorX = json.velocityScaleFactorX;
		this.velocityScaleFactorY = json.velocityScaleFactorY;
		
		this.velocitySkewFactorX = json.velocitySkewFactorX;
		this.velocitySkewFactorY = json.velocitySkewFactorY;
		//\VELOCITY
		
		// ANIMATION
		this.textureAnimation = json.textureAnimation;
		this.frameDelta = json.frameDelta;
		this.frameDeltaVariance = json.frameDeltaVariance;
		this.loopAnimation = json.loopAnimation;
		this.animationLoops = json.animationLoops;
		this.randomStartFrame = json.randomStartFrame;
		//\ANIMATION
		
		// GRAVITY
		this.speed = json.speed;
		this.speedVariance = json.speedVariance;
		
		this.adjustLifeSpanToSpeed = json.adjustLifeSpanToSpeed;
		
		this.gravityX = json.gravityX;
		this.gravityY = json.gravityY;
		
		this.radialAcceleration = json.radialAcceleration;
		this.radialAccelerationVariance = json.radialAccelerationVariance;
		
		this.tangentialAcceleration = json.tangentialAcceleration;
		this.tangentialAccelerationVariance = json.tangentialAccelerationVariance;
		
		this.drag = json.drag;
		this.dragVariance = json.dragVariance;
		
		this.repellentForce = json.repellentForce;
		//\GRAVITY
		
		// RADIAL
		this.radiusMax = json.radiusMax;
		this.radiusMaxVariance = json.radiusMaxVariance;
		
		this.radiusMin = json.radiusMin;
		this.radiusMinVariance = json.radiusMinVariance;
		
		this.rotatePerSecond = json.rotatePerSecond;
		this.rotatePerSecondVariance = json.rotatePerSecondVariance;
		
		this.alignRadialRotation = json.alignRadialRotation;
		this.alignRadialRotationOffset = json.alignRadialRotationOffset;
		this.alignRadialRotationOffsetVariance = json.alignRadialRotationOffsetVariance;
		//\RADIAL
		
		// COLOR
		colorFromJSON(this.colorStart, json.colorStart);
		colorFromJSON(this.colorStartVariance, json.colorStartVariance);
		
		colorFromJSON(this.colorEnd, json.colorEnd);
		colorFromJSON(this.colorEndVariance, json.colorEndVariance);
		
		this.colorEndRelativeToStart = json.colorEndRelativeToStart;
		this.colorEndIsMultiplier = json.colorEndIsMultiplier;
		//\COLOR
		
		// COLOR OFFSET
		colorFromJSON(this.colorOffsetStart, json.colorOffsetStart);
		colorFromJSON(this.colorOffsetStartVariance, json.colorOffsetStartVariance);
		
		colorFromJSON(this.colorOffsetEnd, json.colorOffsetEnd);
		colorFromJSON(this.colorOffsetEndVariance, json.colorOffsetEndVariance);
		
		this.colorOffsetEndRelativeToStart = json.colorOffsetEndRelativeToStart;
		this.colorOffsetEndIsMultiplier = json.colorOffsetEndIsMultiplier;
		//\COLOR OFFSET
		
		// OSCILLATION
		this.oscillationGlobalFrequency = json.oscillationGlobalFrequency;
		this.oscillationUnifiedFrequencyVariance = json.oscillationUnifiedFrequencyVariance;
		
		// position
		this.positionOscillationFrequencyMode = json.positionOscillationFrequencyMode;
		this.positionOscillationGroupStartStep = json.positionOscillationGroupStartStep;
		this.positionOscillationAngle = json.positionOscillationAngle;
		this.positionOscillationAngleVariance = json.positionOscillationAngleVariance;
		this.positionOscillationAngleRelativeTo = json.positionOscillationAngleRelativeTo;
		this.positionOscillationRadius = json.positionOscillationRadius;
		this.positionOscillationRadiusVariance = json.positionOscillationRadiusVariance;
		this.positionOscillationFrequency = json.positionOscillationFrequency;
		this.positionOscillationUnifiedFrequencyVariance = json.positionOscillationUnifiedFrequencyVariance;
		this.positionOscillationFrequencyVariance = json.positionOscillationFrequencyVariance;
		this.positionOscillationFrequencyInverted = json.positionOscillationFrequencyInverted;
		this.positionOscillationFrequencyStart = json.positionOscillationFrequencyStart;
		
		// position2
		this.position2OscillationFrequencyMode = json.position2OscillationFrequencyMode;
		this.position2OscillationGroupStartStep = json.position2OscillationGroupStartStep;
		this.position2OscillationAngle = json.position2OscillationAngle;
		this.position2OscillationAngleVariance = json.position2OscillationAngleVariance;
		this.position2OscillationAngleRelativeTo = json.position2OscillationAngleRelativeTo;
		this.position2OscillationRadius = json.position2OscillationRadius;
		this.position2OscillationRadiusVariance = json.position2OscillationRadiusVariance;
		this.position2OscillationFrequency = json.position2OscillationFrequency;
		this.position2OscillationUnifiedFrequencyVariance = json.position2OscillationUnifiedFrequencyVariance;
		this.position2OscillationFrequencyVariance = json.position2OscillationFrequencyVariance;
		this.position2OscillationFrequencyInverted = json.position2OscillationFrequencyInverted;
		this.position2OscillationFrequencyStart = json.position2OscillationFrequencyStart;
		
		// rotation
		this.rotationOscillationFrequencyMode = json.rotationOscillationFrequencyMode;
		this.rotationOscillationGroupStartStep = json.rotationOscillationGroupStartStep;
		this.rotationOscillationAngle = json.rotationOscillationAngle;
		this.rotationOscillationAngleVariance = json.rotationOscillationAngleVariance;
		this.rotationOscillationFrequency = json.rotationOscillationFrequency;
		this.rotationOscillationUnifiedFrequencyVariance = json.rotationOscillationUnifiedFrequencyVariance;
		this.rotationOscillationFrequencyVariance = json.rotationOscillationFrequencyVariance;
		this.rotationOscillationFrequencyInverted = json.rotationOscillationFrequencyInverted;
		this.rotationOscillationFrequencyStart = json.rotationOscillationFrequencyStart;
		
		// scaleX
		this.scaleXOscillationFrequencyMode = json.scaleXOscillationFrequencyMode;
		this.scaleXOscillationGroupStartStep = json.scaleXOscillationGroupStartStep;
		this.scaleXOscillation = json.scaleXOscillation;
		this.scaleXOscillationVariance = json.scaleXOscillationVariance;
		this.scaleXOscillationFrequency = json.scaleXOscillationFrequency;
		this.scaleXOscillationUnifiedFrequencyVariance = json.scaleXOscillationUnifiedFrequencyVariance;
		this.scaleXOscillationFrequencyVariance = json.scaleXOscillationFrequencyVariance;
		this.scaleXOscillationFrequencyInverted = json.scaleXOscillationFrequencyInverted;
		this.scaleXOscillationFrequencyStart = json.scaleXOscillationFrequencyStart;
		
		// scaleY
		this.scaleYOscillationFrequencyMode = json.scaleYOscillationFrequencyMode;
		this.scaleYOscillationGroupStartStep = json.scaleYOscillationGroupStartStep;
		this.scaleYOscillation = json.scaleYOscillation;
		this.scaleYOscillationVariance = json.scaleYOscillationVariance;
		this.scaleYOscillationFrequency = json.scaleYOscillationFrequency;
		this.scaleYOscillationUnifiedFrequencyVariance = json.scaleYOscillationUnifiedFrequencyVariance;
		this.scaleYOscillationFrequencyVariance = json.scaleYOscillationFrequencyVariance;
		this.scaleYOscillationFrequencyInverted = json.scaleYOscillationFrequencyInverted;
		this.scaleYOscillationFrequencyStart = json.scaleYOscillationFrequencyStart;
		
		// skewX
		this.skewXOscillationFrequencyMode = json.skewXOscillationFrequencyMode;
		this.skewXOscillationGroupStartStep = json.skewXOscillationGroupStartStep;
		this.skewXOscillation = json.skewXOscillation;
		this.skewXOscillationVariance = json.skewXOscillationVariance;
		this.skewXOscillationFrequency = json.skewXOscillationFrequency;
		this.skewXOscillationUnifiedFrequencyVariance = json.skewXOscillationUnifiedFrequencyVariance;
		this.skewXOscillationFrequencyVariance = json.skewXOscillationFrequencyVariance;
		this.skewXOscillationFrequencyInverted = json.skewXOscillationFrequencyInverted;
		this.skewXOscillationFrequencyStart = json.skewXOscillationFrequencyStart;
		
		// skewY
		this.skewYOscillationFrequencyMode = json.skewYOscillationFrequencyMode;
		this.skewYOscillationGroupStartStep = json.skewYOscillationGroupStartStep;
		this.skewYOscillation = json.skewYOscillation;
		this.skewYOscillationVariance = json.skewYOscillationVariance;
		this.skewYOscillationFrequency = json.skewYOscillationFrequency;
		this.skewYOscillationUnifiedFrequencyVariance = json.skewYOscillationUnifiedFrequencyVariance;
		this.skewYOscillationFrequencyVariance = json.skewYOscillationFrequencyVariance;
		this.skewYOscillationFrequencyInverted = json.skewYOscillationFrequencyInverted;
		this.skewYOscillationFrequencyStart = json.skewYOscillationFrequencyStart;
		
		// color
		this.colorOscillationFrequencyMode = json.colorOscillationFrequencyMode;
		this.colorOscillationGroupStartStep = json.colorOscillationGroupStartStep;
		colorFromJSON(this.colorOscillation, json.colorOscillation);
		colorFromJSON(this.colorOscillationVariance, json.colorOscillationVariance);
		this.colorOscillationFrequency = json.colorOscillationFrequency;
		this.colorOscillationUnifiedFrequencyVariance = json.colorOscillationUnifiedFrequencyVariance;
		this.colorOscillationFrequencyVariance = json.colorOscillationFrequencyVariance;
		this.colorOscillationFrequencyInverted = json.colorOscillationFrequencyInverted;
		this.colorOscillationFrequencyStart = json.colorOscillationFrequencyStart;
		
		// color offset
		this.colorOffsetOscillationFrequencyMode = json.colorOffsetOscillationFrequencyMode;
		this.colorOffsetOscillationGroupStartStep = json.colorOffsetOscillationGroupStartStep;
		colorFromJSON(this.colorOffsetOscillation, json.colorOffsetOscillation);
		colorFromJSON(this.colorOffsetOscillationVariance, json.colorOffsetOscillationVariance);
		this.colorOffsetOscillationFrequency = json.colorOffsetOscillationFrequency;
		this.colorOffsetOscillationUnifiedFrequencyVariance = json.colorOffsetOscillationUnifiedFrequencyVariance;
		this.colorOffsetOscillationFrequencyVariance = json.colorOffsetOscillationFrequencyVariance;
		this.colorOffsetOscillationFrequencyInverted = json.colorOffsetOscillationFrequencyInverted;
		this.colorOffsetOscillationFrequencyStart = json.colorOffsetOscillationFrequencyStart;
		//\OSCILLATION
		
		this.exactBounds = json.exactBounds;
		
		this.forceSortFlag = json.forceSortFlag;
	}
	
	/**
	   
	   @param	json
	   @return
	**/
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		// EMITTER
		json.emitterType = this.emitterType;
		
		json.maxNumParticles = this.maxNumParticles;
		
		json.particleAmount = this.particleAmount;
		
		json.autoSetEmissionRate = this.autoSetEmissionRate;
		json.emissionRate = this.emissionRate;
		json.emissionRatio = this.emissionRatio;
		
		json.emitterX = this.emitterX;
		json.emitterY = this.emitterY;
		json.emitterXVariance = this.emitterXVariance;
		json.emitterYVariance = this.emitterYVariance;
		
		json.emitterRadiusMax = this.emitterRadiusMax;
		json.emitterRadiusMaxVariance = this.emitterRadiusMaxVariance;
		json.emitterRadiusMin = this.emitterRadiusMin;
		json.emitterRadiusMinVariance = this.emitterRadiusMinVariance;
		json.emitterRadiusOverridesParticleAngle = this.emitterRadiusOverridesParticleAngle;
		json.emitterRadiusParticleAngleOffset = this.emitterRadiusParticleAngleOffset;
		json.emitterRadiusParticleAngleOffsetVariance = this.emitterRadiusParticleAngleOffsetVariance;
		
		json.emitAngle = this.emitAngle;
		json.emitAngleVariance = this.emitAngleVariance;
		json.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
		json.emitAngleAlignedRotationOffset = this.emitAngleAlignedRotationOffset;
		
		json.duration = this.duration;
		
		json.useDisplayRect = this.useDisplayRect;
		if (!this.displayRect.isEmpty())
		{
			json.displayRect = {x:this.displayRect.x, y:this.displayRect.y, w:this.displayRect.width, h:this.displayRect.height};
		}
		//\EMITTER
		
		// PARTICLE
		json.useAnimationLifeSpan = this.useAnimationLifeSpan;
		json.lifeSpan = this.lifeSpan;
		json.lifeSpanVariance = this.lifeSpanVariance;
		
		json.fadeInTime = this.fadeInTime;
		json.fadeOutTime = this.fadeOutTime;
		
		json.sizeXStart = this.sizeXStart;
		json.sizeXStartVariance = this.sizeXStartVariance;
		json.sizeYStart = this.sizeYStart;
		json.sizeYStartVariance = this.sizeYStartVariance;
		
		json.sizeXEnd = this.sizeXEnd;
		json.sizeXEndVariance = this.sizeXEndVariance;
		json.sizeYEnd = this.sizeYEnd;
		json.sizeYEndVariance = this.sizeYEndVariance;
		json.sizeXEndRelativeToStart = this.sizeXEndRelativeToStart;
		json.sizeYEndRelativeToStart = this.sizeYEndRelativeToStart;
		
		json.rotationStart = this.rotationStart;
		json.rotationStartVariance = this.rotationStartVariance;
		json.rotationEnd = this.rotationEnd;
		json.rotationEndVariance = this.rotationEndVariance;
		json.rotationEndRelativeToStart = this.rotationEndRelativeToStart;
		
		json.skewXStart = this.skewXStart;
		json.skewXStartVariance = this.skewXStartVariance;
		json.skewYStart = this.skewYStart;
		json.skewYStartVariance = this.skewYStartVariance;
		
		json.skewXEnd = this.skewXEnd;
		json.skewXEndVariance = this.skewXEndVariance;
		json.skewYEnd = this.skewYEnd;
		json.skewYEndVariance = this.skewYEndVariance;
		json.skewXEndRelativeToStart = this.skewXEndRelativeToStart;
		json.skewYEndRelativeToStart = this.skewYEndRelativeToStart;
		//\PARTICLE
		
		// VELOCITY
		json.velocityXInheritRatio = this.velocityXInheritRatio;
		json.velocityXInheritRatioVariance = this.velocityXInheritRatioVariance;
		json.velocityYInheritRatio = this.velocityYInheritRatio;
		json.velocityYInheritRatioVariance = this.velocityYInheritRatioVariance;
		
		json.linkRotationToVelocity = this.linkRotationToVelocity;
		json.velocityRotationOffset = this.velocityRotationOffset;
		
		json.velocityRotationFactor = this.velocityRotationFactor;
		
		json.velocityScaleFactorX = this.velocityScaleFactorX;
		json.velocityScaleFactorY = this.velocityScaleFactorY;
		
		json.velocitySkewFactorX = this.velocitySkewFactorX;
		json.velocitySkewFactorY = this.velocitySkewFactorY;
		//\VELOCITY
		
		// ANIMATION
		json.textureAnimation = this.textureAnimation;
		json.frameDelta = this.frameDelta;
		json.frameDeltaVariance = this.frameDeltaVariance;
		json.loopAnimation = this.loopAnimation;
		json.animationLoops = this.animationLoops;
		json.randomStartFrame = this.randomStartFrame;
		//\ANIMATION
		
		// GRAVITY
		json.speed = this.speed;
		json.speedVariance = this.speedVariance;
		json.adjustLifeSpanToSpeed = this.adjustLifeSpanToSpeed;
		
		json.gravityX = this.gravityX;
		json.gravityY = this.gravityY;
		
		json.radialAcceleration = this.radialAcceleration;
		json.radialAccelerationVariance = this.radialAccelerationVariance;
		
		json.tangentialAcceleration = this.tangentialAcceleration;
		json.tangentialAccelerationVariance = this.tangentialAccelerationVariance;
		
		json.drag = this.drag;
		json.dragVariance = this.dragVariance;
		
		json.repellentForce = this.repellentForce;
		//\GRAVITY
		
		// RADIAL
		json.radiusMax = this.radiusMax;
		json.radiusMaxVariance = this.radiusMaxVariance;
		
		json.radiusMin = this.radiusMin;
		json.radiusMinVariance = this.radiusMinVariance;
		
		json.rotatePerSecond = this.rotatePerSecond;
		json.rotatePerSecondVariance = this.rotatePerSecondVariance;
		
		json.alignRadialRotation = this.alignRadialRotation;
		json.alignRadialRotationOffset = this.alignRadialRotationOffset;
		json.alignRadialRotationOffsetVariance = this.alignRadialRotationOffsetVariance;
		//\RADIAL
		
		// COLOR
		json.colorStart = colorToJSON(this.colorStart);
		json.colorStartVariance = colorToJSON(this.colorStartVariance);
		
		json.colorEnd = colorToJSON(this.colorEnd);
		json.colorEndVariance = colorToJSON(this.colorEndVariance);
		
		json.colorEndRelativeToStart = this.colorEndRelativeToStart;
		json.colorEndIsMultiplier = this.colorEndIsMultiplier;
		//\COLOR
		
		// COLOR OFFSET
		json.colorOffsetStart = colorToJSON(this.colorOffsetStart);
		json.colorOffsetStartVariance = colorToJSON(this.colorOffsetStartVariance);
		
		json.colorOffsetEnd = colorToJSON(this.colorOffsetEnd);
		json.colorOffsetEndVariance = colorToJSON(this.colorOffsetEndVariance);
		
		json.colorOffsetEndRelativeToStart = this.colorOffsetEndRelativeToStart;
		json.colorOffsetEndIsMultiplier = this.colorOffsetEndIsMultiplier;
		//\COLOR OFFSET
		
		// OSCILLATION
		json.oscillationGlobalFrequency = this.oscillationGlobalFrequency;
		json.oscillationUnifiedFrequencyVariance = this.oscillationUnifiedFrequencyVariance;
		
		// position
		json.positionOscillationFrequencyMode = this.positionOscillationFrequencyMode;
		json.positionOscillationGroupStartStep = this.positionOscillationGroupStartStep;
		json.positionOscillationAngle = this.positionOscillationAngle;
		json.positionOscillationAngleVariance = this.positionOscillationAngleVariance;
		json.positionOscillationAngleRelativeTo = this.positionOscillationAngleRelativeTo;
		json.positionOscillationRadius = this.positionOscillationRadius;
		json.positionOscillationRadiusVariance = this.positionOscillationRadiusVariance;
		json.positionOscillationFrequency = this.positionOscillationFrequency;
		json.positionOscillationUnifiedFrequencyVariance = this.positionOscillationUnifiedFrequencyVariance;
		json.positionOscillationFrequencyVariance = this.positionOscillationFrequencyVariance;
		json.positionOscillationFrequencyInverted = this.positionOscillationFrequencyInverted;
		json.positionOscillationFrequencyStart = this.positionOscillationFrequencyStart;
		
		// position2
		json.position2OscillationFrequencyMode = this.position2OscillationFrequencyMode;
		json.position2OscillationGroupStartStep = this.position2OscillationGroupStartStep;
		json.position2OscillationAngle = this.position2OscillationAngle;
		json.position2OscillationAngleVariance = this.position2OscillationAngleVariance;
		json.position2OscillationAngleRelativeTo = this.position2OscillationAngleRelativeTo;
		json.position2OscillationRadius = this.position2OscillationRadius;
		json.position2OscillationRadiusVariance = this.position2OscillationRadiusVariance;
		json.position2OscillationFrequency = this.position2OscillationFrequency;
		json.position2OscillationUnifiedFrequencyVariance = this.position2OscillationUnifiedFrequencyVariance;
		json.position2OscillationFrequencyVariance = this.position2OscillationFrequencyVariance;
		json.position2OscillationFrequencyInverted = this.position2OscillationFrequencyInverted;
		json.position2OscillationFrequencyStart = this.position2OscillationFrequencyStart;
		
		// rotation
		json.rotationOscillationFrequencyMode = this.rotationOscillationFrequencyMode;
		json.rotationOscillationGroupStartStep = this.rotationOscillationGroupStartStep;
		json.rotationOscillationAngle = this.rotationOscillationAngle;
		json.rotationOscillationAngleVariance = this.rotationOscillationAngleVariance;
		json.rotationOscillationFrequency = this.rotationOscillationFrequency;
		json.rotationOscillationUnifiedFrequencyVariance = this.rotationOscillationUnifiedFrequencyVariance;
		json.rotationOscillationFrequencyVariance = this.rotationOscillationFrequencyVariance;
		json.rotationOscillationFrequencyInverted = this.rotationOscillationFrequencyInverted;
		json.rotationOscillationFrequencyStart = this.rotationOscillationFrequencyStart;
		
		// scaleX
		json.scaleXOscillationFrequencyMode = this.scaleXOscillationFrequencyMode;
		json.scaleXOscillationGroupStartStep = this.scaleXOscillationGroupStartStep;
		json.scaleXOscillation = this.scaleXOscillation;
		json.scaleXOscillationVariance = this.scaleXOscillationVariance;
		json.scaleXOscillationFrequency = this.scaleXOscillationFrequency;
		json.scaleXOscillationUnifiedFrequencyVariance = this.scaleXOscillationUnifiedFrequencyVariance;
		json.scaleXOscillationFrequencyVariance = this.scaleXOscillationFrequencyVariance;
		json.scaleXOscillationFrequencyInverted = this.scaleXOscillationFrequencyInverted;
		json.scaleXOscillationFrequencyStart = this.scaleXOscillationFrequencyStart;
		
		// scaleY
		json.scaleYOscillationFrequencyMode = this.scaleYOscillationFrequencyMode;
		json.scaleYOscillationGroupStartStep = this.scaleYOscillationGroupStartStep;
		json.scaleYOscillation = this.scaleYOscillation;
		json.scaleYOscillationVariance = this.scaleYOscillationVariance;
		json.scaleYOscillationFrequency = this.scaleYOscillationFrequency;
		json.scaleYOscillationUnifiedFrequencyVariance = this.scaleYOscillationUnifiedFrequencyVariance;
		json.scaleYOscillationFrequencyVariance = this.scaleYOscillationFrequencyVariance;
		json.scaleYOscillationFrequencyInverted = this.scaleYOscillationFrequencyInverted;
		json.scaleYOscillationFrequencyStart = this.scaleYOscillationFrequencyStart;
		
		// skewX
		json.skewXOscillationFrequencyMode = this.skewXOscillationFrequencyMode;
		json.skewXOscillationGroupStartStep = this.skewXOscillationGroupStartStep;
		json.skewXOscillation = this.skewXOscillation;
		json.skewXOscillationVariance = this.skewXOscillationVariance;
		json.skewXOscillationFrequency = this.skewXOscillationFrequency;
		json.skewXOscillationUnifiedFrequencyVariance = this.skewXOscillationUnifiedFrequencyVariance;
		json.skewXOscillationFrequencyVariance = this.skewXOscillationFrequencyVariance;
		json.skewXOscillationFrequencyInverted = this.skewXOscillationFrequencyInverted;
		json.skewXOscillationFrequencyStart = this.skewXOscillationFrequencyStart;
		
		// skewY
		json.skewYOscillationFrequencyMode = this.skewYOscillationFrequencyMode;
		json.skewYOscillationGroupStartStep = this.skewYOscillationGroupStartStep;
		json.skewYOscillation = this.skewYOscillation;
		json.skewYOscillationVariance = this.skewYOscillationVariance;
		json.skewYOscillationFrequency = this.skewYOscillationFrequency;
		json.skewYOscillationUnifiedFrequencyVariance = this.skewYOscillationUnifiedFrequencyVariance;
		json.skewYOscillationFrequencyVariance = this.skewYOscillationFrequencyVariance;
		json.skewYOscillationFrequencyInverted = this.skewYOscillationFrequencyInverted;
		json.skewYOscillationFrequencyStart = this.skewYOscillationFrequencyStart;
		
		// color
		json.colorOscillationFrequencyMode = this.colorOscillationFrequencyMode;
		json.colorOscillationGroupStartStep = this.colorOscillationGroupStartStep;
		json.colorOscillation = colorToJSON(this.colorOscillation);
		json.colorOscillationVariance = colorToJSON(this.colorOscillationVariance);
		json.colorOscillationFrequency = this.colorOscillationFrequency;
		json.colorOscillationUnifiedFrequencyVariance = this.colorOscillationUnifiedFrequencyVariance;
		json.colorOscillationFrequencyVariance = this.colorOscillationFrequencyVariance;
		json.colorOscillationFrequencyInverted = this.colorOscillationFrequencyInverted;
		json.colorOscillationFrequencyStart = this.colorOscillationFrequencyStart;
		
		// color offset
		json.colorOffsetOscillationFrequencyMode = this.colorOffsetOscillationFrequencyMode;
		json.colorOffsetOscillationGroupStartStep = this.colorOffsetOscillationGroupStartStep;
		json.colorOffsetOscillation = colorToJSON(this.colorOffsetOscillation);
		json.colorOffsetOscillationVariance = colorToJSON(this.colorOffsetOscillationVariance);
		json.colorOffsetOscillationFrequency = this.colorOffsetOscillationFrequency;
		json.colorOffsetOscillationUnifiedFrequencyVariance = this.colorOffsetOscillationUnifiedFrequencyVariance;
		json.colorOffsetOscillationFrequencyVariance = this.colorOffsetOscillationFrequencyVariance;
		json.colorOffsetOscillationFrequencyInverted = this.colorOffsetOscillationFrequencyInverted;
		json.colorOffsetOscillationFrequencyStart = this.colorOffsetOscillationFrequencyStart;
		//\OSCILLATION
		
		json.exactBounds = this.exactBounds;
		
		json.forceSortFlag = this.forceSortFlag;
		
		return json;
	}
	
	static public function colorFromJSON(color:MassiveTint, json:Dynamic):Void
	{
		color.red = json.red;
		color.green = json.green;
		color.blue = json.blue;
		color.alpha = json.alpha;
	}
	
	static public function colorToJSON(color:MassiveTint, json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.red = color.red;
		json.green = color.green;
		json.blue = color.blue;
		json.alpha = color.alpha;
		
		return json;
	}
	
	public function fromXML(config:Xml):Void
	{
		var xml:Access = new Access(config.firstElement());
		this.emitterX = Std.parseFloat(xml.node.sourcePosition.att.x);
		this.emitterY = Std.parseFloat(xml.node.sourcePosition.att.y);
		this.emitterXVariance = Std.parseFloat(xml.node.sourcePositionVariance.att.x);
		this.emitterYVariance = Std.parseFloat(xml.node.sourcePositionVariance.att.y);
		this.gravityX = Std.parseFloat(xml.node.gravity.att.x);
		this.gravityY = Std.parseFloat(xml.node.gravity.att.y);
		this.emitterType = Std.parseInt(xml.node.emitterType.att.value);
		this.maxNumParticles = Std.parseInt(xml.node.maxParticles.att.value);
		if (xml.hasNode.particleLifeSpan)
		{
			this.lifeSpan = Math.max(0.01, Std.parseFloat(xml.node.particleLifeSpan.att.value));
		}
		else
		{
			this.lifeSpan = Math.max(0.01, Std.parseFloat(xml.node.particleLifespan.att.value));
		}
		if (xml.hasNode.particleLifespanVariance)
		{
			this.lifeSpanVariance = Std.parseFloat(xml.node.particleLifespanVariance.att.value);
		}
		else
		{
			this.lifeSpanVariance = Std.parseFloat(xml.node.particleLifeSpanVariance.att.value);
		}
		this.sizeStart = Std.parseFloat(xml.node.startParticleSize.att.value);
		this.sizeStartVariance = Std.parseFloat(xml.node.startParticleSizeVariance.att.value);
		this.sizeEnd = Std.parseFloat(xml.node.finishParticleSize.att.value);
		if (xml.hasNode.finishParticleSize)
		{
			this.sizeEndVariance = Std.parseFloat(xml.node.finishParticleSizeVariance.att.value);
		}
		else
		{
			this.sizeEndVariance = Std.parseFloat(xml.node.FinishParticleSizeVariance.att.value);
		}
		this.emitAngle = Std.parseFloat(xml.node.angle.att.value);
		this.emitAngleVariance = Std.parseFloat(xml.node.angleVariance.att.value);
		this.rotationStart = Std.parseFloat(xml.node.rotationStart.att.value);
		this.rotationStartVariance = Std.parseFloat(xml.node.rotationStartVariance.att.value);
		if (xml.hasNode.rotationEnd)
		{
			this.rotationEnd = Std.parseFloat(xml.node.rotationEnd.att.value);
		}
		if (xml.hasNode.rotationEndVariance)
		{
			this.rotationEndVariance = Std.parseFloat(xml.node.rotationEndVariance.att.value);
		}
		if (xml.hasNode.emitAngleAlignedRotation) 
		{
			this.emitAngleAlignedRotation = getBoolValue(xml.node.emitAngleAlignedRotation.att.value);
		}
		this.speed = Std.parseFloat(xml.node.speed.att.value);
		this.speedVariance = Std.parseFloat(xml.node.speedVariance.att.value);
		this.radialAcceleration = Std.parseFloat(xml.node.radialAcceleration.att.value);
		this.radialAccelerationVariance = Std.parseFloat(xml.node.radialAccelVariance.att.value);
		this.tangentialAcceleration = Std.parseFloat(xml.node.tangentialAcceleration.att.value);
		this.tangentialAccelerationVariance = Std.parseFloat(xml.node.tangentialAccelVariance.att.value);
		this.radiusMax = Std.parseFloat(xml.node.maxRadius.att.value);
		this.radiusMaxVariance = Std.parseFloat(xml.node.maxRadiusVariance.att.value);
		this.radiusMin = Std.parseFloat(xml.node.minRadius.att.value);
		if (xml.hasNode.minRadiusVariance)
		{
			this.radiusMinVariance = Std.parseFloat(xml.node.minRadiusVariance.att.value);
		}
		this.rotatePerSecond = Std.parseFloat(xml.node.rotatePerSecond.att.value);
		this.rotatePerSecondVariance = Std.parseFloat(xml.node.rotatePerSecondVariance.att.value);
		getColor(xml.node.startColor, this.colorStart);
		getColor(xml.node.startColorVariance, this.colorStartVariance);
		getColor(xml.node.finishColor, this.colorEnd);
		getColor(xml.node.finishColorVariance, this.colorEndVariance);
		//this.blendFuncSource = getBlendFunc(xml.node.blendFuncSource.att.value);
		//this.blendFuncDestination = getBlendFunc(xml.node.blendFuncDestination.att.value);
		this.duration = Std.parseFloat(xml.node.duration.att.value);
		
		// new introduced properties //
		if (xml.hasNode.animation)
		{
			var anim:Access = xml.node.animation;
			if (anim.hasNode.isAnimated)
			{
				this.textureAnimation = getBoolValue(anim.node.isAnimated.att.value);
			}
			if (anim.hasNode.loops)
			{
				this.animationLoops = Std.parseInt(anim.node.loops.att.value);
			}
			if (anim.hasNode.randomStartFrames)
			{
				this.randomStartFrame = getBoolValue(anim.node.randomStartFrames.att.value);
			}
		}
		
		if (xml.hasNode.fadeInTime)
		{
			this.fadeInTime = Std.parseFloat(xml.node.fadeInTime.att.value);
		}
		if (xml.hasNode.fadeOutTime)
		{
			this.fadeOutTime = Std.parseFloat(xml.node.fadeOutTime.att.value);
		}
		if (xml.hasNode.exactBounds)
		{
			this.exactBounds = getBoolValue(xml.node.exactBounds.att.value);
		}
	}
	
	private static function getBoolValue(str:String):Bool
	{
		if (str == null) return false;
		var valueStr:String = str.toLowerCase();
		var valueInt:Int = Std.parseInt(str);
		return valueStr == "true" || valueInt > 0;
	}
	
	private static function getIntValue(str:String):Int
	{
		var result:Float = Std.parseFloat(str);
		return MathUtils.isNaN(result) ? 0 : Std.int(result);
	}
	
	private static function getFloatValue(str:String):Float
	{
		var result:Float = Std.parseFloat(str);
		return MathUtils.isNaN(result) ? 0 : result;
	}
	
	private static function getColor(element:Access, color:MassiveTint = null):MassiveTint
	{
		if (color == null) color = new MassiveTint();
		if (element.has.red) color.red = Std.parseFloat(element.att.red);
		if (element.has.green) color.green = Std.parseFloat(element.att.green);
		if (element.has.blue) color.blue = Std.parseFloat(element.att.blue);
		if (element.has.alpha) color.alpha = Std.parseFloat(element.att.alpha);
		return color;
	}
	
	private static function getBlendFunc(str:String):String
	{
		if (MathUtils.isNaN(Std.parseFloat(str)))
		{
			switch (str)
			{
				case "DESTINATION_ALPHA" :
					return Context3DBlendFactor.DESTINATION_ALPHA;
					
				case "DESTINATION_COLOR" :
					return Context3DBlendFactor.DESTINATION_COLOR;
					
				case "ONE" :
					return Context3DBlendFactor.ONE;
					
				case "ONE_MINUS_DESTINATION_ALPHA" :
					return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
					
				case "ONE_MINUS_DESTINATION_COLOR" :
					return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
					
				case "ONE_MINUS_SOURCE_ALPHA" :
					return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					
				case "ONE_MINUS_SOURCE_COLOR" :
					return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
					
				case "SOURCE_ALPHA" :
					return Context3DBlendFactor.SOURCE_ALPHA;
					
				case "SOURCE_COLOR" :
					return Context3DBlendFactor.SOURCE_COLOR;
					
				case "ZERO" :
					return Context3DBlendFactor.ZERO;
			}
		}
		
		var value:Int = getIntValue(str);
		switch (value)
		{
			case 0: 
				return Context3DBlendFactor.ZERO;
				
			case 1: 
				return Context3DBlendFactor.ONE;
				
			case 0x300: 
				return Context3DBlendFactor.SOURCE_COLOR;
				
			case 0x301: 
				return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR;
				
			case 0x302: 
				return Context3DBlendFactor.SOURCE_ALPHA;
				
			case 0x303: 
				return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				
			case 0x304: 
				return Context3DBlendFactor.DESTINATION_ALPHA;
				
			case 0x305: 
				return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
				
			case 0x306: 
				return Context3DBlendFactor.DESTINATION_COLOR;
				
			case 0x307: 
				return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR;
				
			default : throw new ArgumentError("unsupported blending function: " + str);
		}
	}
	
}