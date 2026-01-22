package massive.util;

/**
 * ...
 * @author Matse
 */
class MassiveTint 
{
	static private var _POOL:Array<MassiveTint> = new Array<MassiveTint>();
	
	static public function fromPool(red:Float = 0, green:Float = 0, blue:Float = 0, alpha:Float = 0):MassiveTint
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(red, green, blue, alpha);
		return new MassiveTint(red, green, blue, alpha);
	}
	
	/**
	   amount of red tinting, from -1.0 to 1.0
	**/
	public var red:Float;
	
	/**
	   amount of green tinting, from -1.0 to 1.0
	**/
	public var green:Float;
	
	/**
	   amount of blue tinting, from -1.0 to 1.0
	**/
	public var blue:Float;
	
	/**
	   amount of alpha tinting, from 0.0 to 1.0
	**/
	public var alpha:Float;
	
	public function new(red:Float = 0, green:Float = 0, blue:Float = 0, alpha:Float = 0) 
	{
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
	}
	
	public function clear():Void
	{
		this.red = this.green = this.blue = this.alpha = 0.0;
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(red:Float, green:Float, blue:Float, alpha:Float):Void
	{
		this.red = red;
		this.green = green;
		this.blue = blue;
		this.alpha = alpha;
	}
	
	private function setFromPool(red:Float, green:Float, blue:Float, alpha:Float):MassiveTint
	{
		setTo(red, green, blue, alpha);
		return this;
	}
	
	public function copyFrom(tint:MassiveTint):Void
	{
		this.red = tint.red;
		this.green = tint.green;
		this.blue = tint.blue;
		this.alpha = tint.alpha;
	}
	
}