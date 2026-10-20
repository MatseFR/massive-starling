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
abstract class TextPartLayoutResult 
{
	public var elementLocations(default, null):Array<ElementLocation> = new Array<ElementLocation>();
	public var part(default, null):TextPart;
	public var textureIndex:Int = -1;
	
	public function new(part:TextPart) 
	{
		this.part = part;
	}
	
	public function clear():Void
	{
		this.elementLocations.resize(0);
		this.part = null;
		this.textureIndex = -1;
	}
	
	abstract public function pool():Void;
	
	#if flash
	abstract public function getImages(display:MassiveDisplay, datas:Vector<Img>, imgStorage:Vector<Img>, clipStorage:Vector<Clip>, addedTextures:Vector<Texture>):Void;
	#else
	abstract public function getImages(display:MassiveDisplay, datas:Array<Img>, imgStorage:Array<Img>, clipStorage:Array<Clip>, addedTextures:Array<Texture>):Void;
	#end
	
}