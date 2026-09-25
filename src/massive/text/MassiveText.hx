package massive.text;
import haxe.Json;
import massive.text.internal.TextLayoutResult;
import massive.text.internal.TextPartLayoutResult;
import massive.text.lang.LangRules;
import openfl.errors.Error;

/**
 * ...
 * @author Matse
 */
class MassiveText 
{
	public static inline var CHAR_MINUS:Int		 	  = 45;
	public static inline var CHAR_MISSING:Int         =  0;
    public static inline var CHAR_TAB:Int             =  9;
    public static inline var CHAR_NEWLINE:Int         = 10;
    public static inline var CHAR_CARRIAGE_RETURN:Int = 13;
    public static inline var CHAR_SPACE:Int           = 32;
	
	public static inline var EPSILON:Float = 0.00001;
	
	public static var CHAR_HYPHEN(default, null):Int = CHAR_MINUS;
	public static var CLOSE_PARAMS:String = "}!";
	public static var OPEN_PARAMS:String = "!{";
	
	public static var defaultFont:MassiveFont;
	public static var defaultLangRules:LangRules;
	public static var defaultTextFormat:TextFormat;// = new TextFormat();
	public static var defaultTextOptions:TextOptions;// = new TextOptions();
	
	private static var _fonts:Map<String, MassiveFont> = new Map<String, MassiveFont>();
	
	public static function getFont(name:String):MassiveFont
	{
		return _fonts.get(name);
	}
	
	public static function getFontNames(?names:Array<String>):Array<String>
	{
		if (names == null) names = new Array<String>();
		
		for (name in _fonts.keys())
		{
			names[names.length] = name;
		}
		
		return names;
	}
	
	public static function hasFont(name:String):Bool
	{
		return _fonts.exists(name);
	}
	
	public static function registerFont(font:MassiveFont):Void
	{
		_fonts.set(font.name, font);
		if (defaultFont == null) defaultFont = font;
	}
	
	public static function unregisterFont(font:MassiveFont):Void
	{
		_fonts.remove(font.name);
	}
	
	public static function parseText(txt:String, text:Text = null):Text
	{
		if (text == null) text = Text.fromPool();
		
		var currIndex:Int = 0;
		var openIndex:Int;
		var closeIndex:Int;
		var str:String;
		var json:Dynamic;
		var part:TextPart;
		var numChars:Int = txt.length;
		
		part = TextPart.fromPool();
		text.addPart(part);
		
		while (true)
		{
			openIndex = txt.indexOf(OPEN_PARAMS, currIndex);
			if (openIndex != -1)
			{
				if (openIndex != currIndex)
				{
					part.text = txt.substring(currIndex, openIndex);
					part = TextPart.fromPool();
					text.addPart(part);
				}
				closeIndex = txt.indexOf(CLOSE_PARAMS, openIndex + OPEN_PARAMS.length);
				if (closeIndex != -1)
				{
					str = "{" + txt.substring(openIndex + OPEN_PARAMS.length, closeIndex) + "}";
					json = Json.parse(str);
					if (json.format != null) part.formatData = json.format;
					if (json.options != null) part.optionsData = json.options;
					if (json.anim != null) part.animationData = json.anim;
					if (json.animIn != null) part.animationInData = json.animIn;
					if (json.animOut != null) part.animationOutData = json.animOut;
				}
				else
				{
					// error : no params closing
					throw new Error("no params closing");
				}
				currIndex = closeIndex + CLOSE_PARAMS.length;
				if (currIndex == numChars) break;
			}
			else
			{
				part.text = txt.substring(currIndex, numChars);
				break;
			}
		}
		
		return text;
	}
	
	private static function setFormat(format:TextFormat):Void
	{
		_font = getFont(format.font);
		_fontStyle = _font.getFontStyle(format.style);
		_glyphMap = _fontStyle.glyphs;
		_hyphenGlyph = _fontStyle.hyphenGlyph;
		_lineHeight = _fontStyle.lineHeight;
		_kerning = format.kerning;
		_leading = format.leading;
		_spacing = format.letterSpacing;
		_fontSize = format.size != 0.0 ? format.size : _fontStyle.size;
		_fontScale = _fontSize / _fontStyle.size;
	}
	
