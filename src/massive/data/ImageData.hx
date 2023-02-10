package massive.data;

/**
 * ...
 * @author Matse
 */
class ImageData extends DisplayData
{
	private static var POOL:Array<ImageData> = new Array<ImageData>();
	
	public static function fromPool():ImageData
	{
		if (POOL.length != 0) return POOL.pop();
		return new ImageData();
	}
	
	public static function fromPoolArray(numImages:Int, imgList:Array<ImageData> = null):Array<ImageData>
	{
		if (imgList == null) imgList = new Array<ImageData>();
		
		while (numImages != 0)
		{
			if (POOL.length == 0) break;
			imgList.push(POOL.pop());
			numImages--;
		}
		
		while (numImages != 0)
		{
			imgList.push(new ImageData());
			numImages--;
		}
		
		return imgList;
	}
	
	public static function toPool(img:ImageData):Void
	{
		img.clear();
		POOL.push(img);
	}
	
	public static function toPoolArray(imgList:Array<ImageData>):Void
	{
		for (img in imgList)
		{
			img.clear();
			POOL.push(img);
		}
	}
	
	/* inverts display on horizontal axis */
	public var invertX:Bool = false;
	/* inverts display on vertical axis */
	public var invertY:Bool = false;
	
	public var frameTime:Float;
	public var frameTimings:Array<Float>;
	public var frameCount:Int;
	public var frameDelta:Float = 1;
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
	
	public function clear():Void
	{
		this.invertX = false;
		this.invertY = false;
		this.frameDelta = 1;
		this.animate = false;
		this.loop = true;
		this.hasEvents = false;
		clearFrames();
	}
	
	public function clearFrames():Void
	{
		this.frameList = null;
		this.frameTimings = null;
		this.frameCount = 0;
		this.frameEventList = null;
	}
	
	public function setFrames(frames:Array<Frame>, frameIndex:Int = 0, animate:Bool = false, timings:Array<Float> = null, loop:Bool = true, hasEvents:Bool = false, frameEvents:Array<String> = null):Void
	{
		this.frameList = frames;
		this.frameTimings = timings;
		this.frameCount = this.frameTimings == null ? this.frameList.length - 1 : this.frameTimings.length - 1;
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