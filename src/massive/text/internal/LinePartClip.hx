package massive.text.internal;

/**
 * ...
 * @author Matse
 */
class LinePartClip extends LinePart 
{
	private static var _POOL:Array<LinePartClip> = new Array<LinePartClip>();
	private static var _OUT:Array<LinePartClip> = new Array<LinePartClip>();
	
	private static var _instance:LinePartClip;
	
	public static function fromPool():LinePartClip
	{
		return _OUT[_OUT.length] = _POOL.length != 0 ? _POOL.pop() : new LinePartClip();
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
	}
	
	public function new() 
	{
		super();
		
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function validate():Void
	{
		var maxHeight:Float = 0.0;
		var clipLocation:ClipLocation;
		
		for (i in 0...this.elementLocations.length)
		{
			clipLocation = cast this.elementLocations[i];
			if (clipLocation.height > maxHeight) maxHeight = clipLocation.height;
		}
		
		this.lineHeight = maxHeight;
	}
	
	public function adjust(finalLineHeight:Float, finalBaseline:Float, yOffset:Float):Float
	{
		var location:ElementLocation;
		for (i in 0...this.elementLocations.length)
		{
			location = this.elementLocations[i];
			location.y = Math.ffloor(location.y + yOffset + (finalLineHeight - location.height) / 2.0);
		}
		return finalLineHeight - this.lineHeight + yOffset;
	}
	
}