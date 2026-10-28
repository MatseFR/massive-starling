package massive.text.internal;

/**
 * ...
 * @author Matse
 */
class LinePartImg extends LinePart 
{
	private static var _POOL:Array<LinePartImg> = new Array<LinePartImg>();
	
	public static function fromPool():LinePartImg
	{
		return _POOL.length != 0 ? _POOL.pop() : new LinePartImg();
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
		var imgLocation:ImgLocation;
		
		for (i in 0...this.elementLocations.length)
		{
			imgLocation = cast this.elementLocations[i];
			if (imgLocation.height > this.lineHeight) this.lineHeight = imgLocation.height;
		}
		
		this.lineHeightCurrent = this.lineHeight;
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