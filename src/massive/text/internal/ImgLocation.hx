package massive.text.internal;

/**
 * ...
 * @author Matse
 */
class ImgLocation extends ElementLocation 
{
	private static var _POOL:Array<ImgLocation> = new Array<ImgLocation>();
	private static var _OUT:Array<ImgLocation> = new Array<ImgLocation>();
	
	private static var _instance:ImgLocation;
	
	public static function fromPool(config:ImgConfig):ImgLocation
	{
		return _OUT[_OUT.length] = _POOL.length != 0 ? _POOL.pop().setFromPool(config) : new ImgLocation(config);
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_instance.imgConfig = null;
			_instance.linePart = null;
			_instance._scale = 1.0;
			_instance.textPart = null;
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
	}
	
	public var imgConfig(default, null):ImgConfig;
	
	public function new(config:ImgConfig) 
	{
		super();
		this.imgConfig = config;
		
		this.originalWidth = this.width = this.imgConfig.frame.width * this.imgConfig.scale;
		this.originalHeight = this.height = this.imgConfig.frame.height * this.imgConfig.scale;
		this.originalXAdvance = this.xAdvance = this.width;
		this.originalXOffset = this.originalYOffset = this.xOffset = this.yOffset = 0.0;
	}
	
	private function setFromPool(config:ImgConfig):ImgLocation
	{
		this.imgConfig = config;
		
		this.originalWidth = this.width = this.imgConfig.frame.width * this.imgConfig.scale;
		this.originalHeight = this.height = this.imgConfig.frame.height * this.imgConfig.scale;
		this.originalXAdvance = this.xAdvance = this.width;
		this.originalXOffset = this.originalYOffset = this.xOffset = this.yOffset = 0.0;
		return this;
	}
	
}