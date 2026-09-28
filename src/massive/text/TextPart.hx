package massive.text;

/**
 * ...
 * @author Matse
 */
class TextPart 
{
	private static var _POOL:Array<TextPart> = new Array<TextPart>();
	
	public static function fromPool():TextPart
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextPart();
	}
	
	public var animationData:Dynamic;
	public var animationInData:Dynamic;
	public var animationOutData:Dynamic;
	public var format(get, set):TextFormat;
	public var formatData(get, set):Dynamic;
	public var numChars(get, never):Int;
	public var options(get, set):TextOptions;
	public var optionsData:Dynamic;
	public var text:String;
	
	private var _format:TextFormat = new TextFormat();
	private function get_format():TextFormat { return this._format; }
	private function set_format(value:TextFormat):TextFormat
	{
		if (value != null)
		{
			this._format.copyFrom(value);
			if (this._formatData != null) this._format.loadJson(this._formatData);
		}
		return value;
	}
	
	private var _formatData:Dynamic;
	private function get_formatData():Dynamic { return this._formatData; }
	private function set_formatData(value:Dynamic):Dynamic
	{
		if (value != null) this._format.loadJson(value);
		return this._formatData = value;
	}
	
	private function get_numChars():Int { return this.text == null ? 0 : this.text.length; }
	
	private var _options:TextOptions;
	private function get_options():TextOptions { return this._options; }
	private function set_options(value:TextOptions):TextOptions
	{
		if (value != null)
		{
			this._options.copyFrom(value);
			if (this.optionsData != null) this._options.loadJson(this.optionsData);
		}
		return value;
	}

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.animationData = this.animationInData = this.animationOutData = null;
		this.formatData = this.optionsData = null;
		this.text = null;
		this._format.clear();
		this._options.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}