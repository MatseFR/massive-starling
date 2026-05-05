package massive.display;

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
	
	public function new(display:MassiveDisplay) 
	{
		this.display = display;
		clear();
	}
	
	public function clear():Void
	{
		this.numQuads = this.position = this.quadOffset = this.totalQuads = 0;
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