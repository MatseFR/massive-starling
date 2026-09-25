package massive.text.internal;
import massive.display.Img;
import massive.display.MassiveDisplay;
import massive.text.FontStyle;
import massive.text.GlyphLocation;
import massive.text.TextFormat;
import massive.text.TextPart;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class TextPartLayoutResult 
{
	private static var _POOL:Array<TextPartLayoutResult> = new Array<TextPartLayoutResult>();
	
	public static function fromPool(fromPart:TextPart, style:FontStyle):TextPartLayoutResult
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(fromPart, style);
		return new TextPartLayoutResult(fromPart, style);
	}
	
	public var format:TextFormat = new TextFormat();
	public var glyphLocations:Array<GlyphLocation> = new Array<GlyphLocation>();
	public var images:Array<Img> = new Array<Img>();
	public var style:FontStyle;
	
	public function new(fromPart:TextPart, style:FontStyle) 
	{
		this.format.copyFrom(fromPart.format);
		this.style = style;
	}
	
	public function clear():Void
	{
		this.glyphLocations.resize(0);
		this.images.resize(0);
		this.style = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(fromPart:TextPart, style:FontStyle):TextPartLayoutResult
	{
		this.format.copyFrom(fromPart.format);
		this.style = style;
		return this;
	}
	
	#if flash
	public function getImages(display:MassiveDisplay, imgs:Vector<Img>):Void
	#else
	public function getImages(display:MassiveDisplay, imgs:Array<Img>):Void
	#end
	{
		var texIndex:Int = display.getTextureIndex(this.style.texture);
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
		var count:Int = this.glyphLocations.length;
		Img.fromPoolArray(count, this.images);
		
		for (i in 0...count)
		{
			location = this.glyphLocations[i];
			img = this.images[i];
			img.frame = location.glyph.frame;
			img.textureIndex = texIndex;
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
			
			imgs[imgs.length] = img;
		}
	}
	
}