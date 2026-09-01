package massive.display.render;

/**
 * ...
 * @author Matse
 */
class RenderData 
{
	public var display(default, null):MassiveDisplay;
	public var multiTexturing:Bool;
	public var numQuads:Int;
	public var pma:Bool = true;
	public var position:Int;
	public var quadOffset:Int;
	public var totalQuads:Int;
	public var useAlpha:Bool;
	public var useColor:Bool;
	public var useColorOffset:Bool;
	public var useDisplayColor:Bool;
	public var useSimpleColor:Bool;
	
	public var red:Float = 1.0;
	public var green:Float = 1.0;
	public var blue:Float = 1.0;
	public var alpha:Float = 1.0;
	
	public var redOffset:Float = 0.0;
	public var greenOffset:Float = 0.0;
	public var blueOffset:Float = 0.0;
	public var alphaOffset:Float = 0.0;
	
	public function new(display:MassiveDisplay) 
	{
		this.display = display;
		clear();
	}
	
	public function clear():Void
	{
		this.numQuads = this.position = this.quadOffset = this.totalQuads = 0;
		this.red = this.green = this.blue = this.alpha = 1.0;
		this.redOffset = this.greenOffset = this.blueOffset = this.alphaOffset = 0.0;
	}
	
	public function dispose():Void
	{
		this.display = null;
	}
	
	public function render():Void
	{
		this.totalQuads += this.numQuads;
		this.numQuads = this.position = 0;
	}
	
}