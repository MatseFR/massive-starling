package scene.starling;

/**
 * @author Matse
 */
interface IClassicImage 
{
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var rotation(get, set):Float;
	public var scaleX(get, set):Float;
	public var scaleY(get, set):Float;
	public var skewX(get, set):Float;
	public var skewY(get, set):Float;
	public var alpha(get, set):Float;
	public var color(get, set):UInt;
	public var touchable(get, set):Bool;
	
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function alignPivot(horizontalAlign:String="center",
                               verticalAlign:String="center"):Void;
}