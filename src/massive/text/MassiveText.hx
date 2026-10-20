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
		var wordWrap:Bool = options.wordWrap;
		
		var charID:Int;
		var lineFull:Bool;
		var glyph:Glyph;
		var glyphLocation:GlyphLocation;
		var location:ElementLocation;
		var clipLocation:ClipLocation;
		var imgLocation:ImgLocation;
		var numCharsToRemove:Int;
		
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
		
		var locations:Array<ElementLocation> = null;
		
		var finished:Bool = false;
		
		var scale:Float = 1.0;
		
		var containerWidth:Float = width - paddingX;
		var containerHeight:Float = height - paddingY;
		
		var j:Int;
		
		prepare(text, options);
		
		while (true)
		{
			//i = 0;
			while (_i < _numChars)
			{
				lineFull = false;
				
				if (_isText)
				{
					charID = _txt.charCodeAt(_i);
				}
				else
				{
					charID = CHAR_MISSING;
				}
				_charIndex = _totalChars + _i;
				
				if (charID == CHAR_NEWLINE || charID == CHAR_CARRIAGE_RETURN)
				{
					lineFull = true;
				}
				else
				{
					if (_isText)
					{
						glyph = _glyphMap.get(charID);
						if (glyph == null)
						{
							#if debug
							trace("[MassiveText] Character '" + _txt.charAt(_i) + "' not found");
							#end
							charID = CHAR_MISSING;
							glyph = _glyphMap.get(charID);
						}
						
						if (charID == CHAR_SPACE || charID == CHAR_TAB)
						{
							_lastWhiteSpace = _charIndex;
							_lastHyphen = -1;
							if (_currentWord.length != 0)
							{
								_words[_words.length] = _currentWord;
								_currentWord = ElementLocation.arrayFromPool();
							}
							++_numSpaces;
						}
						else if (charID == CHAR_HYPHEN && _lastWhiteSpace != _charIndex - 1)
						{
							_lastHyphen = _charIndex;
						}
						
						if (_kerning)
						{
							_currentX += glyph.getKerning(_lastCharID);
						}
						
						location = glyphLocation = GlyphLocation.fromPool(glyph);
						location.scale = scale;
						_lastCharID = charID;
					}
					else // img or clip
					{
						if (_currentWord.length > 1 || (_currentWord.length == 1 && !_currentWord[0].isSpace))
						{
							_words[_words.length] = _currentWord;
							_currentWord = ElementLocation.arrayFromPool();
						}
						
						if (_isImg)
						{
							location = imgLocation = ImgLocation.fromPool(_imgPart.imgConfigs[_i]);
							
						}
						else // _isClip
						{
							location = clipLocation = ClipLocation.fromPool(_clipPart.clipConfigs[_i]);
						}
						
						if (restrictImageHeightToFontize && location.height > _fontSize + restrictImageHeightOverFlow)
						{
							location.scale = (_fontSize + restrictImageHeightOverFlow) / location.height;
						}
						_lastCharID = CHAR_MISSING;
					}
					
					location.index = _charIndex;
					location.x = _currentX + location.xOffset;
					location.y = _currentY + location.yOffset;
					_currentLine[_currentLine.length] = location;
					_currentWord[_currentWord.length] = location;
					_linePartLocations[_linePartLocations.length] = location;
					location.linePart = _linePart;
					location.textPart = _partResult;
					_currentX += location.xAdvance + _spacing;
					
					if (location.x + location.width > containerWidth)
					{
						hyphenationAllowed = _isText && wordWrap && hyphenation && !location.isSpace;
						
						if (hyphenationAllowed)
						{
							// we want to know how much space there will be if we put this entire word on the next line
							if (_lastWhiteSpace != -1)
							{
								numCharsToRemove = _charIndex - _lastWhiteSpace;
								j = 1;
								while (true)
								{
									index = _currentLine.length - (numCharsToRemove + j);
									if (index < 0)
									{
										remainingWidth = containerWidth;
										break;
									}
									testLocation = _currentLine[index];
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
							for (c in 0..._currentWord.length)
							{
								testLocation = _currentWord[c];
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
								j = _i + 1;
								if (j < _numChars)
								{
									while (true)
									{
										nextCharID = _txt.charCodeAt(j);
										if (nextCharID == CHAR_SPACE || nextCharID == CHAR_TAB || nextCharID == CHAR_NEWLINE || nextCharID == CHAR_CARRIAGE_RETURN) break;
										testGlyph = _glyphMap.get(nextCharID);
										if (testGlyph == null) break; // missing char
										if (testGlyph.isPunctuation) break; // TODO we shouldn't break punctuation ?
										testLocation = GlyphLocation.fromPool(testGlyph);
										testWord[testWord.length] = testLocation;
										++j;
										if (j == _numChars) break;
									}
								}
								
								if (testWord.length >= hyphenationMinLength)
								{
									if (_lastHyphen != -1)
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
										numCharsToRemove = _charIndex - testLocation.index;
										_i -= numCharsToRemove;
										_currentLine.resize(_currentLine.length - numCharsToRemove);
										_currentWord.resize(_currentWord.length - numCharsToRemove);
										_linePartLocations.resize(_linePart.elementLocations.length - numCharsToRemove);
										
										if (!testLocation.isHyphen)
										{
											glyphLocation = GlyphLocation.fromPool(_hyphenGlyph);
											glyphLocation.index = _totalChars + _i;
											glyphLocation.x = testLocation.x + testLocation.xAdvance + _hyphenGlyph.xOffset;
											glyphLocation.y = _currentY + _hyphenGlyph.yOffset;
											_currentLine[_currentLine.length] = glyphLocation;
											_currentWord[_currentWord.length] = glyphLocation;
											_linePartLocations[_linePartLocations.length] = glyphLocation;
											glyphLocation.linePart = _linePart;
											glyphLocation.textPart = _partResult;
										}
										_words[_words.length] = _currentWord;
									}
								}
							}
							testWord.resize(0);
						}
						
						if (!hyphenationOccured)
						{
							if (wordWrap)
							{
								if (_lastWhiteSpace == -1)
								{
									numCharsToRemove = 1;
								}
								else
								{
									numCharsToRemove = _currentWord.length;
									if (_currentWord[0].isSpace)
									{
										--numCharsToRemove;
									}
								}
								
								removeChars(numCharsToRemove);
								
								if (_currentLine.length == 0)
								{
									#if debug
									trace("[MassiveText] cannot fit a single element on a whole line - giving up");
									#end
									finished = true;
									break;
								}
								
							}
							else
							{
								_currentLine.pop(); // TODO : see if resize() is faster
								_currentWord.pop();
								_linePartLocations.pop();
								
								// continue with next line, if there is one
								while (true)
								{
									if (_isText)
									{
										nextCharID = _txt.charCodeAt(_i);
										if (nextCharID == CHAR_NEWLINE || nextCharID == CHAR_CARRIAGE_RETURN)
										{
											break;
										}
									}
									if (_i == _numChars - 1)
									{
										// next part, if possible
										while (true)
										{
											++_partIndex;
											if (_partIndex == _numParts)
											{
												break;
											}
											_part = text.parts[_partIndex];
											setFormat(_part.format);
											
											_totalChars += _numChars;
											
											if (_part.isText)
											{
												_scale = _fontScale;
												
												_strPart = cast _part;
												
												_partResult = TextPartStringLayoutResult.fromPool(_strPart, _fontStyle);
												_textResult.addPart(_partResult);
												
												_txt = _strPart.text;
												_numChars = _txt.length;
												_i = 0;
												break;
											}
											else
											{
												_numChars = _part.numChars;
											}
										}
										
										if (_partIndex == _numParts)
										{
											break;
										}
									}
									else
									{
										++_i;
									}
								}
							}
						}
						
						lineFull = true;
						
						_charIndex = _totalChars + _i;
						if (_lastWhiteSpace == _charIndex)
						{
							// TODO : compare .resize() and .pop() speeds
							_currentLine.pop();
							_currentWord.pop();
							_linePartLocations.pop();
						}
						if (_currentWord.length != 0) _words[_words.length] = _currentWord;
						
						// JUSTIFY
						if (hAlignJustify)
						{
							location = _currentLine[_currentLine.length - 1];
							_currentX = location.x + location.width;
							remainingWidth = containerWidth - _currentX;
							
							cumulatedOffset = 0.0;
							
							if (letterSpreading)
							{
								letterSpreadingOccured = false;
								ratio = remainingWidth / containerWidth;
								if (ratio >= letterSpreadingMinRatio)
								{
									spreadWidth = remainingWidth / (_currentLine.length - 1);
									if (!intPositions || spreadWidth >= intPositionStep)
									{
										spreadWidth = Math.min(spreadWidth, letterSpreadingMax);
										if (intPositions)
										{
											intIncrement = spreadWidth % intPositionStep;
											spreadWidth -= intIncrement;
										}
										
										for (c in 1..._currentLine.length)
										{
											cumulatedOffset += spreadWidth;
											_currentLine[c].x += cumulatedOffset;
										}
										
										cumulatedOffset = 0.0;
										_currentX = location.x + location.width;
										remainingWidth = containerWidth - _currentX;
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
				
				if (lineFull || _totalChars + _i == _allChars - 1)
				{
					validateLine();
					
					if (lineFull)
					{
						if (_currentY + _lineHeight + _leading + _fontStyle.size <= containerHeight)
						{
							nextLine();
						}
						else
						{
							finished = true;
							break;
						}
					}
				}
				if (!_isText && _currentWord.length != 0)
				{
					_words[_words.length] = _currentWord;
					_currentWord = ElementLocation.arrayFromPool();
				}
				++_i;
			}
			if (finished) break;
			
			if (_partIndex + 1 == _numParts) break;
			nextPart();
		}
		
		var numLines:Int = _lines.length;
		var bottom:Float;
		if (_uniformLineHeight)
		{
			bottom = _currentY + _maxLineHeight;
		}
		else
		{
			bottom = _currentY + _lineObjects[numLines - 1].maxLineHeight;
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
		
		_partResult = null;
		
		for (lineID in 0...numLines)
		{
			_currentLine = _lines[lineID];
			_numChars = _currentLine.length;
			
			if (_numChars == 0) continue;
			
			if (doHAlign)
			{
				testLocation = _currentLine[_currentLine.length - 1];
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
			
			for (c in 0..._numChars)
			{
				location = _currentLine[c];
				if (location.width > 0 && location.height > 0)
				{
					if (location.textPart != _partResult)
					{
						_partResult = location.textPart;
						locations = _partResult.elementLocations;
					}
					location.x = (location.x + xOffset) + paddingLeft;
					location.y = (location.y + yOffset) + paddingTop;
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
		
		var result:TextLayoutResult = _textResult;
		complete();
		return result;
	}
	
	private static function prepare(text:Text, options:TextOptions):Void
	{
		_text = text;
		_numParts = _text.numParts;
		_partIndex = -1;
		_totalChars = 0;
		_allChars = _text.numChars;
		
		_textResult = TextLayoutResult.fromPool();
		
		_uniformLineHeight = options.uniformLineHeight;
		
		_currentY = 0.0;
		
		_maxLineHeight = 0.0;
		_maxBaseline = 0.0;
		
		nextLine();
		nextPart();
	}
	
	private static function complete():Void
	{
		_clipPart = null;
		_imgPart = null;
		_strPart = null;
		_part = null;
		_partResult = null;
		_text = null;
		_textResult = null;
		
		_lineObject = null;
		_linePart = null;
		_linePartLocations = null;
		
		_currentLine = null;
		_currentWord = null;
	}
	
	private static function nextPart():Void
	{
		if (_part != null)
		{
			_totalChars += _numChars;
		}
		
		setPart(_text.parts[++_partIndex]);
		_i = 0;
		
		if (_textResult.numParts > _partIndex)
		{
			_partResult = _textResult.getPartAt(_partIndex);
		}
		else
		{
			if (_isText)
			{
				_partResult = TextPartStringLayoutResult.fromPool(_strPart, _fontStyle);
			}
			else if (_isImg)
			{
				_partResult = TextPartImgLayoutResult.fromPool(_imgPart);
			}
			else
			{
				_partResult = TextPartClipLayoutResult.fromPool(_clipPart);
			}
			_textResult.addPart(_partResult);
		}
		
		nextLinePart();
	}
	
	private static function previousPart():Void
	{
		setPart(_text.parts[--_partIndex]);
		
		_partResult = _textResult.getPartAt(_partIndex);
		
		_totalChars -= _numChars;
		_i = _numChars - 1;
	}
	
	private static function setPart(part:TextPart):Void
	{
		_part = part;
		setFormat(_part.format);
		
		if (_part.isText)
		{
			_scale = _fontScale;
			
			_strPart = cast _part;
			_isText = true;
			_isClip = _isImg = false;
			
			_txt = _strPart.text;
		}
		else if (_part.isImg)
		{
			_scale = 1.0;
			
			_imgPart = cast _part;
			_isImg = true;
			_isClip = _isText = false;
		}
		else
		{
			_scale = 1.0;
			
			_clipPart = cast _part;
			_isClip = true;
			_isImg = _isText = false;
		}
		
		_numChars = _part.numChars;
	}
	
	private static function validateLine():Void
	{
		_lineObjects[_lineObjects.length] = _lineObject;
		_lines[_lines.length] = _currentLine;
		
		_lineObject.validate();
		_lineHeight = _lineObject.maxLineHeight;
		_baseline = _lineObject.maxBaseline;
		if (_uniformLineHeight)
		{
			var lineHeightChange:Bool = _lineHeight > _maxLineHeight;
			if (lineHeightChange) _maxLineHeight = _lineHeight;
			var baselineChange = _baseline > _maxBaseline;
			if (baselineChange) _maxBaseline = _baseline;
			
			if (lineHeightChange || baselineChange)
			{
				var yChange:Float = 0.0;
				for (l in 0..._lineObjects.length)
				{
					yChange = _lineObjects[l].adjust(_maxLineHeight, _maxBaseline, yChange);
				}
				_currentY += yChange;
			}
			else
			{
				_lineObject.adjust(_maxLineHeight, _maxBaseline, 0.0);
			}
			_lineHeight = _maxLineHeight;
		}
		else
		{
			_lineObject.adjust(_lineHeight, _baseline, 0.0);
		}
	}
	
	private static function nextLine():Void
	{
		_words.resize(0);
		
		_lineObject = Line.fromPool();
		_currentLine = ElementLocation.arrayFromPool();
		_currentWord = ElementLocation.arrayFromPool();
		
		if (_part != null)
		{
			nextLinePart();
			_currentY += _lineHeight + _leading;
		}
		
		_currentX = 0.0;
		
		_lastWhiteSpace = -1;
		_lastHyphen = -1;
		_lastCharID = -1;
		_numSpaces = 0;
	}
	
	private static function nextLinePart():Void
	{
		_linePart = _part.getLinePart(_fontStyle, _fontScale);
		_lineObject.addPart(_linePart);
		setLinePart(_lineObject.parts.length - 1);
	}
	
	private static function previousLinePart():Void
	{
		_lineObject.removeLastPart();
		setLinePart(_lineObject.parts.length - 1);
	}
	
	private static function setLinePart(index:Int):Void
	{
		_linePart = _lineObject.parts[index];
		_linePartLocations = _linePart.elementLocations;
	}
	
	private static function removeChars(numCharsToRemove:Int):Void
	{
		var offset:Int = _currentWord.length - numCharsToRemove;
		var j:Int = numCharsToRemove - 1;
		
		while (j >= 0)
		{
			--_i;
			_linePartLocations.pop();
			if (_currentWord[offset + j].linePart != _linePart)
			{
				previousLinePart();
			}
			if (_currentWord[offset + j].textPart != _partResult)
			{
				_textResult.removeLastPart();
				previousPart();
			}
			_currentWord.pop();
			if (_currentWord.length == 0) _currentWord = _words.pop();
			--j;
		}
		
		_currentLine.resize(numCharsToRemove > _currentLine.length ? 0 : _currentLine.length - numCharsToRemove);
	}
	
	// new helper vars
	//private static var _containerWidth:Float;
	//private static var _containerHeight:Float;
	
	private static var _i:Int;
	
	private static var _text:Text;
	private static var _numParts:Int;
	private static var _partIndex:Int;
	private static var _part:TextPart;
	private static var _clipPart:TextPartClip;
	private static var _imgPart:TextPartImg;
	private static var _strPart:TextPartString;
	private static var _isClip:Bool;
	private static var _isImg:Bool;
	private static var _isText:Bool;
	private static var _txt:String;
	private static var _scale:Float;
	
	private static var _numChars:Int;
	private static var _totalChars:Int;
	private static var _allChars:Int;
	private static var _charIndex:Int;
	
	private static var _textResult:TextLayoutResult;
	private static var _partResult:TextPartLayoutResult;
	
	private static var _lineObject:Line;
	private static var _linePart:LinePart;
	private static var _linePartLocations:Array<ElementLocation>;
	
	private static var _uniformLineHeight:Bool;
	private static var _lineHeight:Float;
	private static var _maxLineHeight:Float;
	private static var _baseline:Float;
	private static var _maxBaseline:Float;
	
	private static var _currentLine:Array<ElementLocation>;
	private static var _currentWord:Array<ElementLocation>;
	
	private static var _currentX:Float;
	private static var _currentY:Float;
	
	private static var _lastWhiteSpace:Int;
	private static var _lastHyphen:Int;
	private static var _lastCharID:Int;
	private static var _numSpaces:Int;
	
	private static var _intPositionStep:Float;
	
	// helper vars
	private static var _lineObjects:Array<Line> = new Array<Line>();
	private static var _lines:Array<Array<ElementLocation>> = new Array<Array<ElementLocation>>();
	private static var _words:Array<Array<ElementLocation>> = new Array<Array<ElementLocation>>();
	private static var _font:MassiveFont;
	private static var _fontScale:Float;
	private static var _fontStyle:FontStyle;
	private static var _glyphMap:Map<Int, Glyph>;
	private static var _hyphenGlyph:Glyph;
	//private static var _lineHeight:Float;
	private static var _kerning:Bool;
	private static var _leading:Float;
	private static var _spacing:Float;
	private static var _fontSize:Float;
	
}