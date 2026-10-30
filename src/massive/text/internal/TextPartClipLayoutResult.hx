package massive.text.internal;
import massive.data.Frame;
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
		
		var clip:Clip;
		var location:ClipLocation = cast this.elementLocations[0];
		var frame:Frame = location.clipConfig.animation.referenceFrame;
		
		if (this.textureIndex == -1) 
		{
			var texture:Texture = frame.rootTexture;
			this.textureIndex = display.getTextureIndex(texture);
			if (this.textureIndex == -1)
			{
				this.textureIndex = display.addTexture(texture);
				addedTextures[addedTextures.length] = texture;
			}
		}
		
		var count:Int = this.elementLocations.length;
		
		var clipIndex:Int = clipStorage.length;
		
		#if flash
		Clip.fromPoolVector(count, clipStorage);
		#else
		Clip.fromPoolArray(count, clipStorage);
		#end
		
		for (i in 0...count)
		{
			location = cast this.elementLocations[i];
			clip = clipStorage[clipIndex + i];
			location.clipConfig.toClip(clip);
			clip.textureIndex = this.textureIndex;
			clip.x = location.x + (frame.leftWidth * location.scale);
			clip.y = location.y + (frame.topHeight * location.scale);
			clip.scale *= location.scale;
			datas[datas.length] = clip;
		}
	}
	
}