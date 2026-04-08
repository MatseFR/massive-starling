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
	public var oscillationPositionFrequencyMode:String = OscillationFrequencyMode.SINGLE;
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
	public var oscillationPositionAngleRelativeTo:String = AngleRelativeTo.ROTATION;
	/**
	   @default 0
	**/
	public var oscillationPositionRadius:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPositionRadiusVariance:Float = 0.0;
	/**
	   @default 1
	**/
	public var oscillationPositionFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationPositionUnifiedFrequencyVariance:Bool = false;
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
	public var oscillationPositionFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// Position2
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationPosition2FrequencyMode:String = OscillationFrequencyMode.SINGLE;
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
	public var oscillationPosition2AngleRelativeTo:String = AngleRelativeTo.ROTATION;
	/**
	   @default 0
	**/
	public var oscillationPosition2Radius:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPosition2RadiusVariance:Float = 0.0;
	/**
	   @default 1
	**/
	public var oscillationPosition2Frequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationPosition2UnifiedFrequencyVariance:Bool = false;
	/**
	   @default 0
	**/
	public var oscillationPosition2FrequencyVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var oscillationPosition2FrequencyInverted:Bool = false;
	/**
	   see OscillationFrequencyStart for possible values
	   @default	OscillationFrequencyStart.ZERO
	**/
	public var oscillationPosition2FrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// Rotation
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationRotationFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var oscillationRotationGroupStartStep:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationRotationAngle:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationRotationAngleVariance:Float = 0.0;
	/**
	   @default 1
	**/
	public var oscillationRotationFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationRotationUnifiedFrequencyVariance:Bool = false;
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
	public var oscillationRotationFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// ScaleX
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationScaleXFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var oscillationScaleXGroupStartStep:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationScaleX:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationScaleXVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var oscillationScaleXFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationScaleXUnifiedFrequencyVariance:Bool = false;
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
	public var oscillationScaleXFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// ScaleY
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationScaleYFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var oscillationScaleYGroupStartStep:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationScaleY:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationScaleYVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var oscillationScaleYFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationScaleYUnifiedFrequencyVariance:Bool = false;
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
	public var oscillationScaleYFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// SkewX
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationSkewXFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var oscillationSkewXGroupStartStep:Float = 0.0;
	/**
	   @default	0
	**/
	public var oscillationSkewX:Float = 0.0;
	/**
	   @default	0
	**/
	public var oscillationSkewXVariance:Float = 0.0;
	/**
	   @default	1
	**/
	public var oscillationSkewXFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationSkewXUnifiedFrequencyVariance:Bool = false;
	/**
	   @default	0
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
	public var oscillationSkewXFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// SkewY
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationSkewYFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var oscillationSkewYGroupStartStep:Float = 0.0;
	/**
	   @default	0
	**/
	public var oscillationSkewY:Float = 0.0;
	/**
	   @default	0
	**/
	public var oscillationSkewYVariance:Float = 0.0;
	/**
	   @default	1
	**/
	public var oscillationSkewYFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationSkewYUnifiedFrequencyVariance:Bool = false;
	/**
	   @default	0
	**/
	public var oscillationSkewYFrequencyVariance:Float = 0.0;
	/**
	   @default	false
	**/
	public var oscillationSkewYFrequencyInverted:Bool = false;
	/**
	   
	**/
	public var oscillationSkewYFrequencyStart:String = OscillationFrequencyStart.ZERO;
	
	// Color
	/**
	   see OscillationFrequencyMode for possible values
	   @default	OscillationFrequencyMode.SINGLE
	**/
	public var oscillationColorFrequencyMode:String = OscillationFrequencyMode.SINGLE;
	/**
	   @default	0
	**/
	public var oscillationColorGroupStartStep:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorRed:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorGreen:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorBlue:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorAlpha:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorRedVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorGreenVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorBlueVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorAlphaVariance:Float = 0.0;
	/**
	   @default 1
	**/
	public var oscillationColorFrequency:Float = 1.0;
	/**
	   @default	false
	**/
	public var oscillationColorUnifiedFrequencyVariance:Bool = false;
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
	public var oscillationColorFrequencyStart:String = OscillationFrequencyStart.ZERO;
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
		this.colorOffsetStart.setTo(1.0, 1.0, 1.0, 1.0);
		this.colorOffsetStartVariance.setTo(0.0, 0.0, 0.0, 0.0);
		
		this.colorOffsetEnd.setTo(1.0, 1.0, 1.0, 1.0);
		this.colorOffsetEndVariance.setTo(0.0, 0.0, 0.0, 0.0);
		
		this.colorOffsetEndRelativeToStart = false;
		this.colorOffsetEndIsMultiplier = false;
		//\COLOR OFFSET
		
		// OSCILLATION
		this.oscillationGlobalFrequency = 1.0;
		this.oscillationUnifiedFrequencyVariance = 0.0;
		
		// position
		this.oscillationPositionFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationPositionGroupStartStep = 0.0;
		this.oscillationPositionAngle = 0.0;
		this.oscillationPositionAngleVariance = 0.0;
		this.oscillationPositionAngleRelativeTo = AngleRelativeTo.ROTATION;
		this.oscillationPositionRadius = 0.0;
		this.oscillationPositionRadiusVariance = 0.0;
		this.oscillationPositionFrequency = 1.0;
		this.oscillationPositionUnifiedFrequencyVariance = false;
		this.oscillationPositionFrequencyVariance = 0.0;
		this.oscillationPositionFrequencyInverted = false;
		this.oscillationPositionFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// position2
		this.oscillationPosition2FrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationPosition2GroupStartStep = 0.0;
		this.oscillationPosition2Angle = 0.0;
		this.oscillationPosition2AngleVariance = 0.0;
		this.oscillationPosition2AngleRelativeTo = AngleRelativeTo.ROTATION;
		this.oscillationPosition2Radius = 0.0;
		this.oscillationPosition2RadiusVariance = 0.0;
		this.oscillationPosition2Frequency = 1.0;
		this.oscillationPosition2UnifiedFrequencyVariance = false;
		this.oscillationPosition2FrequencyVariance = 0.0;
		this.oscillationPosition2FrequencyInverted = false;
		this.oscillationPosition2FrequencyStart = OscillationFrequencyStart.ZERO;
		
		// rotation
		this.oscillationRotationFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationRotationGroupStartStep = 0.0;
		this.oscillationRotationAngle = 0.0;
		this.oscillationRotationAngleVariance = 0.0;
		this.oscillationRotationFrequency = 1.0;
		this.oscillationRotationUnifiedFrequencyVariance = false;
		this.oscillationRotationFrequencyVariance = 0.0;
		this.oscillationRotationFrequencyInverted = false;
		this.oscillationRotationFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// scaleX
		this.oscillationScaleXFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationScaleXGroupStartStep = 0.0;
		this.oscillationScaleX = 0.0;
		this.oscillationScaleXVariance = 0.0;
		this.oscillationScaleXFrequency = 1.0;
		this.oscillationScaleXUnifiedFrequencyVariance = false;
		this.oscillationScaleXFrequencyVariance = 0.0;
		this.oscillationScaleXFrequencyInverted = false;
		this.oscillationScaleXFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// scaleY
		this.oscillationScaleYFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationScaleYGroupStartStep = 0.0;
		this.oscillationScaleY = 0.0;
		this.oscillationScaleYVariance = 0.0;
		this.oscillationScaleYFrequency = 1.0;
		this.oscillationScaleYUnifiedFrequencyVariance = false;
		this.oscillationScaleYFrequencyVariance = 0.0;
		this.oscillationScaleYFrequencyInverted = false;
		this.oscillationScaleYFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// skewX
		this.oscillationSkewXFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationSkewXGroupStartStep = 0.0;
		this.oscillationSkewX = 0.0;
		this.oscillationSkewXVariance = 0.0;
		this.oscillationSkewXFrequency = 1.0;
		this.oscillationSkewXUnifiedFrequencyVariance = false;
		this.oscillationSkewXFrequencyVariance = 0.0;
		this.oscillationSkewXFrequencyInverted = false;
		this.oscillationSkewXFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// slewY
		this.oscillationSkewYFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationSkewYGroupStartStep = 0.0;
		this.oscillationSkewY = 0.0;
		this.oscillationSkewYVariance = 0.0;
		this.oscillationSkewYFrequency = 1.0;
		this.oscillationSkewYUnifiedFrequencyVariance = false;
		this.oscillationSkewYFrequencyVariance = 0.0;
		this.oscillationSkewYFrequencyInverted = false;
		this.oscillationSkewYFrequencyStart = OscillationFrequencyStart.ZERO;
		
		// color
		this.oscillationColorFrequencyMode = OscillationFrequencyMode.SINGLE;
		this.oscillationColorGroupStartStep = 0.0;
		this.oscillationColorRed = 0.0;
		this.oscillationColorGreen = 0.0;
		this.oscillationColorBlue = 0.0;
		this.oscillationColorAlpha = 0.0;
		this.oscillationColorRedVariance = 0.0;
		this.oscillationColorGreenVariance = 0.0;
		this.oscillationColorBlueVariance = 0.0;
		this.oscillationColorAlphaVariance = 0.0;
		this.oscillationColorFrequency = 1.0;
		this.oscillationColorUnifiedFrequencyVariance = false;
		this.oscillationColorFrequencyVariance = 0.0;
		this.oscillationColorFrequencyInverted = false;
		this.oscillationColorFrequencyStart = OscillationFrequencyStart.ZERO;
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
		
		target.oscillationPositionFrequencyMode = this.oscillationPositionFrequencyMode;
		target.oscillationPositionGroupStartStep = this.oscillationPositionGroupStartStep;
		target.oscillationPositionAngle = this.oscillationPositionAngle;
		target.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
		target.oscillationPositionAngleRelativeTo = this.oscillationPositionAngleRelativeTo;
		target.oscillationPositionRadius = this.oscillationPositionRadius;
		target.oscillationPositionRadiusVariance = this.oscillationPositionRadiusVariance;
		target.oscillationPositionFrequency = this.oscillationPositionFrequency;
		target.oscillationPositionUnifiedFrequencyVariance = this.oscillationPositionUnifiedFrequencyVariance;
		target.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
		target.oscillationPositionFrequencyInverted = this.oscillationPositionFrequencyInverted;
		target.oscillationPositionFrequencyStart = this.oscillationPositionFrequencyStart;
		
		target.oscillationPosition2FrequencyMode = this.oscillationPosition2FrequencyMode;
		target.oscillationPosition2GroupStartStep = this.oscillationPosition2GroupStartStep;
		target.oscillationPosition2Angle = this.oscillationPosition2Angle;
		target.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
		target.oscillationPosition2AngleRelativeTo = this.oscillationPosition2AngleRelativeTo;
		target.oscillationPosition2Radius = this.oscillationPosition2Radius;
		target.oscillationPosition2RadiusVariance = this.oscillationPosition2RadiusVariance;
		target.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
		target.oscillationPosition2UnifiedFrequencyVariance = this.oscillationPosition2UnifiedFrequencyVariance;
		target.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
		target.oscillationPosition2FrequencyInverted = this.oscillationPosition2FrequencyInverted;
		target.oscillationPosition2FrequencyStart = this.oscillationPosition2FrequencyStart;
		
		target.oscillationRotationFrequencyMode = this.oscillationRotationFrequencyMode;
		target.oscillationRotationGroupStartStep = this.oscillationRotationGroupStartStep;
		target.oscillationRotationAngle = this.oscillationRotationAngle;
		target.oscillationRotationAngleVariance = this.oscillationRotationAngleVariance;
		target.oscillationRotationFrequency = this.oscillationRotationFrequency;
		target.oscillationRotationUnifiedFrequencyVariance = this.oscillationRotationUnifiedFrequencyVariance;
		target.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
		target.oscillationRotationFrequencyInverted = this.oscillationRotationFrequencyInverted;
		target.oscillationRotationFrequencyStart = this.oscillationRotationFrequencyStart;
		
		target.oscillationScaleXFrequencyMode = this.oscillationScaleXFrequencyMode;
		target.oscillationScaleXGroupStartStep = this.oscillationScaleXGroupStartStep;
		target.oscillationScaleX = this.oscillationScaleX;
		target.oscillationScaleXVariance = this.oscillationScaleXVariance;
		target.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
		target.oscillationScaleXUnifiedFrequencyVariance = this.oscillationScaleXUnifiedFrequencyVariance;
		target.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
		target.oscillationScaleXFrequencyInverted = this.oscillationScaleXFrequencyInverted;
		target.oscillationScaleXFrequencyStart = this.oscillationScaleXFrequencyStart;
		
		target.oscillationScaleYFrequencyMode = this.oscillationScaleYFrequencyMode;
		target.oscillationScaleYGroupStartStep = this.oscillationScaleYGroupStartStep;
		target.oscillationScaleY = this.oscillationScaleY;
		target.oscillationScaleYVariance = this.oscillationScaleYVariance;
		target.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
		target.oscillationScaleYUnifiedFrequencyVariance = this.oscillationScaleYUnifiedFrequencyVariance;
		target.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
		target.oscillationScaleYFrequencyInverted = this.oscillationScaleYFrequencyInverted;
		target.oscillationScaleYFrequencyStart = this.oscillationScaleYFrequencyStart;
		
		target.oscillationSkewXFrequencyMode = this.oscillationSkewXFrequencyMode;
		target.oscillationSkewXGroupStartStep = this.oscillationSkewXGroupStartStep;
		target.oscillationSkewX = this.oscillationSkewX;
		target.oscillationSkewXVariance = this.oscillationSkewXVariance;
		target.oscillationSkewXFrequency = this.oscillationSkewXFrequency;
		target.oscillationSkewXUnifiedFrequencyVariance = this.oscillationSkewXUnifiedFrequencyVariance;
		target.oscillationSkewXFrequencyVariance = this.oscillationSkewXFrequencyVariance;
		target.oscillationSkewXFrequencyInverted = this.oscillationSkewXFrequencyInverted;
		target.oscillationSkewXFrequencyStart = this.oscillationSkewXFrequencyStart;
		
		target.oscillationSkewYFrequencyMode = this.oscillationSkewYFrequencyMode;
		target.oscillationSkewYGroupStartStep = this.oscillationSkewYGroupStartStep;
		target.oscillationSkewY = this.oscillationSkewY;
		target.oscillationSkewYVariance = this.oscillationSkewYVariance;
		target.oscillationSkewYFrequency = this.oscillationSkewYFrequency;
		target.oscillationSkewYUnifiedFrequencyVariance = this.oscillationSkewYUnifiedFrequencyVariance;
		target.oscillationSkewYFrequencyVariance = this.oscillationSkewYFrequencyVariance;
		target.oscillationSkewYFrequencyInverted = this.oscillationSkewYFrequencyInverted;
		target.oscillationSkewYFrequencyStart = this.oscillationSkewYFrequencyStart;
		
		target.oscillationColorFrequencyMode = this.oscillationColorFrequencyMode;
		target.oscillationColorGroupStartStep = this.oscillationColorGroupStartStep;
		target.oscillationColorRed = this.oscillationColorRed;
		target.oscillationColorGreen = this.oscillationColorGreen;
		target.oscillationColorBlue = this.oscillationColorBlue;
		target.oscillationColorAlpha = this.oscillationColorAlpha;
		target.oscillationColorRedVariance = this.oscillationColorRedVariance;
		target.oscillationColorGreenVariance = this.oscillationColorGreenVariance;
		target.oscillationColorBlueVariance = this.oscillationColorBlueVariance;
		target.oscillationColorAlphaVariance = this.oscillationColorAlphaVariance;
		target.oscillationColorFrequency = this.oscillationColorFrequency;
		target.oscillationColorUnifiedFrequencyVariance = this.oscillationColorUnifiedFrequencyVariance;
		target.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
		target.oscillationColorFrequencyInverted = this.oscillationColorFrequencyInverted;
		target.oscillationColorFrequencyStart = this.oscillationColorFrequencyStart;
		//\OSCILLATION
		
		target.exactBounds = this.exactBounds;
		
		target.customFunction = this.customFunction;
		target.sortFunction = this.sortFunction;
		target.forceSortFlag = this.forceSortFlag;
		
		return target;
	}
	
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
		if (json.emitterRadiusOverridesParticleAngle != null) this.emitterRadiusOverridesParticleAngle = json.emitterRadiusOverridesParticleAngle;
		if (json.emitterRadiusParticleAngleOffset != null) this.emitterRadiusParticleAngleOffset = json.emitterRadiusParticleAngleOffset;
		if (json.emitterRadiusParticleAngleOffsetVariance != null) this.emitterRadiusParticleAngleOffsetVariance = json.emitterRadiusParticleAngleOffsetVariance;
		
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
		if (json.sizeXEndRelativeToStart != null) this.sizeXEndRelativeToStart = json.sizeXEndRelativeToStart;
		if (json.sizeYEndRelativeToStart != null) this.sizeYEndRelativeToStart = json.sizeYEndRelativeToStart;
		
		this.rotationStart = json.rotationStart;
		this.rotationStartVariance = json.rotationStartVariance;
		this.rotationEnd = json.rotationEnd;
		this.rotationEndVariance = json.rotationEndVariance;
		this.rotationEndRelativeToStart = json.rotationEndRelativeToStart;
		
		if (json.skewXStart != null) this.skewXStart = json.skewXStart;
		if (json.skewXStartVariance != null) this.skewXStartVariance = json.skewXStartVariance;
		if (json.skewYStart != null) this.skewYStart = json.skewYStart;
		if (json.skewYStartVariance != null) this.skewYStartVariance = json.skewYStartVariance;
		
		if (json.skewXEnd != null) this.skewXEnd = json.skewXEnd;
		if (json.skewXEndVariance != null) this.skewXEndVariance = json.skewXEndVariance;
		if (json.skewYEnd != null) this.skewYEnd = json.skewYEnd;
		if (json.skewYEndVariance != null) this.skewYEndVariance = json.skewYEndVariance;
		if (json.skewXEndRelativeToStart) this.skewXEndRelativeToStart = json.skewXEndRelativeToStart;
		if (json.skewYEndRelativeToStart) this.skewYEndRelativeToStart = json.skewYEndRelativeToStart;
		//\PARTICLE
		
		// VELOCITY
		this.velocityXInheritRatio = json.velocityXInheritRatio;
		this.velocityXInheritRatioVariance = json.velocityXInheritRatioVariance;
		this.velocityYInheritRatio = json.velocityYInheritRatio;
		this.velocityYInheritRatioVariance = json.velocityYInheritRatioVariance;
		
		this.linkRotationToVelocity = json.linkRotationToVelocity;
		this.velocityRotationOffset = json.velocityRotationOffset;
		
		if (json.velocityRotationFactor != null) this.velocityRotationFactor = json.velocityRotationFactor;
		
		this.velocityScaleFactorX = json.velocityScaleFactorX;
		this.velocityScaleFactorY = json.velocityScaleFactorY;
		
		if (json.velocitySkewFactorX != null) this.velocitySkewFactorX = json.velocitySkewFactorX;
		if (json.velocitySkewFactorY != null) this.velocitySkewFactorY = json.velocitySkewFactorY;
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
		
		if (json.alignRadialRotation != null) this.alignRadialRotation = json.alignRadialRotation;
		if (json.alignRadialRotationOffset != null) this.alignRadialRotationOffset = json.alignRadialRotationOffset;
		if (json.alignRadialRotationOffsetVariance != null) this.alignRadialRotationOffsetVariance = json.alignRadialRotationOffsetVariance;
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
		if (json.colorOffsetStart != null) colorFromJSON(this.colorOffsetStart, json.colorOffsetStart);
		if (json.colorOffsetStartVariance != null) colorFromJSON(this.colorOffsetStartVariance, json.colorOffsetStartVariance);
		
		if (json.colorOffsetEnd != null) colorFromJSON(this.colorOffsetEnd, json.colorOffsetEnd);
		if (json.colorOffsetEndVariance != null) colorFromJSON(this.colorOffsetEndVariance, json.colorOffsetEndVariance);
		
		if (json.colorOffsetEndRelativeToStart != null) this.colorOffsetEndRelativeToStart = json.colorOffsetEndRelativeToStart;
		if (json.colorOffsetEndIsMultiplier != null) this.colorOffsetEndIsMultiplier = json.colorOffsetEndIsMultiplier;
		//\COLOR OFFSET
		
		// OSCILLATION
		this.oscillationGlobalFrequency = json.oscillationGlobalFrequency;
		this.oscillationUnifiedFrequencyVariance = json.oscillationUnifiedFrequencyVariance;
		
		// position
		this.oscillationPositionFrequencyMode = json.oscillationPositionFrequencyMode;
		if (json.oscillationPositionGroupStartStep != null) this.oscillationPositionGroupStartStep = json.oscillationPositionGroupStartStep;
		this.oscillationPositionAngle = json.oscillationPositionAngle;
		this.oscillationPositionAngleVariance = json.oscillationPositionAngleVariance;
		this.oscillationPositionAngleRelativeTo = json.oscillationPositionAngleRelativeTo;
		this.oscillationPositionRadius = json.oscillationPositionRadius;
		this.oscillationPositionRadiusVariance = json.oscillationPositionRadiusVariance;
		this.oscillationPositionFrequency = json.oscillationPositionFrequency;
		this.oscillationPositionUnifiedFrequencyVariance = json.oscillationPositionUnifiedFrequencyVariance;
		this.oscillationPositionFrequencyVariance = json.oscillationPositionFrequencyVariance;
		this.oscillationPositionFrequencyInverted = json.oscillationPositionFrequencyInverted;
		this.oscillationPositionFrequencyStart = json.oscillationPositionFrequencyStart;
		
		// position2
		this.oscillationPosition2FrequencyMode = json.oscillationPosition2FrequencyMode;
		if (json.oscillationPosition2GroupStartStep != null) this.oscillationPosition2GroupStartStep = json.oscillationPosition2GroupStartStep;
		this.oscillationPosition2Angle = json.oscillationPosition2Angle;
		this.oscillationPosition2AngleVariance = json.oscillationPosition2AngleVariance;
		this.oscillationPosition2AngleRelativeTo = json.oscillationPosition2AngleRelativeTo;
		this.oscillationPosition2Radius = json.oscillationPosition2Radius;
		this.oscillationPosition2RadiusVariance = json.oscillationPosition2RadiusVariance;
		this.oscillationPosition2Frequency = json.oscillationPosition2Frequency;
		this.oscillationPosition2UnifiedFrequencyVariance = json.oscillationPosition2UnifiedFrequencyVariance;
		this.oscillationPosition2FrequencyVariance = json.oscillationPosition2FrequencyVariance;
		this.oscillationPosition2FrequencyInverted = json.oscillationPosition2FrequencyInverted;
		this.oscillationPosition2FrequencyStart = json.oscillationPosition2FrequencyStart;
		
		// rotation
		this.oscillationRotationFrequencyMode = json.oscillationRotationFrequencyMode;
		if (json.oscillationRotationGroupStartStep != null) this.oscillationRotationGroupStartStep = json.oscillationRotationGroupStartStep;
		this.oscillationRotationAngle = json.oscillationRotationAngle;
		this.oscillationRotationAngleVariance = json.oscillationRotationAngleVariance;
		this.oscillationRotationFrequency = json.oscillationRotationFrequency;
		this.oscillationRotationUnifiedFrequencyVariance = json.oscillationRotationUnifiedFrequencyVariance;
		this.oscillationRotationFrequencyVariance = json.oscillationRotationFrequencyVariance;
		this.oscillationRotationFrequencyInverted = json.oscillationRotationFrequencyInverted;
		this.oscillationRotationFrequencyStart = json.oscillationRotationFrequencyStart;
		
		// scaleX
		this.oscillationScaleXFrequencyMode = json.oscillationScaleXFrequencyMode;
		if (json.oscillationScaleXGroupStartStep != null) this.oscillationScaleXGroupStartStep = json.oscillationScaleXGroupStartStep;
		this.oscillationScaleX = json.oscillationScaleX;
		this.oscillationScaleXVariance = json.oscillationScaleXVariance;
		this.oscillationScaleXFrequency = json.oscillationScaleXFrequency;
		this.oscillationScaleXUnifiedFrequencyVariance = json.oscillationScaleXUnifiedFrequencyVariance;
		this.oscillationScaleXFrequencyVariance = json.oscillationScaleXFrequencyVariance;
		this.oscillationScaleXFrequencyInverted = json.oscillationScaleXFrequencyInverted;
		this.oscillationScaleXFrequencyStart = json.oscillationScaleXFrequencyStart;
		
		// scaleY
		this.oscillationScaleYFrequencyMode = json.oscillationScaleYFrequencyMode;
		if (json.oscillationScaleYGroupStartStep != null) this.oscillationScaleYGroupStartStep = json.oscillationScaleYGroupStartStep;
		this.oscillationScaleY = json.oscillationScaleY;
		this.oscillationScaleYVariance = json.oscillationScaleYVariance;
		this.oscillationScaleYFrequency = json.oscillationScaleYFrequency;
		this.oscillationScaleYUnifiedFrequencyVariance = json.oscillationScaleYUnifiedFrequencyVariance;
		this.oscillationScaleYFrequencyVariance = json.oscillationScaleYFrequencyVariance;
		this.oscillationScaleYFrequencyInverted = json.oscillationScaleYFrequencyInverted;
		this.oscillationScaleYFrequencyStart = json.oscillationScaleYFrequencyStart;
		
		// skewX
		if (json.oscillationSkewXFrequencyMode != null) this.oscillationSkewXFrequencyMode = json.oscillationSkewXFrequencyMode;
		if (json.oscillationSkewXGroupStartStep != null) this.oscillationSkewXGroupStartStep = json.oscillationSkewXGroupStartStep;
		if (json.oscillationSkewX != null) this.oscillationSkewX = json.oscillationSkewX;
		if (json.oscillationSkewXVariance != null) this.oscillationSkewXVariance = json.oscillationSkewXVariance;
		if (json.oscillationSkewXFrequency != null) this.oscillationSkewXFrequency = json.oscillationSkewXFrequency;
		if (json.oscillationSkewXUnifiedFrequencyVariance != null) this.oscillationSkewXUnifiedFrequencyVariance = json.oscillationSkewXUnifiedFrequencyVariance;
		if (json.oscillationSkewXFrequencyVariance != null) this.oscillationSkewXFrequencyVariance = json.oscillationSkewXFrequencyVariance;
		if (json.oscillationSkewXFrequencyInverted != null) this.oscillationSkewXFrequencyInverted = json.oscillationSkewXFrequencyInverted;
		if (json.oscillationSkewXFrequencyStart != null) this.oscillationSkewXFrequencyStart = json.oscillationSkewXFrequencyStart;
		
		// skewY
		if (json.oscillationSkewYFrequencyMode != null) this.oscillationSkewYFrequencyMode = json.oscillationSkewYFrequencyMode;
		if (json.oscillationSkewYGroupStartStep != null) this.oscillationSkewYGroupStartStep = json.oscillationSkewYGroupStartStep;
		if (json.oscillationSkewY != null) this.oscillationSkewY = json.oscillationSkewY;
		if (json.oscillationSkewYVariance != null) this.oscillationSkewYVariance = json.oscillationSkewYVariance;
		if (json.oscillationSkewYFrequency != null) this.oscillationSkewYFrequency = json.oscillationSkewYFrequency;
		if (json.oscillationSkewYUnifiedFrequencyVariance != null) this.oscillationSkewYUnifiedFrequencyVariance = json.oscillationSkewYUnifiedFrequencyVariance;
		if (json.oscillationSkewYFrequencyVariance != null) this.oscillationSkewYFrequencyVariance = json.oscillationSkewYFrequencyVariance;
		if (json.oscillationSkewYFrequencyInverted != null) this.oscillationSkewYFrequencyInverted = json.oscillationSkewYFrequencyInverted;
		if (json.oscillationSkewYFrequencyStart != null) this.oscillationSkewYFrequencyStart = json.oscillationSkewYFrequencyStart;
		
		// color
		this.oscillationColorFrequencyMode = json.oscillationColorFrequencyMode;
		if (json.oscillationColorGroupStartStep != null) this.oscillationColorGroupStartStep = json.oscillationColorGroupStartStep;
		this.oscillationColorRed = json.oscillationColorRed;
		this.oscillationColorGreen = json.oscillationColorGreen;
		this.oscillationColorBlue = json.oscillationColorBlue;
		this.oscillationColorAlpha = json.oscillationColorAlpha;
		this.oscillationColorRedVariance = json.oscillationColorRedVariance;
		this.oscillationColorGreenVariance = json.oscillationColorGreenVariance;
		this.oscillationColorBlueVariance = json.oscillationColorBlueVariance;
		this.oscillationColorAlphaVariance = json.oscillationColorAlphaVariance;
		this.oscillationColorFrequency = json.oscillationColorFrequency;
		this.oscillationColorUnifiedFrequencyVariance = json.oscillationColorUnifiedFrequencyVariance;
		this.oscillationColorFrequencyVariance = json.oscillationColorFrequencyVariance;
		this.oscillationColorFrequencyInverted = json.oscillationColorFrequencyInverted;
		this.oscillationColorFrequencyStart = json.oscillationColorFrequencyStart;
		//\OSCILLATION
		
		this.exactBounds = json.exactBounds;
		
		this.forceSortFlag = json.forceSortFlag;
	}
	
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
		json.oscillationPositionFrequencyMode = this.oscillationPositionFrequencyMode;
		json.oscillationPositionGroupStartStep = this.oscillationPositionGroupStartStep;
		json.oscillationPositionAngle = this.oscillationPositionAngle;
		json.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
		json.oscillationPositionAngleRelativeTo = this.oscillationPositionAngleRelativeTo;
		json.oscillationPositionRadius = this.oscillationPositionRadius;
		json.oscillationPositionRadiusVariance = this.oscillationPositionRadiusVariance;
		json.oscillationPositionFrequency = this.oscillationPositionFrequency;
		json.oscillationPositionUnifiedFrequencyVariance = this.oscillationPositionUnifiedFrequencyVariance;
		json.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
		json.oscillationPositionFrequencyInverted = this.oscillationPositionFrequencyInverted;
		json.oscillationPositionFrequencyStart = this.oscillationPositionFrequencyStart;
		
		// position2
		json.oscillationPosition2FrequencyMode = this.oscillationPosition2FrequencyMode;
		json.oscillationPosition2GroupStartStep = this.oscillationPosition2GroupStartStep;
		json.oscillationPosition2Angle = this.oscillationPosition2Angle;
		json.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
		json.oscillationPosition2AngleRelativeTo = this.oscillationPosition2AngleRelativeTo;
		json.oscillationPosition2Radius = this.oscillationPosition2Radius;
		json.oscillationPosition2RadiusVariance = this.oscillationPosition2RadiusVariance;
		json.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
		json.oscillationPosition2UnifiedFrequencyVariance = this.oscillationPosition2UnifiedFrequencyVariance;
		json.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
		json.oscillationPosition2FrequencyInverted = this.oscillationPosition2FrequencyInverted;
		json.oscillationPosition2FrequencyStart = this.oscillationPosition2FrequencyStart;
		
		// rotation
		json.oscillationRotationFrequencyMode = this.oscillationRotationFrequencyMode;
		json.oscillationRotationGroupStartStep = this.oscillationRotationGroupStartStep;
		json.oscillationRotationAngle = this.oscillationRotationAngle;
		json.oscillationRotationAngleVariance = this.oscillationRotationAngleVariance;
		json.oscillationRotationFrequency = this.oscillationRotationFrequency;
		json.oscillationRotationUnifiedFrequencyVariance = this.oscillationRotationUnifiedFrequencyVariance;
		json.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
		json.oscillationRotationFrequencyInverted = this.oscillationRotationFrequencyInverted;
		json.oscillationRotationFrequencyStart = this.oscillationRotationFrequencyStart;
		
		// scaleX
		json.oscillationScaleXFrequencyMode = this.oscillationScaleXFrequencyMode;
		json.oscillationScaleXGroupStartStep = this.oscillationScaleXGroupStartStep;
		json.oscillationScaleX = this.oscillationScaleX;
		json.oscillationScaleXVariance = this.oscillationScaleXVariance;
		json.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
		json.oscillationScaleXUnifiedFrequencyVariance = this.oscillationScaleXUnifiedFrequencyVariance;
		json.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
		json.oscillationScaleXFrequencyInverted = this.oscillationScaleXFrequencyInverted;
		json.oscillationScaleXFrequencyStart = this.oscillationScaleXFrequencyStart;
		
		// scaleY
		json.oscillationScaleYFrequencyMode = this.oscillationScaleYFrequencyMode;
		json.oscillationScaleYGroupStartStep = this.oscillationScaleYGroupStartStep;
		json.oscillationScaleY = this.oscillationScaleY;
		json.oscillationScaleYVariance = this.oscillationScaleYVariance;
		json.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
		json.oscillationScaleYUnifiedFrequencyVariance = this.oscillationScaleYUnifiedFrequencyVariance;
		json.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
		json.oscillationScaleYFrequencyInverted = this.oscillationScaleYFrequencyInverted;
		json.oscillationScaleYFrequencyStart = this.oscillationScaleYFrequencyStart;
		
		// skewX
		json.oscillationSkewXFrequencyMode = this.oscillationSkewXFrequencyMode;
		json.oscillationSkewXGroupStartStep = this.oscillationSkewXGroupStartStep;
		json.oscillationSkewX = this.oscillationSkewX;
		json.oscillationSkewXVariance = this.oscillationSkewXVariance;
		json.oscillationSkewXFrequency = this.oscillationSkewXFrequency;
		json.oscillationSkewXUnifiedFrequencyVariance = this.oscillationSkewXUnifiedFrequencyVariance;
		json.oscillationSkewXFrequencyVariance = this.oscillationSkewXFrequencyVariance;
		json.oscillationSkewXFrequencyInverted = this.oscillationSkewXFrequencyInverted;
		json.oscillationSkewXFrequencyStart = this.oscillationSkewXFrequencyStart;
		
		// skewY
		json.oscillationSkewYFrequencyMode = this.oscillationSkewYFrequencyMode;
		json.oscillationSkewYGroupStartStep = this.oscillationSkewYGroupStartStep;
		json.oscillationSkewY = this.oscillationSkewY;
		json.oscillationSkewYVariance = this.oscillationSkewYVariance;
		json.oscillationSkewYFrequency = this.oscillationSkewYFrequency;
		json.oscillationSkewYUnifiedFrequencyVariance = this.oscillationSkewYUnifiedFrequencyVariance;
		json.oscillationSkewYFrequencyVariance = this.oscillationSkewYFrequencyVariance;
		json.oscillationSkewYFrequencyInverted = this.oscillationSkewYFrequencyInverted;
		json.oscillationSkewYFrequencyStart = this.oscillationSkewYFrequencyStart;
		
		// color
		json.oscillationColorFrequencyMode = this.oscillationColorFrequencyMode;
		json.oscillationColorGroupStartStep = this.oscillationColorGroupStartStep;
		json.oscillationColorRed = this.oscillationColorRed;
		json.oscillationColorGreen = this.oscillationColorGreen;
		json.oscillationColorBlue = this.oscillationColorBlue;
		json.oscillationColorAlpha = this.oscillationColorAlpha;
		json.oscillationColorRedVariance = this.oscillationColorRedVariance;
		json.oscillationColorGreenVariance = this.oscillationColorGreenVariance;
		json.oscillationColorBlueVariance = this.oscillationColorBlueVariance;
		json.oscillationColorAlphaVariance = this.oscillationColorAlphaVariance;
		json.oscillationColorFrequency = this.oscillationColorFrequency;
		json.oscillationColorUnifiedFrequencyVariance = this.oscillationColorUnifiedFrequencyVariance;
		json.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
		json.oscillationColorFrequencyInverted = this.oscillationColorFrequencyInverted;
		json.oscillationColorFrequencyStart = this.oscillationColorFrequencyStart;
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