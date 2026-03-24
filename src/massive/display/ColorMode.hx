package massive.display;

/**
 * ...
 * @author Matse
 */
class ColorMode 
{
	/**
	   
	**/
	static public inline var ALPHA:String = "alpha";
	/**
	   Objects color and alpha is only affected by MassiveDisplay color and alpha
	**/
	static public inline var DISPLAY:String = "display";
	/**
	   Objects color and alpha are affected by both their own color/alpha and the MassiveDisplay color/alpha
	   Handles color values over 1.0, each color channel takes 32 bits.
	   This is the default value.
	**/
	static public inline var EXTENDED:String = "extended";
	/**
	   No color or alpha, textures still work.
	   CAUTION : MassiveDisplay alpha and parent containers alpha won't have any effect
	**/
	static public inline var NONE:String = "none";
	/**
	   Color range is 0.0-1.0, color channels are converted to integer, each color channel takes 8 bits.
	   This setting slightly increases performance.
	**/
	static public inline var REGULAR:String = "regular";
	
	static public function getValues():Array<String>
	{
		return [NONE, DISPLAY, REGULAR, EXTENDED];
	}
	
}