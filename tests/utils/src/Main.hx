package;

import haxe.Timer;
import massive.data.MassiveConstants;
import massive.util.LookUp;
import massive.util.MathUtils;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import starling.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class Main extends Sprite 
{
	private var _tf:TextField;
	private var _format:TextFormat;
	private var _m = Math;

	public function new() 
	{
		super();
		
		this._tf = new TextField();
		this._tf.width = this.stage.stageWidth;
		this._tf.height = this.stage.stageHeight;
		addChild(this._tf);
		
		this._format = new TextFormat();
		
		LookUp.init();
		
		cos();
		sin();
		cos_and_sin();
		fastCos();
		fastSin();
		abs();
		absInt();
		atan2();
		ceil();
		floor();
		#if !flash // flash Math.isNaN is *extremely* slow
		isNaN();
		#end
		max();
		min();
		random();
		deg2rad();
		rad2deg();
	}
	
	private function log(str:String):Void
	{
		this._tf.appendText(str + "\n");
	}

	private function logResults(test1:String, time1:Float, test2:String, time2:Float):Void
	{
		var percent:Float;
		var percentStr:String;
		var index:Int;
		var str:String;
		if (time1 > time2)
		{
			percent = time1 / time2 * 100 - 100;
			percentStr = Std.string(percent);
			index = percentStr.indexOf(".");
			if (index != -1)
			{
				percentStr = percentStr.substring(0, index + 3);
			}
			str = test1 + " slower than " + test2 + " by " + percentStr + "% (" + time1 + " vs " + time2 + ")";
			this._format.color = 0x880000;
		}
		else if (time2 > time1)
		{
			percent = time2 / time1 * 100 - 100;
			percentStr = Std.string(percent);
			index = percentStr.indexOf(".");
			if (index != -1)
			{
				percentStr = percentStr.substring(0, index + 3);
			}
			str = test1 + " faster than " + test2 + " by " + percentStr + "% (" + time1 + " vs " + time2 + ")";
			this._format.color = 0x006600;
		}
		else
		{
			str = test1 + " equals " + test2 + " (" + time1 + " vs " + time2 + ")";
			this._format.color = 0x000000;
		}
		//this._tf.defaultTextFormat = this._format;
		var index:Int = this._tf.length;
		log(str);
		this._tf.setTextFormat(this._format, index, this._tf.length);
	}
	
	private function timeStamp():Float
	{
		#if sys
		return Sys.time();
		#else
		return Timer.stamp();
		#end
	}
	
	private function cos():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		#if cpp
		var iterations:Int = MathUtils.INT_MAX;
		#else
		var iterations:Int = 100000000;
		#end
		var result:Float;
		var angle:Float = 1.57;
		//var m:Class<Math> = Math;
		var m = Math;
		
		//trace(Type.typeof(m));
		//trace(Type.getClass(m));
		//trace(Type.getClassName(Type.getClass(m)));
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = Math.cos(Math.random() * MathUtils.PI2);
			result = Math.cos(angle);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = m.cos(Math.random() * MathUtils.PI2);
			result = m.cos(angle);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("(cached Math).cos", time2, "Math.cos", time1);
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = LookUp.cos(Math.random() * MathUtils.PI2);
			result = LookUp.cos(angle);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("LookUp.cos", time2, "Math.cos", time1);
		
		var cache:Array<Float> = LookUp.COS;
		
		//t1 = timeStamp();
		//for (i in 0...iterations)
		//{
			//result = cache[LookUp.getAngle(Math.random() * MathUtils.PI2)];
		//}
		//t2 = timeStamp();
		//time2 = t2 - t1;
		//
		//logResults("cached LookUp.COS", time2, "Math.cos", time1);
		//
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = cache[Std.int(Math.random() * MathUtils.PI2 * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
			result = cache[Std.int(angle * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2];
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("cached LookUp.COS + inlined angle", time2, "Math.cos", time1);
	}
	
	private function sin():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 10000000;
		var result:Float;
		var m = Math;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = Math.sin(Math.random() * MathUtils.PI2);
			result = Math.sin(1.57);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = m.sin(Math.random() * MathUtils.PI2);
			result = m.sin(1.57);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("(cached Math).sin", time2, "Math.sin", time1);
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = LookUp.sin(Math.random() * MathUtils.PI2);
			result = LookUp.sin(1.57);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("LookUp.sin", time2, "Math.sin", time1);
	}
	
	private function cos_and_sin():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 10000000;
		var angle:Float = 1.57;
		var intAngle:Int;
		var result1:Float;
		var result2:Float;
		var COS:Array<Float> = LookUp.COS;
		var SIN:Array<Float> = LookUp.SIN;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result1 = Math.cos(angle);
			result2 = Math.sin(angle);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			intAngle = LookUp.getAngle(angle);
			result1 = COS[intAngle];
			result2 = SIN[intAngle];
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("LookUp cos and sin", time2, "Math cos and sin", time1);
	}
	
	private function fastCos():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 10000000;
		var result:Float;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = Math.cos(Math.random() * MathUtils.PI2);
			result = Math.cos(1.57);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = MathUtils.fastCos(Math.random() * MathUtils.PI2);
			result = MathUtils.fastCos(1.57);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.fastCos", time2, "Math.cos", time1);
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = MathUtils.fasterCos(Math.random() * MathUtils.PI2);
			result = MathUtils.fasterCos(1.57);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.fasterCos", time2, "Math.cos", time1);
	}
	
	private function fastSin():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 10000000;
		var result:Float;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = Math.sin(Math.random() * MathUtils.PI2);
			result = Math.sin(1.57);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = MathUtils.fastSin(Math.random() * MathUtils.PI2);
			result = MathUtils.fastSin(1.57);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.fastSin", time2, "Math.sin", time1);
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			//result = MathUtils.fasterSin(Math.random() * MathUtils.PI2);
			result = MathUtils.fasterSin(1.57);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.fasterSin", time2, "Math.sin", time1);
	}
	
	private function abs():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Float;
		var value:Float = -42;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.abs(value);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.abs(value);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.abs", time2, "Math.abs", time1);
	}
	
	private function absInt():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Int;
		var value:Int = -42;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Std.int(Math.abs(value));
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.absInt(value);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.absInt", time2, "Std.int + Math.abs", time1);
	}
	
	private function atan2():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var x:Float;
		var y:Float;
		var result:Float;
		
		x = -iterations / 2;
		y = iterations / 2;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.atan2(y, x);
			++x;
			--y;
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		x = -iterations / 2;
		y = iterations / 2;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.atan2(y, x);
			++x;
			--y;
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.atan2", time2, "Math.atan2", time1);
	}
	
	private function ceil():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Int;
		var value:Float = 3.1415927;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.ceil(value);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.ceil(value);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.ceil", time2, "Math.ceil", time1);
	}
	
	//private function fceil():Void
	//{
		//var t1:Float;
		//var t2:Float;
		//var time1:Float;
		//var time2:Float;
		//var iterations:Int = 100000000;
		//var result:Float;
		//var value:Float = 3.1415927;
		//
		//t1 = timeStamp();
		//for (i in 0...iterations)
		//{
			//result = Math.fceil(value);
		//}
		//t2 = timeStamp();
		//time1 = t2 - t1;
		//
		//t1 = timeStamp();
		//for (i in 0...iterations)
		//{
			//result = MathUtils.fceil(value);
		//}
		//t2 = timeStamp();
		//time2 = t2 - t1;
		//
		//logResults("MathUtils.fceil", time2, "Math.fceil", time1);
	//}
	
	private function floor():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Int;
		var value:Float = 3.1415927;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.floor(value);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.floor(value);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.floor", time2, "Math.floor", time1);
	}
	
	//private function ffloor():Void
	//{
		//var t1:Float;
		//var t2:Float;
		//var time1:Float;
		//var time2:Float;
		//var iterations:Int = 100000000;
		//var result:Float;
		//var value:Float = 3.1415927;
		//
		//t1 = timeStamp();
		//for (i in 0...iterations)
		//{
			//result = Math.ffloor(value);
		//}
		//t2 = timeStamp();
		//time1 = t2 - t1;
		//
		//t1 = timeStamp();
		//for (i in 0...iterations)
		//{
			//result = MathUtils.ffloor(value);
		//}
		//t2 = timeStamp();
		//time2 = t2 - t1;
		//
		//logResults("MathUtils.ffloor", time2, "Math.ffloor", time1);
	//}
	
	private function isNaN():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Bool;
		var value:Float = Math.NaN;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.isNaN(value);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.isNaN(value);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.isNaN", time2, "Math.isNaN", time1);
	}
	
	private function max():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Float;
		var num1:Float = 123.456;
		var num2:Float = 123.789;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.max(num1, num2);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.max(num1, num2);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.max", time2, "Math.max", time1);
	}
	
	private function min():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Float;
		var num1:Float = 123.456;
		var num2:Float = 123.789;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.min(num1, num2);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.min(num1, num2);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.min", time2, "Math.min", time1);
	}
	
	private function random():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Float;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = Math.random();
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.random();
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.random", time2, "Math.random", time1);
	}
	
	private function deg2rad():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Float;
		var value:Float = 157.0;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtil.deg2rad(value);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.deg2rad(value);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.deg2rad", time2, "MathUtil.deg2rad (starling)", time1);
	}
	
	private function rad2deg():Void
	{
		var t1:Float;
		var t2:Float;
		var time1:Float;
		var time2:Float;
		var iterations:Int = 100000000;
		var result:Float;
		var value:Float = 0.157;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtil.rad2deg(value);
		}
		t2 = timeStamp();
		time1 = t2 - t1;
		
		t1 = timeStamp();
		for (i in 0...iterations)
		{
			result = MathUtils.rad2deg(value);
		}
		t2 = timeStamp();
		time2 = t2 - t1;
		
		logResults("MathUtils.rad2deg", time2, "MathUtil.rad2deg (starling)", time1);
	}

}
