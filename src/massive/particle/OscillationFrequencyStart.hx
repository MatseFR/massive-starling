package massive.particle;

/**
 * @author Matse
 */
class OscillationFrequencyStart
{
	inline public static var ZERO:String = "zero";
	//inline public static var INCREMENTAL:String = "incremental";
	//inline public static var UNIFIED_INCREMENTAL:String = "unified_incremental";
	inline public static var RANDOM:String = "random";
	inline public static var UNIFIED_RANDOM:String = "unified_random";
	
	public static function getValues():Array<String>
	{
		//return [ZERO, INCREMENTAL, UNIFIED_INCREMENTAL, RANDOM, UNIFIED_RANDOM];
		return [ZERO, RANDOM, UNIFIED_RANDOM];
	}
}