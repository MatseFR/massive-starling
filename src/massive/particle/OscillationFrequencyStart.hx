package massive.particle;

/**
 * @author Matse
 */
class OscillationFrequencyStart
{
	inline public static var ZERO:String = "zero";
	inline public static var RANDOM:String = "random";
	inline public static var UNIFIED_RANDOM:String = "unified_random";
	
	public static function getValues():Array<String>
	{
		return [ZERO, RANDOM, UNIFIED_RANDOM];
	}
}