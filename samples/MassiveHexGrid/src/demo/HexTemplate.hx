package demo;
import massive.data.Frame;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class HexTemplate 
{
	public var cost:Int;
	public var isBlockingLoS:Bool;
	public var isTraversable:Bool;
	public var frames:#if flash Vector<Frame> #else Array<Frame> #end;
	public var costFrames:#if flash Vector<Frame> #else Array<Frame> #end;
	
	public function new() 
	{
		
	}
	
}