package massive.data;

/**
 * ...
 * @author Matse
 */
class VertexColorData 
{
	static private var _POOL:Array<VertexColorData> = new Array<VertexColorData>();
	
	static public function fromPool(color1:Int = 0xffffffff, color2:Int = 0xffffffff, color3:Int = 0xffffffff, color4:Int = 0xffffffff):VertexColorData
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(color1, color2, color3, color4);
		return new VertexColorData(color1, color2, color3, color4);
	}
	
	public var color1:Int;
	public var color2:Int;
	public var color3:Int;
	public var color4:Int;
	
	public function new(color1:Int = 0xffffffff, color2:Int = 0xffffffff, color3:Int = 0xffffffff, color4:Int = 0xffffffff) 
	{
		this.color1 = color1;
		this.color2 = color2;
		this.color3 = color3;
		this.color4 = color4;
	}
	
	public function clear():Void
	{
		this.color1 = this.color2 = this.color3 = this.color4 = 0xffffffff;
	}
	
	public function pool():Void
	{
		// no need to call clear()
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(color1:Int, color2:Int, color3:Int, color4:Int):VertexColorData
	{
		this.color1 = color1;
		this.color2 = color2;
		this.color3 = color3;
		this.color4 = color4;
		return this;
	}
	
}