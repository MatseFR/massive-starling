package data;

/**
 * ...
 * @author Matse
 */
class ImageData extends DisplayData
{
	static private var _POOL:Array<ImageData> = new Array<ImageData>();
	
	/* inverts display on horizontal axis */
	public var invertX:Bool = false;
	/* inverts display on vertical axis */
	public var invertY:Bool = false;
	
	public var frameTime:Float;
	public var frameTimings:Array<Float>;
	public var frameCount:Int;
	//public var frameDelta:Float;
	public var frameList:Array<Frame>;
	public var frameEventList:Array<String>;
	public var frameIndex:Int = 0;
	
	public var animate:Bool = false;
	public var loop:Bool = true;
	public var hasEvents:Bool = false;
	
	public function new() 
	{
		super();
	}
	
	public function setFrames(frames:Array<Frame>, timings:Array<Float>, frameIndex:Int = 0, animate:Bool = true, loop:Bool = true, hasEvents:Bool = false, frameEvents:Array<String> = null):Void
	{
		this.frameList = frames;
		this.frameTimings = timings;
		this.frameCount = this.frameTimings.length - 1;
		this.frameIndex = frameIndex;
		this.animate = animate;
		this.loop = loop;
		this.hasEvents = hasEvents;
		this.frameEventList = frameEvents;
		
		if (this.animate)
		{
			if (this.frameIndex == 0)
			{
				this.frameTime = 0;
			}
			else
			{
				this.frameTime = this.frameTimings[this.frameIndex - 1];
			}
		}
	}
	
}