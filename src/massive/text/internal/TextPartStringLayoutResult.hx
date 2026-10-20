package massive.text.internal;
import massive.display.Clip;
import massive.display.Img;
import massive.display.MassiveDisplay;
import massive.text.FontStyle;
import massive.text.TextFormat;
import massive.text.TextPartString;
#if flash
import openfl.Vector;
#end
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class TextPartStringLayoutResult extends TextPartLayoutResult
{
	private static var _POOL:Array<TextPartStringLayoutResult> = new Array<TextPartStringLayoutResult>();
	
	public static function fromPool(fromPart:TextPartString, style:FontStyle):TextPartStringLayoutResult
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(fromPart, style);
		return new TextPartStringLayoutResult(fromPart, style);
	}
	
	public var format:TextFormat = new TextFormat();
	public var style:FontStyle;
	
	public function new(fromPart:TextPartString, style:FontStyle) 
	{
		super(fromPart);
		this.format.copyFrom(fromPart.format);
		this.style = style;
	}
	
	override public function clear():Void
	{
		this.style = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(fromPart:TextPartString, style:FontStyle):TextPartStringLayoutResult
	{
		this.format.copyFrom(fromPart.format);
		this.part = fromPart;
		this.style = style;
		return this;
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
			var texture:Texture = this.style.texture.root;
			this.textureIndex = display.getTextureIndex(texture);
			if (this.textureIndex == -1)
			{
				this.textureIndex = display.addTexture(texture);
				addedTextures[addedTextures.length] = texture;
			}
		}
		
		var img:Img;
		var location:GlyphLocation;
		var red:Float = this.format.red;
		var green:Float = this.format.green;
		var blue:Float = this.format.blue;
		var alpha:Float = this.format.alpha;
		var redOffset:Float = this.format.redOffset;
		var greenOffset:Float = this.format.greenOffset;
		var blueOffset:Float = this.format.blueOffset;
		var alphaOffset:Float = this.format.alphaOffset;
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
			img.red = red;
			img.green = green;
			img.blue = blue;
			img.alpha = alpha;
			img.redOffset = redOffset;
			img.greenOffset = greenOffset;
			img.blueOffset = blueOffset;
			img.alphaOffset = alphaOffset;
			img.scale = location.scale;
			imgStorage[imgStorage.length];
		}
	}
	
}