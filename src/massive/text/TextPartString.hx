package massive.text;
import massive.text.internal.LinePart;
import massive.text.internal.LinePartString;
import massive.text.internal.TextPart;

/**
 * ...
 * @author Matse
 */
class TextPartString extends TextPart
{
	private static var _POOL:Array<TextPartString> = new Array<TextPartString>();
	
	public static function fromPool():TextPartString
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextPartString();
	}
	
	public var text:String;
	
	private function get_numChars():Int { return this.text == null ? 0 : this.text.length; }

	public function new() 
	{
		super();
		this.isText = true;
	}
	
	override public function clear():Void
	{
		this.text = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function getLinePart(style:FontStyle, fontScale:Float):LinePart
	{
		return LinePartString.fromPool(style, fontScale);
	}
	
}