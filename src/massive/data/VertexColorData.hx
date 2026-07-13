package massive.data;

/**
 * ...
 * @author Matse
 */
class VertexColorData 
{
	static private var _POOL:Array<VertexColorData> = new Array<VertexColorData>();
	
	static public function fromPool():VertexColorData
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new VertexColorData();
	}
	
	public var changed(default, null):Bool;
	
	public var color(get, set):Int;
	public var color1(get, set):Int;
	public var color2(get, set):Int;
	public var color3(get, set):Int;
	public var color4(get, set):Int;
	
	public var red(get, set):Float;
	public var red1(get, set):Float;
	public var red2(get, set):Float;
	public var red3(get, set):Float;
	public var red4(get, set):Float;
	
	public var green(get, set):Float;
	public var green1(get, set):Float;
	public var green2(get, set):Float;
	public var green3(get, set):Float;
	public var green4(get, set):Float;
	
	public var blue(get, set):Float;
	public var blue1(get, set):Float;
	public var blue2(get, set):Float;
	public var blue3(get, set):Float;
	public var blue4(get, set):Float;
	
	public var alpha(get, set):Float;
	public var alpha1(get, set):Float;
	public var alpha2(get, set):Float;
	public var alpha3(get, set):Float;
	public var alpha4(get, set):Float;
	
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
		this.changed = true;
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
		this.changed = true;
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
		this.changed = true;
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
		this.changed = true;
		return value;
	}
	
	private function get_red():Float { return this._red1; }
	private function set_red(value:Float):Float
	{
		this.changed = true;
		return this._red1 = this._red2 = this._red3 = this._red4 = value;
	}
	
	private var _red1:Float = 1.0;
	inline private function get_red1():Float { return this._red1; }
	inline private function set_red1(value:Float):Float
	{
		this.changed = true;
		return this._red1 = value;
	}
	
	private var _red2:Float = 1.0;
	inline private function get_red2():Float { return this._red2; }
	inline private function set_red2(value:Float):Float
	{
		this.changed = true;
		return this._red2 = value;
	}
	
	private var _red3:Float = 1.0;
	inline private function get_red3():Float { return this._red3; }
	inline private function set_red3(value:Float):Float
	{
		this.changed = true;
		return this._red3 = value;
	}
	
	private var _red4:Float = 1.0;
	inline private function get_red4():Float { return this._red4; }
	inline private function set_red4(value:Float):Float
	{
		this.changed = true;
		return this._red4 = value;
	}
	
	private function get_green():Float { return this._green1; }
	private function set_green(value:Float):Float
	{
		this.changed = true;
		return this._green1 = this._green2 = this._green3 = this._green4 = value;
	}
	
	private var _green1:Float = 1.0;
	inline private function get_green1():Float { return this._green1; }
	inline private function set_green1(value:Float):Float
	{
		this.changed = true;
		return this._green1 = value;
	}
	
	private var _green2:Float = 1.0;
	inline private function get_green2():Float { return this._green2; }
	inline private function set_green2(value:Float):Float
	{
		this.changed = true;
		return this._green2 = value;
	}
	
	private var _green3:Float = 1.0;
	inline private function get_green3():Float { return this._green3; }
	inline private function set_green3(value:Float):Float
	{
		this.changed = true;
		return this._green3 = value;
	}
	
	private var _green4:Float = 1.0;
	inline private function get_green4():Float { return this._green4; }
	inline private function set_green4(value:Float):Float
	{
		this.changed = true;
		return this._green4 = value;
	}
	
	private function get_blue():Float { return this._blue1; }
	private function set_blue(value:Float):Float
	{
		this.changed = true;
		return this._blue1 = this._blue2 = this._blue3 = this._blue4 = value;
	}
	
	private var _blue1:Float = 1.0;
	inline private function get_blue1():Float { return this._blue1; }
	inline private function set_blue1(value:Float):Float
	{
		this.changed = true;
		return this._blue1 = value;
	}
	
	private var _blue2:Float = 1.0;
	inline private function get_blue2():Float { return this._blue2; }
	inline private function set_blue2(value:Float):Float
	{
		this.changed = true;
		return this._blue2 = value;
	}
	
	private var _blue3:Float = 1.0;
	inline private function get_blue3():Float { return this._blue3; }
	inline private function set_blue3(value:Float):Float
	{
		this.changed = true;
		return this._blue3 = value;
	}
	
	private var _blue4:Float = 1.0;
	inline private function get_blue4():Float { return this._blue4; }
	inline private function set_blue4(value:Float):Float
	{
		this.changed = true;
		return this._blue4 = value;
	}
	
	inline private function get_alpha():Float { return this._alpha1; }
	inline private function set_alpha(value:Float):Float
	{
		this.changed = true;
		return this._alpha1 = this._alpha2 = this._alpha3 = this._alpha4 = value;
	}
	
	private var _alpha1:Float = 1.0;
	inline private function get_alpha1():Float { return this._alpha1; }
	inline private function set_alpha1(value:Float):Float
	{
		this.changed = true;
		return this._alpha1 = value;
	}
	
	private var _alpha2:Float = 1.0;
	inline private function get_alpha2():Float { return this._alpha2; }
	inline private function set_alpha2(value:Float):Float
	{
		this.changed = true;
		return this._alpha2 = value;
	}
	
	private var _alpha3:Float = 1.0;
	inline private function get_alpha3():Float { return this._alpha3; }
	inline private function set_alpha3(value:Float):Float
	{
		this.changed = true;
		return this._alpha3 = value;
	}
	
	private var _alpha4:Float = 1.0;
	inline private function get_alpha4():Float { return this._alpha4; }
	inline private function set_alpha4(value:Float):Float
	{
		this.changed = true;
		return this._alpha4 = value;
	}
	
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
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._red1 = this._red2 = this._red3 = this._red4 = 1.0;
		this._green1 = this._green2 = this._green3 = this._green4 = 1.0;
		this._blue1 = this._blue2 = this._blue3 = this._blue4 = 1.0;
		this._alpha1 = this._alpha2 = this._alpha3 = this._alpha4 = 1.0;
		
		this._color1Final = this._color2Final = this._color3Final = this._color4Final = 0xffffffff;
		this._red1Final = this._red2Final = this._red3Final = this._red4Final = 1.0;
		this._green1Final = this._green2Final = this._green3Final = this._green4Final = 1.0;
		this._blue1Final = this._blue2Final = this._blue3Final = this._blue4Final = 1.0;
		this._alpha1Final = this._alpha2Final = this._alpha3Final = this._alpha4Final = 1.0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}