package display;
import animation.Animator;
import data.Frame;
import data.ImageData;
import data.LookUp;
import data.MassiveConstants;
import openfl.Vector;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class MassiveImageLayer extends MassiveLayer 
{
	public var datas(get, set):Array<ImageData>;
	private var _datas:Array<ImageData>;
	private function get_datas():Array<ImageData> { return this._datas; }
	private function set_datas(value:Array<ImageData>):Array<ImageData>
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
	
	public function new(useDynamicData:Bool = false, datas:Array<ImageData> = null) 
	{
		this.useDynamicData = useDynamicData;
		if (this.useDynamicData)
		{
			this._datas = datas;
			if (this._datas != null) this._numDatas = this._datas.length;
		}
		else
		{
			this._datas = new Array<ImageData>();
		}
		this.animate = true;
		COS = LookUp.COS;
		SIN = LookUp.SIN;
	}
	
	override public function dispose():Void 
	{
		
	}
	
	public function addImage(data:ImageData):Void
	{
		_datas.push(data);
		_numDatas++;
	}
	
	public function addImageArray(datas:Array<ImageData>):Void
	{
		for (data in datas)
		{
			_datas.push(data);
			_numDatas++;
		}
	}
	
	override public function advanceTime(time:Float):Void 
	{
		Animator.animateImageDataList(_datas, time, this);
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
		
		var frame:Frame;
		
		var u1:Float;
		var u2:Float;
		var v1:Float;
		var v2:Float;
		
		if (this.useColor)
		{
			byteData.length += _numDatas * 128;
		}
		else
		{
			byteData.length += _numDatas * 64;
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
			
			frame = data.frameList[data.frameIndex];
			if (data.invertX)
			{
				u1 = frame.u2;
				u2 = frame.u1;
			}
			else
			{
				u1 = frame.u1;
				u2 = frame.u2;
			}
			
			if (data.invertY)
			{
				v1 = frame.v2;
				v2 = frame.v1;
			}
			else
			{
				v1 = frame.v1;
				v2 = frame.v2;
			}
			
			leftOffset = frame.leftWidth * data.scaleX;
			rightOffset = frame.rightWidth * data.scaleX;
			topOffset = frame.topHeight * data.scaleY;
			bottomOffset = frame.bottomHeight * data.scaleY;
			
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
				byteData.writeFloat(u1);
				byteData.writeFloat(v1);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + cosRight + sinTop);
				byteData.writeFloat(y + sinRight - cosTop);
				byteData.writeFloat(u2);
				byteData.writeFloat(v1);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x - cosLeft - sinBottom);
				byteData.writeFloat(y - sinLeft + cosBottom);
				byteData.writeFloat(u1);
				byteData.writeFloat(v2);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + cosRight - sinBottom);
				byteData.writeFloat(y + sinRight + cosBottom);
				byteData.writeFloat(u2);
				byteData.writeFloat(v2);
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
				byteData.writeFloat(u1);
				byteData.writeFloat(v1);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + rightOffset);
				byteData.writeFloat(y - topOffset);
				byteData.writeFloat(u2);
				byteData.writeFloat(v1);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x - leftOffset);
				byteData.writeFloat(y + bottomOffset);
				byteData.writeFloat(u1);
				byteData.writeFloat(v2);
				if (this.useColor)
				{
					byteData.writeFloat(red);
					byteData.writeFloat(green);
					byteData.writeFloat(blue);
					byteData.writeFloat(alpha);
				}
				
				byteData.writeFloat(x + rightOffset);
				byteData.writeFloat(y + bottomOffset);
				byteData.writeFloat(u2);
				byteData.writeFloat(v2);
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
		
		var frame:Frame;
		
		var u1:Float;
		var u2:Float;
		var v1:Float;
		var v2:Float;
		
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
			
			frame = data.frameList[data.frameIndex];
			if (data.invertX)
			{
				u1 = frame.u2;
				u2 = frame.u1;
			}
			else
			{
				u1 = frame.u1;
				u2 = frame.u2;
			}
			
			if (data.invertY)
			{
				v1 = frame.v2;
				v2 = frame.v1;
			}
			else
			{
				v1 = frame.v1;
				v2 = frame.v2;
			}
			
			leftOffset = frame.leftWidth * data.scaleX;
			rightOffset = frame.rightWidth * data.scaleX;
			topOffset = frame.topHeight * data.scaleY;
			bottomOffset = frame.bottomHeight * data.scaleY;
			
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
				vectorData[++position] = u1;
				vectorData[++position] = v1;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + cosRight + sinTop;
				vectorData[++position] = y + sinRight - cosTop;
				vectorData[++position] = u2;
				vectorData[++position] = v1;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x - cosLeft - sinBottom;
				vectorData[++position] = y - sinLeft + cosBottom;
				vectorData[++position] = u1;
				vectorData[++position] = v2;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + cosRight - sinBottom;
				vectorData[++position] = y + sinRight + cosBottom;
				vectorData[++position] = u2;
				vectorData[++position] = v2;
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
				vectorData[++position] = u1;
				vectorData[++position] = v1;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + rightOffset;
				vectorData[++position] = y - topOffset;
				vectorData[++position] = u2;
				vectorData[++position] = v1;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x - leftOffset;
				vectorData[++position] = y + bottomOffset;
				vectorData[++position] = u1;
				vectorData[++position] = v2;
				if (this.useColor)
				{
					vectorData[++position] = red;
					vectorData[++position] = green;
					vectorData[++position] = blue;
					vectorData[++position] = alpha;
				}
				
				vectorData[++position] = x + rightOffset;
				vectorData[++position] = y + bottomOffset;
				vectorData[++position] = u2;
				vectorData[++position] = v2;
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