package massive.core;
import massive.animation.Animator;
import massive.display.MassiveDisplay;
import massive.core.validation.ValidationQueue;
import openfl.errors.Error;
import starling.animation.Juggler;
import starling.core.Starling;

/**
 * ...
 * @author Matse
 */
class Massive 
{
	public static var animator(default, null):Animator;
	public static var validationQueue(default, null):ValidationQueue;
	
	private static var _initDone:Bool = false;
	
	public static function init(starling:Starling = null, juggler:Juggler = null):Void
	{
		if (_initDone) return;
		if (starling == null) starling = Starling.current;
		if (starling == null) throw new Error("Massive.init should be called after Starling has started");
		if (juggler == null) juggler = starling.juggler;
		
		MassiveDisplay.init();
		
		validationQueue = new ValidationQueue(starling);
		juggler.add(validationQueue);
		
		animator = new Animator();
		juggler.add(animator);
	}
	
}