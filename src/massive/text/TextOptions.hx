package massive.text;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.text.TextFieldAutoSize;

/**
 * ...
 * @author Matse
 */
class TextOptions extends EventDispatcher
{
	private static var _POOL:Array<TextOptions> = new Array<TextOptions>();
	
	public static function fromPool(wordWrap:Bool = true, hyphenation:Bool = true, letterSpreading:Bool = true):TextOptions
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(wordWrap, hyphenation, letterSpreading);
		return new TextOptions(wordWrap, hyphenation, letterSpreading);
	}
	
	public var autoSize(get, set):String;
	public var hyphenation(get, set):Bool;
	public var hyphenationMinLength(get, set):Int;
	public var hyphenationMinRatio(get, set):Float;
	public var intPositions(get, set):Bool;
	public var letterSpreading(get, set):Bool;
	public var letterSpreadingMax(get, set):Float;
	public var letterSpreadingMinRatio(get, set):Float;
	public var padding(get, set):Float;
	public var wordWrap(get, set):Bool;
	
	private var _autoSize:String = TextFieldAutoSize.NONE;
	private inline function get_autoSize():String { return this._autoSize; }
	private function set_autoSize(value:String):String
	{
		if (this._autoSize == value) return value;
		this._autoSize = value;
		dispatchEventWith(Event.CHANGE);
		return this._autoSize;
	}
	
	private var _hyphenation:Bool;
	private inline function get_hyphenation():Bool { return this._hyphenation; }
	private function set_hyphenation(value:Bool):Bool
	{
		if (this._hyphenation == value) return value;
		this._hyphenation = value;
		dispatchEventWith(Event.CHANGE);
		return this._hyphenation;
	}
	
	private var _hyphenationMinLength:Int = 7;
	private inline function get_hyphenationMinLength():Int { return this._hyphenationMinLength; }
	private function set_hyphenationMinLength(value:Int):Int
	{
		if (this._hyphenationMinLength == value) return value;
		this._hyphenationMinLength = value;
		dispatchEventWith(Event.CHANGE);
		return this._hyphenationMinLength;
	}
	
	private var _hyphenationMinRatio:Float = 0.1;
	private inline function get_hyphenationMinRatio():Float { return this._hyphenationMinRatio; }
	private function set_hyphenationMinRatio(value:Float):Float
	{
		if (this._hyphenationMinRatio == value) return value;
		this._hyphenationMinRatio = value;
		dispatchEventWith(Event.CHANGE);
		return this._hyphenationMinRatio;
	}
	
	private var _intPositions:Bool = true;
	private inline function get_intPositions():Bool { return this._intPositions; }
	private function set_intPositions(value:Bool):Bool
	{
		if (this._intPositions == value) return value;
		this._intPositions = value;
		dispatchEventWith(Event.CHANGE);
		return this._intPositions;
	}
	
	private var _letterSpreading:Bool;
	private inline function get_letterSpreading():Bool { return this._letterSpreading; }
	private function set_letterSpreading(value:Bool):Bool
	{
		if (this._letterSpreading == value) return value;
		this._letterSpreading = value;
		dispatchEventWith(Event.CHANGE);
		return this._letterSpreading;
	}
	
	private var _letterSpreadingMax:Float = 2.0;
	private inline function get_letterSpreadingMax():Float { return this._letterSpreadingMax; }
	private function set_letterSpreadingMax(value:Float):Float
	{
		if (this._letterSpreadingMax == value) return value;
		this._letterSpreadingMax = value;
		dispatchEventWith(Event.CHANGE);
		return this._letterSpreadingMax;
	}
	
	private var _letterSpreadingMinRatio:Float = 0.1;
	private inline function get_letterSpreadingMinRatio():Float { return this._letterSpreadingMinRatio; }
	private function set_letterSpreadingMinRatio(value:Float):Float
	{
		if (this._letterSpreadingMinRatio == value) return value;
		this._letterSpreadingMinRatio = value;
		dispatchEventWith(Event.CHANGE);
		return this._letterSpreadingMinRatio;
	}
	
	private var _padding:Float = 0.0;
	private inline function get_padding():Float { return this._padding; }
	private function set_padding(value:Float):Float
	{
		if (this._padding == value) return value;
		this._padding = value;
		dispatchEventWith(Event.CHANGE);
		return this._padding;
	}
	
	private var _wordWrap:Bool;
	private inline function get_wordWrap():Bool { return this._wordWrap; }
	private function set_wordWrap(value:Bool):Bool
	{
		if (this._wordWrap == value) return value;
		this._wordWrap = value;
		dispatchEventWith(Event.CHANGE);
		return this._wordWrap;
	}

	public function new(wordWrap:Bool = true, hyphenation:Bool = true, letterSpreading:Bool = true) 
	{
		super();
		
		this._wordWrap = wordWrap;
		this._hyphenation = hyphenation;
		this._letterSpreading = letterSpreading;
	}
	
	public function clear():Void
	{
		this._autoSize = TextFieldAutoSize.NONE;
		this._hyphenationMinLength = 7;
		this._hyphenationMinRatio = 0.1;
		this._intPositions = true;
		this._letterSpreadingMax = 2.0;
		this._letterSpreadingMinRatio = 0.1;
		this._padding = 0.0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function loadJson(json:Dynamic):Void
	{
		if (json.autoSize != null) this._autoSize = json.autoSize;
		if (json.hyphenation != null) this._hyphenation = json.hyphenation;
		if (json.hyphenationMinLength != null) this._hyphenationMinLength = json.hyphenationMinLength;
		if (json.hyphenationMinRatio != null) this._hyphenationMinRatio = json.hyphenationMinRatio;
		if (json.intPositions != null) this._intPositions = json.intPositions;
		if (json.letterSpreading != null) this._letterSpreading = json.letterSpreading;
		if (json.letterSpreadingMax != null) this._letterSpreadingMax = json.letterSpreadingMax;
		if (json.letterSpreadingMinRatio != null) this._letterSpreadingMinRatio = json.letterSpreadingMinRatio;
		if (json.padding != null) this._padding = json.padding;
		if (json.wordWrap != null) this._wordWrap = json.wordWrap;
	}
	
	public function clone(toOptions:TextOptions = null):TextOptions
	{
		if (toOptions == null)
		{
			toOptions = fromPool(this._wordWrap, this._hyphenation, this._letterSpreading);
			toOptions._autoSize = this._autoSize;
			toOptions._hyphenationMinLength = this._hyphenationMinLength;
			toOptions._hyphenationMinRatio = this._hyphenationMinRatio;
			toOptions._intPositions = this._intPositions;
			toOptions._letterSpreadingMax = this._letterSpreadingMax;
			toOptions._letterSpreadingMinRatio = this._letterSpreadingMinRatio;
			toOptions._padding = this._padding;
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