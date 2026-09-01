package massive.display.base;
import haxe.Constraints.Function;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;
import massive.display.render.RenderData;
#if flash
import openfl.Memory;
#end
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * ...
 * @author Matse
 */
@:access(massive.display.Img)
abstract class ContainerBase extends DisplayBase
{
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
	public var color(get, set):Int;
	public var colorOffset(get, set):Int;
	public var red:Float = 1.0;
	public var redOffset:Float = 0.0;
	public var green:Float = 1.0;
	public var greenOffset:Float = 0.0;
	public var blue:Float = 1.0;
	public var blueOffset:Float = 0.0;
	public var alpha:Float = 1.0;
	public var alphaOffset:Float = 0.0;
	
	private function get_color():Int
	{
		var r:Float = this.red > 1.0 ? 1.0 : this.red < 0.0 ? 0.0 : this.red;
		var g:Float = this.green > 1.0 ? 1.0 : this.green < 0.0 ? 0.0 : this.green;
		var b:Float = this.blue > 1.0 ? 1.0 : this.blue < 0.0 ? 0.0 : this.blue;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color(value:Int):Int
	{
		this.red = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.green = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blue = (value & 0xFF) / 255.0;
		return value;
	}
	
	private function get_colorOffset():Int
	{
		var r:Float = this.redOffset > 1.0 ? 1.0 : this.redOffset < 0.0 ? 0.0 : this.redOffset;
		var g:Float = this.greenOffset > 1.0 ? 1.0 : this.greenOffset < 0.0 ? 0.0 : this.greenOffset;
		var b:Float = this.blueOffset > 1.0 ? 1.0 : this.blueOffset < 0.0 ? 0.0 : this.blueOffset;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset(value:Int):Int
	{
		this.redOffset = (Std.int(value >> 16) & 0xFF) / 255.0;
        this.greenOffset = (Std.int(value >> 8) & 0xFF) / 255.0;
        this.blueOffset = (value & 0xFF) / 255.0;
		return value;
	}
	
	private var _colorChanged:Bool;
	private var _colorOffsetChanged:Bool;
	
	private var _eventDispatcher:EventDispatcher = new EventDispatcher();
	
	public function new()
	{
		super();
		this.isContainer = true;
	}
	
	public function clear():Void
	{
		this.__redBasePrevious = this.__greenBasePrevious = this.__blueBasePrevious = this.__alphaBasePrevious = 1.0;
		this.__redOffsetBasePrevious = this.__greenOffsetBasePrevious = this.__blueOffsetBasePrevious = this.__alphaBasePrevious = 0.0;
	}
	
	inline public function addEventListener(type:String, listener:Function):Void
	{
		this._eventDispatcher.addEventListener(type, listener);
	}
	
	inline public function removeEventListener(type:String, listener:Function):Void
	{
		this._eventDispatcher.removeEventListener(type, listener);
	}
	
	inline public function removeEventListeners(type:String = null):Void
	{
		this._eventDispatcher.removeEventListeners(type);
	}
	
	inline public function dispatchEvent(event:Event):Void
	{
		this._eventDispatcher.dispatchEvent(event);
	}
	
	inline public function dispatchEventWith(type:String, bubbles:Bool = false, data:Dynamic = null):Void
	{
		this._eventDispatcher.dispatchEventWith(type, bubbles, data);
	}
	
	inline public function hasEventListener(type:String, listener:Dynamic = null):Bool
	{
		return this._eventDispatcher.hasEventListener(type, listener);
	}
	
	inline private function prepareCommon(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		this.__maxQuads = maxQuads;
		this.__renderData = renderData;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		//this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__simpleColor = renderData.useSimpleColor;
		this.__boundsData = boundsData;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		
		this.__renderOffsetX = renderOffsetX + this.x;
		this.__renderOffsetY = renderOffsetY + this.y;
		
		if (this.__useColor)
		{
			this.__redBase = renderData.red *= this.red;
			this.__greenBase = renderData.green *= this.green;
			this.__blueBase = renderData.blue *= this.blue;
			this.__alphaBase = renderData.alpha *= this.alpha;
			this._colorChanged = this.__redBase != this.__redBasePrevious || this.__greenBase != this.__greenBasePrevious || 
								 this.__blueBase != this.__blueBasePrevious || this.__alphaBase != this.__alphaBasePrevious;
			if (this._colorChanged)
			{
				this.__redBasePrevious = this.__redBase;
				this.__greenBasePrevious = this.__greenBase;
				this.__blueBasePrevious = this.__blueBase;
				this.__alphaBasePrevious = this.__alphaBase;
			}
		}
		
		if (this.__useColorOffset)
		{
			this.__redOffsetBase = renderData.redOffset += this.redOffset;
			this.__greenOffsetBase = renderData.greenOffset += this.greenOffset;
			this.__blueOffsetBase = renderData.blueOffset += this.blueOffset;
			this.__alphaOffsetBase = renderData.alphaOffset += this.alphaOffset;
			this._colorOffsetChanged = this.__redOffsetBase != this.__redOffsetBasePrevious || this.__greenOffsetBase != this.__greenOffsetBasePrevious || 
									   this.__blueOffsetBase != this.__blueOffsetBasePrevious || this.__alphaOffsetBase != this.__alphaOffsetBasePrevious;
			if (this._colorOffsetChanged)
			{
				this.__redOffsetBasePrevious = this.__redOffsetBase;
				this.__greenOffsetBasePrevious = this.__greenOffsetBase;
				this.__blueOffsetBasePrevious = this.__blueOffsetBase;
				this.__alphaOffsetBasePrevious = this.__alphaOffsetBase;
			}
		}
	}
	
	inline private function finishCommon():Void
	{
		this.__renderData.numQuads = this.__quadsWritten;
		
		if (this.__useColor)
		{
			this.__renderData.red /= this.red;
			this.__renderData.green /= this.green;
			this.__renderData.blue /= this.blue;
			this.__renderData.alpha /= this.alpha;
		}
		
		if (this.__useColorOffset)
		{
			this.__renderData.redOffset -= this.redOffset;
			this.__renderData.greenOffset -= this.greenOffset;
			this.__renderData.blueOffset -= this.blueOffset;
			this.__renderData.alphaOffset -= this.alphaOffset;
		}
	}
	
	inline private function prepareDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		this.__byteData = byteData;
		
		prepareCommon(maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
	}
	
	inline private function finishDataBytes():Void
	{
		finishCommon();
	}
	
	#if flash
	inline private function prepareDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Void
	{
		this.__position = renderData.position;
		
		prepareCommon(maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
	}
	
	inline private function finishDataBytesMemory():Void
	{
		finishCommon();
		this.__renderData.position = this.__position;
	}
	#end
	
	#if !flash
	inline private function prepareDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		this.__floatData = floatData;
		this.__position = renderData.position;
		
		prepareCommon(maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
	}
	
	inline private function finishDataFloat32Array():Void
	{
		finishCommon();
		this.__renderData.position = this.__position;
	}
	#end
	
	inline private function prepareDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		this.__vectorData = vectorData;
		this.__position = renderData.position;
		
		prepareCommon(maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
	}
	
	inline private function finishDataVector():Void
	{
		finishCommon();
		this.__renderData.position = this.__position;
	}
	
	abstract public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void;
	
	#if flash
	abstract public function writeDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Void;
	#end
	
	#if !flash
	abstract public function writeDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void;
	#end
	
	abstract public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void;
	
	abstract public function writeBoundsData(boundsData:#if flash Vector<Float> #else Array<Float> #end, renderOffsetX:Float, renderOffsetY:Float):Void;
	
	inline private function writeImageBounds():Void
	{
		this.__x = this.__image.x + this.__image.offsetX + this.__renderOffsetX;
		this.__y = this.__image.y + this.__image.offsetY + this.__renderOffsetY;
		
		updateTransform();
		
		this.__boundsData[++this.__position] = this.__x + this.__x1;
		this.__boundsData[++this.__position] = this.__y + this.__y1;
		this.__boundsData[++this.__position] = this.__x + this.__x2;
		this.__boundsData[++this.__position] = this.__y + this.__y2;
		this.__boundsData[++this.__position] = this.__x + this.__x3;
		this.__boundsData[++this.__position] = this.__y + this.__y3;
		this.__boundsData[++this.__position] = this.__x + this.__x4;
		this.__boundsData[++this.__position] = this.__y + this.__y4;
	}
	
	inline private function writeImageBytes():Void
	{
		setupImage();
		
		// TOP LEFT
		// u1 v1
		this.__byteData.writeFloat(this.__x + this.__x1);
		this.__byteData.writeFloat(this.__y + this.__y1);
		this.__byteData.writeFloat(this.__u1);
		this.__byteData.writeFloat(this.__v1);
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__color);
				}
				else
				{
					this.__byteData.writeFloat(this.__red);
					this.__byteData.writeFloat(this.__green);
					this.__byteData.writeFloat(this.__blue);
					this.__byteData.writeFloat(this.__alpha);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__image._color1Final);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._red1Final);
					this.__byteData.writeFloat(this.__image._green1Final);
					this.__byteData.writeFloat(this.__image._blue1Final);
					this.__byteData.writeFloat(this.__image._alpha1Final);
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__colorOffset);
				}
				else
				{
					this.__byteData.writeFloat(this.__redOffset);
					this.__byteData.writeFloat(this.__greenOffset);
					this.__byteData.writeFloat(this.__blueOffset);
					this.__byteData.writeFloat(this.__alphaOffset);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__image._colorOffset1Final);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._redOffset1Final);
					this.__byteData.writeFloat(this.__image._blueOffset1Final);
					this.__byteData.writeFloat(this.__image._blueOffset1Final);
					this.__byteData.writeFloat(this.__image._alphaOffset1Final);
				}
			}
		}
		if (this.__multiTexturing) this.__byteData.writeFloat(this.__textureIndex);
		
		// TOP RIGHT
		// u2 v1
		this.__byteData.writeFloat(this.__x + this.__x2);
		this.__byteData.writeFloat(this.__y + this.__y2);
		this.__byteData.writeFloat(this.__u2);
		this.__byteData.writeFloat(this.__v1);
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__color);
				}
				else
				{
					this.__byteData.writeFloat(this.__red);
					this.__byteData.writeFloat(this.__green);
					this.__byteData.writeFloat(this.__blue);
					this.__byteData.writeFloat(this.__alpha);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__vertexColor.color2);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._red2Final);
					this.__byteData.writeFloat(this.__image._green2Final);
					this.__byteData.writeFloat(this.__image._blue2Final);
					this.__byteData.writeFloat(this.__image._alpha2Final);
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__colorOffset);
				}
				else
				{
					this.__byteData.writeFloat(this.__redOffset);
					this.__byteData.writeFloat(this.__greenOffset);
					this.__byteData.writeFloat(this.__blueOffset);
					this.__byteData.writeFloat(this.__alphaOffset);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__image._colorOffset2Final);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._redOffset2Final);
					this.__byteData.writeFloat(this.__image._greenOffset2Final);
					this.__byteData.writeFloat(this.__image._blueOffset2Final);
					this.__byteData.writeFloat(this.__image._alphaOffset2Final);
				}
			}
		}
		if (this.__multiTexturing) this.__byteData.writeFloat(this.__textureIndex);
		
		// BOTTOM LEFT
		// u1 v2
		this.__byteData.writeFloat(this.__x + this.__x3);
		this.__byteData.writeFloat(this.__y + this.__y3);
		this.__byteData.writeFloat(this.__u1);
		this.__byteData.writeFloat(this.__v2);
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__color);
				}
				else
				{
					this.__byteData.writeFloat(this.__red);
					this.__byteData.writeFloat(this.__green);
					this.__byteData.writeFloat(this.__blue);
					this.__byteData.writeFloat(this.__alpha);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__image._color3Final);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._red3Final);
					this.__byteData.writeFloat(this.__image._green3Final);
					this.__byteData.writeFloat(this.__image._blue3Final);
					this.__byteData.writeFloat(this.__image._alpha3Final);
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__colorOffset);
				}
				else
				{
					this.__byteData.writeFloat(this.__redOffset);
					this.__byteData.writeFloat(this.__greenOffset);
					this.__byteData.writeFloat(this.__blueOffset);
					this.__byteData.writeFloat(this.__alphaOffset);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__image._colorOffset3Final);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._redOffset3Final);
					this.__byteData.writeFloat(this.__image._greenOffset3Final);
					this.__byteData.writeFloat(this.__image._blueOffset3Final);
					this.__byteData.writeFloat(this.__image._alphaOffset3Final);
				}
			}
		}
		if (this.__multiTexturing) this.__byteData.writeFloat(this.__textureIndex);
		
		// BOTTOM RIGHT
		// u2 v2
		this.__byteData.writeFloat(this.__x + this.__x4);
		this.__byteData.writeFloat(this.__y + this.__y4);
		this.__byteData.writeFloat(this.__u2);
		this.__byteData.writeFloat(this.__v2);
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__color);
				}
				else
				{
					this.__byteData.writeFloat(this.__red);
					this.__byteData.writeFloat(this.__green);
					this.__byteData.writeFloat(this.__blue);
					this.__byteData.writeFloat(this.__alpha);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__image._color4Final);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._red4Final);
					this.__byteData.writeFloat(this.__image._green4Final);
					this.__byteData.writeFloat(this.__image._blue4Final);
					this.__byteData.writeFloat(this.__image._alpha4Final);
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__colorOffset);
				}
				else
				{
					this.__byteData.writeFloat(this.__redOffset);
					this.__byteData.writeFloat(this.__greenOffset);
					this.__byteData.writeFloat(this.__blueOffset);
					this.__byteData.writeFloat(this.__alphaOffset);
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__byteData.writeInt(this.__image._colorOffset4Final);
				}
				else
				{
					this.__byteData.writeFloat(this.__image._redOffset4Final);
					this.__byteData.writeFloat(this.__image._greenOffset4Final);
					this.__byteData.writeFloat(this.__image._blueOffset4Final);
					this.__byteData.writeFloat(this.__image._alphaOffset4Final);
				}
			}
		}
		if (this.__multiTexturing) this.__byteData.writeFloat(this.__textureIndex);
	}
	
	#if flash
	private function writeImageBytesMemory():Void
	{
		setupImage();
		
		// TOP LEFT
		// u1 v1
		Memory.setFloat(this.__position, this.__x + this.__x1);
		Memory.setFloat(this.__position += 4, this.__y + this.__y1);
		Memory.setFloat(this.__position += 4, this.__u1);
		Memory.setFloat(this.__position += 4, this.__v1);
		if (this.__useColor)
		{
			if (this.__uniformColor)
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
			else
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
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
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
			else
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
		}
		if (this.__multiTexturing) Memory.setFloat(this.__position += 4, this.__textureIndex);
		
		// TOP RIGHT
		// u2 v1
		Memory.setFloat(this.__position += 4, this.__x + this.__x2);
		Memory.setFloat(this.__position += 4, this.__y + this.__y2);
		Memory.setFloat(this.__position += 4, this.__u2);
		Memory.setFloat(this.__position += 4, this.__v1);
		if (this.__useColor)
		{
			if (this.__uniformColor)
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
			else
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
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
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
			else
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
		}
		if (this.__multiTexturing) Memory.setFloat(this.__position += 4, this.__textureIndex);
		
		// BOTTOM LEFT
		// u1 v2
		Memory.setFloat(this.__position += 4, this.__x + this.__x3);
		Memory.setFloat(this.__position += 4, this.__y + this.__y3);
		Memory.setFloat(this.__position += 4, this.__u1);
		Memory.setFloat(this.__position += 4, this.__v2);
		if (this.__useColor)
		{
			if (this.__uniformColor)
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
			else
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
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
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
			else
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
		}
		if (this.__multiTexturing) Memory.setFloat(this.__position += 4, this.__textureIndex);
		
		// BOTTOM RIGHT
		// u2 v2
		Memory.setFloat(this.__position += 4, this.__x + this.__x4);
		Memory.setFloat(this.__position += 4, this.__y + this.__y4);
		Memory.setFloat(this.__position += 4, this.__u2);
		Memory.setFloat(this.__position += 4, this.__v2);
		if (this.__useColor)
		{
			if (this.__uniformColor)
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
			else
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
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
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
			else
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
		}
		if (this.__multiTexturing) Memory.setFloat(this.__position += 4, this.__textureIndex);
		
		this.__position += 4;
	}
	#end
	
	#if !flash
	inline private function writeImageFloat32Array():Void
	{
		setupImage();
		
		// TOP LEFT
		// u1 v1
		this.__floatData[this.__position] = this.__x + this.__x1;
		this.__floatData[++this.__position] = this.__y + this.__y1;
		this.__floatData[++this.__position] = this.__u1;
		this.__floatData[++this.__position] = this.__v1;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__color;
				}
				else
				{
					this.__floatData[++this.__position] = this.__red;
					this.__floatData[++this.__position] = this.__green;
					this.__floatData[++this.__position] = this.__blue;
					this.__floatData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__vertexColor.color1;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._red1Final;
					this.__floatData[++this.__position] = this.__image._green1Final;
					this.__floatData[++this.__position] = this.__image._blue1Final;
					this.__floatData[++this.__position] = this.__image._alpha1Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__floatData[++this.__position] = this.__redOffset;
					this.__floatData[++this.__position] = this.__greenOffset;
					this.__floatData[++this.__position] = this.__blueOffset;
					this.__floatData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__image._colorOffset1Final;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._redOffset1Final;
					this.__floatData[++this.__position] = this.__image._greenOffset1Final;
					this.__floatData[++this.__position] = this.__image._blueOffset1Final;
					this.__floatData[++this.__position] = this.__image._alphaOffset1Final;
				}
			}
		}
		if (this.__multiTexturing) this.__floatData[++this.__position] = this.__textureIndex;
		
		// TOP RIGHT
		// u2 v1
		this.__floatData[++this.__position] = this.__x + this.__x2;
		this.__floatData[++this.__position] = this.__y + this.__y2;
		this.__floatData[++this.__position] = this.__u2;
		this.__floatData[++this.__position] = this.__v1;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__color;
				}
				else
				{
					this.__floatData[++this.__position] = this.__red;
					this.__floatData[++this.__position] = this.__green;
					this.__floatData[++this.__position] = this.__blue;
					this.__floatData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__image._color2Final;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._red2Final;
					this.__floatData[++this.__position] = this.__image._green2Final;
					this.__floatData[++this.__position] = this.__image._blue2Final;
					this.__floatData[++this.__position] = this.__image._alpha2Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__floatData[++this.__position] = this.__redOffset;
					this.__floatData[++this.__position] = this.__greenOffset;
					this.__floatData[++this.__position] = this.__blueOffset;
					this.__floatData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__image._colorOffset2Final;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._redOffset2Final;
					this.__floatData[++this.__position] = this.__image._greenOffset2Final;
					this.__floatData[++this.__position] = this.__image._blueOffset2Final;
					this.__floatData[++this.__position] = this.__image._alphaOffset2Final;
				}
			}
		}
		if (this.__multiTexturing) this.__floatData[++this.__position] = this.__textureIndex;
		
		// BOTTOM LEFT
		// u1 v2
		this.__floatData[++this.__position] = this.__x + this.__x3;
		this.__floatData[++this.__position] = this.__y + this.__y3;
		this.__floatData[++this.__position] = this.__u1;
		this.__floatData[++this.__position] = this.__v2;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__color;
				}
				else
				{
					this.__floatData[++this.__position] = this.__red;
					this.__floatData[++this.__position] = this.__green;
					this.__floatData[++this.__position] = this.__blue;
					this.__floatData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__image._color3Final;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._red3Final;
					this.__floatData[++this.__position] = this.__image._green3Final;
					this.__floatData[++this.__position] = this.__image._blue3Final;
					this.__floatData[++this.__position] = this.__image._alpha3Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__floatData[++this.__position] = this.__redOffset;
					this.__floatData[++this.__position] = this.__greenOffset;
					this.__floatData[++this.__position] = this.__blueOffset;
					this.__floatData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__image._colorOffset3Final;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._redOffset3Final;
					this.__floatData[++this.__position] = this.__image._greenOffset3Final;
					this.__floatData[++this.__position] = this.__image._blueOffset3Final;
					this.__floatData[++this.__position] = this.__image._alphaOffset3Final;
				}
			}
		}
		if (this.__multiTexturing) this.__floatData[++this.__position] = this.__textureIndex;
		
		// BOTTOM RIGHT
		// u2 v2
		this.__floatData[++this.__position] = this.__x + this.__x4;
		this.__floatData[++this.__position] = this.__y + this.__y4;
		this.__floatData[++this.__position] = this.__u2;
		this.__floatData[++this.__position] = this.__v2;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__color;
				}
				else
				{
					this.__floatData[++this.__position] = this.__red;
					this.__floatData[++this.__position] = this.__green;
					this.__floatData[++this.__position] = this.__blue;
					this.__floatData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__image._color4Final;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._red4Final;
					this.__floatData[++this.__position] = this.__image._green4Final;
					this.__floatData[++this.__position] = this.__image._blue4Final;
					this.__floatData[++this.__position] = this.__image._alpha4Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__floatData[++this.__position] = this.__redOffset;
					this.__floatData[++this.__position] = this.__greenOffset;
					this.__floatData[++this.__position] = this.__blueOffset;
					this.__floatData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__floatData[++this.__position] = this.__image._colorOffset4Final;
				}
				else
				{
					this.__floatData[++this.__position] = this.__image._redOffset4Final;
					this.__floatData[++this.__position] = this.__image._greenOffset4Final;
					this.__floatData[++this.__position] = this.__image._blueOffset4Final;
					this.__floatData[++this.__position] = this.__image._alphaOffset4Final;
				}
			}
		}
		if (this.__multiTexturing) this.__floatData[++this.__position] = this.__textureIndex;
		
		++this.__position;
	}
	#end
	
	inline private function writeImageVector():Void
	{
		setupImage();
		
		// TOP LEFT
		// u1 v1
		this.__vectorData[this.__position] = this.__x + this.__x1;
		this.__vectorData[++this.__position] = this.__y + this.__y1;
		this.__vectorData[++this.__position] = this.__u1;
		this.__vectorData[++this.__position] = this.__v1;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__color;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__red;
					this.__vectorData[++this.__position] = this.__green;
					this.__vectorData[++this.__position] = this.__blue;
					this.__vectorData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__image._color1Final;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._red1Final;
					this.__vectorData[++this.__position] = this.__image._green1Final;
					this.__vectorData[++this.__position] = this.__image._blue1Final;
					this.__vectorData[++this.__position] = this.__image._alpha1Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__redOffset;
					this.__vectorData[++this.__position] = this.__greenOffset;
					this.__vectorData[++this.__position] = this.__blueOffset;
					this.__vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__image._colorOffset1Final;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._redOffset1Final;
					this.__vectorData[++this.__position] = this.__image._greenOffset1Final;
					this.__vectorData[++this.__position] = this.__image._blueOffset1Final;
					this.__vectorData[++this.__position] = this.__image._alphaOffset1Final;
				}
			}
		}
		if (this.__multiTexturing) this.__vectorData[++this.__position] = this.__textureIndex;
		
		// TOP RIGHT
		// u2 v1
		this.__vectorData[++this.__position] = this.__x + this.__x2;
		this.__vectorData[++this.__position] = this.__y + this.__y2;
		this.__vectorData[++this.__position] = this.__u2;
		this.__vectorData[++this.__position] = this.__v1;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__color;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__red;
					this.__vectorData[++this.__position] = this.__green;
					this.__vectorData[++this.__position] = this.__blue;
					this.__vectorData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__vertexColor.color2;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._red2Final;
					this.__vectorData[++this.__position] = this.__image._green2Final;
					this.__vectorData[++this.__position] = this.__image._blue2Final;
					this.__vectorData[++this.__position] = this.__image._alpha2Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__redOffset;
					this.__vectorData[++this.__position] = this.__greenOffset;
					this.__vectorData[++this.__position] = this.__blueOffset;
					this.__vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__image._colorOffset2Final;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._redOffset2Final;
					this.__vectorData[++this.__position] = this.__image._greenOffset2Final;
					this.__vectorData[++this.__position] = this.__image._blueOffset2Final;
					this.__vectorData[++this.__position] = this.__image._alphaOffset2Final;
				}
			}
		}
		if (this.__multiTexturing) this.__vectorData[++this.__position] = this.__textureIndex;
		
		// BOTTOM LEFT
		// u1 v2
		this.__vectorData[++this.__position] = this.__x + this.__x3;
		this.__vectorData[++this.__position] = this.__y + this.__y3;
		this.__vectorData[++this.__position] = this.__u1;
		this.__vectorData[++this.__position] = this.__v2;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__color;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__red;
					this.__vectorData[++this.__position] = this.__green;
					this.__vectorData[++this.__position] = this.__blue;
					this.__vectorData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__image._color3Final;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._red3Final;
					this.__vectorData[++this.__position] = this.__image._green3Final;
					this.__vectorData[++this.__position] = this.__image._blue3Final;
					this.__vectorData[++this.__position] = this.__image._alpha3Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__redOffset;
					this.__vectorData[++this.__position] = this.__greenOffset;
					this.__vectorData[++this.__position] = this.__blueOffset;
					this.__vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__image._colorOffset3Final;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._redOffset3Final;
					this.__vectorData[++this.__position] = this.__image._greenOffset3Final;
					this.__vectorData[++this.__position] = this.__image._blueOffset3Final;
					this.__vectorData[++this.__position] = this.__image._alphaOffset3Final;
				}
			}
		}
		if (this.__multiTexturing) this.__vectorData[++this.__position] = this.__textureIndex;
		
		// BOTTOM RIGHT
		// u2 v2
		this.__vectorData[++this.__position] = this.__x + this.__x4;
		this.__vectorData[++this.__position] = this.__y + this.__y4;
		this.__vectorData[++this.__position] = this.__u2;
		this.__vectorData[++this.__position] = this.__v2;
		if (this.__useColor)
		{
			if (this.__uniformColor)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__color;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__red;
					this.__vectorData[++this.__position] = this.__green;
					this.__vectorData[++this.__position] = this.__blue;
					this.__vectorData[++this.__position] = this.__alpha;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__image._color4Final;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._red4Final;
					this.__vectorData[++this.__position] = this.__image._green4Final;
					this.__vectorData[++this.__position] = this.__image._blue4Final;
					this.__vectorData[++this.__position] = this.__image._alpha4Final;
				}
			}
		}
		if (this.__useColorOffset)
		{
			if (this.__uniformColorOffset)
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__colorOffset;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__redOffset;
					this.__vectorData[++this.__position] = this.__greenOffset;
					this.__vectorData[++this.__position] = this.__blueOffset;
					this.__vectorData[++this.__position] = this.__alphaOffset;
				}
			}
			else
			{
				if (this.__simpleColor)
				{
					this.__vectorData[++this.__position] = this.__image._colorOffset4Final;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__image._redOffset4Final;
					this.__vectorData[++this.__position] = this.__image._greenOffset4Final;
					this.__vectorData[++this.__position] = this.__image._blueOffset4Final;
					this.__vectorData[++this.__position] = this.__image._alphaOffset4Final;
				}
			}
		}
		if (this.__multiTexturing) this.__vectorData[++this.__position] = this.__textureIndex;
		
		++this.__position;
	}
	
	inline private function setupImage():Void
	{
		this.__x = this.__image.x + this.__image.offsetX + this.__renderOffsetX;
		this.__y = this.__image.y + this.__image.offsetY + this.__renderOffsetY;
		
		this.__frame = this.__image.frame;
		
		updateTransform();
		
		if (this.__multiTexturing) this.__textureIndex = this.__image.textureIndexReal;
		
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
		
		if (this.__storeBounds)
		{
			this.__boundsData[++this.__boundsIndex] = this.__x + this.__x1;
			this.__boundsData[++this.__boundsIndex] = this.__y + this.__y1;
			this.__boundsData[++this.__boundsIndex] = this.__x + this.__x2;
			this.__boundsData[++this.__boundsIndex] = this.__y + this.__y2;
			this.__boundsData[++this.__boundsIndex] = this.__x + this.__x3;
			this.__boundsData[++this.__boundsIndex] = this.__y + this.__y3;
			this.__boundsData[++this.__boundsIndex] = this.__x + this.__x4;
			this.__boundsData[++this.__boundsIndex] = this.__y + this.__y4;
		}
		
		updateColor();
	}
	
	inline private function updateTransform():Void
	{
		if (this.__image.hasVertexPosition)
		{
			this.__vertexPosition = this.__image.vertexPosition;
			if (this.__image._transformChanged || this.__vertexPosition.isChanging)
			{
				if (this.__image.invertX)
				{
					if (this.__image.invertY)
					{
						this.__x1 = this.__image._x1 = this.__vertexPosition.x1_invertXY * this.__image.scaleX;
						this.__x2 = this.__image._x2 = this.__vertexPosition.x2_invertXY * this.__image.scaleX;
						this.__x3 = this.__image._x3 = this.__vertexPosition.x3_invertXY * this.__image.scaleX;
						this.__x4 = this.__image._x4 = this.__vertexPosition.x4_invertXY * this.__image.scaleX;
						this.__y1 = this.__image._y1 = this.__vertexPosition.y1_invertXY * this.__image.scaleY;
						this.__y2 = this.__image._y2 = this.__vertexPosition.y2_invertXY * this.__image.scaleY;
						this.__y3 = this.__image._y3 = this.__vertexPosition.y3_invertXY * this.__image.scaleY;
						this.__y4 = this.__image._y4 = this.__vertexPosition.y4_invertXY * this.__image.scaleY;
					}
					else
					{
						this.__x1 = this.__image._x1 = this.__vertexPosition.x1_invertX * this.__image.scaleX;
						this.__x2 = this.__image._x2 = this.__vertexPosition.x2_invertX * this.__image.scaleX;
						this.__x3 = this.__image._x3 = this.__vertexPosition.x3_invertX * this.__image.scaleX;
						this.__x4 = this.__image._x4 = this.__vertexPosition.x4_invertX * this.__image.scaleX;
						this.__y1 = this.__image._y1 = this.__vertexPosition.y1_invertX * this.__image.scaleY;
						this.__y2 = this.__image._y2 = this.__vertexPosition.y2_invertX * this.__image.scaleY;
						this.__y3 = this.__image._y3 = this.__vertexPosition.y3_invertX * this.__image.scaleY;
						this.__y4 = this.__image._y4 = this.__vertexPosition.y4_invertX * this.__image.scaleY;
					}
				}
				else if (this.__image.invertY)
				{
					this.__x1 = this.__image._x1 = this.__vertexPosition.x1_invertY * this.__image.scaleX;
					this.__x2 = this.__image._x2 = this.__vertexPosition.x2_invertY * this.__image.scaleX;
					this.__x3 = this.__image._x3 = this.__vertexPosition.x3_invertY * this.__image.scaleX;
					this.__x4 = this.__image._x4 = this.__vertexPosition.x4_invertY * this.__image.scaleX;
					this.__y1 = this.__image._y1 = this.__vertexPosition.y1_invertY * this.__image.scaleY;
					this.__y2 = this.__image._y2 = this.__vertexPosition.y2_invertY * this.__image.scaleY;
					this.__y3 = this.__image._y3 = this.__vertexPosition.y3_invertY * this.__image.scaleY;
					this.__y4 = this.__image._y4 = this.__vertexPosition.y4_invertY * this.__image.scaleY;
				}
				else
				{
					this.__x1 = this.__image._x1 = this.__vertexPosition.x1 * this.__image.scaleX;
					this.__x2 = this.__image._x2 = this.__vertexPosition.x2 * this.__image.scaleX;
					this.__x3 = this.__image._x3 = this.__vertexPosition.x3 * this.__image.scaleX;
					this.__x4 = this.__image._x4 = this.__vertexPosition.x4 * this.__image.scaleX;
					this.__y1 = this.__image._y1 = this.__vertexPosition.y1 * this.__image.scaleY;
					this.__y2 = this.__image._y2 = this.__vertexPosition.y2 * this.__image.scaleY;
					this.__y3 = this.__image._y3 = this.__vertexPosition.y3 * this.__image.scaleY;
					this.__y4 = this.__image._y4 = this.__vertexPosition.y4 * this.__image.scaleY;
				}
				this.__image._transformChanged = false;
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
		}
		else if (this.__image._transformChanged)
		{
			this.__rotationChanged = this.__image._rotationChanged;
			this.__skewXChanged = this.__image._skewXChanged;
			this.__skewYChanged = this.__image._skewYChanged;
			
			if (this.__rotationChanged)
			{
				this.__rotation = this.__image._rotation;
				this.__cosRotation = this.__image._cosRotation = Math.cos(this.__rotation);
				this.__sinRotation = this.__image._sinRotation = Math.sin(this.__rotation);
				this.__image._rotationChanged = false;
			}
			else
			{
				this.__cosRotation = this.__image._cosRotation;
				this.__sinRotation = this.__image._sinRotation;
			}
			
			if (this.__skewXChanged)
			{
				this.__skewX = this.__image._skewX;
				this.__cosSkewX = this.__image._cosSkewX = Math.cos(this.__skewX);
				this.__sinSkewX = this.__image._sinSkewX = -Math.sin(this.__skewX);
				this.__image._skewXChanged = false;
			}
			else
			{
				this.__cosSkewX = this.__image._cosSkewX;
				this.__sinSkewX = this.__image._sinSkewX;
			}
			
			if (this.__skewYChanged)
			{
				this.__skewY = this.__image._skewY;
				this.__cosSkewY = this.__image._cosSkewY = Math.cos(this.__skewY);
				this.__sinSkewY = this.__image._sinSkewY = Math.sin(this.__skewY);
				this.__image._skewYChanged = false;
			}
			else
			{
				this.__cosSkewY = this.__image._cosSkewY;
				this.__sinSkewY = this.__image._sinSkewY;
			}
			
			if (this.__image._sizeXChanged)
			{
				if (this.__image._invertX)
				{
					this.__leftOffset = this.__image._leftOffset = -this.__frame.rightWidth * this.__image._scaleX;
					this.__rightOffset = this.__image._rightOffset = this.__frame.leftWidth * this.__image._scaleX;
				}
				else
				{
					this.__leftOffset = this.__image._leftOffset = -this.__frame.leftWidth * this.__image._scaleX;
					this.__rightOffset = this.__image._rightOffset = this.__frame.rightWidth * this.__image._scaleX;
				}
				this.__image._sizeXChanged = false;
			}
			else
			{
				this.__leftOffset = this.__image._leftOffset;
				this.__rightOffset = this.__image._rightOffset;
			}
			
			if (this.__image._sizeYChanged)
			{
				if (this.__image._invertY)
				{
					this.__topOffset = this.__image._topOffset = -this.__frame.bottomHeight * this.__image._scaleY;
					this.__bottomOffset = this.__image._bottomOffset = this.__frame.topHeight * this.__image._scaleY;
				}
				else
				{
					this.__topOffset = this.__image._topOffset = -this.__frame.topHeight * this.__image._scaleY;
					this.__bottomOffset = this.__image._bottomOffset = this.__frame.bottomHeight * this.__image._scaleY;
				}
				this.__image._sizeYChanged = false;
			}
			else
			{
				this.__topOffset = this.__image._topOffset;
				this.__bottomOffset = this.__image._bottomOffset;
			}
			
			this.__image._transformChanged = false;
			
			if (this.__rotationChanged || this.__skewXChanged || this.__skewYChanged)
			{
				this.__a = this.__image._a = this.__cosSkewY * this.__cosRotation - this.__sinSkewY * this.__sinRotation;
				this.__b = this.__image._b = this.__cosSkewY * this.__sinRotation + this.__sinSkewY * this.__cosRotation;
				this.__c = this.__image._c = this.__sinSkewX * this.__cosRotation - this.__cosSkewX * this.__sinRotation;
				this.__d = this.__image._d = this.__sinSkewX * this.__sinRotation + this.__cosSkewX * this.__cosRotation;
			}
			else
			{
				this.__a = this.__image._a;
				this.__b = this.__image._b;
				this.__c = this.__image._c;
				this.__d = this.__image._d;
			}
			
			this.__x1 = this.__image._x1 = this.__leftOffset * this.__a + this.__topOffset * this.__c;
			this.__y1 = this.__image._y1 = this.__leftOffset * this.__b + this.__topOffset * this.__d;
			this.__x2 = this.__image._x2 = this.__rightOffset * this.__a + this.__topOffset * this.__c;
			this.__y2 = this.__image._y2 = this.__rightOffset * this.__b + this.__topOffset * this.__d;
			this.__x3 = this.__image._x3 = this.__leftOffset * this.__a + this.__bottomOffset * this.__c;
			this.__y3 = this.__image._y3 = this.__leftOffset * this.__b + this.__bottomOffset * this.__d;
			this.__x4 = this.__image._x4 = this.__rightOffset * this.__a + this.__bottomOffset * this.__c;
			this.__y4 = this.__image._y4 = this.__rightOffset * this.__b + this.__bottomOffset * this.__d;
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
		return Std.int(this.__red * 255) | Std.int(this.__green * 255) << 8 | Std.int(this.__blue * 255) << 16 | Std.int(this.__alpha * 255) << 24;
	}
	
	inline private function getColorPMA():Int
	{
		return Std.int(this.__red * this.__alpha * 255) | Std.int(this.__green * this.__alpha * 255) << 8 | Std.int(this.__blue * this.__alpha * 255) << 16 | Std.int(this.__alpha * 255) << 24;
	}
	
	inline private function updateColor():Void
	{
		if (this.__useColor)
		{
			if (this.__image.hasVertexColor)
			{
				this.__uniformColor = false;
				if (this._colorChanged || this.__image._colorChanged || this.__image.vertexColor.isChanging)
				{
					this.__image._colorChanged = false;
					
					this.__vertexColor = this.__image.vertexColor;
					
					if (this.__simpleColor)
					{
						if (this.__pma)
						{
							if (this.__image.invertX && this.__vertexColor.canInvertX)
							{
								if (this.__image.invertY && this.__vertexColor.canInvertY)
								{
									this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
									this.__red = this.__vertexColor.red4 * this.__redBase;
									this.__green = this.__vertexColor.green4 * this.__greenBase;
									this.__blue = this.__vertexColor.blue4 * this.__blueBase;
									normalizeColor();
									this.__image._color1Final = getColorPMA();
									
									this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
									this.__red = this.__vertexColor.red3 * this.__redBase;
									this.__green = this.__vertexColor.green3 * this.__greenBase;
									this.__blue = this.__vertexColor.blue3 * this.__blueBase;
									normalizeColor();
									this.__image._color2Final = getColorPMA();
									
									this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
									this.__red = this.__vertexColor.red2 * this.__redBase;
									this.__green = this.__vertexColor.green2 * this.__greenBase;
									this.__blue = this.__vertexColor.blue2 * this.__blueBase;
									normalizeColor();
									this.__image._color3Final = getColorPMA();
									
									this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
									this.__red = this.__vertexColor.red1 * this.__redBase;
									this.__green = this.__vertexColor.green1 * this.__greenBase;
									this.__blue = this.__vertexColor.blue1 * this.__blueBase;
									normalizeColor();
									this.__image._color4Final = getColorPMA();
								}
								else
								{
									this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
									this.__red = this.__vertexColor.red2 * this.__redBase;
									this.__green = this.__vertexColor.green2 * this.__greenBase;
									this.__blue = this.__vertexColor.blue2 * this.__blueBase;
									normalizeColor();
									this.__image._color1Final = getColorPMA();
									
									this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
									this.__red = this.__vertexColor.red1 * this.__redBase;
									this.__green = this.__vertexColor.green1 * this.__greenBase;
									this.__blue = this.__vertexColor.blue1 * this.__blueBase;
									normalizeColor();
									this.__image._color2Final = getColorPMA();
									
									this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
									this.__red = this.__vertexColor.red4 * this.__redBase;
									this.__green = this.__vertexColor.green4 * this.__greenBase;
									this.__blue = this.__vertexColor.blue4 * this.__blueBase;
									normalizeColor();
									this.__image._color3Final = getColorPMA();
									
									this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
									this.__red = this.__vertexColor.red3 * this.__redBase;
									this.__green = this.__vertexColor.green3 * this.__greenBase;
									this.__blue = this.__vertexColor.blue3 * this.__blueBase;
									normalizeColor();
									this.__image._color4Final = getColorPMA();
								}
							}
							else if (this.__image.invertY && this.__vertexColor.canInvertY)
							{
								this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
								this.__red = this.__vertexColor.red3 * this.__redBase;
								this.__green = this.__vertexColor.green3 * this.__greenBase;
								this.__blue = this.__vertexColor.blue3 * this.__blueBase;
								normalizeColor();
								this.__image._color1Final = getColorPMA();
								
								this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
								this.__red = this.__vertexColor.red4 * this.__redBase;
								this.__green = this.__vertexColor.green4 * this.__greenBase;
								this.__blue = this.__vertexColor.blue4 * this.__blueBase;
								normalizeColor();
								this.__image._color2Final = getColorPMA();
								
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__red = this.__vertexColor.red1 * this.__redBase;
								this.__green = this.__vertexColor.green1 * this.__greenBase;
								this.__blue = this.__vertexColor.blue1 * this.__blueBase;
								normalizeColor();
								this.__image._color3Final = getColorPMA();
								
								this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
								this.__red = this.__vertexColor.red2 * this.__redBase;
								this.__green = this.__vertexColor.green2 * this.__greenBase;
								this.__blue = this.__vertexColor.blue2 * this.__blueBase;
								normalizeColor();
								this.__image._color4Final = getColorPMA();
							}
							else
							{
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__red = this.__vertexColor.red1 * this.__redBase;
								this.__green = this.__vertexColor.green1 * this.__greenBase;
								this.__blue = this.__vertexColor.blue1 * this.__blueBase;
								normalizeColor();
								this.__image._color1Final = getColorPMA();
								
								this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
								this.__red = this.__vertexColor.red2 * this.__redBase;
								this.__green = this.__vertexColor.green2 * this.__greenBase;
								this.__blue = this.__vertexColor.blue2 * this.__blueBase;
								normalizeColor();
								this.__image._color2Final = getColorPMA();
								
								this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
								this.__red = this.__vertexColor.red3 * this.__redBase;
								this.__green = this.__vertexColor.green3 * this.__greenBase;
								this.__blue = this.__vertexColor.blue3 * this.__blueBase;
								normalizeColor();
								this.__image._color3Final = getColorPMA();
								
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__red = this.__vertexColor.red1 * this.__redBase;
								this.__green = this.__vertexColor.green1 * this.__greenBase;
								this.__blue = this.__vertexColor.blue1 * this.__blueBase;
								normalizeColor();
								this.__image._color1Final = getColorPMA();
							}
						}
						else // no pma
						{
							if (this.__image.invertX && this.__vertexColor.canInvertX)
							{
								if (this.__image.invertY && this.__vertexColor.canInvertY)
								{
									this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
									this.__red = this.__vertexColor.red4 * this.__redBase;
									this.__green = this.__vertexColor.green4 * this.__greenBase;
									this.__blue = this.__vertexColor.blue4 * this.__blueBase;
									normalizeColor();
									this.__image._color1Final = getColor();
									
									this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
									this.__red = this.__vertexColor.red3 * this.__redBase;
									this.__green = this.__vertexColor.green3 * this.__greenBase;
									this.__blue = this.__vertexColor.blue3 * this.__blueBase;
									normalizeColor();
									this.__image._color2Final = getColor();
									
									this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
									this.__red = this.__vertexColor.red2 * this.__redBase;
									this.__green = this.__vertexColor.green2 * this.__greenBase;
									this.__blue = this.__vertexColor.blue2 * this.__blueBase;
									normalizeColor();
									this.__image._color3Final = getColor();
									
									this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
									this.__red = this.__vertexColor.red1 * this.__redBase;
									this.__green = this.__vertexColor.green1 * this.__greenBase;
									this.__blue = this.__vertexColor.blue1 * this.__blueBase;
									normalizeColor();
									this.__image._color4Final = getColor();
								}
								else
								{
									this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
									this.__red = this.__vertexColor.red2 * this.__redBase;
									this.__green = this.__vertexColor.green2 * this.__greenBase;
									this.__blue = this.__vertexColor.blue2 * this.__blueBase;
									normalizeColor();
									this.__image._color1Final = getColor();
									
									this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
									this.__red = this.__vertexColor.red1 * this.__redBase;
									this.__green = this.__vertexColor.green1 * this.__greenBase;
									this.__blue = this.__vertexColor.blue1 * this.__blueBase;
									normalizeColor();
									this.__image._color2Final = getColor();
									
									this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
									this.__red = this.__vertexColor.red4 * this.__redBase;
									this.__green = this.__vertexColor.green4 * this.__greenBase;
									this.__blue = this.__vertexColor.blue4 * this.__blueBase;
									normalizeColor();
									this.__image._color3Final = getColor();
									
									this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
									this.__red = this.__vertexColor.red3 * this.__redBase;
									this.__green = this.__vertexColor.green3 * this.__greenBase;
									this.__blue = this.__vertexColor.blue3 * this.__blueBase;
									normalizeColor();
									this.__image._color4Final = getColor();
								}
							}
							else if (this.__image.invertY && this.__vertexColor.canInvertY)
							{
								this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
								this.__red = this.__vertexColor.red3 * this.__redBase;
								this.__green = this.__vertexColor.green3 * this.__greenBase;
								this.__blue = this.__vertexColor.blue3 * this.__blueBase;
								normalizeColor();
								this.__image._color1Final = getColor();
								
								this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
								this.__red = this.__vertexColor.red4 * this.__redBase;
								this.__green = this.__vertexColor.green4 * this.__greenBase;
								this.__blue = this.__vertexColor.blue4 * this.__blueBase;
								normalizeColor();
								this.__image._color2Final = getColor();
								
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__red = this.__vertexColor.red1 * this.__redBase;
								this.__green = this.__vertexColor.green1 * this.__greenBase;
								this.__blue = this.__vertexColor.blue1 * this.__blueBase;
								normalizeColor();
								this.__image._color3Final = getColor();
								
								this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
								this.__red = this.__vertexColor.red2 * this.__redBase;
								this.__green = this.__vertexColor.green2 * this.__greenBase;
								this.__blue = this.__vertexColor.blue2 * this.__blueBase;
								normalizeColor();
								this.__image._color4Final = getColor();
							}
							else
							{
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__red = this.__vertexColor.red1 * this.__redBase;
								this.__green = this.__vertexColor.green1 * this.__greenBase;
								this.__blue = this.__vertexColor.blue1 * this.__blueBase;
								normalizeColor();
								this.__image._color1Final = getColor();
								
								this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
								this.__red = this.__vertexColor.red2 * this.__redBase;
								this.__green = this.__vertexColor.green2 * this.__greenBase;
								this.__blue = this.__vertexColor.blue2 * this.__blueBase;
								normalizeColor();
								this.__image._color2Final = getColor();
								
								this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
								this.__red = this.__vertexColor.red3 * this.__redBase;
								this.__green = this.__vertexColor.green3 * this.__greenBase;
								this.__blue = this.__vertexColor.blue3 * this.__blueBase;
								normalizeColor();
								this.__image._color3Final = getColor();
								
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__red = this.__vertexColor.red1 * this.__redBase;
								this.__green = this.__vertexColor.green1 * this.__greenBase;
								this.__blue = this.__vertexColor.blue1 * this.__blueBase;
								normalizeColor();
								this.__image._color1Final = getColor();
							}
						}
					}
					else // non-simple color
					{
						if (this.__pma)
						{
							if (this.__image.invertX && this.__vertexColor.canInvertX)
							{
								if (this.__image.invertY && this.__vertexColor.canInvertY)
								{
									this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
									this.__image._red1Final = this.__vertexColor.red4 * this.__redBase * this.__alpha;
									this.__image._green1Final = this.__vertexColor.green4 * this.__greenBase * this.__alpha;
									this.__image._blue1Final = this.__vertexColor.blue4 * this.__blueBase * this.__alpha;
									this.__image._alpha1Final = this.__alpha;
									
									this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
									this.__image._red2Final = this.__vertexColor.red3 * this.__redBase * this.__alpha;
									this.__image._green2Final = this.__vertexColor.green3 * this.__greenBase * this.__alpha;
									this.__image._blue2Final = this.__vertexColor.blue3 * this.__blueBase * this.__alpha;
									this.__image._alpha2Final = this.__alpha;
									
									this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
									this.__image._red3Final = this.__vertexColor.red2 * this.__redBase * this.__alpha;
									this.__image._green3Final = this.__vertexColor.green2 * this.__greenBase * this.__alpha;
									this.__image._blue3Final = this.__vertexColor.blue2 * this.__blueBase * this.__alpha;
									this.__image._alpha3Final = this.__alpha;
									
									this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
									this.__image._red4Final = this.__vertexColor.red1 * this.__redBase * this.__alpha;
									this.__image._green4Final = this.__vertexColor.green1 * this.__greenBase * this.__alpha;
									this.__image._blue4Final = this.__vertexColor.blue1 * this.__blueBase * this.__alpha;
									this.__image._alpha4Final = this.__alpha;
								}
								else
								{
									this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
									this.__image._red1Final = this.__vertexColor.red2 * this.__redBase * this.__alpha;
									this.__image._green1Final = this.__vertexColor.green2 * this.__greenBase * this.__alpha;
									this.__image._blue1Final = this.__vertexColor.blue2 * this.__blueBase * this.__alpha;
									this.__image._alpha1Final = this.__alpha;
									
									this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
									this.__image._red2Final = this.__vertexColor.red1 * this.__redBase * this.__alpha;
									this.__image._green2Final = this.__vertexColor.green1 * this.__greenBase * this.__alpha;
									this.__image._blue2Final = this.__vertexColor.blue1 * this.__blueBase * this.__alpha;
									this.__image._alpha2Final = this.__alpha;
									
									this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
									this.__image._red3Final = this.__vertexColor.red4 * this.__redBase * this.__alpha;
									this.__image._green3Final = this.__vertexColor.green4 * this.__greenBase * this.__alpha;
									this.__image._blue3Final = this.__vertexColor.blue4 * this.__blueBase * this.__alpha;
									this.__image._alpha3Final = this.__alpha;
									
									this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
									this.__image._red4Final = this.__vertexColor.red3 * this.__redBase * this.__alpha;
									this.__image._green4Final = this.__vertexColor.green3 * this.__greenBase * this.__alpha;
									this.__image._blue4Final = this.__vertexColor.blue3 * this.__blueBase * this.__alpha;
									this.__image._alpha4Final = this.__alpha;
								}
							}
							else if (this.__image.invertY && this.__vertexColor.canInvertY)
							{
								this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
								this.__image._red1Final = this.__vertexColor.red3 * this.__redBase * this.__alpha;
								this.__image._green1Final = this.__vertexColor.green3 * this.__greenBase * this.__alpha;
								this.__image._blue1Final = this.__vertexColor.blue3 * this.__blueBase * this.__alpha;
								this.__image._alpha1Final = this.__alpha;
								
								this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
								this.__image._red2Final = this.__vertexColor.red4 * this.__redBase * this.__alpha;
								this.__image._green2Final = this.__vertexColor.green4 * this.__greenBase * this.__alpha;
								this.__image._blue2Final = this.__vertexColor.blue4 * this.__blueBase * this.__alpha;
								this.__image._alpha2Final = this.__alpha;
								
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__image._red3Final = this.__vertexColor.red1 * this.__redBase * this.__alpha;
								this.__image._green3Final = this.__vertexColor.green1 * this.__greenBase * this.__alpha;
								this.__image._blue3Final = this.__vertexColor.blue1 * this.__blueBase * this.__alpha;
								this.__image._alpha3Final = this.__alpha;
								
								this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
								this.__image._red4Final = this.__vertexColor.red2 * this.__redBase * this.__alpha;
								this.__image._green4Final = this.__vertexColor.green2 * this.__greenBase * this.__alpha;
								this.__image._blue4Final = this.__vertexColor.blue2 * this.__blueBase * this.__alpha;
								this.__image._alpha4Final = this.__alpha;
							}
							else
							{
								this.__alpha = this.__vertexColor.alpha1 * this.__alphaBase;
								this.__image._red1Final = this.__vertexColor.red1 * this.__redBase * this.__alpha;
								this.__image._green1Final = this.__vertexColor.green1 * this.__greenBase * this.__alpha;
								this.__image._blue1Final = this.__vertexColor.blue1 * this.__blueBase * this.__alpha;
								this.__image._alpha1Final = this.__alpha;
								
								this.__alpha = this.__vertexColor.alpha2 * this.__alphaBase;
								this.__image._red2Final = this.__vertexColor.red2 * this.__redBase * this.__alpha;
								this.__image._green2Final = this.__vertexColor.green2 * this.__greenBase * this.__alpha;
								this.__image._blue2Final = this.__vertexColor.blue2 * this.__blueBase * this.__alpha;
								this.__image._alpha2Final = this.__alpha;
								
								this.__alpha = this.__vertexColor.alpha3 * this.__alphaBase;
								this.__image._red3Final = this.__vertexColor.red3 * this.__redBase * this.__alpha;
								this.__image._green3Final = this.__vertexColor.green3 * this.__greenBase * this.__alpha;
								this.__image._blue3Final = this.__vertexColor.blue3 * this.__blueBase * this.__alpha;
								this.__image._alpha3Final = this.__alpha;
								
								this.__alpha = this.__vertexColor.alpha4 * this.__alphaBase;
								this.__image._red4Final = this.__vertexColor.red4 * this.__redBase * this.__alpha;
								this.__image._green4Final = this.__vertexColor.green4 * this.__greenBase * this.__alpha;
								this.__image._blue4Final = this.__vertexColor.blue4 * this.__blueBase * this.__alpha;
								this.__image._alpha4Final = this.__alpha;
							}
						}
						else // no pma
						{
							if (this.__image.invertX && this.__vertexColor.canInvertX)
							{
								if (this.__image.invertY && this.__vertexColor.canInvertY)
								{
									this.__image._red1Final = this.__vertexColor.red4 * this.__redBase;
									this.__image._green1Final = this.__vertexColor.green4 * this.__greenBase;
									this.__image._blue1Final = this.__vertexColor.blue4 * this.__blueBase;
									this.__image._alpha1Final = this.__vertexColor.alpha4 * this.__alphaBase;
									
									this.__image._red2Final = this.__vertexColor.red3 * this.__redBase;
									this.__image._green2Final = this.__vertexColor.green3 * this.__greenBase;
									this.__image._blue2Final = this.__vertexColor.blue3 * this.__blueBase;
									this.__image._alpha2Final = this.__vertexColor.alpha3 * this.__alphaBase;
									
									this.__image._red3Final = this.__vertexColor.red2 * this.__redBase;
									this.__image._green3Final = this.__vertexColor.green2 * this.__greenBase;
									this.__image._blue3Final = this.__vertexColor.blue2 * this.__blueBase;
									this.__image._alpha3Final = this.__vertexColor.alpha2 * this.__alphaBase;
									
									this.__image._red4Final = this.__vertexColor.red1 * this.__redBase;
									this.__image._green4Final = this.__vertexColor.green1 * this.__greenBase;
									this.__image._blue4Final = this.__vertexColor.blue1 * this.__blueBase;
									this.__image._alpha4Final = this.__vertexColor.alpha1 * this.__alphaBase;
								}
								else
								{
									this.__image._red1Final = this.__vertexColor.red2 * this.__redBase;
									this.__image._green1Final = this.__vertexColor.green2 * this.__greenBase;
									this.__image._blue1Final = this.__vertexColor.blue2 * this.__blueBase;
									this.__image._alpha1Final = this.__vertexColor.alpha2 * this.__alphaBase;
									
									this.__image._red2Final = this.__vertexColor.red1 * this.__redBase;
									this.__image._green2Final = this.__vertexColor.green1 * this.__greenBase;
									this.__image._blue2Final = this.__vertexColor.blue1 * this.__blueBase;
									this.__image._alpha2Final = this.__vertexColor.alpha1 * this.__alphaBase;
									
									this.__image._red3Final = this.__vertexColor.red4 * this.__redBase;
									this.__image._green3Final = this.__vertexColor.green4 * this.__greenBase;
									this.__image._blue3Final = this.__vertexColor.blue4 * this.__blueBase;
									this.__image._alpha3Final = this.__vertexColor.alpha4 * this.__alphaBase;
									
									this.__image._red4Final = this.__vertexColor.red3 * this.__redBase;
									this.__image._green4Final = this.__vertexColor.green3 * this.__greenBase;
									this.__image._blue4Final = this.__vertexColor.blue3 * this.__blueBase;
									this.__image._alpha4Final = this.__vertexColor.alpha3 * this.__alphaBase;
								}
							}
							else if (this.__image.invertY && this.__vertexColor.canInvertY)
							{
								this.__image._red1Final = this.__vertexColor.red3 * this.__redBase;
								this.__image._green1Final = this.__vertexColor.green3 * this.__greenBase;
								this.__image._blue1Final = this.__vertexColor.blue3 * this.__blueBase;
								this.__image._alpha1Final = this.__vertexColor.alpha3 * this.__alphaBase;
								
								this.__image._red2Final = this.__vertexColor.red4 * this.__redBase;
								this.__image._green2Final = this.__vertexColor.green4 * this.__greenBase;
								this.__image._blue2Final = this.__vertexColor.blue4 * this.__blueBase;
								this.__image._alpha2Final = this.__vertexColor.alpha4 * this.__alphaBase;
								
								this.__image._red3Final = this.__vertexColor.red1 * this.__redBase;
								this.__image._green3Final = this.__vertexColor.green1 * this.__greenBase;
								this.__image._blue3Final = this.__vertexColor.blue1 * this.__blueBase;
								this.__image._alpha3Final = this.__vertexColor.alpha1 * this.__alphaBase;
								
								this.__image._red4Final = this.__vertexColor.red2 * this.__redBase;
								this.__image._green4Final = this.__vertexColor.green2 * this.__greenBase;
								this.__image._blue4Final = this.__vertexColor.blue2 * this.__blueBase;
								this.__image._alpha4Final = this.__vertexColor.alpha2 * this.__alphaBase;
							}
							else
							{
								this.__image._red1Final = this.__vertexColor.red1 * this.__redBase;
								this.__image._green1Final = this.__vertexColor.green1 * this.__greenBase;
								this.__image._blue1Final = this.__vertexColor.blue1 * this.__blueBase;
								this.__image._alpha1Final = this.__vertexColor.alpha1 * this.__alphaBase;
								
								this.__image._red2Final = this.__vertexColor.red2 * this.__redBase;
								this.__image._green2Final = this.__vertexColor.green2 * this.__greenBase;
								this.__image._blue2Final = this.__vertexColor.blue2 * this.__blueBase;
								this.__image._alpha2Final = this.__vertexColor.alpha2 * this.__alphaBase;
								
								this.__image._red3Final = this.__vertexColor.red3 * this.__redBase;
								this.__image._green3Final = this.__vertexColor.green3 * this.__greenBase;
								this.__image._blue3Final = this.__vertexColor.blue3 * this.__blueBase;
								this.__image._alpha3Final = this.__vertexColor.alpha3 * this.__alphaBase;
								
								this.__image._red4Final = this.__vertexColor.red4 * this.__redBase;
								this.__image._green4Final = this.__vertexColor.green4 * this.__greenBase;
								this.__image._blue4Final = this.__vertexColor.blue4 * this.__blueBase;
								this.__image._alpha4Final = this.__vertexColor.alpha4 * this.__alphaBase;
							}
						}
					}
				}
			}
			else
			{
				this.__uniformColor = true;
				if (this.__simpleColor)
				{
					this.__alpha = this.__image.alpha * this.__alphaBase;
					this.__red = this.__image.red * this.__redBase;
					this.__green = this.__image.green * this.__greenBase;
					this.__blue = this.__image.blue * this.__blueBase;
					normalizeColor();
					this.__color = this.__pma ? getColorPMA() : getColor();
				}
				else
				{
					this.__alpha = this.__image.alpha * this.__alphaBase;
					if (this.__pma)
					{
						this.__red = this.__image.red * this.__redBase * this.__alpha;
						this.__green = this.__image.green * this.__greenBase * this.__alpha;
						this.__blue = this.__image.blue * this.__blueBase * this.__alpha;
					}
					else
					{
						this.__red = this.__image.red * this.__redBase;
						this.__green = this.__image.green * this.__greenBase;
						this.__blue = this.__image.blue * this.__blueBase;
					}
				}
			}
		}
		
		if (this.__useColorOffset)
		{
			if (this.__image.hasVertexColorOffset)
			{
				this.__uniformColorOffset = false;
				if (this._colorOffsetChanged || this.__image._colorOffsetChanged || this.__image.vertexColorOffset.isChanging)
				{
					this.__image._colorOffsetChanged = false;
					
					this.__vertexColorOffset = this.__image.vertexColorOffset;
					
					if (this.__simpleColor)
					{
						if (this.__image.invertX)
						{
							if (this.__image.invertY)
							{
								this.__alpha = this.__vertexColorOffset.alpha4 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red4 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green4 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue4 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset1Final = getColor();
								
								this.__alpha = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red3 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset2Final = getColor();
								
								this.__alpha = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red2 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset3Final = getColor();
								
								this.__alpha = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red1 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset4Final = getColor();
							}
							else
							{
								this.__alpha = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red2 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset1Final = getColor();
								
								this.__alpha = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red1 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset2Final = getColor();
								
								this.__alpha = this.__vertexColorOffset.alpha4 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red4 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green4 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue4 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset3Final = getColor();
								
								this.__alpha = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
								this.__red = this.__vertexColorOffset.red3 + this.__redOffsetBase;
								this.__green = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
								this.__blue = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
								normalizeColor();
								this.__image._colorOffset4Final = getColor();
							}
						}
						else if (this.__image.invertY)
						{
							this.__alpha = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red3 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset1Final = getColor();
							
							this.__alpha = this.__vertexColorOffset.alpha4 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red4 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green4 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue4 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset2Final = getColor();
							
							this.__alpha = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red1 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset3Final = getColor();
							
							this.__alpha = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red2 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset4Final = getColor();
						}
						else
						{
							this.__alpha = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red1 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset1Final = getColor();
							
							this.__alpha = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red2 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset2Final = getColor();
							
							this.__alpha = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red3 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset3Final = getColor();
							
							this.__alpha = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
							this.__red = this.__vertexColorOffset.red1 + this.__redOffsetBase;
							this.__green = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
							this.__blue = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
							normalizeColor();
							this.__image._colorOffset1Final = getColor();
						}
					}
					else // non-simple color
					{
						if (this.__image.invertX)
						{
							if (this.__image.invertY)
							{
								this.__image._redOffset1Final = this.__vertexColorOffset.red4 + this.__redOffsetBase;
								this.__image._greenOffset1Final = this.__vertexColorOffset.green4 + this.__greenOffsetBase;
								this.__image._blueOffset1Final = this.__vertexColorOffset.blue4 + this.__blueOffsetBase;
								this.__image._alphaOffset1Final = this.__vertexColorOffset.alpha4 + this.__alphaOffsetBase;
								
								this.__image._redOffset2Final = this.__vertexColorOffset.red3 + this.__redOffsetBase;
								this.__image._greenOffset2Final = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
								this.__image._blueOffset2Final = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
								this.__image._alphaOffset2Final = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
								
								this.__image._redOffset3Final = this.__vertexColorOffset.red2 + this.__redOffsetBase;
								this.__image._greenOffset3Final = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
								this.__image._blueOffset3Final = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
								this.__image._alphaOffset3Final = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
								
								this.__image._redOffset4Final = this.__vertexColorOffset.red1 + this.__redOffsetBase;
								this.__image._greenOffset4Final = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
								this.__image._blueOffset4Final = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
								this.__image._alphaOffset4Final = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
							}
							else
							{
								this.__image._redOffset1Final = this.__vertexColorOffset.red2 + this.__redOffsetBase;
								this.__image._greenOffset1Final = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
								this.__image._blueOffset1Final = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
								this.__image._alphaOffset1Final = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
								
								this.__image._redOffset2Final = this.__vertexColorOffset.red1 + this.__redOffsetBase;
								this.__image._greenOffset2Final = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
								this.__image._blueOffset2Final = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
								this.__image._alphaOffset2Final = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
								
								this.__image._redOffset3Final = this.__vertexColorOffset.red4 + this.__redOffsetBase;
								this.__image._greenOffset3Final = this.__vertexColorOffset.green4 + this.__greenOffsetBase;
								this.__image._blueOffset3Final = this.__vertexColorOffset.blue4 + this.__blueOffsetBase;
								this.__image._alphaOffset3Final = this.__vertexColorOffset.alpha4 + this.__alphaOffsetBase;
								
								this.__image._redOffset4Final = this.__vertexColorOffset.red3 + this.__redOffsetBase;
								this.__image._greenOffset4Final = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
								this.__image._blueOffset4Final = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
								this.__image._alphaOffset4Final = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
							}
						}
						else if (this.__image.invertY)
						{
							this.__image._redOffset1Final = this.__vertexColorOffset.red3 + this.__redOffsetBase;
							this.__image._greenOffset1Final = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
							this.__image._blueOffset1Final = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
							this.__image._alphaOffset1Final = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
							
							this.__image._redOffset2Final = this.__vertexColorOffset.red4 + this.__redOffsetBase;
							this.__image._greenOffset2Final = this.__vertexColorOffset.green4 + this.__greenOffsetBase;
							this.__image._blueOffset2Final = this.__vertexColorOffset.blue4 + this.__blueOffsetBase;
							this.__image._alphaOffset2Final = this.__vertexColorOffset.alpha4 + this.__alphaOffsetBase;
							
							this.__image._redOffset3Final = this.__vertexColorOffset.red1 + this.__redOffsetBase;
							this.__image._greenOffset3Final = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
							this.__image._blueOffset3Final = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
							this.__image._alphaOffset3Final = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
							
							this.__image._redOffset4Final = this.__vertexColorOffset.red2 + this.__redOffsetBase;
							this.__image._greenOffset4Final = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
							this.__image._blueOffset4Final = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
							this.__image._alphaOffset4Final = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
						}
						else
						{
							this.__image._redOffset1Final = this.__vertexColorOffset.red1 + this.__redOffsetBase;
							this.__image._greenOffset1Final = this.__vertexColorOffset.green1 + this.__greenOffsetBase;
							this.__image._blueOffset1Final = this.__vertexColorOffset.blue1 + this.__blueOffsetBase;
							this.__image._alphaOffset1Final = this.__vertexColorOffset.alpha1 + this.__alphaOffsetBase;
							
							this.__image._redOffset2Final = this.__vertexColorOffset.red2 + this.__redOffsetBase;
							this.__image._greenOffset2Final = this.__vertexColorOffset.green2 + this.__greenOffsetBase;
							this.__image._blueOffset2Final = this.__vertexColorOffset.blue2 + this.__blueOffsetBase;
							this.__image._alphaOffset2Final = this.__vertexColorOffset.alpha2 + this.__alphaOffsetBase;
							
							this.__image._redOffset3Final = this.__vertexColorOffset.red3 + this.__redOffsetBase;
							this.__image._greenOffset3Final = this.__vertexColorOffset.green3 + this.__greenOffsetBase;
							this.__image._blueOffset3Final = this.__vertexColorOffset.blue3 + this.__blueOffsetBase;
							this.__image._alphaOffset3Final = this.__vertexColorOffset.alpha3 + this.__alphaOffsetBase;
							
							this.__image._redOffset4Final = this.__vertexColorOffset.red4 + this.__redOffsetBase;
							this.__image._greenOffset4Final = this.__vertexColorOffset.green4 + this.__greenOffsetBase;
							this.__image._blueOffset4Final = this.__vertexColorOffset.blue4 + this.__blueOffsetBase;
							this.__image._alphaOffset4Final = this.__vertexColorOffset.alpha4 + this.__alphaOffsetBase;
						}
					}
				}
			}
			else
			{
				this.__uniformColorOffset = true;
				if (this.__simpleColor)
				{
					this.__alpha = this.__image.alphaOffset + this.__alphaOffsetBase;
					this.__red = this.__image.redOffset + this.__redOffsetBase;
					this.__green = this.__image.greenOffset + this.__greenOffsetBase;
					this.__blue = this.__image.blueOffset + this.__blueOffsetBase;
					normalizeColor();
					this.__colorOffset = getColor();
				}
				else
				{
					this.__alphaOffset = this.__image.alphaOffset + this.__alphaOffsetBase;
					this.__redOffset = this.__image.redOffset + this.__redOffsetBase;
					this.__greenOffset = this.__image.greenOffset + this.__greenOffsetBase;
					this.__blueOffset = this.__image.blueOffset + this.__blueOffsetBase;
				}
			}
		}
	}
	
	private var __data:DisplayBase;
	private var __container:MixedContainer;
	private var __image:Img;
	
	private var __byteData:ByteArray;
	#if flash
	private var __boundsData:Vector<Float>;
	#else
	private var __boundsData:Array<Float>;
	private var __floatData:Float32Array;
	#end
	private var __vectorData:Vector<Float>;
	
	private var __maxQuads:Int;
	private var __renderData:RenderData;
	
	private var __x:Float;
	private var __y:Float;
	private var __leftOffset:Float;
	private var __rightOffset:Float;
	private var __topOffset:Float;
	private var __bottomOffset:Float;
	private var __rotation:Float;
	private var __skewX:Float;
	private var __skewY:Float;
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
	private var __vertexPosition:VertexPositionData;
	
	private var __uniformColor:Bool;
	private var __uniformColorOffset:Bool;
	private var __vertexColor:VertexColorData;
	private var __vertexColorOffset:VertexColorData;
	private var __red:Float;
	private var __green:Float;
	private var __blue:Float;
	private var __alpha:Float;
	private var __color:Int;
	private var __redOffset:Float;
	private var __greenOffset:Float;
	private var __blueOffset:Float;
	private var __alphaOffset:Float;
	private var __colorOffset:Int;
	
	private var __redBase:Float;
	private var __greenBase:Float;
	private var __blueBase:Float;
	private var __alphaBase:Float;
	private var __redBasePrevious:Float = 1.0;
	private var __greenBasePrevious:Float = 1.0;
	private var __blueBasePrevious:Float = 1.0;
	private var __alphaBasePrevious:Float = 1.0;
	private var __redOffsetBase:Float;
	private var __greenOffsetBase:Float;
	private var __blueOffsetBase:Float;
	private var __alphaOffsetBase:Float;
	private var __redOffsetBasePrevious:Float = 0.0;
	private var __greenOffsetBasePrevious:Float = 0.0;
	private var __blueOffsetBasePrevious:Float = 0.0;
	private var __alphaOffsetBasePrevious:Float = 0.0;
	
	private var __multiTexturing:Bool;
	private var __textureIndex:Float;
	private var __position:Int;
	private var __quadsWritten:Int;
	private var __pma:Bool;
	private var __useColor:Bool;
	//private var __useDisplayColor:Bool;
	private var __useColorOffset:Bool;
	private var __simpleColor:Bool;
	private var __storeBounds:Bool;
	private var __boundsIndex:Int;
	private var __renderOffsetX:Float;
	private var __renderOffsetY:Float;
}