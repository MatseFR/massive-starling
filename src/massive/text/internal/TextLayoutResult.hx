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
class TextLayoutResult 
{
	private static var _POOL:Array<TextLayoutResult> = new Array<TextLayoutResult>();
	
	public static function fromPool():TextLayoutResult
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextLayoutResult();
	}
	
	public var numParts(get, never):Int;
	public var partMap(default, null):Map<TextPart, TextPartLayoutResult> = new Map<TextPart, TextPartLayoutResult>();
	public var parts(default, null):Array<TextPartLayoutResult> = new Array<TextPartLayoutResult>();
	
	private inline function get_numParts():Int { return this.parts.length; }
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.partMap.clear();
		for (i in 0...this.parts.length)
		{
			this.parts[i].pool();
		}
		this.parts.resize(0);
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function addPart(part:TextPartLayoutResult):Void
	{
		this.partMap.set(part.part, part);
		this.parts[this.parts.length] = part;
	}
	
	public function getPartAt(index:Int):TextPartLayoutResult
	{
		return this.parts[index];
	}
	
	public function getPartLast():TextPartLayoutResult
	{
		if (this.parts.length == 0) return null;
		return this.parts[this.parts.length - 1];
	}
	
	public function removeLastPart():Void
	{
		var part:TextPartLayoutResult = this.parts.pop();
		this.partMap.remove(part.part);
		part.pool();
	}
	
	//public function removePart(part:TextPartLayoutResult):Void
	//{
		//this.parts.splice(this.parts.indexOf(part), 1);
	//}
	//
	//public function removePartAt(index:Int):Void
	//{
		//this.parts.splice(index, 1);
	//}
	
	#if flash
	public function getImages(display:MassiveDisplay, datas:Vector<Img>, imgStorage:Vector<Img>, clipStorage:Vector<Clip>, addedTextures:Vector<Texture>):Void
	#else
	public function getImages(display:MassiveDisplay, datas:Array<Img>, imgStorage:Array<Img>, clipStorage:Array<Clip>, addedTextures:Array<Texture>):Void
	#end
	{
		for (i in 0...this.parts.length)
		{
			this.parts[i].getImages(display, datas, imgStorage, clipStorage, addedTextures);
		}
	}
	
}