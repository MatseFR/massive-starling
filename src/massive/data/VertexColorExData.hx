package massive.data;

/**
 * ...
 * @author Matse
 */
class VertexColorExData 
{
	static private var _POOL:Array<VertexColorExData> = new Array<VertexColorExData>();
	
	static public function fromPool(red1:Float = 1.0, red2:Float = 1.0, red3:Float = 1.0, red4:Float = 1.0,
									green1:Float = 1.0, green2:Float = 1.0, green3:Float = 1.0, green4:Float = 1.0,
									blue1:Float = 1.0, blue2:Float = 1.0, blue3:Float = 1.0, blue4:Float = 1.0,
									alpha1:Float = 1.0, alpha2:Float = 1.0, alpha3:Float = 1.0, alpha4:Float = 1.0):VertexColorExData
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(red1, red2, red3, red4, green1, green2, green3, green4, blue1, blue2, blue3, blue4, alpha1, alpha2, alpha3, alpha4);
		return new VertexColorExData(red1, red2, red3, red4, green1, green2, green3, green4, blue1, blue2, blue3, blue4, alpha1, alpha2, alpha3, alpha4);
	}
	
	public var red1:Float;
	public var red2:Float;
	public var red3:Float;
	public var red4:Float;
	
	public var green1:Float;
	public var green2:Float;
	public var green3:Float;
	public var green4:Float;
	
	public var blue1:Float;
	public var blue2:Float;
	public var blue3:Float;
	public var blue4:Float;
	
	public var alpha1:Float;
	public var alpha2:Float;
	public var alpha3:Float;
	public var alpha4:Float;
	
	public function new(red1:Float = 1.0, red2:Float = 1.0, red3:Float = 1.0, red4:Float = 1.0,
						green1:Float = 1.0, green2:Float = 1.0, green3:Float = 1.0, green4:Float = 1.0,
						blue1:Float = 1.0, blue2:Float = 1.0, blue3:Float = 1.0, blue4:Float = 1.0,
						alpha1:Float = 1.0, alpha2:Float = 1.0, alpha3:Float = 1.0, alpha4:Float = 1.0)
	{
		this.red1 = red1;
		this.red2 = red2;
		this.red3 = red3;
		this.red4 = red4;
		this.green1 = green1;
		this.green2 = green2;
		this.green3 = green3;
		this.green4 = green4;
		this.blue1 = blue1;
		this.blue2 = blue2;
		this.blue3 = blue3;
		this.blue4 = blue4;
		this.alpha1 = alpha1;
		this.alpha2 = alpha2;
		this.alpha3 = alpha3;
		this.alpha4 = alpha4;
	}
	
	public function clear():Void
	{
		this.red1 = this.red2 = this.red3 = this.red4 = this.green1 = this.green2 = this.green3 = this.green4 = 
		this.blue1 = this.blue2 = this.blue3 = this.blue4 = this.alpha1 = this.alpha2 = this.alpha3 = this.alpha4 = 1.0;
	}
	
	public function pool():Void
	{
		// no need to call clear()
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(red1:Float, red2:Float, red3:Float, red4:Float,
								 green1:Float, green2:Float, green3:Float, green4:Float,
								 blue1:Float, blue2:Float, blue3:Float, blue4:Float,
								 alpha1:Float, alpha2:Float, alpha3:Float, alpha4:Float):VertexColorExData
	{
		this.red1 = red1;
		this.red2 = red2;
		this.red3 = red3;
		this.red4 = red4;
		this.green1 = green1;
		this.green2 = green2;
		this.green3 = green3;
		this.green4 = green4;
		this.blue1 = blue1;
		this.blue2 = blue2;
		this.blue3 = blue3;
		this.blue4 = blue4;
		this.alpha1 = alpha1;
		this.alpha2 = alpha2;
		this.alpha3 = alpha3;
		this.alpha4 = alpha4;
		return this;
	}
	
}