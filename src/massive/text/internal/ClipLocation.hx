package massive.text.internal;
import massive.animation.Animation;

/**
 * ...
 * @author Matse
 */
class ClipLocation extends ElementLocation 
{
	private static var _POOL:Array<ClipLocation> = new Array<ClipLocation>();
	private static var _OUT:Array<ClipLocation> = new Array<ClipLocation>();
	
	private static var _instance:ClipLocation;
	
	public static function fromPool(animation:Animation):ClipLocation
	{
		_instance = _POOL.length != 0 ? _POOL.pop().setFromPool(animation) : new ClipLocation(animation);
		return _OUT[_OUT.length] = _instance;
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_instance.animation = null;
			_instance.frame = null;
			_instance.textPart = null;
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
	}
	
	public var animation(default, null):Animation;
	
	public function new(animation:Animation) 
	{
		super();
		this.animation = animation;
		this.frame = this.animation.referenceFrame;
		
		this.width = this.frame.width;
		this.height = this.frame.height;
		this.xAdvance = this.width;
		this.xOffset = this.yOffset = 0.0;
	}
	
	private function setFromPool(animation:Animation):ClipLocation
	{
		this.animation = animation;
		this.frame = this.animation.referenceFrame;
		
		this.width = this.frame.width;
		this.height = this.frame.height;
		this.xAdvance = this.width;
		this.xOffset = this.yOffset = 0.0;
		return this;
	}
	
}