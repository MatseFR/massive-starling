package massive.animation;
import massive.data.Frame;
import massive.data.ImageData;
import massive.display.MassiveImageLayer;

/**
 * ...
 * @author Matse
 */
class Animator 
{

	static public inline function animateImageDataList(datas:Array<ImageData>, time:Float, layer:MassiveImageLayer):Void
	{	
		for (data in datas)
		{
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
	
	static public function generateTimings(frameList:Array<Frame>, frameRate:Float = 60, timings:Array<Float> = null):Array<Float>
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