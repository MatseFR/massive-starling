package massive.particle;
import haxe.xml.Access;
import massive.util.MathUtils;
import openfl.display3D.Context3DBlendFactor;
import openfl.errors.ArgumentError;
import openfl.geom.Rectangle;
import starling.extensions.ColorArgb;

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
	public var emissionRate:Float = 100;
	/**
	   Percentage of max particles to consider when automatically setting emission rate
	   @default 1.0
	**/
	public var emissionRatio:Float = 1.0;
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
	/**
	   @default 0
	**/
	public var emitterRadiusMax:Float = 0;
	/**
	   @default 0
	**/
	public var emitterRadiusMaxVariance:Float = 0;
	/**
	   @default 0
	**/
	public var emitterRadiusMin:Float = 0;
	/**
	   @default 0
	**/
	public var emitterRadiusMinVariance:Float = 0;
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
	   Emission time span, -1 = infinite
	**/
	public var duration:Float = -1;
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
	public var lifeSpan:Float = 1;
	/**
	   @default 0
	**/
	public var lifeSpanVariance:Float = 0;
	/**
	   if > 0 the particle alpha will be interpolated from 0 to starting alpha
	   @default 0
	**/
	public var fadeInTime:Float = 0;
	/**
	   if > 0 the particle alpha will be interpolated from current value to end alpha
	   @default 0
	**/
	public var fadeOutTime:Float = 0;
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
	public var sizeXStart:Float = 20;
	/**
	   @default 0
	**/
	public var sizeXStartVariance:Float = 0;
	/**
	   @default 20
	**/
	public var sizeYStart:Float = 20;
	/**
	   @default 0
	**/
	public var sizeYStartVariance:Float = 0;
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
	public var sizeXEnd:Float = 20;
	/**
	   @default 0
	**/
	public var sizeXEndVariance:Float = 0;
	/**
	   @default 20
	**/
	public var sizeYEnd:Float = 20;
	/**
	   @default 0
	**/
	public var sizeYEndVariance:Float = 0;
	/**
	   @default 0
	**/
	public var rotationStart:Float = 0;
	/**
	   @default 0
	**/
	public var rotationStartVariance:Float = 0;
	/**
	   @default 0
	**/
	public var rotationEnd:Float = 0;
	/**
	   @default 0
	**/
	public var rotationEndVariance:Float = 0;
	//##################################################
	//\PARTICLE
	//##################################################
	
	//##################################################
	// VELOCITY
	//##################################################
	/**
	   @default 0
	**/
	public var velocityXInheritRatio:Float = 0;
	/**
	   @default 0
	**/
	public var velocityXInheritRatioVariance:Float = 0;
	/**
	   @default 0
	**/
	public var velocityYInheritRatio:Float = 0;
	/**
	   @default 0
	**/
	public var velocityYInheritRatioVariance:Float = 0;
	/**
	   @default 0
	**/
	public var velocityScaleFactorX:Float = 0;
	/**
	   @default 0
	**/
	public var velocityScaleFactorY:Float = 0;
	/**
	   @default false
	**/
	public var linkRotationToVelocity:Bool = false;
	/**
	   @default 0
	**/
	public var velocityRotationOffset:Float = 0;
	//##################################################
	//\VELOCITY
	//##################################################
	
	//##################################################
	// ANIMATION
	//##################################################
	/**
	   Tells whether the texture should be animated or not
	   @default true
	**/
	public var textureAnimation:Bool = true;
	/**
	   frame rate for texture animation
	   @default 60
	**/
	public var frameRate:Float = 60;
	/**
	   Tells whether texture animation should loop or not
	   @default true
	**/
	public var loopAnimation:Bool = true;
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
	/**
	   Index of the first frame
	   @default 0
	**/
	public var firstFrame:Int = 0;
	/**
	   Index of the last frame, -1 = last one
	   @default -1
	**/
	public var lastFrame:Int = -1;
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
	public var speed:Float = 100;
	/**
	   @default 0
	**/
	public var speedVariance:Float = 20;
	/**
	   @default false
	**/
	public var adjustLifeSpanToSpeed:Bool = false;
	/**
	   @default 0
	**/
	public var gravityX:Float = 0;
	/**
	   @default 0
	**/
	public var gravityY:Float = 0;
	/**
	   @default 0
	**/
	public var radialAcceleration:Float = 0;
	/**
	   @default 0
	**/
	public var radialAccelerationVariance:Float = 0;
	/**
	   @default 0
	**/
	public var tangentialAcceleration:Float = 0;
	/**
	   @default 0
	**/
	public var tangentialAccelerationVariance:Float = 0;
	/**
	   @default 0
	**/
	public var drag:Float = 0;
	/**
	   @default 0
	**/
	public var dragVariance:Float = 0;
	/**
	   @default 0
	**/
	public var repellentForce:Float = 0;
	//##################################################
	//\GRAVITY
	//##################################################
	
	//##################################################
	// RADIAL
	//##################################################
	/**
	   @default 300
	**/
	public var radiusMax:Float = 300;
	/**
	   @default 0
	**/
	public var radiusMaxVariance:Float = 0;
	/**
	   @default 0
	**/
	public var radiusMin:Float = 0;
	/**
	   @default 0
	**/
	public var radiusMinVariance:Float = 0;
	/**
	   @default 0
	**/
	public var rotatePerSecond:Float = 0;
	/**
	   @default 0
	**/
	public var rotatePerSecondVariance:Float = 0;
	//##################################################
	//\RADIAL
	//##################################################
	
	//##################################################
	// COLOR
	//##################################################
	/**
	   
	**/
	public var colorStart:ColorArgb = new ColorArgb(1, 1, 1, 1);
	/**
	   
	**/
	public var colorStartVariance:ColorArgb = new ColorArgb(0, 0, 0, 0);
	/**
	   
	**/
	public var colorEnd:ColorArgb = new ColorArgb(1, 1, 1, 1);
	/**
	   
	**/
	public var colorEndVariance:ColorArgb = new ColorArgb(0, 0, 0, 0);
	//##################################################
	//\COLOR
	//##################################################
	
	//##################################################
	// OSCILLATION
	//##################################################
	// Position
	/**
	   @default 0
	**/
	public var oscillationPositionAngle:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPositionAngleVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPositionRadius:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPositionRadiusVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var oscillationPositionFrequency:Float = 1.0;
	/**
	   @default 0
	**/
	public var oscillationPositionFrequencyVariance:Float = 0.0;
	
	// Position2
	/**
	   @default 0
	**/
	public var oscillationPosition2Angle:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPosition2AngleVariance:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPosition2Radius:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationPosition2RadiusVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var oscillationPosition2Frequency:Float = 1.0;
	/**
	   @default 0
	**/
	public var oscillationPosition2FrequencyVariance:Float = 0.0;
	
	// Rotation
	/**
	   @default 0
	**/
	public var oscillationRotationAngle:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationRotationAngleVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var oscillationRotationFrequency:Float = 1.0;
	/**
	   @default 0
	**/
	public var oscillationRotationFrequencyVariance:Float = 0.0;
	
	// Scale
	/**
	   @default 0
	**/
	public var oscillationScaleX:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationScaleXVariance:Float = 0.0;
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
	public var oscillationScaleXFrequency:Float = 1.0;
	/**
	   @default 0
	**/
	public var oscillationScaleXFrequencyVariance:Float = 0.0;
	/**
	   @default 1.0
	**/
	public var oscillationScaleYFrequency:Float = 1.0;
	/**
	   @default 0
	**/
	public var oscillationScaleYFrequencyVariance:Float = 0.0;
	
	// Color
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
	   @default 0
	**/
	public var oscillationColorFrequency:Float = 0.0;
	/**
	   @default 0
	**/
	public var oscillationColorFrequencyVariance:Float = 0.0;
	//##################################################
	//\OSCILLATION
	//##################################################
	
	/**
	   
	**/
	public var customFunction:Array<Particle>->Int->Void;
	/**
	   
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
		this.emissionRate = 10.0;
		this.emissionRatio = 1.0;
		
		this.emitterX = 0;
		this.emitterY = 0;
		this.emitterXVariance = 0;
		this.emitterYVariance = 0;
		
		this.emitterRadiusMax = 0;
		this.emitterRadiusMaxVariance = 0;
		this.emitterRadiusMin = 0;
		this.emitterRadiusMinVariance = 0;
		
		this.emitAngle = 0;
		this.emitAngleVariance = Math.PI;
		
		this.emitAngleAlignedRotation = false;
		
		this.duration = -1;
		
		this.useDisplayRect = false;
		this.displayRect.setEmpty();
		//\EMITTER
		
		// PARTICLE
		this.useAnimationLifeSpan = false;
		this.lifeSpan = 1;
		this.lifeSpanVariance = 0;
		
		this.fadeInTime = 0.0;
		this.fadeOutTime = 0.0;
		
		this.sizeXStart = 100;
		this.sizeXStartVariance = 0;
		this.sizeYStart = 100;
		this.sizeYStartVariance = 0;
		
		this.sizeXEnd = 100;
		this.sizeXEndVariance = 0;
		this.sizeYEnd = 100;
		this.sizeYEndVariance = 0;
		
		this.rotationStart = 0;
		this.rotationStartVariance = 0;
		this.rotationEnd = 0;
		this.rotationEndVariance = 0;
		//\PARTICLE
		
		// VELOCITY
		this.velocityXInheritRatio = 0;
		this.velocityXInheritRatioVariance = 0;
		this.velocityYInheritRatio = 0;
		this.velocityYInheritRatioVariance = 0;
		
		this.velocityScaleFactorX = 0.0;
		this.velocityScaleFactorY = 0.0;
		
		this.linkRotationToVelocity = false;
		this.velocityRotationOffset = 0.0;
		//\VELOCITY
		
		// ANIMATION
		this.textureAnimation = true;
		//this.animationLength = 1;
		this.frameRate = 60;
		this.firstFrame = 0;
		this.lastFrame = -1;
		this.loopAnimation = true;
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
		//\RADIAL
		
		// COLOR
		this.colorStart.red = this.colorStart.green = this.colorStart.blue = this.colorStart.alpha = 1.0;
		this.colorStartVariance.red = this.colorStartVariance.green = this.colorStartVariance.blue = this.colorStartVariance.alpha = 0.0;
		
		this.colorEnd.red = this.colorEnd.green = this.colorEnd.blue = this.colorEnd.alpha = 1.0;
		this.colorEndVariance.red = this.colorEndVariance.green = this.colorEndVariance.blue = this.colorEndVariance.alpha = 0.0;
		//\COLOR
		
		// OSCILLATION
		// position
		this.oscillationPositionAngle = 0.0;
		this.oscillationPositionAngleVariance = 0.0;
		this.oscillationPositionRadius = 0.0;
		this.oscillationPositionRadiusVariance = 0.0;
		this.oscillationPositionFrequency = 1.0;
		this.oscillationPositionFrequencyVariance = 0.0;
		
		// position2
		this.oscillationPosition2Angle = 0.0;
		this.oscillationPosition2AngleVariance = 0.0;
		this.oscillationPosition2Radius = 0.0;
		this.oscillationPosition2RadiusVariance = 0.0;
		this.oscillationPosition2Frequency = 1.0;
		this.oscillationPosition2FrequencyVariance = 0.0;
		
		// rotation
		this.oscillationRotationAngle = 0.0;
		this.oscillationRotationAngleVariance = 0.0;
		this.oscillationRotationFrequency = 1.0;
		this.oscillationRotationFrequencyVariance = 0.0;
		
		// scale
		this.oscillationScaleX = 0.0;
		this.oscillationScaleXVariance = 0.0;
		this.oscillationScaleY = 0.0;
		this.oscillationScaleYVariance = 0.0;
		this.oscillationScaleXFrequency = 1.0;
		this.oscillationScaleXFrequencyVariance = 0.0;
		this.oscillationScaleYFrequency = 1.0;
		this.oscillationScaleYFrequencyVariance = 0.0;
		
		// color
		this.oscillationColorRed = 0.0;
		this.oscillationColorGreen = 0.0;
		this.oscillationColorBlue = 0.0;
		this.oscillationColorAlpha = 0.0;
		this.oscillationColorRedVariance = 0.0;
		this.oscillationColorGreenVariance = 0.0;
		this.oscillationColorBlueVariance = 0.0;
		this.oscillationColorAlphaVariance = 0.0;
		this.oscillationColorFrequency = 0.0;
		this.oscillationColorFrequencyVariance = 0.0;
		//\OSCILLATION
		
		//this.premultipliedAlpha = true;
		
		//this.blendFuncSource = Context3DBlendFactor.ONE;
		//this.blendFuncDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
		
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
		
		target.emitAngle = this.emitAngle;
		target.emitAngleVariance = this.emitAngleVariance;
		target.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
		
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
		
		target.rotationStart = this.rotationStart;
		target.rotationStartVariance = this.rotationStartVariance;
		target.rotationEnd = this.rotationEnd;
		target.rotationEndVariance = this.rotationEndVariance;
		//\PARTICLE
		
		// VELOCITY
		target.velocityXInheritRatio = this.velocityXInheritRatio;
		target.velocityXInheritRatioVariance = this.velocityXInheritRatioVariance;
		target.velocityYInheritRatio = this.velocityYInheritRatio;
		target.velocityYInheritRatioVariance = this.velocityYInheritRatioVariance;
		
		target.velocityScaleFactorX = this.velocityScaleFactorX;
		target.velocityScaleFactorY = this.velocityScaleFactorY;
		
		target.linkRotationToVelocity = this.linkRotationToVelocity;
		target.velocityRotationOffset = this.velocityRotationOffset;
		//\VELOCITY
		
		// ANIMATION
		target.textureAnimation = this.textureAnimation;
		target.frameRate = this.frameRate;
		target.firstFrame = this.firstFrame;
		target.lastFrame = this.lastFrame;
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
		//\RADIAL
		
		// COLOR
		target.colorStart.copyFrom(this.colorStart);
		target.colorStartVariance.copyFrom(this.colorStartVariance);
		
		target.colorEnd.copyFrom(this.colorEnd);
		target.colorEndVariance.copyFrom(this.colorEndVariance);
		//\COLOR
		
		// OSCILLATION
		target.oscillationPositionAngle = this.oscillationPositionAngle;
		target.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
		target.oscillationPositionRadius = this.oscillationPositionRadius;
		target.oscillationPositionRadiusVariance = this.oscillationPositionRadiusVariance;
		target.oscillationPositionFrequency = this.oscillationPositionFrequency;
		target.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
		
		target.oscillationPosition2Angle = this.oscillationPosition2Angle;
		target.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
		target.oscillationPosition2Radius = this.oscillationPosition2Radius;
		target.oscillationPosition2RadiusVariance = this.oscillationPosition2RadiusVariance;
		target.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
		target.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
		
		target.oscillationRotationAngle = this.oscillationRotationAngle;
		target.oscillationRotationAngleVariance = this.oscillationRotationAngleVariance;
		target.oscillationRotationFrequency = this.oscillationRotationFrequency;
		target.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
		
		target.oscillationScaleX = this.oscillationScaleX;
		target.oscillationScaleXVariance = this.oscillationScaleXVariance;
		target.oscillationScaleY = this.oscillationScaleY;
		target.oscillationScaleYVariance = this.oscillationScaleYVariance;
		target.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
		target.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
		target.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
		target.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
		
		target.oscillationColorRed = this.oscillationColorRed;
		target.oscillationColorGreen = this.oscillationColorGreen;
		target.oscillationColorBlue = this.oscillationColorBlue;
		target.oscillationColorAlpha = this.oscillationColorAlpha;
		target.oscillationColorRedVariance = this.oscillationColorRedVariance;
		target.oscillationColorGreenVariance = this.oscillationColorGreenVariance;
		target.oscillationColorBlueVariance = this.oscillationColorBlueVariance;
		target.oscillationColorAlphaVariance = this.oscillationColorAlphaVariance;
		target.oscillationColorFrequency = this.oscillationColorFrequency;
		target.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
		//\OSCILLATION
		
		//target.premultipliedAlpha = this.premultipliedAlpha;
		
		//target.blendFuncSource = this.blendFuncSource;
		//target.blendFuncDestination = this.blendFuncDestination;
		
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
		
		this.emitAngle = json.emitAngle;
		this.emitAngleVariance = json.emitAngleVariance;
		this.emitAngleAlignedRotation = json.emitAngleAlignedRotation;
		
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
		
		this.rotationStart = json.rotationStart;
		this.rotationStartVariance = json.rotationStartVariance;
		this.rotationEnd = json.rotationEnd;
		this.rotationEndVariance = json.rotationEndVariance;
		//\PARTICLE
		
		// VELOCITY
		this.velocityXInheritRatio = json.velocityXInheritRatio;
		this.velocityXInheritRatioVariance = json.velocityXInheritRatioVariance;
		this.velocityYInheritRatio = json.velocityYInheritRatio;
		this.velocityYInheritRatioVariance = json.velocityYInheritRatioVariance;
		
		this.velocityScaleFactorX = json.velocityScaleFactorX;
		this.velocityScaleFactorY = json.velocityScaleFactorY;
		
		this.linkRotationToVelocity = json.linkRotationToVelocity;
		this.velocityRotationOffset = json.velocityRotationOffset;
		//\VELOCITY
		
		// ANIMATION
		this.textureAnimation = json.textureAnimation;
		this.frameRate = json.frameRate;
		this.firstFrame = json.firstFrame;
		this.lastFrame = json.lastFrame;
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
		//\RADIAL
		
		// COLOR
		colorFromJSON(this.colorStart, json.colorStart);
		colorFromJSON(this.colorStartVariance, json.colorStartVariance);
		colorFromJSON(this.colorEnd, json.colorEnd);
		colorFromJSON(this.colorEndVariance, json.colorEndVariance);
		//\COLOR
		
		// OSCILLATION
		this.oscillationPositionAngle = json.oscillationPositionAngle;
		this.oscillationPositionAngleVariance = json.oscillationPositionAngleVariance;
		this.oscillationPositionRadius = json.oscillationPositionRadius;
		this.oscillationPositionRadiusVariance = json.oscillationPositionRadiusVariance;
		this.oscillationPositionFrequency = json.oscillationPositionFrequency;
		this.oscillationPositionFrequencyVariance = json.oscillationPositionFrequencyVariance;
		
		this.oscillationPosition2Angle = json.oscillationPosition2Angle;
		this.oscillationPosition2AngleVariance = json.oscillationPosition2AngleVariance;
		this.oscillationPosition2Radius = json.oscillationPosition2Radius;
		this.oscillationPosition2RadiusVariance = json.oscillationPosition2RadiusVariance;
		this.oscillationPosition2Frequency = json.oscillationPosition2Frequency;
		this.oscillationPosition2FrequencyVariance = json.oscillationPosition2FrequencyVariance;
		
		this.oscillationRotationAngle = json.oscillationRotationAngle;
		this.oscillationRotationAngleVariance = json.oscillationRotationAngleVariance;
		this.oscillationRotationFrequency = json.oscillationRotationFrequency;
		this.oscillationRotationFrequencyVariance = json.oscillationRotationFrequencyVariance;
		
		this.oscillationScaleX = json.oscillationScaleX;
		this.oscillationScaleXVariance = json.oscillationScaleXVariance;
		this.oscillationScaleY = json.oscillationScaleY;
		this.oscillationScaleYVariance = json.oscillationScaleYVariance;
		this.oscillationScaleXFrequency = json.oscillationScaleXFrequency;
		this.oscillationScaleXFrequencyVariance = json.oscillationScaleXFrequencyVariance;
		this.oscillationScaleYFrequency = json.oscillationScaleYFrequency;
		this.oscillationScaleYFrequencyVariance = json.oscillationScaleYFrequencyVariance;
		
		this.oscillationColorRed = json.oscillationColorRed;
		this.oscillationColorGreen = json.oscillationColorGreen;
		this.oscillationColorBlue = json.oscillationColorBlue;
		this.oscillationColorAlpha = json.oscillationColorAlpha;
		this.oscillationColorRedVariance = json.oscillationColorRedVariance;
		this.oscillationColorGreenVariance = json.oscillationColorGreenVariance;
		this.oscillationColorBlueVariance = json.oscillationColorBlueVariance;
		this.oscillationColorAlphaVariance = json.oscillationColorAlphaVariance;
		this.oscillationColorFrequency = json.oscillationColorFrequency;
		this.oscillationColorFrequencyVariance = json.oscillationColorFrequencyVariance;
		//\OSCILLATION
		
		//this.blendFuncSource = json.blendFuncSource;
		//this.blendFuncDestination = json.blendFuncDestination;
		
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
		
		json.emitAngle = this.emitAngle;
		json.emitAngleVariance = this.emitAngleVariance;
		json.emitAngleAlignedRotation = this.emitAngleAlignedRotation;
		
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
		
		json.rotationStart = this.rotationStart;
		json.rotationStartVariance = this.rotationStartVariance;
		json.rotationEnd = this.rotationEnd;
		json.rotationEndVariance = this.rotationEndVariance;
		//\PARTICLE
		
		// VELOCITY
		json.velocityXInheritRatio = this.velocityXInheritRatio;
		json.velocityXInheritRatioVariance = this.velocityXInheritRatioVariance;
		json.velocityYInheritRatio = this.velocityYInheritRatio;
		json.velocityYInheritRatioVariance = this.velocityYInheritRatioVariance;
		
		json.velocityScaleFactorX = this.velocityScaleFactorX;
		json.velocityScaleFactorY = this.velocityScaleFactorY;
		
		json.linkRotationToVelocity = this.linkRotationToVelocity;
		json.velocityRotationOffset = this.velocityRotationOffset;
		//\VELOCITY
		
		// ANIMATION
		json.textureAnimation = this.textureAnimation;
		json.frameRate = this.frameRate;
		json.firstFrame = this.firstFrame;
		json.lastFrame = this.lastFrame;
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
		//\RADIAL
		
		// COLOR
		json.colorStart = colorToJSON(this.colorStart);
		json.colorStartVariance = colorToJSON(this.colorStartVariance);
		
		json.colorEnd = colorToJSON(this.colorEnd);
		json.colorEndVariance = colorToJSON(this.colorEndVariance);
		//\COLOR
		
		// OSCILLATION
		json.oscillationPositionAngle = this.oscillationPositionAngle;
		json.oscillationPositionAngleVariance = this.oscillationPositionAngleVariance;
		json.oscillationPositionRadius = this.oscillationPositionRadius;
		json.oscillationPositionRadiusVariance = this.oscillationPositionRadiusVariance;
		json.oscillationPositionFrequency = this.oscillationPositionFrequency;
		json.oscillationPositionFrequencyVariance = this.oscillationPositionFrequencyVariance;
		
		json.oscillationPosition2Angle = this.oscillationPosition2Angle;
		json.oscillationPosition2AngleVariance = this.oscillationPosition2AngleVariance;
		json.oscillationPosition2Radius = this.oscillationPosition2Radius;
		json.oscillationPosition2RadiusVariance = this.oscillationPosition2RadiusVariance;
		json.oscillationPosition2Frequency = this.oscillationPosition2Frequency;
		json.oscillationPosition2FrequencyVariance = this.oscillationPosition2FrequencyVariance;
		
		json.oscillationRotationAngle = this.oscillationRotationAngle;
		json.oscillationRotationAngleVariance = this.oscillationRotationAngleVariance;
		json.oscillationRotationFrequency = this.oscillationRotationFrequency;
		json.oscillationRotationFrequencyVariance = this.oscillationRotationFrequencyVariance;
		
		json.oscillationScaleX = this.oscillationScaleX;
		json.oscillationScaleXVariance = this.oscillationScaleXVariance;
		json.oscillationScaleY = this.oscillationScaleY;
		json.oscillationScaleYVariance = this.oscillationScaleYVariance;
		json.oscillationScaleXFrequency = this.oscillationScaleXFrequency;
		json.oscillationScaleXFrequencyVariance = this.oscillationScaleXFrequencyVariance;
		json.oscillationScaleYFrequency = this.oscillationScaleYFrequency;
		json.oscillationScaleYFrequencyVariance = this.oscillationScaleYFrequencyVariance;
		
		json.oscillationColorRed = this.oscillationColorRed;
		json.oscillationColorGreen = this.oscillationColorGreen;
		json.oscillationColorBlue = this.oscillationColorBlue;
		json.oscillationColorAlpha = this.oscillationColorAlpha;
		json.oscillationColorRedVariance = this.oscillationColorRedVariance;
		json.oscillationColorGreenVariance = this.oscillationColorGreenVariance;
		json.oscillationColorBlueVariance = this.oscillationColorBlueVariance;
		json.oscillationColorAlphaVariance = this.oscillationColorAlphaVariance;
		json.oscillationColorFrequency = this.oscillationColorFrequency;
		json.oscillationColorFrequencyVariance = this.oscillationColorFrequencyVariance;
		//\OSCILLATION
		
		//json.blendFuncSource = this.blendFuncSource;
		//json.blendFuncDestination = this.blendFuncDestination;
		
		json.exactBounds = this.exactBounds;
		
		json.forceSortFlag = this.forceSortFlag;
		
		return json;
	}
	
	static public function colorFromJSON(color:ColorArgb, json:Dynamic):Void
	{
		color.red = json.red;
		color.green = json.green;
		color.blue = json.blue;
		color.alpha = json.alpha;
	}
	
	static public function colorToJSON(color:ColorArgb, json:Dynamic = null):Dynamic
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
			//if (anim.hasNode.firstFrame)
			//{
				//target.firstFrameName = anim.node.firstFrame.att.value;
				//if (target.firstFrameName == "")
				//{
					//target.firstFrame = getIntValue(anim.node.firstFrame.att.value);
				//}
			//}
			//if (anim.hasNode.lastFrame)
			//{
				//target.lastFrameName = anim.node.lastFrame.att.value;
				//if (target.lastFrameName == "")
				//{
					//target.lastFrame = getIntValue(anim.node.lastFrame.att.value);
				//}
			//}
			//if (anim.hasNode.numberOfAnimatedFrames)
			//{
				//target.animationLength = getIntValue(anim.node.numberOfAnimatedFrames.att.value);
				//target.lastFrame = target.firstFrame + target.animationLength;
			//}
			if (anim.hasNode.loops)
			{
				this.animationLoops = Std.parseInt(anim.node.loops.att.value);
			}
			if (anim.hasNode.randomStartFrames)
			{
				this.randomStartFrame = getBoolValue(anim.node.randomStartFrames.att.value);
			}
		}
		
		//if (xml.hasNode.tinted)
		//{
			//target.tinted = getBoolValue(xml.node.tinted.att.value);
		//}
		//if (xml.hasNode.premultipliedAlpha)
		//{
			//target.premultipliedAlpha = getBoolValue(xml.node.premultipliedAlpha.att.value);
		//}
		//if (xml.hasNode.spawnTime)
		//{
			//target.spawnTime = Std.parseFloat(xml.node.spawnTime.att.value);
		//}
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
	
	private static function getColor(element:Access, color:ColorArgb = null):ColorArgb
	{
		if (color == null) color = new ColorArgb();
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