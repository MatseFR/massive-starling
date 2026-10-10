package massive.text.internal;
import massive.data.Frame;

/**
 * ...
 * @author Matse
 */
class ImgLocation extends ElementLocation 
{
	private static var _POOL:Array<ImgLocation> = new Array<ImgLocation>();
	private static var _OUT:Array<ImgLocation> = new Array<ImgLocation>();
	
	private static var _instance:ImgLocation;
	
	public static function fromPool(frame:Frame):ImgLocation
	{
		_instance = _POOL.length != 0 ? _POOL.pop().setFromPool(frame) : new ImgLocation(frame);
		return _OUT[_OUT.length] = _instance;
	}
	
	public static function rechargePool():Void
	{
		var count:Int = _OUT.length;
		for (i in 0...count)
		{
			_instance = _OUT[i];
			_instance.frame = null;
			_instance.textPart = null;
			_POOL[_POOL.length] = _instance;
		}
		_OUT.resize(0);
	}
	
	public function new(frame:Frame) 
	{
		super();
		this.frame = frame;
		
		this.width = this.frame.width;
		this.height = this.frame.height;
		this.xAdvance = this.width;
		this.xOffset = this.yOffset = 0.0;
	}
	
	private function setFromPool(frame:Frame):ImgLocation
	{
		this.frame = frame;
		
		this.width = this.frame.width;
		this.height = this.frame.height;
		this.xAdvance = this.width;
		this.xOffset = this.yOffset = 0.0;
		return this;
	}
	
}