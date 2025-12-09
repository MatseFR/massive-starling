package massive.display;
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end
import starling.events.EventDispatcher;

/**
 * Abstract base class for Massive layers
 * @author Matse
 */
abstract class MassiveLayer extends EventDispatcher
{
	/**
	   Name of the layer, only useful if you want to be able to retrieve layers by their name
	**/
	public var name:String;
	/**
	   Tells whether the MassiveDisplay instance this layer is added to should call the advanceTime function or not
	**/
	public var animate:Bool;
	/**
	   Tells whether the layer should count how many datas it has when requested to write it or not.
	   For example ParticleSystem turns this off and sets numDatas directly, according to how many particles are alive.
	   @default true
	**/
	public var autoHandleNumDatas:Bool = true;
	/**
	   The MassiveDisplay instance this layer is added to, if any.
	**/
	public var display:MassiveDisplay;
	/**
	   How many quads this layer should write data for when requested.
	**/
	public var numDatas:Int = 0;
	/**
	   How many quads this layer has in total.
	**/
	public var totalDatas(get, never):Int;
	/**
	   Tells whether this layer should write color data or not, this is decided by the MassiveDisplay instance this layer was added to.
	**/
	public var useColor:Bool;
	
	abstract private function get_totalDatas():Int;
	
	/**
	 * Disposes the layer
	 */
	abstract public function dispose():Void;
	
	/**
	 * Removes all data in the layer
	 */
	abstract public function removeAllData():Void;
	
	/**
	   Writes the layer's quads data to the specified ByteArray
	   @param	byteData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @return
	**/
	abstract public function writeDataBytes(byteData:ByteArray, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	
	#if !flash
	/**
	   Writes the layer's quads data to the specified Float32Array
	   @param	floatData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @return
	**/
	abstract public function writeDataFloat32Array(floatData:Float32Array, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	#end
	
	/**
	   Writes the layer's quads data to the specified Vector
	   @param	vectorData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @return
	**/
	abstract public function writeDataVector(vectorData:Vector<Float>, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int;
	
	/**
	 * Advances time for the layer, controlled by the MassiveDisplay instance this layer was added to
	 * @param	time
	 */
	abstract public function advanceTime(time:Float):Void;
	
}