package massive.data;

/**
 * ...
 * @author Matse
 */
class VertexColorData 
{
	static private var _POOL:Array<VertexColorData> = new Array<VertexColorData>();
	
	static public function fromPool(red:Float = 1.0, green:Float = 1.0, blue:Float = 1.0, alpha:Float = 1.0, canInvertX:Bool = true, canInvertY:Bool = true):VertexColorData
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(red, green, blue, alpha, canInvertX, canInvertY);
		return new VertexColorData(red, green, blue, alpha, canInvertX, canInvertY);
	}
	
	public var canInvertX:Bool;
	public var canInvertY:Bool;
	
	/**
	   When this is set to true, all objects it is assigned to will recalculate their color or color offset values every frame
	   @default	false
	**/
	public var isChanging:Bool;
	public var isInPool(default, null):Bool;
	
	public var color(get, set):Int;
	public var color1(get, set):Int;
	public var color2(get, set):Int;
	public var color3(get, set):Int;
	public var color4(get, set):Int;
	
	public var red(get, set):Float;
	public var red1:Float;
	public var red2:Float;
	public var red3:Float;
	public var red4:Float;
	
	public var green(get, set):Float;
	public var green1:Float;
	public var green2:Float;
	public var green3:Float;
	public var green4:Float;
	
	public var blue(get, set):Float;
	public var blue1:Float;
	public var blue2:Float;
	public var blue3:Float;
	public var blue4:Float;
	
	public var alpha(get, set):Float;
	public var alpha1:Float;
	public var alpha2:Float;
	public var alpha3:Float;
	public var alpha4:Float;
	
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
		var r:Float = this.red1 > 1.0 ? 1.0 : this.red1 < 0.0 ? 0.0 : this.red1;
		var g:Float = this.green1 > 1.0 ? 1.0 : this.green1 < 0.0 ? 0.0 : this.green1;
		var b:Float = this.blue1 > 1.0 ? 1.0 : this.blue1 < 0.0 ? 0.0 : this.blue1;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color1(value:Int):Int
	{
		this.red1 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.green1 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blue1 = (value & 0xFF) / 255.0;
		return value;
	}
	
	private function get_color2():Int
	{
		var r:Float = this.red2 > 1.0 ? 1.0 : this.red2 < 0.0 ? 0.0 : this.red2;
		var g:Float = this.green2 > 1.0 ? 1.0 : this.green2 < 0.0 ? 0.0 : this.green2;
		var b:Float = this.blue2 > 1.0 ? 1.0 : this.blue2 < 0.0 ? 0.0 : this.blue2;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color2(value:Int):Int
	{
		this.red2 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.green2 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blue2 = (value & 0xFF) / 255.0;
		return value;
	}
	
	private function get_color3():Int
	{
		var r:Float = this.red3 > 1.0 ? 1.0 : this.red3 < 0.0 ? 0.0 : this.red3;
		var g:Float = this.green3 > 1.0 ? 1.0 : this.green3 < 0.0 ? 0.0 : this.green3;
		var b:Float = this.blue3 > 1.0 ? 1.0 : this.blue3 < 0.0 ? 0.0 : this.blue3;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color3(value:Int):Int
	{
		this.red3 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.green3 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blue3 = (value & 0xFF) / 255.0;
		return value;
	}
	
	private function get_color4():Int
	{
		var r:Float = this.red4 > 1.0 ? 1.0 : this.red4 < 0.0 ? 0.0 : this.red4;
		var g:Float = this.green4 > 1.0 ? 1.0 : this.green4 < 0.0 ? 0.0 : this.green4;
		var b:Float = this.blue4 > 1.0 ? 1.0 : this.blue4 < 0.0 ? 0.0 : this.blue4;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color4(value:Int):Int
	{
		this.red4 = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.green4 = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blue4 = (value & 0xFF) / 255.0;
		return value;
	}
	
	private function get_red():Float { return this.red1; }
	private function set_red(value:Float):Float
	{
		return this.red1 = this.red2 = this.red3 = this.red4 = value;
	}
	
	private function get_green():Float { return this.green1; }
	private function set_green(value:Float):Float
	{
		return this.green1 = this.green2 = this.green3 = this.green4 = value;
	}
	
	private function get_blue():Float { return this.blue1; }
	private function set_blue(value:Float):Float
	{
		return this.blue1 = this.blue2 = this.blue3 = this.blue4 = value;
	}
	
	inline private function get_alpha():Float { return this.alpha1; }
	inline private function set_alpha(value:Float):Float
	{
		return this.alpha1 = this.alpha2 = this.alpha3 = this.alpha4 = value;
	}
	
	public function new(red:Float = 1.0, green:Float = 1.0, blue:Float = 1.0, alpha:Float = 1.0, canInvertX:Bool = true, canInvertY:Bool = true) 
	{
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
		this.canInvertX = canInvertX;
		this.canInvertY = canInvertY;
	}
	
	public function clear():Void
	{
		this.isChanging = false;
		this.red = this.green = this.blue = this.alpha = 1.0;
		this.canInvertX  = this.canInvertY = true;
	}
	
	public function pool():Void
	{
		if (this.isInPool) return;
		clear();
		_POOL[_POOL.length] = this;
		this.isInPool = true;
	}
	
	private function setFromPool(red:Float, green:Float, blue:Float, alpha:Float, canInvertX:Bool, canInvertY:Bool):VertexColorData
	{
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
		this.canInvertX = canInvertX;
		this.canInvertY = canInvertY;
		this.isInPool = false;
		return this;
	}
	
	public function clone(toVertexColor:VertexColorData = null):VertexColorData
	{
		if (toVertexColor == null) toVertexColor = VertexColorData.fromPool();
		
		toVertexColor.canInvertX = this.canInvertX;
		toVertexColor.canInvertY = this.canInvertY;
		
		toVertexColor.red1 = this.red1;
		toVertexColor.red2 = this.red2;
		toVertexColor.red3 = this.red3;
		toVertexColor.red4 = this.red4;
		
		toVertexColor.green1 = this.green1;
		toVertexColor.green2 = this.green2;
		toVertexColor.green3 = this.green3;
		toVertexColor.green4 = this.green4;
		
		toVertexColor.blue1 = this.blue1;
		toVertexColor.blue2 = this.blue2;
		toVertexColor.blue3 = this.blue3;
		toVertexColor.blue4 = this.blue4;
		
		toVertexColor.alpha1 = this.alpha1;
		toVertexColor.alpha2 = this.alpha2;
		toVertexColor.alpha3 = this.alpha3;
		toVertexColor.alpha4 = this.alpha4;
		
		return toVertexColor;
	}
	
}