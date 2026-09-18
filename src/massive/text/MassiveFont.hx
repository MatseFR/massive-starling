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
	private static inline var CHAR_MINUS:Int		   = 45;
	private static inline var CHAR_MISSING:Int         =  0;
    private static inline var CHAR_TAB:Int             =  9;
    private static inline var CHAR_NEWLINE:Int         = 10;
    private static inline var CHAR_CARRIAGE_RETURN:Int = 13;
    private static inline var CHAR_SPACE:Int           = 32;
	
	private static inline var EPSILON:Float = 0.000001;
	
	private static var _imgs:Array<Img> = new Array<Img>();
	private static var _lines:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	private static var _words:Array<Array<GlyphLocation>> = new Array<Array<GlyphLocation>>();
	//private static var _spaces:Array<GlyphLocation> = new Array<GlyphLocation>(); // CHAR_SPACE & CHAR_TAB
	
	public var baseline:Float;
	public var hyphenChar(get, set):String;
	public var hyphenCharID(get, set):Int;
	public var lineHeight(default, null):Float;
	public var name(default, null):String;
	public var offsetX:Float;
	public var offsetY:Float;
	public var padding:Float;
	public var size(default, null):Float;
	public var texture(default, null):Texture;
	
	private var _hyphenChar:String;
	private function get_hyphenChar():String { return this._hyphenChar; }
	private function set_hyphenChar(value:String):String
	{
		this._hyphenChar = value;
		return this._hyphenChar;
	}
	
	private var _hyphenCharID:Int = CHAR_MINUS;
	private function get_hyphenCharID():Int { return this._hyphenCharID; }
	private function set_hyphenCharID(value:Int):Int
	{
		this._hyphenCharID = value;
		return this._hyphenCharID;
	}
	
	private var _glyphs:Map<Int, Glyph> = new Map<Int, Glyph>();
	private var _hyphenGlyph:Glyph;
	
	private var _breakableVowels:Map<Int, Bool> = new Map<Int, Bool>();
	private var _breakableVowelModifiers:Map<Int, Array<Int>> = new Map<Int, Array<Int>>();
	private var _forbiddenBreaks:Map<Int, Array<Int>> = new Map<Int, Array<Int>>();
	
	private var _unbreakableStrings:Map<Int, Array<Array<Int>>> = new Map<Int, Array<Array<Int>>>();
	private var _minUnbreakableChars:Int = 0;
	private var _maxUnbreakableChars:Int = 0;
	private var _hasUnbreakableStrings:Bool;
	
	// helpers
	private var __hyphenIndexes:Array<Int> = new Array<Int>();

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
		this._hyphenGlyph = getGlyph(CHAR_MINUS);
		if (this._hyphenGlyph == null)
		{
			this._hyphenGlyph = getGlyph(CHAR_MISSING);
		}
		else
		{
			this._hyphenGlyph.isHyphen = true;
		}
		
		var glyph:Glyph;
		glyph = getGlyph(CHAR_SPACE);
		if (glyph != null) glyph.isSpace = true;
		
		glyph = getGlyph(CHAR_TAB);
		if (glyph != null) glyph.isSpace = true;
		
		var vowels:String = "aàâäeéèêëiîïoôöuùûüy";
		var count:Int = vowels.length;
		for (i in 0...count)
		{
			glyph = getGlyph(vowels.charCodeAt(i));
			if (glyph != null) glyph.isVowel = true;
		}
		
		var punctuation:String = ",;.:?!\"'()-";
		count = punctuation.length;
		for (i in 0...count)
		{
			glyph = getGlyph(punctuation.charCodeAt(i));
			if (glyph != null)
			{
				glyph.isLetter = false;
				glyph.isPunctuation = true;
			}
		}
		
		var numbers:String = "0123456789";
		count = numbers.length;
		for (i in 0...count)
		{
			glyph = getGlyph(numbers.charCodeAt(i));
			if (glyph != null)
			{
				glyph.isLetter = false;
				glyph.isNumber = true;
			}
		}
		
		var specialChars:String = "<>_+=*$£%§#@°~";
		count = specialChars.length;
		for (i in 0...count)
		{
			glyph = getGlyph(specialChars.charCodeAt(i));
			if (glyph != null)
			{
				glyph.isLetter = false;
				glyph.isSpecial = true;
			}
		}
		
		addBreakableVowel("y");
		
		//addBreakableVowelModifier("u", "q");
		
		addForbiddenBreak("a", "g");
		addForbiddenBreak("a", "k");
		addForbiddenBreak("a", "l"); // de-mor-al-ized ?
		addForbiddenBreak("a", "m");
		addForbiddenBreak("a", "n");
		
		addForbiddenBreak("b", "o");
		
		addForbiddenBreak("c", "a");
		addForbiddenBreak("c", "e");
		addForbiddenBreak("c", "h");
		addForbiddenBreak("c", "i");
		addForbiddenBreak("c", "k");
		addForbiddenBreak("c", "o");
		addForbiddenBreak("c", "u");
		
		addForbiddenBreak("d", "u"); // produces
		
		addForbiddenBreak("e", "m");
		//addForbiddenBreak("e", "n");
		addForbiddenBreak("e", "p");
		addForbiddenBreak("e", "r");
		
		addForbiddenBreak("g", "a");
		
		addForbiddenBreak("f", "a");
		addForbiddenBreak("f", "e");
		addForbiddenBreak("f", "i");
		addForbiddenBreak("f", "o");
		addForbiddenBreak("f", "u");
		
		addForbiddenBreak("i", "k");
		addForbiddenBreak("i", "n");
		addForbiddenBreak("i", "r");
		addForbiddenBreak("i", "s");
		//addForbiddenBreak("i", "v"); // u-ni-ver-sal
		addForbiddenBreak("i", "z");
		
		addForbiddenBreak("j", "e");
		
		addForbiddenBreak("k", "e");
		
		addForbiddenBreak("l", "d");
		addForbiddenBreak("l", "e");
		addForbiddenBreak("l", "i");
		addForbiddenBreak("l", "o"); // belongs
		
		addForbiddenBreak("m", "a");
		addForbiddenBreak("m", "e");
		addForbiddenBreak("m", "i");
		addForbiddenBreak("m", "o");
		addForbiddenBreak("m", "u");
		
		addForbiddenBreak("n", "a");
		addForbiddenBreak("n", "e");
		addForbiddenBreak("n", "t");
		
		addForbiddenBreak("o", "m");
		addForbiddenBreak("o", "n");
		
		addForbiddenBreak("p", "a");
		addForbiddenBreak("p", "e");
		addForbiddenBreak("p", "h");
		addForbiddenBreak("p", "i");
		
		addForbiddenBreak("p", "o");
		addForbiddenBreak("p", "u");
		addForbiddenBreak("p", "y");
		
		addForbiddenBreak("q", "u");
		
		addForbiddenBreak("r", "a");
		//addForbiddenBreak("r", "e"); // ex-plor-er
		//addForbiddenBreak("r", "i");
		
		addForbiddenBreak("s", "e");
		addForbiddenBreak("s", "h");
		//addForbiddenBreak("s", "i"); // mis-informed
		//addForbiddenBreak("s", "l"); // dis-like
		//addForbiddenBreak("s", "u");
		
		addForbiddenBreak("t", "a");
		//addForbiddenBreak("t", "e");
		addForbiddenBreak("t", "h");
		addForbiddenBreak("t", "i");
		addForbiddenBreak("t", "o");
		addForbiddenBreak("t", "u");
		addForbiddenBreak("t", "y");
		
		addForbiddenBreak("u", "a");
		addForbiddenBreak("u", "c");
		addForbiddenBreak("u", "e");
		addForbiddenBreak("u", "i");
		addForbiddenBreak("u", "m");
		addForbiddenBreak("u", "n");
		addForbiddenBreak("u", "o");
		addForbiddenBreak("u", "r");
		addForbiddenBreak("u", "s");
		
		addForbiddenBreak("v", "a");
		addForbiddenBreak("v", "e");
		addForbiddenBreak("v", "i");
		addForbiddenBreak("v", "o");
		addForbiddenBreak("v", "u");
		
		addForbiddenBreak("z", "a");
		addForbiddenBreak("z", "e");
		addForbiddenBreak("z", "i");
		addForbiddenBreak("z", "o");
		addForbiddenBreak("z", "u");
		addForbiddenBreak("z", "y");
		
		// 3 letters
		addUnbreakableString("act");
		addUnbreakableString("der");
		addUnbreakableString("ect");
		addUnbreakableString("ing");
		addUnbreakableString("riv");
		addUnbreakableString("sue");
		addUnbreakableString("tem");
		addUnbreakableString("ure");
		
		// 4 letters
		addUnbreakableString("ance");
		addUnbreakableString("each");
		//addUnbreakableString("fect");
		addUnbreakableString("fore");
		addUnbreakableString("here");
		addUnbreakableString("less");
		addUnbreakableString("like");
		addUnbreakableString("noun");
		addUnbreakableString("oice");
		addUnbreakableString("pend");
		addUnbreakableString("plet");
		addUnbreakableString("quen");
		addUnbreakableString("sion");
		addUnbreakableString("sire");
		addUnbreakableString("thos");
		addUnbreakableString("void");
		
		// 5 letters
		addUnbreakableString("treme");
		
		// 6 letters
		addUnbreakableString("nounce");
	}
	
	public function addBreakableVowel(vowel:String):Void
	{
		this._breakableVowels.set(vowel.charCodeAt(0), true);
	}
	
	public function isBreakableVowel(charID:Int):Bool
	{
		return this._breakableVowels.exists(charID);
	}
	
	public function addBreakableVowelModifier(vowel:String, charBefore:String):Void
	{
		var charID:Int = vowel.charCodeAt(0);
		var charCodes:Array<Int> = this._breakableVowelModifiers.get(charID);
		if (charCodes == null)
		{
			charCodes = [];
			this._breakableVowelModifiers.set(charID, charCodes);
		}
		charCodes[charCodes.length] = charBefore.charCodeAt(0);
	}
	
	public function isBreakableVowelWithModifier(vowelID:Int, charID:Int):Bool
	{
		var charCodes:Array<Int> = this._breakableVowelModifiers.get(vowelID);
		if (charCodes == null) return false;
		return charCodes.indexOf(charID) != -1;
	}
	
	public function addForbiddenBreak(charA:String, charB:String):Void
	{
		var charID:Int = charA.charCodeAt(0);
		var charCodes:Array<Int> = this._forbiddenBreaks.get(charID);
		if (charCodes == null)
		{
			charCodes = [];
			this._forbiddenBreaks.set(charID, charCodes);
		}
		charCodes[charCodes.length] = charB.charCodeAt(0);
	}
	
	public function isForbiddenBreak(charID1:Int, charID2:Int):Bool
	{
		var charCodes:Array<Int> = this._forbiddenBreaks.get(charID1);
		if (charCodes == null) return false;
		return charCodes.indexOf(charID2) != -1;
	}
	
	public function addUnbreakableString(str:String):Void
	{
		var numChars:Int = str.length;
		var charCodes:Array<Int> = new Array<Int>();
		for (i in 0...numChars)
		{
			charCodes[i] = str.charCodeAt(i);
		}
		
		if (this._minUnbreakableChars == 0 || numChars < this._minUnbreakableChars) this._minUnbreakableChars = numChars;
		if (this._maxUnbreakableChars == 0 || numChars > this._maxUnbreakableChars) this._maxUnbreakableChars = numChars;
		
		var entries:Array<Array<Int>> = this._unbreakableStrings.get(charCodes[0]);
		if (entries == null)
		{
			entries = new Array<Array<Int>>();
			this._unbreakableStrings.set(charCodes[0], entries);
		}
		entries[entries.length] = charCodes;
		
		this._hasUnbreakableStrings = true;
	}
	
	public function isUnbreakableString(chars:Array<GlyphLocation>, fromIndex:Int):Bool
	{
		if (!this._hasUnbreakableStrings) return false;
		
		var startIndex:Int;
		var endIndex:Int;
		var maxIndex:Int = fromIndex + 1;
		var charCount:Int = chars.length;
		var entries:Array<Array<Int>>;
		var entry:Array<Int>;
		var numEntries:Int;
		var unbreakable:Bool;
		
		for (numChars in this._minUnbreakableChars...this._maxUnbreakableChars + 1)
		{
			if (numChars > charCount) break;
			startIndex = fromIndex - (numChars - 1);
			if (startIndex < 0) startIndex = 0;
			endIndex = charCount - (numChars - 1);
			if (endIndex > maxIndex) endIndex = maxIndex;
			
			for (i in startIndex...endIndex)
			{
				entries = this._unbreakableStrings.get(chars[i].glyph.charID);
				if (entries == null) continue;
				
				numEntries = entries.length;
				for (j in 0...numEntries)
				{
					entry = entries[j];
					if (entry.length != numChars) continue;
					
					unbreakable = true;
					for (k in 0...numChars)
					{
						if (chars[i + k].glyph.charID != entry[k])
						{
							unbreakable = false;
							break;
						}
					}
					if (unbreakable) return true;
				}
			}
		}
		return false;
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
	
	private function getBreakIndexWithHyphens(chars:Array<GlyphLocation>, fromIndex:Int, minCharsBefore:Int, minCharsAfter:Int, canBreakWords:Bool, minWordLength:Int):Int
	{
		this.__hyphenIndexes.resize(0);
		var hyphenIndex:Int;
		var index:Int;
		var word:Array<GlyphLocation>;
		var count:Int;
		
		for (i in 0...chars.length)
		{
			if (chars[i].isHyphen)
			{
				this.__hyphenIndexes[this.__hyphenIndexes.length] = i;
			}
		}
		
		if (canBreakWords)
		{
			// find first hyphen index <= fromIndex
			hyphenIndex = -1;
			index = this.__hyphenIndexes.length - 1;
			while (index >= 0)
			{
				if (this.__hyphenIndexes[index] <= fromIndex)
				{
					hyphenIndex = this.__hyphenIndexes[index];
					break;
				}
				--index;
			}
			
			// if hyphen index == fromIndex return that
			if (hyphenIndex == fromIndex) return fromIndex;
			
			// else if word between hyphen index and next hyphen/word end is big enough try to break it
			if (canBreakWords)
			{
				//count = 0;
				if (index < this.__hyphenIndexes.length - 1)
				{
					count = this.__hyphenIndexes[index + 1] - hyphenIndex;
				}
				else
				{
					count = chars.length - hyphenIndex;
				}
				
				if (count - 1 >= minWordLength)
				{
					word = GlyphLocation.arrayFromPool();
					for (i in 1...count)
					{
						word[word.length] = chars[hyphenIndex + i];
					}
					
					index = getBreakIndex(word, fromIndex - hyphenIndex, minCharsBefore, minCharsAfter);
					if (index != -1) return hyphenIndex + index;
				}
			}
			
			// else return hyphen index
			return hyphenIndex;
		}
		else
		{
			// return first hyphen index that is <= fromIndex
			index = this.__hyphenIndexes.length - 1;
			while (index >= 0)
			{
				if (this.__hyphenIndexes[index] <= fromIndex)
				{
					return this.__hyphenIndexes[index];
				}
				--index;
			}
		}
		
		return -1;
	}
	
	private function getBreakIndex(chars:Array<GlyphLocation>, fromIndex:Int, minCharsBefore:Int, minCharsAfter:Int):Int
	{
		var numCharsBefore:Int = fromIndex + 1;
		var numCharsAfter:Int = chars.length - fromIndex;
		var numVowelsBefore:Int = 0;
		var numVowelsAfter:Int = 0;
		var ok:Bool;
		
		#if debug
		var word:String = "";
		var charCount:Int = chars.length;
		for (i in 0...charCount)
		{
			word += chars[i].char;
		}
		trace(word);
		if (word == "happiness")
		{
			trace("debug");
		}
		#end
		
		for (i in 0...fromIndex + 1)
		{
			if (chars[i].isVowel)
			{
				++numVowelsBefore;
			}
		}
		
		if (numVowelsBefore == 0) return -1;
		
		for (i in fromIndex + 1...chars.length)
		{
			if (chars[i].isVowel)
			{
				++numVowelsAfter;
			}
		}
		
		if (numVowelsBefore + numVowelsAfter < 2) return -1;
		
		while (fromIndex >= minCharsBefore - 1)
		{
			ok = numCharsAfter >= minCharsAfter;
			if (ok)
			{
				if (chars[fromIndex].glyph == this._hyphenGlyph)
				{
					return fromIndex;
				}
				else if (numVowelsAfter > 0)
				{
					// first part cannot end with twice the same consonant
					if (numCharsBefore > 1 && !chars[fromIndex - 1].isVowel && chars[fromIndex - 1].glyph.charID == chars[fromIndex].glyph.charID)
					{
						ok = false;
					}
					
					// second part cannot start with twice the same consonant
					if (ok && numCharsAfter > 1 && ! chars[fromIndex + 1].isSpace && chars[fromIndex + 1].glyph.charID == chars[fromIndex + 2].glyph.charID)
					{
						ok = false;
					}
					
					// first part cannot end with a vowel if second part starts with a vowel
					if (ok && numCharsAfter > 0 && chars[fromIndex].isVowel && chars[fromIndex + 1].isVowel && !isBreakableVowel(chars[fromIndex].glyph.charID) && (numCharsBefore == 0 || !isBreakableVowelWithModifier(chars[fromIndex].glyph.charID, chars[fromIndex - 1].glyph.charID)))
					{
						ok = false;
					}
					
					if (ok && numCharsBefore > 1 && numCharsAfter > 0)
					{
						// if first part ends with 2 consonants, second part must start with a vowel
						if (!chars[fromIndex].isVowel && !chars[fromIndex - 1].isVowel && !chars[fromIndex + 1].isVowel)
						{
							ok = false;
						}
					}
				}
				else
				{
					ok = false;
				}
			}
			
			if (ok)
			{
				// check for unbreakable pair
				if (!isForbiddenBreak(chars[fromIndex].glyph.charID, chars[fromIndex + 1].glyph.charID))
				{
					// check for unbreakable character sequence
					if (!isUnbreakableString(chars, fromIndex))
					{
						return fromIndex;
					}
				}
			}
			
			if (chars[fromIndex].isVowel)
			{
				--numVowelsBefore;
				++numVowelsAfter;
				if (numVowelsBefore == 0) break;
			}
			
			--fromIndex;
			--numCharsBefore;
			if (numCharsBefore < minCharsBefore) break;
			++numCharsAfter;
		}
		return -1;
	}
	
	//private function 
	
	public function layoutChars(width:Float, height:Float, text:String, format:TextFormat, wordWrap:Bool):Array<GlyphLocation>
	{
		var kerning:Bool = format.kerning;
        var leading:Float = format.leading;
        var spacing:Float = format.letterSpacing;
        var hAlign:String = format.horizontalAlign;
        var vAlign:String = format.verticalAlign;
        var fontSize:Float = format.size;
        var autoScale:Bool = false;// = options.autoScale;
		var hyphenation:Bool = true;
		var hyphenationMinLength:Int = 6;
		var hyphenationMinRatio:Float = 0.1;
		var hyphenationMinCharsBefore:Int = 2;
		var hyphenationMinCharsAfter:Int = 2;
		var canBreakWordsWithHyphen:Bool = true; // should we break words like master-builder
		var intPositions:Bool = true;
		var letterSpreading:Bool = true;
		var letterSpreadingMax:Float = 3.0;
		var letterSpreadingMaxCurrent:Float = letterSpreadingMax;
		var letterSpreadingMinRatio:Float = 0.05;
        var wordWrap:Bool = wordWrap;//options.wordWrap;
		
		var finished:Bool = false;
		var glyphLocation:GlyphLocation;
		var numChars:Int;
		var containerWidth:Float = 0;
		var containerHeight:Float = 0;
		var scale:Float = 1;
		var i:Int, j:Int;
		
		var lastWhiteSpace:Int;
		var lastCharID:Int;
		var currentLine:Array<GlyphLocation>;
		var currentWord:Array<GlyphLocation>;
		var currentX:Float;
		var currentY:Float = 0;
		
		var hAlignCenter:Bool = hAlign == TextAlign.CENTER;
		var hAlignJustify:Bool = true;//hAlign == TextAlign.JUSTIFY;
		var hAlignRight:Bool = hAlign == TextAlign.RIGHT;
		
		var lineFull:Bool;
		var charID:Int;
		var glyph:Glyph;
		var numCharsToRemove:Int;
		var numSpaces:Int;
		
		var remainingWidth:Float = 0.0;
		var spreadWidth:Float = 0.0;
		var cumulatedOffset:Float;
		var word:Array<GlyphLocation>;
		var nextCharID:Int;
		
		var ratio:Float;
		
		var intCounter:Float;
		var intIncrement:Float;
		var intPositionStep:Float = 1.0;
		
		var hyphenationAllowed:Bool;
		var hyphenationOccured:Bool;
		var letterSpreadingOccured:Bool = false;
		
		var testGlyph:Glyph;
		var testLocation:GlyphLocation;
		var index:Int;
		
		var lastHyphen:Int;
		
		#if debug
		var maxSpread:Float = 0;
		#end
		
		if (fontSize < 0) fontSize *= -this.size;
		
		while (!finished)
		{
			_lines.resize(0);
			_words.resize(0);
			scale = fontSize / this.size;
			containerWidth = (width - this.padding * 2) / scale;
			containerHeight = (height - this.padding * 2) / scale;
			if (intPositions) intPositionStep = 1.0 / scale;
			if (letterSpreading) letterSpreadingMaxCurrent = letterSpreadingMax / scale;
			numSpaces = 0;
			
			if (fontSize < containerHeight)
			{
				lastWhiteSpace = -1;
				lastHyphen = -1;
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
							lastHyphen = -1;
							if (currentWord.length != 0)
							{
								_words[_words.length] = currentWord;
								currentWord = GlyphLocation.arrayFromPool();
							}
							++numSpaces;
						}
						else if (charID == this._hyphenCharID && lastWhiteSpace != i - 1)
						{
							lastHyphen = i;
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
							hyphenationAllowed = hyphenation && !glyph.isSpace;
							
							if (wordWrap && hyphenationAllowed)
							{
								// we want to know how much space there will be if we put this entire word on the next line
								if (lastWhiteSpace != -1)
								{
									numCharsToRemove = i - lastWhiteSpace;
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
								else
								{
									// multi-line word (?)
									hyphenationAllowed = true;
								}
							}
							
							hyphenationOccured = false;
							if (hyphenationAllowed)
							{
								// when autoscaling, we must not split a word in half -> restart
                                if (autoScale && lastWhiteSpace == -1) break;
								
								word = GlyphLocation.arrayFromPool();
								for (c in 0...currentWord.length)
								{
									testLocation = currentWord[c];
									if (testLocation.isSpace) continue;
									word[word.length] = testLocation;
								}
								
								index = -1;
								j = word.length - 2; // we already kow that the last char doesn't fit
								while (j >= 0)
								{
									testLocation = word[j];
									if (testLocation.isHyphen || testLocation.x + testLocation.glyph.xAdvance + this._hyphenGlyph.xOffset + this._hyphenGlyph.width <= containerWidth)
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
											nextCharID = text.charCodeAt(j);
											if (nextCharID == CHAR_SPACE || nextCharID == CHAR_TAB || nextCharID == CHAR_NEWLINE || nextCharID == CHAR_CARRIAGE_RETURN) break;
											testGlyph = getGlyph(nextCharID);
											if (testGlyph.isPunctuation) break;
											//if (testGlyph.isHyphen) break; //lastHyphen = j;
											testLocation = GlyphLocation.fromPool(testGlyph);
											word[word.length] = testLocation;
											++j;
											if (j == numChars) break;
										}
									}
									
									if (word.length >= hyphenationMinLength)
									{
										if (lastHyphen != -1)
										{
											index = getBreakIndexWithHyphens(word, index, hyphenationMinCharsBefore, hyphenationMinCharsAfter, canBreakWordsWithHyphen, hyphenationMinLength);
										}
										else
										{
											index = getBreakIndex(word, index, hyphenationMinCharsBefore, hyphenationMinCharsAfter);
										}
										if (index != -1)
										{
											hyphenationOccured = true;
											testLocation = word[index];
											numCharsToRemove = i - testLocation.index;
											i = testLocation.index;
											currentLine.resize(currentLine.length - numCharsToRemove);
											currentWord.resize(currentWord.length - numCharsToRemove);
											
											if (!testLocation.isHyphen)
											{
												glyphLocation = GlyphLocation.fromPool(this._hyphenGlyph);
												glyphLocation.isHyphen = true;
												glyphLocation.index = i;
												glyphLocation.x = testLocation.x + testLocation.glyph.xAdvance + this._hyphenGlyph.xOffset;
												glyphLocation.y = currentY + this._hyphenGlyph.yOffset;
												currentLine[currentLine.length] = glyphLocation;
												currentWord[currentWord.length] = glyphLocation;
											}
											_words[_words.length] = currentWord;
										}
									}
								}
							}
							
							if (!hyphenationOccured)
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
								currentX = glyphLocation.x + glyphLocation.glyph.width;
								remainingWidth = containerWidth - currentX;
								
								#if debug
								ratio = remainingWidth / containerWidth;
								if (ratio > maxSpread) maxSpread = ratio;
								#end
								
								cumulatedOffset = 0;
								
								if (letterSpreading)
								{
									letterSpreadingOccured = false;
									ratio = remainingWidth / containerWidth;
									if (ratio >= letterSpreadingMinRatio)
									{
										spreadWidth = remainingWidth / (currentLine.length - 1);
										if (!intPositions || spreadWidth >= intPositionStep)
										{
											spreadWidth = Math.min(spreadWidth, letterSpreadingMaxCurrent);
											if (intPositions)
											{
												intIncrement = spreadWidth %  intPositionStep;
												spreadWidth -= intIncrement;
											}
											
											for (c in 1...currentLine.length)
											{
												cumulatedOffset += spreadWidth;
												currentLine[c].x += cumulatedOffset;
											}
											
											cumulatedOffset = 0;
											currentX = glyphLocation.x + glyphLocation.glyph.xAdvance;
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
							lastHyphen = -1;
							lastCharID = - 1;
							numSpaces = 0;
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
		
		#if debug
		trace("maxSpread " + maxSpread);
		#end
		
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