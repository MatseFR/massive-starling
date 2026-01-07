package massive.display;
import massive.animation.Animator;
import massive.data.Frame;
import massive.data.ImageData;
import openfl.Memory;
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end

/**
 * A Massive layer that displays ImageData
 * @author Matse
 */
@:generic
class ImageLayer<T:ImageData = ImageData> extends MassiveLayer 
{
	#if flash
	/**
	   The Vector containing ImageData instances to draw
	**/
	public var datas(get, set):Vector<T>;
	#else
	/**
	   The Array containing ImageData instances to draw
	**/
	public var datas(get, set):Array<T>;
	#end
	/**
	   Tells whether this layer should animate textures or not.
	   If you are displaying non-animated images, consider setting this to false for better performance
	   @default true
	**/
	public var textureAnimation:Bool = true;
	
	#if flash
	private var _datas:Vector<T>;
	private function get_datas():Vector<T> { return this._datas; }
	private function set_datas(value:Vector<T>):Vector<T>
	{
		return this._datas = value;
	}
	#else
	private var _datas:Array<T>;
	private function get_datas():Array<T> { return this._datas; }
	private function set_datas(value:Array<T>):Array<T>
	{
		return this._datas = value;
	}
	#end
	
	private function get_totalDatas():Int { return this._datas == null ? 0 : this._datas.length; }
	
	//#if flash
	//private var COS:Vector<Float>;
	//private var SIN:Vector<Float>;
	//#else
	//private var COS:Array<Float>;
	//private var SIN:Array<Float>;
	//#end
	
