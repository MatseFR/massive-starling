package;

/**
 * ...
 * @author Matse
 */
class ContainerType 
{
	
	static public inline var IMG:String = "img";
	static public inline var MIXED:String = "mixed";
	static public inline var MULTIPLE:String = "multiple";
	
	static public function getValues():Array<String> { return [IMG, MIXED, MULTIPLE]; }
	
}