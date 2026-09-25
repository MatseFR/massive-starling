package massive.text.lang;

/**
 * ...
 * @author Matse
 */
abstract class LangRules 
{

	public function new() 
	{
		
	}
	
	abstract public function dispose():Void;
	
	abstract public function getBreakIndexWithHyphens(chars:Array<GlyphLocation>, fromIndex:Int, minWordLength:Int):Int;
	
	abstract public function getBreakIndex(chars:Array<GlyphLocation>, fromIndex:Int):Int;
	
}