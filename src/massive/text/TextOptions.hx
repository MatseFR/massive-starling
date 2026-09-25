package massive.text;
import starling.text.TextFieldAutoSize;

/**
 * ...
 * @author Matse
 */
class TextOptions 
{
	private static var _POOL:Array<TextOptions> = new Array<TextOptions>();
	
	public static function fromPool(wordWrap:Bool = true, hyphenation:Bool = true, letterSpreading:Bool = true):TextOptions
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(wordWrap, hyphenation, letterSpreading);
		return new TextOptions(wordWrap, hyphenation, letterSpreading);
	}
	
	public var autoSize:String = TextFieldAutoSize.NONE;
	public var hyphenation:Bool;
	public var hyphenationMinLength:Int = 7;
	public var hyphenationMinRatio:Float = 0.1;
	public var intPositions:Bool = true;
	public var letterSpreading:Bool;
	public var letterSpreadingMax:Float = 2.0;
	public var letterSpreadingMinRatio:Float = 0.1;
	public var padding:Float = 0.0;
	public var wordWrap:Bool;

	public function new(wordWrap:Bool = true, hyphenation:Bool = true, letterSpreading:Bool = true) 
	{
		this.wordWrap = wordWrap;
		this.hyphenation = hyphenation;
		this.letterSpreading = letterSpreading;
	}
	
	public function clear():Void
	{
		this.autoSize = TextFieldAutoSize.NONE;
		this.hyphenation = true;
		this.hyphenationMinLength = 7;
		this.hyphenationMinRatio = 0.1;
		this.intPositions = true;
		this.letterSpreading = true;
		this.letterSpreadingMax = 2.0;
		this.letterSpreadingMinRatio = 0.1;
		this.padding = 0.0;
		this.wordWrap = true;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function loadJson(json:Dynamic):Void
	{
		if (json.autoSize != null) this.autoSize = json.autoSize;
		if (json.hyphenation != null) this.hyphenation = json.hyphenation;
		if (json.hyphenationMinLength != null) this.hyphenationMinLength = json.hyphenationMinLength;
		if (json.hyphenationMinRatio != null) this.hyphenationMinRatio = json.hyphenationMinRatio;
		if (json.intPositions != null) this.intPositions = json.intPositions;
		if (json.letterSpreading != null) this.letterSpreading = json.letterSpreading;
		if (json.letterSpreadingMax != null) this.letterSpreadingMax = json.letterSpreadingMax;
		if (json.letterSpreadingMinRatio != null) this.letterSpreadingMinRatio = json.letterSpreadingMinRatio;
		if (json.padding != null) this.padding = json.padding;
		if (json.wordWrap != null) this.wordWrap = json.wordWrap;
	}
	
	public function clone(toOptions:TextOptions = null):TextOptions
	{
		if (toOptions == null)
		{
			toOptions = fromPool(this.wordWrap, this.hyphenation, this.letterSpreading);
			toOptions.autoSize = this.autoSize;
			toOptions.hyphenationMinLength = this.hyphenationMinLength;
			toOptions.hyphenationMinRatio = this.hyphenationMinRatio;
			toOptions.intPositions = this.intPositions;
			toOptions.letterSpreadingMax = this.letterSpreadingMax;
			toOptions.letterSpreadingMinRatio = this.letterSpreadingMinRatio;
			toOptions.padding = this.padding;
		}
		else
		{
			toOptions.copyFrom(this);
		}
		
		return toOptions;
	}
	
	public function copyFrom(options:TextOptions):Void
	{
		this.autoSize = options.autoSize;
		this.hyphenation = options.hyphenation;
		this.hyphenationMinLength = options.hyphenationMinLength;
		this.hyphenationMinRatio = options.hyphenationMinRatio;
		this.intPositions = options.intPositions;
		this.letterSpreading = options.letterSpreading;
		this.letterSpreadingMax = options.letterSpreadingMax;
		this.letterSpreadingMinRatio = options.letterSpreadingMinRatio;
		this.padding = options.padding;
		this.wordWrap = options.wordWrap;
	}
	
	private function setFromPool(wordWrap:Bool, hyphenation:Bool, letterSpreading:Bool):TextOptions
	{
		this.wordWrap = wordWrap;
		this.hyphenation = hyphenation;
		this.letterSpreading = letterSpreading;
		return this;
	}
	
}