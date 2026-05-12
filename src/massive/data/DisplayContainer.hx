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
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;//this.__pma && !this.__useColor && !this.__useDisplayColor;
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
				
				updateColor(this.__image);
				
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
						byteData.writeInt(this.__image._color1Final);
					}
					else
					{
						byteData.writeFloat(this.__image._red1Final);
						byteData.writeFloat(this.__image._green1Final);
						byteData.writeFloat(this.__image._blue1Final);
						byteData.writeFloat(this.__image._alpha1Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						byteData.writeInt(this.__image._colorOffset1Final);
					}
					else
					{
						byteData.writeFloat(this.__image._redOffset1Final);
						byteData.writeFloat(this.__image._greenOffset1Final);
						byteData.writeFloat(this.__image._blueOffset1Final);
						byteData.writeFloat(this.__image._alphaOffset1Final);
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
						byteData.writeInt(this.__image._color2Final);
					}
					else
					{
						byteData.writeFloat(this.__image._red2Final);
						byteData.writeFloat(this.__image._green2Final);
						byteData.writeFloat(this.__image._blue2Final);
						byteData.writeFloat(this.__image._alpha2Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						byteData.writeInt(this.__image._colorOffset2Final);
					}
					else
					{
						byteData.writeFloat(this.__image._redOffset2Final);
						byteData.writeFloat(this.__image._greenOffset2Final);
						byteData.writeFloat(this.__image._blueOffset2Final);
						byteData.writeFloat(this.__image._alphaOffset2Final);
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
						byteData.writeInt(this.__image._color3Final);
					}
					else
					{
						byteData.writeFloat(this.__image._red3Final);
						byteData.writeFloat(this.__image._green3Final);
						byteData.writeFloat(this.__image._blue3Final);
						byteData.writeFloat(this.__image._alpha3Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						byteData.writeInt(this.__image._colorOffset3Final);
					}
					else
					{
						byteData.writeFloat(this.__image._redOffset3Final);
						byteData.writeFloat(this.__image._greenOffset3Final);
						byteData.writeFloat(this.__image._blueOffset3Final);
						byteData.writeFloat(this.__image._alphaOffset3Final);
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
						byteData.writeInt(this.__image._color4Final);
					}
					else
					{
						byteData.writeFloat(this.__image._red4Final);
						byteData.writeFloat(this.__image._green4Final);
						byteData.writeFloat(this.__image._blue4Final);
						byteData.writeFloat(this.__image._alpha4Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						byteData.writeInt(this.__image._colorOffset4Final);
					}
					else
					{
						byteData.writeFloat(this.__image._redOffset4Final);
						byteData.writeFloat(this.__image._greenOffset4Final);
						byteData.writeFloat(this.__image._blueOffset4Final);
						byteData.writeFloat(this.__image._alphaOffset4Final);
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
		if (this._datas == null) return;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;// this.__pma && !this.__useColor && !this.__useDisplayColor;
		this.__simpleColor = renderData.useSimpleColor;
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		this.__position = renderData.position;
		
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
				this.__container.writeDataBytesMemory(maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
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
				
				updateColor(this.__image);
				
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
				Memory.setFloat(this.__position, this.__x + this.__x1);
				Memory.setFloat(this.__position += 4, this.__y + this.__y1);
				Memory.setFloat(this.__position += 4, this.__u1);
				Memory.setFloat(this.__position += 4, this.__v1);
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._color1Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._red1Final);
						Memory.setFloat(this.__position += 4, this.__image._green1Final);
						Memory.setFloat(this.__position += 4, this.__image._blue1Final);
						Memory.setFloat(this.__position += 4, this.__image._alpha1Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._colorOffset1Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._redOffset1Final);
						Memory.setFloat(this.__position += 4, this.__image._greenOffset1Final);
						Memory.setFloat(this.__position += 4, this.__image._blueOffset1Final);
						Memory.setFloat(this.__position += 4, this.__image._alphaOffset1Final);
					}
				}
				if (this.__multiTexturing)
				{
					Memory.setFloat(this.__position += 4, this.__image.textureIndexReal);
				}
				
				// TOP RIGHT
				// u2 v1
				Memory.setFloat(this.__position += 4, this.__x + this.__x2);
				Memory.setFloat(this.__position += 4, this.__y + this.__y2);
				Memory.setFloat(this.__position += 4, this.__u2);
				Memory.setFloat(this.__position += 4, this.__v1);
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._color2Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._red2Final);
						Memory.setFloat(this.__position += 4, this.__image._green2Final);
						Memory.setFloat(this.__position += 4, this.__image._blue2Final);
						Memory.setFloat(this.__position += 4, this.__image._alpha2Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._colorOffset2Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._redOffset2Final);
						Memory.setFloat(this.__position += 4, this.__image._greenOffset2Final);
						Memory.setFloat(this.__position += 4, this.__image._blueOffset2Final);
						Memory.setFloat(this.__position += 4, this.__image._alphaOffset2Final);
					}
				}
				if (this.__multiTexturing)
				{
					Memory.setFloat(this.__position += 4, this.__image.textureIndexReal);
				}
				
				// BOTTOM LEFT
				// u1 v2
				Memory.setFloat(this.__position += 4, this.__x + this.__x3);
				Memory.setFloat(this.__position += 4, this.__y + this.__y3);
				Memory.setFloat(this.__position += 4, this.__u1);
				Memory.setFloat(this.__position += 4, this.__v2);
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._color3Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._red3Final);
						Memory.setFloat(this.__position += 4, this.__image._green3Final);
						Memory.setFloat(this.__position += 4, this.__image._blue3Final);
						Memory.setFloat(this.__position += 4, this.__image._alpha3Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._colorOffset3Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._redOffset3Final);
						Memory.setFloat(this.__position += 4, this.__image._greenOffset3Final);
						Memory.setFloat(this.__position += 4, this.__image._blueOffset3Final);
						Memory.setFloat(this.__position += 4, this.__image._alphaOffset3Final);
					}
				}
				if (this.__multiTexturing)
				{
					Memory.setFloat(this.__position += 4, this.__image.textureIndexReal);
				}
				
				// BOTTOM RIGHT
				// u2 v2
				Memory.setFloat(this.__position += 4, this.__x + this.__x4);
				Memory.setFloat(this.__position += 4, this.__y + this.__y4);
				Memory.setFloat(this.__position += 4, this.__u2);
				Memory.setFloat(this.__position += 4, this.__v2);
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._color4Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._red4Final);
						Memory.setFloat(this.__position += 4, this.__image._green4Final);
						Memory.setFloat(this.__position += 4, this.__image._blue4Final);
						Memory.setFloat(this.__position += 4, this.__image._alpha4Final);
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						Memory.setI32(this.__position += 4, this.__image._colorOffset4Final);
					}
					else
					{
						Memory.setFloat(this.__position += 4, this.__image._redOffset4Final);
						Memory.setFloat(this.__position += 4, this.__image._greenOffset4Final);
						Memory.setFloat(this.__position += 4, this.__image._blueOffset4Final);
						Memory.setFloat(this.__position += 4, this.__image._alphaOffset4Final);
					}
				}
				if (this.__multiTexturing)
				{
					Memory.setFloat(this.__position += 4, this.__image.textureIndexReal);
				}
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawBytesMemory();
					this.__quadsWritten = 0;
					this.__position = 0;
				}
				else
				{
					this.__position += 4;
				}
			}
		}
		
		renderData.numQuads = this.__quadsWritten;
	}
	#end
	
	#if !flash
	/**
	   @inheritDoc
	**/
	public function writeDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;// this.__pma && !this.__useColor && !this.__useDisplayColor;
		this.__simpleColor = renderData.useSimpleColor;
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		this.__position = renderData.position;
		
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
				this.__container.writeDataFloat32Array(floatData, maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
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
				
				updateColor(this.__image);
				
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
				floatData[this.__position] = this.__x + this.__x1;
				floatData[++this.__position] = this.__y + this.__y1;
				floatData[++this.__position] = this.__u1;
				floatData[++this.__position] = this.__v1;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._color1Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._red1Final;
						floatData[++this.__position] = this.__image._green1Final;
						floatData[++this.__position] = this.__image._blue1Final;
						floatData[++this.__position] = this.__image._alpha1Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._colorOffset1Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._redOffset1Final;
						floatData[++this.__position] = this.__image._greenOffset1Final;
						floatData[++this.__position] = this.__image._blueOffset1Final;
						floatData[++this.__position] = this.__image._alphaOffset1Final;
					}
				}
				if (this.__multiTexturing)
				{
					floatData[++this.__position] = this.__image.textureIndexReal;
				}
				
				// TOP RIGHT
				// u2 v1
				floatData[++this.__position] = this.__x + this.__x2;
				floatData[++this.__position] = this.__y + this.__y2;
				floatData[++this.__position] = this.__u2;
				floatData[++this.__position] = this.__v1;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._color2Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._red2Final;
						floatData[++this.__position] = this.__image._green2Final;
						floatData[++this.__position] = this.__image._blue2Final;
						floatData[++this.__position] = this.__image._alpha2Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._colorOffset2Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._redOffset2Final;
						floatData[++this.__position] = this.__image._greenOffset2Final;
						floatData[++this.__position] = this.__image._blueOffset2Final;
						floatData[++this.__position] = this.__image._alphaOffset2Final;
					}
				}
				if (this.__multiTexturing)
				{
					floatData[++this.__position] = this.__image.textureIndexReal;
				}
				
				// BOTTOM LEFT
				// u1 v2
				floatData[++this.__position] = this.__x + this.__x3;
				floatData[++this.__position] = this.__y + this.__y3;
				floatData[++this.__position] = this.__u1;
				floatData[++this.__position] = this.__v2;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._color3Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._red3Final;
						floatData[++this.__position] = this.__image._green3Final;
						floatData[++this.__position] = this.__image._blue3Final;
						floatData[++this.__position] = this.__image._alpha3Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._colorOffset3Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._redOffset3Final;
						floatData[++this.__position] = this.__image._greenOffset3Final;
						floatData[++this.__position] = this.__image._blueOffset3Final;
						floatData[++this.__position] = this.__image._alphaOffset3Final;
					}
				}
				if (this.__multiTexturing)
				{
					floatData[++this.__position] = this.__image.textureIndexReal;
				}
				
				// BOTTOM RIGHT
				// u2 v2
				floatData[++this.__position] = this.__x + this.__x4;
				floatData[++this.__position] = this.__y + this.__y4;
				floatData[++this.__position] = this.__u2;
				floatData[++this.__position] = this.__v2;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._color4Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._red4Final;
						floatData[++this.__position] = this.__image._green4Final;
						floatData[++this.__position] = this.__image._blue4Final;
						floatData[++this.__position] = this.__image._alpha4Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						floatData[++this.__position] = this.__image._colorOffset4Final;
					}
					else
					{
						floatData[++this.__position] = this.__image._red4Final;
						floatData[++this.__position] = this.__image._green4Final;
						floatData[++this.__position] = this.__image._blue4Final;
						floatData[++this.__position] = this.__image._alpha4Final;
					}
				}
				if (this.__multiTexturing)
				{
					floatData[++this.__position] = this.__image.textureIndexReal;
				}
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawFloat32();
					this.__quadsWritten = 0;
					this.__position = 0;
				}
				else
				{
					++this.__position;
				}
			}
		}
		
		renderData.numQuads = this.__quadsWritten;
	}
	#end
	
	/**
	   @inheritDoc
	**/
	public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;// this.__pma && !this.__useColor && !this.__useDisplayColor;
		this.__simpleColor = renderData.useSimpleColor;
		this.__totalQuads = renderData.quadOffset + this.__numQuads;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		this.__position = renderData.position;
		
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
				this.__container.writeDataVector(vectorData, maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
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
				
				updateColor(this.__image);
				
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
				vectorData[this.__position] = this.__x + this.__x1;
				vectorData[++this.__position] = this.__y + this.__y1;
				vectorData[++this.__position] = this.__u1;
				vectorData[++this.__position] = this.__v1;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._color1Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._red1Final;
						vectorData[++this.__position] = this.__image._green1Final;
						vectorData[++this.__position] = this.__image._blue1Final;
						vectorData[++this.__position] = this.__image._alpha1Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._colorOffset1Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._redOffset1Final;
						vectorData[++this.__position] = this.__image._greenOffset1Final;
						vectorData[++this.__position] = this.__image._blueOffset1Final;
						vectorData[++this.__position] = this.__image._alphaOffset1Final;
					}
				}
				if (this.__multiTexturing)
				{
					vectorData[++this.__position] = this.__image.textureIndexReal;
				}
				
				// TOP RIGHT
				// u2 v1
				vectorData[++this.__position] = this.__x + this.__x2;
				vectorData[++this.__position] = this.__y + this.__y2;
				vectorData[++this.__position] = this.__u2;
				vectorData[++this.__position] = this.__v1;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._color2Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._red2Final;
						vectorData[++this.__position] = this.__image._green2Final;
						vectorData[++this.__position] = this.__image._blue2Final;
						vectorData[++this.__position] = this.__image._alpha2Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._colorOffset2Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._redOffset2Final;
						vectorData[++this.__position] = this.__image._greenOffset2Final;
						vectorData[++this.__position] = this.__image._blueOffset2Final;
						vectorData[++this.__position] = this.__image._alphaOffset2Final;
					}
				}
				if (this.__multiTexturing)
				{
					vectorData[++this.__position] = this.__image.textureIndexReal;
				}
				
				// BOTTOM LEFT
				// u1 v2
				vectorData[++this.__position] = this.__x + this.__x3;
				vectorData[++this.__position] = this.__y + this.__y3;
				vectorData[++this.__position] = this.__u1;
				vectorData[++this.__position] = this.__v2;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._color3Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._red3Final;
						vectorData[++this.__position] = this.__image._green3Final;
						vectorData[++this.__position] = this.__image._blue3Final;
						vectorData[++this.__position] = this.__image._alpha3Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._colorOffset3Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._redOffset3Final;
						vectorData[++this.__position] = this.__image._greenOffset3Final;
						vectorData[++this.__position] = this.__image._blueOffset3Final;
						vectorData[++this.__position] = this.__image._alphaOffset3Final;
					}
				}
				if (this.__multiTexturing)
				{
					vectorData[++this.__position] = this.__image.textureIndexReal;
				}
				
				// BOTTOM RIGHT
				// u2 v2
				vectorData[++this.__position] = this.__x + this.__x4;
				vectorData[++this.__position] = this.__y + this.__y4;
				vectorData[++this.__position] = this.__u2;
				vectorData[++this.__position] = this.__v2;
				if (this.__useColor)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._color4Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._red4Final;
						vectorData[++this.__position] = this.__image._green4Final;
						vectorData[++this.__position] = this.__image._blue4Final;
						vectorData[++this.__position] = this.__image._alpha4Final;
					}
				}
				if (this.__useColorOffset)
				{
					if (this.__simpleColor)
					{
						vectorData[++this.__position] = this.__image._colorOffset4Final;
					}
					else
					{
						vectorData[++this.__position] = this.__image._redOffset4Final;
						vectorData[++this.__position] = this.__image._greenOffset4Final;
						vectorData[++this.__position] = this.__image._blueOffset4Final;
						vectorData[++this.__position] = this.__image._alphaOffset4Final;
					}
				}
				if (this.__multiTexturing)
				{
					vectorData[++this.__position] = this.__image.textureIndexReal;
				}
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawVector();
					this.__quadsWritten = 0;
					this.__position = 0;
				}
				else
				{
					++this.__position;
				}
			}
		}
		
		renderData.numQuads = this.__quadsWritten;
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
	
	inline private function normalizeColor():Void
	{
		this.__alpha = this.__alpha < 0.0 ? 0.0 : this.__alpha > 1.0 ? 1.0 : this.__alpha;
		this.__red = this.__red < 0.0 ? 0.0 : this.__red > 1.0 ? 1.0 : this.__red;
		this.__green = this.__green < 0.0 ? 0.0 : this.__green > 1.0 ? 1.0 : this.__green;
		this.__blue = this.__blue < 0.0 ? 0.0 : this.__blue > 1.0 ? 1.0 : this.__blue;
	}
	
	inline private function getColor():Int
	{
		if (this.__pma)
		{
			return Std.int(this.__red * this.__alpha * 255) | Std.int(this.__green * this.__alpha * 255) << 8 | Std.int(this.__blue * this.__alpha * 255) << 16 | Std.int(this.__alpha * 255) << 24;
		}
		else
		{
			return Std.int(this.__red * 255) | Std.int(this.__green * 255) << 8 | Std.int(this.__blue * 255) << 16 | Std.int(this.__alpha * 255) << 24;
		}
	}
	
	inline private function getColorOffset():Int
	{
		return Std.int(this.__red * 255) | Std.int(this.__green * 255) << 8 | Std.int(this.__blue * 255) << 16 | Std.int(this.__alpha * 255) << 24;
	}
	
	private function updateColor(data:ImageData):Void
	{
		if (this.__useColor && data._colorChanged)
		{
			data._colorChanged = false;
			
			if (this.__simpleColor)
			{
				if (data._uniformColor)
				{
					this.__alpha = data._alpha1;
					this.__red = data._red1;
					this.__green = data._green1;
					this.__blue = data._blue1;
					normalizeColor();
					data._color1Final = data._color2Final = data._color3Final = data._color4Final = getColor();
				}
				else
				{
					if (data._invertX)
					{
						if (data._invertY)
						{
							// top left
							this.__alpha = data._alpha4;
							this.__red = data._red4;
							this.__green = data._green4;
							this.__blue = data._blue4;
							normalizeColor();
							data._color1Final = getColor();
							
							// top right
							this.__alpha = data._alpha3;
							this.__red = data._red3;
							this.__green = data._green3;
							this.__blue = data._blue3;
							normalizeColor();
							data._color2Final = getColor();
							
							// bottom left
							this.__alpha = data._alpha2;
							this.__red = data._red2;
							this.__green = data._green2;
							this.__blue = data._blue2;
							normalizeColor();
							data._color3Final = getColor();
							
							// bottom right
							this.__alpha = data._alpha1;
							this.__red = data._red1;
							this.__green = data._green1;
							this.__blue = data._blue1;
							normalizeColor();
							data._color4Final = getColor();
						}
						else
						{
							// top left
							this.__alpha = data._alpha2;
							this.__red = data._red2;
							this.__green = data._green2;
							this.__blue = data._blue2;
							normalizeColor();
							data._color1Final = getColor();
							
							// top right
							this.__alpha = data._alpha1;
							this.__red = data._red1;
							this.__green = data._green1;
							this.__blue = data._blue1;
							normalizeColor();
							data._color2Final = getColor();
							
							// bottom left
							this.__alpha = data._alpha4;
							this.__red = data._red4;
							this.__green = data._green4;
							this.__blue = data._blue4;
							normalizeColor();
							data._color3Final = getColor();
							
							// bottom right
							this.__alpha = data._alpha3;
							this.__red = data._red3;
							this.__green = data._green3;
							this.__blue = data._blue3;
							normalizeColor();
							data._color4Final = getColor();
						}
					}
					else if (data._invertY)
					{
						// top left
						this.__alpha = data._alpha3;
						this.__red = data._red3;
						this.__green = data._green3;
						this.__blue = data._blue3;
						normalizeColor();
						data._color1Final = getColor();
						
						// top right
						this.__alpha = data._alpha4;
						this.__red = data._red4;
						this.__green = data._green4;
						this.__blue = data._blue4;
						normalizeColor();
						data._color2Final = getColor();
						
						// bottom left
						this.__alpha = data._alpha1;
						this.__red = data._red1;
						this.__green = data._green1;
						this.__blue = data._blue1;
						normalizeColor();
						data._color3Final = getColor();
						
						// bottom right
						this.__alpha = data._alpha2;
						this.__red = data._red2;
						this.__green = data._green2;
						this.__blue = data._blue2;
						normalizeColor();
						data._color4Final = getColor();
					}
					else
					{
						// top left
						this.__alpha = data._alpha1;
						this.__red = data._red1;
						this.__green = data._green1;
						this.__blue = data._blue1;
						normalizeColor();
						data._color1Final = getColor();
						
						// top right
						this.__alpha = data._alpha2;
						this.__red = data._red2;
						this.__green = data._green2;
						this.__blue = data._blue2;
						normalizeColor();
						data._color2Final = getColor();
						
						// bottom left
						this.__alpha = data._alpha3;
						this.__red = data._red3;
						this.__green = data._green3;
						this.__blue = data._blue3;
						normalizeColor();
						data._color3Final = getColor();
						
						// bottom right
						this.__alpha = data._alpha4;
						this.__red = data._red4;
						this.__green = data._green4;
						this.__blue = data._blue4;
						normalizeColor();
						data._color4Final = getColor();
					}
				}
			}
			else
			{
				if (this.__pma)
				{
					if (data._uniformColor)
					{
						// all vertices
						this.__alpha = data._alpha1;
						data._red1Final = data._red2Final = data._red3Final = data._red4Final = data._red1 * this.__alpha;
						data._green1Final = data._green2Final = data._green3Final = data._green4Final = data._green1 * this.__alpha;
						data._blue1Final = data._blue2Final = data._blue3Final = data._blue4Final = data._blue1 * this.__alpha;
						data._alpha1Final = data._alpha2Final = data._alpha3Final = data._alpha4Final = this.__alpha;
					}
					else
					{
						if (data._invertX)
						{
							if (data._invertY)
							{
								// top left
								this.__alpha = data._alpha4;
								data._red1Final = data._red4 * this.__alpha;
								data._green1Final = data._green4 * this.__alpha;
								data._blue1Final = data._blue4 * this.__alpha;
								data._alpha1Final = this.__alpha;
								
								// top right
								this.__alpha = data._alpha3;
								data._red2Final = data._red3 * this.__alpha;
								data._green2Final = data._green3 * this.__alpha;
								data._blue2Final = data._blue3 * this.__alpha;
								data._alpha2Final = this.__alpha;
								
								// bottom left
								this.__alpha = data._alpha2;
								data._red3Final = data._red2 * this.__alpha;
								data._green3Final = data._green2 * this.__alpha;
								data._blue3Final = data._blue2 * this.__alpha;
								data._alpha3Final = this.__alpha;
								
								// bottom right
								this.__alpha = data._alpha1;
								data._red4Final = data._red1 * this.__alpha;
								data._green4Final = data._green1 * this.__alpha;
								data._blue4Final = data._blue1 * this.__alpha;
								data._alpha4Final = this.__alpha;
							}
							else
							{
								// top left
								this.__alpha = data._alpha2;
								data._red1Final = data._red2 * this.__alpha;
								data._green1Final = data._green2 * this.__alpha;
								data._blue1Final = data._blue2 * this.__alpha;
								data._alpha1Final = this.__alpha;
								
								// top right
								this.__alpha = data._alpha1;
								data._red2Final = data._red1 * this.__alpha;
								data._green2Final = data._green1 * this.__alpha;
								data._blue2Final = data._blue1 * this.__alpha;
								data._alpha2Final = this.__alpha;
								
								// bottom left
								this.__alpha = data._alpha4;
								data._red3Final = data._red4 * this.__alpha;
								data._green3Final = data._green4 * this.__alpha;
								data._blue3Final = data._blue4 * this.__alpha;
								data._alpha3Final = this.__alpha;
								
								// bottom right
								this.__alpha = data._alpha3;
								data._red4Final = data._red3 * this.__alpha;
								data._green4Final = data._green3 * this.__alpha;
								data._blue4Final = data._blue3 * this.__alpha;
								data._alpha4Final = this.__alpha;
							}
						}
						else if (data._invertY)
						{
							// top left
							this.__alpha = data._alpha3;
							data._red1Final = data._red3 * this.__alpha;
							data._green1Final = data._green3* this.__alpha;
							data._blue1Final = data._blue3 * this.__alpha;
							data._alpha1Final = this.__alpha;
							
							// top right
							this.__alpha = data._alpha4;
							data._red2Final = data._red4 * this.__alpha;
							data._green2Final = data._green4 * this.__alpha;
							data._blue2Final = data._blue4 * this.__alpha;
							data._alpha2Final = this.__alpha;
							
							// bottom left
							this.__alpha = data._alpha1;
							data._red3Final = data._red1 * this.__alpha;
							data._green3Final = data._green1 * this.__alpha;
							data._blue3Final = data._blue1 * this.__alpha;
							data._alpha3Final = this.__alpha;
							
							// bottom right
							this.__alpha = data._alpha2;
							data._red4Final = data._red2 * this.__alpha;
							data._green4Final = data._green2 * this.__alpha;
							data._blue4Final = data._blue2 * this.__alpha;
							data._alpha4Final = this.__alpha;
						}
						else
						{
							// top left
							this.__alpha = data._alpha1;
							data._red1Final = data._red1 * this.__alpha;
							data._green1Final = data._green1 * this.__alpha;
							data._blue1Final = data._blue1 * this.__alpha;
							data._alpha1Final = this.__alpha;
							
							// top right
							this.__alpha = data._alpha2;
							data._red2Final = data._red2 * this.__alpha;
							data._green2Final = data._green2 * this.__alpha;
							data._blue2Final = data._blue2 * this.__alpha;
							data._alpha2Final = this.__alpha;
							
							// bottom left
							this.__alpha = data._alpha3;
							data._red3Final = data._red3 * this.__alpha;
							data._green3Final = data._green3 * this.__alpha;
							data._blue3Final = data._blue3 * this.__alpha;
							data._alpha3Final = this.__alpha;
							
							// bottom right
							this.__alpha = data._alpha4;
							data._red4Final = data._red4 * this.__alpha;
							data._green4Final = data._green4 * this.__alpha;
							data._blue4Final = data._blue4 * this.__alpha;
							data._alpha4Final = this.__alpha;
						}
					}
				}
				else
				{
					if (data._uniformColor)
					{
						// all vertices
						data._red1Final = data._red2Final = data._red3Final = data._red4Final = data._red1;
						data._green1Final = data._green2Final = data._green3Final = data._green4Final = data._green1;
						data._blue1Final = data._blue2Final = data._blue3Final = data._blue4Final = data._blue1;
						data._alpha1Final = data._alpha2Final = data._alpha3Final = data._alpha4Final = data._alpha1;
					}
					else
					{
						if (data._invertX)
						{
							if (data._invertY)
							{
								// top left
								data._red1Final = data._red4;
								data._green1Final = data._green4;
								data._blue1Final = data._blue4;
								data._alpha1Final = data._alpha4;
								
								// top right
								data._red2Final = data._red3;
								data._green2Final = data._green3;
								data._blue2Final = data._blue3;
								data._alpha2Final = data._alpha3;
								
								// bottom left
								data._red3Final = data._red2;
								data._green3Final = data._green2;
								data._blue3Final = data._blue2;
								data._alpha3Final = data._alpha2;
								
								// bottom right
								data._red4Final = data._red1;
								data._green4Final = data._green1;
								data._blue4Final = data._blue1;
								data._alpha4Final = data._alpha1;
							}
							else
							{
								// top left
								data._red1Final = data._red2;
								data._green1Final = data._green2;
								data._blue1Final = data._blue2;
								data._alpha1Final = data._alpha2;
								
								// top right
								data._red2Final = data._red1;
								data._green2Final = data._green1;
								data._blue2Final = data._blue1;
								data._alpha2Final = data._alpha1;
								
								// bottom left
								data._red3Final = data._red4;
								data._green3Final = data._green4;
								data._blue3Final = data._blue4;
								data._alpha3Final = data._alpha4;
								
								// bottom right
								data._red4Final = data._red3;
								data._green4Final = data._green3;
								data._blue4Final = data._blue3;
								data._alpha4Final = data._alpha3;
							}
						}
						else if (data._invertY)
						{
							// top left
							data._red1Final = data._red3;
							data._green1Final = data._green3;
							data._blue1Final = data._blue3;
							data._alpha1Final = data._alpha3;
							
							// top right
							data._red2Final = data._red4;
							data._green2Final = data._green4;
							data._blue2Final = data._blue4;
							data._alpha2Final = data._alpha4;
							
							// bottom left
							data._red3Final = data._red1;
							data._green3Final = data._green1;
							data._blue3Final = data._blue1;
							data._alpha3Final = data._alpha1;
							
							// bottom right
							data._red4Final = data._red2;
							data._green4Final = data._green2;
							data._blue4Final = data._blue2;
							data._alpha4Final = data._alpha2;
						}
						else
						{
							// top left
							data._red1Final = data._red1;
							data._green1Final = data._green1;
							data._blue1Final = data._blue1;
							data._alpha1Final = data._alpha1;
							
							// top right
							data._red2Final = data._red2;
							data._green2Final = data._green2;
							data._blue2Final = data._blue2;
							data._alpha2Final = data._alpha2;
							
							// bottom left
							data._red3Final = data._red3;
							data._green3Final = data._green3;
							data._blue3Final = data._blue3;
							data._alpha3Final = data._alpha3;
							
							// bottom right
							data._red4Final = data._red4;
							data._green4Final = data._green4;
							data._blue4Final = data._blue4;
							data._alpha4Final = data._alpha4;
						}
					}
				}
			}
		}
		
		if (this.__useColorOffset && data._colorOffsetChanged)
		{
			data._colorOffsetChanged = false;
			
			if (this.__simpleColor)
			{
				if (data._uniformColorOffset)
				{
					// top left / all (if uniform color)
					this.__alpha = data._alphaOffset1;
					this.__red = data._redOffset1;
					this.__green = data._greenOffset1;
					this.__blue = data._blueOffset1;
					normalizeColor();
					data._colorOffset1Final = data._colorOffset2Final = data._colorOffset3Final = data._colorOffset4Final = getColorOffset();
				}
				else
				{
					// top left / all (if uniform color)
					this.__alpha = data._alphaOffset1;
					this.__red = data._redOffset1;
					this.__green = data._greenOffset1;
					this.__blue = data._blueOffset1;
					normalizeColor();
					data._colorOffset1Final = getColorOffset();
					
					// top right
					this.__alpha = data._alphaOffset2;
					this.__red = data._redOffset2;
					this.__green = data._greenOffset2;
					this.__blue = data._blueOffset2;
					normalizeColor();
					data._colorOffset2Final = getColorOffset();
					
					// bottom left
					this.__alpha = data._alphaOffset3;
					this.__red = data._redOffset3;
					this.__green = data._greenOffset3;
					this.__blue = data._blueOffset3;
					normalizeColor();
					data._colorOffset3Final = getColorOffset();
					
					// bottom right
					this.__alpha = data._alphaOffset4;
					this.__red = data._redOffset4;
					this.__green = data._greenOffset4;
					this.__blue = data._blueOffset4;
					normalizeColor();
					data._colorOffset4Final = getColorOffset();
				}
			}
			else
			{
				if (this.__pmaForColorOffset)
				{
					if (data._uniformColorOffset)
					{
						this.__alpha = data._alphaOffset1;
						data._redOffset1Final = data._redOffset2Final = data._redOffset3Final = data._redOffset4Final = data._redOffset1 * this.__alpha;
						data._greenOffset1Final = data._greenOffset2Final = data._greenOffset3Final = data._greenOffset4Final = data._greenOffset1 * this.__alpha;
						data._blueOffset1Final = data._blueOffset2Final = data._blueOffset3Final = data._blueOffset4Final = data._blueOffset1 * this.__alpha;
						data._alphaOffset1Final = data._alphaOffset2Final = data._alphaOffset3Final = data._alphaOffset4Final = this.__alpha;
					}
					else
					{
						if (data._invertX)
						{
							if (data._invertY)
							{
								// top left
								this.__alpha = data._alphaOffset4;
								data._redOffset1Final = data._redOffset4 * this.__alpha;
								data._greenOffset1Final = data._greenOffset4 * this.__alpha;
								data._blueOffset1Final = data._blueOffset4 * this.__alpha;
								data._alphaOffset1Final = this.__alpha;
								
								// top right
								this.__alpha = data._alphaOffset3;
								data._redOffset2Final = data._redOffset3 * this.__alpha;
								data._greenOffset2Final = data._greenOffset3 * this.__alpha;
								data._blueOffset2Final = data._blueOffset3 * this.__alpha;
								data._alphaOffset2Final = this.__alpha;
								
								// bottom left
								this.__alpha = data._alphaOffset2;
								data._redOffset3Final = data._redOffset2 * this.__alpha;
								data._greenOffset3Final = data._greenOffset2 * this.__alpha;
								data._blueOffset3Final = data._blueOffset2 * this.__alpha;
								data._alphaOffset3Final = this.__alpha;
								
								// bottom right
								this.__alpha = data._alphaOffset1;
								data._redOffset4Final = data._redOffset1 * this.__alpha;
								data._greenOffset4Final = data._greenOffset1 * this.__alpha;
								data._blueOffset4Final = data._blueOffset1 * this.__alpha;
								data._alphaOffset4Final = this.__alpha;
							}
							else
							{
								// top left
								this.__alpha = data._alphaOffset2;
								data._redOffset1Final = data._redOffset2 * this.__alpha;
								data._greenOffset1Final = data._greenOffset2 * this.__alpha;
								data._blueOffset1Final = data._blueOffset2 * this.__alpha;
								data._alphaOffset1Final = this.__alpha;
								
								// top right
								this.__alpha = data._alphaOffset1;
								data._redOffset2Final = data._redOffset1 * this.__alpha;
								data._greenOffset2Final = data._greenOffset1 * this.__alpha;
								data._blueOffset2Final = data._blueOffset1 * this.__alpha;
								data._alphaOffset2Final = this.__alpha;
								
								// bottom left
								this.__alpha = data._alphaOffset4;
								data._redOffset3Final = data._redOffset4 * this.__alpha;
								data._greenOffset3Final = data._greenOffset4 * this.__alpha;
								data._blueOffset3Final = data._blueOffset4 * this.__alpha;
								data._alphaOffset3Final = this.__alpha;
								
								// bottom right
								this.__alpha = data._alphaOffset3;
								data._redOffset4Final = data._redOffset3 * this.__alpha;
								data._greenOffset4Final = data._greenOffset3 * this.__alpha;
								data._blueOffset4Final = data._blueOffset3 * this.__alpha;
								data._alphaOffset4Final = this.__alpha;
							}
						}
						else if (data._invertY)
						{
							// top left
							this.__alpha = data._alphaOffset3;
							data._redOffset1Final = data._redOffset3 * this.__alpha;
							data._greenOffset1Final = data._greenOffset3 * this.__alpha;
							data._blueOffset1Final = data._blueOffset3 * this.__alpha;
							data._alphaOffset1Final = this.__alpha;
							
							// top right
							this.__alpha = data._alphaOffset4;
							data._redOffset2Final = data._redOffset4 * this.__alpha;
							data._greenOffset2Final = data._greenOffset4 * this.__alpha;
							data._blueOffset2Final = data._blueOffset4 * this.__alpha;
							data._alphaOffset2Final = this.__alpha;
							
							// bottom left
							this.__alpha = data._alphaOffset1;
							data._redOffset3Final = data._redOffset1 * this.__alpha;
							data._greenOffset3Final = data._greenOffset1 * this.__alpha;
							data._blueOffset3Final = data._blueOffset1 * this.__alpha;
							data._alphaOffset3Final = this.__alpha;
							
							// bottom right
							this.__alpha = data._alphaOffset2;
							data._redOffset4Final = data._redOffset2 * this.__alpha;
							data._greenOffset4Final = data._greenOffset2 * this.__alpha;
							data._blueOffset4Final = data._blueOffset2 * this.__alpha;
							data._alphaOffset4Final = this.__alpha;
						}
						else
						{
							// top left
							this.__alpha = data._alphaOffset1;
							data._redOffset1Final = data._redOffset1 * this.__alpha;
							data._greenOffset1Final = data._greenOffset1 * this.__alpha;
							data._blueOffset1Final = data._blueOffset1 * this.__alpha;
							data._alphaOffset1Final = this.__alpha;
							
							// top right
							this.__alpha = data._alphaOffset2;
							data._redOffset2Final = data._redOffset2 * this.__alpha;
							data._greenOffset2Final = data._greenOffset2 * this.__alpha;
							data._blueOffset2Final = data._blueOffset2 * this.__alpha;
							data._alphaOffset2Final = this.__alpha;
							
							// bottom left
							this.__alpha = data._alphaOffset3;
							data._redOffset3Final = data._redOffset3 * this.__alpha;
							data._greenOffset3Final = data._greenOffset3 * this.__alpha;
							data._blueOffset3Final = data._blueOffset3 * this.__alpha;
							data._alphaOffset3Final = this.__alpha;
							
							// bottom right
							this.__alpha = data._alphaOffset4;
							data._redOffset4Final = data._redOffset4 * this.__alpha;
							data._greenOffset4Final = data._greenOffset4 * this.__alpha;
							data._blueOffset4Final = data._blueOffset4 * this.__alpha;
							data._alphaOffset4Final = this.__alpha;
						}
					}
				}
				else
				{
					if (data._uniformColorOffset)
					{
						data._redOffset1Final = data._redOffset2Final = data._redOffset3Final = data._redOffset4Final = data._redOffset1;
						data._greenOffset1Final = data._greenOffset2Final = data._greenOffset3Final = data._greenOffset4Final = data._greenOffset1;
						data._blueOffset1Final = data._blueOffset2Final = data._blueOffset3Final = data._blueOffset4Final = data._blueOffset1;
						data._alphaOffset1Final = data._alphaOffset2Final = data._alphaOffset3Final = data._alphaOffset4Final = data._alphaOffset1;
					}
					else
					{
						if (data._invertX)
						{
							if (data._invertY)
							{
								// top left
								data._redOffset1Final = data._redOffset4;
								data._greenOffset1Final = data._greenOffset4;
								data._blueOffset1Final = data._blueOffset4;
								data._alphaOffset1Final = data._alphaOffset4;
								
								// top right
								data._redOffset2Final = data._redOffset3;
								data._greenOffset2Final = data._greenOffset3;
								data._blueOffset2Final = data._blueOffset3;
								data._alphaOffset2Final = data._alphaOffset3;
								
								// bottom left
								data._redOffset3Final = data._redOffset2;
								data._greenOffset3Final = data._greenOffset2;
								data._blueOffset3Final = data._blueOffset2;
								data._alphaOffset3Final = data._alphaOffset2;
								
								// bottom right
								data._redOffset4Final = data._redOffset1;
								data._greenOffset4Final = data._greenOffset1;
								data._blueOffset4Final = data._blueOffset1;
								data._alphaOffset4Final = data._alphaOffset1;
							}
							else
							{
								// top left
								data._redOffset1Final = data._redOffset2;
								data._greenOffset1Final = data._greenOffset2;
								data._blueOffset1Final = data._blueOffset2;
								data._alphaOffset1Final = data._alphaOffset2;
								
								// top right
								data._redOffset2Final = data._redOffset1;
								data._greenOffset2Final = data._greenOffset1;
								data._blueOffset2Final = data._blueOffset1;
								data._alphaOffset2Final = data._alphaOffset1;
								
								// bottom left
								data._redOffset3Final = data._redOffset4;
								data._greenOffset3Final = data._greenOffset4;
								data._blueOffset3Final = data._blueOffset4;
								data._alphaOffset3Final = data._alphaOffset4;
								
								// bottom right
								data._redOffset4Final = data._redOffset3;
								data._greenOffset4Final = data._greenOffset3;
								data._blueOffset4Final = data._blueOffset3;
								data._alphaOffset4Final = data._alphaOffset3;
							}
						}
						else if (data._invertY)
						{
							// top left
							data._redOffset1Final = data._redOffset3;
							data._greenOffset1Final = data._greenOffset3;
							data._blueOffset1Final = data._blueOffset3;
							data._alphaOffset1Final = data._alphaOffset3;
							
							// top right
							data._redOffset2Final = data._redOffset4;
							data._greenOffset2Final = data._greenOffset4;
							data._blueOffset2Final = data._blueOffset4;
							data._alphaOffset2Final = data._alphaOffset4;
							
							// bottom left
							data._redOffset3Final = data._redOffset1;
							data._greenOffset3Final = data._greenOffset1;
							data._blueOffset3Final = data._blueOffset1;
							data._alphaOffset3Final = data._alphaOffset1;
							
							// bottom right
							data._redOffset4Final = data._redOffset2;
							data._greenOffset4Final = data._greenOffset2;
							data._blueOffset4Final = data._blueOffset2;
							data._alphaOffset4Final = data._alphaOffset2;
						}
						else
						{
							// top left
							data._redOffset1Final = data._redOffset1;
							data._greenOffset1Final = data._greenOffset1;
							data._blueOffset1Final = data._blueOffset1;
							data._alphaOffset1Final = data._alphaOffset1;
							
							// top right
							data._redOffset2Final = data._redOffset2;
							data._greenOffset2Final = data._greenOffset2;
							data._blueOffset2Final = data._blueOffset2;
							data._alphaOffset2Final = data._alphaOffset2;
							
							// bottom left
							data._redOffset3Final = data._redOffset3;
							data._greenOffset3Final = data._greenOffset3;
							data._blueOffset3Final = data._blueOffset3;
							data._alphaOffset3Final = data._alphaOffset3;
							
							// bottom right
							data._redOffset4Final = data._redOffset4;
							data._greenOffset4Final = data._greenOffset4;
							data._blueOffset4Final = data._blueOffset4;
							data._alphaOffset4Final = data._alphaOffset4;
						}
					}
				}
			}
		}
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
			if (data._invertY)
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
	private var __green:Float;
	private var __blue:Float;
	private var __alpha:Float;
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
	private var __pmaForColorOffset:Bool;
	private var __useColor:Bool;
	private var __useDisplayColor:Bool;
	private var __useColorOffset:Bool;
	private var __simpleColor:Bool;
	private var __numQuads:Int;
	private var __totalQuads:Int;
	private var __storeBounds:Bool;
	private var __boundsIndex:Int;
	
}