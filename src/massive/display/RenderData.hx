package massive.display;

/**
 * ...
 * @author Matse
 */
class RenderData 
{
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
	
	public function new() 
	{
		clear();
	}
	
	public function clear():Void
	{
		this.numQuads = this.position = this.quadOffset = this.totalQuads = 0;
	}
	
	public function render():Void
	{
		this.numQuads = this.position = 0;
	}
	
}