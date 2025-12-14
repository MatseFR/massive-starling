package hexagon;
import massive.data.ImageData;

/**
 * ...
 * @author Matse
 */
class Hex
{
	public var q:Int;
	public var r:Int;
	public var cost:Int;
	public var isBlockingLoS:Bool;
	public var isOccupied:Bool;
	public var isTraversable:Bool;
	public var hasNullNeighbor:Bool;
	public var directionNeighborMap:Map<Int, Hex>;
	public var neighborDirectionMap:Map<Hex, Int>;
	public var neighbors:Array<Hex>;
	public var neighborsDirections:Array<Int>;
	public var nullNeighborsDirections:Array<Int>;
	
	// added properties
	public var x:Float;
	public var y:Float;
	public var offsetX:Float;
	public var offsetY:Float;
	public var imageData:ImageData;
	public var costImageData:ImageData;
	
	public function new() 
	{
		
	}
	
	public function dispose():Void
	{
		if (this.directionNeighborMap != null)
		{
			this.directionNeighborMap.clear();
			this.directionNeighborMap = null;
		}
		
		if (this.neighborDirectionMap != null)
		{
			this.neighborDirectionMap.clear();
			this.neighborDirectionMap = null;
		}
	}
	
	public function getDirectionNeighbor(direction:Int):Hex
	{
		return this.directionNeighborMap[direction];
	}
	
	public function getNeighborDirection(neighbor:Hex):Int
	{
		return this.neighborDirectionMap[neighbor];
	}
	
}