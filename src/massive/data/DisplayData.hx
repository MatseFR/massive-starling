package massive.data;

/**
 * Abstract base class for Massive display objects
 * @author Matse
 */
abstract class DisplayData
{
	/**
	   position on x-axis
	   @default 0
	**/
	public var x:Float = 0;
	/**
	   position on y-axis
	   @default 0
	**/
	public var y:Float = 0;
	/**
	   position offset on x-axis
	   @default 0
	**/
	public var offsetX:Float = 0;
	/**
	   position offset on y-axis
	   @default 0
	**/
	public var offsetY:Float = 0;
	/**
	   rotation in radians
	**/
	public var rotation:Float = 0;
	/**
	   horizontal scale factor
	**/
	public var scaleX:Float = 1;
	/**
	   vertical scale factor
	**/
	public var scaleY:Float = 1;
	/**
	   Int color
	   @default 0xffffff
	**/
	public var color(get, set):Int;
	/**
	   Amount of red tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var red:Float = 1;
	/**
	   Amount of green tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var green:Float = 1;
	/**
	   Amount of blue tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var blue:Float = 1;
	/**
	   Opacity, from 0.0 to 1.0
	   @default 1
	**/
	public var alpha:Float = 1;
	/**
	   Tells whether this object is visible or not
	   @default true
	**/
	public var visible:Bool = true;
	
	private function get_color():Int
	{
		var r:Float = this.red > 1.0 ? 1.0 : this.red < 0.0 ? 0.0 : this.red;
		var g:Float = this.green > 1.0 ? 1.0 : this.green < 0.0 ? 0.0 : this.green;
		var b:Float = this.blue > 1.0 ? 1.0 : this.blue < 0.0 ? 0.0 : this.blue;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color(value:Int):Int
	{
		this.red = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.green = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blue = (value & 0xFF) / 255.0;
		return value;
	}
	
	public function new() 
	{
		
	}
	
	/**
	   restores default values
	**/
	public function clear():Void
	{
		this.x = this.y = this.offsetX = this.offsetY = this.rotation = 0;
		this.scaleX = this.scaleY = this.red = this.green = this.blue = this.alpha = 1;
		this.visible = true;
	}
	
	/**
	   send the object to pool
	**/
	abstract public function pool():Void;
	
}