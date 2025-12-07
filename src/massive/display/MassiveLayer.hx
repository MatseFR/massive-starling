package massive.display;
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end
import starling.events.EventDispatcher;

/**
 * ...
 * @author Matse
 */
abstract class MassiveLayer extends EventDispatcher
{
	/**
	   
	**/
	public var name:String;
	/**
	   
	**/
	public var animate:Bool;
	/**
	   
	**/
	public var autoHandleNumDatas:Bool = true;
	/**
	   
	**/
	public var display:MassiveDisplay;
	/**
	   
	**/
	public var numDatas:Int = 0;
	/**
	   
	**/
	public var totalDatas(get, never):Int;
	/**
	   
	**/
	public var useColor:Bool;
	
	abstract private function get_totalDatas():Int;
	
	/**
	 * 
	 */
	abstract public function dispose():Void;
	
	/**
	 * 
	 */
	abstract public function removeAllData():Void;
	
	/**
	   
	   @param	byteData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @return
	**/
	abstract public function writeDataBytes(byteData:ByteArray, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	
	#if !flash
	/**
	   
	   @param	floatData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @return
	**/
	abstract public function writeDataFloat32Array(floatData:Float32Array, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	#end
	
	/**
	   
	   @param	vectorData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @return
	**/
	abstract public function writeDataVector(vectorData:Vector<Float>, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	
	/**
	 * 
	 * @param	time
	 */
	abstract public function advanceTime(time:Float):Void;
	
}