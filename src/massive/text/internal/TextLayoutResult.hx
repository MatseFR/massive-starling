package massive.text.internal;
import massive.display.Img;
import massive.display.MassiveDisplay;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class TextLayoutResult 
{
	private static var _POOL:Array<TextLayoutResult> = new Array<TextLayoutResult>();
	
	public static function fromPool():TextLayoutResult
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextLayoutResult();
	}
	
	public var parts(default, null):Array<TextPartLayoutResult> = new Array<TextPartLayoutResult>();
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		for (i in 0...this.parts.length)
		{
			this.parts[i].pool();
		}
		this.parts.resize(0);
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addPart(part:TextPartLayoutResult):Void
	{
		this.parts[this.parts.length] = part;
	}
	
	#if flash
	public function getImages(display:MassiveDisplay, imgs:Vector<Img> = null):Vector<Img>
	#else
	public function getImages(display:MassiveDisplay, imgs:Array<Img> = null):Array<Img>
	#end
	{
		for (i in 0...this.parts.length)
		{
			this.parts[i].getImages(display, imgs);
		}
		return imgs;
	}
	
}