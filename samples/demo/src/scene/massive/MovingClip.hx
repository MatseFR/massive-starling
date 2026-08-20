package scene.massive;

import massive.display.Clip;

/**
 * ...
 * @author Matse
 */
class MovingClip extends Clip implements IMassiveClip
{
	public var speedVariance:Float;
	public var velocityX:Float;
	public var velocityY:Float;

	public function new() 
	{
		super();
		
	}
	
}