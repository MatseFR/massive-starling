package massive.display.base;
import starling.events.EventDispatcher;

/**
 * ...
 * @author Matse
 */
abstract class DisplayBase extends EventDispatcher
{
	/**
	   Tells whether this object is animated or not
	   @default	false
	**/
	public var animate:Bool = false;
	/**
	   Tells wether this object is a container or not
	**/
	public var isContainer(default, null):Bool = false;
	/**
	   
	**/
	public var name:String;
	/**
	   Tells whether this object is visible or not.
	   @default true
	**/
	public var visible:Bool = true;
	/**
	   The object's position on x axis, relative to the MassiveDisplay and container(s) it belongs to
	   @default 0
	**/
	public var x:Float = 0.0;
	/**
	   The object's position on y axis, relative to the MassiveDisplay and container(s) it belongs to
	   @default 0
	**/
	public var y:Float = 0.0;

	public function new() 
	{
		super();
	}
	
}