package massive.text;

import massive.animation.Animation;
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
	
	public var animations(default, null):Array<Animation> = new Array<Animation>();
	
	private function get_numChars():Int { return this.animations.length; }

	public function new() 
	{
		super();
		this.isClip = true;
	}
	
	override public function clear():Void 
	{
		this.animations.resize(0);
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
}