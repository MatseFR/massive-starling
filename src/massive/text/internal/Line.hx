package massive.text.internal;

/**
 * ...
 * @author Matse
 */
class Line 
{
	private static var _POOL:Array<Line> = new Array<Line>();
	
	public static function fromPool():Line
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new Line();
	}
	
	public var currentLineHeight:Float;
	public var maxBaseline:Float = 0.0;
	public var maxLineHeight:Float = 0.0;
	public var maxTextHeight:Float = 0.0;
	public var parts(default, null):Array<LinePart> = new Array<LinePart>();
	public var yOffset:Float = 0.0;
	
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
		
		this.maxBaseline = 0.0;
		this.maxLineHeight = 0.0;
		this.maxTextHeight = 0.0;
		this.yOffset = 0.0;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public inline function addPart(part:LinePart):Void
	{
		this.parts[this.parts.length] = part;
	}
	
	public function removeLastPart():Void
	{
		this.parts.pop().pool();
	}
	
	public function validate():Void
	{
		var part:LinePart;
		this.maxLineHeight = 0.0;
		this.maxBaseline = 0.0;
		this.maxTextHeight = 0.0;
		
		for (i in 0...this.parts.length)
		{
			part = this.parts[i];
			part.validate();
			if (part.lineHeight > this.maxLineHeight) this.maxLineHeight = part.lineHeight;
			if (part.baseline > this.maxBaseline) this.maxBaseline = part.baseline;
			if (part.isText && part.lineHeight > this.maxTextHeight) this.maxTextHeight = part.lineHeight;
		}
		
		this.currentLineHeight = this.maxLineHeight;
	}
	
	public function adjust(finalLineHeight:Float, finalTextHeight:Float, finalBaseline:Float, yOffset:Float):Float
	{
		this.yOffset += yOffset;
		for (i in 0...this.parts.length)
		{
			this.parts[i].adjust(finalLineHeight, finalTextHeight, finalBaseline, this.yOffset);
		}
		var diff:Float = finalLineHeight - this.currentLineHeight + yOffset;
		this.currentLineHeight = finalLineHeight;
		return diff;
	}
	
}