package massive.util;

/**
 * This is heavily based on Jackson Dunstan's articles 
 * https://www.jacksondunstan.com
 * all improvement indications are from the as3 version for now and need to be checked on various targets
 * @author Matse
 */
class MathUtils 
{
	inline static public var DEG2RAD:Float = 0.01745329251994329576923690768489;
	inline static public var FLOAT_MAX:Float = 1.79769313486231e+308; // from flambe.math.FMath
	inline static public var FLOAT_MIN:Float = -1.79769313486231e+308; // from flambe.math.FMath
	inline static public var INT_MAX:Float = 2147483647; // from flambe.math.FMath
	inline static public var INT_MIN:Float = -2147483648; // from flambe.math.FMath
	inline static public var RAD2DEG:Float = 57.295779513082320876798154814105;
	static public var RANDOM_SEED:Int = 1;
	
	/** 6-7 times faster than Math.abs */
	inline static public function abs(val:Float):Float
	{
		return val < 0.0 ? -val : val;
	}
	
	/** About 10-20% faster than MathUtils.abs for integers */
	inline static public function absInt(val:Int):Int
	{
		return (val ^ (val >> 31)) - (val >> 31);
	}
	
	/** 10 times faster than Math.atan2 */
	inline static public function atan2(y:Float, x:Float):Float
	{
		var result:Float;
		if (y > 0)
		{
			if (x >= 0) 
				result = 0.78539816339744830961566084581988 - 0.78539816339744830961566084581988 * (x - y) / (x + y);
			else
				result = 2.3561944901923449288469825374596 - 0.78539816339744830961566084581988 * (x + y) / (y - x);
		}
		else
		{
			if (x >= 0) 
				result = -0.78539816339744830961566084581988 + 0.78539816339744830961566084581988 * (x + y) / (x - y);            
			else
				result = -2.3561944901923449288469825374596 - 0.78539816339744830961566084581988 * (x - y) / (y + x);
		}
		return result;
	}
	
	/** Almost 3 times faster than Math.ceil */
	inline static public function ceil(val:Float):Int
	{
		//return (val != val) ? Math.NaN : val == Std.int(val) ? val : val >= 0 ? Std.int(val + 1) : Std.int(val);
		return val == Std.int(val) ? Std.int(val) : val >= 0 ? Std.int(val + 1) : Std.int(val);
	}
	
	inline static public function fceil(val:Float):Float
	{
		return val == Std.int(val) ? val : val >= 0 ? Std.int(val + 1) : Std.int(val);
	}
	
	/** Almost 3 times faster than Math.floor */
	inline static public function floor(val:Float):Int
	{
		//return (val != val) ? Math.NaN : val == Std.int(val) ? val : val < 0 ? Std.int(val - 1) : Std.int(val);
		return val == Std.int(val) ? Std.int(val) : val < 0 ? Std.int(val - 1) : Std.int(val);
	}
	
	inline static public function ffloor(val:Float):Float
	{
		return val == Std.int(val) ? val : val < 0 ? Std.int(val - 1) : Std.int(val);
	}
	
	/** 45 times faster than isNaN */
	inline static public function isNaN(val:Float):Bool
	{
		return val != val;
	}
	
	/** 7 times faster than Math.max */
	inline static public function max(val1:Float, val2:Float):Float
	{
		if ((val1 != val1) || (val2 != val2))
		{
			return Math.NaN;
		}
		return val1 > val2 ? val1 : val2;
	}
	
	/** 7 times faster than Math.min */
	inline static public function min(val1:Float, val2:Float):Float
	{
		if ((val1 != val1) || (val2 != val2))
		{
			return Math.NaN;
		}
		return val1 < val2 ? val1 : val2;
	}
	
	/** 7 times faster than Math.random */
	inline static public function random():Float
	{
		return ((RANDOM_SEED = (RANDOM_SEED * 16807) & 0x7FFFFFFF) / 2147483648);
	}
	
	/** 8 times faster than starling's deg2rad */
	inline static public function deg2rad(deg:Float):Float
	{
		return deg * DEG2RAD;
	}
	
	/** 8 times faster than starling's rad2deg */
	inline static public function rad2deg(rad:Float):Float
	{
		return rad * RAD2DEG;
	}
	
}