package massive.display;
import openfl.Vector;
import openfl.utils.ByteArray;
import starling.errors.AbstractMethodError;

/**
 * ...
 * @author Matse
 */
abstract class MassiveLayer
{
	public var name:String;
	public var useDynamicData:Bool;
	public var animate:Bool;
	public var useColor:Bool;
	
	public var display:MassiveDisplay;
	
	/**
	 * 
	 */
	public function dispose():Void
	{
		throw new AbstractMethodError();
	}
	
	/**
	 * 
	 * @param	byteData
	 * @param	offset
	 * @return
	 */
	public function writeDataBytes(byteData:ByteArray, offset:Int):Int
	{
		throw new AbstractMethodError();
	}
	
	/**
	 * 
	 * @param	vectorData
	 * @param	offset
	 * @return
	 */
	public function writeDataVector(vectorData:Vector<Float>, offset:Int):Int
	{
		throw new AbstractMethodError();
	}
	
	/**
	 * 
	 * @param	time
	 */
	public function advanceTime(time:Float):Void
	{
		throw new AbstractMethodError();
	}
}