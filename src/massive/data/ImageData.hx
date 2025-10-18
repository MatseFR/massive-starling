package massive.data;

/**
 * ...
 * @author Matse
 */
class ImageData extends DisplayData
{
	static private var _POOL:Array<ImageData> = new Array<ImageData>();
	
	static public function fromPool():ImageData
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ImageData();
	}
	
	static public function fromPoolArray(numImages:Int, imgList:Array<ImageData> = null):Array<ImageData>
	{
		if (imgList == null) imgList = new Array<ImageData>();
		
		while (numImages != 0)
		{
			if (_POOL.length == 0) break;
			imgList[imgList.length] = _POOL.pop();
			numImages--;
		}
		
		while (numImages != 0)
		{
			imgList[imgList.length] = new ImageData();
			numImages--;
		}
		
		return imgList;
	}
	
	static public function toPool(img:ImageData):Void
	{
		img.clear();
		_POOL[_POOL.length] = img;
	}
	
	static public function toPoolArray(imgList:Array<ImageData>):Void
	{
		for (img in imgList)
		{
			img.pool();
		}
	}
	
	/* inverts display on horizontal axis */
	public var invertX:Bool = false;
	/* inverts display on vertical axis */
	public var invertY:Bool = false;
	
	/* time elapsed on current frame */
	public var frameTime:Float;
	/* duration of each frame */
	public var frameTimings:Array<Float>;
	/* how many frames */
	public var frameCount:Int;
	/* playback speed */
	public var frameDelta:Float = 1;
	/* lists all frames */
	public var frameList:Array<Frame>;
	public var frameEventList:Array<String>;
	/* index of the current frame */
	public var frameIndex:Int = 0;
	
	/* tells whether the ImageData is animated (if it has frames) or not */
	public var animate:Bool = false;
	/* tells whether to loop frames */
	public var loop:Bool = true;
	public var hasEvents:Bool = false;
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void
	{
		this.invertX = this.invertY = this.animate = this.hasEvents = false;
		this.frameDelta = 1;
		this.loop = true;
		
		clearFrames();
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
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