package massive.text.lang;

/**
 * ...
 * @author Matse
 */
abstract class LatinRulesBase extends LangRules
{
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
	
}