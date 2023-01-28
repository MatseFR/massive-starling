package scene;

import massive.data.QuadData;
import massive.display.MassiveDisplay;
import massive.display.MassiveQuadLayer;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class MassiveQuads extends Sprite implements IAnimatable
{
	public var numQuads:Int = 2000;
	public var useAlpha:Bool = false;
	public var useByteArray:Bool = true;
	
	private var _display:MassiveDisplay;
	private var _layer:MassiveQuadLayer;
	
	private var _quads:Array<MassiveQuad>;
	private var _quadWidth:Float = 20;
	private var _quadHeight:Float = 20;
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	private var _top:Float;
	private var _bottom:Float;
	private var _left:Float;
	private var _right:Float;
	private var _space:Float = 20;

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
		
		_top = -_space;
		_bottom = stageHeight + _space;
		_left = -_space;
		_right = stageWidth + _space;
		
		_display = new MassiveDisplay();
		_display.blendMode = BlendMode.NORMAL;
		_display.touchable = false;
		_display.bufferSize = numQuads;
		_display.useByteArray = useByteArray;
		//_display.useColor = false;
		addChild(_display);
		
		_layer = new MassiveQuadLayer();
		_display.addLayer(_layer);
		
		_quads = new Array<MassiveQuad>();
		var quad:MassiveQuad;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...numQuads)
		{
			quad = new MassiveQuad();
			quad.x = Math.random() * stageWidth;
			quad.y = Math.random() * stageHeight;
			quad.width = _quadWidth;
			quad.height = _quadHeight;
			quad.rotation = Math.random() * Math.PI;
			
			if (useAlpha) quad.colorAlpha = Math.random();
			quad.colorRed = Math.random();
			quad.colorGreen = Math.random();
			quad.colorBlue = Math.random();
			
			speedVariance = Math.random();
			velocity = _velocityBase + speedVariance * _velocityRange;
			quad.velocityX = Math.cos(quad.rotation) * velocity;
			quad.velocityY = Math.sin(quad.rotation) * velocity;
			
			quad.alignPivot(Align.CENTER, Align.CENTER);
			
			_quads[i] = quad;
			_layer.addQuad(quad);
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function dispose():Void 
	{
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

class MassiveQuad extends QuadData
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new()
	{
		super();
	}
}