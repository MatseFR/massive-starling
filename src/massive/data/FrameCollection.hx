package massive.data;

/**
 * ...
 * @author Matse
 */
class FrameCollection 
{
	private static var _POOL:Array<FrameCollection> = new Array<FrameCollection>();
	
	static public function fromPool():FrameCollection
	{
		return new FrameCollection();
	}
	
	private var _frameMap:Map<String, Frame> = new Map<String, Frame>();

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._frameMap.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	public function add(id:String, frame:Frame):Void
	{
		this._frameMap.set(id, frame);
	}
	
	public function get(id:String):Frame
	{
		return this._frameMap.get(id);
	}
	
	public function remove(id:String):Void
	{
		this._frameMap.remove(id);
	}
	
}