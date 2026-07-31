package massive.display.base;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;

/**
 * Abstract base class for Massive display objects
 * @author Matse
 */
abstract class QuadBase extends DisplayBase
{
	/**
	   Tells whether vertexColor property is null (false) or not (true)
	**/
	public var hasVertexColor(default, null):Bool;
	/**
	   Tells whether vertexColorOffset property is null (false) or not (true)
	**/
	public var hasVertexColorOffset(default, null):Bool;
	/**
	   Tells whether vertexData property is null (false) or not (true)
	**/
	public var hasVertexPosition(default, null):Bool;
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
	   
	**/
	public var vertexColor(get, set):VertexColorData;
	/**
	   
	**/
	public var vertexColorOffset(get, set):VertexColorData;
	/**
	   
	**/
	public var vertexPosition(get, set):VertexPositionData;
	/**
	   Int color for all vertices
	   @default 0xffffff
	**/
	public var color(get, set):Int;
	/**
	   Int color offset
	   @default 0x000000
	**/
	public var colorOffset(get, set):Int;
	/**
	   Amount of red tinting for all vertices, can be negative
	   @default 1
	**/
	public var red(get, set):Float;
	/**
	   Amount of red offset, can be negative
	   @default	0
	**/
	public var redOffset(get, set):Float;
	/**
	   Amount of green tinting, can be negative
	   @default 1
	**/
	public var green(get, set):Float;
	/**
	   @default	0
	**/
	public var greenOffset(get, set):Float;
	/**
	   Amount of blue tinting, can be negative
	   @default 1
	**/
	public var blue(get, set):Float;
	/**
	   Blue offset
	   @default	0
	**/
	public var blueOffset(get, set):Float;
	/**
	   Opacity, from 0.0 to 1.0
	   @default 1
	**/
	public var alpha(get, set):Float;
	/**
	   Amount of alpha offset
	   @default	0
	**/
	public var alphaOffset(get, set):Float;
	
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
	
	private var _vertexColor:VertexColorData;
	inline private function get_vertexColor():VertexColorData { return this._vertexColor; }
	inline private function set_vertexColor(value:VertexColorData):VertexColorData
	{
		if (this._vertexColor == value) return value;
		this.hasVertexColor = value != null;
		this._colorChanged = true;
		return this._vertexColor = value;
	}
	
	private var _vertexColorOffset:VertexColorData;
	inline private function get_vertexColorOffset():VertexColorData { return this._vertexColorOffset; }
	inline private function set_vertexColorOffset(value:VertexColorData):VertexColorData
	{
		if (this._vertexColorOffset == value) return value;
		this.hasVertexColorOffset = value != null;
		this._colorOffsetChanged = true;
		return this._vertexColorOffset = value;
	}
	
	private var _vertexPosition:VertexPositionData;
	inline private function get_vertexPosition():VertexPositionData { return this._vertexPosition; }
	inline private function set_vertexPosition(value:VertexPositionData):VertexPositionData
	{
		if (this._vertexPosition == value) return value;
		this.hasVertexPosition = value != null;
		this._transformChanged = true;
		if (!this.hasVertexPosition)
		{
			this._sizeXChanged = this._sizeYChanged = true;
		}
		return this._vertexPosition = value;
	}
	
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
	
	private var _red:Float = 1.0;
	inline private function get_red():Float { return this._red; }
	inline private function set_red(value:Float):Float
	{
		this._colorChanged = true;
		return this._red = value;
	}
	
	private var _redOffset:Float = 0.0;
	inline private function get_redOffset():Float { return this._redOffset; }
	inline private function set_redOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._redOffset = value;
	}
	
	private var _green:Float = 1.0;
	inline private function get_green():Float { return this._green; }
	inline private function set_green(value:Float):Float
	{
		this._colorChanged = true;
		return this._green = value;
	}
	
	private var _greenOffset:Float = 0.0;
	inline private function get_greenOffset():Float { return this._greenOffset; }
	inline private function set_greenOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._greenOffset = value;
	}
	
	private var _blue:Float = 1.0;
	inline private function get_blue():Float { return this._blue; }
	inline private function set_blue(value:Float):Float
	{
		this._colorChanged = true;
		return this._blue = value;
	}
	
	private var _blueOffset:Float = 0.0;
	inline private function get_blueOffset():Float { return this._blueOffset; }
	inline private function set_blueOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._blueOffset = value;
	}
	
	private var _alpha:Float = 1.0;
	inline private function get_alpha():Float { return this._alpha; }
	inline private function set_alpha(value:Float):Float
	{
		this._colorChanged = true;
		return this._alpha = value;
	}
	
	private var _alphaOffset:Float = 0.0;
	inline private function get_alphaOffset():Float { return this._alphaOffset; }
	inline private function set_alphaOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._alphaOffset = value;
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
	
	private var _colorChanged:Bool;
	private var _colorOffsetChanged:Bool;
	
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
		this._colorChanged = this._colorOffsetChanged = false;
	}
	
	/**
	   send the object to pool
	**/
	abstract public function pool():Void;
	
	inline private function applyVertexData():Void
	{
		this._x1 = this._vertexPosition.x1 * this._scaleX;
		this._x2 = this._vertexPosition.x2 * this._scaleX;
		this._x3 = this._vertexPosition.x3 * this._scaleX;
		this._x4 = this._vertexPosition.x4 * this._scaleX;
		this._y1 = this._vertexPosition.y1 * this._scaleY;
		this._y2 = this._vertexPosition.y2 * this._scaleY;
		this._y3 = this._vertexPosition.y3 * this._scaleY;
		this._y4 = this._vertexPosition.y4 * this._scaleY;
		this._sizeXChanged = this._sizeYChanged = this._transformChanged = false;
	}
	
}