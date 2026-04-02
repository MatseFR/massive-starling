package massive.display;
import haxe.io.FPHelper;
import massive.data.QuadData;
import massive.util.MathUtils;
import openfl.Vector;
import openfl.geom.Matrix;
import openfl.geom.Point;
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
	
	private var _matrix:Matrix = new Matrix();
	private var _inPt:Point = new Point();
	private var _outPt:Point = new Point();
	private var _useMatrix:Bool = false;
	
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
	public function dispose(poolData:Bool = true):Void
	{
		if (poolData)
		{
			removeAllData(poolData);
		}
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
		if (index != -1) removeQuadAt(index);
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
			if (index != -1) removeQuadAt(index);
		}
	}
	
	/**
	   @inheritDoc
	**/
	public function removeAllData(pool:Bool = true):Void 
	{
		if (pool)
		{
			var count:Int = this._datas.length;
			for (i in 0...count)
			{
				this._datas[i].pool();
			}
		}
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
	
	private var __x:Float;
	private var __y:Float;
	private var __leftOffset:Float;
	private var __rightOffset:Float;
	private var __topOffset:Float;
	private var __bottomOffset:Float;
	private var __rotation:Float;
	private var __skewX:Float;
	private var __skewY:Float;
	private var __red:Float;
	private var __redOffset:Float;
	private var __green:Float;
	private var __greenOffset:Float;
	private var __blue:Float;
	private var __blueOffset:Float;
	private var __alpha:Float;
	private var __alphaOffset:Float;
	private var __color:Int;
	private var __colorOffset:Int;
	private var __cosRotation:Float;
	private var __sinRotation:Float;
	private var __cosSkewX:Float;
	private var __sinSkewX:Float;
	private var __cosSkewY:Float;
	private var __sinSkewY:Float;
	private var __a:Float;
	private var __b:Float;
	private var __c:Float;
	private var __d:Float;
	private var __x1:Float;
	private var __y1:Float;
	private var __x2:Float;
	private var __y2:Float;
	private var __x3:Float;
	private var __y3:Float;
	private var __x4:Float;
	private var __y4:Float;
	private var __rotationChanged:Bool;
	private var __skewXChanged:Bool;
	private var __skewYChanged:Bool;
	
	private var __position:Int;
	private var __quadsWritten:Int;
	private var __pma:Bool;
	private var __useColor:Bool;
	private var __useColorOffset:Bool;
	private var __simpleColor:Bool;
	private var __numQuads:Int;
	private var __totalQuads:Int;
	private var __storeBounds:Bool;
	private var __boundsIndex:Int;
	private var __data:T;
	
	/**
	   @inheritDoc
	**/
	public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Bool 
	{
		if (this._datas == null) return true;
		
		this.__quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__simpleColor = renderData.useSimpleColor;
		this.__numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in renderData.quadOffset...this.__totalQuads)
		{
			this.__data = this._datas[i];
			if (!this.__data.visible) continue;
			
			++this.__quadsWritten;
			
			this.__x = this.__data.x + this.__data.offsetX + renderOffsetX;
			this.__y = this.__data.y + this.__data.offsetY + renderOffsetY;
			
			if (this.__data._transformChanged)
			{
				this.__rotationChanged = this.__data._rotationChanged;
				this.__skewXChanged = this.__data._skewXChanged;
				this.__skewYChanged = this.__data._skewYChanged;
				
				if (this.__rotationChanged)
				{
					this.__rotation = this.__data._rotation;
					this.__cosRotation = this.__data._cosRotation = Math.cos(this.__rotation);
					this.__sinRotation = this.__data._sinRotation = Math.sin(this.__rotation);
					this.__data._rotationChanged = false;
				}
				else
				{
					this.__cosRotation = this.__data._cosRotation;
					this.__sinRotation = this.__data._sinRotation;
				}
				
				if (this.__skewXChanged)
				{
					this.__skewX = this.__data._skewX;
					this.__cosSkewX = this.__data._cosSkewX = Math.cos(this.__skewX);
					this.__sinSkewX = this.__data._sinSkewX = -Math.sin(this.__skewX);
					this.__data._skewXChanged = false;
				}
				else
				{
					this.__cosSkewX = this.__data._cosSkewX;
					this.__sinSkewX = this.__data._sinSkewX;
				}
				
				if (this.__skewYChanged)
				{
					this.__skewY = this.__data._skewY;
					this.__cosSkewY = this.__data._cosSkewY = Math.cos(this.__skewY);
					this.__sinSkewY = this.__data._sinSkewY = Math.sin(this.__skewY);
					this.__data._skewYChanged = false;
				}
				else
				{
					this.__cosSkewY = this.__data._cosSkewY;
					this.__sinSkewY = this.__data._sinSkewY;
				}
				
				if (this.__data._sizeXChanged)
				{
					this.__data._leftOffset = this.__data.leftWidth * this.__data._scaleX;
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset = this.__data.rightWidth * this.__data._scaleX;
					this.__data._sizeXChanged = false;
				}
				else
				{
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset;
				}
				
				if (this.__data._sizeYChanged)
				{
					this.__data._topOffset = this.__data.topHeight * this.__data._scaleY;
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset = this.__data.bottomHeight * this.__data._scaleY;
					this.__data._sizeYChanged = false;
				}
				else
				{
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset;
				}
				
				this.__data._transformChanged = false;
				
				if (this.__rotationChanged || this.__skewXChanged || this.__skewYChanged)
				{
					this.__a = this.__data._a = this.__cosSkewY * this.__cosRotation - this.__sinSkewY * this.__sinRotation;
					this.__b = this.__data._b = this.__cosSkewY * this.__sinRotation + this.__sinSkewY * this.__cosRotation;
					this.__c = this.__data._c = this.__sinSkewX * this.__cosRotation - this.__cosSkewX * this.__sinRotation;
					this.__d = this.__data._d = this.__sinSkewX * this.__sinRotation + this.__cosSkewX * this.__cosRotation;
				}
				else
				{
					this.__a = this.__data._a;
					this.__b = this.__data._b;
					this.__c = this.__data._c;
					this.__d = this.__data._d;
				}
				
				this.__x1 = this.__data._x1 = this.__leftOffset * this.__a + this.__topOffset * this.__c;
				this.__y1 = this.__data._y1 = this.__leftOffset * this.__b + this.__topOffset * this.__d;
				this.__x2 = this.__data._x2 = this.__rightOffset * this.__a + this.__topOffset * this.__c;
				this.__y2 = this.__data._y2 = this.__rightOffset * this.__b + this.__topOffset * this.__d;
				this.__x3 = this.__data._x3 = this.__leftOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y3 = this.__data._y3 = this.__leftOffset * this.__b + this.__bottomOffset * this.__d;
				this.__x4 = this.__data._x4 = this.__rightOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y4 = this.__data._y4 = this.__rightOffset * this.__b + this.__bottomOffset * this.__d;
			}
			else
			{
				this.__x1 = this.__data._x1;
				this.__y1 = this.__data._y1;
				this.__x2 = this.__data._x2;
				this.__y2 = this.__data._y2;
				this.__x3 = this.__data._x3;
				this.__y3 = this.__data._y3;
				this.__x4 = this.__data._x4;
				this.__y4 = this.__data._y4;
			}
			
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					this.__alpha = this.__data.alpha;
					this.__alpha = this.__alpha < 0.0 ? 0.0 : this.__alpha > 1.0 ? 1.0 : this.__alpha;
					this.__red = this.__data.red;
					this.__red = this.__red < 0.0 ? 0.0 : this.__red > 1.0 ? 1.0 : this.__red;
					this.__green = this.__data.green;
					this.__green = this.__green < 0.0 ? 0.0 : this.__green > 1.0 ? 1.0 : this.__green;
					this.__blue = this.__data.blue;
					this.__blue = this.__blue < 0.0 ? 0.0 : this.__blue > 1.0 ? 1.0 : this.__blue;
					if (this.__pma)
					{
						this.__color = Std.int(this.__red * this.__alpha * 255) | Std.int(this.__green * this.__alpha * 255) << 8 | Std.int(this.__blue * this.__alpha * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
					else
					{
						this.__color = Std.int(this.__red * 255) | Std.int(this.__green * 255) << 8 | Std.int(this.__blue * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
				}
				else
				{
					this.__alpha = this.__data.alpha;
					if (this.__pma)
					{
						this.__red = this.__data.red * this.__alpha;
						this.__green = this.__data.green * this.__alpha;
						this.__blue = this.__data.blue * this.__alpha;
					}
					else
					{
						this.__red = this.__data.red;
						this.__green = this.__data.green;
						this.__blue = this.__data.blue;
					}
				}
			}
			
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__alphaOffset = this.__data.alphaOffset;
					this.__alphaOffset = this.__alphaOffset < 0.0 ? 0.0 : this.__alphaOffset > 1.0 ? 1.0 : this.__alphaOffset;
					this.__redOffset = this.__data.redOffset;
					this.__redOffset = this.__redOffset < 0.0 ? 0.0 : this.__redOffset > 1.0 ? 1.0 : this.__redOffset;
					this.__greenOffset = this.__data.greenOffset;
					this.__greenOffset = this.__greenOffset < 0.0 ? 0.0 : this.__greenOffset > 1.0 ? 1.0 : this.__greenOffset;
					this.__blueOffset = this.__data.blueOffset;
					this.__blueOffset = this.__blueOffset < 0.0 ? 0.0 : this.__blueOffset > 1.0 ? 1.0 : this.__blueOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__colorOffset = Std.int(this.__redOffset * 255) | Std.int(this.__greenOffset * 255) << 8 | Std.int(this.__blueOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
					else
					{
						this.__colorOffset = Std.int(this.__redOffset * this.__alphaOffset * 255) | Std.int(this.__greenOffset * this.__alphaOffset * 255) << 8 | Std.int(this.__blueOffset * this.__alphaOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
				}
				else
				{
					this.__alphaOffset = this.__data.alphaOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__redOffset = this.__data.redOffset;
						this.__greenOffset = this.__data.greenOffset;
						this.__blueOffset = this.__data.blueOffset;
					}
					else
					{
						this.__redOffset = this.__data.redOffset * this.__alphaOffset;
						this.__greenOffset = this.__data.greenOffset * this.__alphaOffset;
						this.__blueOffset = this.__data.blueOffset * this.__alphaOffset;
					}
				}
			}
			
			if (this.__storeBounds)
			{
				boundsData[++this.__boundsIndex] = this.__x + this.__x1;
				boundsData[++this.__boundsIndex] = this.__y + this.__y1;
				boundsData[++this.__boundsIndex] = this.__x + this.__x2;
				boundsData[++this.__boundsIndex] = this.__y + this.__y2;
				boundsData[++this.__boundsIndex] = this.__x + this.__x3;
				boundsData[++this.__boundsIndex] = this.__y + this.__y3;
				boundsData[++this.__boundsIndex] = this.__x + this.__x4;
				boundsData[++this.__boundsIndex] = this.__y + this.__y4;
			}
			
			// TOP LEFT
			byteData.writeFloat(this.__x + this.__x1);
			byteData.writeFloat(this.__y + this.__y1);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__color);
				}
				else
				{
					byteData.writeFloat(this.__red);
					byteData.writeFloat(this.__green);
					byteData.writeFloat(this.__blue);
					byteData.writeFloat(this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__colorOffset);
				}
				else
				{
					byteData.writeFloat(this.__redOffset);
					byteData.writeFloat(this.__greenOffset);
					byteData.writeFloat(this.__blueOffset);
					byteData.writeFloat(this.__alphaOffset);
				}
			}
			
			// TOP RIGHT
			byteData.writeFloat(this.__x + this.__x2);
			byteData.writeFloat(this.__y + this.__y2);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__color);
				}
				else
				{
					byteData.writeFloat(this.__red);
					byteData.writeFloat(this.__green);
					byteData.writeFloat(this.__blue);
					byteData.writeFloat(this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__colorOffset);
				}
				else
				{
					byteData.writeFloat(this.__redOffset);
					byteData.writeFloat(this.__greenOffset);
					byteData.writeFloat(this.__blueOffset);
					byteData.writeFloat(this.__alphaOffset);
				}
			}
			
			// BOTTOM LEFT
			byteData.writeFloat(this.__x + this.__x3);
			byteData.writeFloat(this.__y + this.__y3);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__color);
				}
				else
				{
					byteData.writeFloat(this.__red);
					byteData.writeFloat(this.__green);
					byteData.writeFloat(this.__blue);
					byteData.writeFloat(this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__colorOffset);
				}
				else
				{
					byteData.writeFloat(this.__redOffset);
					byteData.writeFloat(this.__greenOffset);
					byteData.writeFloat(this.__blueOffset);
					byteData.writeFloat(this.__alphaOffset);
				}
			}
			
			// BOTTOM RIGHT
			byteData.writeFloat(this.__x + this.__x4);
			byteData.writeFloat(this.__y + this.__y4);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__color);
				}
				else
				{
					byteData.writeFloat(this.__red);
					byteData.writeFloat(this.__green);
					byteData.writeFloat(this.__blue);
					byteData.writeFloat(this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					byteData.writeInt(this.__colorOffset);
				}
				else
				{
					byteData.writeFloat(this.__redOffset);
					byteData.writeFloat(this.__greenOffset);
					byteData.writeFloat(this.__blueOffset);
					byteData.writeFloat(this.__alphaOffset);
				}
			}
		}
		
		renderData.numQuads += this.__quadsWritten;
		renderData.totalQuads += this.__quadsWritten;
		
		if (this.numDatas == this.__totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this.__numQuads;
			return false;
		}
	}
	
	#if flash
	/**
	   @inheritDoc
	**/
	public function writeDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Bool
	{
		if (this._datas == null) return true;
		
		this.__position = renderData.position;
		this.__quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__simpleColor = renderData.useSimpleColor;
		this.__numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in renderData.quadOffset...this.__totalQuads)
		{
			this.__data = this._datas[i];
			if (!this.__data.visible) continue;
			
			++this.__quadsWritten;
			
			this.__x = this.__data.x + this.__data.offsetX + renderOffsetX;
			this.__y = this.__data.y + this.__data.offsetY + renderOffsetY;
			
			if (this.__data._transformChanged)
			{
				this.__rotationChanged = this.__data._rotationChanged;
				this.__skewXChanged = this.__data._skewXChanged;
				this.__skewYChanged = this.__data._skewYChanged;
				
				if (this.__rotationChanged)
				{
					this.__rotation = this.__data._rotation;
					this.__cosRotation = this.__data._cosRotation = Math.cos(this.__rotation);
					this.__sinRotation = this.__data._sinRotation = Math.sin(this.__rotation);
					this.__data._rotationChanged = false;
				}
				else
				{
					this.__cosRotation = this.__data._cosRotation;
					this.__sinRotation = this.__data._sinRotation;
				}
				
				if (this.__skewXChanged)
				{
					this.__skewX = this.__data._skewX;
					this.__cosSkewX = this.__data._cosSkewX = Math.cos(this.__skewX);
					this.__sinSkewX = this.__data._sinSkewX = -Math.sin(this.__skewX);
					this.__data._skewXChanged = false;
				}
				else
				{
					this.__cosSkewX = this.__data._cosSkewX;
					this.__sinSkewX = this.__data._sinSkewX;
				}
				
				if (this.__skewYChanged)
				{
					this.__skewY = this.__data._skewY;
					this.__cosSkewY = this.__data._cosSkewY = Math.cos(this.__skewY);
					this.__sinSkewY = this.__data._sinSkewY = Math.sin(this.__skewY);
					this.__data._skewYChanged = false;
				}
				else
				{
					this.__cosSkewY = this.__data._cosSkewY;
					this.__sinSkewY = this.__data._sinSkewY;
				}
				
				if (this.__data._sizeXChanged)
				{
					this.__data._leftOffset = this.__data.leftWidth * this.__data._scaleX;
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset = this.__data.rightWidth * this.__data._scaleX;
					this.__data._sizeXChanged = false;
				}
				else
				{
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset;
				}
				
				if (this.__data._sizeYChanged)
				{
					this.__data._topOffset = this.__data.topHeight * this.__data._scaleY;
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset = this.__data.bottomHeight * this.__data._scaleY;
					this.__data._sizeYChanged = false;
				}
				else
				{
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset;
				}
				
				this.__data._transformChanged = false;
				
				if (this.__rotationChanged || this.__skewXChanged || this.__skewYChanged)
				{
					this.__a = this.__data._a = this.__cosSkewY * this.__cosRotation - this.__sinSkewY * this.__sinRotation;
					this.__b = this.__data._b = this.__cosSkewY * this.__sinRotation + this.__sinSkewY * this.__cosRotation;
					this.__c = this.__data._c = this.__sinSkewX * this.__cosRotation - this.__cosSkewX * this.__sinRotation;
					this.__d = this.__data._d = this.__sinSkewX * this.__sinRotation + this.__cosSkewX * this.__cosRotation;
				}
				else
				{
					this.__a = this.__data._a;
					this.__b = this.__data._b;
					this.__c = this.__data._c;
					this.__d = this.__data._d;
				}
				
				this.__x1 = this.__data._x1 = this.__leftOffset * this.__a + this.__topOffset * this.__c;
				this.__y1 = this.__data._y1 = this.__leftOffset * this.__b + this.__topOffset * this.__d;
				this.__x2 = this.__data._x2 = this.__rightOffset * this.__a + this.__topOffset * this.__c;
				this.__y2 = this.__data._y2 = this.__rightOffset * this.__b + this.__topOffset * this.__d;
				this.__x3 = this.__data._x3 = this.__leftOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y3 = this.__data._y3 = this.__leftOffset * this.__b + this.__bottomOffset * this.__d;
				this.__x4 = this.__data._x4 = this.__rightOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y4 = this.__data._y4 = this.__rightOffset * this.__b + this.__bottomOffset * this.__d;
			}
			else
			{
				this.__x1 = this.__data._x1;
				this.__y1 = this.__data._y1;
				this.__x2 = this.__data._x2;
				this.__y2 = this.__data._y2;
				this.__x3 = this.__data._x3;
				this.__y3 = this.__data._y3;
				this.__x4 = this.__data._x4;
				this.__y4 = this.__data._y4;
			}
			
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					this.__alpha = this.__data.alpha;
					this.__alpha = this.__alpha < 0.0 ? 0.0 : this.__alpha > 1.0 ? 1.0 : this.__alpha;
					this.__red = this.__data.red;
					this.__red = this.__red < 0.0 ? 0.0 : this.__red > 1.0 ? 1.0 : this.__red;
					this.__green = this.__data.green;
					this.__green = this.__green < 0.0 ? 0.0 : this.__green > 1.0 ? 1.0 : this.__green;
					this.__blue = this.__data.blue;
					this.__blue = this.__blue < 0.0 ? 0.0 : this.__blue > 1.0 ? 1.0 : this.__blue;
					if (this.__pma)
					{
						this.__color = Std.int(this.__red * this.__alpha * 255) | Std.int(this.__green * this.__alpha * 255) << 8 | Std.int(this.__blue * this.__alpha * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
					else
					{
						this.__color = Std.int(this.__red * 255) | Std.int(this.__green * 255) << 8 | Std.int(this.__blue * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
				}
				else
				{
					this.__alpha = this.__data.alpha;
					if (this.__pma)
					{
						this.__red = this.__data.red * this.__alpha;
						this.__green = this.__data.green * this.__alpha;
						this.__blue = this.__data.blue * this.__alpha;
					}
					else
					{
						this.__red = this.__data.red;
						this.__green = this.__data.green;
						this.__blue = this.__data.blue;
					}
				}
			}
			
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__alphaOffset = this.__data.alphaOffset;
					this.__alphaOffset = this.__alphaOffset < 0.0 ? 0.0 : this.__alphaOffset > 1.0 ? 1.0 : this.__alphaOffset;
					this.__redOffset = this.__data.redOffset;
					this.__redOffset = this.__redOffset < 0.0 ? 0.0 : this.__redOffset > 1.0 ? 1.0 : this.__redOffset;
					this.__greenOffset = this.__data.greenOffset;
					this.__greenOffset = this.__greenOffset < 0.0 ? 0.0 : this.__greenOffset > 1.0 ? 1.0 : this.__greenOffset;
					this.__blueOffset = this.__data.blueOffset;
					this.__blueOffset = this.__blueOffset < 0.0 ? 0.0 : this.__blueOffset > 1.0 ? 1.0 : this.__blueOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__colorOffset = Std.int(this.__redOffset * 255) | Std.int(this.__greenOffset * 255) << 8 | Std.int(this.__blueOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
					else
					{
						this.__colorOffset = Std.int(this.__redOffset * this.__alphaOffset * 255) | Std.int(this.__greenOffset * this.__alphaOffset * 255) << 8 | Std.int(this.__blueOffset * this.__alphaOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
				}
				else
				{
					this.__alphaOffset = this.__data.alphaOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__redOffset = this.__data.redOffset;
						this.__greenOffset = this.__data.greenOffset;
						this.__blueOffset = this.__data.blueOffset;
					}
					else
					{
						this.__redOffset = this.__data.redOffset * this.__alphaOffset;
						this.__greenOffset = this.__data.greenOffset * this.__alphaOffset;
						this.__blueOffset = this.__data.blueOffset * this.__alphaOffset;
					}
				}
			}
			
			if (this.__storeBounds)
			{
				boundsData[++this.__boundsIndex] = this.__x + this.__x1;
				boundsData[++this.__boundsIndex] = this.__y + this.__y1;
				boundsData[++this.__boundsIndex] = this.__x + this.__x2;
				boundsData[++this.__boundsIndex] = this.__y + this.__y2;
				boundsData[++this.__boundsIndex] = this.__x + this.__x3;
				boundsData[++this.__boundsIndex] = this.__y + this.__y3;
				boundsData[++this.__boundsIndex] = this.__x + this.__x4;
				boundsData[++this.__boundsIndex] = this.__y + this.__y4;
			}
			
			// TOP LEFT
			Memory.setFloat(this.__position, this.__x + this.__x1);
			Memory.setFloat(this.__position += 4, this.__y + this.__y1);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__color);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__red);
					Memory.setFloat(this.__position += 4, this.__green);
					Memory.setFloat(this.__position += 4, this.__blue);
					Memory.setFloat(this.__position += 4, this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__colorOffset);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__redOffset);
					Memory.setFloat(this.__position += 4, this.__greenOffset);
					Memory.setFloat(this.__position += 4, this.__blueOffset);
					Memory.setFloat(this.__position += 4, this.__alphaOffset);
				}
			}
			
			// TOP RIGHT
			Memory.setFloat(this.__position += 4, this.__x + this.__x2);
			Memory.setFloat(this.__position += 4, this.__y + this.__y2);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__color);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__red);
					Memory.setFloat(this.__position += 4, this.__green);
					Memory.setFloat(this.__position += 4, this.__blue);
					Memory.setFloat(this.__position += 4, this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__colorOffset);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__redOffset);
					Memory.setFloat(this.__position += 4, this.__greenOffset);
					Memory.setFloat(this.__position += 4, this.__blueOffset);
					Memory.setFloat(this.__position += 4, this.__alphaOffset);
				}
			}
			
			// BOTTOM LEFT
			Memory.setFloat(this.__position += 4, this.__x + this.__x3);
			Memory.setFloat(this.__position += 4, this.__y + this.__y3);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__color);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__red);
					Memory.setFloat(this.__position += 4, this.__green);
					Memory.setFloat(this.__position += 4, this.__blue);
					Memory.setFloat(this.__position += 4, this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__colorOffset);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__redOffset);
					Memory.setFloat(this.__position += 4, this.__greenOffset);
					Memory.setFloat(this.__position += 4, this.__blueOffset);
					Memory.setFloat(this.__position += 4, this.__alphaOffset);
				}
			}
			
			// BOTTOM RIGHT
			Memory.setFloat(this.__position += 4, this.__x + this.__x4);
			Memory.setFloat(this.__position += 4, this.__y + this.__y4);
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__color);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__red);
					Memory.setFloat(this.__position += 4, this.__green);
					Memory.setFloat(this.__position += 4, this.__blue);
					Memory.setFloat(this.__position += 4, this.__alpha);
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					Memory.setI32(this.__position += 4, this.__colorOffset);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__redOffset);
					Memory.setFloat(this.__position += 4, this.__greenOffset);
					Memory.setFloat(this.__position += 4, this.__blueOffset);
					Memory.setFloat(this.__position += 4, this.__alphaOffset);
				}
			}
			
			this.__position += 4;
		}
		
		renderData.numQuads += this.__quadsWritten;
		renderData.position = this.__position;
		renderData.totalQuads += this.__quadsWritten;
		
		if (this.numDatas == this.__totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this.__numQuads;
			return false;
		}
	}
	#end
	
	#if !flash
	/**
	   @inheritDoc
	**/
	public function writeDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Bool
	{
		if (this._datas == null) return true;
		
		this.__position = renderData.position;
		this.__quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__simpleColor = renderData.useSimpleColor;
		this.__numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		for (i in renderData.quadOffset...this.__totalQuads)
		{
			this.__data = this._datas[i];
			if (!this.__data.visible) continue;
			
			++this.__quadsWritten;
			
			this.__x = this.__data.x + this.__data.offsetX + renderOffsetX;
			this.__y = this.__data.y + this.__data.offsetY + renderOffsetY;
			
			if (this.__data._transformChanged)
			{
				this.__rotationChanged = this.__data._rotationChanged;
				this.__skewXChanged = this.__data._skewXChanged;
				this.__skewYChanged = this.__data._skewYChanged;
				
				if (this.__rotationChanged)
				{
					this.__rotation = this.__data._rotation;
					this.__cosRotation = this.__data._cosRotation = Math.cos(this.__rotation);
					this.__sinRotation = this.__data._sinRotation = Math.sin(this.__rotation);
					this.__data._rotationChanged = false;
				}
				else
				{
					this.__cosRotation = this.__data._cosRotation;
					this.__sinRotation = this.__data._sinRotation;
				}
				
				if (this.__skewXChanged)
				{
					this.__skewX = this.__data._skewX;
					this.__cosSkewX = this.__data._cosSkewX = Math.cos(this.__skewX);
					this.__sinSkewX = this.__data._sinSkewX = -Math.sin(this.__skewX);
					this.__data._skewXChanged = false;
				}
				else
				{
					this.__cosSkewX = this.__data._cosSkewX;
					this.__sinSkewX = this.__data._sinSkewX;
				}
				
				if (this.__skewYChanged)
				{
					this.__skewY = this.__data._skewY;
					this.__cosSkewY = this.__data._cosSkewY = Math.cos(this.__skewY);
					this.__sinSkewY = this.__data._sinSkewY = Math.sin(this.__skewY);
					this.__data._skewYChanged = false;
				}
				else
				{
					this.__cosSkewY = this.__data._cosSkewY;
					this.__sinSkewY = this.__data._sinSkewY;
				}
				
				if (this.__data._sizeXChanged)
				{
					this.__data._leftOffset = this.__data.leftWidth * this.__data._scaleX;
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset = this.__data.rightWidth * this.__data._scaleX;
					this.__data._sizeXChanged = false;
				}
				else
				{
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset;
				}
				
				if (this.__data._sizeYChanged)
				{
					this.__data._topOffset = this.__data.topHeight * this.__data._scaleY;
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset = this.__data.bottomHeight * this.__data._scaleY;
					this.__data._sizeYChanged = false;
				}
				else
				{
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset;
				}
				
				this.__data._transformChanged = false;
				
				if (this.__rotationChanged || this.__skewXChanged || this.__skewYChanged)
				{
					this.__a = this.__data._a = this.__cosSkewY * this.__cosRotation - this.__sinSkewY * this.__sinRotation;
					this.__b = this.__data._b = this.__cosSkewY * this.__sinRotation + this.__sinSkewY * this.__cosRotation;
					this.__c = this.__data._c = this.__sinSkewX * this.__cosRotation - this.__cosSkewX * this.__sinRotation;
					this.__d = this.__data._d = this.__sinSkewX * this.__sinRotation + this.__cosSkewX * this.__cosRotation;
				}
				else
				{
					this.__a = this.__data._a;
					this.__b = this.__data._b;
					this.__c = this.__data._c;
					this.__d = this.__data._d;
				}
				
				this.__x1 = this.__data._x1 = this.__leftOffset * this.__a + this.__topOffset * this.__c;
				this.__y1 = this.__data._y1 = this.__leftOffset * this.__b + this.__topOffset * this.__d;
				this.__x2 = this.__data._x2 = this.__rightOffset * this.__a + this.__topOffset * this.__c;
				this.__y2 = this.__data._y2 = this.__rightOffset * this.__b + this.__topOffset * this.__d;
				this.__x3 = this.__data._x3 = this.__leftOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y3 = this.__data._y3 = this.__leftOffset * this.__b + this.__bottomOffset * this.__d;
				this.__x4 = this.__data._x4 = this.__rightOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y4 = this.__data._y4 = this.__rightOffset * this.__b + this.__bottomOffset * this.__d;
			}
			else
			{
				this.__x1 = this.__data._x1;
				this.__y1 = this.__data._y1;
				this.__x2 = this.__data._x2;
				this.__y2 = this.__data._y2;
				this.__x3 = this.__data._x3;
				this.__y3 = this.__data._y3;
				this.__x4 = this.__data._x4;
				this.__y4 = this.__data._y4;
			}
			
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					this.__alpha = this.__data.alpha;
					this.__alpha = this.__alpha < 0.0 ? 0.0 : this.__alpha > 1.0 ? 1.0 : this.__alpha;
					this.__red = this.__data.red;
					this.__red = this.__red < 0.0 ? 0.0 : this.__red > 1.0 ? 1.0 : this.__red;
					this.__green = this.__data.green;
					this.__green = this.__green < 0.0 ? 0.0 : this.__green > 1.0 ? 1.0 : this.__green;
					this.__blue = this.__data.blue;
					this.__blue = this.__blue < 0.0 ? 0.0 : this.__blue > 1.0 ? 1.0 : this.__blue;
					if (this.__pma)
					{
						this.__color = Std.int(this.__red * this.__alpha * 255) | Std.int(this.__green * this.__alpha * 255) << 8 | Std.int(this.__blue * this.__alpha * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
					else
					{
						this.__color = Std.int(this.__red * 255) | Std.int(this.__green * 255) << 8 | Std.int(this.__blue * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
				}
				else
				{
					this.__alpha = this.__data.alpha;
					if (this.__pma)
					{
						this.__red = this.__data.red * this.__alpha;
						this.__green = this.__data.green * this.__alpha;
						this.__blue = this.__data.blue * this.__alpha;
					}
					else
					{
						this.__red = this.__data.red;
						this.__green = this.__data.green;
						this.__blue = this.__data.blue;
					}
				}
			}
			
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__alphaOffset = this.__data.alphaOffset;
					this.__alphaOffset = this.__alphaOffset < 0.0 ? 0.0 : this.__alphaOffset > 1.0 ? 1.0 : this.__alphaOffset;
					this.__redOffset = this.__data.redOffset;
					this.__redOffset = this.__redOffset < 0.0 ? 0.0 : this.__redOffset > 1.0 ? 1.0 : this.__redOffset;
					this.__greenOffset = this.__data.greenOffset;
					this.__greenOffset = this.__greenOffset < 0.0 ? 0.0 : this.__greenOffset > 1.0 ? 1.0 : this.__greenOffset;
					this.__blueOffset = this.__data.blueOffset;
					this.__blueOffset = this.__blueOffset < 0.0 ? 0.0 : this.__blueOffset > 1.0 ? 1.0 : this.__blueOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__colorOffset = Std.int(this.__redOffset * 255) | Std.int(this.__greenOffset * 255) << 8 | Std.int(this.__blueOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
					else
					{
						this.__colorOffset = Std.int(this.__redOffset * this.__alphaOffset * 255) | Std.int(this.__greenOffset * this.__alphaOffset * 255) << 8 | Std.int(this.__blueOffset * this.__alphaOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
				}
				else
				{
					this.__alphaOffset = this.__data.alphaOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__redOffset = this.__data.redOffset;
						this.__greenOffset = this.__data.greenOffset;
						this.__blueOffset = this.__data.blueOffset;
					}
					else
					{
						this.__redOffset = this.__data.redOffset * this.__alphaOffset;
						this.__greenOffset = this.__data.greenOffset * this.__alphaOffset;
						this.__blueOffset = this.__data.blueOffset * this.__alphaOffset;
					}
				}
			}
			
			if (this.__storeBounds)
			{
				boundsData[++this.__boundsIndex] = this.__x + this.__x1;
				boundsData[++this.__boundsIndex] = this.__y + this.__y1;
				boundsData[++this.__boundsIndex] = this.__x + this.__x2;
				boundsData[++this.__boundsIndex] = this.__y + this.__y2;
				boundsData[++this.__boundsIndex] = this.__x + this.__x3;
				boundsData[++this.__boundsIndex] = this.__y + this.__y3;
				boundsData[++this.__boundsIndex] = this.__x + this.__x4;
				boundsData[++this.__boundsIndex] = this.__y + this.__y4;
			}
			
			// TOP LEFT
			floatData[this.__position]   = this.__x + this.__x1;
			floatData[++this.__position] = this.__y + this.__y1;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__color;
				}
				else
				{
					floatData[++this.__position] = this.__red;
					floatData[++this.__position] = this.__green;
					floatData[++this.__position] = this.__blue;
					floatData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					floatData[++this.__position] = this.__redOffset;
					floatData[++this.__position] = this.__greenOffset;
					floatData[++this.__position] = this.__blueOffset;
					floatData[++this.__position] = this.__alphaOffset;
				}
			}
			
			// TOP RIGHT
			floatData[++this.__position] = this.__x + this.__x2;
			floatData[++this.__position] = this.__y + this.__y2;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__color;
				}
				else
				{
					floatData[++this.__position] = this.__red;
					floatData[++this.__position] = this.__green;
					floatData[++this.__position] = this.__blue;
					floatData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					floatData[++this.__position] = this.__redOffset;
					floatData[++this.__position] = this.__greenOffset;
					floatData[++this.__position] = this.__blueOffset;
					floatData[++this.__position] = this.__alphaOffset;
				}
			}
			
			// BOTTOM LEFT
			floatData[++this.__position] = this.__x + this.__x3;
			floatData[++this.__position] = this.__y + this.__y3;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__color;
				}
				else
				{
					floatData[++this.__position] = this.__red;
					floatData[++this.__position] = this.__green;
					floatData[++this.__position] = this.__blue;
					floatData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					floatData[++this.__position] = this.__redOffset;
					floatData[++this.__position] = this.__greenOffset;
					floatData[++this.__position] = this.__blueOffset;
					floatData[++this.__position] = this.__alphaOffset;
				}
			}
			
			// BOTTOM RIGHT
			floatData[++this.__position] = this.__x + this.__x4;
			floatData[++this.__position] = this.__y + this.__y4;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__color;
				}
				else
				{
					floatData[++this.__position] = this.__red;
					floatData[++this.__position] = this.__green;
					floatData[++this.__position] = this.__blue;
					floatData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					floatData[++this.__position] = this.__redOffset;
					floatData[++this.__position] = this.__greenOffset;
					floatData[++this.__position] = this.__blueOffset;
					floatData[++this.__position] = this.__alphaOffset;
				}
			}
			
			++this.__position;
		}
		
		renderData.numQuads += this.__quadsWritten;
		renderData.position = this.__position;
		renderData.totalQuads += this.__quadsWritten;
		
		if (this.numDatas == this.__totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this.__numQuads;
			return false;
		}
	}
	#end
	
	/**
	   @inheritDoc
	**/
	public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Bool 
	{
		if (this._datas == null) return true;
		
		this.__position = renderData.position;
		this.__quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__simpleColor = renderData.useSimpleColor;
		this.__numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		for (i in renderData.quadOffset...this.__totalQuads)
		{
			this.__data = this._datas[i];
			if (!this.__data.visible) continue;
			
			++this.__quadsWritten;
			
			this.__x = this.__data.x + this.__data.offsetX + renderOffsetX;
			this.__y = this.__data.y + this.__data.offsetY + renderOffsetY;
			
			if (this.__data._transformChanged)
			{
				this.__rotationChanged = this.__data._rotationChanged;
				this.__skewXChanged = this.__data._skewXChanged;
				this.__skewYChanged = this.__data._skewYChanged;
				
				if (this.__rotationChanged)
				{
					this.__rotation = this.__data._rotation;
					this.__cosRotation = this.__data._cosRotation = Math.cos(this.__rotation);
					this.__sinRotation = this.__data._sinRotation = Math.sin(this.__rotation);
					this.__data._rotationChanged = false;
				}
				else
				{
					this.__cosRotation = this.__data._cosRotation;
					this.__sinRotation = this.__data._sinRotation;
				}
				
				if (this.__skewXChanged)
				{
					this.__skewX = this.__data._skewX;
					this.__cosSkewX = this.__data._cosSkewX = Math.cos(this.__skewX);
					this.__sinSkewX = this.__data._sinSkewX = -Math.sin(this.__skewX);
					this.__data._skewXChanged = false;
				}
				else
				{
					this.__cosSkewX = this.__data._cosSkewX;
					this.__sinSkewX = this.__data._sinSkewX;
				}
				
				if (this.__skewYChanged)
				{
					this.__skewY = this.__data._skewY;
					this.__cosSkewY = this.__data._cosSkewY = Math.cos(this.__skewY);
					this.__sinSkewY = this.__data._sinSkewY = Math.sin(this.__skewY);
					this.__data._skewYChanged = false;
				}
				else
				{
					this.__cosSkewY = this.__data._cosSkewY;
					this.__sinSkewY = this.__data._sinSkewY;
				}
				
				if (this.__data._sizeXChanged)
				{
					this.__data._leftOffset = this.__data.leftWidth * this.__data._scaleX;
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset = this.__data.rightWidth * this.__data._scaleX;
					this.__data._sizeXChanged = false;
				}
				else
				{
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset;
				}
				
				if (this.__data._sizeYChanged)
				{
					this.__data._topOffset = this.__data.topHeight * this.__data._scaleY;
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset = this.__data.bottomHeight * this.__data._scaleY;
					this.__data._sizeYChanged = false;
				}
				else
				{
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset;
				}
				
				this.__data._transformChanged = false;
				
				if (this.__rotationChanged || this.__skewXChanged || this.__skewYChanged)
				{
					this.__a = this.__data._a = this.__cosSkewY * this.__cosRotation - this.__sinSkewY * this.__sinRotation;
					this.__b = this.__data._b = this.__cosSkewY * this.__sinRotation + this.__sinSkewY * this.__cosRotation;
					this.__c = this.__data._c = this.__sinSkewX * this.__cosRotation - this.__cosSkewX * this.__sinRotation;
					this.__d = this.__data._d = this.__sinSkewX * this.__sinRotation + this.__cosSkewX * this.__cosRotation;
				}
				else
				{
					this.__a = this.__data._a;
					this.__b = this.__data._b;
					this.__c = this.__data._c;
					this.__d = this.__data._d;
				}
				
				this.__x1 = this.__data._x1 = this.__leftOffset * this.__a + this.__topOffset * this.__c;
				this.__y1 = this.__data._y1 = this.__leftOffset * this.__b + this.__topOffset * this.__d;
				this.__x2 = this.__data._x2 = this.__rightOffset * this.__a + this.__topOffset * this.__c;
				this.__y2 = this.__data._y2 = this.__rightOffset * this.__b + this.__topOffset * this.__d;
				this.__x3 = this.__data._x3 = this.__leftOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y3 = this.__data._y3 = this.__leftOffset * this.__b + this.__bottomOffset * this.__d;
				this.__x4 = this.__data._x4 = this.__rightOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y4 = this.__data._y4 = this.__rightOffset * this.__b + this.__bottomOffset * this.__d;
			}
			else
			{
				this.__x1 = this.__data._x1;
				this.__y1 = this.__data._y1;
				this.__x2 = this.__data._x2;
				this.__y2 = this.__data._y2;
				this.__x3 = this.__data._x3;
				this.__y3 = this.__data._y3;
				this.__x4 = this.__data._x4;
				this.__y4 = this.__data._y4;
			}
			
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					this.__alpha = this.__data.alpha;
					this.__alpha = this.__alpha < 0.0 ? 0.0 : this.__alpha > 1.0 ? 1.0 : this.__alpha;
					this.__red = this.__data.red;
					this.__red = this.__red < 0.0 ? 0.0 : this.__red > 1.0 ? 1.0 : this.__red;
					this.__green = this.__data.green;
					this.__green = this.__green < 0.0 ? 0.0 : this.__green > 1.0 ? 1.0 : this.__green;
					this.__blue = this.__data.blue;
					this.__blue = this.__blue < 0.0 ? 0.0 : this.__blue > 1.0 ? 1.0 : this.__blue;
					if (this.__pma)
					{
						this.__color = Std.int(this.__red * this.__alpha * 255) | Std.int(this.__green * this.__alpha * 255) << 8 | Std.int(this.__blue * this.__alpha * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
					else
					{
						this.__color = Std.int(this.__red * 255) | Std.int(this.__green * 255) << 8 | Std.int(this.__blue * 255) << 16 | Std.int(this.__alpha * 255) << 24;
					}
				}
				else
				{
					this.__alpha = this.__data.alpha;
					if (this.__pma)
					{
						this.__red = this.__data.red * this.__alpha;
						this.__green = this.__data.green * this.__alpha;
						this.__blue = this.__data.blue * this.__alpha;
					}
					else
					{
						this.__red = this.__data.red;
						this.__green = this.__data.green;
						this.__blue = this.__data.blue;
					}
				}
			}
			
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__alphaOffset = this.__data.alphaOffset;
					this.__alphaOffset = this.__alphaOffset < 0.0 ? 0.0 : this.__alphaOffset > 1.0 ? 1.0 : this.__alphaOffset;
					this.__redOffset = this.__data.redOffset;
					this.__redOffset = this.__redOffset < 0.0 ? 0.0 : this.__redOffset > 1.0 ? 1.0 : this.__redOffset;
					this.__greenOffset = this.__data.greenOffset;
					this.__greenOffset = this.__greenOffset < 0.0 ? 0.0 : this.__greenOffset > 1.0 ? 1.0 : this.__greenOffset;
					this.__blueOffset = this.__data.blueOffset;
					this.__blueOffset = this.__blueOffset < 0.0 ? 0.0 : this.__blueOffset > 1.0 ? 1.0 : this.__blueOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__colorOffset = Std.int(this.__redOffset * 255) | Std.int(this.__greenOffset * 255) << 8 | Std.int(this.__blueOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
					else
					{
						this.__colorOffset = Std.int(this.__redOffset * this.__alphaOffset * 255) | Std.int(this.__greenOffset * this.__alphaOffset * 255) << 8 | Std.int(this.__blueOffset * this.__alphaOffset * 255) << 16 | Std.int(this.__alphaOffset * 255) << 24;
					}
				}
				else
				{
					this.__alphaOffset = this.__data.alphaOffset;
					if (this.__useColor || renderData.useDisplayColor)
					{
						this.__redOffset = this.__data.redOffset;
						this.__greenOffset = this.__data.greenOffset;
						this.__blueOffset = this.__data.blueOffset;
					}
					else
					{
						this.__redOffset = this.__data.redOffset * this.__alphaOffset;
						this.__greenOffset = this.__data.greenOffset * this.__alphaOffset;
						this.__blueOffset = this.__data.blueOffset * this.__alphaOffset;
					}
				}
			}
			
			if (this.__storeBounds)
			{
				boundsData[++this.__boundsIndex] = this.__x + this.__x1;
				boundsData[++this.__boundsIndex] = this.__y + this.__y1;
				boundsData[++this.__boundsIndex] = this.__x + this.__x2;
				boundsData[++this.__boundsIndex] = this.__y + this.__y2;
				boundsData[++this.__boundsIndex] = this.__x + this.__x3;
				boundsData[++this.__boundsIndex] = this.__y + this.__y3;
				boundsData[++this.__boundsIndex] = this.__x + this.__x4;
				boundsData[++this.__boundsIndex] = this.__y + this.__y4;
			}
			
			// TOP LEFT
			vectorData[this.__position]   = this.__x + this.__x1;
			vectorData[++this.__position] = this.__y + this.__y1;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__color;
				}
				else
				{
					vectorData[++this.__position] = this.__red;
					vectorData[++this.__position] = this.__green;
					vectorData[++this.__position] = this.__blue;
					vectorData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					vectorData[++this.__position] = this.__redOffset;
					vectorData[++this.__position] = this.__greenOffset;
					vectorData[++this.__position] = this.__blueOffset;
					vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			
			// TOP RIGHT
			vectorData[++this.__position] = this.__x + this.__x2;
			vectorData[++this.__position] = this.__y + this.__y2;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__color;
				}
				else
				{
					vectorData[++this.__position] = this.__red;
					vectorData[++this.__position] = this.__green;
					vectorData[++this.__position] = this.__blue;
					vectorData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					vectorData[++this.__position] = this.__redOffset;
					vectorData[++this.__position] = this.__greenOffset;
					vectorData[++this.__position] = this.__blueOffset;
					vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			
			// BOTTOM LEFT
			vectorData[++this.__position] = this.__x + this.__x3;
			vectorData[++this.__position] = this.__y + this.__y3;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__color;
				}
				else
				{
					vectorData[++this.__position] = this.__red;
					vectorData[++this.__position] = this.__green;
					vectorData[++this.__position] = this.__blue;
					vectorData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					vectorData[++this.__position] = this.__redOffset;
					vectorData[++this.__position] = this.__greenOffset;
					vectorData[++this.__position] = this.__blueOffset;
					vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			
			// BOTTOM RIGHT
			vectorData[++this.__position] = this.__x + this.__x4;
			vectorData[++this.__position] = this.__y + this.__y4;
			if (this.__useColor)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__color;
				}
				else
				{
					vectorData[++this.__position] = this.__red;
					vectorData[++this.__position] = this.__green;
					vectorData[++this.__position] = this.__blue;
					vectorData[++this.__position] = this.__alpha;
				}
			}
			if (this.__useColorOffset)
			{
				if (this.__simpleColor)
				{
					vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					vectorData[++this.__position] = this.__redOffset;
					vectorData[++this.__position] = this.__greenOffset;
					vectorData[++this.__position] = this.__blueOffset;
					vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			
			++this.__position;
		}
		
		renderData.numQuads += this.__quadsWritten;
		renderData.position = this.__position;
		renderData.totalQuads += this.__quadsWritten;
		
		if (this.numDatas == this.__totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this.__numQuads;
			return false;
		}
	}
	
	/**
	   @inheritDoc
	**/
	public function writeBoundsData(boundsData:#if flash Vector<Float> #else Array<Float> #end, renderOffsetX:Float, renderOffsetY:Float):Void
	{
		this.__position = boundsData.length;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in 0...this.numDatas)
		{
			this.__data = this._datas[i];
			if (!this.__data.visible) continue;
			
			this.__x = this.__data.x + this.__data.offsetX + renderOffsetX;
			this.__y = this.__data.y + this.__data.offsetY + renderOffsetY;
			
			if (this.__data._transformChanged)
			{
				this.__rotationChanged = this.__data._rotationChanged;
				this.__skewXChanged = this.__data._skewXChanged;
				this.__skewYChanged = this.__data._skewYChanged;
				
				if (this.__rotationChanged)
				{
					this.__rotation = this.__data._rotation;
					this.__cosRotation = this.__data._cosRotation = Math.cos(this.__rotation);
					this.__sinRotation = this.__data._sinRotation = Math.sin(this.__rotation);
					this.__data._rotationChanged = false;
				}
				else
				{
					this.__cosRotation = this.__data._cosRotation;
					this.__sinRotation = this.__data._sinRotation;
				}
				
				if (this.__skewXChanged)
				{
					this.__skewX = this.__data._skewX;
					this.__cosSkewX = this.__data._cosSkewX = Math.cos(this.__skewX);
					this.__sinSkewX = this.__data._sinSkewX = -Math.sin(this.__skewX);
					this.__data._skewXChanged = false;
				}
				else
				{
					this.__cosSkewX = this.__data._cosSkewX;
					this.__sinSkewX = this.__data._sinSkewX;
				}
				
				if (this.__skewYChanged)
				{
					this.__skewY = this.__data._skewY;
					this.__cosSkewY = this.__data._cosSkewY = Math.cos(this.__skewY);
					this.__sinSkewY = this.__data._sinSkewY = Math.sin(this.__skewY);
					this.__data._skewYChanged = false;
				}
				else
				{
					this.__cosSkewY = this.__data._cosSkewY;
					this.__sinSkewY = this.__data._sinSkewY;
				}
				
				if (this.__data._sizeXChanged)
				{
					this.__data._leftOffset = this.__data.leftWidth * this.__data._scaleX;
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset = this.__data.rightWidth * this.__data._scaleX;
					this.__data._sizeXChanged = false;
				}
				else
				{
					this.__leftOffset = -this.__data._leftOffset;
					this.__rightOffset = this.__data._rightOffset;
				}
				
				if (this.__data._sizeYChanged)
				{
					this.__data._topOffset = this.__data.topHeight * this.__data._scaleY;
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset = this.__data.bottomHeight * this.__data._scaleY;
					this.__data._sizeYChanged = false;
				}
				else
				{
					this.__topOffset = -this.__data._topOffset;
					this.__bottomOffset = this.__data._bottomOffset;
				}
				
				this.__data._transformChanged = false;
				
				if (this.__rotationChanged || this.__skewXChanged || this.__skewYChanged)
				{
					this.__a = this.__data._a = this.__cosSkewY * this.__cosRotation - this.__sinSkewY * this.__sinRotation;
					this.__b = this.__data._b = this.__cosSkewY * this.__sinRotation + this.__sinSkewY * this.__cosRotation;
					this.__c = this.__data._c = this.__sinSkewX * this.__cosRotation - this.__cosSkewX * this.__sinRotation;
					this.__d = this.__data._d = this.__sinSkewX * this.__sinRotation + this.__cosSkewX * this.__cosRotation;
				}
				else
				{
					this.__a = this.__data._a;
					this.__b = this.__data._b;
					this.__c = this.__data._c;
					this.__d = this.__data._d;
				}
				
				this.__x1 = this.__data._x1 = this.__leftOffset * this.__a + this.__topOffset * this.__c;
				this.__y1 = this.__data._y1 = this.__leftOffset * this.__b + this.__topOffset * this.__d;
				this.__x2 = this.__data._x2 = this.__rightOffset * this.__a + this.__topOffset * this.__c;
				this.__y2 = this.__data._y2 = this.__rightOffset * this.__b + this.__topOffset * this.__d;
				this.__x3 = this.__data._x3 = this.__leftOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y3 = this.__data._y3 = this.__leftOffset * this.__b + this.__bottomOffset * this.__d;
				this.__x4 = this.__data._x4 = this.__rightOffset * this.__a + this.__bottomOffset * this.__c;
				this.__y4 = this.__data._y4 = this.__rightOffset * this.__b + this.__bottomOffset * this.__d;
			}
			else
			{
				this.__x1 = this.__data._x1;
				this.__y1 = this.__data._y1;
				this.__x2 = this.__data._x2;
				this.__y2 = this.__data._y2;
				this.__x3 = this.__data._x3;
				this.__y3 = this.__data._y3;
				this.__x4 = this.__data._x4;
				this.__y4 = this.__data._y4;
			}
			
			boundsData[this.__position]   = this.__x + this.__x1;
			boundsData[++this.__position] = this.__y + this.__y1;
			boundsData[++this.__position] = this.__x + this.__x2;
			boundsData[++this.__position] = this.__y + this.__y2;
			boundsData[++this.__position] = this.__x + this.__x3;
			boundsData[++this.__position] = this.__y + this.__y3;
			boundsData[++this.__position] = this.__x + this.__x4;
			boundsData[++this.__position] = this.__y + this.__y4;
			
			++this.__position;
		}
	}
	
}