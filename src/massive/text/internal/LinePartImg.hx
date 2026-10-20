package massive.text.internal;

/**
 * ...
 * @author Matse
 */
class LinePartImg extends LinePart 
{
	private static var _POOL:Array<LinePartImg> = new Array<LinePartImg>();
	//private static var _OUT:Array<LinePartImg> = new Array<LinePartImg>();
	
	//private static var _instance:LinePartImg;
	
	public static function fromPool():LinePartImg
	{
		//return _OUT[_OUT.length] = _POOL.length != 0 ? _POOL.pop() : new LinePartImg();
		return _POOL.length != 0 ? _POOL.pop() : new LinePartImg();
	}
	
	//public static function rechargePool():Void
	//{
		//var count:Int = _OUT.length;
		//for (i in 0...count)
		//{
			//_instance = _OUT[i];
			//_POOL[_POOL.length] = _instance;
		//}
		//_OUT.resize(0);
	//}
	
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
	
	public function adjust(finalLineHeight:Float, finalBaseline:Float, yOffset:Float):Void
	{
		var location:ElementLocation;
		for (i in 0...this.elementLocations.length)
		{
			location = this.elementLocations[i];
			location.y = Math.ffloor(location.y + yOffset + (finalLineHeight - location.height) / 2.0);
		}
		//return finalLineHeight - this.lineHeight + yOffset;
	}
	
}