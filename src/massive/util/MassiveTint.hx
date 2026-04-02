package massive.util;

/**
 * ...
 * @author Matse
 */
class MassiveTint 
{
	static private var _POOL:Array<MassiveTint> = new Array<MassiveTint>();
	
	static public function fromPool(red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 0.0, changeCallback:MassiveTint->Void = null):MassiveTint
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(red, green, blue, alpha, changeCallback);
		return new MassiveTint(red, green, blue, alpha, changeCallback);
	}
	
	/**
	   amount of red tinting, from -1.0 to 1.0
	**/
	public var red(get, set):Float;
	private function get_red():Float { return this.redValue; }
	private function set_red(value:Float):Float
	{
		if (this.redValue == value) return value;
		this.redValue = value;
		if (this.changeCallback != null) changeCallback(this);
		return this.redValue;
	}
	
	/**
	   Fast read access to red value
	**/
	public var redValue(default, null):Float;
	
	/**
	   amount of green tinting, from -1.0 to 1.0
	**/
	public var green(get, set):Float;
	private function get_green():Float { return this.greenValue; }
	private function set_green(value:Float):Float
	{
		if (this.greenValue == value) return value;
		this.greenValue = value;
		if (this.changeCallback != null) changeCallback(this);
		return this.greenValue;
	}
	
	/**
	   Fast read access to green value
	**/
	public var greenValue(default, null):Float;
	
	/**
	   amount of blue tinting, from -1.0 to 1.0
	**/
	public var blue(get, set):Float;
	private function get_blue():Float { return this.blueValue; }
	private function set_blue(value:Float):Float
	{
		if (this.blueValue == value) return value;
		this.blueValue = value;
		if (this.changeCallback != null) changeCallback(this);
		return this.blueValue;
	}
	
	/**
	   Fast read access to blue value
	**/
	public var blueValue(default, null):Float;
	
	/**
	   transparency, from 0.0 to 1.0
	**/
	public var alpha(get, set):Float;
	private function get_alpha():Float { return this.alphaValue; }
	private function set_alpha(value:Float):Float
	{
		if (this.alphaValue == value) return value;
		this.alphaValue = value;
		if (this.changeCallback != null) changeCallback(this);
		return this.alphaValue;
	}
	
	/**
	   Fast read access to alpha value
	**/
	public var alphaValue(default, null):Float;
	
	public var changeCallback:MassiveTint->Void;
	
	public function new(red:Float = 0.0, green:Float = 0.0, blue:Float = 0.0, alpha:Float = 0.0, changeCallback:MassiveTint->Void = null) 
	{
		this.redValue = red;
		this.greenValue = green;
		this.blueValue = blue;
		this.alphaValue = alpha;
		this.changeCallback = changeCallback;
	}
	
	public function clear():Void
	{
		clearValues();
		this.changeCallback = null;
	}
	
	public function clearValues():Void
	{
		this.redValue = this.greenValue = this.blueValue = this.alphaValue = 0.0;
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(red:Float, green:Float, blue:Float, alpha:Float, changeCallback:MassiveTint->Void = null):Void
	{
		this.redValue = red;
		this.greenValue = green;
		this.blueValue = blue;
		this.alphaValue = alpha;
		this.changeCallback = changeCallback;
	}
	
	private function setFromPool(red:Float, green:Float, blue:Float, alpha:Float, changeCallback:MassiveTint->Void):MassiveTint
	{
		setTo(red, green, blue, alpha, changeCallback);
		return this;
	}
	
	public function copyFrom(tint:MassiveTint):Void
	{
		this.redValue = tint.redValue;
		this.greenValue = tint.greenValue;
		this.blueValue = tint.blueValue;
		this.alphaValue = tint.alphaValue;
	}
	
	public function hasColor():Bool
	{
		return this.redValue != 0.0 || this.greenValue != 0.0 || this.blueValue != 0.0;
	}
	
	public function hasValue():Bool
	{
		return this.redValue != 0.0 || this.greenValue != 0.0 || this.blueValue != 0.0 || this.alphaValue != 0.0;
	}
	
	public function isSameAs(tint:MassiveTint):Bool
	{
		return this.redValue == tint.red && this.greenValue == tint.green && this.blueValue == tint.blue && this.alphaValue == tint.alpha;
	}
	
	public function isSameColorAs(tint:MassiveTint):Bool
	{
		return this.redValue == tint.red && this.greenValue == tint.green && this.blueValue == tint.blue;
	}
	
}