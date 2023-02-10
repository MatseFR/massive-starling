package scene;

import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.utils.Color;

/**
 * ...
 * @author Matse
 */
class ClassicQuads extends Scene implements IAnimatable
{
	public var numQuads:Int = 2000;
	public var useRandomAlpha:Bool = false;
	public var useRandomColor:Bool;
	
	private var _quads:Array<MovingQuad>;
	private var _quadWidth:Float = 20;
	private var _quadHeight:Float = 20;
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		var stageWidth:Float = stage.stageWidth;
		var stageHeight:Float = stage.stageHeight;
		
		updateBounds();
		
		_quads = new Array<MovingQuad>();
		var quad:MovingQuad;
		var velocity:Float;
		for (i in 0...numQuads)
		{
			quad = new MovingQuad(_quadWidth, _quadHeight);
			if (useRandomAlpha) quad.alpha = Math.random();
			if (useRandomColor) quad.color = Color.rgb(Std.random(256), Std.random(256), Std.random(256));
			quad.touchable = false;
			quad.alignPivot();
			
			quad.x = Math.random() * stageWidth;
			quad.y = Math.random() * stageHeight;
			quad.rotation = Math.random() * Math.PI;
			
			velocity = _velocityBase + Math.random() * _velocityRange;
			quad.velocityX = Math.cos(quad.rotation) * velocity;
			quad.velocityY = Math.sin(quad.rotation) * velocity;
			
			_quads[i] = quad;
			addChild(quad);
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this);
		
		super.dispose();
	}
	
	public function advanceTime(time:Float):Void
	{
		for (quad in _quads)
		{
			quad.x += quad.velocityX * time;
			quad.y += quad.velocityY * time;
			
			if (quad.x < _left)
			{
				quad.x = _right;
			}
			else if (quad.x > _right)
			{
				quad.x = _left;
			}
			
			if (quad.y < _top)
			{
				quad.y = _bottom;
			}
			else if (quad.y > _bottom)
			{
				quad.y = _top;
			}
		}
	}
	
}

class MovingQuad extends Quad
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new(width:Float, height:Float, color:Int = 0xffffff)
	{
		super(width, height, color);
	}
}