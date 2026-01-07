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
	inline static public var HALF_PI:Float = 1.5707963267948966192313216916398;
	inline static public var INT_MAX:Int = 2147483647; // from flambe.math.FMath
	inline static public var INT_MIN:Int = -2147483648; // from flambe.math.FMath
	inline static public var PI2:Float = 6.283185307179586476925286766559;
	inline static public var RAD2DEG:Float = 57.295779513082320876798154814105;
	static public var RANDOM_SEED:Int = 1;
	
	/**
	   Returns the absolute value of `val`.
	   html5	~5% faster than Math.abs(val)
	   @param	val
	   @return
	**/
	inline static public function abs(val:Float):Float
	{
		#if html5
		return val < 0.0 ? -val : val;
		#else
		return Math.abs(val);
		#end
	}
	
	/**
	   Returns the absolute value of `val`.
	   flash/air		~140% faster than Std.int(Math.abs(val))
	   hxcpp windows	?% faster than Std.int(Math.abs(val)) (hard to measure, time is 0 vs some time)
	   html5			not sure
	   @param	val
	   @return
	**/
	inline static public function absInt(val:Int):Int
	{
		return (val ^ (val >> 31)) - (val >> 31);
	}
	
	/**
	   Returns the trigonometric arc tangent whose tangent is the quotient of two specified numbers, in radians.
	   html5	not sure
	   @param	y
	   @param	x
	   @return
	**/
	inline static public function atan2(y:Float, x:Float):Float
	{
		//#if html5
		//var result:Float;
		//if (y > 0)
		//{
			//if (x >= 0) 
				//result = 0.78539816339744830961566084581988 - 0.78539816339744830961566084581988 * (x - y) / (x + y);
			//else
				//result = 2.3561944901923449288469825374596 - 0.78539816339744830961566084581988 * (x + y) / (y - x);
		//}
		//else
		//{
			//if (x >= 0) 
				//result = -0.78539816339744830961566084581988 + 0.78539816339744830961566084581988 * (x + y) / (x - y);            
			//else
				//result = -2.3561944901923449288469825374596 - 0.78539816339744830961566084581988 * (x - y) / (y + x);
		//}
		//return result;
		//#else
		return Math.atan2(y, x);
		//#end
	}
	
	/**
	   Returns the smallest integer value that is not less than `val`.
	   flash/air	~180% faster than Math.ceil(val)
	   @param	val
	   @return
	**/
	inline static public function ceil(val:Float):Int
	{
		#if flash
		return val == Std.int(val) ? Std.int(val) : val >= 0 ? Std.int(val + 1) : Std.int(val);
		#else
		return Math.ceil(val);
		#end
	}
	
	/**
	   Returns the largest integer value that is not greater than `val`.
	   flash/air	~190% faster than Math.floor(val)
	   @param	val
	   @return
	**/
	inline static public function floor(val:Float):Int
	{
		#if flash
		return val == Std.int(val) ? Std.int(val) : val < 0 ? Std.int(val - 1) : Std.int(val);
		#else
		return Math.floor(val);
		#end
	}
	
	/**
	   Tells if `val` is Math.NaN
	   flash/air		8-9000% faster than Math.isNaN(val)
	   hxcpp windows	?% faster than Math.isNaN(val) (hard to measure, time is 0 vs some time)
	   @param	val
	   @return
	**/
	inline static public function isNaN(val:Float):Bool
	{
		//#if html5
		//return Math.isNaN(val);
		//#else
		return val != val;
		//#end
	}
	
	/**
	   Returns the greater of values `val1` and `val2`.
	   flash/air	~900% faster than Math.max(val1, val2)
	   html5		~50% faster than Math.max(val1, val2)
	   @param	val1
	   @param	val2
	   @return
	**/
	inline static public function max(val1:Float, val2:Float):Float
	{
		return val1 > val2 ? val1 : val2;
	}
	
	/**
	   Returns the greater of values `val1` and `val2`.
	   @param	val1
	   @param	val2
	   @return
	**/
	inline static public function maxInt(val1:Int, val2:Int):Int
	{
		return val1 > val2 ? val1 : val2;
	}
	
	/**
	   Returns the smaller of values `val1` and `val2`.
	   flash/air	~800% faster than Math.min(val1, val2)
	   html5		~50% faster than Math.min(val1, val2)
	   @param	val1
	   @param	val2
	   @return
	**/
	inline static public function min(val1:Float, val2:Float):Float
	{
		return val1 < val2 ? val1 : val2;
	}
	
	/**
	   Returns the smaller of values `val1` and `val2`.
	   @param	val1
	   @param	val2
	   @return
	**/
	inline static public function minInt(val1:Int, val2:Int):Int
	{
		return val1 < val2 ? val1 : val2;
	}
	
	/**
	   Returns a pseudo-random number which is greater than or equal to 0.0, and less than 1.0.
	   flash/air		~400% faster than Math.random()
	   hxcpp windows	~8000% faster than Math.random()
	   @return
	**/
	inline static public function random():Float
	{
		#if html5
		return Math.random();
		#else
		return ((RANDOM_SEED = (RANDOM_SEED * 16807) & 0x7FFFFFFF) / 2147483648);
		#end
	}
	
	/**
	   Converts an angle from degrees into radians.
	   flash/air		~400% faster than starling's MathUtil.deg2rad(deg)
	   hxcpp windows	?% faster than starling's MathUtil.deg2rad(deg) (hard to measure, time is 0 vs some time)
	   @param	deg
	   @return
	**/
	inline static public function deg2rad(deg:Float):Float
	{
		return deg * DEG2RAD;
	}
	
	/**
	   Converts an angle from radians into degrees.
	   flash/air		~500% faster than starling's MathUtil.rad2deg(rad)
	   hxcpp windows	?% faster than starling's MathUtil.rad2deg(rad) (hard to measure, time is 0 vs some time)
	   @param	rad
	   @return
	**/
	inline static public function rad2deg(rad:Float):Float
	{
		return rad * RAD2DEG;
	}
	
	/**
	   This is from Flixel's FlxMath class, but doesn't seem faster on any target ?
	   @param	rad
	   @return
	**/
	inline static public function fastCos(rad:Float):Float
	{
		return fastSin(rad + HALF_PI);
	}
	
	/**
	   This is from Flixel's FlxMath class, but doesn't seem faster on any target ?
	   @param	rad
	   @return
	**/
	inline static public function fastSin(rad:Float):Float
	{
		rad *= 0.3183098862; // divide by pi to normalize
		
		// bound between -1 and 1
		if (rad > 1)
		{
			rad -= (Math.ceil(rad) >> 1) << 1;
		}
		else if (rad < -1)
		{
			rad += (Math.ceil(-rad) >> 1) << 1;
		}
		
		// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
		if (rad > 0)
		{
			return rad * (3.1 + rad * (0.5 + rad * (-7.2 + rad * 3.6)));
		}
		else
		{
			return rad * (3.1 - rad * (0.5 + rad * (7.2 + rad * 3.6)));
		}
	}
	
	inline static public function fasterCos(rad:Float):Float
	{
		return fasterSin(rad + 1.57079632);
	}
	
	inline static public function fasterSin(rad:Float):Float
	{
		//always wrap input angle to -PI..PI
		if (rad < -3.14159265)
			rad += 6.28318531;
		else if (rad >  3.14159265)
			rad -= 6.28318531;
		
		//compute sine
		if (rad < 0)
			return 1.27323954 * rad + .405284735 * rad * rad;
		else
			return 1.27323954 * rad - 0.405284735 * rad * rad;
	}
	
}