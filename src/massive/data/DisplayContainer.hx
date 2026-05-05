package massive.data;
import massive.display.RenderData;
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end
#if flash
import openfl.Memory;
#end

/**
 * ...
 * @author Matse
 */
@:access(massive.data.ImageData)
class DisplayContainer extends DisplayBase 
{
	/**
	   Tells whether the MassiveDisplay instance this layer is added to should call the advanceTime function or not
	**/
	public var animate:Bool = true;
	/**
	   Tells whether the container should count how many datas it has when requested to write it or not.
	   For example ParticleSystem turns this off and sets numDatas directly, according to how many particles are alive.
	   @default true
	**/
	public var autoHandleNumDatas:Bool = true;
	/**
	   How many quads this container should write data for when requested.
	**/
	public var numDatas:Int = 0;
	
	#if flash
	private var _datas:Vector<DisplayBase>;
	#else
	private var _datas:Array<DisplayBase>;
	#end

	public function new(datas:#if flash Vector<DisplayBase> #else Array<DisplayBase>#end = null) 
	{
		super();
		this.isContainer = true;
		this._datas = datas;
		#if flash
		if (this._datas == null) this._datas = new Vector<DisplayBase>();
		#else
		if (this._datas == null) this._datas = new Array<DisplayBase>();
		#end
	}
	
	public function addChild(child:DisplayBase):Void
	{
		this._datas[this._datas.length] = child;
	}
	
	public function addChildAt(child:DisplayBase, index:Int):Void
	{
		#if flash
		this._datas.insertAt(index, child);
		#else
		this._datas.insert(index, child);
		#end
	}
	
	public function addChildren(children:Array<DisplayBase>):Void
	{
		var count:Int = children.length;
		for (i in 0...count)
		{
			this._datas[this._datas.length] = children[i];
		}
	}
	
	public function addChildrenAt(children:Array<DisplayBase>, index:Int):Void
	{
		--index;
		var count:Int = children.length;
		for (i in 0...count)
		{
			#if flash
			this._datas.insertAt(++index, children[i]);
			#else
			this._datas.insert(++index, children[i]);
			#end
		}
	}
	
	public function getChildAt(index:Int):DisplayBase
	{
		return this._datas[index];
	}
	
	public function getChildIndex(child:DisplayBase):Int
	{
		return this._datas.indexOf(child);
	}
	
	public function removeChild(child:DisplayBase):Void
	{
		removeChildAt(this._datas.indexOf(child));
	}
	
	public function removeChildAt(index:Int):Void
	{
		#if flash
		this._datas.removeAt(index);
		#else
		this._datas.splice(index, 1);
		#end
	}
	
	public function removeChildren(children:Array<DisplayBase>):Void
	{
		var count:Int = children.length;
		for (i in 0...count)
		{
			#if flash
			this._datas.removeAt(this._datas.indexOf(children[i]));
			#else
			this._datas.splice(this._datas.indexOf(children[i]), 1);
			#end
		}
	}
	
	public function removeChildrenAt(index:Int, len:Int):Void
	{
		#if flash
		this._datas.splice(index, len);
		#else
		this._datas.splice(index, len);
		#end
	}
	
	public function removeAllChildren():Void
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
		
	}
	
