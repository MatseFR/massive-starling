package massive.data;
import openfl.Vector;

/**
 * ...
 * @author Matse
 */
class LookUp 
{
	static public var initDone(get, never):Bool;
	static private var _initDone:Bool = false;
	static private function get_initDone():Bool { return _initDone; }
	
	// Note : for some reason, using Vector here on flash/air target ends up with quite a lot of garbage collection and lesser performance, so I'm sticking with Array
	//#if flash
	//static public var COS(get, never):Vector<Float>;
	//static private var _COS:Vector<Float>;
	//static private function get_COS():Vector<Float>
	//{
		//if (!_initDone) init();
		//return _COS;
	//}
	//
	//static public var SIN(get, never):Vector<Float>;
	//static private var _SIN:Vector<Float>;
	//static private function get_SIN():Vector<Float>
	//{
		//if (!_initDone) init();
		//return _SIN;
	//}
	//#else
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
	//#end
	
	static private inline var COSINUS_CONSTANT:Float = 0.00306796157577128245943617517898;
	static private inline var SINUS_CONSTANT:Float = 0.00306796157577128245943617517898;
	
	static public function init():Void
	{
		if (_initDone) return;
		
		//#if flash
		//_COS = new Vector<Float>(2048, true);
		//_SIN = new Vector<Float>(2048, true);
		//#else
		_COS = new Array<Float>();
		_SIN = new Array<Float>();
		//#end
		
		for (i in 0...0x800)
		{
			_COS[i & 0x7FF] = Math.cos(i * COSINUS_CONSTANT);
			_SIN[i & 0x7FF] = Math.sin(i * SINUS_CONSTANT);
		}
		
		_initDone = true;
	}
	
	static public inline function getAngle(angle:Float):Int
	{
		return Std.int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
	}
	
	static public inline function cos(angle:Float):Float
	{
		return _COS[Std.int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
	}
	
	static public inline function sin(angle:Float):Float
	{
		return _SIN[Std.int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
	}
	
}