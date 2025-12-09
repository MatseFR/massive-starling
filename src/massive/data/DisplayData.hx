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
	   Amount of red tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var colorRed:Float = 1;
	/**
	   Amount of green tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var colorGreen:Float = 1;
	/**
	   Amount of blue tinting, from -1.0 to 10.0
	   @default 1
	**/
	public var colorBlue:Float = 1;
	/**
	   Opacity, from 0.0 to 1.0
	   @default 1
	**/
	public var colorAlpha:Float = 1;
	/**
	   Tells whether this object is visible or not
	   @default true
	**/
	public var visible:Bool = true;
	
	public function new() 
	{
		
	}
	
	/**
	   restores default values
	**/
	public function clear():Void
	{
		this.x = this.y = this.offsetX = this.offsetY = this.rotation = 0;
		this.scaleX = this.scaleY = this.colorRed = this.colorGreen = this.colorBlue = this.colorAlpha = 1;
		this.visible = true;
	}
	
	/**
	   send the object to pool
	**/
	abstract public function pool():Void;
	
}