	public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__simpleColor = renderData.useSimpleColor;
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in 0...this.numDatas)
		{
			this.__data = this._datas[i];
			if (!this.__data.visible) continue;
			if (this.__data.isContainer)
			{
				this.__container = cast this.__data;
				renderData.numQuads = this.__quadsWritten;
				this.__container.writeDataBytes(byteData, maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
				this.__quadsWritten = renderData.numQuads;
			}
			else
			{
				this.__image = cast this.__data;
				
				this.__x = this.__image.x + this.__image.offsetX + renderOffsetX;
				this.__y = this.__image.y + this.__image.offsetY + renderOffsetY;
				
				this.__frame = this.__image.frameCurrent;
				
				if (this.__image._transformChanged)
				{
					updateTransform(this.__image);
				}
				else
				{
					this.__x1 = this.__image._x1;
					this.__y1 = this.__image._y1;
					this.__x2 = this.__image._x2;
					this.__y2 = this.__image._y2;
					this.__x3 = this.__image._x3;
					this.__y3 = this.__image._y3;
					this.__x4 = this.__image._x4;
					this.__y4 = this.__image._y4;
				}
				
				if (this.__image._invertX)
				{
					this.__u1 = this.__frame.u2;
					this.__u2 = this.__frame.u1;
				}
				else
				{
					this.__u1 = this.__frame.u1;
					this.__u2 = this.__frame.u2;
				}
				
				if (this.__image._invertY)
				{
					this.__v1 = this.__frame.v2;
					this.__v2 = this.__frame.v1;
				}
				else
				{
					this.__v1 = this.__frame.v1;
					this.__v2 = this.__frame.v2;
				}
				
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						this.__alpha = this.__image.alpha;
						this.__alpha = this.__alpha < 0.0 ? 0.0 : this.__alpha > 1.0 ? 1.0 : this.__alpha;
						this.__red = this.__image.red;
						this.__red = this.__red < 0.0 ? 0.0 : this.__red > 1.0 ? 1.0 : this.__red;
						this.__green = this.__image.green;
						this.__green = this.__green < 0.0 ? 0.0 : this.__green > 1.0 ? 1.0 : this.__green;
						this.__blue = this.__image.blue;
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
						this.__alpha = this.__image.alpha;
						if (this.__pma)
						{
							this.__red = this.__image.red * this.__alpha;
							this.__green = this.__image.green * this.__alpha;
							this.__blue = this.__image.blue * this.__alpha;
						}
						else
						{
							this.__red = this.__image.red;
							this.__green = this.__image.green;
							this.__blue = this.__image.blue;
						}
					}
				}
				
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						this.__alphaOffset = this.__image.alphaOffset;
						this.__alphaOffset = this.__alphaOffset < 0.0 ? 0.0 : this.__alphaOffset > 1.0 ? 1.0 : this.__alphaOffset;
						this.__redOffset = this.__image.redOffset;
						this.__redOffset = this.__redOffset < 0.0 ? 0.0 : this.__redOffset > 1.0 ? 1.0 : this.__redOffset;
						this.__greenOffset = this.__image.greenOffset;
						this.__greenOffset = this.__greenOffset < 0.0 ? 0.0 : this.__greenOffset > 1.0 ? 1.0 : this.__greenOffset;
						this.__blueOffset = this.__image.blueOffset;
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
						this.__alphaOffset = this.__image.alphaOffset;
						if (this.__useColor || renderData.useDisplayColor)
						{
							this.__redOffset = this.__image.redOffset;
							this.__greenOffset = this.__image.greenOffset;
							this.__blueOffset = this.__image.blueOffset;
						}
						else
						{
							this.__redOffset = this.__image.redOffset * this.__alphaOffset;
							this.__greenOffset = this.__image.greenOffset * this.__alphaOffset;
							this.__blueOffset = this.__image.blueOffset * this.__alphaOffset;
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
				// u1 v1
				byteData.writeFloat(this.__x + this.__x1);
				byteData.writeFloat(this.__y + this.__y1);
				byteData.writeFloat(this.__u1);
				byteData.writeFloat(this.__v1);
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
				if (this.__multiTexturing)
				{
					byteData.writeFloat(this.__image.textureIndexReal);
				}
				
				// TOP RIGHT
				// u2 v1
				byteData.writeFloat(this.__x + this.__x2);
				byteData.writeFloat(this.__y + this.__y2);
				byteData.writeFloat(this.__u2);
				byteData.writeFloat(this.__v1);
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
				if (this.__multiTexturing)
				{
					byteData.writeFloat(this.__image.textureIndexReal);
				}
				
				// BOTTOM LEFT
				// u1 v2
				byteData.writeFloat(this.__x + this.__x3);
				byteData.writeFloat(this.__y + this.__y3);
				byteData.writeFloat(this.__u1);
				byteData.writeFloat(this.__v2);
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
				if (this.__multiTexturing)
				{
					byteData.writeFloat(this.__image.textureIndexReal);
				}
				
				// BOTTOM RIGHT
				// u2 v2
				byteData.writeFloat(this.__x + this.__x4);
				byteData.writeFloat(this.__y + this.__y4);
				byteData.writeFloat(this.__u2);
				byteData.writeFloat(this.__v2);
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
				if (this.__multiTexturing)
				{
					byteData.writeFloat(this.__image.textureIndexReal);
				}
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawBytes();
					this.__quadsWritten = 0;
				}
			}
		}
		
		renderData.numQuads = this.__quadsWritten;
	}
	
	#if flash
	/**
	   @inheritDoc
	**/
	public function writeDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Void
	{
		
	}
	#end
	
	#if !flash
	/**
	   @inheritDoc
	**/
	public function writeDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		
	}
	#end
	
	/**
	   @inheritDoc
	**/
	public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		
	}
	
	public function writeBoundsData(boundsData:#if flash Vector<Float> #else Array<Float> #end, renderOffsetX:Float, renderOffsetY:Float):Void
	{
		this.__position = boundsData.length-1;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		renderOffsetX += this.x;
		renderOffsetY += this.y;
		
		for (i in 0...this.numDatas)
		{
			this.__data = this._datas[i];
			if (!this.__data.visible) continue;
			if (this.__data.isContainer)
			{
				this.__container = cast this.__data;
				this.__container.writeBoundsData(boundsData, renderOffsetX, renderOffsetY);
			}
			else
			{
				this.__image = cast this.__data;
				
				this.__x = this.__image.x + this.__image.offsetX + renderOffsetX;
				this.__y = this.__image.y + this.__image.offsetY + renderOffsetY;
				
				if (this.__image._transformChanged)
				{
					updateTransform(this.__image);
				}
				else
				{
					this.__x1 = this.__image._x1;
					this.__y1 = this.__image._y1;
					this.__x2 = this.__image._x2;
					this.__y2 = this.__image._y2;
					this.__x3 = this.__image._x3;
					this.__y3 = this.__image._y3;
					this.__x4 = this.__image._x4;
					this.__y4 = this.__image._y4;
				}
				
				boundsData[++this.__position] = this.__x + this.__x1;
				boundsData[++this.__position] = this.__y + this.__y1;
				boundsData[++this.__position] = this.__x + this.__x2;
				boundsData[++this.__position] = this.__y + this.__y2;
				boundsData[++this.__position] = this.__x + this.__x3;
				boundsData[++this.__position] = this.__y + this.__y3;
				boundsData[++this.__position] = this.__x + this.__x4;
				boundsData[++this.__position] = this.__y + this.__y4;
			}
		}
	}
	
	inline private function updateColor(data:ImageData):Void
	{
		
	}
	
	inline private function updateTransform(data:ImageData):Void
	{
		this.__rotationChanged = data._rotationChanged;
		this.__skewXChanged = data._skewXChanged;
		this.__skewYChanged = data._skewYChanged;
		
		if (this.__rotationChanged)
		{
			this.__rotation = data._rotation;
			this.__cosRotation = data._cosRotation = Math.cos(this.__rotation);
			this.__sinRotation = data._sinRotation = Math.sin(this.__rotation);
			data._rotationChanged = false;
		}
		else
		{
			this.__cosRotation = data._cosRotation;
			this.__sinRotation = data._sinRotation;
		}
		
		if (this.__skewXChanged)
		{
			this.__skewX = data._skewX;
			this.__cosSkewX = data._cosSkewX = Math.cos(this.__skewX);
			this.__sinSkewX = data._sinSkewX = -Math.sin(this.__skewX);
			data._skewXChanged = false;
		}
		else
		{
			this.__cosSkewX = data._cosSkewX;
			this.__sinSkewX = data._sinSkewX;
		}
		
		if (this.__skewYChanged)
		{
			this.__skewY = data._skewY;
			this.__cosSkewY = data._cosSkewY = Math.cos(this.__skewY);
			this.__sinSkewY = data._sinSkewY = Math.sin(this.__skewY);
			data._skewYChanged = false;
		}
		else
		{
			this.__cosSkewY = data._cosSkewY;
			this.__sinSkewY = data._sinSkewY;
		}
		
		if (data._sizeXChanged)
		{
			if (data._invertX)
			{
				data._leftOffset = this.__frame.rightWidth * data._scaleX;
				this.__leftOffset = -data._leftOffset;
				this.__rightOffset = data._rightOffset = this.__frame.leftWidth * data._scaleX;
			}
			else
			{
				data._leftOffset = this.__frame.leftWidth * data._scaleX;
				this.__leftOffset = -data._leftOffset;
				this.__rightOffset = data._rightOffset = this.__frame.rightWidth * data._scaleX;
			}
			data._sizeXChanged = false;
		}
		else
		{
			this.__leftOffset = -data._leftOffset;
			this.__rightOffset = data._rightOffset;
		}
		
		if (data._sizeYChanged)
		{
			if (data.invertY)
			{
				data._topOffset = this.__frame.bottomHeight * data._scaleY;
				this.__topOffset = -data._topOffset;
				this.__bottomOffset = data._bottomOffset = this.__frame.topHeight * data._scaleY;
			}
			else
			{
				data._topOffset = this.__frame.topHeight * data._scaleY;
				this.__topOffset = -data._topOffset;
				this.__bottomOffset = data._bottomOffset = this.__frame.bottomHeight * data._scaleY;
			}
			data._sizeYChanged = false;
		}
		else
		{
			this.__topOffset = -data._topOffset;
			this.__bottomOffset = data._bottomOffset;
		}
		
		data._transformChanged = false;
		
		if (this.__rotationChanged || this.__skewXChanged || this.__skewYChanged)
		{
			this.__a = data._a = this.__cosSkewY * this.__cosRotation - this.__sinSkewY * this.__sinRotation;
			this.__b = data._b = this.__cosSkewY * this.__sinRotation + this.__sinSkewY * this.__cosRotation;
			this.__c = data._c = this.__sinSkewX * this.__cosRotation - this.__cosSkewX * this.__sinRotation;
			this.__d = data._d = this.__sinSkewX * this.__sinRotation + this.__cosSkewX * this.__cosRotation;
		}
		else
		{
			this.__a = data._a;
			this.__b = data._b;
			this.__c = data._c;
			this.__d = data._d;
		}
		
		this.__x1 = data._x1 = this.__leftOffset * this.__a + this.__topOffset * this.__c;
		this.__y1 = data._y1 = this.__leftOffset * this.__b + this.__topOffset * this.__d;
		this.__x2 = data._x2 = this.__rightOffset * this.__a + this.__topOffset * this.__c;
		this.__y2 = data._y2 = this.__rightOffset * this.__b + this.__topOffset * this.__d;
		this.__x3 = data._x3 = this.__leftOffset * this.__a + this.__bottomOffset * this.__c;
		this.__y3 = data._y3 = this.__leftOffset * this.__b + this.__bottomOffset * this.__d;
		this.__x4 = data._x4 = this.__rightOffset * this.__a + this.__bottomOffset * this.__c;
		this.__y4 = data._y4 = this.__rightOffset * this.__b + this.__bottomOffset * this.__d;
	}
	
	private var __data:DisplayBase;
	private var __container:DisplayContainer;
	private var __containerDone:Bool;
	private var __image:ImageData;
	
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
	private var __frame:Frame;
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
	private var __u1:Float;
	private var __u2:Float;
	private var __v1:Float;
	private var __v2:Float;
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
	
	private var __multiTexturing:Bool;
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
	
}