package scene;

import starling.display.Sprite;

/**
 * ...
 * @author Matse
 */
class Scene extends Sprite 
{
	private var _top:Float;
	private var _bottom:Float;
	private var _left:Float;
	private var _right:Float;
	private var _space:Float = 20;

	public function new() 
	{
		super();
		
	}
	
	public function updateBounds():Void
	{
		var stageWidth:Float = stage.stageWidth;
		var stageHeight:Float = stage.stageHeight;
		
		_top = -_space;
		_bottom = stageHeight + _space;
		_left = -_space;
		_right = stageWidth + _space;
	}
	
}