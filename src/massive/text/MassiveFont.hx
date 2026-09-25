package massive.text;
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class MassiveFont 
{
	public var baseline:Float;
	public var defaultStyle(get, set):FontStyle;
	public var hyphenChar(get, set):String;
	public var hyphenCharID(get, set):Int;
	public var lineHeight(default, null):Float;
	public var name(default, null):String;
	public var size(default, null):Float;
	
	private var _defaultStyle:FontStyle;
	private function get_defaultStyle():FontStyle { return this._defaultStyle; }
	private function set_defaultStyle(value:FontStyle):FontStyle
	{
		this._defaultStyle = value;
		this.baseline = this._defaultStyle.baseline;
		this.lineHeight = this._defaultStyle.lineHeight;
		this.size = this._defaultStyle.size;
		
		return this._defaultStyle;
	}
	
	private var _hyphenChar:String;
	private function get_hyphenChar():String { return this._hyphenChar; }
	private function set_hyphenChar(value:String):String
	{
		this._hyphenChar = value;
		return this._hyphenChar;
	}
	
	private var _hyphenCharID:Int = MassiveText.CHAR_HYPHEN;
	private function get_hyphenCharID():Int { return this._hyphenCharID; }
	private function set_hyphenCharID(value:Int):Int
	{
		this._hyphenCharID = value;
		return this._hyphenCharID;
	}
	
	private var _styleMap:Map<String, FontStyle> = new Map<String, FontStyle>();
	
	public function new(name:String)
	{
		this.name = name;
	}
	
	public function createFontStyle(name:String = "default", texture:Texture = null, fontData:Dynamic = null):FontStyle
	{
		var fontStyle:FontStyle = new FontStyle(name, texture, fontData);
		addFontStyle(fontStyle);
		return fontStyle;
	}
	
	public function addFontStyle(fontStyle:FontStyle):Void
	{
		this._styleMap.set(fontStyle.name, fontStyle);
		if (this._defaultStyle == null) this.defaultStyle = fontStyle;
	}
	
	public function getFontStyle(name:String):FontStyle
	{
		var style:FontStyle = this._styleMap.get(name);
		if (style == null) return this.defaultStyle;
		return style;
	}
	
}