package massive.text.internal;
import massive.text.internal.ElementLocation;

/**
 * ...
 * @author Matse
 */
class GlyphLocation extends ElementLocation
{
	private static var _POOL:Array<GlyphLocation> = new Array<GlyphLocation>();
	private static var _OUT:Array<GlyphLocation> = new Array<GlyphLocation>();
	
	private static var _instance:GlyphLocation;
	
	public static function fromPool(glyph:Glyph):GlyphLocation
	{
		_instance = _POOL.length != 0 ? _POOL.pop().setFromPool(glyph) : new GlyphLocation(glyph);
		return _OUT[_OUT.length] = _instance;
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_instance.frame = null;
			_instance.glyph = null;
			_instance.textPart = null;
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
	}
	
	#if debug
	public var char:String;
	#end
	//public var index:Int;
	//public var isHyphen:Bool;
	//public var isSpace:Bool;
	//public var isVowel:Bool;
	public var glyph:Glyph;
	//public var scale:Float;
	//public var textPart:TextPartLayoutResult;
	//public var x:Float;
	//public var y:Float;

	public function new(glyph:Glyph) 
	{
		super();
		this.glyph = glyph;
		//if (this.glyph != null)
		//{
			this.charID = glyph.charID;
			this.frame = glyph.frame;
			this.height = glyph.height;
			this.isHyphen = glyph.isHyphen;
			this.isSpace = glyph.isSpace;
			this.isVowel = glyph.isVowel;
			this.width = glyph.width;
			this.xAdvance = glyph.xAdvance;
			this.xOffset = glyph.xOffset;
			this.yOffset = glyph.yOffset;
			#if debug
			this.char = glyph.char;
			#end
		//}
	}
	
	private function setFromPool(glyph:Glyph):GlyphLocation
	{
		this.glyph = glyph;
		//if (this.glyph != null)
		//{
			this.charID = glyph.charID;
			this.frame = glyph.frame;
			this.height = glyph.height;
			this.isHyphen = glyph.isHyphen;
			this.isSpace = glyph.isSpace;
			this.isVowel = glyph.isVowel;
			this.width = glyph.width;
			this.xAdvance = glyph.xAdvance;
			this.xOffset = glyph.xOffset;
			this.yOffset = glyph.yOffset;
			#if debug
			this.char = glyph.char;
			#end
		//}
		//else
		//{
			//this.isHyphen = false;
			//this.isSpace = false;
			//this.isVowel = false;
			//#if debug
			//this.char = null;
			//#end
		//}
		return this;
	}
	
}