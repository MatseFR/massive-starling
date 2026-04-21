package massive.particle;

/**
 * ...
 * @author Matse
 */
class EmitterType 
{
	static public inline var GRAVITY:Int = 0;
	static public inline var RADIAL:Int = 1;
	
	static public function getNames():Array<String>
	{
		return ["Gravity", "Radial"];
	}
	
	static public function getValues():Array<Int>
	{
		return [GRAVITY, RADIAL];
	}
}