package massive.text;
#if !flash
import lime.utils.Float32Array;
#end
import massive.animation.Animator;
import massive.display.Clip;
import massive.display.Img;
import massive.display.MassiveDisplay;
import massive.display.base.ContainerBase;
import massive.display.render.RenderData;
import massive.text.internal.ElementLocation;
import massive.text.internal.TextLayoutResult;
import massive.text.lang.LangRules;
import massive.util.MathUtils;
import openfl.Vector;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import starling.events.Event;
import starling.text.TextFieldAutoSize;
import starling.textures.Texture;

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
	
	public var animator(get, set):Animator;
	public var format(get, set):TextFormat;
	public var height(get, set):Float;
	public var langRules(get, set):LangRules;
	public var options(get, set):TextOptions;
	public var text(get, set):String;
	public var textData(get, set):String;
	public var textDataSafeMode:Bool;
	public var textObject(get, set):Text;
	public var width(get, set):Float;
	
	private var _animator:Animator;
	private function get_animator():Animator { return this._animator; }
	private function set_animator(value:Animator):Animator
	{
		if (this._animator == value) return value;
		if (this._animator != null)
		{
			this._animator.removeBasicClipList(this._clips);
		}
		if (value != null)
		{
			value.addBasicClipList(this._clips);
		}
		return this._animator = value;
	}
	
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
	
	private var _langRules:LangRules;
	private function get_langRules():LangRules { return this._langRules; }
	private function set_langRules(value:LangRules):LangRules
	{
		if (this._langRules == value) return value;
		this._requiresRecomposition = this._textObject != null;
		return this._langRules = value;
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
			var part:TextPartString = TextPartString.fromPool();
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
			if (this.textDataSafeMode)
			{
				MassiveText.parseTextSafe(value, this._textObject);
			}
			else
			{
				MassiveText.parseText(value, this._textObject);
			}
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
	private var _clips:Vector<Clip> = new Vector<Clip>();
	private var _images:Vector<Img> = new Vector<Img>();
	private var _addedTextures:Vector<Texture> = new Vector<Texture>();
	#else
	private var _boundsData:Array<Float> = new Array<Float>();
	private var _datas:Array<Img> = new Array<Img>();
	private var _clips:Array<Clip> = new Array<Clip>();
	private var _images:Array<Img> = new Array<Img>();
	private var _addedTextures:Array<Texture> = new Array<Texture>();
	#end
	private var _lastDisplay:MassiveDisplay;
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
		
		this._format.addEventListener(Event.CHANGE, onFormatChange);
		this._options.addEventListener(Event.CHANGE, onOptionsChange);
	}
	
	override public function clear():Void
	{
		clearText();
		this.animator = null;
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
		#if flash
		if (this._images.length != 0)
		{
			Img.toPoolVector(this._images);
			this._images.length = 0;
		}
		if (this._clips.length != 0)
		{
			Clip.toPoolVector(this._clips);
			this._clips.length = 0;
		}
		if (this._addedTextures.length != 0)
		{
			this._lastDisplay.removeTextures(this._addedTextures);
			this._addedTextures.length = 0;
		}
		this._datas.length = 0;
		#else
		if (this._images.length != 0)
		{
			Img.toPoolArray(this._images);
			this._images.resize(0);
		}
		if (this._clips.length != 0)
		{
			Clip.toPoolArray(this._clips);
			this._clips.resize(0);
		}
		if (this._addedTextures.length != 0)
		{
			this._lastDisplay.removeTextures(this._addedTextures);
			this._addedTextures.resize(0);
		}
		this._datas.resize(0);
		#end
		
		this._lastDisplay = null;
		
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
		if (this._textObject != null)
		{
			this._textObject.format = this._format;
			this._requiresRecomposition = true;
		}
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
		
		if (this._textObject != null)
		{
			this._textObject.options = this._options;
			this._requiresRecomposition = true;
		}
	}
	
	private function recompose(display:MassiveDisplay):Void
	{
		#if flash
		if (this._images.length != 0)
		{
			Img.toPoolVector(this._images);
			this._images.length = 0;
		}
		if (this._clips.length != 0)
		{
			Clip.toPoolVector(this._clips);
			this._clips.length = 0;
		}
		if (this._addedTextures.length != 0)
		{
			this._lastDisplay.removeTextures(this._addedTextures);
			this._addedTextures.length = 0;
		}
		this._datas.length = 0;
		#else
		if (this._images.length != 0)
		{
			Img.toPoolArray(this._images);
			this._images.resize(0);
		}
		if (this._clips.length != 0)
		{
			Clip.toPoolArray(this._clips);
			this._clips.resize(0);
		}
		if (this._addedTextures.length != 0)
		{
			this._lastDisplay.removeTextures(this._addedTextures);
			this._addedTextures.resize(0);
		}
		this._datas.resize(0);
		#end
		
		var w:Float = this._isHorizontalAutoSize ? 1000000 : this._width;
		var h:Float = this._isVerticalAutoSize ? 10000000 : this._height;
		
		var result:TextLayoutResult = MassiveText.processText(w, h, this._textObject, this._langRules);
		result.getImages(display, this._datas, this._images, this._clips, this._addedTextures);
		ElementLocation.rechargePool();
		result.pool();
		
		this._requiresBounds = this._isAutoSize;
		this._requiresRecomposition = false;
		
		this._lastDisplay = display;
	}
	
	private function updateBounds(renderOffsetX:Float, renderOffsetY:Float):Void
	{
		writeBoundsData(this._boundsData, renderOffsetX, renderOffsetY);
		
		if (this.numDatas == 0)
		{
			this._bounds.setTo(this.x, this.y, 0.0, 0.0);
			return;
		}
		
		var pos:Int = -1;
		
		var minX:Float = MathUtils.FLOAT_MAX;
		var maxX:Float = MathUtils.FLOAT_MIN;
		var minY:Float = MathUtils.FLOAT_MAX;
		var maxY:Float = MathUtils.FLOAT_MIN;
		
		var tX:Float;
		var tY:Float;
		
		for (i in 0...this.numDatas)
		{
			for (j in 0...4)
			{
				tX = this._boundsData[++pos];
				tY = this._boundsData[++pos];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
			}
		}
		
		this._bounds.setTo(this.x + minX - renderOffsetX, this.y + minY - renderOffsetY, maxX - minX, maxY - minY);
		
		if (this._isHorizontalAutoSize) this._width = this._bounds.width;
		if (this._isVerticalAutoSize) this._height = this._bounds.height;
		
		this._requiresBounds = false;
	}
	
	/**
	   @inheritDoc
	**/
	public function writeDataBytes(byteData:ByteArray, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this._requiresRecomposition || renderData.display != this._lastDisplay) recompose(renderData.display);
		
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
		
		if (this._requiresBounds) updateBounds(renderOffsetX, renderOffsetY);
		
		finishDataBytes();
	}
	
	#if flash
	/**
	   @inheritDoc
	**/
	public function writeDataBytesMemory(maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:Vector<Float>):Void
	{
		if (this._datas == null) return;
		
		if (this._requiresRecomposition || renderData.display != this._lastDisplay) recompose(renderData.display);
		
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
		
		if (this._requiresBounds) updateBounds(renderOffsetX, renderOffsetY);
		
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
		
		if (this._requiresRecomposition || renderData.display != this._lastDisplay) recompose(renderData.display);
		
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
		
		if (this._requiresBounds) updateBounds(renderOffsetX, renderOffsetY);
		
		finishDataFloat32Array();
	}
	#end
	
	/**
	   @inheritDoc
	**/
	public function writeDataVector(vectorData:Vector<Float>, maxQuads:Int, renderOffsetX:Float, renderOffsetY:Float, renderData:RenderData, ?boundsData:#if flash Vector<Float> #else Array<Float> #end):Void
	{
		if (this._datas == null) return;
		
		if (this._requiresRecomposition || renderData.display != this._lastDisplay) recompose(renderData.display);
		
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
		
		if (this._requiresBounds) updateBounds(renderOffsetX, renderOffsetY);
		
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