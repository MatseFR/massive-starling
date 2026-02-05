package massive.display;
import haxe.io.FPHelper;
import massive.data.QuadData;
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end
#if flash
import openfl.Memory;
#end

/**
 * A Massive layer that displays QuadData
 * @author Matse
 */
@:generic
class QuadLayer<T:QuadData = QuadData> extends MassiveLayer 
{
	
	#if flash
	/**
	   The Vector containing QuadData instances to draw
	**/
	public var datas(get, set):Vector<T>;
	#else
	/**
	   The Array containing QuadData instances to draw
	**/
	public var datas(get, set):Array<T>;
	#end
	
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
		this.animate = false;
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
	 * Adds the specified QuadData to this layer
	 * @param	data
	 */
	public function addQuad(data:T):Void
	{
		this._datas[this._datas.length] = data;
	}
	
	/**
	 * Adds the specified QuadData Array to this layer
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
	 * Removes the specified QuadData from this layer
	 * @param	data
	 */
	public function removeQuad(data:T):Void
	{
		var index:Int = this._datas.indexOf(data);
		if (index != -1)
		{
			removeQuadAt(index);
		}
	}
	
	/**
	   Removes QuadData at specified index
	   @param	index
	**/
	public function removeQuadAt(index:Int):Void
	{
		#if flash
		this._datas.removeAt(index);
		#else
		this._datas.splice(index, 1);
		#end
	}
	
