package massive.display;

/**
 * ...
 * @author Matse
 */
class MassiveRenderMode 
{
	/**
	   Use a `ByteArray` to store and upload vertex data. This seems to result in faster upload on flash/air target, but at a higher cpu cost.
	   This is the slowest option on all targets and should be avoided : I keep it to demonstrate how slow `ByteArray` is.
	**/
	static public inline var BYTEARRAY:String = "ByteArray";
	#if flash
	/**
	   Flash/Air target only
	   Use a `ByteArray` with domain memory to store and upload vertex data. This changes everything and makes `ByteArray` the fastest option.
	   This is the default setting on Flash/Air target.
	**/
	static public inline var BYTEARRAY_DOMAIN_MEMORY:String = "DomainMemoryByteArray";
	#end
	#if !flash
	/**
	   Non-Flash targets only
	   Use a `Float32Array` to store and upload vertex data. This is what `VertexBuffer3D` uses internally on non-Flash targets.
	   This is the fastest option and default setting on non-Flash targets.
	**/
	static public inline var FLOAT32ARRAY:String = "Float32Array";
	#end
	/**
	   Use a `Vector<Float>` to store and upload vertex data. This is a very good option on Flash/Air target (slightly slower than `BYTEARRAY_DOMAIN_MEMORY`).
	   On other targets, `VertexBuffer3D` copies values to a Float32Array for upload, which limits performance.
	**/
	static public inline var VECTOR:String = "Vector";
	
	static public function getValues():Array<String>
	{
		#if flash
		return [BYTEARRAY, BYTEARRAY_DOMAIN_MEMORY, VECTOR];
		#else
		return [BYTEARRAY, FLOAT32ARRAY, VECTOR];
		#end
	}
	
}