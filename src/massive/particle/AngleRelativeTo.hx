package massive.particle;

/**
 * ...
 * @author Matse
 */
class AngleRelativeTo 
{
	inline public static var ABSOLUTE:String = "absolute";
	inline public static var ROTATION:String = "rotation";
	inline public static var VELOCITY:String = "velocity";
	
	public static function getValues():Array<String>
	{
		return [ABSOLUTE, ROTATION, VELOCITY];
	}
}