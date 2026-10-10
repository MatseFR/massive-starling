package massive.text.internal;
import massive.display.Clip;
import massive.display.Img;
import massive.display.MassiveDisplay;
#if flash
import openfl.Vector;
#end
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class TextPartImgLayoutResult extends TextPartLayoutResult 
{
	private static var _POOL:Array<TextPartImgLayoutResult> = new Array<TextPartImgLayoutResult>();
	
	public static function fromPool():TextPartImgLayoutResult
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextPartImgLayoutResult();
	}
	
	public function new() 
	{
		super();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	#if flash
	public function getImages(display:MassiveDisplay, datas:Vector<Img>, imgStorage:Vector<Img>, clipStorage:Vector<Clip>, addedTextures:Vector<Texture>):Void
	#else
	public function getImages(display:MassiveDisplay, datas:Array<Img>, imgStorage:Array<Img>, clipStorage:Array<Clip>, addedTextures:Array<Texture>):Void
	#end
	{
		if (this.elementLocations.length == 0) return;
		
		if (this.textureIndex == -1)
		{
			var texture:Texture = this.elementLocations[0].frame.rootTexture;
			this.textureIndex = display.getTextureIndex(texture);
			if (this.textureIndex == -1)
			{
				this.textureIndex = display.addTexture(texture);
				addedTextures[addedTextures.length] = texture;
			}
		}
		
		var img:Img;
		var location:ImgLocation;
		
		var count:Int = this.elementLocations.length;
		
		var dataIndex:Int = datas.length;
		#if flash
		Img.fromPoolVector(count, datas);
		#else
		Img.fromPoolArray(count, datas);
		#end
		
		for (i in 0...count)
		{
			location = cast this.elementLocations[i];
			img = datas[dataIndex + i];
			img.frame = location.frame;
			img.textureIndex = this.textureIndex;
			img.x = location.x;
			img.y = location.y;
			img.scale = location.scale;
			imgStorage[imgStorage.length] = img;
		}
	}
	
}