package massive.display;

/**
 * ...
 * @author Matse
 */
class MassiveColorMode 
{
	/**
	   Handles color values over 1.0, each color channel takes 32 bits.
	   This is the default value.
	**/
	static public inline var EXTENDED:String = "extended";
	/**
	   No color or alpha, textures still work.
	**/
	static public inline var NONE:String = "none";
	/**
	   Color range is 0.0-1.0, color channels are converted to integer, each color channel takes 8 bits.
	   This setting slightly increases performance.
	**/
	static public inline var REGULAR:String = "regular";
	
	static public function getValues():Array<String>
	{
		return [EXTENDED, NONE, REGULAR];
	}
	
}