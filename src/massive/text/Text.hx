package massive.text;

/**
 * ...
 * @author Matse
 */
class Text 
{
	private static var _POOL:Array<Text> = new Array<Text>();
	
	public static function fromPool():Text
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new Text();
	}
	
	public var format(get, set):TextFormat;
	public var numChars(get, never):Int;
	public var numParts(get, never):Int;
	public var options(get, set):TextOptions;
	public var parts(default, null):Array<TextPart> = new Array<TextPart>();
	
	private var _format:TextFormat;
	private function get_format():TextFormat { return this._format; }
	private function set_format(value:TextFormat):TextFormat
	{
		this._format = value;
		for (i in 0...this.parts.length)
		{
			this.parts[i].format = this._format;
		}
		return this._format;
	}
	
	private function get_numChars():Int
	{
		var count:Int = 0;
		for (i in 0...this.parts.length)
		{
			count += this.parts[i].numChars;
		}
		return count;
	}
	
	private function get_numParts():Int { return this.parts.length; }
	
	private var _options:TextOptions;
	private function get_options():TextOptions { return this._options; }
	private function set_options(value:TextOptions):TextOptions
	{
		this._options = value;
		//for (i in 0...this.parts.length)
		//{
			//this.parts[i].options = this._options;
		//}
		return this._options;
	}
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		for (i in 0...this.parts.length)
		{
			this.parts[i].pool();
		}
		this.parts.resize(0);
		
		if (this._format != null)
		{
			this._format.pool();
			this._format = null;
		}
		
		if (this._options != null)
		{
			this._options.pool();
			this._options = null;
		}
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addPart(part:TextPart):Void
	{
		if (this._format != null) part.format = this._format;
		this.parts[this.parts.length] = part;
	}
	
	public function getPartAt(index:Int):TextPart
	{
		return this.parts[index];
	}
	
}