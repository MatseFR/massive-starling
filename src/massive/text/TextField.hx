package massive.text;
#if !flash
import lime.utils.Float32Array;
#end
import massive.display.Img;
import massive.display.MassiveDisplay;
import massive.display.base.ContainerBase;
import massive.display.render.RenderData;
import massive.text.internal.TextLayoutResult;
import openfl.Vector;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import starling.events.Event;
import starling.text.TextFieldAutoSize;

/**
 * ...
 * @author Matse
 */
class TextField extends ContainerBase 
{
	private static var _POOL:Array<TextField> = new Array<TextField>();
	
	public static function fromPool():TextField
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TextField();
	}
	
	public var format(get, set):TextFormat;
	public var height(get, set):Float;
	public var options(get, set):TextOptions;
	public var text(get, set):String;
	public var textData(get, set):String;
	public var textObject(get, set):Text;
	public var width(get, set):Float;
	
	private var _format:TextFormat = new TextFormat();
	private function get_format():TextFormat { return this._format; }
	private function set_format(value:TextFormat):TextFormat
	{
		if (value == null) 
		{
			this._format.clear();
			return value;
		}
		this._format.copyFrom(value);
		return this._format = value;
	}
	
	private var _height:Float;
	private function get_height():Float { return this._height; }
	private function set_height(value:Float):Float
	{
		if (this._height == value) return value;
		this._requiresRecomposition = this._textObject != null;
		return this._height = value;
	}
	
	private var _options:TextOptions = new TextOptions();
	private function get_options():TextOptions { return this._options; }
	private function set_options(value:TextOptions):TextOptions
	{
		if (value == null)
		{
			this._options.clear();
			return value;
		}
		this._options.copyFrom(value);
		return this._options = value;
	}
	
	private var _text:String;
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		clearText();
		if (value != null)
		{
			createTextObject();
			var part:TextPart = TextPart.fromPool();
			part.text = value;
			this._textObject.addPart(part);
			this._requiresRecomposition = true;
		}
		return this._text = value;
	}
	
	private var _textData:String;
	private function get_textData():String { return this._textData; }
	private function set_textData(value:String):String
	{
		clearText();
		if (value != null)
		{
			createTextObject();
			MassiveText.parseText(value, this._textObject);
			this._requiresRecomposition = true;
		}
		return this._textData = value;
	}
	
	private var _textObject:Text;
	private function get_textObject():Text { return this._textObject; }
	private function set_textObject(value:Text):Text
	{
		if (this._textObject == value) return value;
		clearText();
		if (value != null)
		{
			this._isTextObjectExternal = true;
			this._requiresRecomposition = true;
		}
		return this._textObject = value;
	}
	
	private var _width:Float;
	private function get_width():Float { return this._width; }
	private function set_width(value:Float):Float
	{
		if (this._width == value) return value;
		this._requiresRecomposition = this._textObject != null;
		return this._width = value;
	}
	
	private var _bounds:Rectangle = new Rectangle();
	#if flash
	private var _boundsData:Vector<Float> = new Vector<Float>();
	private var _datas:Vector<Img> = new Vector<Img>();
	#else
	private var _boundsData:Array<Float> = new Array<Float>();
	private var _datas:Array<Img> = new Array<Img>();
	#end
	private var _isTextObjectExternal:Bool;
	private var _requiresBounds:Bool;
	private var _requiresRecomposition:Bool;
	
	private var _isAutoSize:Bool;
	private var _isHorizontalAutoSize:Bool;
	private var _isVerticalAutoSize:Bool;

	public function new(text:String = null, format:TextFormat = null, options:TextOptions = null, width:Float = 0.0, height:Float = 0.0) 
	{
		super();
		if (text != null) this.text = text;
		if (format != null) this.format = format;
		if (options != null) this.options = options;
		this._width = width;
		this._height = height;
	}
	
	override public function clear():Void
	{
		clearText();
		this._format.clear();
		this._options.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setFromPool(text:String, format:TextFormat, options:TextOptions, width:Float, height:Float):TextField
	{
		if (text != null) this.text = text;
		if (format != null) this.format = format;
		if (options != null) this.options = options;
		this._width = width;
		this._height = height;
		return this;
	}
	
	private function clearText():Void
	{
		if (this._datas.length != 0)
		{
			#if flash
			Img.toPoolVector(this._datas);
			this._datas.length = 0;
			#else
			Img.toPoolArray(this._datas);
			this._datas.resize(0);
			#end
		}
		
		this._text = null;
		this._textData = null;
		
		if (this._textObject == null) return;
		
		if (this._isTextObjectExternal)
		{
			this._isTextObjectExternal = false;
		}
		else
		{
			this._textObject.pool();
		}
		this._textObject = null;
	}
	
	private function createTextObject():Void
	{
		this._textObject = Text.fromPool(this._format, this._options);
	}
	
	private function onFormatChange(evt:Event):Void
	{
		if (!this._requiresRecomposition) this._requiresRecomposition = this._textObject != null;
	}
	
	private function onOptionsChange(evt:Event):Void
	{
		this._isAutoSize = this._options.autoSize != TextFieldAutoSize.NONE;
		if (this._isAutoSize)
		{
			if (this._options.autoSize == TextFieldAutoSize.BOTH_DIRECTIONS)
			{
				this._isHorizontalAutoSize = true;
				this._isVerticalAutoSize = true;
			}
			else
			{
				this._isHorizontalAutoSize = this._options.autoSize == TextFieldAutoSize.HORIZONTAL;
				this._isVerticalAutoSize = this._options.autoSize == TextFieldAutoSize.VERTICAL;
			}
		}
		else
		{
			this._isHorizontalAutoSize = false;
			this._isVerticalAutoSize = false;
		}
		
		if (!this._requiresRecomposition) this._requiresRecomposition = this._textObject != null;
	}
	
	private function recompose(display:MassiveDisplay):Void
	{
		#if flash
		Img.toPoolVector(this._datas);
		this._datas.length = 0;
		#else
		Img.toPoolArray(this._datas);
		this._datas.resize(0);
		#end
		
		var w:Float = this._isHorizontalAutoSize ? 100000 : this._width;
		var h:Float = this._isVerticalAutoSize ? 1000000 : this._height;
		
		var result:TextLayoutResult = MassiveText.processText(w, h, this._textObject, null);
		result.getImages(display, this._datas);
		GlyphLocation.rechargePool();
		result.pool();
		
		this._requiresBounds = this._isAutoSize;
	}
	
	private function updateBounds():Void
	{
		
		this._requiresBounds = false;
	}
	
	/**
	   @inheritDoc
	**/
	public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this._requiresRecomposition) recompose(renderData.display);
		
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
		
		if (this._requiresRecomposition) recompose(renderData.display);
		
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
		
		if (this._requiresRecomposition) recompose(renderData.display);
		
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
		
		if (this._requiresRecomposition) recompose(renderData.display);
		
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
			if (!this.__image.visible) continue;
			
			writeImageBounds();
		}
	}
	
}