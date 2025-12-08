package scene;

import massive.util.LookUp;
import massive.data.MassiveConstants;
import massive.data.QuadData;
import massive.display.MassiveDisplay;
import massive.display.MassiveQuadLayer;
import massive.util.MathUtils;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.filters.BlurFilter;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class MassiveQuads extends Scene implements IAnimatable
{
	public var displayScale:Float;
	public var numBuffers:Int = 2;
	public var numObjects:Int = 2000;
	public var useBlurFilter:Bool;
	public var useColor:Bool;
	public var useRandomAlpha:Bool = false;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	public var useByteArray:Bool;
	#if !flash
	public var useFloat32Array:Bool;
	#end
	public var useSprite3D:Bool;
	
	private var _displayList:Array<MassiveDisplay> = new Array<MassiveDisplay>();
	
	private var _quads:#if flash Vector<MassiveQuad> #else Array<MassiveQuad> #end;
	private var _quadWidth:Float = 100;
	private var _quadHeight:Float = 100;
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	private var _sprite3D:Sprite3D;
	
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
		
		if (this.useSprite3D)
		{
			this._sprite3D = new Sprite3D();
			this._sprite3D.pivotX = this.stage.stageWidth / 2;
			this._sprite3D.pivotY = this.stage.stageHeight / 2;
			this._sprite3D.x = this._sprite3D.pivotX;
			this._sprite3D.y = this._sprite3D.pivotY;
			addChild(this._sprite3D);
		}
		
		var numDisplays:Int = MathUtils.ceil(this.numObjects / MassiveConstants.MAX_QUADS);
		var display:MassiveDisplay;
		var layer:MassiveQuadLayer;
		var numQuads:Int;
		#if flash
		this._quads = new Vector<MassiveQuad>();
		#else
		this._quads = new Array<MassiveQuad>();
		#end
		var quad:MassiveQuad;
		var speedVariance:Float;
		var velocity:Float;
		for (i in 0...numDisplays)
		{
			numQuads = i == numDisplays - 1 ? this.numObjects % MassiveConstants.MAX_QUADS : MassiveConstants.MAX_QUADS;
			
			display = new MassiveDisplay();
			display.bufferSize = numQuads;
			display.numBuffers = this.numBuffers;
			display.useByteArray = this.useByteArray;
			display.useColor = this.useColor;
			#if !flash
			display.useFloat32Array = this.useFloat32Array;
			#end
			
			layer = new MassiveQuadLayer();
			display.addLayer(layer);
			
			for (j in 0...numQuads)
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
				
				this._quads[this._quads.length] = quad;
				layer.addQuad(quad);
			}
			
			if (this.useSprite3D)
			{
				this._sprite3D.addChild(display);
			}
			else
			{
				addChild(display);
			}
		}
		
		if (this.useBlurFilter)
		{
			this.filter = new BlurFilter();
		}
		
		Starling.currentJuggler.add(this);
	}
	
	override public function updateBounds():Void 
	{
		super.updateBounds();
		
		if (this._sprite3D != null)
		{
			this._sprite3D.pivotX = this.stage.stageWidth / 2;
			this._sprite3D.pivotY = this.stage.stageHeight / 2;
			this._sprite3D.x = this._sprite3D.pivotX;
			this._sprite3D.y = this._sprite3D.pivotY;
		}
		
		if (!this.useRandomRotation && this._quads != null)
		{
			var stageHeight:Float = this.stage.stageHeight;
			
			for (i in 0...this.numObjects)
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
		if (this.useSprite3D)
		{
			this._sprite3D.rotationY += 0.01;
		}
		
		var quad:MassiveQuad;
		for (i in 0...this.numObjects)
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