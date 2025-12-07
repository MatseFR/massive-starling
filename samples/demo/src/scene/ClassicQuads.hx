package scene;

import massive.data.LookUp;
import massive.util.MathUtils;
import openfl.Vector;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Quad;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.filters.BlurFilter;
import starling.utils.Color;

/**
 * ...
 * @author Matse
 */
class ClassicQuads extends Scene implements IAnimatable
{
	public var displayScale:Float;
	public var numQuads:Int = 2000;
	public var useBlurFilter:Bool;
	public var useRandomAlpha:Bool = false;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	public var useSprite3D:Bool;
	
	private var _quads:#if flash Vector<MovingQuad> #else Array<MovingQuad> #end;
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
		
		#if flash
		this._quads = new Vector<MovingQuad>();
		#else
		this._quads = new Array<MovingQuad>();
		#end
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
			if (this.useSprite3D)
			{
				this._sprite3D.addChild(quad);
			}
			else
			{
				addChild(quad);
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
		if (this.useSprite3D)
		{
			this._sprite3D.rotationY += 0.01;
		}
		
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