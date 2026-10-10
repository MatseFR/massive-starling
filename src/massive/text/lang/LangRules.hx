package massive.text.lang;
import massive.text.internal.ElementLocation;

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
	
	abstract public function getBreakIndexWithHyphens(chars:Array<ElementLocation>, fromIndex:Int, minWordLength:Int):Int;
	
	abstract public function getBreakIndex(chars:Array<ElementLocation>, fromIndex:Int):Int;
	
}