package massive.display;
import massive.display.base.ContainerBase;
import massive.util.MathUtils;
import openfl.Vector;
import massive.display.render.RenderData;
import openfl.utils.ByteArray;
#if !flash
import openfl.utils._internal.Float32Array;
#end

/**
 * ...
 * @author Matse
 */
class ImgContainer extends ContainerBase 
{
	#if flash
	private var _datas:Vector<Img>;
	#else
	private var _datas:Array<Img>;
	#end
	
	#if flash
	public function new(datas:Vector<Img> = null) 
	#else
	public function new(datas:Array<Img> = null)
	#end
	{
		super();
		
		this._datas = datas;
		#if flash
		if (this._datas == null) this._datas = new Vector<Img>();
		#else
		if (this._datas == null) this._datas = new Array<Img>();
		#end
	}
	
	public function addChild(child:Img):Void
	{
		this._datas[this._datas.length] = child;
	}
	
	public function addChildAt(child:Img, index:Int):Void
	{
		#if flash
		this._datas.insertAt(index, child);
		#else
		this._datas.insert(index, child);
		#end
	}
	
	public function addChildren(children:Array<Img>):Void
	{
		var count:Int = children.length;
		for (i in 0...count)
		{
			this._datas[this._datas.length] = children[i];
		}
	}
	
	public function addChildrenAt(children:Array<Img>, index:Int):Void
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
	
	public function getChildAt(index:Int):Img
	{
		return this._datas[index];
	}
	
	public function getChildIndex(child:Img):Int
	{
		return this._datas.indexOf(child);
	}
	
	public function removeChild(child:Img):Void
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
	
	public function removeChildren(children:Array<Img>):Void
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
			this.__image = this._datas[i];
			if (!this.__image.visible) continue;
			
			writeImageBytes();
			
			if (++this.__quadsWritten == maxQuads)
			{
				renderData.numQuads = this.__quadsWritten;
				renderData.display.drawBytes();
				this.__quadsWritten = 0;
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
			this.__image = this._datas[i];
			if (!this.__image.visible) continue;
			
			writeImageBytesMemory();
			
			if (++this.__quadsWritten == maxQuads)
			{
				renderData.numQuads = this.__quadsWritten;
				renderData.display.drawBytesMemory();
				this.__quadsWritten = 0;
				this.__position = 0;
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
			this.__image = this._datas[i];
			if (!this.__image.visible) continue;
			
			writeImageFloat32Array();
			
			if (++this.__quadsWritten == maxQuads)
			{
				renderData.numQuads = this.__quadsWritten;
				renderData.display.drawFloat32();
				this.__quadsWritten = 0;
				this.__position = 0;
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
			this.__image = this._datas[i];
			if (!this.__image.visible) continue;
			
			writeImageVector();
			
			if (++this.__quadsWritten == maxQuads)
			{
				renderData.numQuads = this.__quadsWritten;
				renderData.display.drawVector();
				this.__quadsWritten = 0;
				this.__position = 0;
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
			this.__image = this._datas[i];
			if (!this.__data.visible) continue;
			
			writeImageBounds();
		}
	}
	
}