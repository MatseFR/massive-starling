package massive.text.internal;

import massive.text.FontStyle;

/**
 * ...
 * @author Matse
 */
class LinePartString extends LinePart 
{
	private static var _POOL:Array<LinePartString> = new Array<LinePartString>();
	
	public static function fromPool(style:FontStyle, fontScale:Float):LinePartString
	{
		return _POOL.length != 0 ? _POOL.pop().setFromPool(style, fontScale) : new LinePartString(style, fontScale);
	}
	
	public var fontScale:Float;
	public var style:FontStyle;
	
	public function new(style:FontStyle, fontScale:Float) 
	{
		super();
		this.isText = true;
		this.style = style;
		this.fontScale = fontScale;
		
		this.baseline = this.style.baseline * this.fontScale;
		this.lineHeight = this.style.lineHeight * this.fontScale;
		
		this.spaceWidth = this.style.spaceWidth * this.fontScale;
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
		
		this.baseline = this.style.baseline * this.fontScale;
		this.lineHeight = this.style.lineHeight * this.fontScale;
		
		this.spaceWidth = this.style.spaceWidth * this.fontScale;
		
		return this;
	}
	
	public function validate():Void
	{
		
	}
	
	public function adjust(finalLineHeight:Float, finalTextHeight:Float, finalBaseline:Float, yOffset:Float):Void
	{
		var lineHeightDiff:Float = Math.ffloor((finalLineHeight - finalTextHeight) / 2);
		var baselineDiff:Float = finalBaseline - this.baseline;
		var location:ElementLocation;
		
		for (i in 0...this.elementLocations.length)
		{
			location = this.elementLocations[i];
			location.y = location.yOffset + yOffset + lineHeightDiff + baselineDiff;
		}
	}
	
}