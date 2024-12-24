package scene;

import massive.data.QuadData;
import massive.display.MassiveDisplay;
import massive.display.MassiveQuadLayer;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.events.Event;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class MassiveQuads extends Scene implements IAnimatable
{
	public var numQuads:Int = 2000;
	public var useRandomAlpha:Bool = false;
	public var useRandomColor:Bool;
	public var useByteArray:Bool = true;
	
	private var _display:MassiveDisplay;
	private var _layer:MassiveQuadLayer;
	
	private var _quads:Array<MassiveQuad>;
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
		
		var stageWidth:Float = this.stage.stageWidth;
		var stageHeight:Float = this.stage.stageHeight;
		
		updateBounds();
		
		this._display = new MassiveDisplay();
		this._display.blendMode = BlendMode.NORMAL;
		this._display.touchable = false;
		this._display.bufferSize = numQuads;
		this._display.useByteArray = useByteArray;
		//this._display.useColor = false;
		addChild(this._display);
		
		this._layer = new MassiveQuadLayer();
		this._display.addLayer(this._layer);
		
		this._quads = new Array<MassiveQuad>();
		var quad:MassiveQuad;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...numQuads)
		{
			quad = new MassiveQuad();
			quad.x = Math.random() * stageWidth;
			quad.y = Math.random() * stageHeight;
			quad.width = this._quadWidth;
			quad.height = this._quadHeight;
			quad.rotation = Math.random() * (Math.PI * 2);
			
			if (this.useRandomAlpha) quad.colorAlpha = Math.random();
			if (this.useRandomColor)
			{
				quad.colorRed = Math.random();
				quad.colorGreen = Math.random();
				quad.colorBlue = Math.random();
			}
			
			speedVariance = Math.random();
			velocity = this._velocityBase + speedVariance * this._velocityRange;
			quad.velocityX = Math.cos(quad.rotation) * velocity;
			quad.velocityY = Math.sin(quad.rotation) * velocity;
			
			quad.alignPivot(Align.CENTER, Align.CENTER);
			
			this._quads[i] = quad;
			this._layer.addQuad(quad);
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
		for (quad in this._quads)
		{
			quad.x += quad.velocityX * time;
			quad.y += quad.velocityY * time;
			
			if (quad.x < this._left)
			{
				quad.x = this._right;
			}
			else if (quad.x > this._right)
			{
				quad.x = this._left;
			}
			
			if (quad.y < this._top)
			{
				quad.y = this._bottom;
			}
			else if (quad.y > this._bottom)
			{
				quad.y = this._top;
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