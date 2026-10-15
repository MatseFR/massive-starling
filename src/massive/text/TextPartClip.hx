package massive.text;

import massive.animation.Animation;
import massive.text.internal.ClipConfig;
import massive.text.internal.LinePart;
import massive.text.internal.LinePartClip;
import massive.text.internal.TextPart;

/**
 * ...
 * @author Matse
 */
class TextPartClip extends TextPart 
{
	private static var _POOL:Array<TextPartClip> = new Array<TextPartClip>();
	
	public static function fromPool():TextPartClip
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextPartClip();
	}
	
	public var clipConfigs(default, null):Array<ClipConfig> = new Array<ClipConfig>();
	
	private function get_numChars():Int { return this.clipConfigs.length; }

	public function new() 
	{
		super();
		this.isClip = true;
	}
	
	override public function clear():Void 
	{
		for (i in 0...this.clipConfigs.length)
		{
			this.clipConfigs[i].pool();
		}
		this.clipConfigs.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function getLinePart(style:FontStyle, fontScale:Float):LinePart
	{
		return LinePartClip.fromPool();
	}
	
}