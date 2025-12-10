package massive.animation;
import massive.data.Frame;
import massive.data.ImageData;
#if flash
import openfl.Vector;
#end

/**
 * Animates textures and generates timings
 * @author Matse
 */
class Animator 
{
	/**
	   Animates textures of the specified ImageData list
	   @param datas
	   @param time
	**/
	@:generic
	static public inline function animateImageDataList<T:ImageData>(datas:#if flash Vector<T> #else Array<T>#end, time:Float):Void
	{
		var count:Int = datas.length;
		var data:T;
		for (i in 0...count)
		{
			data = datas[i];
			if (!data.animate) continue;
			
			data.frameTime += time * data.frameDelta;
			if (data.frameTime >= data.frameTimings[data.frameIndex])
			{
				if (data.frameIndex < data.frameCount)
				{
					data.frameIndex++;
				}
				else if (data.loop && (data.numLoops == 0 || data.loopCount < data.numLoops))
				{
					data.frameTime -= data.frameTimings[data.frameIndex];
					data.frameIndex = 0;
					data.loopCount++;
				}
			}
		}
		
	}
	
	/**
	   Generates timings for the specified frameList, with the specified frameRate
	   @param	frameList
	   @param	frameRate
	   @param	timings
	   @return
	**/
	static public function generateTimings(frameList:#if flash Vector<Frame> #else Array<Frame> #end, frameRate:Float = 60, timings:Array<Float> = null):Array<Float>
	{
		if (timings == null) timings = new Array<Float>();
		
		var frameTime:Float = 1.0 / frameRate;
		var total:Float = 0;
		var count:Int = frameList.length;
		
		for (i in 0...count)
		{
			total += frameTime;
			timings[i] = total;
		}
		
		return timings;
	}
	
}