package massive.text;

/**
 * ...
 * @author Matse
 */
class GlyphLocation 
{
	private static var _ARRAY_POOL:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	private static var _ARRAY_OUT:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	private static var _POOL:Array<GlyphLocation> = new Array<GlyphLocation>();
	private static var _OUT:Array<GlyphLocation> = new Array<GlyphLocation>();
	
	private static var _array:Array<GlyphLocation>;
	private static var _instance:GlyphLocation;
	
	public static function arrayFromPool():Array<GlyphLocation>
	{
		_array = _ARRAY_POOL.length != 0 ? _ARRAY_POOL.pop() : new Array<GlyphLocation>();
		_ARRAY_OUT[_ARRAY_OUT.length] = _array;
		return _array;
	}
	
	public static function fromPool(glyph:Glyph):GlyphLocation
	{
		_instance = _POOL.length != 0 ? _POOL.pop().setFromPool(glyph) : new GlyphLocation(glyph);
		_OUT[_OUT.length] = _instance;
		return _instance;
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_instance.glyph = null;
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
		
		count = _ARRAY_OUT.length;
		for (i in 0...count)
		{
			_array = _ARRAY_OUT[i];
			_array.resize(0);
			_ARRAY_POOL[_ARRAY_POOL.length] = _array;
		}
		_ARRAY_OUT.resize(0);
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