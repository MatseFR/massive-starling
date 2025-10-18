package massive.data;

/**
 * ...
 * @author Matse
 */
abstract class DisplayData
{
	public var x:Float = 0;
	public var y:Float = 0;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var rotation:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	
	/* -1 to 10 */
	public var colorRed:Float = 1;
	/* -1 to 10 */
	public var colorGreen:Float = 1;
	/* -1 to 10 */
	public var colorBlue:Float = 1;
	/* 0 to 1 */
	public var colorAlpha:Float = 1;
	
	public var visible:Bool = true;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.x = this.y = this.offsetX = this.offsetY = this.rotation = 0;
		this.scaleX = this.scaleY = this.colorRed = this.colorGreen = this.colorBlue = this.colorAlpha = 1;
		this.visible = true;
	}
	
	abstract public function pool():Void;
	
}