package scene.massive;

import massive.data.Frame;
import massive.display.Img;

/**
 * ...
 * @author Matse
 */
class MovingImg extends Img implements IMassiveImg
{
	public var speedVariance:Float;
	public var velocityX:Float;
	public var velocityY:Float;

	public function new(frame:Frame=null) 
	{
		super(frame);
		
	}
	
}