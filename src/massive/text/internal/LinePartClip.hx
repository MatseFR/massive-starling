package massive.text.internal;

/**
 * ...
 * @author Matse
 */
class LinePartClip extends LinePart 
{
	private static var _POOL:Array<LinePartClip> = new Array<LinePartClip>();
	
	public static function fromPool():LinePartClip
	{
		return _POOL.length != 0 ? _POOL.pop() : new LinePartClip();
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
		this.lineHeight = 0.0;
		var clipLocation:ClipLocation;
		
		for (i in 0...this.elementLocations.length)
		{
			clipLocation = cast this.elementLocations[i];
			if (clipLocation.height > this.lineHeight) this.lineHeight = clipLocation.height;
		}
	}
	
	public function adjust(finalLineHeight:Float, finalTextHeight:Float, finalBaseline:Float, yOffset:Float):Void
	{
		var location:ElementLocation;
		for (i in 0...this.elementLocations.length)
		{
			location = this.elementLocations[i];
			location.y = Math.ffloor(location.originY + yOffset + (finalLineHeight - location.height) / 2.0);
		}
	}
	
}