	/**
	 * Removes the specified QuadData Array from this layer
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
				removeQuadAt(index);
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
		// nothing
	}
	
	/**
	   @inheritDoc
	**/
	public function writeDataBytes(byteData:ByteArray, offset:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool):Int 
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
		var color:Int = 0;
		
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
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = Std.int(red * alpha * 255) | Std.int(green * alpha * 255) << 8 | Std.int(blue * alpha * 255) << 16 | Std.int(alpha * 255) << 24;
					}
					else
					{
						alpha = data.alpha;
						red = data.red * alpha;
						green = data.green * alpha;
						blue = data.blue * alpha;
					}
				}
				else
				{
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = Std.int(red * 255) | Std.int(green * 255) << 8 | Std.int(blue * 255) << 16 | Std.int(alpha * 255) << 24;
					}
					else
					{
						red = data.red;
						green = data.green;
						blue = data.blue;
						alpha = data.alpha;
					}
				}
			}
			
			leftOffset = data.leftWidth * data.scaleX;
			rightOffset = data.rightWidth * data.scaleX;
			topOffset = data.topHeight * data.scaleY;
			bottomOffset = data.bottomHeight * data.scaleY;
			
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
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
				
				byteData.writeFloat(x + cosRight + sinTop);
				byteData.writeFloat(y + sinRight - cosTop);
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
				
				byteData.writeFloat(x - cosLeft - sinBottom);
				byteData.writeFloat(y - sinLeft + cosBottom);
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
				
				byteData.writeFloat(x + cosRight - sinBottom);
				byteData.writeFloat(y + sinRight + cosBottom);
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
			}
			else
			{
				byteData.writeFloat(x - leftOffset);
				byteData.writeFloat(y - topOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
				
				byteData.writeFloat(x + rightOffset);
				byteData.writeFloat(y - topOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
				
				byteData.writeFloat(x - leftOffset);
				byteData.writeFloat(y + bottomOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
				
				byteData.writeFloat(x + rightOffset);
				byteData.writeFloat(y + bottomOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						byteData.writeInt(color);
					}
					else
					{
						byteData.writeFloat(red);
						byteData.writeFloat(green);
						byteData.writeFloat(blue);
						byteData.writeFloat(alpha);
					}
				}
			}
		}
		
		return quadsWritten;
	}
	
	#if flash
	/**
	   @inheritDoc
	**/
	public function writeDataBytesMemory(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool, renderData:RenderData):Bool
	{
		if (this._datas == null) return true;
		
		var position:Int = renderData.position;
		
		//if (useColor)
		//{
			//if (simpleColor)
			//{
				//position = offset * 48;
			//}
			//else
			//{
				//position = offset * 96;
			//}
		//}
		//else
		//{
			////position = offset * 32;
			//position = offset << 5;
		//}
		
		var quadsWritten:Int = 0;
		
		var x:Float, y:Float;
		var leftOffset:Float, rightOffset:Float, topOffset:Float, bottomOffset:Float;
		var rotation:Float;
		
		var red:Float = 0;
		var green:Float = 0;
		var blue:Float = 0;
		var alpha:Float = 0;
		var color:Int = 0;
		
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
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = Std.int(red * alpha * 255) | Std.int(green * alpha * 255) << 8 | Std.int(blue * alpha * 255) << 16 | Std.int(alpha * 255) << 24;
					}
					else
					{
						alpha = data.alpha;
						red = data.red * alpha;
						green = data.green * alpha;
						blue = data.blue * alpha;
					}
				}
				else
				{
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = Std.int(red * 255) | Std.int(green * 255) << 8 | Std.int(blue * 255) << 16 | Std.int(alpha * 255) << 24;
					}
					else
					{
						red = data.red;
						green = data.green;
						blue = data.blue;
						alpha = data.alpha;
					}
				}
			}
			
			leftOffset = data.leftWidth * data.scaleX;
			rightOffset = data.rightWidth * data.scaleX;
			topOffset = data.topHeight * data.scaleY;
			bottomOffset = data.bottomHeight * data.scaleY;
			
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
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
				
				Memory.setFloat(position += 4, x + cosRight + sinTop);
				Memory.setFloat(position += 4, y + sinRight - cosTop);
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
				
				Memory.setFloat(position += 4, x - cosLeft - sinBottom);
				Memory.setFloat(position += 4, y - sinLeft + cosBottom);
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
				
				Memory.setFloat(position += 4, x + cosRight - sinBottom);
				Memory.setFloat(position += 4, y + sinRight + cosBottom);
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
			}
			else
			{
				Memory.setFloat(position, x - leftOffset);
				Memory.setFloat(position += 4, y - topOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
				
				Memory.setFloat(position += 4, x + rightOffset);
				Memory.setFloat(position += 4, y - topOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
				
				Memory.setFloat(position += 4, x - leftOffset);
				Memory.setFloat(position += 4, y + bottomOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
				
				Memory.setFloat(position += 4, x + rightOffset);
				Memory.setFloat(position += 4, y + bottomOffset);
				if (useColor)
				{
					if (simpleColor)
					{
						Memory.setI32(position += 4, color);
					}
					else
					{
						Memory.setFloat(position += 4, red);
						Memory.setFloat(position += 4, green);
						Memory.setFloat(position += 4, blue);
						Memory.setFloat(position += 4, alpha);
					}
				}
			}
			position += 4;
		}
		
		//return quadsWritten;
		return true;
	}
	#end
	
	#if !flash
	/**
	   @inheritDoc
	**/
	public function writeDataFloat32Array(floatData:Float32Array, offset:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool):Int
	{
		if (this._datas == null) return 0;
		
		var vertexID:Int = offset << 2;
		var position:Int;
		
		if (useColor)
		{
			if (simpleColor)
			{
				position = vertexID * 3;
			}
			else
			{
				position = vertexID * 6;
			}
		}
		else
		{
			position = vertexID * 2;
		}
		
		var quadsWritten:Int = 0;
		
		var x:Float, y:Float;
		var leftOffset:Float, rightOffset:Float, topOffset:Float, bottomOffset:Float;
		var rotation:Float;
		
		var red:Float = 0;
		var green:Float = 0;
		var blue:Float = 0;
		var alpha:Float = 0;
		var color:Float = 0;
		
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
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = FPHelper.i32ToFloat(Std.int(red * alpha * 255) | Std.int(green * alpha * 255) << 8 | Std.int(blue * alpha * 255) << 16 | Std.int(alpha * 255) << 24);
					}
					else
					{
						alpha = data.alpha;
						red = data.red * alpha;
						green = data.green * alpha;
						blue = data.blue * alpha;
					}
				}
				else
				{
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = FPHelper.i32ToFloat(Std.int(red * 255) | Std.int(green * 255) << 8 | Std.int(blue * 255) << 16 | Std.int(alpha * 255) << 24);
					}
					else
					{
						red = data.red;
						green = data.green;
						blue = data.blue;
						alpha = data.alpha;
					}
				}
			}
			
			leftOffset = data.leftWidth * data.scaleX;
			rightOffset = data.rightWidth * data.scaleX;
			topOffset = data.topHeight * data.scaleY;
			bottomOffset = data.bottomHeight * data.scaleY;
			
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
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
				}
				
				floatData[++position] = x + cosRight + sinTop;
				floatData[++position] = y + sinRight - cosTop;
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
				}
				
				floatData[++position] = x - cosLeft - sinBottom;
				floatData[++position] = y - sinLeft + cosBottom;
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
				}
				
				floatData[++position] = x + cosRight - sinBottom;
				floatData[++position] = y + sinRight + cosBottom;
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
				}
			}
			else
			{
				floatData[position]   = x - leftOffset;
				floatData[++position] = y - topOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
				}
				
				floatData[++position] = x + rightOffset;
				floatData[++position] = y - topOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
				}
				
				floatData[++position] = x - leftOffset;
				floatData[++position] = y + bottomOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
				}
				
				floatData[++position] = x + rightOffset;
				floatData[++position] = y + bottomOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						floatData[++position] = color;
					}
					else
					{
						floatData[++position] = red;
						floatData[++position] = green;
						floatData[++position] = blue;
						floatData[++position] = alpha;
					}
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
	public function writeDataVector(vectorData:Vector<Float>, offset:Int, renderOffsetX:Float, renderOffsetY:Float, pma:Bool, useColor:Bool, simpleColor:Bool):Int 
	{
		if (this._datas == null) return 0;
		
		var vertexID:Int = offset << 2;
		var position:Int;
		
		if (useColor)
		{
			if (simpleColor)
			{
				position = vertexID * 3;
			}
			else
			{
				position = vertexID * 6;
			}
		}
		else
		{
			position = vertexID * 2;
		}
		
		var quadsWritten:Int = 0;
		
		var x:Float, y:Float;
		var leftOffset:Float, rightOffset:Float, topOffset:Float, bottomOffset:Float;
		var rotation:Float;
		
		var red:Float = 0;
		var green:Float = 0;
		var blue:Float = 0;
		var alpha:Float = 0;
		var color:Float = 0;
		
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
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = FPHelper.i32ToFloat(Std.int(red * alpha * 255) | Std.int(green * alpha * 255) << 8 | Std.int(blue * alpha * 255) << 16 | Std.int(alpha * 255) << 24);
					}
					else
					{
						alpha = data.alpha;
						red = data.red * alpha;
						green = data.green * alpha;
						blue = data.blue * alpha;
					}
				}
				else
				{
					if (simpleColor)
					{
						alpha = data.alpha;
						alpha = alpha < 0.0 ? 0.0 : alpha > 1.0 ? 1.0 : alpha;
						red = data.red;
						red = red < 0.0 ? 0.0 : red > 1.0 ? 1.0 : red;
						green = data.green;
						green = green < 0.0 ? 0.0 : green > 1.0 ? 1.0 : green;
						blue = data.blue;
						blue = blue < 0.0 ? 0.0 : blue > 1.0 ? 1.0 : blue;
						color = FPHelper.i32ToFloat(Std.int(red * 255) | Std.int(green * 255) << 8 | Std.int(blue * 255) << 16 | Std.int(alpha * 255) << 24);
					}
					else
					{
						red = data.red;
						green = data.green;
						blue = data.blue;
						alpha = data.alpha;
					}
				}
			}
			
			leftOffset = data.leftWidth * data.scaleX;
			rightOffset = data.rightWidth * data.scaleX;
			topOffset = data.topHeight * data.scaleY;
			bottomOffset = data.bottomHeight * data.scaleY;
			
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
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
				
				vectorData[++position] = x + cosRight + sinTop;
				vectorData[++position] = y + sinRight - cosTop;
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
				
				vectorData[++position] = x - cosLeft - sinBottom;
				vectorData[++position] = y - sinLeft + cosBottom;
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
				
				vectorData[++position] = x + cosRight - sinBottom;
				vectorData[++position] = y + sinRight + cosBottom;
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
			}
			else
			{
				vectorData[position]   = x - leftOffset;
				vectorData[++position] = y - topOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
				
				vectorData[++position] = x + rightOffset;
				vectorData[++position] = y - topOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
				
				vectorData[++position] = x - leftOffset;
				vectorData[++position] = y + bottomOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
				
				vectorData[++position] = x + rightOffset;
				vectorData[++position] = y + bottomOffset;
				if (useColor)
				{
					if (simpleColor)
					{
						vectorData[++position] = color;
					}
					else
					{
						vectorData[++position] = red;
						vectorData[++position] = green;
						vectorData[++position] = blue;
						vectorData[++position] = alpha;
					}
				}
			}
			++position;
		}
		
		return quadsWritten;
	}
	
}