package scene.object;

/**
 * @author Matse
 */
interface IMassiveClip 
{
	public var x:Float;
	public var y:Float;
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var textureIndex(get, set):Float;
	public var invertX(get, set):Bool;
	public var invertY(get, set):Bool;
	public var frameDelta:Float;
	public var red(get, set):Float;
	public var green(get, set):Float;
	public var blue(get, set):Float;
	public var alpha(get, set):Float;
	public var velocityX:Float;
	public var velocityY:Float;
}