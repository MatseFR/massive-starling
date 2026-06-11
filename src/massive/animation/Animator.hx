package massive.animation;
import massive.display.Clip;
import massive.display.base.DisplayBase;
import massive.display.DisplayContainer;
import massive.data.Frame;
#if flash
import openfl.Vector;
#end

/**
 * Animates textures and generates timings
 * @author Matse
 */
class Animator 
{
	static private var _clip:Clip;
	
	/**
	   Animates textures of the specified ImageData list
	   @param	datas
	   @param	time
	**/
	@:access(massive.display.DisplayContainer)
	#if flash
	static public function animateDataList(datas:Vector<DisplayBase>, time:Float):Void
	#else
	static public function animateDataList(datas:Array<DisplayBase>, time:Float):Void
	#end
	{
		var count:Int = datas.length;
		var data:DisplayBase;
		var container:DisplayContainer;
		for (i in 0...count)
		{
			data = datas[i];
			if (!data.animate) continue;
			if (data.isContainer)
			{
				container = cast data;
				animateDataList(container._datas, time);
			}
			else
			{
				_clip = cast data;
				_clip.advanceTime(time);
			}
		}
		
	}
	
	#if flash
	static public function createAnimation(frames:Vector<Frame>, frameRate:Float = 60):Animation
	#else
	static public function createAnimation(frames:Array<Frame>, frameRate:Float = 60):Animation
	#end
	{
		var anim:Animation = Animation.fromPool();
		var timeStep:Float = 1.0 / frameRate;
		var frameTime:Float = 0.0;
		var count:Int = frames.length;
		
		for (i in 0...count)
		{
			frameTime += timeStep;
			anim.addFrame(AnimationFrame.fromPool(frames[i], frameTime));
		}
		anim.ready();
		return anim;
	}
	
	/**
	   Generates timings for the specified frameList, with the specified frameRate
	   @param	frames
	   @param	frameRate
	   @param	timings
	   @return
	**/
	static public function generateTimings(frames:#if flash Vector<Frame> #else Array<Frame> #end, frameRate:Float = 60, timings:#if SWC Vector<Float> #else Array<Float>#end = null):#if SWC Vector<Float> #else Array<Float>#end
	{
		if (timings == null) timings = new #if SWC Vector<Float> #else Array<Float>#end();
		
		var frameTime:Float = 1.0 / frameRate;
		var total:Float = 0;
		var count:Int = frames.length;
		
		for (i in 0...count)
		{
			total += frameTime;
			timings[i] = total;
		}
		
		return timings;
	}
	
}