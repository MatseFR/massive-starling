package scene.massive;
import massive.animation.Animation;
import massive.display.Clip;

/**
 * @author Matse
 */
interface IMassiveClip extends IMassiveImg
{
	public var frameDelta:Float;
	
	public function play(animation:Animation, frameIndex:Int = 0, numLoops:Int = -1, animationCompleteCallback:Clip->Void = null):Void;
}