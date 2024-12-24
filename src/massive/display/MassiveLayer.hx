package massive.display;
import openfl.Vector;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
abstract class MassiveLayer
{
	public var name:String;
	/**
	   @private
	**/
	public var useDynamicData:Bool;
	/**
	   @private
	**/
	public var animate:Bool;
	/**
	   @private
	**/
	public var useColor:Bool;
	
	public var display:MassiveDisplay;
	
	/**
	 * 
	 */
	abstract public function dispose():Void;
	
	/**
	 * 
	 */
	abstract public function removeAllData():Void;
	
	/**
	 * 
	 * @param	byteData
	 * @param	offset
	 * @return
	 */
	abstract public function writeDataBytes(byteData:ByteArray, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	
	/**
	 * 
	 * @param	vectorData
	 * @param	offset
	 * @return
	 */
	abstract public function writeDataVector(vectorData:Vector<Float>, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	
	/**
	 * 
	 * @param	time
	 */
	abstract public function advanceTime(time:Float):Void;
	
}