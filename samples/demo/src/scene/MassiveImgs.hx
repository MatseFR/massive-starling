package scene;
import openfl.Vector;
import scene.massive.MovingImg;

/**
 * ...
 * @author Matse
 */
class MassiveImgs extends MassiveSceneBase 
{
	#if flash
	private var _imgList:Vector<MovingImg> = new Vector<MovingImg>();
	#else
	private var _imgList:Array<MovingImg> = new Array<MovingImg>();
	#end
	
	public function new() 
	{
		super();
	}
	
	private function init():Void
	{
		var img:MovingImg;
		
		for (i in 0...this.numObjects)
		{
			img = new MovingImg();
			initImg(img);
			this._imgList[i] = img;
		}
	}
	
	override public function advanceTime(time:Float):Void 
	{
		super.advanceTime(time);
		
		if (this._movement)
		{
			var img:MovingImg;
			for (i in 0...this.numObjects)
			{
				img = this._imgList[i];
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
	
}