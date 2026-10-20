package massive.text.internal;

/**
 * ...
 * @author Matse
 */
class ClipLocation extends ElementLocation 
{
	private static var _POOL:Array<ClipLocation> = new Array<ClipLocation>();
	private static var _OUT:Array<ClipLocation> = new Array<ClipLocation>();
	
	private static var _instance:ClipLocation;
	
	public static function fromPool(config:ClipConfig):ClipLocation
	{
		return _OUT[_OUT.length] = _POOL.length != 0 ? _POOL.pop().setFromPool(config) : new ClipLocation(config);
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_instance.clipConfig = null;
			_instance.linePart = null;
			_instance._scale = 1.0;
			_instance.textPart = null;
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
	}
	
	public var clipConfig(default, null):ClipConfig;
	
	public function new(config:ClipConfig) 
	{
		super();
		this.clipConfig = config;
		
		this.originalWidth = this.width = this.clipConfig.animation.referenceFrame.width * this.clipConfig.scale;
		this.originalHeight = this.height = this.clipConfig.animation.referenceFrame.height * this.clipConfig.scale;
		this.originalXAdvance = this.xAdvance = this.width;
		this.originalXOffset = this.originalYOffset = this.xOffset = this.yOffset = 0.0;
	}
	
	private function setFromPool(config:ClipConfig):ClipLocation
	{
		this.clipConfig = config;
		
		this.originalWidth = this.width = this.clipConfig.animation.referenceFrame.width * this.clipConfig.scale;
		this.originalHeight = this.height = this.clipConfig.animation.referenceFrame.height * this.clipConfig.scale;
		this.originalXAdvance = this.xAdvance = this.width;
		this.originalXOffset = this.originalYOffset = this.xOffset = this.yOffset = 0.0;
		return this;
	}
	
}