package massive.text;
import haxe.Json;
import massive.animation.AnimationCollection;
import massive.data.FrameCollection;
import massive.text.internal.ClipConfig;
import massive.text.internal.ClipLocation;
import massive.text.internal.ElementLocation;
import massive.text.internal.GlyphLocation;
import massive.text.internal.ImgConfig;
import massive.text.internal.ImgLocation;
import massive.text.internal.Line;
import massive.text.internal.LinePart;
import massive.text.internal.TextLayoutResult;
import massive.text.internal.TextPart;
import massive.text.internal.TextPartClipLayoutResult;
import massive.text.internal.TextPartImgLayoutResult;
import massive.text.internal.TextPartLayoutResult;
import massive.text.internal.TextPartStringLayoutResult;
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
	
	public static var animations(default, null):AnimationCollection = new AnimationCollection();
	public static var defaultFont:MassiveFont;
	public static var defaultLangRules:LangRules;
	public static var defaultTextFormat(get, set):TextFormat;// = new TextFormat();
	public static var defaultTextOptions(get, set):TextOptions;// = new TextOptions();
	public static var frames(default, null):FrameCollection = new FrameCollection();
	
	private static var _defaultTextFormat:TextFormat = new TextFormat();
	private static function get_defaultTextFormat():TextFormat { return _defaultTextFormat; }
	private static function set_defaultTextFormat(value:TextFormat):TextFormat
	{
		if (value == null)
		{
			_defaultTextFormat.clear();
		}
		else
		{
			_defaultTextFormat.copyFrom(value);
		}
		return _defaultTextFormat;
	}
	
	private static var _defaultTextOptions:TextOptions = new TextOptions();
	private static function get_defaultTextOptions():TextOptions { return _defaultTextOptions; }
	private static function set_defaultTextOptions(value:TextOptions):TextOptions
	{
		if (value == null)
		{
			_defaultTextOptions.clear();
		}
		else
		{
			_defaultTextOptions.copyFrom(value);
		}
		return _defaultTextOptions;
	}
	
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
		var part:TextPartString;
		var numChars:Int = txt.length;
		
		part = TextPartString.fromPool();
		text.addPart(part);
		
		while (true)
		{
			openIndex = txt.indexOf(OPEN_PARAMS, currIndex);
			if (openIndex != -1)
			{
				if (openIndex != currIndex)
				{
					part.text = txt.substring(currIndex, openIndex);
					part = TextPartString.fromPool();
					text.addPart(part);
				}
				closeIndex = txt.indexOf(CLOSE_PARAMS, openIndex + OPEN_PARAMS.length);
				if (closeIndex != -1)
				{
					str = "{" + txt.substring(openIndex + OPEN_PARAMS.length, closeIndex) + "}";
					json = Json.parse(str);
					if (json.format != null) part.formatData = json.format;
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
	
	public static function parseTextSafe(txt:String, text:Text = null):Text
	{
		if (text == null) text = Text.fromPool();
		
		var currIndex:Int = 0;
		var openIndex:Int;
		var closeIndex:Int;
		var nextIndex:Int;
		var str:String;
		var json:Dynamic = null;
		var part:TextPart;
		var clipPart:TextPartClip;
		var imgPart:TextPartImg;
		var strPart:TextPartString = null;
		var clipConfig:ClipConfig;
		var imgConfig:ImgConfig;
		var numChars:Int = txt.length;
		var nodeData:Array<Dynamic>;
		var nodeCount:Int;
		var ok:Bool;
		
		while (true)
		{
			openIndex = txt.indexOf(OPEN_PARAMS, currIndex);
			if (openIndex != -1)
			{
				closeIndex = txt.indexOf(CLOSE_PARAMS, openIndex + OPEN_PARAMS.length);
				if (closeIndex != -1)
				{
					nextIndex = txt.indexOf(OPEN_PARAMS, openIndex + OPEN_PARAMS.length);
					if (nextIndex == -1 || nextIndex > closeIndex)
					{
						str = "{" + txt.substring(openIndex + OPEN_PARAMS.length, closeIndex) + "}";
						ok = true;
						try
						{
							json = Json.parse(str);
						}
						catch (e)
						{
							ok = false;
						}
						if (ok)
						{
							if (openIndex != currIndex)
							{
								if (strPart == null)
								{
									strPart = TextPartString.fromPool();
									text.addPart(strPart);
								}
								strPart.text = txt.substring(currIndex, openIndex);
								strPart = null;
							}
							
							part = null;
							if (json.img != null)
							{
								part = imgPart = TextPartImg.fromPool();
								//if (json.img.frame != null)
								//{
									//imgPart.frames[imgPart.frames.length] = frames.get(json.img.frame);
								//}
								imgPart.imgConfigs[imgPart.imgConfigs.length] = ImgConfig.fromPool(json.img);
								text.addPart(imgPart);
							}
							else if (json.imgs != null)
							{
								part = imgPart = TextPartImg.fromPool();
								nodeData = json.imgs;
								nodeCount = nodeData.length;
								for (i in 0...nodeCount)
								{
									imgPart.imgConfigs[imgPart.imgConfigs.length] = ImgConfig.fromPool(nodeData[i]);
								}
								text.addPart(imgPart);
							}
							
							if (json.clip != null)
							{
								part = clipPart = TextPartClip.fromPool();
								//if (json.clip.animation != null)
								//{
									//clipPart.animations[clipPart.animations.length] = animations.get(json.clip.animation);
								//}
								clipPart.clipConfigs[clipPart.clipConfigs.length] = ClipConfig.fromPool(json.clip);
								text.addPart(clipPart);
							}
							else if (json.clips != null)
							{
								part = clipPart = TextPartClip.fromPool();
								nodeData = json.clips;
								nodeCount = nodeData.length;
								for (i in 0...nodeCount)
								{
									clipPart.clipConfigs[clipPart.clipConfigs.length] = ClipConfig.fromPool(nodeData[i]);
								}
								text.addPart(clipPart);
							}
							
							if (part == null)
							{
								part = strPart = TextPartString.fromPool();
								text.addPart(strPart);
							}
							
							if (json.format != null) part.formatData = json.format;
							if (json.anim != null) part.animationData = json.anim;
							if (json.animIn != null) part.animationInData = json.animIn;
							if (json.animOut != null) part.animationOutData = json.animOut;
						}
						else
						{
							if (strPart == null)
							{
								strPart = TextPartString.fromPool();
								text.addPart(strPart);
							}
							strPart.text = txt.substring(currIndex, closeIndex + CLOSE_PARAMS.length);
							strPart = null;
						}
						currIndex = closeIndex + CLOSE_PARAMS.length;
						if (currIndex == numChars) break;
					}
					else
					{
						if (nextIndex != -1)
						{
							if (strPart == null)
							{
								strPart = TextPartString.fromPool();
								text.addPart(strPart);
							}
							strPart.text = txt.substring(currIndex, nextIndex);
							strPart = null;
							currIndex = nextIndex;
						}
						else
						{
							if (strPart == null)
							{
								strPart = TextPartString.fromPool();
								text.addPart(strPart);
							}
							strPart.text = txt.substring(currIndex, numChars);
							break;
						}
					}
				}
				else
				{
					if (strPart == null)
					{
						strPart = TextPartString.fromPool();
						text.addPart(strPart);
					}
					strPart.text = txt.substring(currIndex, numChars);
					break;
				}
			}
			else
			{
				if (strPart == null)
				{
					strPart = TextPartString.fromPool();
					text.addPart(strPart);
				}
				strPart.text = txt.substring(currIndex, numChars);
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
		//_lineHeight = _fontStyle.lineHeight;
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
		
		var hAlign:String = text.options.horizontalAlign;
		var hAlignJustify:Bool = hAlign == TextAlign.JUSTIFY;
		var hAlignCenter:Bool = hAlign == TextAlign.CENTER;
		var hAlignRight:Bool = hAlign == TextAlign.RIGHT;
		var doHAlign:Bool = hAlignCenter || hAlignRight;
		var vAlign:String = text.options.verticalAlign;
		
		var options:TextOptions = text.options;
		var hyphenation:Bool = options.hyphenation && langRules != null;
		var hyphenationMinLength:Int = options.hyphenationMinLength;
		var hyphenationMinRatio:Float = options.hyphenationMinRatio;
		var intPositions:Bool = options.intPositions;
		var letterSpreading:Bool = options.letterSpreading;
		var letterSpreadingMax:Float = options.letterSpreadingMax;
		var letterSpreadingMinRatio:Float = options.letterSpreadingMinRatio;
		var paddingX:Float = options.paddingLeft + options.paddingRight;
		var paddingY:Float = options.paddingTop + options.paddingBottom;
		var paddingLeft:Float = options.paddingLeft;
		var paddingTop:Float = options.paddingTop;
		var restrictImageHeightToFontize:Bool = options.restrictImageHeightToFontSize;
		var restrictImageHeightOverFlow:Float = options.restrictImageHeightOverflow;
		var uniformLineHeight:Bool = options.uniformLineHeight;
		var wordWrap:Bool = options.wordWrap;
		
		var charID:Int;
		var charIndex:Int;
		var lastWhiteSpace:Int = -1;
		var lastCharID:Int = -1;
		var lastHyphen:Int = -1;
		var lineFull:Bool;
		var glyph:Glyph;
		var glyphLocation:GlyphLocation;
		var location:ElementLocation;
		var clipLocation:ClipLocation;
		var imgLocation:ImgLocation;
		var numChars:Int;
		var numCharsToRemove:Int;
		var numSpaces:Int = 0;
		var totalChars:Int = 0;
		
		var currentX:Float = 0;
		var currentY:Float = 0;
		var currentLine:Array<ElementLocation> = ElementLocation.arrayFromPool();
		var currentWord:Array<ElementLocation> = ElementLocation.arrayFromPool();
		var lineObject:Line = Line.fromPool();
		var linePart:LinePart;
		var linePartLocations:Array<ElementLocation>;
		
		var hyphenationAllowed:Bool;
		var hyphenationOccured:Bool;
		var letterSpreadingOccured:Bool = false;
		var index:Int;
		var ratio:Float;
		var remainingWidth:Float = 0.0;
		var testLocation:ElementLocation;
		var testWord:Array<ElementLocation> = ElementLocation.arrayFromPool();
		var word:Array<ElementLocation>;
		var nextCharID:Int;
		var testGlyph:Glyph;
		var cumulatedOffset:Float;
		var spreadWidth:Float = 0.0;
		var intIncrement:Float;
		var intPositionStep:Float = 1.0;
		var intCounter:Float;
		
		var part:TextPart;
		var clipPart:TextPartClip = null;
		var imgPart:TextPartImg = null;
		var strPart:TextPartString = null;
		var txt:String = null;
		var textResult:TextLayoutResult = TextLayoutResult.fromPool();
		var partResult:TextPartLayoutResult;
		var numParts:Int = text.numParts;
		var allChars:Int = text.numChars;
		var locations:Array<ElementLocation> = null;
		
		var finished:Bool = false;
		
		var scale:Float = 1.0;
		
		var containerWidth:Float = width - paddingX;//padding * 2;
		var containerHeight:Float = height - paddingY;//padding * 2;
		
		var lineHeight:Float;
		var lineHeightChange:Bool;
		var maxLineHeight:Float = 0.0;
		var baseline:Float;
		var baselineChange:Bool;
		var maxBaseline:Float = 0.0;
		
		var isClip:Bool;
		var isImg:Bool;
		var isText:Bool;
		
		var i:Int;
		var j:Int;
		var p:Int = 0;
		
		while (p < numParts)
		{
			part = text.parts[p];
			setFormat(part.format);
			
			if (p == 0)
			{
				if (intPositions) intPositionStep = 1.0 / scale;
			}
			if (_fontSize > containerHeight) break; // TODO this should be checked earlier, only once
			
			if (part.isText)
			{
				scale = _fontScale;
				
				strPart = cast part;
				isText = true;
				isClip = isImg = false;
				
				txt = strPart.text;
				partResult = TextPartStringLayoutResult.fromPool(strPart, _fontStyle);
				textResult.addPart(partResult);
			}
			else if (part.isImg)
			{
				scale = 1.0;
				
				imgPart = cast part;
				isImg = true;
				isClip = isText = false;
				
				partResult = TextPartImgLayoutResult.fromPool();
				textResult.addPart(partResult);
			}
			else
			{
				scale = 1.0;
				
				clipPart = cast part;
				isClip = true;
				isImg = isText = false;
				
				partResult = TextPartClipLayoutResult.fromPool();
				textResult.addPart(partResult);
			}
			
			numChars = part.numChars;
			linePart = part.getLinePart(_fontStyle, _fontScale);
			lineObject.addPart(linePart);
			linePartLocations = linePart.elementLocations;
			
			i = 0;
			while (i < numChars)
			{
				lineFull = false;
				
				if (isText)
				{
					charID = txt.charCodeAt(i);
				}
				else
				{
					charID = CHAR_MISSING;
				}
				charIndex = totalChars + i;
				
				if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
				{
					lineFull = true;
				}
				else
				{
					if (isText)
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
								currentWord = ElementLocation.arrayFromPool();
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
						
						location = glyphLocation = GlyphLocation.fromPool(glyph);
						location.scale = scale;
						lastCharID = charID;
					}
					else if (isImg)
					{
						location = imgLocation = ImgLocation.fromPool(imgPart.imgConfigs[i]);
						if (restrictImageHeightToFontize && location.height > _fontSize + restrictImageHeightOverFlow)
						{
							location.scale = (_fontSize + restrictImageHeightOverFlow) / location.height;
						}
						lastCharID = CHAR_MISSING;
					}
					else // isClip
					{
						location = clipLocation = ClipLocation.fromPool(clipPart.clipConfigs[i]);
						if (restrictImageHeightToFontize && location.height > _fontSize + restrictImageHeightOverFlow)
						{
							location.scale = (_fontSize + restrictImageHeightOverFlow) / location.height;
						}
						lastCharID = CHAR_MISSING;
					}
					
					location.index = charIndex;
					//location.scale = scale;
					location.x = currentX + location.xOffset * scale;
					location.y = currentY + location.yOffset * scale;
					currentLine[currentLine.length] = location;
					currentWord[currentWord.length] = location;
					linePartLocations[linePartLocations.length] = location;
					location.textPart = partResult;
					currentX += (location.xAdvance + _spacing) * scale;
					
					if (location.x + location.width * scale > containerWidth)
					{
						hyphenationAllowed = isText && wordWrap && hyphenation && !location.isSpace;
						
						if (hyphenationAllowed)
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
										remainingWidth = containerWidth - (testLocation.x + testLocation.width);
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
								if (testLocation.isHyphen || testLocation.x + testLocation.xAdvance + _hyphenGlyph.xOffset + _hyphenGlyph.width <= containerWidth)
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
										i -= numCharsToRemove;
										currentLine.resize(currentLine.length - numCharsToRemove);
										currentWord.resize(currentWord.length - numCharsToRemove);
										linePartLocations.resize(linePart.elementLocations.length - numCharsToRemove);
										
										if (!testLocation.isHyphen)
										{
											glyphLocation = GlyphLocation.fromPool(_hyphenGlyph);
											glyphLocation.index = totalChars + i;
											glyphLocation.x = testLocation.x + testLocation.xAdvance + _hyphenGlyph.xOffset;
											glyphLocation.y = currentY + _hyphenGlyph.yOffset;
											currentLine[currentLine.length] = glyphLocation;
											currentWord[currentWord.length] = glyphLocation;
											linePartLocations[linePartLocations.length] = glyphLocation;
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
									linePartLocations.resize(linePartLocations.length - numCharsToRemove);
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
									linePartLocations.resize(linePartLocations.length - numCharsToRemove);
								}
								
								if (currentLine.length == 0) break;
								
								i -= numCharsToRemove;
							}
							else
							{
								currentLine.pop(); // TODO : see if resize() is faster
								currentWord.pop();
								linePartLocations.pop();
								if (currentWord.length != 0) _words[_words.length] = currentWord;
								
								// continue with next line, if there is one
								while (true)
								{
									if (isText)
									{
										nextCharID = txt.charCodeAt(i);
										if (nextCharID == CHAR_NEWLINE || nextCharID == CHAR_CARRIAGE_RETURN)
										{
											break;
										}
									}
									if (i == numChars - 1)
									{
										// next part, if possible
										while (true)
										{
											++p;
											if (p == numParts)
											{
												break;
											}
											part = text.parts[p];
											setFormat(part.format);
											
											totalChars += numChars;
											
											if (part.isText)
											{
												scale = _fontScale;
												
												strPart = cast part;
												
												partResult = TextPartStringLayoutResult.fromPool(strPart, _fontStyle);
												textResult.addPart(partResult);
												
												txt = strPart.text;
												numChars = txt.length;
												i = 0;
												break;
											}
											else
											{
												numChars = part.numChars;
											}
										}
										
										if (p == numParts)
										{
											break;
										}
									}
									else
									{
										++i;
									}
								}
							}
						}
						
						lineFull = true;
						
						charIndex = totalChars + i;
						if (lastWhiteSpace == charIndex)
						{
							// TODO : compare .resize() and .pop() speeds
							currentLine.pop();
							linePartLocations.pop();
						}
						
						// JUSTIFY
						if (hAlignJustify)
						{
							location = currentLine[currentLine.length - 1];
							currentX = location.x + location.width;
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
										currentX = location.x + location.width;
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
				
				if (lineFull || totalChars + i == allChars - 1)
				{
					_lineObjects[_lineObjects.length] = lineObject;
					_lines[_lines.length] = currentLine;
					
					lineObject.validate();
					lineHeight = lineObject.maxLineHeight;
					baseline = lineObject.maxBaseline;
					if (uniformLineHeight)
					{
						lineHeightChange = lineHeight > maxLineHeight;
						if (lineHeightChange) maxLineHeight = lineHeight;
						baselineChange = baseline > maxBaseline;
						if (baselineChange) maxBaseline = baseline;
						
						if (lineHeightChange || baselineChange)
						{
							var yChange:Float = 0.0;
							for (l in 0..._lineObjects.length)
							{
								yChange = _lineObjects[l].adjust(maxLineHeight, maxBaseline, yChange);
							}
							currentY += yChange;
						}
						else
						{
							lineObject.adjust(maxLineHeight, maxBaseline, 0.0);
						}
						lineHeight = maxLineHeight;
					}
					else
					{
						lineObject.adjust(lineHeight, baseline, 0.0);
					}
					
					if (lineFull)
					{
						if (currentY + lineHeight + _leading + _fontStyle.size <= containerHeight)
						{
							currentLine = ElementLocation.arrayFromPool();
							lineObject = Line.fromPool();
							linePart = part.getLinePart(_fontStyle, _fontScale);
							lineObject.addPart(linePart);
							linePartLocations = linePart.elementLocations;
							_words.resize(0);
							currentWord.resize(0);
							currentX = 0;
							currentY += lineHeight + _leading;
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
				}
				++i;
			}
			totalChars += numChars;
			if (finished) break;
			++p;
		}
		
		var numLines:Int = _lines.length;
		var bottom:Float;// = currentY + _lineObjects[numLines - 1].maxLineHeight;//_lineHeight;
		if (uniformLineHeight)
		{
			bottom = currentY + maxLineHeight;
		}
		else
		{
			bottom = currentY + _lineObjects[numLines - 1].maxLineHeight;
		}
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
				right = testLocation.x - testLocation.xOffset + testLocation.xAdvance;
				
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
				location = currentLine[c];
				if (location.width > 0 && location.height > 0)
				{
					if (location.textPart != partResult)
					{
						partResult = location.textPart;
						locations = partResult.elementLocations;
					}
					location.x = (location.x + xOffset) * scale + paddingLeft;
					location.y = (location.y + yOffset) * scale + paddingTop;
					//location.scale = scale;
					locations[locations.length] = location;
				}
			}
		}
		
		for (l in 0...numLines)
		{
			_lineObjects[l].pool();
		}
		_lineObjects.resize(0);
		_lines.resize(0);
		_words.resize(0);
		
		return textResult;
	}
	
	// helper vars
	private static var _lineObjects:Array<Line> = new Array<Line>();
	private static var _lines:Array<Array<ElementLocation>> = new Array<Array<ElementLocation>>();
	private static var _words:Array<Array<ElementLocation>> = new Array<Array<ElementLocation>>();
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