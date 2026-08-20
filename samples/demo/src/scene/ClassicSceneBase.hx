package scene;
import massive.util.MathUtils;
import openfl.Vector;
import scene.starling.IClassicImage;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.filters.BlurFilter;
import starling.textures.Texture;
import starling.utils.Color;

/**
 * ...
 * @author Matse
 */
abstract class ClassicSceneBase extends Scene implements IAnimatable
{
	public var multiTextureStyle:Bool;
	public var numObjects:Int = 1000;
	public var textures:Array<Vector<Texture>>;
	public var objectScale:Float = 1;
	public var useBlurFilter:Bool;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	public var useSprite3D:Bool;
	
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	private var _sprite3D:Sprite3D;
	
	#if flash
	private var _imageList:Vector<Image> = new Vector<Image>();
	#else
	private var _imageList:Array<Image> = new Array<Image>();
	#end
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this);
		
		super.dispose();
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
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
		
		if (this.useBlurFilter)
		{
			this.filter = new BlurFilter();
		}
		
		Starling.currentJuggler.add(this);
		
		init();
	}
	
	abstract private function init():Void;
	
	private function initImage(img:IClassicImage, speedVariance:Float):Void
	{
		img.x = MathUtils.random() * this.stage.stageWidth;
		img.y = MathUtils.random() * this.stage.stageHeight;
		img.scaleX = img.scaleY = this.objectScale;
		
		img.touchable = false;
		img.alignPivot();
		
		if (this.useRandomRotation) img.rotation = MathUtils.random() * MathUtils.PI2;
		if (this.useRandomAlpha) img.alpha = MathUtils.random();
		if (this.useRandomColor) img.color = Color.rgb(Std.random(256), Std.random(256), Std.random(256));
		
		var velocity:Float = this._velocityBase + speedVariance * this._velocityRange;
		img.velocityX = Math.cos(img.rotation) * velocity;
		img.velocityY = Math.sin(img.rotation) * velocity;
		
		if (img.velocityX < 0.0) img.scaleY *= -1.0;
		
		if (this.useSprite3D)
		{
			this._sprite3D.addChild(cast img);
		}
		else
		{
			addChild(cast img);
		}
		
		this._imageList[this._imageList.length] = cast img;
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
		
		if (!this.useRandomRotation && this._imageList != null)
		{
			var stageHeight:Float = this.stage.stageHeight;
			
			for (i in 0...this.numObjects)
			{
				this._imageList[i].y = MathUtils.random() * stageHeight;
			}
		}
	}
	
	public function advanceTime(time:Float):Void
	{
		if (this.useSprite3D)
		{
			this._sprite3D.rotationY += 0.01;
		}
	}
	
}