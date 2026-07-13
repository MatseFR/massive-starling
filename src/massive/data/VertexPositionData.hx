package massive.data;

/**
 * ...
 * @author Matse
 */
class VertexPositionData 
{
	static private var _POOL:Array<VertexPositionData> = new Array<VertexPositionData>();
	
	static public function fromPool(x1:Float = 0.0, x2:Float = 0.0, x3:Float = 0.0, x4:Float = 0.0, y1:Float = 0.0, y2:Float = 0.0, y3:Float = 0.0, y4:Float = 0.0):VertexPositionData
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(x1, x2, x3, x4, y1, y2, y3, y4);
		return new VertexPositionData(x1, x2, x3, x4, y1, y2, y3, y4);
	}
	
	public var x1:Float;
	public var x2:Float;
	public var x3:Float;
	public var x4:Float;
	public var y1:Float;
	public var y2:Float;
	public var y3:Float;
	public var y4:Float;

	public function new(x1:Float = 0.0, x2:Float = 0.0, x3:Float = 0.0, x4:Float = 0.0, y1:Float = 0.0, y2:Float = 0.0, y3:Float = 0.0, y4:Float = 0.0) 
	{
		this.x1 = x1;
		this.x2 = x2;
		this.x3 = x3;
		this.x4 = x4;
		this.y1 = y1;
		this.y2 = y2;
		this.y3 = y3;
		this.y4 = y4;
	}
	
	public function clear():Void
	{
		this.x1 = this.x2 = this.x3 = this.x4 = this.y1 = this.y2 = this.y3 = this.y4 = 0.0;
	}
	
	public function pool():Void
	{
		// no need to call clear()
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(x1:Float = 0.0, x2:Float = 0.0, x3:Float = 0.0, x4:Float = 0.0, y1:Float = 0.0, y2:Float = 0.0, y3:Float = 0.0, y4:Float = 0.0):VertexPositionData
	{
		this.x1 = x1;
		this.x2 = x2;
		this.x3 = x3;
		this.x4 = x4;
		this.y1 = y1;
		this.y2 = y2;
		this.y3 = y3;
		this.y4 = y4;
		return this;
	}
	
}