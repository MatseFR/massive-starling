package massive.text;

import massive.data.Frame;
import massive.text.internal.ImgConfig;
import massive.text.internal.LinePart;
import massive.text.internal.LinePartImg;
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
	
	public var imgConfigs(default, null):Array<ImgConfig> = new Array<ImgConfig>();
	
	private function get_numChars():Int { return this.imgConfigs.length; }
	
	public function new() 
	{
		super();
		this.isImg = true;
	}
	
	override public function clear():Void 
	{
		for (i in 0...this.imgConfigs.length)
		{
			this.imgConfigs[i].pool();
		}
		this.imgConfigs.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function getLinePart(style:FontStyle, fontScale:Float):LinePart
	{
		return LinePartImg.fromPool();
	}
	
}