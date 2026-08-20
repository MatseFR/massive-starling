package scene;

import massive.animation.Animation;
import massive.animation.Animator;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;
import massive.util.AnimUtils;
import openfl.Vector;
import scene.massive.IMassiveClip;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
abstract class MassiveClipsBase extends MassiveSceneBase
{
	public var clipType:String;
	public var frameDeltaBase:Float = 0.1;
	public var frameDeltaVariance:Float = 0.5;
	
	override function set_animation(value:Bool):Bool 
	{
		if (this._animator != null)
		{
			this._animator.animate = value;
		}
		return super.set_animation(value);
	}
	
	private var _animations:Array<Animation> = new Array<Animation>();
	private var _animator:Animator = new Animator();
	
	public function new() 
	{
		super();
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this._animator);
		this._animator.clear();
		
		var count:Int = this._animations.length;
		for (i in 0...count)
		{
			this._animations[i].pool(true, false, false);
		}
		
		super.dispose();
	}
	
	private function init():Void
	{
		var animation:Animation;
		
		for (i in 0...this._numTextures)
		{
			animation = AnimUtils.createVertexAnimation(this._frames[i], 60,
														this.vertexPositionAnimation ? this._animationPositions[i] : null,
														this.vertexColorAnimation ? this._animationColors : null,
														this.vertexColorOffsetAnimation ? this._animationColorOffsets : null);
			animation.loop = true;
			this._animations[this._animations.length] = animation;
		}
		
		Starling.currentJuggler.add(this._animator);
		this._animator.animate = this._animation;
	}
	
	private function initClip(clip:IMassiveClip):Int
	{
		var variant:Int = super.initImg(clip, false);
		
		clip.frameDelta = this.frameDeltaBase + clip.speedVariance * this.frameDeltaVariance;
		clip.play(this._animations[variant], Std.random(this._animations[variant].numFrames));
		
		return variant;
	}
	
}