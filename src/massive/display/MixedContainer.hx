package massive.display;
import massive.display.base.ContainerBase;
import massive.display.base.DisplayBase;
import massive.display.render.RenderData;
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
class MixedContainer extends ContainerBase 
{
	#if flash
	private var _datas:Vector<DisplayBase>;
	#else
	private var _datas:Array<DisplayBase>;
	#end
	
	#if flash
	public function new(datas:Vector<DisplayBase> = null) 
	#else
	public function new(datas:Array<DisplayBase> = null)
	#end
	{
		super();
		
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
	
	public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		prepareDataBytes(byteData, maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
		
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
				
				writeImageBytes();
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawBytes();
					this.__quadsWritten = 0;
				}
			}
		}
		
		finishDataBytes();
	}
	
	#if flash
	/**
	   @inheritDoc
	**/
	public function writeDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Void
	{
		if (this._datas == null) return;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		prepareDataBytesMemory(maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
		
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
				
				writeImageBytesMemory();
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawBytesMemory();
					this.__quadsWritten = 0;
					this.__position = 0;
				}
			}
		}
		
		finishDataBytesMemory();
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
		
		prepareDataFloat32Array(floatData, maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
		
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
				
				writeImageFloat32Array();
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawFloat32();
					this.__quadsWritten = 0;
					this.__position = 0;
				}
			}
		}
		
		finishDataFloat32Array();
	}
	#end
	
	/**
	   @inheritDoc
	**/
	public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		prepareDataVector(vectorData, maxQuads, renderOffsetX, renderOffsetY, renderData, boundsData);
		
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
				
				writeImageVector();
				
				if (++this.__quadsWritten == maxQuads)
				{
					renderData.numQuads = this.__quadsWritten;
					renderData.display.drawVector();
					this.__quadsWritten = 0;
					this.__position = 0;
				}
			}
		}
		
		finishDataVector();
	}
	
	public function writeBoundsData(boundsData:#if flash Vector<Float> #else Array<Float> #end, renderOffsetX:Float, renderOffsetY:Float):Void
	{
		this.__boundsData = boundsData;
		this.__position = this.__boundsData.length-1;
		
		if (this.autoHandleNumDatas) this.numDatas = this._datas.length;
		
		this.__renderOffsetX = renderOffsetX + this.x;
		this.__renderOffsetY = renderOffsetY + this.y;
		
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
				
				writeImageBounds();
			}
		}
	}
}