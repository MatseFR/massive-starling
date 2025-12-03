package massive.display;
import massive.data.LookUp;
import massive.data.MassiveConstants;
import massive.data.QuadData;
import openfl.Vector;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class MassiveQuadLayer<T:QuadData = QuadData> extends MassiveLayer 
{
	
	public var datas(get, set):Array<T>;
	
	private var _datas:Array<T>;
	private function get_datas():Array<T> { return this._datas; }
	private function set_datas(value:Array<T>):Array<T>
	{
		return this._datas = value;
	}
	
	private function get_totalDatas():Int { return this._datas == null ? 0 : this._datas.length; }
	
	//#if flash
	//private var COS:Vector<Float>;
	//private var SIN:Vector<Float>;
	//#else
	private var COS:Array<Float>;
	private var SIN:Array<Float>;
	//#end
	
	public function new(datas:Array<T> = null) 
	{
		super();
		
		this._datas = datas;
		if (this._datas == null) this._datas = new Array<T>();
		this.animate = false;
		COS = LookUp.COS;
		SIN = LookUp.SIN;
	}
	
	public function dispose():Void
	{
		this._datas = null;
	}
	
	/**
	 * 
	 * @param	data
	 */
	public function addQuad(data:T):Void
	{
		this._datas[this._datas.length] = data;
	}
	
	/**
	 * 
	 * @param	datas
	 */
	public function addQuadArray(datas:Array<T>):Void
	{
		var count:Int = datas.length;
		for (i in 0...count)
		{
			this._datas[this._datas.length] = datas[i];
		}
	}
	
	/**
	 * 
	 * @param	data
	 */
	public function removeQuad(data:T):Void
	{
		var index:Int = this._datas.indexOf(data);
		if (index != -1)
		{
			this._datas.splice(index, 1);
		}
	}
	
	/**
	 * 
	 * @param	datas
	 */
	public function removeQuadArray(datas:Array<T>):Void
	{
		var index:Int;
		var count:Int = datas.length;
		for (i in 0...count)
		{
			index = this._datas.indexOf(datas[i]);
			if (index != -1)
			{
				this._datas.splice(index, 1);
			}
		}
	}
	
	public function removeAllData():Void 
	{
		this._datas.resize(0);
	}
	
	public function advanceTime(time:Float):Void 
	{
		// nothing
	}
	
	public function writeDataBytes(byteData:ByteArray, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int 
	{
		if (this._datas == null) return 0;
		
		var quadsWritten:Int = 0;
		
		var x:Float, y:Float;
		var leftOffset:Float, rightOffset:Float, topOffset:Float, bottomOffset:Float;
		var rotation:Float;
		
		var red:Float = 0;
		var green:Float = 0;
		var blue:Float = 0;
		var alpha:Float = 0;
		
		var angle:Int;
		var cos:Float;
		var sin:Float;
		
		var cosLeft:Float;
		var cosRight:Float;
		var cosTop:Float;
		var cosBottom:Float;
		var sinLeft:Float;
		var sinRight:Float;
		var sinTop:Float;
		var sinBottom:Float;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		if (this.useColor)
		{
			byteData.length += this.numDatas * 96;
		}
		else
		{
			//byteData.length += this.numDatas * 32;
			byteData.length += this.numDatas << 5;
		}
		
		var data:T;
		for (i in 0...this.numDatas)
		{
			data = this._datas[i];
			if (!data.visible) continue;
			
			++quadsWritten;
			
			x = data.x + data.offsetX + renderOffsetX;
			y = data.y + data.offsetY + renderOffsetY;
			rotation = data.rotation;
			
			if (this.useColor)
			{
				red = data.colorRed;
				green = data.colorGreen;
				blue = data.colorBlue;
				alpha = data.colorAlpha;
			}
			
			leftOffset = data.leftWidth * data.scaleX;
			rightOffset = data.rightWidth * data.scaleX;
			topOffset = data.topHeight * data.scaleY;
			bottomOffset = data.bottomHeight * data.scaleY;
			
			if (rotation != 0.0)
			{
				angle = Std.int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				cos = COS[angle];
				sin = SIN[angle];
				
				cosLeft = cos * leftOffset;
				cosRight = cos * rightOffset;
				cosTop = cos * topOffset;
				cosBottom = cos * bottomOffset;
				sinLeft = sin * leftOffset;
				sinRight = sin * rightOffset;
				sinTop = sin * topOffset;
				sinBottom = sin * bottomOffset;
				
				byteData.writeFloat(x - cosLeft + sinTop);
				byteData.writeFloat(y - sinLeft - cosTop);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + cosRight + sinTop);
				byteData.writeFloat(y + sinRight - cosTop);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x - cosLeft - sinBottom);
				byteData.writeFloat(y - sinLeft + cosBottom);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + cosRight - sinBottom);
				byteData.writeFloat(y + sinRight + cosBottom);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
			}
			else
			{
				byteData.writeFloat(x - leftOffset);
				byteData.writeFloat(y - topOffset);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + rightOffset);
				byteData.writeFloat(y - topOffset);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x - leftOffset);
				byteData.writeFloat(y + bottomOffset);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + rightOffset);
				byteData.writeFloat(y + bottomOffset);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
			}
		}
		
		return quadsWritten;
	}
	
	public function writeDataVector(vectorData:Vector<Float>, offset:Int, renderOffsetX:Float, renderOffsetY:Float):Int 
	{
		if (this._datas == null) return 0;
		
		var vertexID:Int = offset << 2;
		var position:Int;
		
		if (this.useColor)
		{
			position = vertexID << 3;
		}
		else
		{
			position = vertexID << 2;
		}
		
		var quadsWritten:Int = 0;
		
		var x:Float, y:Float;
		var leftOffset:Float, rightOffset:Float, topOffset:Float, bottomOffset:Float;
		var rotation:Float;
		
		var red:Float = 0;
		var green:Float = 0;
		var blue:Float = 0;
		var alpha:Float = 0;
		
		var angle:Int;
		var cos:Float;
		var sin:Float;
		
		var cosLeft:Float;
		var cosRight:Float;
		var cosTop:Float;
		var cosBottom:Float;
		var sinLeft:Float;
		var sinRight:Float;
		var sinTop:Float;
		var sinBottom:Float;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		var data:T;
		for (i in 0...this.numDatas)
		{
			data = this._datas[i];
			if (!data.visible) continue;
			
			++quadsWritten;
			
			x = data.x + data.offsetX + renderOffsetX;
			y = data.y + data.offsetY + renderOffsetY;
			rotation = data.rotation;
			
			if (this.useColor)
			{
				red = data.colorRed;
				green = data.colorGreen;
				blue = data.colorBlue;
				alpha = data.colorAlpha;
			}
			
			leftOffset = data.leftWidth * data.scaleX;
			rightOffset = data.rightWidth * data.scaleX;
			topOffset = data.topHeight * data.scaleY;
			bottomOffset = data.bottomHeight * data.scaleY;
			
			if (rotation != 0)
			{
				angle = Std.int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				cos = COS[angle];
				sin = SIN[angle];
				
				cosLeft = cos * leftOffset;
				cosRight = cos * rightOffset;
				cosTop = cos * topOffset;
				cosBottom = cos * bottomOffset;
				sinLeft = sin * leftOffset;
				sinRight = sin * rightOffset;
				sinTop = sin * topOffset;
				sinBottom = sin * bottomOffset;
				
				vectorData[position]   = x - cosLeft + sinTop;
				vectorData[++position] = y - sinLeft - cosTop;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + cosRight + sinTop;
				vectorData[++position] = y + sinRight - cosTop;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x - cosLeft - sinBottom;
				vectorData[++position] = y - sinLeft + cosBottom;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + cosRight - sinBottom;
				vectorData[++position] = y + sinRight + cosBottom;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
			}
			else
			{
				vectorData[position]   = x - leftOffset;
				vectorData[++position] = y - topOffset;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + rightOffset;
				vectorData[++position] = y - topOffset;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x - leftOffset;
				vectorData[++position] = y + bottomOffset;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + rightOffset;
				vectorData[++position] = y + bottomOffset;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
			}
			++position;
		}
		
		return quadsWritten;
	}
	
}