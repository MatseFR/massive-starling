package massive.display;
import massive.data.Frame;
import massive.display.base.QuadBase;

#if flash
import openfl.Vector;
#end

/**
 * Image display object with optionnal texture animation
 * @author Matse
 */
class Img extends QuadBase
{
	static public var TEXTURE_INDEX_MULTIPLIER:Float;
	
	static private var _POOL:Array<Img> = new Array<Img>();
	
	/**
	   Returns an ImageData from pool if there's at least one in pool, or a new one otherwise
	   @return
	**/
	static public function fromPool():Img
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new Img();
	}
	
	/**
	   Returns an Array of ImageData, taken from pool if possible and created otherwise
	   @param	numImages
	   @param	images
	   @return
	**/
	static public function fromPoolArray(numImages:Int, images:Array<Img> = null):Array<Img>
	{
		if (images == null) images = new Array<Img>();
		
		while (numImages != 0)
		{
			if (_POOL.length == 0) break;
			images[images.length] = _POOL.pop();
			numImages--;
		}
		
		while (numImages != 0)
		{
			images[images.length] = new Img();
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
	static public function fromPoolVector(numImages:Int, images:Vector<Img> = null):Vector<Img>
	{
		if (images == null) images = new Vector<Img>();
		
		while (numImages != 0)
		{
			if (_POOL.length == 0) break;
			images[images.length] = _POOL.pop();
			numImages--;
		}
		
		while (numImages != 0)
		{
			images[images.length] = new Img();
			numImages--;
		}
		
		return images;
	}
	#end
	
	/**
	   Equivalent to calling ImageData's pool function
	   @param	img
	**/
	static public function toPool(img:Img):Void
	{
		img.clear();
		_POOL[_POOL.length] = img;
	}
	
	/**
	   Pools all ImageData objects in the specified Array
	   @param	images
	**/
	static public function toPoolArray(images:Array<Img>):Void
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
	static public function toPoolVector(images:Vector<Img>):Void
	{
		var count:Int = images.length;
		for (i in 0...count)
		{
			images[i].pool();
		}
	}
	#end
	
	/**
	   
	**/
	public var frame(get, set):Frame;
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
	   Texture index when using multitexturing
	   @default	0
	**/
	public var textureIndex(get, set):Float;
	/**
	   Texture index used for rendering, if the profile is baseline it will differ from textureIndex
	   @default	0
	**/
	public var textureIndexReal(default, null):Float = 0.0;
	/**
	   Current frame's width, if any, multiplied by scaleX (0 otherwise)
	**/
	public var width(get, set):Float;
	
	private var _frame:Frame;
	inline private function get_frame():Frame { return this._frame; }
	inline private function set_frame(value:Frame):Frame
	{
		this._transformChanged = this._sizeXChanged = this._sizeYChanged = true;
		return this._frame = value;
	}
	
	private function get_height():Float { return this._frame == null ? 0.0 : this._frame.height * this.scaleY; }
	private function set_height(value:Float):Float
	{
		if (this._frame == null) return 0.0;
		this.scaleY = value / this._frame.height;
		return value;
	}
	
	private var _invertX:Bool = false;
	inline private function get_invertX():Bool { return this._invertX; }
	inline private function set_invertX(value:Bool):Bool
	{
		if (this._invertX == value) return value;
		this._transformChanged = this._sizeXChanged = this._colorChanged = this._colorOffsetChanged = true;
		return this._invertX = value;
	}
	
	private var _invertY:Bool = false;
	inline private function get_invertY():Bool {return this._invertY; }
	inline private function set_invertY(value:Bool):Bool
	{
		if (this._invertY == value) return value;
		this._transformChanged = this._sizeYChanged = this._colorChanged = this._colorOffsetChanged = true;
		return this._invertY = value;
	}
	
	inline private function get_textureIndex():Float { return this.textureIndexReal / TEXTURE_INDEX_MULTIPLIER; }
	inline private function set_textureIndex(value:Float):Float
	{
		return this.textureIndexReal = value * TEXTURE_INDEX_MULTIPLIER;
	}
	
	private function get_width():Float { return (this._frame == null) ? 0.0 : this._frame.width * this.scaleX; }
	private function set_width(value:Float):Float
	{
		if (this._frame == null) return 0.0;
		this.scaleX = value / this._frame.width;
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
		this.invertX = this.invertY = false;
		
		this.textureIndexReal = 0.0;
		
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
	
}