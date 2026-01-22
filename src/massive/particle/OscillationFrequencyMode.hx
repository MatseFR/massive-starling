package massive.particle;

/**
 * ...
 * @author Matse
 */
class OscillationFrequencyMode 
{
	inline public static var GLOBAL:String = "global";
	inline public static var GROUP:String = "group";
	inline public static var SINGLE:String = "single";
	
	public static function getValues():Array<String>
	{
		return [GLOBAL, GROUP, SINGLE];
	}
}