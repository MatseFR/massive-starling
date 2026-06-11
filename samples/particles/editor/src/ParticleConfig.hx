package;
import massive.animation.Animation;
import massive.data.Frame;
import massive.display.color.ColorOffsetMode;
import massive.particle.ParticleAnimation;
import massive.particle.ParticleFrame;
import massive.particle.ParticleSystemOptions;
import starling.display.BlendMode;
import starling.textures.Texture;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class ParticleConfig 
{
	public var blendMode:String = BlendMode.NORMAL;
	public var colorOffsetMode:String = ColorOffsetMode.NONE;
	#if flash
	public var animations(default, null):Vector<ParticleAnimation> = new Vector<ParticleAnimation>();
	public var frames(default, null):Vector<ParticleFrame> = new Vector<ParticleFrame>();
	#else
	public var animations(default, null):Array<ParticleAnimation> = new Array<ParticleAnimation>();
	public var frames(default, null):Array<ParticleFrame> = new Array<ParticleFrame>();
	#end
	public var hasAnimation(get, never):Bool;
	public var hasFrame(get, never):Bool;
	public var options:ParticleSystemOptions;
	public var texture:Texture;
	
	private function get_hasAnimation():Bool { return this.animations.length != 0; }
	private function get_hasFrame():Bool { return this.frames.length != 0; }

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		for (i in 0...this.animations.length)
		{
			this.animations[i].pool();
		}
		for (i in 0...this.frames.length)
		{
			this.frames[i].pool();
		}
		#if flash
		this.animations.length = 0;
		this.frames.length = 0;
		#else
		this.animations.resize(0);
		this.frames.resize(0);
		#end
		
		this.blendMode = BlendMode.NORMAL;
		this.colorOffsetMode = ColorOffsetMode.NONE;
		if (this.options != null)
		{
			this.options.pool();
			this.options = null;
		}
		this.texture = null;
	}
	
	public function addAnimation(animation:Animation, weight:Float = 1.0, textureIndex:Int = 0):Void
	{
		this.animations[this.animations.length] = ParticleAnimation.fromPool(animation, weight, textureIndex);
	}
	
	public function addFrame(frame:Frame, weight:Float = 1.0, textureIndex:Int = 0):Void
	{
		this.frames[this.frames.length] = ParticleFrame.fromPool(frame, weight, textureIndex);
	}
	
}