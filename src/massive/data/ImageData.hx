package massive.data;
import openfl.Vector;

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
	
	/* tells whether the ImageData is animated (if it has frames) or not */
	public var animate:Bool = false;
	/* how many frames */
	public var frameCount:Int;
	public var frameCurrent(get, never):Frame;
	/* playback speed */
	public var frameDelta:Float = 1;
	/* index of the current frame */
	public var frameIndex:Int = 0;
	/* lists all frames */
	public var frameList:#if flash Vector<Frame> #else Array<Frame> #end;
	/* time elapsed on current frame */
	public var frameTime:Float;
	/* duration of each frame */
	public var frameTimings:Array<Float>;
	public var height(get, set):Float;
	/* inverts display on horizontal axis */
	public var invertX:Bool = false;
	/* inverts display on vertical axis */
	public var invertY:Bool = false;
	/* tells whether to loop frames */
	public var loop:Bool = true;
	/* tells how many loops have been done */
	public var loopCount:Int = 0;
	/* how many loops, 0 == infinite */
	public var numLoops:Int = 0;
	public var width(get, set):Float;
	
	private function get_frameCurrent():Frame { return this.frameList[this.frameIndex]; }
	
	private function get_height():Float { return this.frameList[this.frameIndex].height * this.scaleY; }
	private function set_height(value:Float):Float
	{
		this.scaleY = value / this.frameList[this.frameIndex].height;
		return value;
	}
	
	private function get_width():Float { return this.frameList[this.frameIndex].width * this.scaleX; }
	private function set_width(value:Float):Float
	{
		this.scaleX = value / this.frameList[this.frameIndex].width;
		return value;
	}
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void
	{
		this.invertX = this.invertY = this.animate = false;
		this.frameDelta = 1;
		this.frameTime = 0;
		this.loop = true;
		this.loopCount = this.numLoops = 0;
		
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
	}
	
	public function setFrames(frames:#if flash Vector<Frame> #else Array<Frame> #end, timings:Array<Float> = null, loop:Bool = true, numLoops:Int = 0, frameIndex:Int = 0, animate:Bool = true):Void
	{
		this.frameList = frames;
		this.frameTimings = timings;
		this.frameCount = this.frameTimings == null ? this.frameList != null ? this.frameList.length - 1 : 0 : this.frameTimings.length - 1;
		this.loop = loop;
		this.numLoops = numLoops;
		this.frameIndex = frameIndex;
		this.animate = animate;
		
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
	
	public function setFrameTimings(timings:Array<Float>):Void
	{
		this.frameTimings = timings;
		this.frameCount = this.frameTimings == null ? this.frameList.length - 1 : this.frameTimings.length - 1;
	}
	
}