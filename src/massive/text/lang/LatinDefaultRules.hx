package massive.text.lang;

/**
 * ...
 * @author Matse
 */
class LatinDefaultRules extends LatinRulesBase 
{
	// helpers
	private var __hyphenIndexes:Array<Int> = new Array<Int>();

	public function new() 
	{
		super();
		
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
	
	public function getBreakIndexWithHyphens(chars:Array<GlyphLocation>, fromIndex:Int, minWordLength:Int):Int
	{
		this.__hyphenIndexes.resize(0);
		var minCharsBefore:Int = 1;
		var minCharsAfter:Int = 1;
		var canBreakWords:Bool = true;
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
					
					index = getBreakIndex(word, fromIndex - hyphenIndex);
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
	
	public function getBreakIndex(chars:Array<GlyphLocation>, fromIndex:Int):Int
	{
		var minCharsBefore:Int = 1;
		var minCharsAfter:Int = 1;
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
				if (chars[fromIndex].isHyphen)
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
	
}