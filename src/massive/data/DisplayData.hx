package massive.data;

/**
 * Abstract base class for Massive display objects
 * @author Matse
 */
@:allow(massive.display.MassiveLayer)
abstract class DisplayData extends DisplayBase
{
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
	   Int color for all vertices
	   @default 0xffffff
	**/
	public var color(get, set):Int;
	/**
	   Int color for top left vertex
	   @default	0xffffff
	**/
	public var color1(get, set):Int;
	/**
	   Int color for top right vertex
	   @default	0xffffff
	**/
	public var color2(get, set):Int;
	/**
	   Int color for bottom left vertex
	   @default	0xffffff
	**/
	public var color3(get, set):Int;
	/**
	   Int color for bottom right vertex
	   @default	0xffffff
	**/
	public var color4(get, set):Int;
	/**
	   Int color offset
	   @default 0x000000
	**/
	public var colorOffset(get, set):Int;
	/**
	   Int color offset for top left vertex
	   @default 0x000000
	**/
	public var colorOffset1(get, set):Int;
	/**
	   Int color offset for top right vertex
	   @default 0x000000
	**/
	public var colorOffset2(get, set):Int;
	/**
	   Int color offset for bottom left vertex
	   @default 0x000000
	**/
	public var colorOffset3(get, set):Int;
	/**
	   Int color offset for bottom right vertex
	   @default 0x000000
	**/
	public var colorOffset4(get, set):Int;
	/**
	   Amount of red tinting for all vertices, can be negative
	   @default 1
	**/
	public var red(get, set):Float;
	/**
	   Amount of red tinting for top left vertex, can be negative
	   @default	1
	**/
	public var red1(get, set):Float;
	/**
	   Amount of red tinting for top right vertex, can be negative
	   @default	1
	**/
	public var red2(get, set):Float;
	/**
	   Amount of red tinting for bottom left vertex, can be negative
	   @default	1
	**/
	public var red3(get, set):Float;
	/**
	   Amount of red tinting for bottom right vertex, can be negative
	   @default	1
	**/
	public var red4(get, set):Float;
	/**
	   Amount of red offset, can be negative
	   @default	0
	**/
	public var redOffset(get, set):Float;
	/**
	   Amount of red offset for top left vertex, can be negative
	   @default	0
	**/
	public var redOffset1(get, set):Float;
	/**
	   Amount of red offset for top right vertex, can be negative
	   @default	0
	**/
	public var redOffset2(get, set):Float;
	/**
	   Amount of red offset for bottom left vertex, can be negative
	   @default	0
	**/
	public var redOffset3(get, set):Float;
	/**
	   Amount of red offset for bottom right vertex, can be negative
	   @default	0
	**/
	public var redOffset4(get, set):Float;
	/**
	   Amount of green tinting, can be negative
	   @default 1
	**/
	public var green(get, set):Float;
	/**
	   Amount of green tinting for top left vertex, can be negative
	   @default	1
	**/
	public var green1(get, set):Float;
	/**
	   Amount of green tinting for top right vertex, can be negative
	   @default	1
	**/
	public var green2(get, set):Float;
	/**
	   Amount of green tinting for bottom left vertex, can be negative
	   @default	1
	**/
	public var green3(get, set):Float;
	/**
	   Amount of green tinting for bottom right vertex, can be negative
	   @default	1
	**/
	public var green4(get, set):Float;
	/**
	   @default	0
	**/
	public var greenOffset(get, set):Float;
	/**
	   Amount of green offset for top left vertex, can be negative
	   @default	0
	**/
	public var greenOffset1(get, set):Float;
	/**
	   Amount of green offset for top right vertex, can be negative
	   @default	0
	**/
	public var greenOffset2(get, set):Float;
	/**
	   Amount of green offset for bottom left vertex, can be negative
	   @default	0
	**/
	public var greenOffset3(get, set):Float;
	/**
	   Amount of green offset for bottom right vertex, can be negative
	   @default	0
	**/
	public var greenOffset4(get, set):Float;
	/**
	   Amount of blue tinting, can be negative
	   @default 1
	**/
	public var blue(get, set):Float;
	/**
	   Amount of blue tinting for top left vertex, can be negative
	   @default	1
	**/
	public var blue1(get, set):Float;
	/**
	   Amount of blue tinting for top right vertex, can be negative
	   @default	1
	**/
	public var blue2(get, set):Float;
	/**
	   Amount of blue tinting for bottom left vertex, can be negative
	   @default	1
	**/
	public var blue3(get, set):Float;
	/**
	   Amount of blue tinting for bottom right vertex, can be negative
	   @default	1
	**/
	public var blue4(get, set):Float;
	/**
	   Blue offset
	   @default	0
	**/
	public var blueOffset(get, set):Float;
	/**
	   Amount of blue offset for top left vertex, can be negative
	   @default	0
	**/
	public var blueOffset1(get, set):Float;
	/**
	   Amount of blue offset for top right vertex, can be negative
	   @default	0
	**/
	public var blueOffset2(get, set):Float;
	/**
	   Amount of blue offset for bottom left vertex, can be negative
	   @default	0
	**/
	public var blueOffset3(get, set):Float;
	/**
	   Amount of blue offset for bottom right vertex, can be negative
	   @default	0
	**/
	public var blueOffset4(get, set):Float;
	/**
	   Opacity, from 0.0 to 1.0
	   @default 1
	**/
	public var alpha(get, set):Float;
	/**
	   Opacity for top left vertex
	   @default	1
	**/
	public var alpha1(get, set):Float;
	/**
	   Opacity for top right vertex
	   @default	1
	**/
	public var alpha2(get, set):Float;
	/**
	   Opacity for bottom left vertex
	   @default	1
	**/
	public var alpha3(get, set):Float;
	/**
	   Opacity for bottom right vertex
	   @default	1
	**/
	public var alpha4(get, set):Float;
	/**
	   Amount of alpha offset
	   @default	0
	**/
	public var alphaOffset(get, set):Float;
	/**
	   Amount of alpha offset for top left vertex, can be negative
	   @default	0
	**/
	public var alphaOffset1(get, set):Float;
	/**
	   Amount of alpha offset for top right vertex, can be negative
	   @default	0
	**/
	public var alphaOffset2(get, set):Float;
	/**
	   Amount of alpha offset for bottom left vertex, can be negative
	   @default	0
	**/
	public var alphaOffset3(get, set):Float;
	/**
	   Amount of alpha offset for bottom right vertex, can be negative
	   @default	0
	**/
	public var alphaOffset4(get, set):Float;
	/**
	   Tells whether the same color should apply to all vertices (true) or not (false).
	   @default	true
	**/
	public var uniformColor(get, set):Bool;
	/**
	   Tells whether the same color offset should apply to all vertices (true) or not (false).
	   @default	true
	**/
	public var uniformColorOffset(get, set):Bool;
	
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
	
