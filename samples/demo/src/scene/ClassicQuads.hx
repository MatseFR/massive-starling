package scene;

import massive.data.LookUp;
import massive.util.MathUtils;
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
	public var displayScale:Float;
	public var numQuads:Int = 2000;
	public var useRandomAlpha:Bool = false;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	
	private var _quads:Array<MovingQuad>;
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
		
		this._quads = new Array<MovingQuad>();
		var quad:MovingQuad;
		var velocity:Float;
		for (i in 0...this.numQuads)
		{
			quad = new MovingQuad(this._quadWidth, this._quadHeight);
			quad.scale = this.displayScale;
			if (this.useRandomAlpha) quad.alpha = MathUtils.random();
			if (this.useRandomColor) quad.color = Color.rgb(Std.random(256), Std.random(256), Std.random(256));
			quad.touchable = false;
			quad.alignPivot();
			
			quad.x = MathUtils.random() * stageWidth;
			quad.y = MathUtils.random() * stageHeight;
			if (this.useRandomRotation) quad.rotation = MathUtils.random() * MathUtils.PI2;
			
			velocity = this._velocityBase + MathUtils.random() * this._velocityRange;
			quad.velocityX = LookUp.cos(quad.rotation) * velocity;
			quad.velocityY = LookUp.sin(quad.rotation) * velocity;
			
			this._quads[i] = quad;
			addChild(quad);
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
		var quad:MovingQuad;
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

class MovingQuad extends Quad
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new(width:Float, height:Float, color:Int = 0xffffff)
	{
		super(width, height, color);
	}
}