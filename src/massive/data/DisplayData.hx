package massive.data;

/**
 * Abstract base class for Massive display objects
 * @author Matse
 */
@:allow(massive.display.MassiveLayer)
abstract class DisplayData extends DisplayBase
{
	/**
	   position on x-axis
	   @default 0
	**/
	//public var x:Float = 0.0;
	/**
	   position on y-axis
	   @default 0
	**/
	//public var y:Float = 0.0;
	/**
	   position offset on x-axis
	   @default 0
	**/
	public var offsetX:Float = 0.0;
	/**
	   position offset on y-axis
	   @default 0
	**/
	public var offsetY:Float = 0.0;
	/**
	   rotation in radians
	   @default	0
	**/
	public var rotation(get, set):Float;
	/**
	   horizontal scale factor
	   @default	1
	**/
	public var scaleX(get, set):Float;
	/**
	   vertical scale factor
	   @default	1
	**/
	public var scaleY(get, set):Float;
	/**
	   horizontal skew angle in radians
	   @default	0
	**/
	public var skewX(get, set):Float;
	/**
	   vertical skew angle in radians
	   @default	0
	**/
	public var skewY(get, set):Float;
	/**
	   Int color
	   @default 0xffffff
	**/
	public var color(get, set):Int;
	/**
	   Int color offset
	   @default 0x000000
	**/
	public var colorOffset(get, set):Int;
	/**
	   Amount of red tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var red:Float = 1.0;
	/**
	   @default	0
	**/
	public var redOffset:Float = 0.0;
	/**
	   Amount of green tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var green:Float = 1.0;
	/**
	   @default	0
	**/
	public var greenOffset:Float = 0.0;
	/**
	   Amount of blue tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var blue:Float = 1.0;
	/**
	   @default	0
	**/
	public var blueOffset:Float = 0.0;
	/**
	   Opacity, from 0.0 to 1.0
	   @default 1
	**/
	public var alpha:Float = 1.0;
	/**
	   @default	0
	**/
	public var alphaOffset:Float = 0.0;
	/**
	   Tells whether this object is visible or not
	   @default true
	**/
	//public var visible:Bool = true;
	
	private function get_color():Int
	{
		var r:Float = this.red > 1.0 ? 1.0 : this.red < 0.0 ? 0.0 : this.red;
		var g:Float = this.green > 1.0 ? 1.0 : this.green < 0.0 ? 0.0 : this.green;
		var b:Float = this.blue > 1.0 ? 1.0 : this.blue < 0.0 ? 0.0 : this.blue;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color(value:Int):Int
	{
		this.red = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.green = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blue = (value & 0xFF) / 255.0;
		return value;
	}
	
	private function get_colorOffset():Int
	{
		var r:Float = this.redOffset > 1.0 ? 1.0 : this.redOffset < 0.0 ? 0.0 : this.redOffset;
		var g:Float = this.greenOffset > 1.0 ? 1.0 : this.greenOffset < 0.0 ? 0.0 : this.greenOffset;
		var b:Float = this.blueOffset > 1.0 ? 1.0 : this.blueOffset < 0.0 ? 0.0 : this.blueOffset;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset(value:Int):Int
	{
		this.redOffset = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.greenOffset = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blueOffset = (value & 0xFF) / 255.0;
		return value;
	}
	
	private var _rotation:Float = 0.0;
	inline private function get_rotation():Float { return this._rotation; }
	inline private function set_rotation(value:Float):Float
	{
		if (this._rotation == value) return value;
		this._transformChanged = this._rotationChanged = true;
		return this._rotation = value;
	}
	
	private var _scaleX:Float = 1.0;
	inline private function get_scaleX():Float { return this._scaleX; }
	inline private function set_scaleX(value:Float):Float
	{
		if (this._scaleX == value) return value;
		this._transformChanged = this._sizeXChanged = true;
		return this._scaleX = value;
	}
	
	private var _scaleY:Float = 1.0;
	inline private function get_scaleY():Float { return this._scaleY; }
	inline private function set_scaleY(value:Float):Float
	{
		if (this._scaleY == value) return value;
		this._transformChanged = this._sizeYChanged = true;
		return this._scaleY = value;
	}
	
	private var _skewX:Float = 0.0;
	inline private function get_skewX():Float { return this._skewX; }
	inline private function set_skewX(value:Float):Float
	{
		if (this._skewX == value) return value;
		this._transformChanged = this._skewXChanged = true;
		return this._skewX = value;
	}
	
	private var _skewY:Float = 0.0;
	inline private function get_skewY():Float { return this._skewY; }
	inline private function set_skewY(value:Float):Float
	{
		if (this._skewY == value) return value;
		this._transformChanged = this._skewYChanged = true;
		return this._skewY = value;
	}
	
	private var _cosRotation:Float = 1.0;
	private var _cosSkewX:Float = 1.0;
	private var _cosSkewY:Float = 1.0;
	private var _sinRotation:Float = 0.0;
	private var _sinSkewX:Float = 0.0;
	private var _sinSkewY:Float = 0.0;
	
	private var _rotationChanged:Bool;
	private var _sizeXChanged:Bool;
	private var _sizeYChanged:Bool;
	private var _skewXChanged:Bool;
	private var _skewYChanged:Bool;
	private var _transformChanged:Bool;
	
	private var _leftOffset:Float;
	private var _rightOffset:Float;
	private var _topOffset:Float;
	private var _bottomOffset:Float;
	
	private var _a:Float = 1.0;
	private var _b:Float = 0.0;
	private var _c:Float = 0.0;
	private var _d:Float = 1.0;
	
	private var _x1:Float;
	private var _x2:Float;
	private var _x3:Float;
	private var _x4:Float;
	private var _y1:Float;
	private var _y2:Float;
	private var _y3:Float;
	private var _y4:Float;
	
	public function new() 
	{
		super();
		this._sizeXChanged = this._sizeYChanged = this._transformChanged = true; // force initial calculations
	}
	
	/**
	   restores default values
	**/
	public function clear():Void
	{
		this.x = this.y = this.offsetX = this.offsetY = this._rotation = this._skewX = this._skewY = this.redOffset = this.greenOffset = this.blueOffset = this.alphaOffset = 0.0;
		this._scaleX = this._scaleY = this.red = this.green = this.blue = this.alpha = 1.0;
		this.visible = true;
		
		this._cosRotation = this._cosSkewX = this._cosSkewY = this._a = this._d = 1.0;
		this._sinRotation = this._sinSkewX = this._sinSkewY = this._b = this._c = 0.0;
		this._rotationChanged = this._skewXChanged = this._skewYChanged = false;
		this._sizeXChanged = this._sizeYChanged = this._transformChanged = true;
	}
	
	/**
	   send the object to pool
	**/
	abstract public function pool():Void;
	
}