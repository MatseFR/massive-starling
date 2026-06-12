package massive.animation;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexColorExData;
import massive.data.VertexData;

/**
 * ...
 * @author Matse
 */
class AnimationFrame 
{
	static private var _POOL:Array<AnimationFrame> = new Array<AnimationFrame>();
	
	static public function fromPool(frame:Frame = null, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null, 
									vertexData:VertexData = null, vertexColorData:VertexColorData = null, vertexColorExData:VertexColorExData = null):AnimationFrame
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(frame, timing, event, eventParams);
		return new AnimationFrame(frame, timing, event, eventParams);
	}
	
	public var event:String;
	public var eventParams:Dynamic;
	public var frame:Frame;
	public var timing:Float;
	public var vertexData:VertexData;
	public var vertexColorData:VertexColorData;
	public var vertexColorExData:VertexColorExData;

	public function new(frame:Frame = null, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null, 
						vertexData:VertexData = null, vertexColorData:VertexColorData = null, vertexColorExData:VertexColorExData = null) 
	{
		this.frame = frame;
		this.timing = timing;
		this.event = event;
		this.eventParams = eventParams;
		this.vertexData = vertexData;
		this.vertexColorData = vertexColorData;
		this.vertexColorExData = vertexColorExData;
	}
	
	public function clear():Void
	{
		this.event = null;
		this.eventParams = null;
		this.frame = null;
		this.timing = 0.0;
		this.vertexData = null;
		this.vertexColorData = null;
		this.vertexColorExData = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(frame:Frame, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null, 
								 vertexData:VertexData = null, vertexColorData:VertexColorData = null, vertexColorExData:VertexColorExData = null):AnimationFrame
	{
		this.frame = frame;
		this.timing = timing;
		this.event = event;
		this.eventParams = eventParams;
		this.vertexData = vertexData;
		this.vertexColorData = vertexColorData;
		this.vertexColorExData = vertexColorExData;
		return this;
	}
	
}