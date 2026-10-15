package massive.text.internal;
import massive.animation.Animation;
import massive.display.Clip;

/**
 * ...
 * @author Matse
 */
class ClipConfig extends GraphicConfig 
{
	private static var _POOL:Array<ClipConfig> = new Array<ClipConfig>();
	
	public static function fromPool(json:Dynamic = null):ClipConfig
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(json);
		return new ClipConfig(json);
	}
	
	public var animation:Animation;
	
	public function new(json:Dynamic = null) 
	{
		super(json);
	}
	
	override public function clear():Void 
	{
		this.animation = null;
		
		super.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(json:Dynamic):ClipConfig
	{
		if (json != null) fromJson(json);
		return this;
	}
	
	override public function fromJson(json:Dynamic):Void 
	{
		if (json.animation != null) this.animation = MassiveText.animations.get(json.animation);
		
		super.fromJson(json);
	}
	
	public function toClip(clip:Clip = null):Clip
	{
		if (clip == null) clip = Clip.fromPool();
		
		clip.play(this.animation);
		
		clip.scale = this.scale;
		
		clip.red = this.red;
		clip.green = this.green;
		clip.blue = this.blue;
		clip.alpha = this.alpha;
		
		clip.redOffset = this.redOffset;
		clip.greenOffset = this.greenOffset;
		clip.blueOffset = this.blueOffset;
		clip.alphaOffset = this.alphaOffset;
		
		return clip;
	}
	
}