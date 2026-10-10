package massive.text;
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
	
	//public var format(get, set):TextFormat;
	//public var formatData(get, set):Dynamic;
	//public var numChars(get, never):Int;
	public var text:String;
	
	//private var _format:TextFormat = new TextFormat();
	//private inline function get_format():TextFormat { return this._format; }
	//private function set_format(value:TextFormat):TextFormat
	//{
		//if (value != null)
		//{
			//this._format.copyFrom(value);
			//if (this._formatData != null) this._format.loadJson(this._formatData);
		//}
		//return value;
	//}
	//
	//private var _formatData:Dynamic;
	//private inline function get_formatData():Dynamic { return this._formatData; }
	//private function set_formatData(value:Dynamic):Dynamic
	//{
		//if (value != null) this._format.loadJson(value);
		//return this._formatData = value;
	//}
	
	private function get_numChars():Int { return this.text == null ? 0 : this.text.length; }

	public function new() 
	{
		super();
		this.isText = true;
	}
	
	override public function clear():Void
	{
		//this.formatData = null;
		this.text = null;
		//this._format.clear();
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}