package massive.data;
#if flash
import openfl.Vector;
#end

/**
 * Image display object with optionnal texture animation
 * @author Matse
 */
class ImageData extends DisplayData
{
	static private var _POOL:Array<ImageData> = new Array<ImageData>();
	
	/**
	   Returns an ImageData from pool if there's at least one in pool, or a new one otherwise
	   @return
	**/
	static public function fromPool():ImageData
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ImageData();
	}
	
	/**
	   Returns an Array of ImageData, taken from pool if possible and created otherwise
	   @param	numImages
	   @param	imgList
	   @return
	**/
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
	
	#if flash
	/**
	   Returns a Vector of ImageData, taken from pool if possible and created otherwise
	   @param	numImages
	   @param	imgList
	   @return
	**/
	static public function fromPoolVector(numImages:Int, imgList:Vector<ImageData> = null):Vector<ImageData>
	{
		if (imgList == null) imgList = new Vector<ImageData>();
		
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
	#end
	
	/**
	   Equivalent to calling ImageData's pool function
	   @param	img
	**/
	static public function toPool(img:ImageData):Void
	{
		img.clear();
		_POOL[_POOL.length] = img;
	}
	
	/**
	   Pools all ImageData objects in the specified Array
	   @param	imgList
	**/
	static public function toPoolArray(imgList:Array<ImageData>):Void
	{
		for (img in imgList)
		{
			img.clear();
			_POOL[_POOL.length] = img;
		}
	}
	
	#if flash
	/**
	   Pools all ImageData objects in the specified Vector
	   @param	imgList
	**/
	static public function toPoolVector(imgList:Vector<ImageData>):Void
	{
		for (img in imgList)
		{
			img.pool();
		}
	}
	#end
	
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
	
	/**
	   @inheritDoc
	**/
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
	
	/**
	   @inheritDoc
	**/
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	/**
	   Clears all stored Frame objects and associated timings
	**/
	public function clearFrames():Void
	{
		this.frameList = null;
		this.frameTimings = null;
		this.frameCount = 0;
	}
	
	/**
	   Sets the current animation properties : Frame objects, associated timings + playing options
	   @param	frames
	   @param	timings
	   @param	loop
	   @param	numLoops
	   @param	frameIndex
	   @param	animate
	**/
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
			if (this.frameCount == 0)
			{
				this.animate = false;
			}
			else
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
	
	/**
	   Set the timings associated to the current Frame objects
	   @param	timings
	**/
	public function setFrameTimings(timings:Array<Float>):Void
	{
		this.frameTimings = timings;
		this.frameCount = this.frameTimings == null ? this.frameList != null ? this.frameList.length - 1 : 0 : this.frameTimings.length - 1;
	}
	
}