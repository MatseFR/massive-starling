package massive.text.internal;

/**
 * ...
 * @author Matse
 */
abstract class TextPart 
{
	public var animationData:Dynamic;
	public var animationInData:Dynamic;
	public var animationOutData:Dynamic;
	public var format(get, set):TextFormat;
	public var formatData(get, set):Dynamic;
	public var isClip(default, null):Bool;
	public var isImg(default, null):Bool;
	public var isText(default, null):Bool;
	public var numChars(get, never):Int;
	
	private var _format:TextFormat = new TextFormat();
	private inline function get_format():TextFormat { return this._format; }
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
	private inline function get_formatData():Dynamic { return this._formatData; }
	private function set_formatData(value:Dynamic):Dynamic
	{
		if (value != null) this._format.loadJson(value);
		return this._formatData = value;
	}
	
	abstract private function get_numChars():Int;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._format.clear();
		this.animationData = this.animationInData = this.animationOutData = null;
	}
	
	abstract public function pool():Void;
	
}