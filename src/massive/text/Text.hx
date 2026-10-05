package massive.text;

/**
 * ...
 * @author Matse
 */
class Text 
{
	private static var _POOL:Array<Text> = new Array<Text>();
	
	public static function fromPool(format:TextFormat = null, options:TextOptions = null):Text
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(format, options);
		return new Text(format, options);
	}
	
	public var format(get, set):TextFormat;
	public var numChars(get, never):Int;
	public var numParts(get, never):Int;
	public var options(get, set):TextOptions;
	public var parts(default, null):Array<TextPart> = new Array<TextPart>();
	
	private var _format:TextFormat = new TextFormat();
	private function get_format():TextFormat { return this._format; }
	private function set_format(value:TextFormat):TextFormat
	{
		if (value == null) 
		{
			this._format.clear();
			return value;
		}
		this._format.copyFrom(value);
		if (this.parts.length != 0)
		{
			this.parts[0].format = this._format;
			for (i in 1...this.parts.length)
			{
				this.parts[i].format = this.parts[i - 1].format;
			}
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
	
	private var _options:TextOptions = new TextOptions();
	private function get_options():TextOptions { return this._options; }
	private function set_options(value:TextOptions):TextOptions
	{
		if (value == null)
		{
			this._options.clear();
			return value;
		}
		this._options.copyFrom(value);
		//for (i in 0...this.parts.length)
		//{
			//this.parts[i].options = this._options;
		//}
		return this._options;
	}
	
	public function new(format:TextFormat = null, options:TextOptions = null) 
	{
		this.format = format;
		this.options = options;
	}
	
	public function clear():Void
	{
		for (i in 0...this.parts.length)
		{
			this.parts[i].pool();
		}
		this.parts.resize(0);
		
		this._format.clear();
		this._options.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(format:TextFormat, options:TextOptions):Text
	{
		this.format = format;
		this.options = options;
		return this;
	}
	
	public function addPart(part:TextPart):Void
	{
		if (this.parts.length == 0)
		{
			part.format = this._format;
		}
		else
		{
			part.format = this.parts[this.parts.length - 1].format;
		}
		this.parts[this.parts.length] = part;
	}
	
	public function getPartAt(index:Int):TextPart
	{
		return this.parts[index];
	}
	
}