	public static function processText(width:Float, height:Float, text:Text, langRules:LangRules):TextLayoutResult
	{
		if (text.format == null) text.format = defaultTextFormat;
		if (text.options == null) text.options = defaultTextOptions;
		if (langRules == null) langRules = defaultLangRules;
		
		var hAlign:String = text.format.horizontalAlign;
		var hAlignJustify:Bool = hAlign == TextAlign.JUSTIFY;
		var hAlignCenter:Bool = hAlign == TextAlign.CENTER;
		var hAlignRight:Bool = hAlign == TextAlign.RIGHT;
		var doHAlign:Bool = hAlignCenter || hAlignRight;
		var vAlign:String = text.format.verticalAlign;
		
		var options:TextOptions = text.options;
		var hyphenation:Bool = options.hyphenation && langRules != null;
		var hyphenationMinLength:Int = options.hyphenationMinLength;
		var hyphenationMinRatio:Float = options.hyphenationMinRatio;
		var intPositions:Bool = options.intPositions;
		var letterSpreading:Bool = options.letterSpreading;
		var letterSpreadingMax:Float = options.letterSpreadingMax;
		var letterSpreadingMinRatio:Float = options.letterSpreadingMinRatio;
		var padding:Float = options.padding;
		var wordWrap:Bool = options.wordWrap;
		
		var charID:Int;
		var charIndex:Int;
		var lastWhiteSpace:Int = -1;
		var lastCharID:Int = -1;
		var lastHyphen:Int = -1;
		var lineFull:Bool;
		var glyph:Glyph;
		var glyphLocation:GlyphLocation;
		var numChars:Int;
		var numCharsToRemove:Int;
		var numSpaces:Int = 0;
		var totalChars:Int = 0;
		
		var currentX:Float = 0;
		var currentY:Float = 0;
		var currentLine:Array<GlyphLocation> = GlyphLocation.arrayFromPool();
		var currentWord:Array<GlyphLocation> = GlyphLocation.arrayFromPool();
		
		var hyphenationAllowed:Bool;
		var hyphenationOccured:Bool;
		var letterSpreadingOccured:Bool = false;
		var index:Int;
		var ratio:Float;
		var remainingWidth:Float = 0.0;
		var testLocation:GlyphLocation;
		var testWord:Array<GlyphLocation> = GlyphLocation.arrayFromPool();
		var word:Array<GlyphLocation>;
		var nextCharID:Int;
		var testGlyph:Glyph;
		var cumulatedOffset:Float;
		var spreadWidth:Float = 0.0;
		var intIncrement:Float;
		var intPositionStep:Float = 1.0;
		var intCounter:Float;
		
		var part:TextPart;
		var txt:String;
		var textResult:TextLayoutResult = TextLayoutResult.fromPool();
		var partResult:TextPartLayoutResult;
		var numParts:Int = text.numParts;
		var allChars:Int = text.numChars;
		var locations:Array<GlyphLocation> = null;
		
		var finished:Bool = false;
		
		var scale:Float = 1.0;
		
		var containerWidth:Float = width;
		var containerHeight:Float = height;
		
		var i:Int;
		var j:Int;
		
		for (p in 0...numParts)
		{
			part = text.parts[p];
			setFormat(part.format);
			if (p == 0)
			{
				scale = _fontScale;
				containerWidth = (width - padding * 2) / scale;
				containerHeight = (height - padding * 2) / scale;
				if (intPositions) intPositionStep = 1.0 / scale;
			}
			if (_fontSize > containerHeight) break; // TODO this should be checked earlier, only once
			
			txt = part.text;
			partResult = TextPartLayoutResult.fromPool(part, _fontStyle);
			textResult.addPart(partResult);
			
			numChars = txt.length;
			i = 0;
			while (i < numChars)
			{
				lineFull = false;
				charID = txt.charCodeAt(i);
				charIndex = totalChars + i;
				
				if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
				{
					lineFull = true;
				}
				else
				{
					glyph = _glyphMap.get(charID);
					if (glyph == null)
					{
						trace("[MassiveText] Character '" + txt.charAt(i) + "' not found");
						charID = CHAR_MISSING;
						glyph = _glyphMap.get(charID);
					}
					
					if (charID == CHAR_SPACE || charID == CHAR_TAB)
					{
						lastWhiteSpace = charIndex;
						lastHyphen = -1;
						if (currentWord.length != 0)
						{
							_words[_words.length] = currentWord;
							currentWord = GlyphLocation.arrayFromPool();
						}
						++numSpaces;
					}
					else if (charID == CHAR_HYPHEN && lastWhiteSpace != charIndex - 1)
					{
						lastHyphen = charIndex;
					}
					
					if (_kerning)
					{
						currentX += glyph.getKerning(lastCharID);
					}
					
					glyphLocation = GlyphLocation.fromPool(glyph);
					glyphLocation.index = charIndex;
					glyphLocation.x = currentX + glyph.xOffset;
					glyphLocation.y = currentY + glyph.yOffset;
					currentLine[currentLine.length] = glyphLocation;
					currentWord[currentWord.length] = glyphLocation;
					glyphLocation.textPart = partResult;
					
					currentX += glyph.xAdvance + _spacing;
					lastCharID = charID;
					
					if (glyphLocation.x + glyph.width > containerWidth)
					{
						hyphenationAllowed = hyphenation && !glyph.isSpace;
						
						if (wordWrap && hyphenationAllowed)
						{
							// we want to know how much space there will be if we put this entire word on the next line
							if (lastWhiteSpace != -1)
							{
								numCharsToRemove = charIndex - lastWhiteSpace;
								j = 1;
								while (true)
								{
									index = currentLine.length - (numCharsToRemove + j);
									if (index < 0)
									{
										remainingWidth = containerWidth;
										break;
									}
									testLocation = currentLine[index];
									if (!testLocation.isSpace)
									{
										remainingWidth = containerWidth - (testLocation.x + testLocation.glyph.width);
										break;
									}
									++j;
								}
								ratio = remainingWidth / containerWidth;
								hyphenationAllowed = ratio >= hyphenationMinRatio;
							}
						}
						
						hyphenationOccured = false;
						if (hyphenationAllowed)
						{
							for (c in 0...currentWord.length)
							{
								testLocation = currentWord[c];
								if (testLocation.isSpace) continue;
								testWord[testWord.length] = testLocation;
							}
							
							index = -1;
							j = testWord.length - 2; // we already kow that the last char doesn't fit
							while (j >= 0)
							{
								testLocation = testWord[j];
								if (testLocation.isHyphen || testLocation.x + testLocation.glyph.xAdvance + _hyphenGlyph.xOffset + _hyphenGlyph.width <= containerWidth)
								{
									index = j;
									break;
								}
								--j;
							}
							
							if (index != -1)
							{
								j = i + 1;
								if (j < numChars)
								{
									while (true)
									{
										nextCharID = txt.charCodeAt(j);
										if (nextCharID == CHAR_SPACE || nextCharID == CHAR_TAB || nextCharID == CHAR_NEWLINE || nextCharID == CHAR_CARRIAGE_RETURN) break;
										testGlyph = _glyphMap.get(nextCharID);
										if (testGlyph == null) break; // missing char
										if (testGlyph.isPunctuation) break; // TODO we shouldn't break punctuation ?
										testLocation = GlyphLocation.fromPool(testGlyph);
										testWord[testWord.length] = testLocation;
										++j;
										if (j == numChars) break;
									}
								}
								
								if (testWord.length >= hyphenationMinLength)
								{
									if (lastHyphen != -1)
									{
										index = langRules.getBreakIndexWithHyphens(testWord, index, hyphenationMinLength);
									}
									else
									{
										index = langRules.getBreakIndex(testWord, index);
									}
									
									if (index != -1)
									{
										hyphenationOccured = true;
										testLocation = testWord[index];
										numCharsToRemove = charIndex - testLocation.index;
										i -= numCharsToRemove; // TODO check that
										currentLine.resize(currentLine.length - numCharsToRemove);
										currentWord.resize(currentWord.length - numCharsToRemove);
										
										if (!testLocation.isHyphen)
										{
											glyphLocation = GlyphLocation.fromPool(_hyphenGlyph);
											glyphLocation.index = totalChars + i;
											glyphLocation.x = testLocation.x + testLocation.glyph.xAdvance + _hyphenGlyph.xOffset;
											glyphLocation.y = currentY + _hyphenGlyph.yOffset;
											currentLine[currentLine.length] = glyphLocation;
											currentWord[currentWord.length] = glyphLocation;
											glyphLocation.textPart = partResult;
										}
										_words[_words.length] = currentWord;
									}
								}
							}
							testWord.resize(0);
						}
						
						if (!hyphenationOccured)
						{
							if (wordWrap)
							{
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
									numCharsToRemove = charIndex - lastWhiteSpace;
									currentLine.resize(currentLine.length - numCharsToRemove);
									if (currentWord.length > numCharsToRemove + 1)
									{
										currentWord.resize(currentWord.length - (numCharsToRemove + 1));
										_words[_words.length] = currentWord;
									}
								}
								
								if (currentLine.length == 0) break;
								
								i -= numCharsToRemove;
							}
							else
							{
								currentLine.pop(); // TODO : see if resize() is faster
								
								// continue with next line, if there is one
								// TODO : change to handle CHAR_CARRIAGE_RETURN too
								while (i < numChars - 1 && txt.charCodeAt(i) != CHAR_NEWLINE)
								{
									++i;
								}
							}
						}
						
						lineFull = true;
						
						charIndex = totalChars + i;
						if (lastWhiteSpace == charIndex)
						{
							// TODO : compare .resize() and .pop() speeds
							currentLine.pop();
						}
						
						// JUSTIFY
						if (hAlignJustify)
						{
							glyphLocation = currentLine[currentLine.length - 1];
							currentX = glyphLocation.x + glyphLocation.glyph.width;
							remainingWidth = containerWidth - currentX;
							
							cumulatedOffset = 0.0;
							
							if (letterSpreading)
							{
								letterSpreadingOccured = false;
								ratio = remainingWidth / containerWidth;
								if (ratio >= letterSpreadingMinRatio)
								{
									spreadWidth = remainingWidth / (currentLine.length - 1);
									if (!intPositions || spreadWidth >= intPositionStep)
									{
										spreadWidth = Math.min(spreadWidth, letterSpreadingMax);
										if (intPositions)
										{
											intIncrement = spreadWidth % intPositionStep;
											spreadWidth -= intIncrement;
										}
										
										for (c in 1...currentLine.length)
										{
											cumulatedOffset += spreadWidth;
											currentLine[c].x += cumulatedOffset;
										}
										
										cumulatedOffset = 0.0;
										currentX = glyphLocation.x + glyphLocation.glyph.width;
										remainingWidth = containerWidth - currentX;
										spreadWidth = remainingWidth / (_words.length - 1);
										letterSpreadingOccured = true;
									}
								}
							}
							
							if (intPositions)
							{
								if (!letterSpreadingOccured)
								{
									spreadWidth = remainingWidth / (_words.length - 1);
								}
								intIncrement = spreadWidth % intPositionStep;
								spreadWidth -= intIncrement;
								intCounter = 0.0;
								
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
				
				if (totalChars + i == allChars - 1)
				{
					_lines[_lines.length] = currentLine;
				}
				else if (lineFull)
				{
					_lines[_lines.length] = currentLine;
					
					if (currentY + _lineHeight + _leading + _fontStyle.size <= containerHeight)
					{
						currentLine = GlyphLocation.arrayFromPool();
						_words.resize(0);
						currentWord.resize(0);
						currentX = 0;
						currentY += _lineHeight + _leading;
						lastWhiteSpace = -1;
						lastHyphen = -1;
						lastCharID = -1;
						numSpaces = 0;
					}
					else
					{
						finished = true;
						break;
					}
				}
				++i;
			}
			totalChars += numChars;
			if (finished) break;
		}
		
		var numLines:Int = _lines.length;
		var bottom:Float = currentY + _lineHeight;
		var xOffset:Int = 0;
		var yOffset:Int = 0;
		var right:Float;
		
		if (vAlign == TextAlign.BOTTOM)
		{
			yOffset = Std.int(containerHeight - bottom);
		}
		else if (vAlign == TextAlign.CENTER)
		{
			yOffset = Std.int((containerHeight - bottom) / 2);
		}
		
		if (yOffset < 0) yOffset = 0;
		
		partResult = null;
		
		for (lineID in 0...numLines)
		{
			currentLine = _lines[lineID];
			numChars = currentLine.length;
			
			if (numChars == 0) continue;
			
			if (doHAlign)
			{
				testLocation = currentLine[currentLine.length - 1];
				right = testLocation.x - testLocation.glyph.xOffset + testLocation.glyph.xAdvance;
				
				if (hAlignRight)
				{
					xOffset = Std.int(containerWidth - right);
				}
				else if (hAlignCenter)
				{
					xOffset = Std.int((containerWidth - right) / 2);
				}
			}
			
			for (c in 0...numChars)
			{
				glyphLocation = currentLine[c];
				if (glyphLocation.glyph.width > 0 && glyphLocation.glyph.height > 0)
				{
					if (glyphLocation.textPart != partResult)
					{
						partResult = glyphLocation.textPart;
						locations = partResult.glyphLocations;
					}
					glyphLocation.x = (glyphLocation.x + xOffset) * scale + padding;
					glyphLocation.y = (glyphLocation.y + yOffset) * scale + padding;
					glyphLocation.scale = scale;
					locations[locations.length] = glyphLocation;
				}
			}
		}
		
		_lines.resize(0);
		_words.resize(0);
		
		return textResult;
	}
	
	// helper vars
	private static var _lines:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	private static var _words:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	private static var _font:MassiveFont;
	private static var _fontScale:Float;
	private static var _fontStyle:FontStyle;
	private static var _glyphMap:Map<Int, Glyph>;
	private static var _hyphenGlyph:Glyph;
	private static var _lineHeight:Float;
	private static var _kerning:Bool;
	private static var _leading:Float;
	private static var _spacing:Float;
	private static var _fontSize:Float;
	
}