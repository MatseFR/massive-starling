package;

/**
 * ...
 * @author Matse
 */
class TestClass 
{
	public var publicBool:Bool;
	public var publicInt:Int;
	public var getSetBool(get, set):Bool;
	public var getSetInt(get, set):Int;
	public var inlineGetSetBool(get, set):Bool;
	public var inlineGetSetInt(get, set):Int;
	public var red(get, set):Float;
	public var inlineRed(get, set):Float;
	
	private var _getSetBool:Bool;
	private function get_getSetBool():Bool { return this._getSetBool; }
	private function set_getSetBool(value:Bool):Bool
	{
		return this._getSetBool = value;
	}
	
	private var _getSetInt:Int;
	private function get_getSetInt():Int { return this._getSetInt; }
	private function set_getSetInt(value:Int):Int
	{
		return this._getSetInt = value;
	}
	
	private var _inlineGetSetBool:Bool;
	inline private function get_inlineGetSetBool():Bool { return this._inlineGetSetBool; }
	inline private function set_inlineGetSetBool(value:Bool):Bool
	{
		return this._inlineGetSetBool = value;
	}
	
	private var _inlineGetSetInt:Int;
	inline private function get_inlineGetSetInt():Int { return this._inlineGetSetInt; }
	inline private function set_inlineGetSetInt(value:Int):Int
	{
		return this._inlineGetSetInt = value;
	}
	
	private var _red:Float;
	private function get_red():Float { return this._red; }
	private function set_red(value:Float):Float
	{
		this._red1 = this._red2 = this._red3 = this._red4 = value;
		return this._red = value;
	}
	
	private var _inlineRed:Float;
	inline private function get_inlineRed():Float { return this._red; }
	inline private function set_inlineRed(value:Float):Float
	{
		this._red1 = this._red2 = this._red3 = this._red4 = value;
		return this._inlineRed = value;
	}
	
	private var _red1:Float;
	private var _red2:Float;
	private var _red3:Float;
	private var _red4:Float;

	public function new() 
	{
		
	}
	
}