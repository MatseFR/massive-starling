package massive.text;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * ...
 * @author Matse
 */
class TextFormat extends EventDispatcher
{
	private static var _POOL:Array<TextFormat> = new Array<TextFormat>();
	
	public static function fromPool(font:String = null, style:String = null, size:Float = 0.0, color:Int = 0x0, hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER):TextFormat
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(font, style, size, color, hAlign, vAlign);
		return new TextFormat(font, style, size, color, hAlign, vAlign);
	}
	
	public var color(get, set):Int;
	public var colorOffset(get, set):Int;
	public var font(get, set):String;
	public var kerning(get, set):Bool;
	public var horizontalAlign(get, set):String;
	public var leading(get, set):Float;
	public var letterSpacing(get, set):Float;
	public var size(get, set):Float;
	public var style(get, set):String;
	public var verticalAlign(get, set):String;
	
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
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
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
		if (this._colorOffsetChanged && this._colorOffset == value) return value;
		this.redOffset = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.greenOffset = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blueOffset = (value & 0xFF) / 255.0;
		this._colorOffsetChanged = false;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._colorOffset = value;
	}
	
	private var _font:String;
	private inline function get_font():String { return this._font; }
	private function set_font(value:String):String
	{
		if (this._font == value) return value;
		this._font = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._font;
	}
	
	private var _kerning:Bool = true;
	private inline function get_kerning():Bool { return this._kerning; }
	private function set_kerning(value:Bool):Bool
	{
		if (this._kerning == value) return value;
		this._kerning = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._kerning;
	}
	
	private var _horizontalAlign:String;
	private inline function get_horizontalAlign():String { return this._horizontalAlign; }
	private function set_horizontalAlign(value:String):String
	{
		if (this._horizontalAlign == value) return value;
		this._horizontalAlign = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._horizontalAlign;
	}
	
	private var _leading:Float = 0.0;
	private inline function get_leading():Float { return this._leading; }
	private function set_leading(value:Float):Float
	{
		if (this._leading == value) return value;
		this._leading = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._leading;
	}
	
	private var _letterSpacing:Float = 0.0;
	private inline function get_letterSpacing():Float { return this._letterSpacing; }
	private function set_letterSpacing(value:Float):Float
	{
		if (this._letterSpacing == value) return value;
		this._letterSpacing = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._letterSpacing;
	}
	
	private var _size:Float;
	private inline function get_size():Float { return this._size; }
	private function set_size(value:Float):Float
	{
		if (this._size == value) return value;
		this._size = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._size;
	}
	
	private var _style:String;
	private inline function get_style():String { return this._style; }
	private function set_style(value:String):String
	{
		if (this._style == value) return value;
		this._style = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._style;
	}
	
	private var _verticalAlign:String;
	private inline function get_verticalAlign():String { return this._verticalAlign; }
	private function set_verticalAlign(value:String):String
	{
		if (this._verticalAlign == value) return value;
		this._verticalAlign = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._verticalAlign;
	}
	
	private var _red:Float = 1.0;
	private inline function get_red():Float { return this._red; }
	private function set_red(value:Float):Float
	{
		if (this._red == value) return value;
		this._red = value;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._red;
	}
	
	private var _green:Float = 1.0;
	private inline function get_green():Float { return this._green; }
	private function set_green(value:Float):Float
	{
		if (this._green == value) return value;
		this._green = value;
		this._colorChanged = true;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._green;
	}
	
	private var _blue:Float = 1.0;
	private inline function get_blue():Float { return this._blue; }
	private function set_blue(value:Float):Float
	{
		if (this._blue == value) return value;
		this._blue = value;
		this._colorChanged = true;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._blue;
	}
	
	private var _alpha:Float = 1.0;
	private inline function get_alpha():Float { return this._alpha; }
	private function set_alpha(value:Float):Float
	{
		if (this._alpha == value) return value;
		this._alpha = value;
		this._colorChanged = true;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._alpha;
	}
	
	private var _redOffset:Float = 0.0;
	private inline function get_redOffset():Float { return this._redOffset; }
	private function set_redOffset(value:Float):Float
	{
		if (this._redOffset == value) return value;
		this._redOffset = value;
		this._colorOffsetChanged = true;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._redOffset;
	}
	
	private var _greenOffset:Float = 0.0;
	private inline function get_greenOffset():Float { return this._greenOffset; }
	private function set_greenOffset(value:Float):Float
	{
		if (this._greenOffset == value) return value;
		this._greenOffset = value;
		this._colorOffsetChanged = true;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._greenOffset;
	}
	
	private var _blueOffset:Float = 0.0;
	private inline function get_blueOffset():Float { return this._blueOffset; }
	private function set_blueOffset(value:Float):Float
	{
		if (this._blueOffset == value) return value;
		this._blueOffset = value;
		this._colorOffsetChanged = true;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._blueOffset;
	}
	
	private var _alphaOffset:Float = 0.0;
	private inline function get_alphaOffset():Float { return this._alphaOffset; }
	private function set_alphaOffset(value:Float):Float
	{
		if (this._alphaOffset == value) return value;
		this._alphaOffset = value;
		this._colorOffsetChanged = true;
		if (this._eventsEnabled) dispatchEventWith(Event.CHANGE);
		return this._alphaOffset;
	}
	
	private var _colorChanged:Bool;
	private var _colorOffsetChanged:Bool;
	private var _eventsEnabled:Bool = true;

	public function new(font:String = null, style:String = null, size:Float = 0.0, color:Int = 0xffffff, hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER) 
	{
		super();
		setTo(font, style, size, color, hAlign, vAlign, false);
	}
	
	public function clear():Void
	{
		this._color = 0xffffff;
		this._colorOffset = 0x000000;
		this._leading = this._letterSpacing = 0.0;
		this._kerning = true;
		this._red = this._green = this._blue = this._alpha = 1.0;
		this._redOffset = this._greenOffset = this._blueOffset = this._alphaOffset = 0.0;
		
		this._colorChanged = false;
		this._colorOffsetChanged = false;
		this._eventsEnabled = true;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function loadJson(json:Dynamic, dispatchChangeEvent:Bool = true):Void
	{
		this._eventsEnabled = false;
		
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
		if (json.alphaOffset != null) this._alphaOffset = json.alphaOffset;
		
		this._eventsEnabled = true;
		
		if (dispatchChangeEvent) dispatchEventWith(Event.CHANGE);
	}
	
	public function clone(toFormat:TextFormat = null, dispatchChangeEvent:Bool = true):TextFormat
	{
		if (toFormat == null)
		{
			toFormat = fromPool(this.font, this.style, this.size, this.color, this.horizontalAlign, this.verticalAlign);
			
			toFormat._eventsEnabled = false;
			
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
			
			toFormat._eventsEnabled = true;
		}
		else
		{
			toFormat.copyFrom(this, dispatchChangeEvent);
		}
		
		return toFormat;
	}
	
	public function copyFrom(format:TextFormat, dispatchChangeEvent:Bool = true):Void
	{
		this._eventsEnabled = false;
		
		this.font = format._font;
		this.style = format._style;
		this.size = format._size;
		this.kerning = format._kerning;
		this.leading = format._leading;
		this.letterSpacing = format._letterSpacing;
		this.horizontalAlign = format._horizontalAlign;
		this.verticalAlign = format._verticalAlign;
		
		this.red = format._red;
		this.green = format._green;
		this.blue = format._blue;
		this.alpha = format._alpha;
		
		this.redOffset = format._redOffset;
		this.greenOffset = format._greenOffset;
		this.blueOffset = format._blueOffset;
		this.alphaOffset = format._alphaOffset;
		
		this._eventsEnabled = true;
		
		if (dispatchChangeEvent) dispatchEventWith(Event.CHANGE);
	}
	
	public function setTo(font:String = null, style:String = null, size:Float = 0.0, color:Int = 0xffffff, hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER, dispatchChangeEvent:Bool = true):Void
	{
		this._eventsEnabled = false;
		
		this.font = font;
		this.style = style;
		this.size = size;
		this.color = color;
		this.horizontalAlign = hAlign;
		this.verticalAlign = vAlign;
		
		this._eventsEnabled = true;
		
		if (dispatchChangeEvent) dispatchEventWith(Event.CHANGE);
	}
	
	public function setColor(red:Float, green:Float, blue:Float, alpha:Float, dispatchChangeEvent:Bool = true):Void
	{
		this._eventsEnabled = false;
		
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
		
		this._eventsEnabled = true;
		
		if (dispatchChangeEvent) dispatchEventWith(Event.CHANGE);
	}
	
	public function setColorOffset(red:Float, green:Float, blue:Float, alpha:Float, dispatchChangeEvent:Bool = true):Void
	{
		this._eventsEnabled = false;
		
		this.redOffset = red;
		this.greenOffset = green;
		this.blueOffset = blue;
		this.alphaOffset = alpha;
		
		this._eventsEnabled = true;
		
		if (dispatchChangeEvent) dispatchEventWith(Event.CHANGE);
	}
	
	private function setFromPool(font:String, style:String, size:Float, color:Int, hAlign:String, vAlign:String):TextFormat
	{
		setTo(font, style, size, color, hAlign, vAlign, false);
		return this;
	}
	
}