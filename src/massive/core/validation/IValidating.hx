package massive.core.validation;

/**
 * Directly inspired by FeathersUI-starling
 * @author Matse
 */
interface IValidating 
{
	public var isOnValidationQueue(default, null):Bool;
	
	function validate():Void;
}