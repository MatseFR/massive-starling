package massive.data;

/**
 * ...
 * @author Matse
 */
class LookUp 
{
	static public var initDone(get, never):Bool;
	static private var _initDone:Bool = false;
	static private function get_initDone():Bool { return _initDone; }
	
	static public var COS(get, never):Array<Float>;
	static private var _COS:Array<Float>;
	static private function get_COS():Array<Float>
	{
		if (!_initDone) init();
		return _COS;
	}
	
	static public var SIN(get, never):Array<Float>;
	static private var _SIN:Array<Float>;
	static private function get_SIN():Array<Float>
	{
		if (!_initDone) init();
		return _SIN;
	}
	
	private static inline var COSINUS_CONSTANT:Float = 0.00306796157577128245943617517898;
	private static inline var SINUS_CONSTANT:Float = 0.00306796157577128245943617517898;
	
	static public function init():Void
	{
		if (_initDone) return;
		
		_COS = new Array<Float>();
		_SIN = new Array<Float>();
		
		for (i in 0...0x800)
		{
			_COS[i & 0x7FF] = Math.cos(i * COSINUS_CONSTANT);
			_SIN[i & 0x7FF] = Math.sin(i * SINUS_CONSTANT);
		}
		
		_initDone = true;
	}
	
	inline static public function getAngle(angle:Float):Int
	{
		return Std.int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
	}
	
}