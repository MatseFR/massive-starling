package massive.text;

/**
 * ...
 * @author Matse
 */
class TextFormat 
{
	private static var _POOL:Array<TextFormat> = new Array<TextFormat>();
	
	public static function fromPool(font:String = null, style:String = null, size:Float = 0.0, color:Int = 0x0, hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER):TextFormat
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(font, style, size, color, hAlign, vAlign);
		return new TextFormat(font, style, size, color, hAlign, vAlign);
	}
	
	public var color(get, set):Int;
	public var colorOffset(get, set):Int;
	public var font:String;
	public var kerning:Bool = true;
	public var horizontalAlign:String;
	public var leading:Float = 0.0;
	public var letterSpacing:Float = 0.0;
	public var size:Float;
	public var style:String;
	public var verticalAlign:String;
	
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
	
	public var red:Float;
	public var green:Float;
	public var blue:Float;
	public var alpha:Float = 1.0;
	
	public var redOffset:Float = 0.0;
	public var greenOffset:Float = 0.0;
	public var blueOffset:Float = 0.0;
	public var alphaOffset:Float = 0.0;

	public function new(font:String = null, style:String = null, size:Float = 0.0, color:Int = 0x0, hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER) 
	{
		setTo(font, style, size, color, hAlign, vAlign);
	}
	
	public function clear():Void
	{
		this.font = this.style = null;
		this.size = this.leading = this.letterSpacing = 0.0;
		this.kerning = true;
		this.horizontalAlign = this.verticalAlign = TextAlign.CENTER;
		this.red = this.green = this.blue = this.alpha = 1.0;
		this.redOffset = this.greenOffset = this.blueOffset = this.alphaOffset = 0.0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function loadJson(json:Dynamic):Void
	{
		if (json.font != null) this.font = json.font;
		if (json.style != null) this.style = json.style;
		if (json.kerning != null) this.kerning = json.kerning;
		if (json.leading != null) this.leading = json.leading;
		if (json.letterSpacing != null) this.letterSpacing = json.letterSpacing;
		if (json.horizontalAlign != null) this.horizontalAlign = json.horizontalAlign;
		if (json.verticalAlign != null) this.verticalAlign = json.verticalAlign;
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
		if (json.alphaOffset != null) this.alphaOffset = json.alphaOffset;
	}
	
	public function clone(toFormat:TextFormat = null):TextFormat
	{
		if (toFormat == null)
		{
			toFormat = fromPool(this.font, this.style, this.size, this.color, this.horizontalAlign, this.verticalAlign);
			toFormat.kerning = this.kerning;
			toFormat.leading = this.leading;
			toFormat.letterSpacing = this.letterSpacing;
			toFormat.red = this.red;
			toFormat.green = this.green;
			toFormat.blue = this.blue;
			toFormat.alpha = this.alpha;
			toFormat.redOffset = this.redOffset;
			toFormat.greenOffset = this.greenOffset;
			toFormat.blueOffset = this.blueOffset;
			toFormat.alphaOffset = this.alphaOffset;
		}
		else
		{
			toFormat.copyFrom(this);
		}
		
		return toFormat;
	}
	
	public function copyFrom(format:TextFormat):Void
	{
		this.font = format.font;
		this.style = format.style;
		this.size = format.size;
		this.kerning = format.kerning;
		this.leading = format.leading;
		this.letterSpacing = format.letterSpacing;
		this.horizontalAlign = format.horizontalAlign;
		this.verticalAlign = format.verticalAlign;
		
		this.red = format.red;
		this.green = format.green;
		this.blue = format.blue;
		this.alpha = format.alpha;
		
		this.redOffset = format.redOffset;
		this.greenOffset = format.greenOffset;
		this.blueOffset = format.blueOffset;
		this.alphaOffset = format.alphaOffset;
	}
	
	public function setTo(font:String = null, style:String = null, size:Float = 0.0, color:Int = 0x0, hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER):Void
	{
		this.font = font;
		this.style = style;
		this.size = size;
		this.color = color;
		this.horizontalAlign = hAlign;
		this.verticalAlign = vAlign;
	}
	
	private function setFromPool(font:String, style:String, size:Float, color:Int, hAlign:String, vAlign:String):TextFormat
	{
		setTo(font, style, size, color, hAlign, vAlign);
		return this;
	}
	
}