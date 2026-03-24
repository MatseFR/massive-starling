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
	   Disposes the layer, optionally pooling its data
	   @param	poolData
	**/
	abstract public function dispose(poolData:Bool = true):Void;
	
	/**
	   Removes all data in the layer, optionally pooling it
	   @param	pool
	**/
	abstract public function removeAllData(pool:Bool = true):Void;
	
	/**
	   Writes the layer's quads data to the specified ByteArray
	   @param	byteData
	   @param	maxQuads
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @param	renderData
	   @param	boundsData
	   @return
	**/
	abstract public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Bool;
	
	#if flash
	/**
	   Writes the layer's quads data to the domain memory ByteArray
	   @param	maxQuads
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @param	renderData
	   @param	boundsData
	   @return
	**/
	abstract public function writeDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Bool;
	#end
	
	#if !flash
	/**
	   Writes the layer's quads data to the specified Float32Array
	   @param	floatData
	   @param	maxQuads
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @param	renderData
	   @param	boundsData
	   @return
	**/
	abstract public function writeDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Bool;
	#end
	
	/**
	   Writes the layer's quads data to the specified Vector
	   @param	vectorData
	   @param	maxQuads
	   @param	renderOffsetX
	   @param	renderOffsetY
	   @param	pma
	   @param	useColor
	   @param	simpleColor
	   @param	renderData
	   @param	boundsData
	   @return
	**/
	abstract public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Bool;
	
	/**
	   Writes the layer's quads bounds to the specified Vector (flash target) or Array (other targets)
	   @param	boundsData
	   @param	renderData
	   @param	renderOffsetX
	   @param	renderOffsetY
	**/
	abstract public function writeBoundsData(boundsData:#if flash Vector<Float> #else Array<Float> #end, renderOffsetX:Float, renderOffsetY:Float):Void;
	
	/**
	 * Advances time for the layer, controlled by the MassiveDisplay instance this layer was added to
	 * @param	time
	 */
	abstract public function advanceTime(time:Float):Void;
	
}