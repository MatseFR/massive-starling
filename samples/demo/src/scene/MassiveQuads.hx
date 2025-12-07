package scene;

import massive.data.LookUp;
import massive.data.QuadData;
import massive.display.MassiveDisplay;
import massive.display.MassiveQuadLayer;
import massive.util.MathUtils;
import openfl.Vector;
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
	public var displayScale:Float;
	public var numBuffers:Int = 2;
	public var numQuads:Int = 2000;
	public var useColor:Bool;
	public var useRandomAlpha:Bool = false;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	public var useByteArray:Bool;
	#if !flash
	public var useFloat32Array:Bool;
	#end
	
	private var _display:MassiveDisplay;
	private var _layer:MassiveQuadLayer;
	
	private var _quads:#if flash Vector<MassiveQuad> #else Array<MassiveQuad> #end;
	private var _quadWidth:Float = 100;
	private var _quadHeight:Float = 100;
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
		this._display.bufferSize = this.numQuads;
		this._display.numBuffers = this.numBuffers;
		this._display.useByteArray = this.useByteArray;
		#if !flash
		this._display.useFloat32Array = this.useFloat32Array;
		#end
		this._display.useColor = this.useColor;
		addChild(this._display);
		
		this._layer = new MassiveQuadLayer();
		this._display.addLayer(this._layer);
		
		#if flash
		this._quads = new Vector<MassiveQuad>();
		#else
		this._quads = new Array<MassiveQuad>();
		#end
		var quad:MassiveQuad;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...this.numQuads)
		{
			quad = new MassiveQuad();
			quad.x = MathUtils.random() * stageWidth;
			quad.y = MathUtils.random() * stageHeight;
			quad.width = this._quadWidth;
			quad.height = this._quadHeight;
			quad.scaleX = quad.scaleY = this.displayScale;
			if (this.useRandomRotation) quad.rotation = MathUtils.random() * MathUtils.PI2;
			
			if (this.useRandomAlpha) quad.colorAlpha = MathUtils.random();
			if (this.useRandomColor)
			{
				quad.colorRed = MathUtils.random();
				quad.colorGreen = MathUtils.random();
				quad.colorBlue = MathUtils.random();
			}
			
			speedVariance = MathUtils.random();
			velocity = this._velocityBase + speedVariance * this._velocityRange;
			quad.velocityX = LookUp.cos(quad.rotation) * velocity;
			quad.velocityY = LookUp.sin(quad.rotation) * velocity;
			
			quad.alignPivot(Align.CENTER, Align.CENTER);
			
			this._quads[i] = quad;
			this._layer.addQuad(quad);
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function updateBounds():Void 
	{
		super.updateBounds();
		
		if (!this.useRandomRotation && this._quads != null)
		{
			var stageHeight:Float = this.stage.stageHeight;
			
			for (i in 0...this.numQuads)
			{
				this._quads[i].y = MathUtils.random() * stageHeight;
			}
		}
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this);
		
		super.dispose();
	}
	
	public function advanceTime(time:Float):Void
	{
		var quad:MassiveQuad;
		for (i in 0...this.numQuads)
		{
			quad = this._quads[i];
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