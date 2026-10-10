package massive.text;

import massive.data.Frame;
import massive.text.internal.TextPart;

/**
 * ...
 * @author Matse
 */
class TextPartImg extends TextPart 
{
	private static var _POOL:Array<TextPartImg> = new Array<TextPartImg>();
	
	public static function fromPool():TextPartImg
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextPartImg();
	}
	
	public var frames(default, null):Array<Frame> = new Array<Frame>();
	
	private function get_numChars():Int { return this.frames.length; }
	
	public function new() 
	{
		super();
		this.isImg = true;
	}
	
	override public function clear():Void 
	{
		this.frames.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}