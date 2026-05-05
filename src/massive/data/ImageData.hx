package massive.data;

#if flash
import openfl.Vector;
#end

/**
 * Image display object with optionnal texture animation
 * @author Matse
 */
@:allow(massive.animation.Animator)
@:allow(massive.display.ImageLayer)
class ImageData extends DisplayData
{
	static public var TEXTURE_INDEX_MULTIPLIER:Float;
	
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
	   @param	images
	   @return
	**/
	static public function fromPoolArray(numImages:Int, images:Array<ImageData> = null):Array<ImageData>
	{
		if (images == null) images = new Array<ImageData>();
		
		while (numImages != 0)
		{
			if (_POOL.length == 0) break;
			images[images.length] = _POOL.pop();
			numImages--;
		}
		
		while (numImages != 0)
		{
			images[images.length] = new ImageData();
			numImages--;
		}
		
		return images;
	}
	
	#if flash
	/**
	   Returns a Vector of ImageData, taken from pool if possible and created otherwise
	   @param	numImages
	   @param	images
	   @return
	**/
	static public function fromPoolVector(numImages:Int, images:Vector<ImageData> = null):Vector<ImageData>
	{
		if (images == null) images = new Vector<ImageData>();
		
		while (numImages != 0)
		{
			if (_POOL.length == 0) break;
			images[images.length] = _POOL.pop();
			numImages--;
		}
		
		while (numImages != 0)
		{
			images[images.length] = new ImageData();
			numImages--;
		}
		
		return images;
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
	   @param	images
	**/
	static public function toPoolArray(images:Array<ImageData>):Void
	{
		var count:Int = images.length;
		for (i in 0...count)
		{
			images[i].pool();
		}
	}
	
	#if flash
	/**
	   Pools all ImageData objects in the specified Vector
	   @param	images
	**/
	static public function toPoolVector(images:Vector<ImageData>):Void
	{
		var count:Int = images.length;
		for (i in 0...count)
		{
			images[i].pool();
		}
	}
	#end
	
	/**
	   Tells whether the ImageData is animated (if it has frames) or not
	   @default	false
	**/
	public var animate:Bool = false;
	/**
	   How many frames
	   @default	0
	**/
	public var frameCount:Int = 0;
	/**
	   Current Frame, if any (null otherwise)
	**/
	public var frameCurrent(default, null):Frame;
	/**
	   Playback speed
	   @default	1
	**/
	public var frameDelta:Float = 1.0;
	/**
	   Index of the current frame
	   @default	0
	**/
	public var frameIndex(get, set):Int;
	/**
	   Lists all frames
	   @default	null
	**/
	public var frameList:#if flash Vector<Frame> #else Array<Frame> #end;
	/**
	   Time elapsed on current frame
	   @default	0
	**/
	public var frameTime:Float = 0.0;
	/**
	   Timing of the current frame
	**/
	public var frameTimingCurrent(default, null):Float;
	/**
	   Duration of each frame
	   @default	null
	**/
	public var frameTimings:#if SWC Vector<Float> #else Array<Float> #end;
	/**
	   Current frame's height, if any, multiplied by scaleY (0 otherwise)
	**/
	public var height(get, set):Float;
	/**
	   Tells whether to invert display on horizontal axis or not
	   @default	false
	**/
	public var invertX(get, set):Bool;
	/**
	   Tells whether to invert display on vertical axis or not
	   @default	false
	**/
	public var invertY(get, set):Bool;
	/**
	   Tells whether to loop frames
	   @default	true
	**/
	public var loop:Bool = true;
	/**
	   Tells how many loops have been done
	   @default	0
	**/
	public var loopCount:Int = 0;
	/**
	   How many loops, 0 == infinite
	   @default	0
	**/
	public var numLoops:Int = 0;
	/**
	   Texture index when using multitexturing
	   @default	0
	**/
	public var textureIndex(get, set):Float;
	/**
	   Texture index used for rendering, if the profile is baseline it will differ from textureIndex
	   @default	0
	**/
	public var textureIndexReal:Float = 0.0;
	/**
	   Current frame's width, if any, multiplied by scaleX (0 otherwise)
	**/
	public var width(get, set):Float;
	
	private var _frameIndex:Int = -1;
	inline private function get_frameIndex():Int { return this._frameIndex; }
	inline private function set_frameIndex(value:Int):Int
	{
		if (this._frameIndex == value) return value;
		this.frameCurrent = this.frameList[value];
		this.frameTimingCurrent = this.frameTimings[value];
		this._transformChanged = this._sizeXChanged = this._sizeYChanged = true;
		return this._frameIndex = value;
	}
	
	private function get_height():Float { return (this.frameList == null || this.frameList.length == 0) ? 0.0 : this.frameList[this.frameIndex].height * this.scaleY; }
	private function set_height(value:Float):Float
	{
		if (this.frameList == null || this.frameList.length == 0) return 0.0;
		this.scaleY = value / this.frameList[this.frameIndex].height;
		return value;
	}
	
	private var _invertX:Bool = false;
	inline private function get_invertX():Bool { return this._invertX; }
	inline private function set_invertX(value:Bool):Bool
	{
		if (this._invertX == value) return value;
		this._transformChanged = this._sizeXChanged = true;
		return this._invertX = value;
	}
	
	private var _invertY:Bool = false;
	inline private function get_invertY():Bool {return this._invertY; }
	inline private function set_invertY(value:Bool):Bool
	{
		if (this._invertY == value) return value;
		this._transformChanged = this._sizeYChanged = true;
		return this._invertY = value;
	}
	
	inline private function get_textureIndex():Float { return this.textureIndexReal / TEXTURE_INDEX_MULTIPLIER; }
	inline private function set_textureIndex(value:Float):Float
	{
		return this.textureIndexReal = value * TEXTURE_INDEX_MULTIPLIER;
	}
	
	private function get_width():Float { return (this.frameList == null || this.frameList.length == 0) ? 0.0 : this.frameList[this.frameIndex].width * this.scaleX; }
	private function set_width(value:Float):Float
	{
		if (this.frameList == null || this.frameList.length == 0) return 0.0;
		this.scaleX = value / this.frameList[this.frameIndex].width;
		return value;
	}
	
	/**
	   Constructor
	**/
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
		this.frameDelta = 1.0;
		this._frameIndex = -1;
		this.frameTime = this.textureIndexReal = 0.0;
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
	public function setFrames(frames:#if flash Vector<Frame> #else Array<Frame> #end, timings:#if SWC Vector<Float> #else Array<Float> = null #end, loop:Bool = true, numLoops:Int = 0, frameIndex:Int = 0, animate:Bool = true):Void
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
				if (this._frameIndex == 0)
				{
					this.frameTime = 0.0;
				}
				else
				{
					this.frameTime = this.frameTimings[this._frameIndex - 1];
				}
			}
		}
	}
	
	/**
	   Set the timings associated to the current Frame objects
	   @param	timings
	**/
	public function setFrameTimings(timings:#if SWC Vector<Float> #else Array<Float> #end):Void
	{
		this.frameTimings = timings;
		this.frameCount = this.frameTimings == null ? this.frameList != null ? this.frameList.length - 1 : 0 : this.frameTimings.length - 1;
	}
	
}