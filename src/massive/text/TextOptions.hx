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
	
	public static function fromPool(hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER, wordWrap:Bool = true, hyphenation:Bool = false, letterSpreading:Bool = true):TextOptions
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(hAlign, vAlign, wordWrap, hyphenation, letterSpreading);
		return new TextOptions(hAlign, vAlign, wordWrap, hyphenation, letterSpreading);
	}
	
	public var autoSize(get, set):String;
	public var horizontalAlign(get, set):String;
	public var hyphenation(get, set):Bool;
	public var hyphenationMinLength(get, set):Int;
	public var hyphenationMinRatio(get, set):Float;
	public var intPositions(get, set):Bool;
	public var leading(get, set):Float;
	public var letterSpreading(get, set):Bool;
	public var letterSpreadingAllowIrregular(get, set):Bool;
	public var letterSpreadingMax(get, set):Float;
	public var letterSpreadingSpaceRatio(get, set):Float;
	public var padding(get, set):Float;
	public var paddingLeft(get, set):Float;
	public var paddingRight(get, set):Float;
	public var paddingTop(get, set):Float;
	public var paddingBottom(get, set):Float;
	public var restrictImageHeightToFontSize(get, set):Bool;
	public var restrictImageHeightOverflow(get, set):Float;
	public var uniformLineHeight(get, set):Bool;
	public var verticalAlign(get, set):String;
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
	
	private var _horizontalAlign:String;
	private inline function get_horizontalAlign():String { return this._horizontalAlign; }
	private function set_horizontalAlign(value:String):String
	{
		if (this._horizontalAlign == value) return value;
		this._horizontalAlign = value;
		dispatchEventWith(Event.CHANGE);
		return this._horizontalAlign;
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
	
	private var _hyphenationMinRatio:Float = 0.05;
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
	
	private var _leading:Float = 0.0;
	private inline function get_leading():Float { return this._leading; }
	private function set_leading(value:Float):Float
	{
		if (this._leading == value) return value;
		this._leading = value;
		dispatchEventWith(Event.CHANGE);
		return this._leading;
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
	
	private var _letterSpreadingAllowIrregular:Bool;
	private inline function get_letterSpreadingAllowIrregular():Bool { return this._letterSpreadingAllowIrregular; }
	private function set_letterSpreadingAllowIrregular(value:Bool):Bool
	{
		if (this._letterSpreadingAllowIrregular == value) return value;
		this._letterSpreadingAllowIrregular = value;
		dispatchEventWith(Event.CHANGE);
		return this._letterSpreadingAllowIrregular;
	}
	
	private var _letterSpreadingMax:Float = 0.0;
	private inline function get_letterSpreadingMax():Float { return this._letterSpreadingMax; }
	private function set_letterSpreadingMax(value:Float):Float
	{
		if (this._letterSpreadingMax == value) return value;
		this._letterSpreadingMax = value;
		dispatchEventWith(Event.CHANGE);
		return this._letterSpreadingMax;
	}
	
	private var _letterSpreadingSpaceRatio:Float = 3.0;
	private inline function get_letterSpreadingSpaceRatio():Float { return this._letterSpreadingSpaceRatio; }
	private function set_letterSpreadingSpaceRatio(value:Float):Float
	{
		if (this._letterSpreadingSpaceRatio == value) return value;
		this._letterSpreadingSpaceRatio = value;
		dispatchEventWith(Event.CHANGE);
		return this._letterSpreadingSpaceRatio;
	}
	
	private inline function get_padding():Float { return this._paddingLeft; }
	private function set_padding(value:Float):Float
	{
		this._paddingLeft = this._paddingRight = this._paddingTop = this._paddingBottom = value;
		dispatchEventWith(Event.CHANGE);
		return value;
	}
	
	private var _paddingLeft:Float = 0.0;
	private inline function get_paddingLeft():Float { return this._paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		if (this._paddingLeft == value) return value;
		this._paddingLeft = value;
		dispatchEventWith(Event.CHANGE);
		return this._paddingLeft;
	}
	
	private var _paddingRight:Float = 0.0;
	private inline function get_paddingRight():Float { return this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if (this._paddingRight == value) return value;
		this._paddingRight = value;
		dispatchEventWith(Event.CHANGE);
		return this._paddingRight;
	}
	
	private var _paddingTop:Float = 0.0;
	private inline function get_paddingTop():Float { return this._paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		if (this._paddingTop == value) return value;
		this._paddingTop = value;
		dispatchEventWith(Event.CHANGE);
		return this._paddingTop;
	}
	
	private var _paddingBottom:Float = 0.0;
	private inline function get_paddingBottom():Float { return this._paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		if (this._paddingBottom == value) return value;
		this._paddingBottom = value;
		dispatchEventWith(Event.CHANGE);
		return this._paddingBottom;
	}
	
	private var _restrictImageHeightToFontSize:Bool = true;
	private inline function get_restrictImageHeightToFontSize():Bool { return this._restrictImageHeightToFontSize; }
	private function set_restrictImageHeightToFontSize(value:Bool):Bool
	{
		if (this._restrictImageHeightToFontSize == value) return value;
		this._restrictImageHeightToFontSize = value;
		dispatchEventWith(Event.CHANGE);
		return this._restrictImageHeightToFontSize;
	}
	
	private var _restrictImageHeightOverflow:Float = 0.0;
	private inline function get_restrictImageHeightOverflow():Float { return this._restrictImageHeightOverflow; }
	private function set_restrictImageHeightOverflow(value:Float):Float
	{
		if (this._restrictImageHeightOverflow == value) return value;
		this._restrictImageHeightOverflow = value;
		dispatchEventWith(Event.CHANGE);
		return this._restrictImageHeightOverflow;
	}
	
	private var _uniformLineHeight:Bool = true;
	private inline function get_uniformLineHeight():Bool { return this._uniformLineHeight; }
	private function set_uniformLineHeight(value:Bool):Bool
	{
		if (this._uniformLineHeight == value) return value;
		this._uniformLineHeight = value;
		dispatchEventWith(Event.CHANGE);
		return this._uniformLineHeight;
	}
	
	private var _verticalAlign:String;
	private inline function get_verticalAlign():String { return this._verticalAlign; }
	private function set_verticalAlign(value:String):String
	{
		if (this._verticalAlign == value) return value;
		this._verticalAlign = value;
		dispatchEventWith(Event.CHANGE);
		return this._verticalAlign;
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

	public function new(hAlign:String = TextAlign.CENTER, vAlign:String = TextAlign.CENTER, wordWrap:Bool = true, hyphenation:Bool = false, letterSpreading:Bool = true) 
	{
		super();
		
		this._horizontalAlign = hAlign;
		this._verticalAlign = vAlign;
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
		this._leading = 0.0;
		this._letterSpreadingAllowIrregular = false;
		this._letterSpreadingMax = 0.0;
		this._letterSpreadingSpaceRatio = 3.0;
		this._paddingLeft = this._paddingRight = this._paddingTop = this._paddingBottom = 0.0;
		this._restrictImageHeightToFontSize = true;
		this._restrictImageHeightOverflow = 0.0;
		this._uniformLineHeight = true;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function loadJson(json:Dynamic, dispatchChangeEvent:Bool = true):Void
	{
		if (json.autoSize != null) this._autoSize = json.autoSize;
		if (json.horizontalAlign != null) this._horizontalAlign = json.horizontalAlign;
		if (json.hyphenation != null) this._hyphenation = json.hyphenation;
		if (json.hyphenationMinLength != null) this._hyphenationMinLength = json.hyphenationMinLength;
		if (json.hyphenationMinRatio != null) this._hyphenationMinRatio = json.hyphenationMinRatio;
		if (json.intPositions != null) this._intPositions = json.intPositions;
		if (json.leading != null) this._leading = json.leading;
		if (json.letterSpreading != null) this._letterSpreading = json.letterSpreading;
		if (json.letterSpreadingAllowIrregular != null) this._letterSpreadingAllowIrregular = json.letterSpreadingAllowIrregular;
		if (json.letterSpreadingMax != null) this._letterSpreadingMax = json.letterSpreadingMax;
		if (json.letterSpreadingSpaceRatio != null) this._letterSpreadingSpaceRatio = json.letterSpreadingMinRatio;
		if (json.padding != null)
		{
			this._paddingLeft = this._paddingRight = this._paddingTop = this._paddingBottom = json.padding;
		}
		else
		{
			if (json.paddingLeft != null) this._paddingLeft = json.paddingLeft;
			if (json.paddingRight != null) this._paddingRight = json.paddingRight;
			if (json.paddingTop != null) this._paddingTop = json.paddingTop;
			if (json.paddingBottom != null) this._paddingBottom = json.paddingBottom;
		}
		if (json.restrictImageHeightToFontSize != null) this._restrictImageHeightToFontSize = json.restrictImageHeightToFontSize;
		if (json.restrictImageHeightOverflow != null) this._restrictImageHeightOverflow = json.restrictImageHeightOverflow;
		if (json.uniformLineHeight != null) this._uniformLineHeight = json.uniformLineHeight;
		if (json.verticalAlign != null) this._verticalAlign = json.verticalAlign;
		if (json.wordWrap != null) this._wordWrap = json.wordWrap;
		
		if (dispatchChangeEvent) dispatchEventWith(Event.CHANGE);
	}
	
	public function clone(toOptions:TextOptions = null, dispatchChangeEvent:Bool = true):TextOptions
	{
		if (toOptions == null)
		{
			toOptions = fromPool(this._horizontalAlign, this._verticalAlign, this._wordWrap, this._hyphenation, this._letterSpreading);
			toOptions._autoSize = this._autoSize;
			toOptions._hyphenationMinLength = this._hyphenationMinLength;
			toOptions._hyphenationMinRatio = this._hyphenationMinRatio;
			toOptions._intPositions = this._intPositions;
			toOptions._leading = this._leading;
			toOptions._letterSpreadingAllowIrregular = this._letterSpreadingAllowIrregular;
			toOptions._letterSpreadingMax = this._letterSpreadingMax;
			toOptions._letterSpreadingSpaceRatio = this._letterSpreadingSpaceRatio;
			toOptions._paddingLeft = this._paddingLeft;
			toOptions._paddingRight = this._paddingRight;
			toOptions._paddingTop = this._paddingTop;
			toOptions._paddingBottom = this._paddingBottom;
			toOptions._restrictImageHeightToFontSize = this._restrictImageHeightToFontSize;
			toOptions._restrictImageHeightOverflow = this._restrictImageHeightOverflow;
			toOptions._uniformLineHeight = this._uniformLineHeight;
		}
		else
		{
			toOptions.copyFrom(this, dispatchChangeEvent);
		}
		
		return toOptions;
	}
	
	public function copyFrom(options:TextOptions, dispatchChangeEvent:Bool = true):Void
	{
		this._autoSize = options._autoSize;
		this._horizontalAlign = options._horizontalAlign;
		this._hyphenation = options._hyphenation;
		this._hyphenationMinLength = options._hyphenationMinLength;
		this._hyphenationMinRatio = options._hyphenationMinRatio;
		this._intPositions = options._intPositions;
		this._leading = options._leading;
		this._letterSpreading = options._letterSpreading;
		this._letterSpreadingAllowIrregular = options._letterSpreadingAllowIrregular;
		this._letterSpreadingMax = options._letterSpreadingMax;
		this._letterSpreadingSpaceRatio = options._letterSpreadingSpaceRatio;
		this._paddingLeft = options._paddingLeft;
		this._paddingRight = options._paddingRight;
		this._paddingTop = options._paddingTop;
		this._paddingBottom = options._paddingBottom;
		this._restrictImageHeightToFontSize = options._restrictImageHeightToFontSize;
		this._restrictImageHeightOverflow = options._restrictImageHeightOverflow;
		this._uniformLineHeight = options._uniformLineHeight;
		this._verticalAlign = options._verticalAlign;
		this._wordWrap = options._wordWrap;
		
		if (dispatchChangeEvent) dispatchEventWith(Event.CHANGE);
	}
	
	private function setFromPool(hAlign:String, vAlign:String, wordWrap:Bool, hyphenation:Bool, letterSpreading:Bool):TextOptions
	{
		this._horizontalAlign = hAlign;
		this._verticalAlign = vAlign;
		this._wordWrap = wordWrap;
		this._hyphenation = hyphenation;
		this._letterSpreading = letterSpreading;
		return this;
	}
	
}