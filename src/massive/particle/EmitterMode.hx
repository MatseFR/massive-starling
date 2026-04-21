package massive.particle;

/**
 * ...
 * @author Matse
 */
class EmitterMode 
{
	static public inline var BURST:Int = 0;
	static public inline var STREAM:Int = 1;
	
	static public function getNames():Array<String>
	{
		return ["Burst", "Stream"];
	}
	
	static public function getValues():Array<Int>
	{
		return [BURST, STREAM];
	}
}