package massive.display;

import haxe.io.FPHelper;
import massive.animation.Animator;
import massive.data.Frame;
import massive.data.ImageData;
import massive.util.MathUtils;
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end
#if flash
import openfl.Memory;
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
	
	/**
	   Tells whether this layer should animate textures or not.
	   If you are displaying non-animated images, consider setting this to false for better performance
	   @default true
	**/
	public var textureAnimation:Bool = true;
	
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
	public function dispose(poolData:Bool = true):Void 
	{
		if (poolData)
		{
			removeAllData(poolData);
		}
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
		if (index != -1) removeImageAt(index);
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
			if (index != -1) removeImageAt(index);
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
		if (this.textureAnimation) Animator.animateImageDataList(this._datas, time);
	}
	
	private var _x:Float;
	private var _y:Float;
	private var _leftOffset:Float;
	private var _rightOffset:Float;
	private var _topOffset:Float;
	private var _bottomOffset:Float;
	private var _rotation:Float;
	private var _skewX:Float;
	private var _skewY:Float;
	private var _red:Float;
	private var _redOffset:Float;
	private var _green:Float;
	private var _greenOffset:Float;
	private var _blue:Float;
	private var _blueOffset:Float;
	private var _alpha:Float;
	private var _alphaOffset:Float;
	private var _color:Int;
	private var _colorOffset:Int;
	private var _frame:Frame;
	private var _cosRotation:Float;
	private var _sinRotation:Float;
	private var _cosSkewX:Float;
	private var _sinSkewX:Float;
	private var _cosSkewY:Float;
	private var _sinSkewY:Float;
	private var _a:Float;
	private var _b:Float;
	private var _c:Float;
	private var _d:Float;
	private var _u1:Float;
	private var _u2:Float;
	private var _v1:Float;
	private var _v2:Float;
	private var _x1:Float;
	private var _y1:Float;
	private var _x2:Float;
	private var _y2:Float;
	private var _x3:Float;
	private var _y3:Float;
	private var _x4:Float;
	private var _y4:Float;
	private var _rotationChanged:Bool;
	private var _skewXChanged:Bool;
	private var _skewYChanged:Bool;
	
	private var _multiTexturing:Bool;
	private var _position:Int;
	private var _quadsWritten:Int;
	private var _pma:Bool;
	private var _useColor:Bool;
	private var _useColorOffset:Bool;
	private var _simpleColor:Bool;
	private var _numQuads:Int;
	private var _totalQuads:Int;
	private var _storeBounds:Bool;
	private var _boundsIndex:Int;
	private var _data:T;
	
	/**
	   @inheritDoc
	**/
	public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Bool
	{
		if (this._datas == null) return true;
		
		this._quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this._multiTexturing = renderData.multiTexturing;
		this._pma = renderData.pma;
		this._useColor = renderData.useColor;
		this._useColorOffset = renderData.useColorOffset;
		this._simpleColor = renderData.useSimpleColor;
		this._numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this._totalQuads = renderData.quadOffset + this._numQuads;
		this._storeBounds = boundsData != null;
		this._boundsIndex = this._storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in renderData.quadOffset...this._totalQuads)
		{
			this._data = this._datas[i];
			if (!this._data.visible) continue;
			
			++this._quadsWritten;
			
			this._x = this._data.x + this._data.offsetX + renderOffsetX;
			this._y = this._data.y + this._data.offsetY + renderOffsetY;
			
			this._frame = this._data.frameList[this._data.frameIndex];
			
			if (this._data._transformChanged)
			{
				this._rotationChanged = this._data._rotationChanged;
				this._skewXChanged = this._data._skewXChanged;
				this._skewYChanged = this._data._skewYChanged;
				
				if (this._rotationChanged)
				{
					this._rotation = this._data._rotation;
					this._cosRotation = this._data._cosRotation = Math.cos(this._rotation);
					this._sinRotation = this._data._sinRotation = Math.sin(this._rotation);
					this._data._rotationChanged = false;
				}
				else
				{
					this._cosRotation = this._data._cosRotation;
					this._sinRotation = this._data._sinRotation;
				}
				
				if (this._skewXChanged)
				{
					this._skewX = this._data._skewX;
					this._cosSkewX = this._data._cosSkewX = Math.cos(this._skewX);
					this._sinSkewX = this._data._sinSkewX = -Math.sin(this._skewX);
					this._data._skewXChanged = false;
				}
				else
				{
					this._cosSkewX = this._data._cosSkewX;
					this._sinSkewX = this._data._sinSkewX;
				}
				
				if (this._skewYChanged)
				{
					this._skewY = this._data._skewY;
					this._cosSkewY = this._data._cosSkewY = Math.cos(this._skewY);
					this._sinSkewY = this._data._sinSkewY = Math.sin(this._skewY);
					this._data._skewYChanged = false;
				}
				else
				{
					this._cosSkewY = this._data._cosSkewY;
					this._sinSkewY = this._data._sinSkewY;
				}
				
				if (this._data._sizeXChanged)
				{
					if (this._data._invertX)
					{
						this._data._leftOffset = this._frame.rightWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.leftWidth * this._data._scaleX;
					}
					else
					{
						this._data._leftOffset = this._frame.leftWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.rightWidth * this._data._scaleX;
					}
					this._data._sizeXChanged = false;
				}
				else
				{
					this._leftOffset = -this._data._leftOffset;
					this._rightOffset = this._data._rightOffset;
				}
				
				if (this._data._sizeYChanged)
				{
					if (this._data.invertY)
					{
						this._data._topOffset = this._frame.bottomHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.topHeight * this._data._scaleY;
					}
					else
					{
						this._data._topOffset = this._frame.topHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.bottomHeight * this._data._scaleY;
					}
					this._data._sizeYChanged = false;
				}
				else
				{
					this._topOffset = -this._data._topOffset;
					this._bottomOffset = this._data._bottomOffset;
				}
				
				this._data._transformChanged = false;
				
				if (this._rotationChanged || this._skewXChanged || this._skewYChanged)
				{
					this._a = this._data._a = this._cosSkewY * this._cosRotation - this._sinSkewY * this._sinRotation;
					this._b = this._data._b = this._cosSkewY * this._sinRotation + this._sinSkewY * this._cosRotation;
					this._c = this._data._c = this._sinSkewX * this._cosRotation - this._cosSkewX * this._sinRotation;
					this._d = this._data._d = this._sinSkewX * this._sinRotation + this._cosSkewX * this._cosRotation;
				}
				else
				{
					this._a = this._data._a;
					this._b = this._data._b;
					this._c = this._data._c;
					this._d = this._data._d;
				}
				
				this._x1 = this._data._x1 = this._leftOffset * this._a + this._topOffset * this._c;
				this._y1 = this._data._y1 = this._leftOffset * this._b + this._topOffset * this._d;
				this._x2 = this._data._x2 = this._rightOffset * this._a + this._topOffset * this._c;
				this._y2 = this._data._y2 = this._rightOffset * this._b + this._topOffset * this._d;
				this._x3 = this._data._x3 = this._leftOffset * this._a + this._bottomOffset * this._c;
				this._y3 = this._data._y3 = this._leftOffset * this._b + this._bottomOffset * this._d;
				this._x4 = this._data._x4 = this._rightOffset * this._a + this._bottomOffset * this._c;
				this._y4 = this._data._y4 = this._rightOffset * this._b + this._bottomOffset * this._d;
			}
			else
			{
				this._x1 = this._data._x1;
				this._y1 = this._data._y1;
				this._x2 = this._data._x2;
				this._y2 = this._data._y2;
				this._x3 = this._data._x3;
				this._y3 = this._data._y3;
				this._x4 = this._data._x4;
				this._y4 = this._data._y4;
			}
			
			if (this._data._invertX)
			{
				this._u1 = this._frame.u2;
				this._u2 = this._frame.u1;
			}
			else
			{
				this._u1 = this._frame.u1;
				this._u2 = this._frame.u2;
			}
			
			if (this._data._invertY)
			{
				this._v1 = this._frame.v2;
				this._v2 = this._frame.v1;
			}
			else
			{
				this._v1 = this._frame.v1;
				this._v2 = this._frame.v2;
			}
			
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					this._alpha = this._data.alpha;
					this._alpha = this._alpha < 0.0 ? 0.0 : this._alpha > 1.0 ? 1.0 : this._alpha;
					this._red = this._data.red;
					this._red = this._red < 0.0 ? 0.0 : this._red > 1.0 ? 1.0 : this._red;
					this._green = this._data.green;
					this._green = this._green < 0.0 ? 0.0 : this._green > 1.0 ? 1.0 : this._green;
					this._blue = this._data.blue;
					this._blue = this._blue < 0.0 ? 0.0 : this._blue > 1.0 ? 1.0 : this._blue;
					if (this._pma)
					{
						this._color = Std.int(this._red * this._alpha * 255) | Std.int(this._green * this._alpha * 255) << 8 | Std.int(this._blue * this._alpha * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
					else
					{
						this._color = Std.int(this._red * 255) | Std.int(this._green * 255) << 8 | Std.int(this._blue * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
				}
				else
				{
					this._alpha = this._data.alpha;
					if (this._pma)
					{
						this._red = this._data.red * this._alpha;
						this._green = this._data.green * this._alpha;
						this._blue = this._data.blue * this._alpha;
					}
					else
					{
						this._red = this._data.red;
						this._green = this._data.green;
						this._blue = this._data.blue;
					}
				}
			}
			
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					this._alphaOffset = this._data.alphaOffset;
					this._alphaOffset = this._alphaOffset < 0.0 ? 0.0 : this._alphaOffset > 1.0 ? 1.0 : this._alphaOffset;
					this._redOffset = this._data.redOffset;
					this._redOffset = this._redOffset < 0.0 ? 0.0 : this._redOffset > 1.0 ? 1.0 : this._redOffset;
					this._greenOffset = this._data.greenOffset;
					this._greenOffset = this._greenOffset < 0.0 ? 0.0 : this._greenOffset > 1.0 ? 1.0 : this._greenOffset;
					this._blueOffset = this._data.blueOffset;
					this._blueOffset = this._blueOffset < 0.0 ? 0.0 : this._blueOffset > 1.0 ? 1.0 : this._blueOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._colorOffset = Std.int(this._redOffset * 255) | Std.int(this._greenOffset * 255) << 8 | Std.int(this._blueOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
					else
					{
						this._colorOffset = Std.int(this._redOffset * this._alphaOffset * 255) | Std.int(this._greenOffset * this._alphaOffset * 255) << 8 | Std.int(this._blueOffset * this._alphaOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
				}
				else
				{
					this._alphaOffset = this._data.alphaOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._redOffset = this._data.redOffset;
						this._greenOffset = this._data.greenOffset;
						this._blueOffset = this._data.blueOffset;
					}
					else
					{
						this._redOffset = this._data.redOffset * this._alphaOffset;
						this._greenOffset = this._data.greenOffset * this._alphaOffset;
						this._blueOffset = this._data.blueOffset * this._alphaOffset;
					}
				}
			}
			
			if (this._storeBounds)
			{
				boundsData[++this._boundsIndex] = this._x + this._x1;
				boundsData[++this._boundsIndex] = this._y + this._y1;
				boundsData[++this._boundsIndex] = this._x + this._x2;
				boundsData[++this._boundsIndex] = this._y + this._y2;
				boundsData[++this._boundsIndex] = this._x + this._x3;
				boundsData[++this._boundsIndex] = this._y + this._y3;
				boundsData[++this._boundsIndex] = this._x + this._x4;
				boundsData[++this._boundsIndex] = this._y + this._y4;
			}
			
			// TOP LEFT
			// u1 v1
			byteData.writeFloat(this._x + this._x1);
			byteData.writeFloat(this._y + this._y1);
			byteData.writeFloat(this._u1);
			byteData.writeFloat(this._v1);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._color);
				}
				else
				{
					byteData.writeFloat(this._red);
					byteData.writeFloat(this._green);
					byteData.writeFloat(this._blue);
					byteData.writeFloat(this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._colorOffset);
				}
				else
				{
					byteData.writeFloat(this._redOffset);
					byteData.writeFloat(this._greenOffset);
					byteData.writeFloat(this._blueOffset);
					byteData.writeFloat(this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				byteData.writeFloat(this._data.textureIndexReal);
			}
			
			// TOP RIGHT
			// u2 v1
			byteData.writeFloat(this._x + this._x2);
			byteData.writeFloat(this._y + this._y2);
			byteData.writeFloat(this._u2);
			byteData.writeFloat(this._v1);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._color);
				}
				else
				{
					byteData.writeFloat(this._red);
					byteData.writeFloat(this._green);
					byteData.writeFloat(this._blue);
					byteData.writeFloat(this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._colorOffset);
				}
				else
				{
					byteData.writeFloat(this._redOffset);
					byteData.writeFloat(this._greenOffset);
					byteData.writeFloat(this._blueOffset);
					byteData.writeFloat(this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				byteData.writeFloat(this._data.textureIndexReal);
			}
			
			// BOTTOM LEFT
			// u1 v2
			byteData.writeFloat(this._x + this._x3);
			byteData.writeFloat(this._y + this._y3);
			byteData.writeFloat(this._u1);
			byteData.writeFloat(this._v2);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._color);
				}
				else
				{
					byteData.writeFloat(this._red);
					byteData.writeFloat(this._green);
					byteData.writeFloat(this._blue);
					byteData.writeFloat(this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._colorOffset);
				}
				else
				{
					byteData.writeFloat(this._redOffset);
					byteData.writeFloat(this._greenOffset);
					byteData.writeFloat(this._blueOffset);
					byteData.writeFloat(this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				byteData.writeFloat(this._data.textureIndexReal);
			}
			
			// BOTTOM RIGHT
			// u2 v2
			byteData.writeFloat(this._x + this._x4);
			byteData.writeFloat(this._y + this._y4);
			byteData.writeFloat(this._u2);
			byteData.writeFloat(this._v2);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._color);
				}
				else
				{
					byteData.writeFloat(this._red);
					byteData.writeFloat(this._green);
					byteData.writeFloat(this._blue);
					byteData.writeFloat(this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					byteData.writeInt(this._colorOffset);
				}
				else
				{
					byteData.writeFloat(this._redOffset);
					byteData.writeFloat(this._greenOffset);
					byteData.writeFloat(this._blueOffset);
					byteData.writeFloat(this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				byteData.writeFloat(this._data.textureIndexReal);
			}
		}
		
		renderData.numQuads += this._quadsWritten;
		renderData.totalQuads += this._quadsWritten;
		
		if (this.numDatas == this._totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this._numQuads;
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
		
		this._position = renderData.position;
		this._quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this._multiTexturing = renderData.multiTexturing;
		this._pma = renderData.pma;
		this._useColor = renderData.useColor;
		this._useColorOffset = renderData.useColorOffset;
		this._simpleColor = renderData.useSimpleColor;
		this._numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this._totalQuads = renderData.quadOffset + this._numQuads;
		this._storeBounds = boundsData != null;
		this._boundsIndex = this._storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in renderData.quadOffset...this._totalQuads)
		{
			this._data = this._datas[i];
			if (!this._data.visible) continue;
			
			++this._quadsWritten;
			
			this._x = this._data.x + this._data.offsetX + renderOffsetX;
			this._y = this._data.y + this._data.offsetY + renderOffsetY;
			
			this._frame = this._data.frameList[this._data.frameIndex];
			
			if (this._data._transformChanged)
			{
				this._rotationChanged = this._data._rotationChanged;
				this._skewXChanged = this._data._skewXChanged;
				this._skewYChanged = this._data._skewYChanged;
				
				if (this._rotationChanged)
				{
					this._rotation = this._data._rotation;
					this._cosRotation = this._data._cosRotation = Math.cos(this._rotation);
					this._sinRotation = this._data._sinRotation = Math.sin(this._rotation);
					this._data._rotationChanged = false;
				}
				else
				{
					this._cosRotation = this._data._cosRotation;
					this._sinRotation = this._data._sinRotation;
				}
				
				if (this._skewXChanged)
				{
					this._skewX = this._data._skewX;
					this._cosSkewX = this._data._cosSkewX = Math.cos(this._skewX);
					this._sinSkewX = this._data._sinSkewX = -Math.sin(this._skewX);
					this._data._skewXChanged = false;
				}
				else
				{
					this._cosSkewX = this._data._cosSkewX;
					this._sinSkewX = this._data._sinSkewX;
				}
				
				if (this._skewYChanged)
				{
					this._skewY = this._data._skewY;
					this._cosSkewY = this._data._cosSkewY = Math.cos(this._skewY);
					this._sinSkewY = this._data._sinSkewY = Math.sin(this._skewY);
					this._data._skewYChanged = false;
				}
				else
				{
					this._cosSkewY = this._data._cosSkewY;
					this._sinSkewY = this._data._sinSkewY;
				}
				
				if (this._data._sizeXChanged)
				{
					if (this._data._invertX)
					{
						this._data._leftOffset = this._frame.rightWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.leftWidth * this._data._scaleX;
					}
					else
					{
						this._data._leftOffset = this._frame.leftWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.rightWidth * this._data._scaleX;
					}
					this._data._sizeXChanged = false;
				}
				else
				{
					this._leftOffset = -this._data._leftOffset;
					this._rightOffset = this._data._rightOffset;
				}
				
				if (this._data._sizeYChanged)
				{
					if (this._data.invertY)
					{
						this._data._topOffset = this._frame.bottomHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.topHeight * this._data._scaleY;
					}
					else
					{
						this._data._topOffset = this._frame.topHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.bottomHeight * this._data._scaleY;
					}
					this._data._sizeYChanged = false;
				}
				else
				{
					this._topOffset = -this._data._topOffset;
					this._bottomOffset = this._data._bottomOffset;
				}
				
				this._data._transformChanged = false;
				
				if (this._rotationChanged || this._skewXChanged || this._skewYChanged)
				{
					this._a = this._data._a = this._cosSkewY * this._cosRotation - this._sinSkewY * this._sinRotation;
					this._b = this._data._b = this._cosSkewY * this._sinRotation + this._sinSkewY * this._cosRotation;
					this._c = this._data._c = this._sinSkewX * this._cosRotation - this._cosSkewX * this._sinRotation;
					this._d = this._data._d = this._sinSkewX * this._sinRotation + this._cosSkewX * this._cosRotation;
				}
				else
				{
					this._a = this._data._a;
					this._b = this._data._b;
					this._c = this._data._c;
					this._d = this._data._d;
				}
				
				this._x1 = this._data._x1 = this._leftOffset * this._a + this._topOffset * this._c;
				this._y1 = this._data._y1 = this._leftOffset * this._b + this._topOffset * this._d;
				this._x2 = this._data._x2 = this._rightOffset * this._a + this._topOffset * this._c;
				this._y2 = this._data._y2 = this._rightOffset * this._b + this._topOffset * this._d;
				this._x3 = this._data._x3 = this._leftOffset * this._a + this._bottomOffset * this._c;
				this._y3 = this._data._y3 = this._leftOffset * this._b + this._bottomOffset * this._d;
				this._x4 = this._data._x4 = this._rightOffset * this._a + this._bottomOffset * this._c;
				this._y4 = this._data._y4 = this._rightOffset * this._b + this._bottomOffset * this._d;
			}
			else
			{
				this._x1 = this._data._x1;
				this._y1 = this._data._y1;
				this._x2 = this._data._x2;
				this._y2 = this._data._y2;
				this._x3 = this._data._x3;
				this._y3 = this._data._y3;
				this._x4 = this._data._x4;
				this._y4 = this._data._y4;
			}
			
			if (this._data._invertX)
			{
				this._u1 = this._frame.u2;
				this._u2 = this._frame.u1;
			}
			else
			{
				this._u1 = this._frame.u1;
				this._u2 = this._frame.u2;
			}
			
			if (this._data._invertY)
			{
				this._v1 = this._frame.v2;
				this._v2 = this._frame.v1;
			}
			else
			{
				this._v1 = this._frame.v1;
				this._v2 = this._frame.v2;
			}
			
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					this._alpha = this._data.alpha;
					this._alpha = this._alpha < 0.0 ? 0.0 : this._alpha > 1.0 ? 1.0 : this._alpha;
					this._red = this._data.red;
					this._red = this._red < 0.0 ? 0.0 : this._red > 1.0 ? 1.0 : this._red;
					this._green = this._data.green;
					this._green = this._green < 0.0 ? 0.0 : this._green > 1.0 ? 1.0 : this._green;
					this._blue = this._data.blue;
					this._blue = this._blue < 0.0 ? 0.0 : this._blue > 1.0 ? 1.0 : this._blue;
					if (this._pma)
					{
						this._color = Std.int(this._red * this._alpha * 255) | Std.int(this._green * this._alpha * 255) << 8 | Std.int(this._blue * this._alpha * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
					else
					{
						this._color = Std.int(this._red * 255) | Std.int(this._green * 255) << 8 | Std.int(this._blue * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
				}
				else
				{
					this._alpha = this._data.alpha;
					if (this._pma)
					{
						this._red = this._data.red * this._alpha;
						this._green = this._data.green * this._alpha;
						this._blue = this._data.blue * this._alpha;
					}
					else
					{
						this._red = this._data.red;
						this._green = this._data.green;
						this._blue = this._data.blue;
					}
				}
			}
			
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					this._alphaOffset = this._data.alphaOffset;
					this._alphaOffset = this._alphaOffset < 0.0 ? 0.0 : this._alphaOffset > 1.0 ? 1.0 : this._alphaOffset;
					this._redOffset = this._data.redOffset;
					this._redOffset = this._redOffset < 0.0 ? 0.0 : this._redOffset > 1.0 ? 1.0 : this._redOffset;
					this._greenOffset = this._data.greenOffset;
					this._greenOffset = this._greenOffset < 0.0 ? 0.0 : this._greenOffset > 1.0 ? 1.0 : this._greenOffset;
					this._blueOffset = this._data.blueOffset;
					this._blueOffset = this._blueOffset < 0.0 ? 0.0 : this._blueOffset > 1.0 ? 1.0 : this._blueOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._colorOffset = Std.int(this._redOffset * 255) | Std.int(this._greenOffset * 255) << 8 | Std.int(this._blueOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
					else
					{
						this._colorOffset = Std.int(this._redOffset * this._alphaOffset * 255) | Std.int(this._greenOffset * this._alphaOffset * 255) << 8 | Std.int(this._blueOffset * this._alphaOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
				}
				else
				{
					this._alphaOffset = this._data.alphaOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._redOffset = this._data.redOffset;
						this._greenOffset = this._data.greenOffset;
						this._blueOffset = this._data.blueOffset;
					}
					else
					{
						this._redOffset = this._data.redOffset * this._alphaOffset;
						this._greenOffset = this._data.greenOffset * this._alphaOffset;
						this._blueOffset = this._data.blueOffset * this._alphaOffset;
					}
				}
			}
			
			if (this._storeBounds)
			{
				boundsData[++this._boundsIndex] = this._x + this._x1;
				boundsData[++this._boundsIndex] = this._y + this._y1;
				boundsData[++this._boundsIndex] = this._x + this._x2;
				boundsData[++this._boundsIndex] = this._y + this._y2;
				boundsData[++this._boundsIndex] = this._x + this._x3;
				boundsData[++this._boundsIndex] = this._y + this._y3;
				boundsData[++this._boundsIndex] = this._x + this._x4;
				boundsData[++this._boundsIndex] = this._y + this._y4;
			}
			
			// TOP LEFT
			// u1 v1
			Memory.setFloat(this._position, this._x + this._x1);
			Memory.setFloat(this._position += 4, this._y + this._y1);
			Memory.setFloat(this._position += 4, this._u1);
			Memory.setFloat(this._position += 4, this._v1);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._color);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._red);
					Memory.setFloat(this._position += 4, this._green);
					Memory.setFloat(this._position += 4, this._blue);
					Memory.setFloat(this._position += 4, this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._colorOffset);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._redOffset);
					Memory.setFloat(this._position += 4, this._greenOffset);
					Memory.setFloat(this._position += 4, this._blueOffset);
					Memory.setFloat(this._position += 4, this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				Memory.setFloat(this._position += 4, this._data.textureIndexReal);
			}
			
			// TOP RIGHT
			// u2 v1
			Memory.setFloat(this._position += 4, this._x + this._x2);
			Memory.setFloat(this._position += 4, this._y + this._y2);
			Memory.setFloat(this._position += 4, this._u2);
			Memory.setFloat(this._position += 4, this._v1);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._color);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._red);
					Memory.setFloat(this._position += 4, this._green);
					Memory.setFloat(this._position += 4, this._blue);
					Memory.setFloat(this._position += 4, this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._colorOffset);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._redOffset);
					Memory.setFloat(this._position += 4, this._greenOffset);
					Memory.setFloat(this._position += 4, this._blueOffset);
					Memory.setFloat(this._position += 4, this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				Memory.setFloat(this._position += 4, this._data.textureIndexReal);
			}
			
			// BOTTOM LEFT
			// u1 v2
			Memory.setFloat(this._position += 4, this._x + this._x3);
			Memory.setFloat(this._position += 4, this._y + this._y3);
			Memory.setFloat(this._position += 4, this._u1);
			Memory.setFloat(this._position += 4, this._v2);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._color);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._red);
					Memory.setFloat(this._position += 4, this._green);
					Memory.setFloat(this._position += 4, this._blue);
					Memory.setFloat(this._position += 4, this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._colorOffset);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._redOffset);
					Memory.setFloat(this._position += 4, this._greenOffset);
					Memory.setFloat(this._position += 4, this._blueOffset);
					Memory.setFloat(this._position += 4, this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				Memory.setFloat(this._position += 4, this._data.textureIndexReal);
			}
			
			// BOTTOM RIGHT
			// u2 v2
			Memory.setFloat(this._position += 4, this._x + this._x4);
			Memory.setFloat(this._position += 4, this._y + this._y4);
			Memory.setFloat(this._position += 4, this._u2);
			Memory.setFloat(this._position += 4, this._v2);
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._color);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._red);
					Memory.setFloat(this._position += 4, this._green);
					Memory.setFloat(this._position += 4, this._blue);
					Memory.setFloat(this._position += 4, this._alpha);
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					Memory.setI32(this._position += 4, this._colorOffset);
				}
				else
				{
					Memory.setFloat(this._position += 4, this._redOffset);
					Memory.setFloat(this._position += 4, this._greenOffset);
					Memory.setFloat(this._position += 4, this._blueOffset);
					Memory.setFloat(this._position += 4, this._alphaOffset);
				}
			}
			if (this._multiTexturing)
			{
				Memory.setFloat(this._position += 4, this._data.textureIndexReal);
			}
			
			this._position += 4;
		}
		
		renderData.numQuads += this._quadsWritten;
		renderData.position = this._position;
		renderData.totalQuads += this._quadsWritten;
		
		if (this.numDatas == this._totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this._numQuads;
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
		
		this._position = renderData.position;
		this._quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this._multiTexturing = renderData.multiTexturing;
		this._pma = renderData.pma;
		this._useColor = renderData.useColor;
		this._useColorOffset = renderData.useColorOffset;
		this._simpleColor = renderData.useSimpleColor;
		this._numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this._totalQuads = renderData.quadOffset + this._numQuads;
		this._storeBounds = boundsData != null;
		this._boundsIndex = this._storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in renderData.quadOffset...this._totalQuads)
		{
			this._data = this._datas[i];
			if (!this._data.visible) continue;
			
			++this._quadsWritten;
			
			this._x = this._data.x + this._data.offsetX + renderOffsetX;
			this._y = this._data.y + this._data.offsetY + renderOffsetY;
			
			this._frame = this._data.frameList[this._data.frameIndex];
			
			if (this._data._transformChanged)
			{
				this._rotationChanged = this._data._rotationChanged;
				this._skewXChanged = this._data._skewXChanged;
				this._skewYChanged = this._data._skewYChanged;
				
				if (this._rotationChanged)
				{
					this._rotation = this._data._rotation;
					this._cosRotation = this._data._cosRotation = Math.cos(this._rotation);
					this._sinRotation = this._data._sinRotation = Math.sin(this._rotation);
					this._data._rotationChanged = false;
				}
				else
				{
					this._cosRotation = this._data._cosRotation;
					this._sinRotation = this._data._sinRotation;
				}
				
				if (this._skewXChanged)
				{
					this._skewX = this._data._skewX;
					this._cosSkewX = this._data._cosSkewX = Math.cos(this._skewX);
					this._sinSkewX = this._data._sinSkewX = -Math.sin(this._skewX);
					this._data._skewXChanged = false;
				}
				else
				{
					this._cosSkewX = this._data._cosSkewX;
					this._sinSkewX = this._data._sinSkewX;
				}
				
				if (this._skewYChanged)
				{
					this._skewY = this._data._skewY;
					this._cosSkewY = this._data._cosSkewY = Math.cos(this._skewY);
					this._sinSkewY = this._data._sinSkewY = Math.sin(this._skewY);
					this._data._skewYChanged = false;
				}
				else
				{
					this._cosSkewY = this._data._cosSkewY;
					this._sinSkewY = this._data._sinSkewY;
				}
				
				if (this._data._sizeXChanged)
				{
					if (this._data._invertX)
					{
						this._data._leftOffset = this._frame.rightWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.leftWidth * this._data._scaleX;
					}
					else
					{
						this._data._leftOffset = this._frame.leftWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.rightWidth * this._data._scaleX;
					}
					this._data._sizeXChanged = false;
				}
				else
				{
					this._leftOffset = -this._data._leftOffset;
					this._rightOffset = this._data._rightOffset;
				}
				
				if (this._data._sizeYChanged)
				{
					if (this._data.invertY)
					{
						this._data._topOffset = this._frame.bottomHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.topHeight * this._data._scaleY;
					}
					else
					{
						this._data._topOffset = this._frame.topHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.bottomHeight * this._data._scaleY;
					}
					this._data._sizeYChanged = false;
				}
				else
				{
					this._topOffset = -this._data._topOffset;
					this._bottomOffset = this._data._bottomOffset;
				}
				
				this._data._transformChanged = false;
				
				if (this._rotationChanged || this._skewXChanged || this._skewYChanged)
				{
					this._a = this._data._a = this._cosSkewY * this._cosRotation - this._sinSkewY * this._sinRotation;
					this._b = this._data._b = this._cosSkewY * this._sinRotation + this._sinSkewY * this._cosRotation;
					this._c = this._data._c = this._sinSkewX * this._cosRotation - this._cosSkewX * this._sinRotation;
					this._d = this._data._d = this._sinSkewX * this._sinRotation + this._cosSkewX * this._cosRotation;
				}
				else
				{
					this._a = this._data._a;
					this._b = this._data._b;
					this._c = this._data._c;
					this._d = this._data._d;
				}
				
				this._x1 = this._data._x1 = this._leftOffset * this._a + this._topOffset * this._c;
				this._y1 = this._data._y1 = this._leftOffset * this._b + this._topOffset * this._d;
				this._x2 = this._data._x2 = this._rightOffset * this._a + this._topOffset * this._c;
				this._y2 = this._data._y2 = this._rightOffset * this._b + this._topOffset * this._d;
				this._x3 = this._data._x3 = this._leftOffset * this._a + this._bottomOffset * this._c;
				this._y3 = this._data._y3 = this._leftOffset * this._b + this._bottomOffset * this._d;
				this._x4 = this._data._x4 = this._rightOffset * this._a + this._bottomOffset * this._c;
				this._y4 = this._data._y4 = this._rightOffset * this._b + this._bottomOffset * this._d;
			}
			else
			{
				this._x1 = this._data._x1;
				this._y1 = this._data._y1;
				this._x2 = this._data._x2;
				this._y2 = this._data._y2;
				this._x3 = this._data._x3;
				this._y3 = this._data._y3;
				this._x4 = this._data._x4;
				this._y4 = this._data._y4;
			}
			
			if (this._data._invertX)
			{
				this._u1 = this._frame.u2;
				this._u2 = this._frame.u1;
			}
			else
			{
				this._u1 = this._frame.u1;
				this._u2 = this._frame.u2;
			}
			
			if (this._data._invertY)
			{
				this._v1 = this._frame.v2;
				this._v2 = this._frame.v1;
			}
			else
			{
				this._v1 = this._frame.v1;
				this._v2 = this._frame.v2;
			}
			
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					this._alpha = this._data.alpha;
					this._alpha = this._alpha < 0.0 ? 0.0 : this._alpha > 1.0 ? 1.0 : this._alpha;
					this._red = this._data.red;
					this._red = this._red < 0.0 ? 0.0 : this._red > 1.0 ? 1.0 : this._red;
					this._green = this._data.green;
					this._green = this._green < 0.0 ? 0.0 : this._green > 1.0 ? 1.0 : this._green;
					this._blue = this._data.blue;
					this._blue = this._blue < 0.0 ? 0.0 : this._blue > 1.0 ? 1.0 : this._blue;
					if (this._pma)
					{
						this._color = Std.int(this._red * this._alpha * 255) | Std.int(this._green * this._alpha * 255) << 8 | Std.int(this._blue * this._alpha * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
					else
					{
						this._color = Std.int(this._red * 255) | Std.int(this._green * 255) << 8 | Std.int(this._blue * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
				}
				else
				{
					this._alpha = this._data.alpha;
					if (this._pma)
					{
						this._red = this._data.red * this._alpha;
						this._green = this._data.green * this._alpha;
						this._blue = this._data.blue * this._alpha;
					}
					else
					{
						this._red = this._data.red;
						this._green = this._data.green;
						this._blue = this._data.blue;
					}
				}
			}
			
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					this._alphaOffset = this._data.alphaOffset;
					this._alphaOffset = this._alphaOffset < 0.0 ? 0.0 : this._alphaOffset > 1.0 ? 1.0 : this._alphaOffset;
					this._redOffset = this._data.redOffset;
					this._redOffset = this._redOffset < 0.0 ? 0.0 : this._redOffset > 1.0 ? 1.0 : this._redOffset;
					this._greenOffset = this._data.greenOffset;
					this._greenOffset = this._greenOffset < 0.0 ? 0.0 : this._greenOffset > 1.0 ? 1.0 : this._greenOffset;
					this._blueOffset = this._data.blueOffset;
					this._blueOffset = this._blueOffset < 0.0 ? 0.0 : this._blueOffset > 1.0 ? 1.0 : this._blueOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._colorOffset = Std.int(this._redOffset * 255) | Std.int(this._greenOffset * 255) << 8 | Std.int(this._blueOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
					else
					{
						this._colorOffset = Std.int(this._redOffset * this._alphaOffset * 255) | Std.int(this._greenOffset * this._alphaOffset * 255) << 8 | Std.int(this._blueOffset * this._alphaOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
				}
				else
				{
					this._alphaOffset = this._data.alphaOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._redOffset = this._data.redOffset;
						this._greenOffset = this._data.greenOffset;
						this._blueOffset = this._data.blueOffset;
					}
					else
					{
						this._redOffset = this._data.redOffset * this._alphaOffset;
						this._greenOffset = this._data.greenOffset * this._alphaOffset;
						this._blueOffset = this._data.blueOffset * this._alphaOffset;
					}
				}
			}
			
			if (this._storeBounds)
			{
				boundsData[++this._boundsIndex] = this._x + this._x1;
				boundsData[++this._boundsIndex] = this._y + this._y1;
				boundsData[++this._boundsIndex] = this._x + this._x2;
				boundsData[++this._boundsIndex] = this._y + this._y2;
				boundsData[++this._boundsIndex] = this._x + this._x3;
				boundsData[++this._boundsIndex] = this._y + this._y3;
				boundsData[++this._boundsIndex] = this._x + this._x4;
				boundsData[++this._boundsIndex] = this._y + this._y4;
			}
			
			// TOP LEFT
			// u1 v1
			floatData[this._position] = this._x + this._x1;
			floatData[++this._position] = this._y + this._y1;
			floatData[++this._position] = this._u1;
			floatData[++this._position] = this._v1;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._color;
				}
				else
				{
					floatData[++this._position] = this._red;
					floatData[++this._position] = this._green;
					floatData[++this._position] = this._blue;
					floatData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._colorOffset;
				}
				else
				{
					floatData[++this._position] = this._redOffset;
					floatData[++this._position] = this._greenOffset;
					floatData[++this._position] = this._blueOffset;
					floatData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				floatData[++this._position] = this._data.textureIndexReal;
			}
			
			// TOP RIGHT
			// u2 v1
			floatData[++this._position] = this._x + this._x2;
			floatData[++this._position] = this._y + this._y2;
			floatData[++this._position] = this._u2;
			floatData[++this._position] = this._v1;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._color;
				}
				else
				{
					floatData[++this._position] = this._red;
					floatData[++this._position] = this._green;
					floatData[++this._position] = this._blue;
					floatData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._colorOffset;
				}
				else
				{
					floatData[++this._position] = this._redOffset;
					floatData[++this._position] = this._greenOffset;
					floatData[++this._position] = this._blueOffset;
					floatData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				floatData[++this._position] = this._data.textureIndexReal;
			}
			
			// BOTTOM LEFT
			// u1 v2
			floatData[++this._position] = this._x + this._x3;
			floatData[++this._position] = this._y + this._y3;
			floatData[++this._position] = this._u1;
			floatData[++this._position] = this._v2;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._color;
				}
				else
				{
					floatData[++this._position] = this._red;
					floatData[++this._position] = this._green;
					floatData[++this._position] = this._blue;
					floatData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._colorOffset;
				}
				else
				{
					floatData[++this._position] = this._redOffset;
					floatData[++this._position] = this._greenOffset;
					floatData[++this._position] = this._blueOffset;
					floatData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				floatData[++this._position] = this._data.textureIndexReal;
			}
			
			// BOTTOM RIGHT
			// u2 v2
			floatData[++this._position] = this._x + this._x4;
			floatData[++this._position] = this._y + this._y4;
			floatData[++this._position] = this._u2;
			floatData[++this._position] = this._v2;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._color;
				}
				else
				{
					floatData[++this._position] = this._red;
					floatData[++this._position] = this._green;
					floatData[++this._position] = this._blue;
					floatData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					floatData[++this._position] = this._colorOffset;
				}
				else
				{
					floatData[++this._position] = this._redOffset;
					floatData[++this._position] = this._greenOffset;
					floatData[++this._position] = this._blueOffset;
					floatData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				floatData[++this._position] = this._data.textureIndexReal;
			}
			
			++this._position;
		}
		
		renderData.numQuads += this._quadsWritten;
		renderData.position = this._position;
		renderData.totalQuads += this._quadsWritten;
		
		if (this.numDatas == this._totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this._numQuads;
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
		
		this._position = renderData.position;
		this._quadsWritten = 0;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this._multiTexturing = renderData.multiTexturing;
		this._pma = renderData.pma;
		this._useColor = renderData.useColor;
		this._useColorOffset = renderData.useColorOffset;
		this._simpleColor = renderData.useSimpleColor;
		this._numQuads = MathUtils.minInt(this.numDatas - renderData.quadOffset, maxQuads);
		this._totalQuads = renderData.quadOffset + this._numQuads;
		this._storeBounds = boundsData != null;
		this._boundsIndex = this._storeBounds ? boundsData.length - 1 : -1;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in renderData.quadOffset...this._totalQuads)
		{
			this._data = this._datas[i];
			if (!this._data.visible) continue;
			
			++this._quadsWritten;
			
			this._x = this._data.x + this._data.offsetX + renderOffsetX;
			this._y = this._data.y + this._data.offsetY + renderOffsetY;
			
			this._frame = this._data.frameList[this._data.frameIndex];
			
			if (this._data._transformChanged)
			{
				this._rotationChanged = this._data._rotationChanged;
				this._skewXChanged = this._data._skewXChanged;
				this._skewYChanged = this._data._skewYChanged;
				
				if (this._rotationChanged)
				{
					this._rotation = this._data._rotation;
					this._cosRotation = this._data._cosRotation = Math.cos(this._rotation);
					this._sinRotation = this._data._sinRotation = Math.sin(this._rotation);
					this._data._rotationChanged = false;
				}
				else
				{
					this._cosRotation = this._data._cosRotation;
					this._sinRotation = this._data._sinRotation;
				}
				
				if (this._skewXChanged)
				{
					this._skewX = this._data._skewX;
					this._cosSkewX = this._data._cosSkewX = Math.cos(this._skewX);
					this._sinSkewX = this._data._sinSkewX = -Math.sin(this._skewX);
					this._data._skewXChanged = false;
				}
				else
				{
					this._cosSkewX = this._data._cosSkewX;
					this._sinSkewX = this._data._sinSkewX;
				}
				
				if (this._skewYChanged)
				{
					this._skewY = this._data._skewY;
					this._cosSkewY = this._data._cosSkewY = Math.cos(this._skewY);
					this._sinSkewY = this._data._sinSkewY = Math.sin(this._skewY);
					this._data._skewYChanged = false;
				}
				else
				{
					this._cosSkewY = this._data._cosSkewY;
					this._sinSkewY = this._data._sinSkewY;
				}
				
				if (this._data._sizeXChanged)
				{
					if (this._data._invertX)
					{
						this._data._leftOffset = this._frame.rightWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.leftWidth * this._data._scaleX;
					}
					else
					{
						this._data._leftOffset = this._frame.leftWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.rightWidth * this._data._scaleX;
					}
					this._data._sizeXChanged = false;
				}
				else
				{
					this._leftOffset = -this._data._leftOffset;
					this._rightOffset = this._data._rightOffset;
				}
				
				if (this._data._sizeYChanged)
				{
					if (this._data.invertY)
					{
						this._data._topOffset = this._frame.bottomHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.topHeight * this._data._scaleY;
					}
					else
					{
						this._data._topOffset = this._frame.topHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.bottomHeight * this._data._scaleY;
					}
					this._data._sizeYChanged = false;
				}
				else
				{
					this._topOffset = -this._data._topOffset;
					this._bottomOffset = this._data._bottomOffset;
				}
				
				this._data._transformChanged = false;
				
				if (this._rotationChanged || this._skewXChanged || this._skewYChanged)
				{
					this._a = this._data._a = this._cosSkewY * this._cosRotation - this._sinSkewY * this._sinRotation;
					this._b = this._data._b = this._cosSkewY * this._sinRotation + this._sinSkewY * this._cosRotation;
					this._c = this._data._c = this._sinSkewX * this._cosRotation - this._cosSkewX * this._sinRotation;
					this._d = this._data._d = this._sinSkewX * this._sinRotation + this._cosSkewX * this._cosRotation;
				}
				else
				{
					this._a = this._data._a;
					this._b = this._data._b;
					this._c = this._data._c;
					this._d = this._data._d;
				}
				
				this._x1 = this._data._x1 = this._leftOffset * this._a + this._topOffset * this._c;
				this._y1 = this._data._y1 = this._leftOffset * this._b + this._topOffset * this._d;
				this._x2 = this._data._x2 = this._rightOffset * this._a + this._topOffset * this._c;
				this._y2 = this._data._y2 = this._rightOffset * this._b + this._topOffset * this._d;
				this._x3 = this._data._x3 = this._leftOffset * this._a + this._bottomOffset * this._c;
				this._y3 = this._data._y3 = this._leftOffset * this._b + this._bottomOffset * this._d;
				this._x4 = this._data._x4 = this._rightOffset * this._a + this._bottomOffset * this._c;
				this._y4 = this._data._y4 = this._rightOffset * this._b + this._bottomOffset * this._d;
			}
			else
			{
				this._x1 = this._data._x1;
				this._y1 = this._data._y1;
				this._x2 = this._data._x2;
				this._y2 = this._data._y2;
				this._x3 = this._data._x3;
				this._y3 = this._data._y3;
				this._x4 = this._data._x4;
				this._y4 = this._data._y4;
			}
			
			if (this._data._invertX)
			{
				this._u1 = this._frame.u2;
				this._u2 = this._frame.u1;
			}
			else
			{
				this._u1 = this._frame.u1;
				this._u2 = this._frame.u2;
			}
			
			if (this._data._invertY)
			{
				this._v1 = this._frame.v2;
				this._v2 = this._frame.v1;
			}
			else
			{
				this._v1 = this._frame.v1;
				this._v2 = this._frame.v2;
			}
			
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					this._alpha = this._data.alpha;
					this._alpha = this._alpha < 0.0 ? 0.0 : this._alpha > 1.0 ? 1.0 : this._alpha;
					this._red = this._data.red;
					this._red = this._red < 0.0 ? 0.0 : this._red > 1.0 ? 1.0 : this._red;
					this._green = this._data.green;
					this._green = this._green < 0.0 ? 0.0 : this._green > 1.0 ? 1.0 : this._green;
					this._blue = this._data.blue;
					this._blue = this._blue < 0.0 ? 0.0 : this._blue > 1.0 ? 1.0 : this._blue;
					if (this._pma)
					{
						this._color = Std.int(this._red * this._alpha * 255) | Std.int(this._green * this._alpha * 255) << 8 | Std.int(this._blue * this._alpha * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
					else
					{
						this._color = Std.int(this._red * 255) | Std.int(this._green * 255) << 8 | Std.int(this._blue * 255) << 16 | Std.int(this._alpha * 255) << 24;
					}
				}
				else
				{
					this._alpha = this._data.alpha;
					if (this._pma)
					{
						this._red = this._data.red * this._alpha;
						this._green = this._data.green * this._alpha;
						this._blue = this._data.blue * this._alpha;
					}
					else
					{
						this._red = this._data.red;
						this._green = this._data.green;
						this._blue = this._data.blue;
					}
				}
			}
			
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					this._alphaOffset = this._data.alphaOffset;
					this._alphaOffset = this._alphaOffset < 0.0 ? 0.0 : this._alphaOffset > 1.0 ? 1.0 : this._alphaOffset;
					this._redOffset = this._data.redOffset;
					this._redOffset = this._redOffset < 0.0 ? 0.0 : this._redOffset > 1.0 ? 1.0 : this._redOffset;
					this._greenOffset = this._data.greenOffset;
					this._greenOffset = this._greenOffset < 0.0 ? 0.0 : this._greenOffset > 1.0 ? 1.0 : this._greenOffset;
					this._blueOffset = this._data.blueOffset;
					this._blueOffset = this._blueOffset < 0.0 ? 0.0 : this._blueOffset > 1.0 ? 1.0 : this._blueOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._colorOffset = Std.int(this._redOffset * 255) | Std.int(this._greenOffset * 255) << 8 | Std.int(this._blueOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
					else
					{
						this._colorOffset = Std.int(this._redOffset * this._alphaOffset * 255) | Std.int(this._greenOffset * this._alphaOffset * 255) << 8 | Std.int(this._blueOffset * this._alphaOffset * 255) << 16 | Std.int(this._alphaOffset * 255) << 24;
					}
				}
				else
				{
					this._alphaOffset = this._data.alphaOffset;
					if (this._useColor || renderData.useDisplayColor)
					{
						this._redOffset = this._data.redOffset;
						this._greenOffset = this._data.greenOffset;
						this._blueOffset = this._data.blueOffset;
					}
					else
					{
						this._redOffset = this._data.redOffset * this._alphaOffset;
						this._greenOffset = this._data.greenOffset * this._alphaOffset;
						this._blueOffset = this._data.blueOffset * this._alphaOffset;
					}
				}
			}
			
			if (this._storeBounds)
			{
				boundsData[++this._boundsIndex] = this._x + this._x1;
				boundsData[++this._boundsIndex] = this._y + this._y1;
				boundsData[++this._boundsIndex] = this._x + this._x2;
				boundsData[++this._boundsIndex] = this._y + this._y2;
				boundsData[++this._boundsIndex] = this._x + this._x3;
				boundsData[++this._boundsIndex] = this._y + this._y3;
				boundsData[++this._boundsIndex] = this._x + this._x4;
				boundsData[++this._boundsIndex] = this._y + this._y4;
			}
			
			// TOP LEFT
			// u1 v1
			vectorData[this._position] = this._x + this._x1;
			vectorData[++this._position] = this._y + this._y1;
			vectorData[++this._position] = this._u1;
			vectorData[++this._position] = this._v1;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._color;
				}
				else
				{
					vectorData[++this._position] = this._red;
					vectorData[++this._position] = this._green;
					vectorData[++this._position] = this._blue;
					vectorData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._colorOffset;
				}
				else
				{
					vectorData[++this._position] = this._redOffset;
					vectorData[++this._position] = this._greenOffset;
					vectorData[++this._position] = this._blueOffset;
					vectorData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				vectorData[++this._position] = this._data.textureIndexReal;
			}
			
			// TOP RIGHT
			// u2 v1
			vectorData[++this._position] = this._x + this._x2;
			vectorData[++this._position] = this._y + this._y2;
			vectorData[++this._position] = this._u2;
			vectorData[++this._position] = this._v1;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._color;
				}
				else
				{
					vectorData[++this._position] = this._red;
					vectorData[++this._position] = this._green;
					vectorData[++this._position] = this._blue;
					vectorData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._colorOffset;
				}
				else
				{
					vectorData[++this._position] = this._redOffset;
					vectorData[++this._position] = this._greenOffset;
					vectorData[++this._position] = this._blueOffset;
					vectorData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				vectorData[++this._position] = this._data.textureIndexReal;
			}
			
			// BOTTOM LEFT
			// u1 v2
			vectorData[++this._position] = this._x + this._x3;
			vectorData[++this._position] = this._y + this._y3;
			vectorData[++this._position] = this._u1;
			vectorData[++this._position] = this._v2;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._color;
				}
				else
				{
					vectorData[++this._position] = this._red;
					vectorData[++this._position] = this._green;
					vectorData[++this._position] = this._blue;
					vectorData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._colorOffset;
				}
				else
				{
					vectorData[++this._position] = this._redOffset;
					vectorData[++this._position] = this._greenOffset;
					vectorData[++this._position] = this._blueOffset;
					vectorData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				vectorData[++this._position] = this._data.textureIndexReal;
			}
			
			// BOTTOM RIGHT
			// u2 v2
			vectorData[++this._position] = this._x + this._x4;
			vectorData[++this._position] = this._y + this._y4;
			vectorData[++this._position] = this._u2;
			vectorData[++this._position] = this._v2;
			if (this._useColor)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._color;
				}
				else
				{
					vectorData[++this._position] = this._red;
					vectorData[++this._position] = this._green;
					vectorData[++this._position] = this._blue;
					vectorData[++this._position] = this._alpha;
				}
			}
			if (this._useColorOffset)
			{
				if (this._simpleColor)
				{
					vectorData[++this._position] = this._colorOffset;
				}
				else
				{
					vectorData[++this._position] = this._redOffset;
					vectorData[++this._position] = this._greenOffset;
					vectorData[++this._position] = this._blueOffset;
					vectorData[++this._position] = this._alphaOffset;
				}
			}
			if (this._multiTexturing)
			{
				vectorData[++this._position] = this._data.textureIndexReal;
			}
			
			++this._position;
		}
		
		renderData.numQuads += this._quadsWritten;
		renderData.position = this._position;
		renderData.totalQuads += this._quadsWritten;
		
		if (this.numDatas == this._totalQuads)
		{
			renderData.quadOffset = 0;
			return true;
		}
		else
		{
			renderData.quadOffset += this._numQuads;
			return false;
		}
	}
	
	/**
	   @inheritDoc
	**/
	//public function writeBoundsData(boundsData:#if flash Vector<Float> #else Array<Float> #end, renderData:RenderData, renderOffsetX:Float, renderOffsetY:Float):Void
	public function writeBoundsData(boundsData:#if flash Vector<Float> #else Array<Float> #end, renderOffsetX:Float, renderOffsetY:Float):Void
	{
		this._position = boundsData.length;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in 0...this.numDatas)
		{
			this._data = this._datas[i];
			if (!this._data.visible) continue;
			
			this._x = this._data.x + this._data.offsetX + renderOffsetX;
			this._y = this._data.y + this._data.offsetY + renderOffsetY;
			
			if (this._data._transformChanged)
			{
				this._frame = this._data.frameCurrent;
				
				this._rotationChanged = this._data._rotationChanged;
				this._skewXChanged = this._data._skewXChanged;
				this._skewYChanged = this._data._skewYChanged;
				
				if (this._rotationChanged)
				{
					this._rotation = this._data._rotation;
					this._cosRotation = this._data._cosRotation = Math.cos(this._rotation);
					this._sinRotation = this._data._sinRotation = Math.sin(this._rotation);
					this._data._rotationChanged = false;
				}
				else
				{
					this._cosRotation = this._data._cosRotation;
					this._sinRotation = this._data._sinRotation;
				}
				
				if (this._skewXChanged)
				{
					this._skewX = this._data._skewX;
					this._cosSkewX = this._data._cosSkewX = Math.cos(this._skewX);
					this._sinSkewX = this._data._sinSkewX = -Math.sin(this._skewX);
					this._data._skewXChanged = false;
				}
				else
				{
					this._cosSkewX = this._data._cosSkewX;
					this._sinSkewX = this._data._sinSkewX;
				}
				
				if (this._skewYChanged)
				{
					this._skewY = this._data._skewY;
					this._cosSkewY = this._data._cosSkewY = Math.cos(this._skewY);
					this._sinSkewY = this._data._sinSkewY = Math.sin(this._skewY);
					this._data._skewYChanged = false;
				}
				else
				{
					this._cosSkewY = this._data._cosSkewY;
					this._sinSkewY = this._data._sinSkewY;
				}
				
				if (this._data._sizeXChanged)
				{
					if (this._data._invertX)
					{
						this._data._leftOffset = this._frame.rightWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.leftWidth * this._data._scaleX;
					}
					else
					{
						this._data._leftOffset = this._frame.leftWidth * this._data._scaleX;
						this._leftOffset = -this._data._leftOffset;
						this._rightOffset = this._data._rightOffset = this._frame.rightWidth * this._data._scaleX;
					}
					this._data._sizeXChanged = false;
				}
				else
				{
					this._leftOffset = -this._data._leftOffset;
					this._rightOffset = this._data._rightOffset;
				}
				
				if (this._data._sizeYChanged)
				{
					if (this._data.invertY)
					{
						this._data._topOffset = this._frame.bottomHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.topHeight * this._data._scaleY;
					}
					else
					{
						this._data._topOffset = this._frame.topHeight * this._data._scaleY;
						this._topOffset = -this._data._topOffset;
						this._bottomOffset = this._data._bottomOffset = this._frame.bottomHeight * this._data._scaleY;
					}
					this._data._sizeYChanged = false;
				}
				else
				{
					this._topOffset = -this._data._topOffset;
					this._bottomOffset = this._data._bottomOffset;
				}
				
				this._data._transformChanged = false;
				
				if (this._rotationChanged || this._skewXChanged || this._skewYChanged)
				{
					this._a = this._data._a = this._cosSkewY * this._cosRotation - this._sinSkewY * this._sinRotation;
					this._b = this._data._b = this._cosSkewY * this._sinRotation + this._sinSkewY * this._cosRotation;
					this._c = this._data._c = this._sinSkewX * this._cosRotation - this._cosSkewX * this._sinRotation;
					this._d = this._data._d = this._sinSkewX * this._sinRotation + this._cosSkewX * this._cosRotation;
				}
				else
				{
					this._a = this._data._a;
					this._b = this._data._b;
					this._c = this._data._c;
					this._d = this._data._d;
				}
				
				this._x1 = this._data._x1 = this._leftOffset * this._a + this._topOffset * this._c;
				this._y1 = this._data._y1 = this._leftOffset * this._b + this._topOffset * this._d;
				this._x2 = this._data._x2 = this._rightOffset * this._a + this._topOffset * this._c;
				this._y2 = this._data._y2 = this._rightOffset * this._b + this._topOffset * this._d;
				this._x3 = this._data._x3 = this._leftOffset * this._a + this._bottomOffset * this._c;
				this._y3 = this._data._y3 = this._leftOffset * this._b + this._bottomOffset * this._d;
				this._x4 = this._data._x4 = this._rightOffset * this._a + this._bottomOffset * this._c;
				this._y4 = this._data._y4 = this._rightOffset * this._b + this._bottomOffset * this._d;
			}
			else
			{
				this._x1 = this._data._x1;
				this._y1 = this._data._y1;
				this._x2 = this._data._x2;
				this._y2 = this._data._y2;
				this._x3 = this._data._x3;
				this._y3 = this._data._y3;
				this._x4 = this._data._x4;
				this._y4 = this._data._y4;
			}
			
			boundsData[this._position]   = this._x + this._x1;
			boundsData[++this._position] = this._y + this._y1;
			boundsData[++this._position] = this._x + this._x2;
			boundsData[++this._position] = this._y + this._y2;
			boundsData[++this._position] = this._x + this._x3;
			boundsData[++this._position] = this._y + this._y3;
			boundsData[++this._position] = this._x + this._x4;
			boundsData[++this._position] = this._y + this._y4;
			
			++this._position;
		}
	}
	
}