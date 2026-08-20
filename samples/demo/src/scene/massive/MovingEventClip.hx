package scene.massive;

import massive.display.EventClip;

/**
 * ...
 * @author Matse
 */
class MovingEventClip extends EventClip implements IMassiveClip
{
	public var speedVariance:Float;
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new() 
	{
		super();
		
	}
	
}