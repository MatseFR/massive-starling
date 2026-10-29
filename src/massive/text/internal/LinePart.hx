package massive.text.internal;

/**
 * ...
 * @author Matse
 */
abstract class LinePart 
{
	public var elementLocations:Array<ElementLocation> = new Array<ElementLocation>();
	public var baseline:Float = 0.0;
	public var isText(default, null):Bool;
	public var lineHeight:Float = 0.0;
	public var spaceWidth:Float = 0.0;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.elementLocations.resize(0);
		this.baseline = 0.0;
		this.lineHeight = 0.0;
		this.spaceWidth = 0.0;
	}
	
	abstract public function pool():Void;
	
	abstract public function validate():Void;
	
	abstract public function adjust(finalLineHeight:Float, finalTextHeight:Float, finalBaseline:Float, yOffset:Float):Void;
	
}