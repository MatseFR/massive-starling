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
	   Name of the layer, only useful if you want to be able to retrieve layers by their name
	**/
	public var name:String;
	/**
	   How many quads this layer should write data for when requested.
	**/
	public var numDatas:Int = 0;
	/**
	   How many quads this layer has in total.
	**/
	public var totalDatas(get, never):Int;
	/**
	   Tells whether this layer is visible or not.
	   @default true
	**/
	public var visible:Bool = true;
	/**
	   The layer's position on x axis, relative to the MassiveDisplay it belongs to
	   @default 0
	**/
	public var x:Float = 0.0;
	/**
	   The layer's position on y axis, relative to the MassiveDisplay it belongs to
	   @default 0
	**/
	public var y:Float = 0.0;
	
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
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @return
	**/
	abstract public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool, renderData:RenderData):Bool;
	
	#if flash
	/**
	   Writes the layer's quads data to the domain memory ByteArray
	   byteData is still passed as a parameter so that the layer can set its length
	   @param	byteData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @return
	**/
	abstract public function writeDataBytesMemory(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool, renderData:RenderData):Bool;
	#end
	
	#if !flash
	/**
	   Writes the layer's quads data to the specified Float32Array
	   @param	floatData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @return
	**/
	abstract public function writeDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool, renderData:RenderData):Bool;
	#end
	
	/**
	   Writes the layer's quads data to the specified Vector
	   @param	vectorData
	   @param	offset
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @return
	**/
	abstract public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool, renderData:RenderData):Bool;
	
	/**
	 * Advances time for the layer, controlled by the MassiveDisplay instance this layer was added to
	 * @param	time
	 */
	abstract public function advanceTime(time:Float):Void;
	
}