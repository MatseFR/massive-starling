package massive.text.internal;

import massive.text.FontStyle;

/**
 * ...
 * @author Matse
 */
class LinePartString extends LinePart 
{
	private static var _POOL:Array<LinePartString> = new Array<LinePartString>();
	private static var _OUT:Array<LinePartString> = new Array<LinePartString>();
	
	private static var _instance:LinePartString;
	
	public static function fromPool(style:FontStyle, fontScale:Float):LinePartString
	{
		return _OUT[_OUT.length] = _POOL.length != 0 ? _POOL.pop().setFromPool(style, fontScale) : new LinePartString(style, fontScale);
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_instance.style = null;
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
	}
	
	public var fontScale:Float;
	public var style:FontStyle;
	
	public function new(style:FontStyle, fontScale:Float) 
	{
		super();
		this.style = style;
		this.fontScale = fontScale;
		
		this.baseline = this.baselineCurrent = this.style.baseline * this.fontScale;
		this.lineHeight = this.lineHeightCurrent = this.style.lineHeight * this.fontScale;
	}
	
	override public function clear():Void 
	{
		this.style = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(style:FontStyle, fontScale:Float):LinePartString
	{
		this.style = style;
		this.fontScale = fontScale;
		
		this.baseline = this.baselineCurrent = this.style.baseline * this.fontScale;
		this.lineHeight = this.lineHeightCurrent = this.style.lineHeight * this.fontScale;
		
		return this;
	}
	
	public function validate():Void
	{
		
	}
	
	public function adjust(finalLineHeight:Float, finalBaseline:Float, yOffset:Float):Float
	{
		var lineHeightDiff:Float = (finalLineHeight - this.lineHeightCurrent) / 2;
		var baselineDiff:Float = finalBaseline - this.baselineCurrent;
		var location:ElementLocation;
		
		for (i in 0...this.elementLocations.length)
		{
			location = this.elementLocations[i];
			location.y = Math.ffloor(location.y + yOffset + lineHeightDiff + baselineDiff * location.scale);
			//location.y += baselineDiff * location.scale;
		}
		
		this.lineHeightCurrent = finalLineHeight;
		this.baselineCurrent = finalBaseline;
		
		return lineHeightDiff + yOffset;
	}
	
}