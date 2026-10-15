package massive.text.internal;
import massive.data.Frame;
import massive.display.Img;

/**
 * ...
 * @author Matse
 */
class ImgConfig extends GraphicConfig
{
	static private var _POOL:Array<ImgConfig> = new Array<ImgConfig>();
	
	static public function fromPool(json:Dynamic = null):ImgConfig
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(json);
		return new ImgConfig(json);
	}
	
	public var frame:Frame;
	
	public function new(json:Dynamic = null) 
	{
		super(json);
	}
	
	override public function clear():Void 
	{
		this.frame = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(json:Dynamic):ImgConfig
	{
		if (json != null) fromJson(json);
		return this;
	}
	
	override public function fromJson(json:Dynamic):Void 
	{
		if (json.frame != null) this.frame = MassiveText.frames.get(json.frame);
		
		super.fromJson(json);
	}
	
	public function toImg(img:Img = null):Img
	{
		if (img == null) 
		{
			img = Img.fromPool(this.frame);
		}
		else
		{
			img.frame = this.frame;
		}
		
		img.scale = this.scale;
		
		img.red = this.red;
		img.green = this.green;
		img.blue = this.blue;
		img.alpha = this.alpha;
		
		img.redOffset = this.redOffset;
		img.greenOffset = this.greenOffset;
		img.blueOffset = this.blueOffset;
		img.alphaOffset = this.alphaOffset;
		
		return img;
	}
	
}