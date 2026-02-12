package scene;

import starling.display.Sprite;

/**
 * ...
 * @author Matse
 */
abstract class Scene extends Sprite 
{
	public var animation(get, set):Bool;
	public var autoUpdateBounds(get, set):Bool;
	public var movement(get, set):Bool;
	
	private var _animation:Bool;
	private function get_animation():Bool { return this._animation; }
	private function set_animation(value:Bool):Bool
	{
		return this._animation = value;
	}
	
	private var _autoUpdateBounds:Bool;
	private function get_autoUpdateBounds():Bool { return this._autoUpdateBounds; }
	private function set_autoUpdateBounds(value:Bool):Bool
	{
		return this._autoUpdateBounds = value;
	}
	
	private var _movement:Bool;
	private function get_movement():Bool { return this._movement; }
	private function set_movement(value:Bool):Bool
	{
		return this._movement = value;
	}
	
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
		
		this._top = -this._space;
		this._bottom = stageHeight + this._space;
		this._left = -this._space;
		this._right = stageWidth + this._space;
	}
	
}