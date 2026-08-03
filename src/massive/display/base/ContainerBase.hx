package massive.display.base;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;
import massive.display.Clip;
import massive.display.render.RenderData;
#if flash
import openfl.Memory;
#end
import openfl.Vector;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end

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
	/**
	   Tells whether this container should animate textures or not.
	   If you are displaying non-animated images, consider setting this to false for better performance
	   @default true
	**/
	public var textureAnimation:Bool = true;
	
	public function new()
	{
		super();
		this.isContainer = true;
	}
	
	inline private function prepareDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		this.__byteData = byteData;
		this.__maxQuads = maxQuads;
		this.__renderData = renderData;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;// this.__pma && !this.__useColor && !this.__useDisplayColor;
		this.__simpleColor = renderData.useSimpleColor;
		this.__boundsData = boundsData;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		
		this.__renderOffsetX = renderOffsetX + this.x;
		this.__renderOffsetY = renderOffsetY + this.y;
	}
	
	inline private function finishDataBytes():Void
	{
		this.__renderData.numQuads = this.__quadsWritten;
	}
	
	#if flash
	inline private function prepareDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Void
	{
		this.__maxQuads = maxQuads;
		this.__renderData = renderData;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;// this.__pma && !this.__useColor && !this.__useDisplayColor;
		this.__simpleColor = renderData.useSimpleColor;
		this.__boundsData = boundsData;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		this.__position = renderData.position;
		
		this.__renderOffsetX = renderOffsetX + this.x;
		this.__renderOffsetY = renderOffsetY + this.y;
	}
	
	inline private function finishDataBytesMemory():Void
	{
		this.__renderData.numQuads = this.__quadsWritten;
		this.__renderData.position = this.__position;
	}
	#end
	
	#if !flash
	inline private function prepareDataFloat32Array(floatData:Float32Array, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		this.__floatData = floatData;
		this.__maxQuads = maxQuads;
		this.__renderData = renderData;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;// this.__pma && !this.__useColor && !this.__useDisplayColor;
		this.__simpleColor = renderData.useSimpleColor;
		this.__boundsData = boundsData;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		this.__position = renderData.position;
		
		this.__renderOffsetX = renderOffsetX + this.x;
		this.__renderOffsetY = renderOffsetY + this.y;
	}
	
	inline private function finishDataFloat32Array():Void
	{
		this.__renderData.numQuads = this.__quadsWritten;
		this.__renderData.position = this.__position;
	}
	#end
	
	inline private function prepareDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		this.__vectorData = vectorData;
		this.__maxQuads = maxQuads;
		this.__renderData = renderData;
		
		this.__multiTexturing = renderData.multiTexturing;
		this.__pma = renderData.pma;
		this.__useColor = renderData.useColor;
		this.__useDisplayColor = renderData.useDisplayColor;
		this.__useColorOffset = renderData.useColorOffset;
		this.__pmaForColorOffset = false;// this.__pma && !this.__useColor && !this.__useDisplayColor;
		this.__simpleColor = renderData.useSimpleColor;
		this.__boundsData = boundsData;
		this.__storeBounds = boundsData != null;
		this.__boundsIndex = this.__storeBounds ? boundsData.length - 1 : -1;
		
		this.__quadsWritten = renderData.numQuads;
		this.__position = renderData.position;
		
		this.__renderOffsetX = renderOffsetX + this.x;
		this.__renderOffsetY = renderOffsetY + this.y;
	}
	
	inline private function finishDataVector():Void
	{
		this.__renderData.numQuads = this.__quadsWritten;
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
		
		if (this.__image._transformChanged)
		{
			updateTransform();
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
					this.__byteData.writeInt(this.__vertexColor.color1);
				}
				else
				{
					this.__byteData.writeFloat(this.__vertexColor.red1);
					this.__byteData.writeFloat(this.__vertexColor.green1);
					this.__byteData.writeFloat(this.__vertexColor.blue1);
					this.__byteData.writeFloat(this.__vertexColor.alpha1);
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
					this.__byteData.writeInt(this.__vertexColorOffset.color1);
				}
				else
				{
					this.__byteData.writeFloat(this.__vertexColorOffset.red1);
					this.__byteData.writeFloat(this.__vertexColorOffset.green1);
					this.__byteData.writeFloat(this.__vertexColorOffset.blue1);
					this.__byteData.writeFloat(this.__vertexColorOffset.alpha1);
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
					this.__byteData.writeFloat(this.__vertexColor.red2);
					this.__byteData.writeFloat(this.__vertexColor.green2);
					this.__byteData.writeFloat(this.__vertexColor.blue2);
					this.__byteData.writeFloat(this.__vertexColor.alpha2);
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
					this.__byteData.writeInt(this.__vertexColorOffset.color2);
				}
				else
				{
					this.__byteData.writeFloat(this.__vertexColorOffset.red2);
					this.__byteData.writeFloat(this.__vertexColorOffset.green2);
					this.__byteData.writeFloat(this.__vertexColorOffset.blue2);
					this.__byteData.writeFloat(this.__vertexColorOffset.alpha2);
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
					this.__byteData.writeInt(this.__vertexColor.color3);
				}
				else
				{
					this.__byteData.writeFloat(this.__vertexColor.red3);
					this.__byteData.writeFloat(this.__vertexColor.green3);
					this.__byteData.writeFloat(this.__vertexColor.blue3);
					this.__byteData.writeFloat(this.__vertexColor.alpha3);
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
					this.__byteData.writeInt(this.__vertexColorOffset.color3);
				}
				else
				{
					this.__byteData.writeFloat(this.__vertexColorOffset.red3);
					this.__byteData.writeFloat(this.__vertexColorOffset.green3);
					this.__byteData.writeFloat(this.__vertexColorOffset.blue3);
					this.__byteData.writeFloat(this.__vertexColorOffset.alpha3);
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
					this.__byteData.writeInt(this.__vertexColor.color4);
				}
				else
				{
					this.__byteData.writeFloat(this.__vertexColor.red4);
					this.__byteData.writeFloat(this.__vertexColor.green4);
					this.__byteData.writeFloat(this.__vertexColor.blue4);
					this.__byteData.writeFloat(this.__vertexColor.alpha4);
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
					this.__byteData.writeInt(this.__vertexColorOffset.color4);
				}
				else
				{
					this.__byteData.writeFloat(this.__vertexColorOffset.red4);
					this.__byteData.writeFloat(this.__vertexColorOffset.green4);
					this.__byteData.writeFloat(this.__vertexColorOffset.blue4);
					this.__byteData.writeFloat(this.__vertexColorOffset.alpha4);
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
					Memory.setI32(this.__position += 4, this.__vertexColor.color1);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColor.red1);
					Memory.setFloat(this.__position += 4, this.__vertexColor.green1);
					Memory.setFloat(this.__position += 4, this.__vertexColor.blue1);
					Memory.setFloat(this.__position += 4, this.__vertexColor.alpha1);
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
					Memory.setI32(this.__position += 4, this.__vertexColorOffset.color1);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.red1);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.green1);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.blue1);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.alpha1);
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
					Memory.setI32(this.__position += 4, this.__vertexColor.color2);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColor.red2);
					Memory.setFloat(this.__position += 4, this.__vertexColor.green2);
					Memory.setFloat(this.__position += 4, this.__vertexColor.blue2);
					Memory.setFloat(this.__position += 4, this.__vertexColor.alpha2);
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
					Memory.setI32(this.__position += 4, this.__vertexColorOffset.color2);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.red2);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.green2);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.blue2);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.alpha2);
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
					Memory.setI32(this.__position += 4, this.__vertexColor.color3);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColor.red3);
					Memory.setFloat(this.__position += 4, this.__vertexColor.green3);
					Memory.setFloat(this.__position += 4, this.__vertexColor.blue3);
					Memory.setFloat(this.__position += 4, this.__vertexColor.alpha3);
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
					Memory.setI32(this.__position += 4, this.__vertexColorOffset.color3);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.red3);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.green3);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.blue3);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.alpha3);
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
					Memory.setI32(this.__position += 4, this.__vertexColor.color4);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColor.red4);
					Memory.setFloat(this.__position += 4, this.__vertexColor.green4);
					Memory.setFloat(this.__position += 4, this.__vertexColor.blue4);
					Memory.setFloat(this.__position += 4, this.__vertexColor.alpha4);
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
					Memory.setI32(this.__position += 4, this.__vertexColorOffset.color4);
				}
				else
				{
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.red4);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.green4);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.blue4);
					Memory.setFloat(this.__position += 4, this.__vertexColorOffset.alpha4);
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
					this.__floatData[++this.__position] = this.__vertexColor.red1;
					this.__floatData[++this.__position] = this.__vertexColor.green1;
					this.__floatData[++this.__position] = this.__vertexColor.blue1;
					this.__floatData[++this.__position] = this.__vertexColor.alpha1;
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
					this.__floatData[++this.__position] = this.__vertexColorOffset.color1;
				}
				else
				{
					this.__floatData[++this.__position] = this.__vertexColorOffset.red1;
					this.__floatData[++this.__position] = this.__vertexColorOffset.green1;
					this.__floatData[++this.__position] = this.__vertexColorOffset.blue1;
					this.__floatData[++this.__position] = this.__vertexColorOffset.alpha1;
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
					this.__floatData[++this.__position] = this.__vertexColor.color2;
				}
				else
				{
					this.__floatData[++this.__position] = this.__vertexColor.red2;
					this.__floatData[++this.__position] = this.__vertexColor.green2;
					this.__floatData[++this.__position] = this.__vertexColor.blue2;
					this.__floatData[++this.__position] = this.__vertexColor.alpha2;
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
					this.__floatData[++this.__position] = this.__vertexColorOffset.color2;
				}
				else
				{
					this.__floatData[++this.__position] = this.__vertexColorOffset.red2;
					this.__floatData[++this.__position] = this.__vertexColorOffset.green2;
					this.__floatData[++this.__position] = this.__vertexColorOffset.blue2;
					this.__floatData[++this.__position] = this.__vertexColorOffset.alpha2;
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
					this.__floatData[++this.__position] = this.__vertexColor.color3;
				}
				else
				{
					this.__floatData[++this.__position] = this.__vertexColor.red3;
					this.__floatData[++this.__position] = this.__vertexColor.green3;
					this.__floatData[++this.__position] = this.__vertexColor.blue3;
					this.__floatData[++this.__position] = this.__vertexColor.alpha3;
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
					this.__floatData[++this.__position] = this.__vertexColorOffset.color3;
				}
				else
				{
					this.__floatData[++this.__position] = this.__vertexColorOffset.red3;
					this.__floatData[++this.__position] = this.__vertexColorOffset.green3;
					this.__floatData[++this.__position] = this.__vertexColorOffset.blue3;
					this.__floatData[++this.__position] = this.__vertexColorOffset.alpha3;
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
					this.__floatData[++this.__position] = this.__vertexColor.color4;
				}
				else
				{
					this.__floatData[++this.__position] = this.__vertexColor.red4;
					this.__floatData[++this.__position] = this.__vertexColor.green4;
					this.__floatData[++this.__position] = this.__vertexColor.blue4;
					this.__floatData[++this.__position] = this.__vertexColor.alpha4;
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
					this.__floatData[++this.__position] = this.__vertexColorOffset.color4;
				}
				else
				{
					this.__floatData[++this.__position] = this.__vertexColorOffset.red4;
					this.__floatData[++this.__position] = this.__vertexColorOffset.green4;
					this.__floatData[++this.__position] = this.__vertexColorOffset.blue4;
					this.__floatData[++this.__position] = this.__vertexColorOffset.alpha4;
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
					this.__vectorData[++this.__position] = this.__vertexColor.color1;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__vertexColor.red1;
					this.__vectorData[++this.__position] = this.__vertexColor.green1;
					this.__vectorData[++this.__position] = this.__vertexColor.blue1;
					this.__vectorData[++this.__position] = this.__vertexColor.alpha1;
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
					this.__vectorData[++this.__position] = this.__vertexColorOffset.color1;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__vertexColorOffset.red1;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.green1;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.blue1;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.alpha1;
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
					this.__vectorData[++this.__position] = this.__vertexColor.red2;
					this.__vectorData[++this.__position] = this.__vertexColor.green2;
					this.__vectorData[++this.__position] = this.__vertexColor.blue2;
					this.__vectorData[++this.__position] = this.__vertexColor.alpha2;
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
					this.__vectorData[++this.__position] = this.__vertexColorOffset.color2;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__vertexColorOffset.red2;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.green2;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.blue2;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.alpha2;
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
					this.__vectorData[++this.__position] = this.__vertexColor.color3;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__vertexColor.red3;
					this.__vectorData[++this.__position] = this.__vertexColor.green3;
					this.__vectorData[++this.__position] = this.__vertexColor.blue3;
					this.__vectorData[++this.__position] = this.__vertexColor.alpha3;
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
					this.__vectorData[++this.__position] = this.__vertexColorOffset.color3;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__vertexColorOffset.red3;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.green3;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.blue3;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.alpha3;
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
					this.__vectorData[++this.__position] = this.__vertexColor.color4;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__vertexColor.red4;
					this.__vectorData[++this.__position] = this.__vertexColor.green4;
					this.__vectorData[++this.__position] = this.__vertexColor.blue4;
					this.__vectorData[++this.__position] = this.__vertexColor.alpha4;
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
					this.__vectorData[++this.__position] = this.__vertexColorOffset.color4;
				}
				else
				{
					this.__vectorData[++this.__position] = this.__vertexColorOffset.red4;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.green4;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.blue4;
					this.__vectorData[++this.__position] = this.__vertexColorOffset.alpha4;
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
		
		if (this.__image._transformChanged)
		{
			updateTransform();
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
			this.__x1 = this.__image._x1 = this.__vertexPosition.x1 * this.__image.scaleX;
			this.__x2 = this.__image._x2 = this.__vertexPosition.x2 * this.__image.scaleX;
			this.__x3 = this.__image._x3 = this.__vertexPosition.x3 * this.__image.scaleX;
			this.__x4 = this.__image._x4 = this.__vertexPosition.x4 * this.__image.scaleX;
			this.__y1 = this.__image._y1 = this.__vertexPosition.y1 * this.__image.scaleY;
			this.__y2 = this.__image._y2 = this.__vertexPosition.y2 * this.__image.scaleY;
			this.__y3 = this.__image._y3 = this.__vertexPosition.y3 * this.__image.scaleY;
			this.__y4 = this.__image._y4 = this.__vertexPosition.y4 * this.__image.scaleY;
			this.__image._transformChanged = false;
		}
		else
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
	
	inline private function updateColor():Void
	{
		if (this.__useColor)
		{
			if (this.__image.hasVertexColor)
			{
				this.__uniformColor = false;
				this.__vertexColor = this.__image.vertexColor;
			}
			else
			{
				this.__uniformColor = true;
				if (this.__simpleColor)
				{
					this.__alpha = this.__image.alpha;
					this.__red = this.__image.red;
					this.__green = this.__image.green;
					this.__blue = this.__image.blue;
					normalizeColor();
					this.__color = getColor();
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
		}
		
		if (this.__useColorOffset)
		{
			if (this.__image.hasVertexColorOffset)
			{
				this.__uniformColorOffset = false;
				this.__vertexColorOffset = this.__image.vertexColorOffset;
			}
			else
			{
				this.__uniformColorOffset = true;
				if (this.__simpleColor)
				{
					this.__alpha = this.__image._alpha;
					this.__red = this.__image._red;
					this.__green = this.__image._green;
					this.__blue = this.__image._blue;
					normalizeColor();
					this.__colorOffset = getColorOffset();
				}
				else
				{
					this.__alphaOffset = this.__image.alphaOffset;
					this.__redOffset = this.__image.redOffset;
					this.__greenOffset = this.__image.greenOffset;
					this.__blueOffset = this.__image.blueOffset;
				}
			}
		}
		//if (this.__useColor && this.__image._colorChanged)
		//{
			//this.__image._colorChanged = false;
			//
			//if (this.__simpleColor)
			//{
				//if (this.__image._uniformColor)
				//{
					//this.__alpha = this.__image._alpha1;
					//this.__red = this.__image._red1;
					//this.__green = this.__image._green1;
					//this.__blue = this.__image._blue1;
					//normalizeColor();
					//this.__image._color1Final = this.__image._color2Final = this.__image._color3Final = this.__image._color4Final = getColor();
				//}
				//else
				//{
					//if (this.__image._invertX)
					//{
						//if (this.__image._invertY)
						//{
							//// top left
							//this.__alpha = this.__image._alpha4;
							//this.__red = this.__image._red4;
							//this.__green = this.__image._green4;
							//this.__blue = this.__image._blue4;
							//normalizeColor();
							//this.__image._color1Final = getColor();
							//
							//// top right
							//this.__alpha = this.__image._alpha3;
							//this.__red = this.__image._red3;
							//this.__green = this.__image._green3;
							//this.__blue = this.__image._blue3;
							//normalizeColor();
							//this.__image._color2Final = getColor();
							//
							//// bottom left
							//this.__alpha = this.__image._alpha2;
							//this.__red = this.__image._red2;
							//this.__green = this.__image._green2;
							//this.__blue = this.__image._blue2;
							//normalizeColor();
							//this.__image._color3Final = getColor();
							//
							//// bottom right
							//this.__alpha = this.__image._alpha1;
							//this.__red = this.__image._red1;
							//this.__green = this.__image._green1;
							//this.__blue = this.__image._blue1;
							//normalizeColor();
							//this.__image._color4Final = getColor();
						//}
						//else
						//{
							//// top left
							//this.__alpha = this.__image._alpha2;
							//this.__red = this.__image._red2;
							//this.__green = this.__image._green2;
							//this.__blue = this.__image._blue2;
							//normalizeColor();
							//this.__image._color1Final = getColor();
							//
							//// top right
							//this.__alpha = this.__image._alpha1;
							//this.__red = this.__image._red1;
							//this.__green = this.__image._green1;
							//this.__blue = this.__image._blue1;
							//normalizeColor();
							//this.__image._color2Final = getColor();
							//
							//// bottom left
							//this.__alpha = this.__image._alpha4;
							//this.__red = this.__image._red4;
							//this.__green = this.__image._green4;
							//this.__blue = this.__image._blue4;
							//normalizeColor();
							//this.__image._color3Final = getColor();
							//
							//// bottom right
							//this.__alpha = this.__image._alpha3;
							//this.__red = this.__image._red3;
							//this.__green = this.__image._green3;
							//this.__blue = this.__image._blue3;
							//normalizeColor();
							//this.__image._color4Final = getColor();
						//}
					//}
					//else if (this.__image._invertY)
					//{
						//// top left
						//this.__alpha = this.__image._alpha3;
						//this.__red = this.__image._red3;
						//this.__green = this.__image._green3;
						//this.__blue = this.__image._blue3;
						//normalizeColor();
						//this.__image._color1Final = getColor();
						//
						//// top right
						//this.__alpha = this.__image._alpha4;
						//this.__red = this.__image._red4;
						//this.__green = this.__image._green4;
						//this.__blue = this.__image._blue4;
						//normalizeColor();
						//this.__image._color2Final = getColor();
						//
						//// bottom left
						//this.__alpha = this.__image._alpha1;
						//this.__red = this.__image._red1;
						//this.__green = this.__image._green1;
						//this.__blue = this.__image._blue1;
						//normalizeColor();
						//this.__image._color3Final = getColor();
						//
						//// bottom right
						//this.__alpha = this.__image._alpha2;
						//this.__red = this.__image._red2;
						//this.__green = this.__image._green2;
						//this.__blue = this.__image._blue2;
						//normalizeColor();
						//this.__image._color4Final = getColor();
					//}
					//else
					//{
						//// top left
						//this.__alpha = this.__image._alpha1;
						//this.__red = this.__image._red1;
						//this.__green = this.__image._green1;
						//this.__blue = this.__image._blue1;
						//normalizeColor();
						//this.__image._color1Final = getColor();
						//
						//// top right
						//this.__alpha = this.__image._alpha2;
						//this.__red = this.__image._red2;
						//this.__green = this.__image._green2;
						//this.__blue = this.__image._blue2;
						//normalizeColor();
						//this.__image._color2Final = getColor();
						//
						//// bottom left
						//this.__alpha = this.__image._alpha3;
						//this.__red = this.__image._red3;
						//this.__green = this.__image._green3;
						//this.__blue = this.__image._blue3;
						//normalizeColor();
						//this.__image._color3Final = getColor();
						//
						//// bottom right
						//this.__alpha = this.__image._alpha4;
						//this.__red = this.__image._red4;
						//this.__green = this.__image._green4;
						//this.__blue = this.__image._blue4;
						//normalizeColor();
						//this.__image._color4Final = getColor();
					//}
				//}
			//}
			//else
			//{
				//if (this.__pma)
				//{
					//if (this.__image._uniformColor)
					//{
						//// all vertices
						//this.__alpha = this.__image._alpha1;
						//this.__image._red1Final = this.__image._red2Final = this.__image._red3Final = this.__image._red4Final = this.__image._red1 * this.__alpha;
						//this.__image._green1Final = this.__image._green2Final = this.__image._green3Final = this.__image._green4Final = this.__image._green1 * this.__alpha;
						//this.__image._blue1Final = this.__image._blue2Final = this.__image._blue3Final = this.__image._blue4Final = this.__image._blue1 * this.__alpha;
						//this.__image._alpha1Final = this.__image._alpha2Final = this.__image._alpha3Final = this.__image._alpha4Final = this.__alpha;
					//}
					//else
					//{
						//if (this.__image._invertX)
						//{
							//if (this.__image._invertY)
							//{
								//// top left
								//this.__alpha = this.__image._alpha4;
								//this.__image._red1Final = this.__image._red4 * this.__alpha;
								//this.__image._green1Final = this.__image._green4 * this.__alpha;
								//this.__image._blue1Final = this.__image._blue4 * this.__alpha;
								//this.__image._alpha1Final = this.__alpha;
								//
								//// top right
								//this.__alpha = this.__image._alpha3;
								//this.__image._red2Final = this.__image._red3 * this.__alpha;
								//this.__image._green2Final = this.__image._green3 * this.__alpha;
								//this.__image._blue2Final = this.__image._blue3 * this.__alpha;
								//this.__image._alpha2Final = this.__alpha;
								//
								//// bottom left
								//this.__alpha = this.__image._alpha2;
								//this.__image._red3Final = this.__image._red2 * this.__alpha;
								//this.__image._green3Final = this.__image._green2 * this.__alpha;
								//this.__image._blue3Final = this.__image._blue2 * this.__alpha;
								//this.__image._alpha3Final = this.__alpha;
								//
								//// bottom right
								//this.__alpha = this.__image._alpha1;
								//this.__image._red4Final = this.__image._red1 * this.__alpha;
								//this.__image._green4Final = this.__image._green1 * this.__alpha;
								//this.__image._blue4Final = this.__image._blue1 * this.__alpha;
								//this.__image._alpha4Final = this.__alpha;
							//}
							//else
							//{
								//// top left
								//this.__alpha = this.__image._alpha2;
								//this.__image._red1Final = this.__image._red2 * this.__alpha;
								//this.__image._green1Final = this.__image._green2 * this.__alpha;
								//this.__image._blue1Final = this.__image._blue2 * this.__alpha;
								//this.__image._alpha1Final = this.__alpha;
								//
								//// top right
								//this.__alpha = this.__image._alpha1;
								//this.__image._red2Final = this.__image._red1 * this.__alpha;
								//this.__image._green2Final = this.__image._green1 * this.__alpha;
								//this.__image._blue2Final = this.__image._blue1 * this.__alpha;
								//this.__image._alpha2Final = this.__alpha;
								//
								//// bottom left
								//this.__alpha = this.__image._alpha4;
								//this.__image._red3Final = this.__image._red4 * this.__alpha;
								//this.__image._green3Final = this.__image._green4 * this.__alpha;
								//this.__image._blue3Final = this.__image._blue4 * this.__alpha;
								//this.__image._alpha3Final = this.__alpha;
								//
								//// bottom right
								//this.__alpha = this.__image._alpha3;
								//this.__image._red4Final = this.__image._red3 * this.__alpha;
								//this.__image._green4Final = this.__image._green3 * this.__alpha;
								//this.__image._blue4Final = this.__image._blue3 * this.__alpha;
								//this.__image._alpha4Final = this.__alpha;
							//}
						//}
						//else if (this.__image._invertY)
						//{
							//// top left
							//this.__alpha = this.__image._alpha3;
							//this.__image._red1Final = this.__image._red3 * this.__alpha;
							//this.__image._green1Final = this.__image._green3* this.__alpha;
							//this.__image._blue1Final = this.__image._blue3 * this.__alpha;
							//this.__image._alpha1Final = this.__alpha;
							//
							//// top right
							//this.__alpha = this.__image._alpha4;
							//this.__image._red2Final = this.__image._red4 * this.__alpha;
							//this.__image._green2Final = this.__image._green4 * this.__alpha;
							//this.__image._blue2Final = this.__image._blue4 * this.__alpha;
							//this.__image._alpha2Final = this.__alpha;
							//
							//// bottom left
							//this.__alpha = this.__image._alpha1;
							//this.__image._red3Final = this.__image._red1 * this.__alpha;
							//this.__image._green3Final = this.__image._green1 * this.__alpha;
							//this.__image._blue3Final = this.__image._blue1 * this.__alpha;
							//this.__image._alpha3Final = this.__alpha;
							//
							//// bottom right
							//this.__alpha = this.__image._alpha2;
							//this.__image._red4Final = this.__image._red2 * this.__alpha;
							//this.__image._green4Final = this.__image._green2 * this.__alpha;
							//this.__image._blue4Final = this.__image._blue2 * this.__alpha;
							//this.__image._alpha4Final = this.__alpha;
						//}
						//else
						//{
							//// top left
							//this.__alpha = this.__image._alpha1;
							//this.__image._red1Final = this.__image._red1 * this.__alpha;
							//this.__image._green1Final = this.__image._green1 * this.__alpha;
							//this.__image._blue1Final = this.__image._blue1 * this.__alpha;
							//this.__image._alpha1Final = this.__alpha;
							//
							//// top right
							//this.__alpha = this.__image._alpha2;
							//this.__image._red2Final = this.__image._red2 * this.__alpha;
							//this.__image._green2Final = this.__image._green2 * this.__alpha;
							//this.__image._blue2Final = this.__image._blue2 * this.__alpha;
							//this.__image._alpha2Final = this.__alpha;
							//
							//// bottom left
							//this.__alpha = this.__image._alpha3;
							//this.__image._red3Final = this.__image._red3 * this.__alpha;
							//this.__image._green3Final = this.__image._green3 * this.__alpha;
							//this.__image._blue3Final = this.__image._blue3 * this.__alpha;
							//this.__image._alpha3Final = this.__alpha;
							//
							//// bottom right
							//this.__alpha = this.__image._alpha4;
							//this.__image._red4Final = this.__image._red4 * this.__alpha;
							//this.__image._green4Final = this.__image._green4 * this.__alpha;
							//this.__image._blue4Final = this.__image._blue4 * this.__alpha;
							//this.__image._alpha4Final = this.__alpha;
						//}
					//}
				//}
				//else
				//{
					//if (this.__image._uniformColor)
					//{
						//// all vertices
						//this.__image._red1Final = this.__image._red2Final = this.__image._red3Final = this.__image._red4Final = this.__image._red1;
						//this.__image._green1Final = this.__image._green2Final = this.__image._green3Final = this.__image._green4Final = this.__image._green1;
						//this.__image._blue1Final = this.__image._blue2Final = this.__image._blue3Final = this.__image._blue4Final = this.__image._blue1;
						//this.__image._alpha1Final = this.__image._alpha2Final = this.__image._alpha3Final = this.__image._alpha4Final = this.__image._alpha1;
					//}
					//else
					//{
						//if (this.__image._invertX)
						//{
							//if (this.__image._invertY)
							//{
								//// top left
								//this.__image._red1Final = this.__image._red4;
								//this.__image._green1Final = this.__image._green4;
								//this.__image._blue1Final = this.__image._blue4;
								//this.__image._alpha1Final = this.__image._alpha4;
								//
								//// top right
								//this.__image._red2Final = this.__image._red3;
								//this.__image._green2Final = this.__image._green3;
								//this.__image._blue2Final = this.__image._blue3;
								//this.__image._alpha2Final = this.__image._alpha3;
								//
								//// bottom left
								//this.__image._red3Final = this.__image._red2;
								//this.__image._green3Final = this.__image._green2;
								//this.__image._blue3Final = this.__image._blue2;
								//this.__image._alpha3Final = this.__image._alpha2;
								//
								//// bottom right
								//this.__image._red4Final = this.__image._red1;
								//this.__image._green4Final = this.__image._green1;
								//this.__image._blue4Final = this.__image._blue1;
								//this.__image._alpha4Final = this.__image._alpha1;
							//}
							//else
							//{
								//// top left
								//this.__image._red1Final = this.__image._red2;
								//this.__image._green1Final = this.__image._green2;
								//this.__image._blue1Final = this.__image._blue2;
								//this.__image._alpha1Final = this.__image._alpha2;
								//
								//// top right
								//this.__image._red2Final = this.__image._red1;
								//this.__image._green2Final = this.__image._green1;
								//this.__image._blue2Final = this.__image._blue1;
								//this.__image._alpha2Final = this.__image._alpha1;
								//
								//// bottom left
								//this.__image._red3Final = this.__image._red4;
								//this.__image._green3Final = this.__image._green4;
								//this.__image._blue3Final = this.__image._blue4;
								//this.__image._alpha3Final = this.__image._alpha4;
								//
								//// bottom right
								//this.__image._red4Final = this.__image._red3;
								//this.__image._green4Final = this.__image._green3;
								//this.__image._blue4Final = this.__image._blue3;
								//this.__image._alpha4Final = this.__image._alpha3;
							//}
						//}
						//else if (this.__image._invertY)
						//{
							//// top left
							//this.__image._red1Final = this.__image._red3;
							//this.__image._green1Final = this.__image._green3;
							//this.__image._blue1Final = this.__image._blue3;
							//this.__image._alpha1Final = this.__image._alpha3;
							//
							//// top right
							//this.__image._red2Final = this.__image._red4;
							//this.__image._green2Final = this.__image._green4;
							//this.__image._blue2Final = this.__image._blue4;
							//this.__image._alpha2Final = this.__image._alpha4;
							//
							//// bottom left
							//this.__image._red3Final = this.__image._red1;
							//this.__image._green3Final = this.__image._green1;
							//this.__image._blue3Final = this.__image._blue1;
							//this.__image._alpha3Final = this.__image._alpha1;
							//
							//// bottom right
							//this.__image._red4Final = this.__image._red2;
							//this.__image._green4Final = this.__image._green2;
							//this.__image._blue4Final = this.__image._blue2;
							//this.__image._alpha4Final = this.__image._alpha2;
						//}
						//else
						//{
							//// top left
							//this.__image._red1Final = this.__image._red1;
							//this.__image._green1Final = this.__image._green1;
							//this.__image._blue1Final = this.__image._blue1;
							//this.__image._alpha1Final = this.__image._alpha1;
							//
							//// top right
							//this.__image._red2Final = this.__image._red2;
							//this.__image._green2Final = this.__image._green2;
							//this.__image._blue2Final = this.__image._blue2;
							//this.__image._alpha2Final = this.__image._alpha2;
							//
							//// bottom left
							//this.__image._red3Final = this.__image._red3;
							//this.__image._green3Final = this.__image._green3;
							//this.__image._blue3Final = this.__image._blue3;
							//this.__image._alpha3Final = this.__image._alpha3;
							//
							//// bottom right
							//this.__image._red4Final = this.__image._red4;
							//this.__image._green4Final = this.__image._green4;
							//this.__image._blue4Final = this.__image._blue4;
							//this.__image._alpha4Final = this.__image._alpha4;
						//}
					//}
				//}
			//}
		//}
		//
		//if (this.__useColorOffset && this.__image._colorOffsetChanged)
		//{
			//this.__image._colorOffsetChanged = false;
			//
			//if (this.__simpleColor)
			//{
				//if (this.__image._uniformColorOffset)
				//{
					//// top left / all (if uniform color)
					//this.__alpha = this.__image._alphaOffset1;
					//this.__red = this.__image._redOffset1;
					//this.__green = this.__image._greenOffset1;
					//this.__blue = this.__image._blueOffset1;
					//normalizeColor();
					//this.__image._colorOffset1Final = this.__image._colorOffset2Final = this.__image._colorOffset3Final = this.__image._colorOffset4Final = getColorOffset();
				//}
				//else
				//{
					//// top left / all (if uniform color)
					//this.__alpha = this.__image._alphaOffset1;
					//this.__red = this.__image._redOffset1;
					//this.__green = this.__image._greenOffset1;
					//this.__blue = this.__image._blueOffset1;
					//normalizeColor();
					//this.__image._colorOffset1Final = getColorOffset();
					//
					//// top right
					//this.__alpha = this.__image._alphaOffset2;
					//this.__red = this.__image._redOffset2;
					//this.__green = this.__image._greenOffset2;
					//this.__blue = this.__image._blueOffset2;
					//normalizeColor();
					//this.__image._colorOffset2Final = getColorOffset();
					//
					//// bottom left
					//this.__alpha = this.__image._alphaOffset3;
					//this.__red = this.__image._redOffset3;
					//this.__green = this.__image._greenOffset3;
					//this.__blue = this.__image._blueOffset3;
					//normalizeColor();
					//this.__image._colorOffset3Final = getColorOffset();
					//
					//// bottom right
					//this.__alpha = this.__image._alphaOffset4;
					//this.__red = this.__image._redOffset4;
					//this.__green = this.__image._greenOffset4;
					//this.__blue = this.__image._blueOffset4;
					//normalizeColor();
					//this.__image._colorOffset4Final = getColorOffset();
				//}
			//}
			//else
			//{
				//if (this.__pmaForColorOffset)
				//{
					//if (this.__image._uniformColorOffset)
					//{
						//this.__alpha = this.__image._alphaOffset1;
						//this.__image._redOffset1Final = this.__image._redOffset2Final = this.__image._redOffset3Final = this.__image._redOffset4Final = this.__image._redOffset1 * this.__alpha;
						//this.__image._greenOffset1Final = this.__image._greenOffset2Final = this.__image._greenOffset3Final = this.__image._greenOffset4Final = this.__image._greenOffset1 * this.__alpha;
						//this.__image._blueOffset1Final = this.__image._blueOffset2Final = this.__image._blueOffset3Final = this.__image._blueOffset4Final = this.__image._blueOffset1 * this.__alpha;
						//this.__image._alphaOffset1Final = this.__image._alphaOffset2Final = this.__image._alphaOffset3Final = this.__image._alphaOffset4Final = this.__alpha;
					//}
					//else
					//{
						//if (this.__image._invertX)
						//{
							//if (this.__image._invertY)
							//{
								//// top left
								//this.__alpha = this.__image._alphaOffset4;
								//this.__image._redOffset1Final = this.__image._redOffset4 * this.__alpha;
								//this.__image._greenOffset1Final = this.__image._greenOffset4 * this.__alpha;
								//this.__image._blueOffset1Final = this.__image._blueOffset4 * this.__alpha;
								//this.__image._alphaOffset1Final = this.__alpha;
								//
								//// top right
								//this.__alpha = this.__image._alphaOffset3;
								//this.__image._redOffset2Final = this.__image._redOffset3 * this.__alpha;
								//this.__image._greenOffset2Final = this.__image._greenOffset3 * this.__alpha;
								//this.__image._blueOffset2Final = this.__image._blueOffset3 * this.__alpha;
								//this.__image._alphaOffset2Final = this.__alpha;
								//
								//// bottom left
								//this.__alpha = this.__image._alphaOffset2;
								//this.__image._redOffset3Final = this.__image._redOffset2 * this.__alpha;
								//this.__image._greenOffset3Final = this.__image._greenOffset2 * this.__alpha;
								//this.__image._blueOffset3Final = this.__image._blueOffset2 * this.__alpha;
								//this.__image._alphaOffset3Final = this.__alpha;
								//
								//// bottom right
								//this.__alpha = this.__image._alphaOffset1;
								//this.__image._redOffset4Final = this.__image._redOffset1 * this.__alpha;
								//this.__image._greenOffset4Final = this.__image._greenOffset1 * this.__alpha;
								//this.__image._blueOffset4Final = this.__image._blueOffset1 * this.__alpha;
								//this.__image._alphaOffset4Final = this.__alpha;
							//}
							//else
							//{
								//// top left
								//this.__alpha = this.__image._alphaOffset2;
								//this.__image._redOffset1Final = this.__image._redOffset2 * this.__alpha;
								//this.__image._greenOffset1Final = this.__image._greenOffset2 * this.__alpha;
								//this.__image._blueOffset1Final = this.__image._blueOffset2 * this.__alpha;
								//this.__image._alphaOffset1Final = this.__alpha;
								//
								//// top right
								//this.__alpha = this.__image._alphaOffset1;
								//this.__image._redOffset2Final = this.__image._redOffset1 * this.__alpha;
								//this.__image._greenOffset2Final = this.__image._greenOffset1 * this.__alpha;
								//this.__image._blueOffset2Final = this.__image._blueOffset1 * this.__alpha;
								//this.__image._alphaOffset2Final = this.__alpha;
								//
								//// bottom left
								//this.__alpha = this.__image._alphaOffset4;
								//this.__image._redOffset3Final = this.__image._redOffset4 * this.__alpha;
								//this.__image._greenOffset3Final = this.__image._greenOffset4 * this.__alpha;
								//this.__image._blueOffset3Final = this.__image._blueOffset4 * this.__alpha;
								//this.__image._alphaOffset3Final = this.__alpha;
								//
								//// bottom right
								//this.__alpha = this.__image._alphaOffset3;
								//this.__image._redOffset4Final = this.__image._redOffset3 * this.__alpha;
								//this.__image._greenOffset4Final = this.__image._greenOffset3 * this.__alpha;
								//this.__image._blueOffset4Final = this.__image._blueOffset3 * this.__alpha;
								//this.__image._alphaOffset4Final = this.__alpha;
							//}
						//}
						//else if (this.__image._invertY)
						//{
							//// top left
							//this.__alpha = this.__image._alphaOffset3;
							//this.__image._redOffset1Final = this.__image._redOffset3 * this.__alpha;
							//this.__image._greenOffset1Final = this.__image._greenOffset3 * this.__alpha;
							//this.__image._blueOffset1Final = this.__image._blueOffset3 * this.__alpha;
							//this.__image._alphaOffset1Final = this.__alpha;
							//
							//// top right
							//this.__alpha = this.__image._alphaOffset4;
							//this.__image._redOffset2Final = this.__image._redOffset4 * this.__alpha;
							//this.__image._greenOffset2Final = this.__image._greenOffset4 * this.__alpha;
							//this.__image._blueOffset2Final = this.__image._blueOffset4 * this.__alpha;
							//this.__image._alphaOffset2Final = this.__alpha;
							//
							//// bottom left
							//this.__alpha = this.__image._alphaOffset1;
							//this.__image._redOffset3Final = this.__image._redOffset1 * this.__alpha;
							//this.__image._greenOffset3Final = this.__image._greenOffset1 * this.__alpha;
							//this.__image._blueOffset3Final = this.__image._blueOffset1 * this.__alpha;
							//this.__image._alphaOffset3Final = this.__alpha;
							//
							//// bottom right
							//this.__alpha = this.__image._alphaOffset2;
							//this.__image._redOffset4Final = this.__image._redOffset2 * this.__alpha;
							//this.__image._greenOffset4Final = this.__image._greenOffset2 * this.__alpha;
							//this.__image._blueOffset4Final = this.__image._blueOffset2 * this.__alpha;
							//this.__image._alphaOffset4Final = this.__alpha;
						//}
						//else
						//{
							//// top left
							//this.__alpha = this.__image._alphaOffset1;
							//this.__image._redOffset1Final = this.__image._redOffset1 * this.__alpha;
							//this.__image._greenOffset1Final = this.__image._greenOffset1 * this.__alpha;
							//this.__image._blueOffset1Final = this.__image._blueOffset1 * this.__alpha;
							//this.__image._alphaOffset1Final = this.__alpha;
							//
							//// top right
							//this.__alpha = this.__image._alphaOffset2;
							//this.__image._redOffset2Final = this.__image._redOffset2 * this.__alpha;
							//this.__image._greenOffset2Final = this.__image._greenOffset2 * this.__alpha;
							//this.__image._blueOffset2Final = this.__image._blueOffset2 * this.__alpha;
							//this.__image._alphaOffset2Final = this.__alpha;
							//
							//// bottom left
							//this.__alpha = this.__image._alphaOffset3;
							//this.__image._redOffset3Final = this.__image._redOffset3 * this.__alpha;
							//this.__image._greenOffset3Final = this.__image._greenOffset3 * this.__alpha;
							//this.__image._blueOffset3Final = this.__image._blueOffset3 * this.__alpha;
							//this.__image._alphaOffset3Final = this.__alpha;
							//
							//// bottom right
							//this.__alpha = this.__image._alphaOffset4;
							//this.__image._redOffset4Final = this.__image._redOffset4 * this.__alpha;
							//this.__image._greenOffset4Final = this.__image._greenOffset4 * this.__alpha;
							//this.__image._blueOffset4Final = this.__image._blueOffset4 * this.__alpha;
							//this.__image._alphaOffset4Final = this.__alpha;
						//}
					//}
				//}
				//else
				//{
					//if (this.__image._uniformColorOffset)
					//{
						//this.__image._redOffset1Final = this.__image._redOffset2Final = this.__image._redOffset3Final = this.__image._redOffset4Final = this.__image._redOffset1;
						//this.__image._greenOffset1Final = this.__image._greenOffset2Final = this.__image._greenOffset3Final = this.__image._greenOffset4Final = this.__image._greenOffset1;
						//this.__image._blueOffset1Final = this.__image._blueOffset2Final = this.__image._blueOffset3Final = this.__image._blueOffset4Final = this.__image._blueOffset1;
						//this.__image._alphaOffset1Final = this.__image._alphaOffset2Final = this.__image._alphaOffset3Final = this.__image._alphaOffset4Final = this.__image._alphaOffset1;
					//}
					//else
					//{
						//if (this.__image._invertX)
						//{
							//if (this.__image._invertY)
							//{
								//// top left
								//this.__image._redOffset1Final = this.__image._redOffset4;
								//this.__image._greenOffset1Final = this.__image._greenOffset4;
								//this.__image._blueOffset1Final = this.__image._blueOffset4;
								//this.__image._alphaOffset1Final = this.__image._alphaOffset4;
								//
								//// top right
								//this.__image._redOffset2Final = this.__image._redOffset3;
								//this.__image._greenOffset2Final = this.__image._greenOffset3;
								//this.__image._blueOffset2Final = this.__image._blueOffset3;
								//this.__image._alphaOffset2Final = this.__image._alphaOffset3;
								//
								//// bottom left
								//this.__image._redOffset3Final = this.__image._redOffset2;
								//this.__image._greenOffset3Final = this.__image._greenOffset2;
								//this.__image._blueOffset3Final = this.__image._blueOffset2;
								//this.__image._alphaOffset3Final = this.__image._alphaOffset2;
								//
								//// bottom right
								//this.__image._redOffset4Final = this.__image._redOffset1;
								//this.__image._greenOffset4Final = this.__image._greenOffset1;
								//this.__image._blueOffset4Final = this.__image._blueOffset1;
								//this.__image._alphaOffset4Final = this.__image._alphaOffset1;
							//}
							//else
							//{
								//// top left
								//this.__image._redOffset1Final = this.__image._redOffset2;
								//this.__image._greenOffset1Final = this.__image._greenOffset2;
								//this.__image._blueOffset1Final = this.__image._blueOffset2;
								//this.__image._alphaOffset1Final = this.__image._alphaOffset2;
								//
								//// top right
								//this.__image._redOffset2Final = this.__image._redOffset1;
								//this.__image._greenOffset2Final = this.__image._greenOffset1;
								//this.__image._blueOffset2Final = this.__image._blueOffset1;
								//this.__image._alphaOffset2Final = this.__image._alphaOffset1;
								//
								//// bottom left
								//this.__image._redOffset3Final = this.__image._redOffset4;
								//this.__image._greenOffset3Final = this.__image._greenOffset4;
								//this.__image._blueOffset3Final = this.__image._blueOffset4;
								//this.__image._alphaOffset3Final = this.__image._alphaOffset4;
								//
								//// bottom right
								//this.__image._redOffset4Final = this.__image._redOffset3;
								//this.__image._greenOffset4Final = this.__image._greenOffset3;
								//this.__image._blueOffset4Final = this.__image._blueOffset3;
								//this.__image._alphaOffset4Final = this.__image._alphaOffset3;
							//}
						//}
						//else if (this.__image._invertY)
						//{
							//// top left
							//this.__image._redOffset1Final = this.__image._redOffset3;
							//this.__image._greenOffset1Final = this.__image._greenOffset3;
							//this.__image._blueOffset1Final = this.__image._blueOffset3;
							//this.__image._alphaOffset1Final = this.__image._alphaOffset3;
							//
							//// top right
							//this.__image._redOffset2Final = this.__image._redOffset4;
							//this.__image._greenOffset2Final = this.__image._greenOffset4;
							//this.__image._blueOffset2Final = this.__image._blueOffset4;
							//this.__image._alphaOffset2Final = this.__image._alphaOffset4;
							//
							//// bottom left
							//this.__image._redOffset3Final = this.__image._redOffset1;
							//this.__image._greenOffset3Final = this.__image._greenOffset1;
							//this.__image._blueOffset3Final = this.__image._blueOffset1;
							//this.__image._alphaOffset3Final = this.__image._alphaOffset1;
							//
							//// bottom right
							//this.__image._redOffset4Final = this.__image._redOffset2;
							//this.__image._greenOffset4Final = this.__image._greenOffset2;
							//this.__image._blueOffset4Final = this.__image._blueOffset2;
							//this.__image._alphaOffset4Final = this.__image._alphaOffset2;
						//}
						//else
						//{
							//// top left
							//this.__image._redOffset1Final = this.__image._redOffset1;
							//this.__image._greenOffset1Final = this.__image._greenOffset1;
							//this.__image._blueOffset1Final = this.__image._blueOffset1;
							//this.__image._alphaOffset1Final = this.__image._alphaOffset1;
							//
							//// top right
							//this.__image._redOffset2Final = this.__image._redOffset2;
							//this.__image._greenOffset2Final = this.__image._greenOffset2;
							//this.__image._blueOffset2Final = this.__image._blueOffset2;
							//this.__image._alphaOffset2Final = this.__image._alphaOffset2;
							//
							//// bottom left
							//this.__image._redOffset3Final = this.__image._redOffset3;
							//this.__image._greenOffset3Final = this.__image._greenOffset3;
							//this.__image._blueOffset3Final = this.__image._blueOffset3;
							//this.__image._alphaOffset3Final = this.__image._alphaOffset3;
							//
							//// bottom right
							//this.__image._redOffset4Final = this.__image._redOffset4;
							//this.__image._greenOffset4Final = this.__image._greenOffset4;
							//this.__image._blueOffset4Final = this.__image._blueOffset4;
							//this.__image._alphaOffset4Final = this.__image._alphaOffset4;
						//}
					//}
				//}
			//}
		//}
	}
	
	private var __data:DisplayBase;
	private var __container:MixedContainer;
	private var __image:Img;
	private var __clip:Clip;
	
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
	
	private var __multiTexturing:Bool;
	private var __textureIndex:Float;
	private var __position:Int;
	private var __quadsWritten:Int;
	private var __numQuads:Int;
	private var __quadOffset:Int;
	private var __totalQuads:Int;
	private var __pma:Bool;
	private var __pmaForColorOffset:Bool;
	private var __useColor:Bool;
	private var __useDisplayColor:Bool;
	private var __useColorOffset:Bool;
	private var __simpleColor:Bool;
	private var __storeBounds:Bool;
	private var __boundsIndex:Int;
	private var __renderOffsetX:Float;
	private var __renderOffsetY:Float;
}