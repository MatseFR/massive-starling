package massive.text.internal;
import massive.data.Frame;

/**
 * ...
 * @author Matse
 */
abstract class ElementLocation 
{
	private static var _ARRAY_POOL:Array<Array<ElementLocation>> = new Array<Array<ElementLocation>>();
	private static var _ARRAY_OUT:Array<Array<ElementLocation>> = new Array<Array<ElementLocation>>();
	
	private static var _array:Array<ElementLocation>;
	
	public static function arrayFromPool():Array<ElementLocation>
	{
		_array = _ARRAY_POOL.length != 0 ? _ARRAY_POOL.pop() : new Array<ElementLocation>();
		return _ARRAY_OUT[_ARRAY_OUT.length] = _array;
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _ARRAY_OUT.length;
		for (i in 0...count)
		{
			_array = _ARRAY_OUT[i];
			_array.resize(0);
			_ARRAY_POOL[_ARRAY_POOL.length] = _array;
		}
		_ARRAY_OUT.resize(0);
		
		ClipLocation.rechargePool();
		GlyphLocation.rechargePool();
		ImgLocation.rechargePool();
	}
	
	public var charID(default, null):Int;
	public var frame(default, null):Frame;
	public var height(default, null):Float;
	public var index:Int;
	public var isGraphic:Bool;
	public var isHyphen:Bool;
	public var isNumber:Bool;
	public var isPunctuation:Bool;
	public var isSpace:Bool;
	public var isSpecial:Bool;
	public var isVowel:Bool;
	public var linePart:LinePart;
	public var originalHeight(default, null):Float;
	public var originalWidth(default, null):Float;
	public var originalXAdvance(default, null):Float;
	public var originalXOffset(default, null):Float;
	public var originalYOffset(default, null):Float;
	public var scale(get, set):Float;
	public var textPart:TextPartLayoutResult;
	public var width(default, null):Float;
	public var x:Float;
	public var y:Float;
	public var xAdvance(default, null):Float;
	public var xOffset(default, null):Float;
	public var yOffset(default, null):Float;
	
	private var _scale:Float = 1.0;
	private inline function get_scale():Float { return this._scale; }
	private function set_scale(value:Float):Float
	{
		if (this._scale == value) return value;
		this.width = this.originalWidth * value;
		this.height = this.originalHeight * value;
		this.xAdvance = this.originalXAdvance * value;
		this.xOffset = this.originalXOffset * value;
		this.yOffset = this.originalYOffset * value;
		return this._scale = value;
	}
	
	public function new() 
	{
		
	}
	
}