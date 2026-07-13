package massive.display;
import massive.animation.BasicAnimation;
import massive.animation.BasicAnimationFrame;
import openfl.Vector;

/**
 * ...
 * @author Matse
 */
class BasicClip extends Img 
{
	static private var _POOL:Array<BasicClip> = new Array<BasicClip>();
	
	static public function fromPool():BasicClip
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new BasicClip();
	}
	
	/**
	   Tells whether this object is animated or not
	**/
	public var animate:Bool = false;
	/**
	   Current animation
	**/
	public var animation(default, null):BasicAnimation;
	public var animationFrame:BasicAnimationFrame;
	public var completeCallback:BasicClip->Void;
	public var frameDelta:Float = 1.0;
	public var frameIndex(get, set):Int;
	public var frameTime:Float = 0.0;
	public var frameTimingCurrent:Float;
	public var lastFrameIndex:Int = -1;
	public var loop:Bool;
	public var loopCount:Int = 0;
	/**
	   How many loops, 0 == infinite
	   @default	0
	**/
	public var numLoops:Int = 0;
	
	private var _frameIndex:Int = -1;
	private inline function get_frameIndex():Int { return this._frameIndex; }
	private inline function set_frameIndex(value:Int):Int
	{
		if (this._frameIndex == value) return value;
		this.animationFrame = this._frames[value];
		this.frame = this.animationFrame.frame;
		this.frameTimingCurrent = this.animationFrame.timing;
		return this._frameIndex = value;
	}
	
	#if flash
	private var _frames:Vector<BasicAnimationFrame>;
	#else
	private var _frames:Array<BasicAnimationFrame>;
	#end

	public function new() 
	{
		super();
		
	}
	
	override public function clear():Void
	{
		clearAnimation();
	}
	
	override public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function clearAnimation():Void
	{
		this.animation = null;
		this._frameIndex = this.lastFrameIndex = -1;
		this.frameTime = 0.0;
		this.loop = false;
		this.loopCount = 0;
		this.numLoops = 0;
	}
	
	public function play(animation:BasicAnimation, frameIndex:Int = 0, completeCallback:BasicClip->Void = null):Void
	{
		this.animation = animation;
		this._frames = this.animation.frames;
		this.frameIndex = frameIndex;
		this.frameTime = this._frameIndex == 0 ? 0.0 : this._frames[this._frameIndex - 1].timing;
		this.completeCallback = completeCallback;
		this.lastFrameIndex = this.animation.lastFrame;
		this.loop = this.animation.loop;
		this.numLoops = this.animation.numLoops;
		this.animate = true;
	}
	
	public function pause():Void
	{
		this.animate = false;
	}
	
	public function resume():Void
	{
		this.animate = true;
	}
	
}