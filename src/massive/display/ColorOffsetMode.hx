package massive.display;

/**
 * ...
 * @author Matse
 */
class ColorOffsetMode 
{
	/**
	   
	**/
	static public inline var DISPLAY:String = "display";
	
	/**
	   
	**/
	static public inline var DISPLAY_AND_OBJECT:String = "display_and_object";
	
	/**
	   
	**/
	static public inline var NONE:String = "none";
	
	/**
	   
	**/
	static public inline var OBJECT:String = "object";
	
	static public function getValues():Array<String>
	{
		return [NONE, DISPLAY, DISPLAY_AND_OBJECT, OBJECT];
	}
}