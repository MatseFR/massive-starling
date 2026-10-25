package massive.text.lang;
import massive.text.FontStyle;
import massive.text.Glyph;
import massive.text.MassiveFont;
import massive.text.internal.ElementLocation;

/**
 * ...
 * @author Matse
 */
abstract class LatinRulesBase extends LangRules
{
	public static var CONSONANTS:String = "bcdfghjklmnpqrstvwxz";
	public static var CONSONANTS_IDS:Array<Int> = [98, 99, 100, 102, 103, 104, 106, 107, 108, 109, 110, 112, 113, 114, 115, 116, 118, 119, 120, 122];
	
	public static var NUMBERS:String = "0123456789";
	public static var NUMBERS_IDS:Array<Int> = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57];
	
	public static var PUNCTUATION:String = ",;.:!?()[]{}«»\"-/";
	public static var PUNCTUATION_IDS:Array<Int> = [44, 59, 46, 58, 33, 63, 40, 41, 91, 93, 123, 125, 171, 187, 34, 45, 47];
	
	public static var VOWELS:String = "aeiouy";
	public static var VOWELS_IDS:Array<Int> = [97, 101, 105, 111, 117, 121];
	
	private var _breakableVowels:Map<Int, Bool> = new Map<Int, Bool>();
	private var _breakableVowelModifiers:Map<Int, Array<Int>> = new Map<Int, Array<Int>>();
	private var _forbiddenBreaks:Map<Int, Array<Int>> = new Map<Int, Array<Int>>();
	
	private var _unbreakableStrings:Map<Int, Array<Array<Int>>> = new Map<Int, Array<Array<Int>>>();
	private var _minUnbreakableChars:Int = 0;
	private var _maxUnbreakableChars:Int = 0;
	private var _hasUnbreakableStrings:Bool;
	
	public function new() 
	{
		super();
	}
	
	public function dispose():Void
	{
		this._breakableVowels.clear();
		this._breakableVowelModifiers.clear();
		this._forbiddenBreaks.clear();
		this._unbreakableStrings.clear();
	}
	
	public function applyToFont(font:MassiveFont):Void
	{
		var styleNames:Array<String> = font.getFontStyleNames();
		for (i in 0...styleNames.length)
		{
			applyToFontStyle(font.getFontStyle(styleNames[i]));
		}
	}
	
	public function applyToFontStyle(style:FontStyle):Void
	{
		var glyph:Glyph;
		
		for (i in 0...CONSONANTS_IDS.length)
		{
			glyph = style.getGlyph(CONSONANTS_IDS[i]);
			if (glyph == null) continue;
			glyph.isLetter = true;
		}
		
		for (i in 0...VOWELS_IDS.length)
		{
			glyph = style.getGlyph(VOWELS_IDS[i]);
			if (glyph == null) continue;
			glyph.isLetter = true;
			glyph.isVowel = true;
		}
		
		for (i in 0...PUNCTUATION_IDS.length)
		{
			glyph = style.getGlyph(PUNCTUATION_IDS[i]);
			if (glyph == null) continue;
			glyph.isPunctuation = true;
		}
		
		for (i in 0...NUMBERS_IDS.length)
		{
			glyph = style.getGlyph(NUMBERS_IDS[i]);
			if (glyph == null) continue;
			glyph.isNumber = true;
		}
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
	
	public function isUnbreakableString(chars:Array<ElementLocation>, fromIndex:Int):Bool
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
				entries = this._unbreakableStrings.get(chars[i].charID);
				if (entries == null) continue;
				
				numEntries = entries.length;
				for (j in 0...numEntries)
				{
					entry = entries[j];
					if (entry.length != numChars) continue;
					
					unbreakable = true;
					for (k in 0...numChars)
					{
						if (chars[i + k].charID != entry[k])
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
	
}