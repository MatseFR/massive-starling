package scene.massive;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;

/**
 * @author Matse
 */
interface IMassiveImg 
{
	public var x:Float;
	public var y:Float;
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var skewX(get, set):Float;
	public var skewY(get, set):Float;
	public var frame(get, set):Frame;
	public var textureIndex(get, set):Float;
	public var invertX(get, set):Bool;
	public var invertY(get, set):Bool;
	public var red(get, set):Float;
	public var green(get, set):Float;
	public var blue(get, set):Float;
	public var alpha(get, set):Float;
	public var redOffset(get, set):Float;
	public var greenOffset(get, set):Float;
	public var blueOffset(get, set):Float;
	public var alphaOffset(get, set):Float;
	
	public var vertexColor(get, set):VertexColorData;
	public var vertexColorOffset(get, set):VertexColorData;
	public var vertexPosition(get, set):VertexPositionData;
	
	public var speedVariance:Float;
	public var velocityX:Float;
	public var velocityY:Float;
}