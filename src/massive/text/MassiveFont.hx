package massive.text;
import massive.data.Frame;
import massive.display.Img;
import massive.display.ImgContainer;
import openfl.errors.ArgumentError;
import openfl.geom.Rectangle;
import starling.text.MiniBitmapFont;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class MassiveFont 
{
	private static inline var CHAR_MISSING:Int         =  0;
    private static inline var CHAR_TAB:Int             =  9;
    private static inline var CHAR_NEWLINE:Int         = 10;
    private static inline var CHAR_CARRIAGE_RETURN:Int = 13;
    private static inline var CHAR_SPACE:Int           = 32;
	
	private static inline var EPSILON:Float = 0.000001;
	
	private static var _imgs:Array<Img> = new Array<Img>();
	private static var _lines:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	private static var _words:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	
	public var baseline:Float;
	//public var intPositions:Bool = true;
	public var lineHeight(default, null):Float;
	public var name(default, null):String;
	public var offsetX:Float;
	public var offsetY:Float;
	public var padding:Float;
	public var size(default, null):Float;
	public var texture(default, null):Texture;
	
	private var _glyphs:Map<Int, Glyph> = new Map<Int, Glyph>();

	public function new(texture:Texture = null, fontData:Dynamic = null) 
	{
		// if no texture is passed in, we create the minimal, embedded font
        if (texture == null && fontData == null)
        {
            texture = MiniBitmapFont.texture;
            fontData = MiniBitmapFont.xml;
        }
		
		this.name = "unknown";
		this.lineHeight = this.size = this.baseline = 14.0;
		this.offsetX = this.offsetY = this.padding = 0.0;
		this.texture = texture;
		
		addGlyph(CHAR_MISSING, new Glyph(CHAR_MISSING, null, 0, 0, 0));
		parseFontData(fontData);
	}
	
	public function addGlyph(charID:Int, glyph:Glyph):Void
	{
		this._glyphs.set(charID, glyph);
	}
	
	public function getGlyph(charID:Int):Glyph
	{
		return this._glyphs.get(charID);
	}
	
	public function hasGlyph(charID:Int):Bool
	{
		return this._glyphs.exists(charID);
	}
	
	public function getCharIDs(result:Array<Int> = null):Array<Int>
	{
		if (result == null) result = new Array<Int>();
		
		for (key in this._glyphs.keys())
		{
			result[result.length] = key;
		}
		return result;
	}
	
	public function hasChars(text:String):Bool
	{
		if (text == null) return true;
		
		var charID:Int;
		var numChars:Int = text.length;
		
		for (i in 0...numChars)
		{
			charID = text.charCodeAt(i);
			
			if (charID != CHAR_SPACE && charID != CHAR_TAB && charID != CHAR_NEWLINE &&
                charID != CHAR_CARRIAGE_RETURN && getGlyph(charID) == null)
            {
                return false;
            }
		}
		
		return true;
	}
	
	public function fillContainer(container:ImgContainer, width:Float, height:Float, text:String, format:TextFormat, wordWrap:Bool):Void
	{
		//var glyphLocations:Array<GlyphLocation> = arrangeChars(width, height, text, format, wordWrap);
		var glyphLocations:Array<GlyphLocation> = layoutChars(width, height, text, format, wordWrap);
		var numChars:Int = glyphLocations.length;
		var location:GlyphLocation;
		Img.fromPoolArray(numChars, _imgs);
		var img:Img;
		for (i in 0...numChars)
		{
			location = glyphLocations[i];
			img = _imgs[i];
			img.frame = location.glyph.frame;
			img.x = location.x;
			img.y = location.y;
			img.scaleX = img.scaleY = location.scale;
			img.color = format.color;
		}
		container.addChildren(_imgs);
		_imgs.resize(0);
		
		GlyphLocation.rechargePool();
	}
	
	public function layoutChars(width:Float, height:Float, text:String, format:TextFormat, wordWrap:Bool):Array<GlyphLocation>
	{
		var kerning:Bool = format.kerning;
        var leading:Float = format.leading;
        var spacing:Float = format.letterSpacing;
        var hAlign:String = format.horizontalAlign;
        var vAlign:String = format.verticalAlign;
        var fontSize:Float = format.size;
        var autoScale:Bool = false;// = options.autoScale;
		var intPositions:Bool = true;
        var wordWrap:Bool = wordWrap;//options.wordWrap;
		
		var finished:Bool = false;
		var glyphLocation:GlyphLocation;
		var numChars:Int;
		var containerWidth:Float = 0;
		var containerHeight:Float = 0;
		var scale:Float = 1;
		var i:Int;
		
		var lastWhiteSpace:Int;
		var lastCharID:Int;
		var currentLine:Array<GlyphLocation>;
		var currentWord:Array<GlyphLocation>;
		var currentX:Float;
		var currentY:Float = 0;
		
		var hAlignCenter:Bool = hAlign == TextAlign.CENTER;
		var hAlignJustify:Bool = hAlign == TextAlign.JUSTIFY;
		var hAlignRight:Bool = hAlign == TextAlign.RIGHT;
		
		//var vAlignCenter:Bool;
		//var vAlignRight:Bool;
		
		var lineFull:Bool;
		var charID:Int;
		var glyph:Glyph;
		var numCharsToRemove:Int;
		
		var remainingWidth:Float;
		var remainingSpace:Float;
		var spreadWidth:Float;
		var cumulatedOffset:Float;
		var word:Array<GlyphLocation>;
		
		var intCounter:Float;
		var intIncrement:Float;
		var intPositionStep:Float = 1.0;
		
		if (fontSize < 0) fontSize *= -this.size;
		
		while (!finished)
		{
			_lines.resize(0);
			_words.resize(0);
			scale = fontSize / this.size;
			containerWidth = (width - this.padding * 2) / scale;
			containerHeight = (height - this.padding * 2) / scale;
			if (intPositions) intPositionStep = 1.0 / scale;
			
			if (fontSize < containerHeight)
			{
				lastWhiteSpace = -1;
                lastCharID = -1;
				currentLine = GlyphLocation.arrayFromPool();
				currentWord = GlyphLocation.arrayFromPool();
				currentX = 0;
				currentY = 0;
				
				numChars = text.length;
				i = 0;
				while (i < numChars)
				{
					lineFull = false;
					charID = text.charCodeAt(i);
					
					if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
					{
						lineFull = true;
					}
					else
					{
						glyph = getGlyph(charID);
						if (glyph == null)
						{
							trace("[MassiveFont] Character '" + text.charAt(i) + "' not found");
							charID = CHAR_MISSING;
							glyph = getGlyph(charID);
						}
						
						if (charID == CHAR_SPACE || charID == CHAR_TAB)
						{
							lastWhiteSpace = i;
							if (currentWord.length != 0)
							{
								_words[_words.length] = currentWord;
								currentWord = GlyphLocation.arrayFromPool();
							}
						}
						
						if (kerning)
						{
							currentX += glyph.getKerning(lastCharID);
						}
						
						glyphLocation = GlyphLocation.fromPool(glyph);
						#if debug
						glyphLocation.char = text.charAt(i);
						#end
						glyphLocation.index = i;
						glyphLocation.x = currentX + glyph.xOffset;
						glyphLocation.y = currentY + glyph.yOffset;
						currentLine[currentLine.length] = glyphLocation;
						currentWord[currentWord.length] = glyphLocation;
						
						currentX += glyph.xAdvance + spacing;
						lastCharID = charID;
						
						if (glyphLocation.x + glyph.width > containerWidth)
						{
							if (wordWrap)
							{
								// when autoscaling, we must not split a word in half -> restart
                                if (autoScale && lastWhiteSpace == -1) break;
								
								if (lastWhiteSpace == -1)
								{
									numCharsToRemove = 1;
									currentLine.resize(currentLine.length - numCharsToRemove);
									if (currentWord.length > numCharsToRemove)
									{
										currentWord.resize(currentWord.length - numCharsToRemove);
										_words[_words.length] = currentWord;
									}
								}
								else
								{
									numCharsToRemove = i - lastWhiteSpace;
									currentLine.resize(currentLine.length - numCharsToRemove);
									
									if (currentWord.length > numCharsToRemove + 1)
									{
										currentWord.resize(currentWord.length - (numCharsToRemove + 1));
										_words[_words.length] = currentWord;
									}
								}
								
								if (currentLine.length == 0)
								{
									break;
								}
								
								i -= numCharsToRemove;
							}
							else
							{
								if (autoScale) break;
                                currentLine.pop();
								
								// continue with next line, if there is one
								while (i < numChars - 1 && text.charCodeAt(i) != CHAR_NEWLINE)
								{
									++i;
								}
							}
							
							lineFull = true;
							
							if (lastWhiteSpace == i)
							{
								// TODO : compare .resize() and .pop() speeds
								currentLine.pop();
								//currentLine.resize(currentLine.length - 1);
							}
							
							// JUSTIFY
							if (hAlignJustify)
							{
								glyphLocation = currentLine[currentLine.length - 1];
								currentX = glyphLocation.x + glyphLocation.glyph.xAdvance;
								remainingWidth = containerWidth - currentX;
								spreadWidth = remainingWidth / (_words.length - 1);
								
								cumulatedOffset = 0;
								
								if (intPositions)
								{
									remainingSpace = spreadWidth;
									intIncrement = remainingSpace % intPositionStep;
									spreadWidth -= intIncrement;
									intCounter = 0;
									
									for (c in 1..._words.length)
									{
										intCounter += intIncrement;
										if (intCounter + EPSILON >= intPositionStep)
										{
											intCounter -= intPositionStep;
											cumulatedOffset += spreadWidth + intPositionStep;
										}
										else
										{
											cumulatedOffset += spreadWidth;
										}
										word = _words[c];
										for (d in 0...word.length)
										{
											word[d].x += cumulatedOffset;
										}
									}
								}
								else
								{
									for (c in 1..._words.length)
									{
										cumulatedOffset += spreadWidth;
										word = _words[c];
										for (d in 0...word.length)
										{
											word[d].x += cumulatedOffset;
										}
									}
								}
							}
							//\JUSTIFY
						}
					}
					
					if (i == numChars - 1)
					{
						_lines[_lines.length] = currentLine;
						finished = true;
					}
					else if (lineFull)
					{
						_lines[_lines.length] = currentLine;
						
						if (currentY + this.lineHeight + leading + this.size <= containerHeight)
						{
							currentLine = GlyphLocation.arrayFromPool();
							_words.resize(0);
							currentWord = GlyphLocation.arrayFromPool();
							currentX = 0;
							currentY += this.lineHeight + leading;
							lastWhiteSpace = -1;
							lastCharID = - 1;
						}
						else
						{
							break;
						}
					}
					++i;
				}
			}
			
			if (autoScale && !finished && fontSize > 3)
			{
				fontSize -= 1;
			}
			else
			{
				finished = true;
			}
		}
		
		var finalLocations:Array<GlyphLocation> = GlyphLocation.arrayFromPool();
		var numLines:Int = _lines.length;
		var bottom:Float = currentY + this.lineHeight;
		var xOffset:Int;
		var yOffset:Int = 0;
		var line:Array<GlyphLocation>;
		var lastLocation:GlyphLocation;
		var right:Float;
		
		if (vAlign == Align.BOTTOM)
		{
			yOffset = Std.int(containerHeight - bottom);
		}
		else if (vAlign == Align.CENTER)
		{
			yOffset = Std.int((containerHeight - bottom) / 2);
		}
		
		if (yOffset < 0) yOffset = 0;
		
		for (lineID in 0...numLines)
		{
			line = _lines[lineID];
			numChars = line.length;
			
			if (numChars == 0) continue;
			
			xOffset = 0;
			lastLocation = line[line.length - 1];
			right = lastLocation.x - lastLocation.glyph.xOffset + lastLocation.glyph.xAdvance;
			
			if (hAlignRight)
			{
				xOffset = Std.int(containerWidth - right);
			}
			else if (hAlignCenter)
			{
				xOffset = Std.int((containerWidth - right) / 2);
			}
			
			for (c in 0...numChars)
			{
				glyphLocation = line[c];
				if (glyphLocation.glyph.width > 0 && glyphLocation.glyph.height > 0)
				{
					glyphLocation.x = (glyphLocation.x + xOffset + this.offsetX) * scale + this.padding;
					glyphLocation.y = (glyphLocation.y + yOffset + this.offsetY) * scale + this.padding;
					glyphLocation.scale = scale;
					finalLocations[finalLocations.length] = glyphLocation;
				}
			}
		}
		
		return finalLocations;
	}
	
	public function arrangeChars(width:Float, height:Float, text:String, format:TextFormat, wordWrap:Bool):Array<GlyphLocation>
	{
		if (text == null || text.length == 0) return GlyphLocation.arrayFromPool();
		
		var kerning:Bool = format.kerning;
        var leading:Float = format.leading;
        var spacing:Float = format.letterSpacing;
        var hAlign:String = format.horizontalAlign;
        var vAlign:String = format.verticalAlign;
        var fontSize:Float = format.size;
        var autoScale:Bool = false;// = options.autoScale;
        var wordWrap:Bool = wordWrap;//options.wordWrap;
		
		var finished:Bool = false;
		var glyphLocation:GlyphLocation;
		var numChars:Int;
		var containerWidth:Float = 0;
		var containerHeight:Float = 0;
		var scale:Float = 1;
		var i:Int;
		
		var lastWhiteSpace:Int;
		var lastCharID:Int;
		var currentLine:Array<GlyphLocation>;
		var currentX:Float;
		var currentY:Float = 0;
		
		if (fontSize < 0) fontSize *= -this.size;
		
		while (!finished)
		{
			_lines.resize(0);
			scale = fontSize / this.size;
			containerWidth = (width - this.padding * 2) / scale;
			containerHeight = (height - this.padding * 2) / scale;
			
			if (fontSize < containerHeight)
			{
				lastWhiteSpace = -1;
                lastCharID = -1;
				currentLine = GlyphLocation.arrayFromPool();
				currentX = 0;
				currentY = 0;
				
				numChars = text.length;
				i = 0;
				while (i < numChars)
				{
					var lineFull:Bool = false;
					var charID:Int = text.charCodeAt(i);
					
					if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
					{
						lineFull = true;
					}
					else
					{
						var glyph:Glyph = getGlyph(charID);
						if (glyph == null)
						{
							trace("[MassiveFont] Character '" + text.charAt(i) + "' not found");
							charID = CHAR_MISSING;
							glyph = getGlyph(charID);
						}
						
						if (charID == CHAR_SPACE || charID == CHAR_TAB)
						{
							lastWhiteSpace = i;
						}
						
						if (kerning)
						{
							currentX += glyph.getKerning(lastCharID);
						}
						
						glyphLocation = GlyphLocation.fromPool(glyph);
						glyphLocation.index = i;
						glyphLocation.x = currentX + glyph.xOffset;
						glyphLocation.y = currentY + glyph.yOffset;
						currentLine[currentLine.length] = glyphLocation;
						
						currentX += glyph.xAdvance + spacing;
						lastCharID = charID;
						
						if (glyphLocation.x + glyph.width > containerWidth)
						{
							if (wordWrap)
							{
								// when autoscaling, we must not split a word in half -> restart
                                if (autoScale && lastWhiteSpace == -1) break;
								
								var numCharsToRemove:Int = lastWhiteSpace == -1 ? 1 : i - lastWhiteSpace;
								currentLine.resize(currentLine.length - numCharsToRemove);
								
								if (currentLine.length == 0)
								{
									break;
								}
								
								i -= numCharsToRemove;
							}
							else
							{
								if (autoScale) break;
                                currentLine.pop();
								
								// continue with next line, if there is one
								while (i < numChars - 1 && text.charCodeAt(i) != CHAR_NEWLINE)
								{
									++i;
								}
							}
							
							lineFull = true;
						}
					}
					
					if (i == numChars - 1)
					{
						_lines[_lines.length] = currentLine;
						finished = true;
					}
					else if (lineFull)
					{
						_lines[_lines.length] = currentLine;
						
						if (lastWhiteSpace == i)
						{
							// TODO : compare .resize() and .pop() speeds
							currentLine.pop();
							//currentLine.resize(currentLine.length - 1);
						}
						
						if (currentY + this.lineHeight + leading + this.size <= containerHeight)
						{
							currentLine = GlyphLocation.arrayFromPool();
							currentX = 0;
							currentY += this.lineHeight + leading;
							lastWhiteSpace = -1;
							lastCharID = - 1;
						}
						else
						{
							break;
						}
					}
					++i;
				}
			}
			
			if (autoScale && !finished && fontSize > 3)
			{
				fontSize -= 1;
			}
			else
			{
				finished = true;
			}
		}
		
		var finalLocations:Array<GlyphLocation> = GlyphLocation.arrayFromPool();
		var numLines:Int = _lines.length;
		var bottom:Float = currentY + this.lineHeight;
		var xOffset:Int;
		var yOffset:Int = 0;
		var line:Array<GlyphLocation>;
		var lastLocation:GlyphLocation;
		var right:Float;
		
		if (vAlign == Align.BOTTOM)
		{
			yOffset = Std.int(containerHeight - bottom);
		}
		else if (vAlign == Align.CENTER)
		{
			yOffset = Std.int((containerHeight - bottom) / 2);
		}
		
		if (yOffset < 0) yOffset = 0;
		
		for (lineID in 0...numLines)
		{
			line = _lines[lineID];
			numChars = line.length;
			
			if (numChars == 0) continue;
			
			xOffset = 0;
			lastLocation = line[line.length - 1];
			right = lastLocation.x - lastLocation.glyph.xOffset + lastLocation.glyph.xAdvance;
			
			if (hAlign == Align.RIGHT)
			{
				xOffset = Std.int(containerWidth - right);
			}
			else if (hAlign == Align.CENTER)
			{
				xOffset = Std.int((containerWidth - right) / 2);
			}
			
			for (c in 0...numChars)
			{
				glyphLocation = line[c];
				if (glyphLocation.glyph.width > 0 && glyphLocation.glyph.height > 0)
				{
					glyphLocation.x = (glyphLocation.x + xOffset + this.offsetX) * scale + this.padding;
					glyphLocation.y = (glyphLocation.y + yOffset + this.offsetY) * scale + this.padding;
					glyphLocation.scale = scale;
					finalLocations[finalLocations.length] = glyphLocation;
				}
			}
		}
		
		return finalLocations;
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
            throw new ArgumentError("MassiveFont only supports XML data");
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
		
		this.name = info != null ? info.get("face") : "";
		this.size = info != null ? Std.parseFloat(info.get("size")) / scale : Math.NaN;
		this.lineHeight = common != null ? Std.parseFloat(common.get("lineHeight")) / scale : Math.NaN;
		this.baseline = common != null ? Std.parseFloat(common.get("base")) / scale : Math.NaN;
		
		if (this.size <= 0.0)
		{
			trace("[MassiveFont] Warning: invalid font size in '" + this.name + "' font.");
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