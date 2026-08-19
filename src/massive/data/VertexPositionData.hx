package massive.data;
import massive.display.Img;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class VertexPositionData 
{
	static private var _POOL:Array<VertexPositionData> = new Array<VertexPositionData>();
	
	#if flash
	static public function cloneSequence(sequence:Vector<VertexPositionData>, cloneSequence:Vector<VertexPositionData> = null):Vector<VertexPositionData>
	#else
	static public function cloneSequence(sequence:Array<VertexPositionData>, cloneSequence:Array<VertexPositionData> = null):Array<VertexPositionData>
	#end
	{
		#if flash
		if (cloneSequence == null) cloneSequence = new Vector<VertexPositionData>();
		#else
		if (cloneSequence == null) cloneSequence = new Array<VertexPositionData>();
		#end
		
		var position:VertexPositionData;
		var clonePosition:VertexPositionData;
		var count:Int = sequence.length;
		for (i in 0...count)
		{
			position = sequence[i];
			clonePosition = fromPool(0.0, 0.0, true, true, false);
			position.clone(clonePosition);
			cloneSequence[cloneSequence.length] = clonePosition;
		}
		
		return cloneSequence;
	}
	
	static public function fromPool(pivotX:Float = 0.0, pivotY:Float = 0.0,
									canInvertX:Bool = true, canInvertY:Bool = true,
									processInvertedValues:Bool = true,
									x1:Float = 0.0, x2:Float = 0.0, x3:Float = 0.0, x4:Float = 0.0,
									y1:Float = 0.0, y2:Float = 0.0, y3:Float = 0.0, y4:Float = 0.0):VertexPositionData
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(pivotX, pivotY,
															  canInvertX, canInvertY,
															  processInvertedValues,
															  x1, x2, x3, x4, y1, y2, y3, y4);
		return new VertexPositionData(pivotX, pivotY,
									  canInvertX, canInvertY,
									  processInvertedValues,
									  x1, x2, x3, x4, y1, y2, y3, y4);
	}
	
	@:access(massive.display.Img)
	static public function fromImg(img:Img, canInvertX:Bool = true, canInvertY:Bool = true, processInvertedValues:Bool = true):VertexPositionData
	{
		return fromPool(img._x1 + img.frame.pivotX, img._y1 + img.frame.pivotY,
						canInvertX, canInvertY,
						processInvertedValues,
						img._x1, img._x2, img._x3, img._x4,
						img._y1, img._y2, img._y3, img._y4);
	}
	
	#if flash
	static public function poolSequence(sequence:Vector<VertexPositionData>):Void
	#else
	static public function poolSequence(sequence:Array<VertexPositionData>):Void
	#end
	{
		var count:Int = sequence.length;
		for (i in 0...count)
		{
			sequence[i].pool();
		}
	}
	
	public var canInvertX:Bool;
	public var canInvertY:Bool;
	
	/**
	   When this is set to true, all objects it is assigned to will recalculate their vertex position values every frame
	   @default	false
	**/
	public var isChanging:Bool;
	public var isInPool(default, null):Bool;
	
	public var pivotX:Float;
	public var pivotY:Float;
	
	public var x1:Float;
	public var x2:Float;
	public var x3:Float;
	public var x4:Float;
	public var y1:Float;
	public var y2:Float;
	public var y3:Float;
	public var y4:Float;
	
	public var x1_invertX:Float;
	public var x2_invertX:Float;
	public var x3_invertX:Float;
	public var x4_invertX:Float;
	public var y1_invertX:Float;
	public var y2_invertX:Float;
	public var y3_invertX:Float;
	public var y4_invertX:Float;
	
	public var x1_invertY:Float;
	public var x2_invertY:Float;
	public var x3_invertY:Float;
	public var x4_invertY:Float;
	public var y1_invertY:Float;
	public var y2_invertY:Float;
	public var y3_invertY:Float;
	public var y4_invertY:Float;
	
	public var x1_invertXY:Float;
	public var x2_invertXY:Float;
	public var x3_invertXY:Float;
	public var x4_invertXY:Float;
	public var y1_invertXY:Float;
	public var y2_invertXY:Float;
	public var y3_invertXY:Float;
	public var y4_invertXY:Float;

	public function new(pivotX:Float = 0.0, pivotY:Float = 0.0,
						canInvertX:Bool = true, canInvertY:Bool = true, 
						processInvertedValues:Bool = true,
						x1:Float = 0.0, x2:Float = 0.0, x3:Float = 0.0, x4:Float = 0.0,
						y1:Float = 0.0, y2:Float = 0.0, y3:Float = 0.0, y4:Float = 0.0) 
	{
		this.pivotX = pivotX;
		this.pivotY = pivotY;
		this.canInvertX = canInvertX;
		this.canInvertY = canInvertY;
		this.x1 = x1;
		this.x2 = x2;
		this.x3 = x3;
		this.x4 = x4;
		this.y1 = y1;
		this.y2 = y2;
		this.y3 = y3;
		this.y4 = y4;
		
		if (processInvertedValues) processInversions();
	}
	
	public function clear():Void
	{
		this.isChanging = false;
		this.pivotX = this.pivotY = this.x1 = this.x2 = this.x3 = this.x4 = this.y1 = this.y2 = this.y3 = this.y4 = 0.0;
	}
	
	public function pool():Void
	{
		if (this.isInPool) return;
		// no need to call clear()
		_POOL[_POOL.length] = this;
		this.isInPool = true;
	}
	
	private function setFromPool(pivotX:Float, pivotY:Float, canInvertX:Bool, canInvertY:Bool, processInvertedValues:Bool,
								 x1:Float, x2:Float, x3:Float, x4:Float, y1:Float, y2:Float, y3:Float, y4:Float):VertexPositionData
	{
		this.pivotX = pivotX;
		this.pivotY = pivotY;
		this.canInvertX = canInvertX;
		this.canInvertY = canInvertY;
		this.x1 = x1;
		this.x2 = x2;
		this.x3 = x3;
		this.x4 = x4;
		this.y1 = y1;
		this.y2 = y2;
		this.y3 = y3;
		this.y4 = y4;
		if (processInvertedValues) processInversions();
		this.isInPool = false;
		return this;
	}
	
	public function clone(toVertexPosition:VertexPositionData = null):VertexPositionData
	{
		if (toVertexPosition == null) 
		{
			toVertexPosition = VertexPositionData.fromPool(this.pivotX, this.pivotY,
														   this.canInvertX, this.canInvertY, 
														   false,
														   this.x1, this.x2, this.x3, this.x4,
														   this.y1, this.y2, this.y3, this.y4);
		}
		else
		{
			toVertexPosition.pivotX = this.pivotX;
			toVertexPosition.pivotY = this.pivotY;
			
			toVertexPosition.canInvertX = this.canInvertX;
			toVertexPosition.canInvertY = this.canInvertY;
			
			toVertexPosition.x1 = this.x1;
			toVertexPosition.x2 = this.x2;
			toVertexPosition.x3 = this.x3;
			toVertexPosition.x4 = this.x4;
			
			toVertexPosition.y1 = this.y1;
			toVertexPosition.y2 = this.y2;
			toVertexPosition.y3 = this.y3;
			toVertexPosition.y4 = this.y4;
		}
		
		toVertexPosition.x1_invertX = this.x1_invertX;
		toVertexPosition.x2_invertX = this.x2_invertX;
		toVertexPosition.x3_invertX = this.x3_invertX;
		toVertexPosition.x4_invertX = this.x4_invertX;
		
		toVertexPosition.y1_invertX = this.y1_invertX;
		toVertexPosition.y2_invertX = this.y2_invertX;
		toVertexPosition.y3_invertX = this.y3_invertX;
		toVertexPosition.y4_invertX = this.y4_invertX;
		
		toVertexPosition.x1_invertY = this.x1_invertY;
		toVertexPosition.x2_invertY = this.x2_invertY;
		toVertexPosition.x3_invertY = this.x3_invertY;
		toVertexPosition.x4_invertY = this.x4_invertY;
		
		toVertexPosition.y1_invertY = this.y1_invertY;
		toVertexPosition.y2_invertY = this.y2_invertY;
		toVertexPosition.y3_invertY = this.y3_invertY;
		toVertexPosition.y4_invertY = this.y4_invertY;
		
		toVertexPosition.x1_invertXY = this.x1_invertXY;
		toVertexPosition.x2_invertXY = this.x2_invertXY;
		toVertexPosition.x3_invertXY = this.x3_invertXY;
		toVertexPosition.x4_invertXY = this.x4_invertXY;
		
		toVertexPosition.y1_invertXY = this.y1_invertXY;
		toVertexPosition.y2_invertXY = this.y2_invertXY;
		toVertexPosition.y3_invertXY = this.y3_invertXY;
		toVertexPosition.y4_invertXY = this.y4_invertXY;
		
		return toVertexPosition;
	}
	
	public function processInversions():Void
	{
		if (this.canInvertX)
		{
			this.x1_invertX = this.pivotX - (this.x2 - this.pivotX);
			this.x2_invertX = this.pivotX + (this.pivotX - this.x1);
			this.x3_invertX = this.pivotX - (this.x4 - this.pivotX);
			this.x4_invertX = this.pivotX + (this.pivotX - this.x3);
			
			this.y1_invertX = this.y2;
			this.y2_invertX = this.y1;
			this.y3_invertX = this.y4;
			this.y4_invertX = this.y3;
		}
		else
		{
			this.x1_invertX = this.x1;
			this.x2_invertX = this.x2;
			this.x3_invertX = this.x3;
			this.x4_invertX = this.x4;
			
			this.y1_invertX = this.y1;
			this.y2_invertX = this.y2;
			this.y3_invertX = this.y3;
			this.y4_invertX = this.y4;
		}
		
		if (this.canInvertY)
		{
			this.x1_invertY = this.x3;
			this.x2_invertY = this.x4;
			this.x3_invertY = this.x1;
			this.x4_invertY = this.x2;
			
			this.y1_invertY = this.pivotY - (this.y3 - this.pivotY);
			this.y2_invertY = this.pivotY - (this.y4 - this.pivotY);
			this.y3_invertY = this.pivotY + (this.pivotY - this.y1);
			this.y4_invertY = this.pivotY + (this.pivotY - this.y2);
		}
		else
		{
			this.x1_invertY = this.x1;
			this.x2_invertY = this.x2;
			this.x3_invertY = this.x3;
			this.x4_invertY = this.x4;
			
			this.y1_invertY = this.y1;
			this.y2_invertY = this.y2;
			this.y3_invertY = this.y3;
			this.y4_invertY = this.y4;
		}
		
		if (this.canInvertX && this.canInvertY)
		{
			this.x1_invertXY = this.pivotX - (this.x4 - this.pivotX);
			this.x2_invertXY = this.pivotX + (this.pivotX - this.x3);
			this.x3_invertXY = this.pivotX - (this.x2 - this.pivotX);
			this.x4_invertXY = this.pivotX + (this.pivotX - this.x1);
			
			this.y1_invertXY = this.pivotY - (this.y4 - this.pivotY);
			this.y2_invertXY = this.pivotY - (this.y3 - this.pivotY);
			this.y3_invertXY = this.pivotY + (this.pivotY - this.y2);
			this.y4_invertXY = this.pivotY + (this.pivotY - this.y1);
		}
		else
		{
			this.x1_invertXY = this.x1;
			this.x2_invertXY = this.x2;
			this.x3_invertXY = this.x3;
			this.x4_invertXY = this.x4;
			
			this.y1_invertXY = this.y1;
			this.y2_invertXY = this.y2;
			this.y3_invertXY = this.y3;
			this.y4_invertXY = this.y4;
		}
	}
	
}