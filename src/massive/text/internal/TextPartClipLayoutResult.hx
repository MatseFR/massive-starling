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
class TextPartClipLayoutResult extends TextPartLayoutResult 
{
	private static var _POOL:Array<TextPartClipLayoutResult> = new Array<TextPartClipLayoutResult>();
	
	public static function fromPool():TextPartClipLayoutResult
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextPartClipLayoutResult();
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
			var texture:Texture = cast(this.elementLocations[0], ClipLocation).animation.referenceFrame.rootTexture;
			this.textureIndex = display.getTextureIndex(texture);
			if (this.textureIndex == -1)
			{
				this.textureIndex = display.addTexture(texture);
				addedTextures[addedTextures.length] = texture;
			}
		}
		
		var clip:Clip;
		var location:ClipLocation;
		var count:Int = this.elementLocations.length;
		
		var clipIndex:Int = clipStorage.length;
		
		#if flash
		Clip.fromPoolVector(count, clipStorage);
		#else
		Clip.fromPoolArray(count, clipStorage);
		#end
		
		for (i in 0...count)
		{
			clip = clipStorage[clipIndex + i];
			clip.textureIndex = this.textureIndex;
			location = cast this.elementLocations[i];
			clip.play(location.animation);
			clip.x = location.x;
			clip.y = location.y;
			clip.scale = location.scale;
			datas[datas.length] = clip;
		}
	}
	
}