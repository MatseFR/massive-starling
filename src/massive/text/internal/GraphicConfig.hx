package massive.text.internal;

/**
 * ...
 * @author Matse
 */
abstract class GraphicConfig 
{
	public var color(get, set):Int;
	public var colorOffset(get, set):Int;
	public var scale:Float = 1.0;
	
	public var red(get, set):Float;
	public var green(get, set):Float;
	public var blue(get, set):Float;
	public var alpha(get, set):Float;
	
	public var redOffset(get, set):Float;
	public var greenOffset(get, set):Float;
	public var blueOffset(get, set):Float;
	public var alphaOffset(get, set):Float;
	
	private var _color:Int = 0xffffff;
	private function get_color():Int
	{
		if (!this._colorChanged) return this._color;
		var r:Float = this._red > 1.0 ? 1.0 : this._red < 0.0 ? 0.0 : this._red;
		var g:Float = this._green > 1.0 ? 1.0 : this._green < 0.0 ? 0.0 : this._green;
		var b:Float = this._blue > 1.0 ? 1.0 : this._blue < 0.0 ? 0.0 : this._blue;
		this._colorChanged = false;
		return this._color = Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color(value:Int):Int
	{
		if (!this._colorChanged && this._color == value) return value;
		this._red = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._green = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blue = (value & 0xFF) / 255.0;
		this._colorChanged = false;
		return this._color = value;
	}
	
	private var _colorOffset:Int = 0x000000;
	private function get_colorOffset():Int
	{
		if (!this._colorOffsetChanged) return this._colorOffset;
		var r:Float = this._redOffset > 1.0 ? 1.0 : this._redOffset < 0.0 ? 0.0 : this._redOffset;
		var g:Float = this._greenOffset > 1.0 ? 1.0 : this._greenOffset < 0.0 ? 0.0 : this._greenOffset;
		var b:Float = this._blueOffset > 1.0 ? 1.0 : this._blueOffset < 0.0 ? 0.0 : this._blueOffset;
		this._colorOffsetChanged = false;
		return this._colorOffset = Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset(value:Int):Int
	{
		if (!this._colorOffsetChanged && this._colorOffset == value) return value;
		this.redOffset = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.greenOffset = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blueOffset = (value & 0xFF) / 255.0;
		this._colorOffsetChanged = false;
		return this._colorOffset = value;
	}
	
	private var _red:Float = 1.0;
	private inline function get_red():Float { return this._red; }
	private function set_red(value:Float):Float
	{
		if (this._red == value) return value;
		this._red = value;
		this._colorChanged = true;
		return this._red;
	}
	
	private var _green:Float = 1.0;
	private inline function get_green():Float { return this._green; }
	private function set_green(value:Float):Float
	{
		if (this._green == value) return value;
		this._green = value;
		this._colorChanged = true;
		return this._green;
	}
	
	private var _blue:Float = 1.0;
	private inline function get_blue():Float { return this._blue; }
	private function set_blue(value:Float):Float
	{
		if (this._blue == value) return value;
		this._blue = value;
		this._colorChanged = true;
		return this._blue;
	}
	
	private var _alpha:Float = 1.0;
	private inline function get_alpha():Float { return this._alpha; }
	private function set_alpha(value:Float):Float
	{
		if (this._alpha == value) return value;
		this._alpha = value;
		return this._alpha;
	}
	
	private var _redOffset:Float = 0.0;
	private inline function get_redOffset():Float { return this._redOffset; }
	private function set_redOffset(value:Float):Float
	{
		if (this._redOffset == value) return value;
		this._redOffset = value;
		this._colorOffsetChanged = true;
		return this._redOffset;
	}
	
	private var _greenOffset:Float = 0.0;
	private inline function get_greenOffset():Float { return this._greenOffset; }
	private function set_greenOffset(value:Float):Float
	{
		if (this._greenOffset == value) return value;
		this._greenOffset = value;
		this._colorOffsetChanged = true;
		return this._greenOffset;
	}
	
	private var _blueOffset:Float = 0.0;
	private inline function get_blueOffset():Float { return this._blueOffset; }
	private function set_blueOffset(value:Float):Float
	{
		if (this._blueOffset == value) return value;
		this._blueOffset = value;
		this._colorOffsetChanged = true;
		return this._blueOffset;
	}
	
	private var _alphaOffset:Float = 0.0;
	private inline function get_alphaOffset():Float { return this._alphaOffset; }
	private function set_alphaOffset(value:Float):Float
	{
		if (this._alphaOffset == value) return value;
		this._alphaOffset = value;
		return this._alphaOffset;
	}
	
	private var _colorChanged:Bool;
	private var _colorOffsetChanged:Bool;
	
	public function new(json:Dynamic = null) 
	{
		if (json != null) fromJson(json);
	}
	
	public function clear():Void
	{
		this._color = 0xffffff;
		this._colorOffset = 0x000000;
		this.scale = 1.0;
		this._red = this._green = this._blue = this._alpha = 1.0;
		this._redOffset = this._greenOffset = this._blueOffset = this._alphaOffset = 0.0;
		
		this._colorChanged = false;
		this._colorOffsetChanged = false;
	}
	
	abstract public function pool():Void;
	
	public function fromJson(json:Dynamic):Void
	{
		if (json.scale != null)
		{
			this.scale = json.scale;
		}
		if (json.color != null)
		{
			this.color = json.color;
		}
		else
		{
			if (json.red != null) this.red = json.red;
			if (json.green != null) this.green = json.green;
			if (json.blue != null) this.blue = json.blue;
		}
		if (json.alpha != null) this.alpha = json.alpha;
		if (json.colorOffset != null)
		{
			this.colorOffset = json.colorOffset;
		}
		else
		{
			if (json.redOffset != null) this.redOffset = json.redOffset;
			if (json.greenOffset != null) this.greenOffset = json.greenOffset;
			if (json.blueOffset != null) this.blueOffset = json.blueOffset;
		}
		if (json.alphaOffset != null) this._alphaOffset = json.alphaOffset;
	}
	
}