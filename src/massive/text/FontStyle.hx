package massive.text;
import massive.data.Frame;
import openfl.errors.ArgumentError;
import openfl.geom.Rectangle;
import starling.text.MiniBitmapFont;
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class FontStyle 
{
	public var baseline:Float;
	public var fontName:String;
	public var glyphs(default, null):Map<Int, Glyph> = new Map<Int, Glyph>();
	public var hyphenGlyph(default, null):Glyph;
	public var lineHeight(default, null):Float;
	public var name(default, null):String;
	public var offsetX:Float;
	public var offsetY:Float;
	public var size(default, null):Float;
	public var spaceGlyph(default, null):Glyph;
	public var texture(default, null):Texture;

	public function new(name:String, texture:Texture = null, fontData:Dynamic = null) 
	{
		this.name = name;
		
		// if no texture is passed in, we create the minimal, embedded font
        if (texture == null && fontData == null)
        {
            texture = MiniBitmapFont.texture;
            fontData = MiniBitmapFont.xml;
        }
		
		this.lineHeight = this.size = this.baseline = 14.0;
		this.offsetX = this.offsetY = 0.0;
		this.texture = texture;
		
		addGlyph(MassiveText.CHAR_MISSING, new Glyph(MassiveText.CHAR_MISSING, null, 0, 0, 0));
		parseFontData(fontData);
		
		this.hyphenGlyph = getGlyph(MassiveText.CHAR_MINUS);
		if (this.hyphenGlyph == null)
		{
			this.hyphenGlyph = getGlyph(MassiveText.CHAR_MISSING);
		}
		else
		{
			this.hyphenGlyph.isHyphen = true;
		}
		
		var glyph:Glyph;
		glyph = getGlyph(MassiveText.CHAR_SPACE);
		if (glyph != null) glyph.isSpace = true;
		
		glyph = getGlyph(MassiveText.CHAR_TAB);
		if (glyph != null) glyph.isSpace = true;
	}
	
	public function addGlyph(charID:Int, glyph:Glyph):Void
	{
		this.glyphs.set(charID, glyph);
	}
	
	public function getGlyph(charID:Int):Glyph
	{
		return this.glyphs.get(charID);
	}
	
	public function hasGlyph(charID:Int):Bool
	{
		return this.glyphs.exists(charID);
	}
	
	public function getCharIDs(result:Array<Int> = null):Array<Int>
	{
		if (result == null) result = new Array<Int>();
		
		for (key in this.glyphs.keys())
		{
			result[result.length] = key;
		}
		return result;
	}
	
	public function hasChars(text:String):Bool
	{
		if (text == null) return true;
		
		var numChars:Int = text.length;
		
		for (i in 0...numChars)
		{
			if (getGlyph(text.charCodeAt(i)) == null) return false;
		}
		
		return true;
	}
	
	private function parseFontData(data:Dynamic):Void
	{
		try
        {
            var fontXml:Xml = null;
            if(#if (haxe_ver < 4.2) Std.is #else Std.isOfType #end(data, String))
                fontXml = Xml.parse(data).firstElement();
            else if(#if (haxe_ver < 4.2) Std.is #else Std.isOfType #end(data, Xml))
                fontXml = cast data;
            #if flash
            else if (#if (haxe_ver < 4.2) Std.is #else Std.isOfType #end(data, flash.xml.XML))
                fontXml = Xml.parse((data : flash.xml.XML).toString()).firstElement();
            #end
                
            parseFontXml(fontXml);
        }
        catch (error:Dynamic)
        {
            throw new ArgumentError("FontStyle only supports XML data");
        }
	}
	
	private function parseFontXml(fontXml:Xml):Void
	{
		var scale:Float = this.texture.scale;
		var frameRect:Rectangle = this.texture.frame;
		var frameX:Float = frameRect != null ? frameRect.x : 0.0;
		var frameY:Float = frameRect != null ? frameRect.y : 0.0;
		
		var info:Xml = null;
		var infoIterator:Iterator<Xml> = fontXml.elementsNamed("info");
		if (infoIterator.hasNext())
		{
			info = infoIterator.next();
		}
		if (info == null)
		{
			fontXml = fontXml.firstElement();
			infoIterator = fontXml.elementsNamed("info");
			if (infoIterator.hasNext())
			{
				info = infoIterator.next();
			}
		}
		
		var common:Xml = null;
		var commonIterator:Iterator<Xml> = fontXml.elementsNamed("common");
		if (commonIterator.hasNext())
		{
			common = commonIterator.next();
		}
		
		this.fontName = info != null ? info.get("face") : "";
		this.size = info != null ? Std.parseFloat(info.get("size")) / scale : Math.NaN;
		this.lineHeight = common != null ? Std.parseFloat(common.get("lineHeight")) / scale : Math.NaN;
		this.baseline = common != null ? Std.parseFloat(common.get("base")) / scale : Math.NaN;
		
		if (this.size <= 0.0)
		{
			trace("[FontStyle] Warning: invalid font size in '" + this.name + "' font.");
			this.size = (this.size == 0.0 ? 16.0 : this.size * -1.0);
		}
		
		var chars:Xml = null;
		var charsIterator:Iterator<Xml> = fontXml.elementsNamed("chars");
		if (charsIterator.hasNext())
		{
			chars = charsIterator.next();
		}
		if (chars != null)
		{
			for (charElement in chars.elementsNamed("char"))
			{
				var id:Int = Std.parseInt(charElement.get("id"));
				var xOffset:Float = Std.parseFloat(charElement.get("xoffset")) / scale;
				var yOffset:Float = Std.parseFloat(charElement.get("yoffset")) / scale;
				var xAdvance:Float = Std.parseFloat(charElement.get("xadvance")) / scale;
				
				var x:Float = Std.parseFloat(charElement.get("x")) / scale + frameX;
				var y:Float = Std.parseFloat(charElement.get("y")) / scale + frameY;
				var width:Float = Std.parseFloat(charElement.get("width")) / scale;
				var height:Float = Std.parseFloat(charElement.get("height")) / scale;
				
				var frame:Frame = Frame.fromPool(this.texture.root, x, y, width, height, false);
				var glyph:Glyph = new Glyph(id, frame, xOffset, yOffset, xAdvance);
				addGlyph(id, glyph);
			}
		}
		
		var kernings:Xml = null;
		var kerningsIterator:Iterator<Xml> = fontXml.elementsNamed("kernings");
		if (kerningsIterator.hasNext())
		{
			kernings = kerningsIterator.next();
		}
		if (kernings != null)
		{
			for (kerningElement in kernings.elementsNamed("kerning"))
			{
				var first:Int = Std.parseInt(kerningElement.get("first"));
				var second:Int = Std.parseInt(kerningElement.get("second"));
				var amount:Float = Std.parseFloat(kerningElement.get("amount")) / scale;
				if (hasGlyph(second)) getGlyph(second).addKerning(first, amount);
			}
		}
	}
	
}