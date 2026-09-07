package massive.text;

/**
 * ...
 * @author Matse
 */
class GlyphLocation 
{
	private static var _ARRAY_POOL:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	private static var _POOL:Array<GlyphLocation> = new Array<GlyphLocation>();
	
	public static function arrayFromPool():Array<GlyphLocation>
	{
		return new Array<GlyphLocation>();
	}
	
	public static function fromPool(glyph:Glyph):GlyphLocation
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(glyph);
		return new GlyphLocation(glyph);
	}
	
	#if debug
	public var char:String;
	#end
	public var index:Int;
	public var glyph:Glyph;
	public var scale:Float;
	public var x:Float;
	public var y:Float;

	public function new(glyph:Glyph) 
	{
		this.glyph = glyph;
	}
	
	private function setFromPool(glyph:Glyph):GlyphLocation
	{
		this.glyph = glyph;
		return this;
	}
	
}