	private function get_color1():Int
	{
		var r:Float = this._red1 > 1.0 ? 1.0 : this._red1 < 0.0 ? 0.0 : this._red1;
		var g:Float = this._green1 > 1.0 ? 1.0 : this._green1 < 0.0 ? 0.0 : this._green1;
		var b:Float = this._blue1 > 1.0 ? 1.0 : this._blue1 < 0.0 ? 0.0 : this._blue1;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color1(value:Int):Int
	{
		this._red1 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._green1 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blue1 = (value & 0xFF) / 255.0;
		this._colorChanged = true;
		return value;
	}
	
	private function get_color2():Int
	{
		var r:Float = this._red2 > 1.0 ? 1.0 : this._red2 < 0.0 ? 0.0 : this._red2;
		var g:Float = this._green2 > 1.0 ? 1.0 : this._green2 < 0.0 ? 0.0 : this._green2;
		var b:Float = this._blue2 > 1.0 ? 1.0 : this._blue2 < 0.0 ? 0.0 : this._blue2;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color2(value:Int):Int
	{
		this._red2 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._green2 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blue2 = (value & 0xFF) / 255.0;
		this._colorChanged = true;
		return value;
	}
	
	private function get_color3():Int
	{
		var r:Float = this._red3 > 1.0 ? 1.0 : this._red3 < 0.0 ? 0.0 : this._red3;
		var g:Float = this._green3 > 1.0 ? 1.0 : this._green3 < 0.0 ? 0.0 : this._green3;
		var b:Float = this._blue3 > 1.0 ? 1.0 : this._blue3 < 0.0 ? 0.0 : this._blue3;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color3(value:Int):Int
	{
		this._red3 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._green3 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blue3 = (value & 0xFF) / 255.0;
		this._colorChanged = true;
		return value;
	}
	
	private function get_color4():Int
	{
		var r:Float = this._red4 > 1.0 ? 1.0 : this._red4 < 0.0 ? 0.0 : this._red4;
		var g:Float = this._green4 > 1.0 ? 1.0 : this._green4 < 0.0 ? 0.0 : this._green4;
		var b:Float = this._blue4 > 1.0 ? 1.0 : this._blue4 < 0.0 ? 0.0 : this._blue4;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color4(value:Int):Int
	{
		this._red4 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._green4 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blue4 = (value & 0xFF) / 255.0;
		this._colorChanged = true;
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
	
	private function get_colorOffset1():Int
	{
		var r:Float = this._redOffset1 > 1.0 ? 1.0 : this._redOffset1 < 0.0 ? 0.0 : this._redOffset1;
		var g:Float = this._greenOffset1 > 1.0 ? 1.0 : this._greenOffset1 < 0.0 ? 0.0 : this._greenOffset1;
		var b:Float = this._blueOffset1 > 1.0 ? 1.0 : this._blueOffset1 < 0.0 ? 0.0 : this._blueOffset1;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset1(value:Int):Int
	{
		this._redOffset1 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._greenOffset1 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blueOffset1 = (value & 0xFF) / 255.0;
		this._colorOffsetChanged = true;
		return value;
	}
	
	private function get_colorOffset2():Int
	{
		var r:Float = this._redOffset2 > 1.0 ? 1.0 : this._redOffset2 < 0.0 ? 0.0 : this._redOffset2;
		var g:Float = this._greenOffset2 > 1.0 ? 1.0 : this._greenOffset2 < 0.0 ? 0.0 : this._greenOffset2;
		var b:Float = this._blueOffset2 > 1.0 ? 1.0 : this._blueOffset2 < 0.0 ? 0.0 : this._blueOffset2;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset2(value:Int):Int
	{
		this._redOffset2 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._greenOffset2 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blueOffset2 = (value & 0xFF) / 255.0;
		this._colorOffsetChanged = true;
		return value;
	}
	
	private function get_colorOffset3():Int
	{
		var r:Float = this._redOffset3 > 1.0 ? 1.0 : this._redOffset3 < 0.0 ? 0.0 : this._redOffset3;
		var g:Float = this._greenOffset3 > 1.0 ? 1.0 : this._greenOffset3 < 0.0 ? 0.0 : this._greenOffset3;
		var b:Float = this._blueOffset3 > 1.0 ? 1.0 : this._blueOffset3 < 0.0 ? 0.0 : this._blueOffset3;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset3(value:Int):Int
	{
		this._redOffset3 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._greenOffset3 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blueOffset3 = (value & 0xFF) / 255.0;
		this._colorOffsetChanged = true;
		return value;
	}
	
	private function get_colorOffset4():Int
	{
		var r:Float = this._redOffset4 > 1.0 ? 1.0 : this._redOffset4 < 0.0 ? 0.0 : this._redOffset4;
		var g:Float = this._greenOffset4 > 1.0 ? 1.0 : this._greenOffset4 < 0.0 ? 0.0 : this._greenOffset4;
		var b:Float = this._blueOffset4 > 1.0 ? 1.0 : this._blueOffset4 < 0.0 ? 0.0 : this._blueOffset4;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset4(value:Int):Int
	{
		this._redOffset4 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._greenOffset4 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blueOffset4 = (value & 0xFF) / 255.0;
		this._colorOffsetChanged = true;
		return value;
	}
	
	inline private function get_red():Float { return this._red1; }
	inline private function set_red(value:Float):Float
	{
		this._colorChanged = true;
		return this._red1 = this._red2 = this._red3 = this._red4 = value;
	}
	
	private var _red1:Float = 1.0;
	inline private function get_red1():Float { return this._red1; }
	inline private function set_red1(value:Float):Float
	{
		this._colorChanged = true;
		return this._red1 = value;
	}
	
	private var _red2:Float = 1.0;
	inline private function get_red2():Float { return this._red2; }
	inline private function set_red2(value:Float):Float
	{
		this._colorChanged = true;
		return this._red2 = value;
	}
	
	private var _red3:Float = 1.0;
	inline private function get_red3():Float { return this._red3; }
	inline private function set_red3(value:Float):Float
	{
		this._colorChanged = true;
		return this._red3 = value;
	}
	
	private var _red4:Float = 1.0;
	inline private function get_red4():Float { return this._red4; }
	inline private function set_red4(value:Float):Float
	{
		this._colorChanged = true;
		return this._red4 = value;
	}
	
	inline private function get_redOffset():Float { return this._redOffset1; }
	inline private function set_redOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._redOffset1 = this._redOffset2 = this._redOffset3 = this._redOffset4 = value;
	}
	
	private var _redOffset1:Float = 0.0;
	inline private function get_redOffset1():Float { return this._redOffset1; }
	inline private function set_redOffset1(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._redOffset1 = value;
	}
	
	private var _redOffset2:Float = 0.0;
	inline private function get_redOffset2():Float { return this._redOffset2; }
	inline private function set_redOffset2(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._redOffset2 = value;
	}
	
	private var _redOffset3:Float = 0.0;
	inline private function get_redOffset3():Float { return this._redOffset3; }
	inline private function set_redOffset3(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._redOffset3 = value;
	}
	
	private var _redOffset4:Float = 0.0;
	inline private function get_redOffset4():Float { return this._redOffset4; }
	inline private function set_redOffset4(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._redOffset4 = value;
	}
	
	inline private function get_green():Float { return this._green1; }
	inline private function set_green(value:Float):Float
	{
		this._colorChanged = true;
		return this._green1 = this._green2 = this._green3 = this._green4 = value;
	}
	
	private var _green1:Float = 1.0;
	inline private function get_green1():Float { return this._green1; }
	inline private function set_green1(value:Float):Float
	{
		this._colorChanged = true;
		return this._green1 = value;
	}
	
	private var _green2:Float = 1.0;
	inline private function get_green2():Float { return this._green2; }
	inline private function set_green2(value:Float):Float
	{
		this._colorChanged = true;
		return this._green2 = value;
	}
	
	private var _green3:Float = 1.0;
	inline private function get_green3():Float { return this._green3; }
	inline private function set_green3(value:Float):Float
	{
		this._colorChanged = true;
		return this._green3 = value;
	}
	
	private var _green4:Float = 1.0;
	inline private function get_green4():Float { return this._green4; }
	inline private function set_green4(value:Float):Float
	{
		this._colorChanged = true;
		return this._green4 = value;
	}
	
	inline private function get_greenOffset():Float { return this._greenOffset1; }
	inline private function set_greenOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._greenOffset1 = this._greenOffset2 = this._greenOffset3 = this._greenOffset4 = value;
	}
	
	private var _greenOffset1:Float = 0.0;
	inline private function get_greenOffset1():Float { return this._greenOffset1; }
	inline private function set_greenOffset1(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._greenOffset1 = value;
	}
	
	private var _greenOffset2:Float = 0.0;
	inline private function get_greenOffset2():Float { return this._greenOffset2; }
	inline private function set_greenOffset2(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._greenOffset2 = value;
	}
	
	private var _greenOffset3:Float = 0.0;
	inline private function get_greenOffset3():Float { return this._greenOffset3; }
	inline private function set_greenOffset3(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._greenOffset3 = value;
	}
	
	private var _greenOffset4:Float = 0.0;
	inline private function get_greenOffset4():Float { return this._greenOffset4; }
	inline private function set_greenOffset4(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._greenOffset4 = value;
	}
	
	inline private function get_blue():Float { return this._blue1; }
	inline private function set_blue(value:Float):Float
	{
		this._colorChanged = true;
		return this._blue1 = this._blue2 = this._blue3 = this._blue4 = value;
	}
	
	private var _blue1:Float = 1.0;
	inline private function get_blue1():Float { return this._blue1; }
	inline private function set_blue1(value:Float):Float
	{
		this._colorChanged = true;
		return this._blue1 = value;
	}
	
	private var _blue2:Float = 1.0;
	inline private function get_blue2():Float { return this._blue2; }
	inline private function set_blue2(value:Float):Float
	{
		this._colorChanged = true;
		return this._blue2 = value;
	}
	
	private var _blue3:Float = 1.0;
	inline private function get_blue3():Float { return this._blue3; }
	inline private function set_blue3(value:Float):Float
	{
		this._colorChanged = true;
		return this._blue3 = value;
	}
	
	private var _blue4:Float = 1.0;
	inline private function get_blue4():Float { return this._blue4; }
	inline private function set_blue4(value:Float):Float
	{
		this._colorChanged = true;
		return this._blue4 = value;
	}
	
	inline private function get_blueOffset():Float { return this._blueOffset1; }
	inline private function set_blueOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._blueOffset1 = this._blueOffset2 = this._blueOffset3 = this._blueOffset4 = value;
	}
	
	private var _blueOffset1:Float = 0.0;
	inline private function get_blueOffset1():Float { return this._blueOffset1; }
	inline private function set_blueOffset1(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._blueOffset1 = value;
	}
	
	private var _blueOffset2:Float = 0.0;
	inline private function get_blueOffset2():Float { return this._blueOffset2; }
	inline private function set_blueOffset2(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._blueOffset2 = value;
	}
	
	private var _blueOffset3:Float = 0.0;
	inline private function get_blueOffset3():Float { return this._blueOffset3; }
	inline private function set_blueOffset3(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._blueOffset3 = value;
	}
	
	private var _blueOffset4:Float = 0.0;
	inline private function get_blueOffset4():Float { return this._blueOffset4; }
	inline private function set_blueOffset4(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._blueOffset4 = value;
	}
	
	inline private function get_alpha():Float { return this._alpha1; }
	inline private function set_alpha(value:Float):Float
	{
		this._colorChanged = true;
		return this._alpha1 = this._alpha2 = this._alpha3 = this._alpha4 = value;
	}
	
	private var _alpha1:Float = 1.0;
	inline private function get_alpha1():Float { return this._alpha1; }
	inline private function set_alpha1(value:Float):Float
	{
		this._colorChanged = true;
		return this._alpha1 = value;
	}
	
	private var _alpha2:Float = 1.0;
	inline private function get_alpha2():Float { return this._alpha2; }
	inline private function set_alpha2(value:Float):Float
	{
		this._colorChanged = true;
		return this._alpha2 = value;
	}
	
	private var _alpha3:Float = 1.0;
	inline private function get_alpha3():Float { return this._alpha3; }
	inline private function set_alpha3(value:Float):Float
	{
		this._colorChanged = true;
		return this._alpha3 = value;
	}
	
	private var _alpha4:Float = 1.0;
	inline private function get_alpha4():Float { return this._alpha4; }
	inline private function set_alpha4(value:Float):Float
	{
		this._colorChanged = true;
		return this._alpha4 = value;
	}
	
	inline private function get_alphaOffset():Float { return this._alphaOffset1; }
	inline private function set_alphaOffset(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._alphaOffset1 = this._alphaOffset2 = this._alphaOffset3 = this._alphaOffset4 = value;
	}
	
	private var _alphaOffset1:Float = 0.0;
	inline private function get_alphaOffset1():Float { return this._alphaOffset1; }
	inline private function set_alphaOffset1(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._alphaOffset1 = value;
	}
	
	private var _alphaOffset2:Float = 0.0;
	inline private function get_alphaOffset2():Float { return this._alphaOffset2; }
	inline private function set_alphaOffset2(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._alphaOffset2 = value;
	}
	
	private var _alphaOffset3:Float = 0.0;
	inline private function get_alphaOffset3():Float { return this._alphaOffset3; }
	inline private function set_alphaOffset3(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._alphaOffset3 = value;
	}
	
	private var _alphaOffset4:Float = 0.0;
	inline private function get_alphaOffset4():Float { return this._alphaOffset4; }
	inline private function set_alphaOffset4(value:Float):Float
	{
		this._colorOffsetChanged = true;
		return this._alphaOffset4 = value;
	}
	
	private var _uniformColor:Bool = true;
	inline private function get_uniformColor():Bool { return this._uniformColor; }
	inline private function set_uniformColor(value:Bool):Bool
	{
		this._colorChanged = true;
		return this._uniformColor = value;
	}
	
	private var _uniformColorOffset:Bool = true;
	inline private function get_uniformColorOffset():Bool { return this._uniformColorOffset; }
	inline private function set_uniformColorOffset(value:Bool):Bool
	{
		this._colorOffsetChanged = true;
		return this._uniformColorOffset = value;
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
	
	private var _color1Final:Int = 0xffffffff;
	private var _color2Final:Int = 0xffffffff;
	private var _color3Final:Int = 0xffffffff;
	private var _color4Final:Int = 0xffffffff;
	
	private var _red1Final:Float = 1.0;
	private var _red2Final:Float = 1.0;
	private var _red3Final:Float = 1.0;
	private var _red4Final:Float = 1.0;
	
	private var _green1Final:Float = 1.0;
	private var _green2Final:Float = 1.0;
	private var _green3Final:Float = 1.0;
	private var _green4Final:Float = 1.0;
	
	private var _blue1Final:Float = 1.0;
	private var _blue2Final:Float = 1.0;
	private var _blue3Final:Float = 1.0;
	private var _blue4Final:Float = 1.0;
	
	private var _alpha1Final:Float = 1.0;
	private var _alpha2Final:Float = 1.0;
	private var _alpha3Final:Float = 1.0;
	private var _alpha4Final:Float = 1.0;
	
	private var _colorOffsetChanged:Bool;
	
	private var _colorOffset1Final:Int = 0x00000000;
	private var _colorOffset2Final:Int = 0x00000000;
	private var _colorOffset3Final:Int = 0x00000000;
	private var _colorOffset4Final:Int = 0x00000000;
	
	private var _redOffset1Final:Float = 0.0;
	private var _redOffset2Final:Float = 0.0;
	private var _redOffset3Final:Float = 0.0;
	private var _redOffset4Final:Float = 0.0;
	
	private var _greenOffset1Final:Float = 0.0;
	private var _greenOffset2Final:Float = 0.0;
	private var _greenOffset3Final:Float = 0.0;
	private var _greenOffset4Final:Float = 0.0;
	
	private var _blueOffset1Final:Float = 0.0;
	private var _blueOffset2Final:Float = 0.0;
	private var _blueOffset3Final:Float = 0.0;
	private var _blueOffset4Final:Float = 0.0;
	
	private var _alphaOffset1Final:Float = 0.0;
	private var _alphaOffset2Final:Float = 0.0;
	private var _alphaOffset3Final:Float = 0.0;
	private var _alphaOffset4Final:Float = 0.0;
	
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