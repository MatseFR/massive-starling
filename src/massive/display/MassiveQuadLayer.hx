package display;
import data.LookUp;
import data.MassiveConstants;
import data.QuadData;
import openfl.Vector;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class MassiveQuadLayer extends MassiveLayer 
{
	public var datas(get, set):Array<QuadData>;
	private var _datas:Array<QuadData>;
	private function get_datas():Array<QuadData> { return this._datas; }
	private function set_datas(value:Array<QuadData>):Array<QuadData>
	{
		if (value == this._datas) return value;
		this.useDynamicData = true;
		this._numDatas = value != null ? value.length : 0;
		return this._datas = value;
	}
	
	public var numDatas(get, never):Int;
	private var _numDatas:Int = 0;
	private function get_numDatas():Int { return this._numDatas; }
	
	private var COS:Array<Float>;
	private var SIN:Array<Float>;
	
	public function new(useDynamicData:Bool = false, datas:Array<QuadData> = null) 
	{
		this.useDynamicData = useDynamicData;
		if (this.useDynamicData)
		{
			this._datas = datas;
			if (this._datas != null) this._numDatas = this._datas.length;
		}
		else
		{
			this._datas = new Array<QuadData>();
		}
		this.animate = false;
		COS = LookUp.COS;
		SIN = LookUp.SIN;
	}
	
	/**
	 * 
	 * @param	data
	 */
	public function addQuad(data:QuadData):Void
	{
		_datas.push(data);
		_numDatas++;
	}
	
	/**
	 * 
	 * @param	datas
	 */
	public function addQuadArray(datas:Array<QuadData>):Void
	{
		for (data in datas)
		{
			_datas.push(data);
			_numDatas++;
		}
	}
	
	override public function writeDataBytes(byteData:ByteArray, offset:Int):Int 
	{
		if (this._datas == null) return 0;
		
		if (this.useDynamicData)
		{
			this._numDatas = this._datas.length;
		}
		
		var quadsWritten:Int = -1;
		
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
		
		if (this.useColor)
		{
			byteData.length += _numDatas * 96;
		}
		else
		{
			byteData.length += _numDatas * 32;
		}
		
		for (data in _datas)
		{
			if (!data.visible) continue;
			
			quadsWritten++;
			
			x = data.x;
			y = data.y;
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
		
		return ++quadsWritten;
	}
	
	override public function writeDataVector(vectorData:Vector<Float>, offset:Int):Int 
	{
		if (this._datas == null) return 0;
		
		var vertexID:Int;
		var position:Int;
		var quadsWritten:Int = -1;
		
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
		
		for (data in _datas)
		{
			if (!data.visible) continue;
			
			vertexID = (offset + ++quadsWritten) << 2;
			
			x = data.x;
			y = data.y;
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
			
			position = vertexID << 3;
			
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
		}
		
		return ++quadsWritten;
	}
	
}