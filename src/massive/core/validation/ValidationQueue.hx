package massive.core.validation;

import starling.animation.IAnimatable;
import starling.core.Starling;

/**
 * Directly inspired by FeathersUI-starling
 * @author Matse
 */
@:access(massive.core.validation.IValidating)
class ValidationQueue implements IAnimatable 
{
	private var _isValidating:Bool;
	private var _queue:Array<IValidating> = new Array<IValidating>();
	private var _starling:Starling;

	public function new(starling:Starling) 
	{
		this._starling = starling;
	}
	
	public function add(element:IValidating):Void
	{
		if (element.isOnValidationQueue) return;
		this._queue[this._queue.length] = element;
		element.isOnValidationQueue = true;
	}
	
	public function remove(element:IValidating):Void
	{
		var index:Int = this._queue.indexOf(element);
		if (index != -1) 
		{
			this._queue.splice(index, 1);
			element.isOnValidationQueue = false;
		}
	}
	
	public function advanceTime(time:Float):Void 
	{
		if (this._isValidating || !this._starling.contextValid) return;
		
		this._isValidating = true;
		
		var i:Int = 0;
		while (i < this._queue.length)
		{
			this._queue[i].validate();
			this._queue[i].isOnValidationQueue = false;
			++i;
		}
		
		this._queue.resize(0);
		this._isValidating = false;
	}
	
}