	public function new(datas:#if flash Vector<T> #else Array<T>#end = null) 
	{
		super();
		
		this._datas = datas;
		#if flash
		if (this._datas == null) this._datas = new Vector<T>();
		#else
		if (this._datas == null) this._datas = new Array<T>();
		#end
		this.animate = true;
		//COS = LookUp.COS;
		//SIN = LookUp.SIN;
	}
	
	/**
	   @inheritDoc
	**/
	public function dispose():Void 
	{
		this._datas = null;
	}
	
	/**
	 * Adds the specified ImageData to this layer
	 * @param	data
	 */
	public function addImage(data:T):Void
	{
		this._datas[this._datas.length] = data;
	}
	
	/**
	 * Adds the specified ImageData Array to this layer
	 * @param	datas
	 */
	public function addImageArray(datas:Array<T>):Void
	{
		var count:Int = datas.length;
		for (i in 0...count)
		{
			this._datas[this._datas.length] = datas[i];
		}
	}
	
	/**
	 * Removes the specified ImageData from this layer
	 * @param	data
	 */
	public function removeImage(data:T):Void
	{
		var index:Int = this._datas.indexOf(data);
		if (index != -1)
		{
			removeImageAt(index);
		}
	}
	
	/**
	   Removes ImageData at specified index
	   @param	index
	**/
	public function removeImageAt(index:Int):Void
	{
		#if flash
		this._datas.removeAt(index);
		#else
		this._datas.splice(index, 1);
		#end
	}
	
	/**
	 * Removes the specified ImageData Array from this layer
	 * @param	datas
	 */
	public function removeImageArray(datas:Array<T>):Void
	{
		var index:Int;
		var count:Int = datas.length;
		for (i in 0...count)
		{
			index = this._datas.indexOf(datas[i]);
			if (index != -1)
			{
				removeImageAt(index);
			}
		}
	}
	
	/**
	   @inheritDoc
	**/
	public function removeAllData():Void 
	{
		#if flash
		this._datas.length = 0;
		#else
		this._datas.resize(0);
		#end
	}
	
	/**
	   @inheritDoc
	**/
	public function advanceTime(time:Float):Void 
	{
		if (this.textureAnimation) Animator.animateImageDataList(this._datas, time);
	}
	
	/**
	   @inheritDoc
	**/
	public function writeDataBytes(byteData:ByteArray, offset:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool):Int
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
		
		//var angle:Int;
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
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		if (useColor)
		{
			//byteData.length += numDatas * 128;
			byteData.length += this.numDatas << 7;
		}
		else
		{
			//byteData.length += numDatas * 64;
			byteData.length += this.numDatas << 6;
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
			
			if (useColor)
			{
				if (pma)
				{
					alpha = data.colorAlpha;
					red = data.colorRed * alpha;
					green = data.colorGreen * alpha;
					blue = data.colorBlue * alpha;
				}
				else
				{
					red = data.colorRed;
					green = data.colorGreen;
					blue = data.colorBlue;
					alpha = data.colorAlpha;
				}
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
			
			if (rotation != 0.0)
			{
				//angle = Std.int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				//cos = COS[angle];
				//sin = SIN[angle];
				cos = Math.cos(rotation);
				sin = Math.sin(rotation);
				
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
	
	#if flash
	/**
	   @inheritDoc
	**/
	public function writeDataBytesMemory(byteData:ByteArray, offset:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool):Int
	{
		if (this._datas == null) return 0;
		
		var position:Int;
		
		if (useColor)
		{
			position = offset * 96;
		}
		else
		{
			position = offset << 5;
		}
		
		var quadsWritten:Int = 0;
		
		var x:Float, y:Float;
		var leftOffset:Float, rightOffset:Float, topOffset:Float, bottomOffset:Float;
		var rotation:Float;
		
		var red:Float = 0;
		var green:Float = 0;
		var blue:Float = 0;
		var alpha:Float = 0;
		
		//var angle:Int;
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
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		if (useColor)
		{
			//byteData.length += numDatas * 128;
			byteData.length += this.numDatas << 7;
		}
		else
		{
			//byteData.length += numDatas * 64;
			byteData.length += this.numDatas << 6;
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
			
			if (useColor)
			{
				if (pma)
				{
					alpha = data.colorAlpha;
					red = data.colorRed * alpha;
					green = data.colorGreen * alpha;
					blue = data.colorBlue * alpha;
				}
				else
				{
					red = data.colorRed;
					green = data.colorGreen;
					blue = data.colorBlue;
					alpha = data.colorAlpha;
				}
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
			
			if (rotation != 0.0)
			{
				//angle = Std.int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				//cos = COS[angle];
				//sin = SIN[angle];
				cos = Math.cos(rotation);
				sin = Math.sin(rotation);
				
				cosLeft = cos * leftOffset;
				cosRight = cos * rightOffset;
				cosTop = cos * topOffset;
				cosBottom = cos * bottomOffset;
				sinLeft = sin * leftOffset;
				sinRight = sin * rightOffset;
				sinTop = sin * topOffset;
				sinBottom = sin * bottomOffset;
				
				Memory.setFloat(position, x - cosLeft + sinTop);
				Memory.setFloat(position += 4, y - sinLeft - cosTop);
				Memory.setFloat(position += 4, u1);
				Memory.setFloat(position += 4, v1);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
				
				Memory.setFloat(position += 4, x + cosRight + sinTop);
				Memory.setFloat(position += 4, y + sinRight - cosTop);
				Memory.setFloat(position += 4, u2);
				Memory.setFloat(position += 4, v1);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
				
				Memory.setFloat(position += 4, x - cosLeft - sinBottom);
				Memory.setFloat(position += 4, y - sinLeft + cosBottom);
				Memory.setFloat(position += 4, u1);
				Memory.setFloat(position += 4, v2);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
				
				Memory.setFloat(position += 4, x + cosRight - sinBottom);
				Memory.setFloat(position += 4, y + sinRight + cosBottom);
				Memory.setFloat(position += 4, u2);
				Memory.setFloat(position += 4, v2);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
			}
			else
			{
				Memory.setFloat(position, x - leftOffset);
				Memory.setFloat(position += 4, y - topOffset);
				Memory.setFloat(position += 4, u1);
				Memory.setFloat(position += 4, v1);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
				
				Memory.setFloat(position += 4, x + rightOffset);
				Memory.setFloat(position += 4, y - topOffset);
				Memory.setFloat(position += 4, u2);
				Memory.setFloat(position += 4, v1);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
				
				Memory.setFloat(position += 4, x - leftOffset);
				Memory.setFloat(position += 4, y + bottomOffset);
				Memory.setFloat(position += 4, u1);
				Memory.setFloat(position += 4, v2);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
				
				Memory.setFloat(position += 4, x + rightOffset);
				Memory.setFloat(position += 4, y + bottomOffset);
				Memory.setFloat(position += 4, u2);
				Memory.setFloat(position += 4, v2);
				if (useColor)
				{
					Memory.setFloat(position += 4, red);
					Memory.setFloat(position += 4, green);
					Memory.setFloat(position += 4, blue);
					Memory.setFloat(position += 4, alpha);
				}
			}
			position += 4;
		}
		
		return quadsWritten;
	}
	#end
	
	#if !flash
	/**
	   @inheritDoc
	**/
	public function writeDataFloat32Array(floatData:Float32Array, offset:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool):Int
	{
		if (this._datas == null) return 0;
		
		var vertexID:Int = offset << 2;
		var position:Int;
		
		if (useColor)
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
		
		//var angle:Int;
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
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		var data:T;
		for (i in 0...this.numDatas)
		{
			data = this._datas[i];
			if (!data.visible) continue;
			
			++quadsWritten;
			
			x = data.x + data.offsetX + renderOffsetX;
			y = data.y + data.offsetY + renderOffsetY;
			rotation = data.rotation;
			
			if (useColor)
			{
				if (pma)
				{
					alpha = data.colorAlpha;
					red = data.colorRed * alpha;
					green = data.colorGreen * alpha;
					blue = data.colorBlue * alpha;
				}
				else
				{
					red = data.colorRed;
					green = data.colorGreen;
					blue = data.colorBlue;
					alpha = data.colorAlpha;
				}
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
			
			if (rotation != 0.0)
			{
				//angle = Std.int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				//cos = COS[angle];
				//sin = SIN[angle];
				cos = Math.cos(rotation);
				sin = Math.sin(rotation);
				
				cosLeft = cos * leftOffset;
				cosRight = cos * rightOffset;
				cosTop = cos * topOffset;
				cosBottom = cos * bottomOffset;
				sinLeft = sin * leftOffset;
				sinRight = sin * rightOffset;
				sinTop = sin * topOffset;
				sinBottom = sin * bottomOffset;
				
				floatData[position]   = x - cosLeft + sinTop;
				floatData[++position] = y - sinLeft - cosTop;
				floatData[++position] = u1;
				floatData[++position] = v1;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
				
				floatData[++position] = x + cosRight + sinTop;
				floatData[++position] = y + sinRight - cosTop;
				floatData[++position] = u2;
				floatData[++position] = v1;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
				
				floatData[++position] = x - cosLeft - sinBottom;
				floatData[++position] = y - sinLeft + cosBottom;
				floatData[++position] = u1;
				floatData[++position] = v2;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
				
				floatData[++position] = x + cosRight - sinBottom;
				floatData[++position] = y + sinRight + cosBottom;
				floatData[++position] = u2;
				floatData[++position] = v2;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
			}
			else
			{
				floatData[position]   = x - leftOffset;
				floatData[++position] = y - topOffset;
				floatData[++position] = u1;
				floatData[++position] = v1;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
				
				floatData[++position] = x + rightOffset;
				floatData[++position] = y - topOffset;
				floatData[++position] = u2;
				floatData[++position] = v1;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
				
				floatData[++position] = x - leftOffset;
				floatData[++position] = y + bottomOffset;
				floatData[++position] = u1;
				floatData[++position] = v2;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
				
				floatData[++position] = x + rightOffset;
				floatData[++position] = y + bottomOffset;
				floatData[++position] = u2;
				floatData[++position] = v2;
				if (useColor)
				{
					floatData[++position] = red;
					floatData[++position] = green;
					floatData[++position] = blue;
					floatData[++position] = alpha;
				}
			}
			++position;
		}
		
		return quadsWritten;
	}
	#end
	
	/**
	   @inheritDoc
	**/
	public function writeDataVector(vectorData:Vector<Float>, offset:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool):Int
	{
		if (this._datas == null) return 0;
		
		var vertexID:Int = offset << 2;
		var position:Int;
		
		if (useColor)
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
		
		//var angle:Int;
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
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		var data:T;
		for (i in 0...this.numDatas)
		{
			data = this._datas[i];
			if (!data.visible) continue;
			
			++quadsWritten;
			
			x = data.x + data.offsetX + renderOffsetX;
			y = data.y + data.offsetY + renderOffsetY;
			rotation = data.rotation;
			
			if (useColor)
			{
				if (pma)
				{
					alpha = data.colorAlpha;
					red = data.colorRed * alpha;
					green = data.colorGreen * alpha;
					blue = data.colorBlue * alpha;
				}
				else
				{
					red = data.colorRed;
					green = data.colorGreen;
					blue = data.colorBlue;
					alpha = data.colorAlpha;
				}
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
			
			if (rotation != 0.0)
			{
				//angle = Std.int(rotation * MassiveConstants.ANGLE_CONSTANT) & MassiveConstants.ANGLE_CONSTANT_2;
				//cos = COS[angle];
				//sin = SIN[angle];
				cos = Math.cos(rotation);
				sin = Math.sin(rotation);
				
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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
				if (useColor)
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