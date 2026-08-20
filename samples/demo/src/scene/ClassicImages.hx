package scene;
import flash.Vector;
import massive.util.MathUtils;
import scene.starling.IClassicImage;
import starling.display.Image;
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class ClassicImages extends ClassicSceneBase 
{
	#if flash
	private var _images:Vector<MovingImage> = new Vector<MovingImage>();
	#else
	private var _images:Array<MovingImage> = new Vector<MovingImage>();
	#end
	
	public function new() 
	{
		super();
	}
	
	private function init():Void
	{
		var numTextures:Int = this.textures.length;
		
		var img:MovingImage;
		var speedVariance:Float;
		var variant:Int;
		
		for (i in 0...this.numObjects)
		{
			variant = Std.random(numTextures);
			
			speedVariance = MathUtils.random();
			img = new MovingImage(this.textures[variant][Std.random(this.textures[variant].length)]);
			
			initImage(img, speedVariance);
			this._images[i] = img;
		}
	}
	
	override public function advanceTime(time:Float):Void
	{
		super.advanceTime(time);
		
		if (!this._movement) return;
		
		var img:MovingImage;
		for (i in 0...this.numObjects)
		{
			img = this._images[i];
			
			img.x += img.velocityX * time;
			img.y += img.velocityY * time;
			
			if (img.x < this._left)
			{
				img.x = this._right;
			}
			else if (img.x > this._right)
			{
				img.x = this._left;
			}
			
			if (img.y < this._top)
			{
				img.y = this._bottom;
			}
			else if (img.y > this._bottom)
			{
				img.y = this._top;
			}
		}
	}
	
}

class MovingImage extends Image implements IClassicImage
{
	public var velocityX:Float;
	public var velocityY:Float;
	
	public function new(texture:Texture)
	{
		super(texture);
	}
}