package;
import massive.animation.Animator;
import massive.data.Frame;
import massive.particle.ParticleSystemOptions;
#if flash
import openfl.Vector;
#end
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class ParticleConfig 
{
	public var blendMode:String;
	#if flash
	public var frames(default, null):Vector<Vector<Frame>> = new Vector<Vector<Frame>>();
	#else
	public var frames(default, null):Array<Array<Frame>> = new Array<Array<Frame>>();
	#end
	public var frameTimings(default, null):Array<Array<Float>> = new Array<Array<Float>>();
	public var options:ParticleSystemOptions;
	public var texture:Texture;

	public function new() 
	{
		
	}
	
	public function addFrames(frames:#if flash Vector<Frame>#else Array<Frame>#end, timings:Array<Float> = null):Void
	{
		if (timings == null) timings = Animator.generateTimings(frames);
		this.frames[this.frames.length] = frames;
		this.frameTimings[this.frameTimings.length] = timings;
	}
	
}