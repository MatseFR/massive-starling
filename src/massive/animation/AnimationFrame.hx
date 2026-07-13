package massive.animation;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;

/**
 * ...
 * @author Matse
 */
class AnimationFrame 
{
	static private var _POOL:Array<AnimationFrame> = new Array<AnimationFrame>();
	
	static public function fromPool(frame:Frame = null, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null, 
									vertexPosition:VertexPositionData = null, vertexColor:VertexColorData = null, vertexColorOffset:VertexColorData = null):AnimationFrame
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(frame, timing, event, eventParams, vertexPosition, vertexColor, vertexColorOffset);
		return new AnimationFrame(frame, timing, event, eventParams);
	}
	
	public var event:String;
	public var eventParams:Dynamic;
	public var frame:Frame;
	public var timing:Float;
	public var vertexPosition:VertexPositionData;
	public var vertexColor:VertexColorData;
	public var vertexColorOffset:VertexColorData;

	public function new(frame:Frame = null, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null, 
						vertexData:VertexPositionData = null, vertexColorData:VertexColorData = null, vertexColorOffset:VertexColorData = null) 
	{
		this.frame = frame;
		this.timing = timing;
		this.event = event;
		this.eventParams = eventParams;
		this.vertexPosition = vertexData;
		this.vertexColor = vertexColorData;
		this.vertexColorOffset = vertexColorOffset;
	}
	
	public function clear():Void
	{
		this.event = null;
		this.eventParams = null;
		this.frame = null;
		this.timing = 0.0;
		this.vertexPosition = null;
		this.vertexColor = null;
		this.vertexColorOffset = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(frame:Frame, timing:Float = 0.0, event:String = null, eventParams:Dynamic = null, 
								 vertexPosition:VertexPositionData = null, vertexColor:VertexColorData = null, vertexColorOffset:VertexColorData = null):AnimationFrame
	{
		this.frame = frame;
		this.timing = timing;
		this.event = event;
		this.eventParams = eventParams;
		this.vertexPosition = vertexPosition;
		this.vertexColor = vertexColor;
		this.vertexColorOffset = vertexColorOffset;
		return this;
	}
	
}