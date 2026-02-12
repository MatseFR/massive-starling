package massive.display;

/**
 * ...
 * @author Matse
 */
class RenderData 
{
	public var multiTexturing:Bool;
	public var numQuads:Int;
	public var position:Int;
	public var quadOffset:Int;
	public var totalQuads:Int;
	
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