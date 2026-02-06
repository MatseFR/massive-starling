package massive.display;

import massive.data.MassiveConstants;
import massive.util.MathUtils;
import massive.util.ReverseIterator;
import openfl.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DBufferUsage;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DTextureFormat;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.errors.Error;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
import starling.animation.IAnimatable;
import starling.animation.Juggler;
import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.errors.MissingContextError;
import starling.events.Event;
import starling.rendering.Painter;
import starling.rendering.Program;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.MatrixUtil;
import starling.utils.RenderUtil;
#if !flash
import lime.utils.UInt16Array;
import openfl.utils._internal.Float32Array;
#end
#if flash
import flash.system.ApplicationDomain;
import openfl.Memory;
#end

/**
 * MassiveDisplay is a starling DisplayObject
 * setup should be done before adding it to stage
 * in order to display anything you need to add at least a layer to it, and then add data to that layer
 * @author Matse
 */
class MassiveDisplay extends DisplayObject implements IAnimatable
{
	
	/**
	   The default Juggler instance to use for all MassiveDisplay objects when their juggler property is null.
	   If left null it will default to Starling.currentJuggler.
	**/
	static public var defaultJuggler:Juggler;
	
	/**
	   Default colorMode, used when colorMode parameter is null.
	**/
	static public var defaultColorMode:String = MassiveColorMode.EXTENDED;
	
	/**
	   Default renderMode, used when renderMode parameter is null.
	**/
	static public var defaultRenderMode:String = #if flash MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY #else MassiveRenderMode.FLOAT32ARRAY #end;
	
	/**
	   Default program used when `useColor` is `true` and `texture` is `null`
	**/
	static public var programColorNoTexture:Program;
	/**
	   Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
	**/
	static public var programColorTextureCompressed:Program;
	/**
	   Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
	**/
	static public var programColorTextureCompressedPMA:Program;
	/**
	   Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programColorTextureCompressedAlpha:Program;
	/**
	   Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programColorTextureCompressedAlphaPMA:Program;
	/**
	   Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programColorTextureDefault:Program;
	/**
	   Default program used when `useColor` is `true`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programColorTextureDefaultPMA:Program;
	/**
	   Default program used when `useColor` is `false` and `texture` is `null`
	**/
	static public var programNoColorNoTexture:Program;
	/**
	   Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
	**/
	static public var programNoColorTextureCompressed:Program;
	/**
	   Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED`
	**/
	static public var programNoColorTextureCompressedPMA:Program;
	/**
	   Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programNoColorTextureCompressedAlpha:Program;
	/**
	   Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programNoColorTextureCompressedAlphaPMA:Program;
	/**
	   Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `false` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programNoColorTextureDefault:Program;
	/**
	   Default program used when `useColor` is `false`, `texture`'s `premultipliedAlpha` is `true` and `texture`'s format is neither `Context3DTextureFormat.COMPRESSED` or `Context3DTextureFormat.COMPRESSED_ALPHA`
	**/
	static public var programNoColorTextureDefaultPMA:Program;
	
	#if flash
	static private var _byteIndices:ByteArray;
	#else
	static private var _uint16Indices:UInt16Array;
	#end
	static private var _helperMatrix:Matrix = new Matrix();
	static private var _helperPoint:Point = new Point();
	
	/**
	   If set to true, the MassiveDisplay instance will automatically add itself to the juggler 
	   when added to stage and remove itself when removed from stage. Default is true.
	   @default true
	**/
	public var autoHandleJuggler(get, set):Bool;
	/**
	   By default a MassiveDisplay instance will use stage bounds, set this if you need different bounds.
	   @default null
	**/
	public var boundsRect:Rectangle;
	/**
	   color as Int
	**/
	public var color(get, set):Int;
	/**
	   Tells how to handle color, see massive.display.MassiveColorMode for possible values and details about them.
	**/
	public var colorMode(get, set):String;
	/**
	   Amount of blue tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var blue(get, set):Float;
	/**
	   Amount of green tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var green(get, set):Float;
	/**
	   Amount of red tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var red(get, set):Float;
	/**
	   How many 32bit values per quad
	**/
	public var elementsPerQuad(get, never):Int;
	/**
	   How many 32bit values per vertex
	**/
	public var elementsPerVertex(get, never):Int;
	/**
	   The Juggler instance that this MassiveDisplay instance will use if autoHandleJuggler is true.
	   If null, MassiveDisplay.defaultJuggler will be used.
	**/
	public var juggler(get, set):Juggler;
	/**
	   The maximum number of quads that can be rendered simultaneously.
	   This determines the vertex buffer(s) size and how many are needed.
	   For best performance, one vertex buffer is created for 16383 quads.
	**/
	public var maxQuads(get, set):Int;
	/**
	   Tells how many layers this MassiveDisplay instance currently has.
	**/
	public var numLayers(get, never):Int;
	/**
	   Tells how many quads were rendered on the last render call
	**/
	public var numQuads(get, never):Int;
	/**
	   
	**/
	public var pma(default, null):Bool = true;
	/**
	   The shader used by this MassiveDisplay instance
	**/
	public var program(get, set):Program;
	/**
	   Tells how to render, see massive.display.MassiveRenderMode for possible values and details about them.
	**/
	public var renderMode(get, set):String;
	/**
	   Offsets all layers by the specified amount on x axis when rendering
	   @default 0
	**/
	public var renderOffsetX:Float = 0;
	/**
	   Offsets all layers by the specified amount on y axis when rendering
	   @default 0
	**/
	public var renderOffsetY:Float = 0;
	/**
	   The texture used by this MassiveDisplay instance, typically from a TextureAtlas.
	**/
	public var texture(get, set):Texture;
	/**
	   Tells whether texture should repeat or not
	   @default false
	**/
	public var textureRepeat(get, set):Bool;
	/**
	   Tells which texture smoothing value to use
	   @default TextureSmoothing.BILINEAR
	**/
	public var textureSmoothing(get, set):String;
	
	private var _autoHandleJuggler:Bool = true;
	private function get_autoHandleJuggler():Bool { return this._autoHandleJuggler; }
	private function set_autoHandleJuggler(value:Bool):Bool
	{
		return this._autoHandleJuggler = value;
	}
	
	private function get_color():Int 
	{
		var r:Float = this._red > 1.0 ? 1.0 : this._red < 0.0 ? 0.0 : this._red;
		var g:Float = this._green > 1.0 ? 1.0 : this._green < 0.0 ? 0.0 : this._green;
		var b:Float = this._blue > 1.0 ? 1.0 : this._blue < 0.0 ? 0.0 : this._blue;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_color(value:Int):Int
	{
		this._red = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._green = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blue = (value & 0xFF) / 255.0;
		updateColor();
		return value;
	}
	
	private var _colorMode:String;
	private function get_colorMode():String { return this._colorMode; }
	private function set_colorMode(value:String):String
	{
		if (this._colorMode == value) return value;
		
		switch (value)
		{
			case MassiveColorMode.EXTENDED :
				this._useColor = true;
				this._simpleColorMode = false;
			
			case MassiveColorMode.REGULAR :
				this._useColor = true;
				this._simpleColorMode = true;
			
			case MassiveColorMode.NONE :
				this._useColor = false;
				this._simpleColorMode = false;
		}
		
		updateElements();
		if (this._buffersCreated)
		{
			updateBuffers();
		}
		if (this._program != null)
		{
			updateProgram();
		}
		updateData();
		
		return this._colorMode = value;
	}
	
	private var _blue:Float = 1;
	private function get_blue():Float { return this._blue; }
	private function set_blue(value:Float):Float
	{
		if (!this.pma)
		{
			#if flash
			this._byteColor.position = 8;
			this._byteColor.writeFloat(value);
			#else
			this._vectorColor[2] = value;
			#end
		}
		return this._blue = value;
	}
	
	private var _green:Float = 1;
	private function get_green():Float { return this._green; }
	private function set_green(value:Float):Float
	{
		if (!this.pma)
		{
			#if flash
			this._byteColor.position = 4;
			this._byteColor.writeFloat(value);
			#else
			this._vectorColor[1] = value;
			#end
		}
		return this._green = value;
	}
	
	private var _red:Float = 1;
	private function get_red():Float { return this._red; }
	private function set_red(value:Float):Float
	{
		if (!this.pma)
		{
			#if flash
			this._byteColor.position = 0;
			this._byteColor.writeFloat(value);
			#else
			this._vectorColor[0] = value;
			#end
		}
		return this._red = value;
	}
	
	private var _elementsPerQuad:Int;
	private function get_elementsPerQuad():Int { return this._elementsPerQuad; }
	
	private var _elementsPerVertex:Int;
	private function get_elementsPerVertex():Int { return this._elementsPerVertex; }
	
	private var _juggler:Juggler;
	private function get_juggler():Juggler { return this._juggler; }
	private function set_juggler(value:Juggler):Juggler
	{
		return this._juggler = value;
	}
	
	private var _maxQuads:Int;
	private function get_maxQuads():Int { return this._maxQuads; }
	private function set_maxQuads(value:Int):Int
	{
		if (this._maxQuads == value) return value;
		var prevBufferSize:Int = this._bufferSize;
		this._bufferSize = MathUtils.minInt(value, MassiveConstants.MAX_QUADS);
		var prevNumBuffers:Int = this._numBuffers;
		this._numBuffers = Math.ceil(value / MassiveConstants.MAX_QUADS);
		if (this._bufferSize != prevBufferSize || this._numBuffers != prevNumBuffers)
		{
			if (this._buffersCreated)
			{
				updateBuffers();
			}
			updateData();
		}
		return this._maxQuads = value;
	}
	
	private function get_numLayers():Int { return this._layers.length; }
	
	private var _numQuads:Int = 0;
	private function get_numQuads():Int { return this._numQuads; }
	
	private var _program:Program;
	private function get_program():Program { return this._program; }
	private function set_program(value:Program):Program
	{
		this._isUserProgram = value != null;
		return this._program = value;
	}
	
	private var _renderMode:String;
	private function get_renderMode():String { return this._renderMode; }
	private function set_renderMode(value:String):String
	{
		if (this._renderMode == value) return value;
		
		switch (value)
		{
			case MassiveRenderMode.BYTEARRAY :
				this._useByteArray = true;
				#if flash
				this._useByteArrayDomainMemory = false;
				#end
				if (this._byteData == null)
				{
					this._byteData = new ByteArray(this._bufferSize * this._elementsPerQuad * 4);
					this._byteData.endian = Endian.LITTLE_ENDIAN;
				}
				else
				{
					this._byteData.length = this._bufferSize * this._elementsPerQuad * 4;
				}
				#if !flash
				this._useFloat32Array = false;
				this._float32Data = null;
				#end
				this._vectorData = null;
			
			#if flash
			case MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY :
				this._useByteArray = true;
				this._useByteArrayDomainMemory = true;
				if (this._byteData == null)
				{
					this._byteData = new ByteArray(this._bufferSize * this._elementsPerQuad * 4 + 1024); // for some reason if we don't add 1024 to the byte array's length it will fail on release mode
					this._byteData.endian = Endian.LITTLE_ENDIAN;
				}
				else
				{
					this._byteData.length = this._bufferSize * this._elementsPerQuad * 4 + 1024; // for some reason if we don't add 1024 to the byte array's length it will fail on release mode
				}
				this._vectorData = null;
			#end
			
			#if !flash
			case MassiveRenderMode.FLOAT32ARRAY :
				this._useFloat32Array = true;
				this._float32Data = new Float32Array(this._bufferSize * this._elementsPerQuad);
				this._useByteArray = false;
				this._byteData = null;
				this._vectorData = null;
			#end
			
			case MassiveRenderMode.VECTOR :
				this._vectorData = new Vector<Float>();
				this._useByteArray = false;
				#if flash
				this._useByteArrayDomainMemory = false;
				#end
				this._byteData = null;
				#if !flash
				this._useFloat32Array = false;
				this._float32Data = null;
				#end
		}
		
		return this._renderMode = value;
	}
	
	private var _texture:Texture;
	private function get_texture():Texture { return this._texture; }
	private function set_texture(value:Texture):Texture
	{
		if (this._texture == value) return value;
		var textureWasNull:Bool = this._texture == null;
		this._texture = value;
		this.pma = this._texture != null ? this._texture.premultipliedAlpha : true;
		updateColor();
		if (textureWasNull || this._texture == null)
		{
			updateElements();
			if (this._buffersCreated)
			{
				updateBuffers();
			}
			updateData();
		}
		if (this._program != null)
		{
			updateProgram();
		}
		return this._texture;
	}
	
	private var _textureRepeat:Bool = false;
	private function get_textureRepeat():Bool { return this._textureRepeat; }
	private function set_textureRepeat(value:Bool):Bool
	{
		return this._textureRepeat = value;
	}
	
	private var _textureSmoothing:String = TextureSmoothing.BILINEAR;
	private function get_textureSmoothing():String { return this._textureSmoothing; }
	private function set_textureSmoothing(value:String):String
	{
		return this._textureSmoothing = value;
	}
	
	override function set_touchable(value:Bool):Bool 
	{
		if (value)
		{
			throw new Error("MassiveDisplay cannot be touchable");
		}
		return super.set_touchable(value);
	}
	
	
	private var _simpleColorMode:Bool;
	/**
	   Tells whether to have color data for tinting/colorizing, this results in bigger vertex data and more complex shader so disabling it is a good idea if you don't need it
	**/
	private var _useColor:Bool;
	
	/**
	   Tells the MassiveDisplay instance to use a ByteArray to store and upload vertex data. This seems to result in faster upload on flash/air target, but at a higher cpu cost.
	**/
	private var _useByteArray:Bool;
	
	#if !flash
	/**
	   Tells the MassiveDisplay instance to use a Float32Array to store and upload vertex data, this offers the best performance on non-flash targets
	**/
	private var _useFloat32Array:Bool;
	#end
	
	#if flash
	/**
	   (flash/air target only) If useByteArray is set to true, this makes the MassiveDisplay instance to write vertex data using domain memory, which is a lot faster than calling ByteArray functions.
	   This seems to be the best setting for flash/air target.
	**/
	private var _useByteArrayDomainMemory:Bool;
	#end
	
	#if flash
	private var _layers:Vector<MassiveLayer> = new Vector<MassiveLayer>();
	#else
	private var _layers:Array<MassiveLayer> = new Array<MassiveLayer>();
	#end
	private var _numLayers:Int;
	
	private var _buffersCreated:Bool = false;
	private var _bufferSize:Int;
	private var _numBuffers:Int;
	
	private var _indexBuffer:IndexBuffer3D;
	private var _vertexBuffer:VertexBuffer3D;
	private var _vertexBufferIndex:Int;
	private var _vertexBuffers:Array<VertexBuffer3D>;
	
	#if flash
	private var _byteColor:ByteArray;
	#else
	private var _vectorColor:Vector<Float>;
	#end
	private var _vectorData:Vector<Float>;
	private var _byteData:ByteArray;
	#if !flash
	private var _float32Data:Float32Array;
	#end
	
	private var _isUserProgram:Bool;
	
	private var _positionOffset:Int = 0;
	private var _colorOffset:Int;
	private var _uvOffset:Int;
	
	#if flash
	private var _zeroBytes:ByteArray = new ByteArray();
	#end
	
	private var contextBufferIndex:Int;
	private var _renderData:RenderData = new RenderData();
	
	/**
	   
	   @param	texture
	   @param	renderMode
	   @param	colorMode
	   @param	maxQuads
	**/
	public function new(texture:Texture = null, renderMode:String = null, colorMode:String = null, maxQuads:Int = MassiveConstants.MAX_QUADS)//, numBuffers:Int = 1) 
	{
		super();
		
		this.texture = texture;
		this.maxQuads = maxQuads;
		
		if (colorMode == null) colorMode = defaultColorMode;
		if (colorMode == null) colorMode = MassiveColorMode.EXTENDED;
		this.colorMode = colorMode;
		
		if (renderMode == null) renderMode = defaultRenderMode;
		if (renderMode == null)
		{
			#if flash
			renderMode = MassiveRenderMode.BYTEARRAY_DOMAIN_MEMORY;
			#else
			renderMode = MassiveRenderMode.FLOAT32ARRAY;
			#end
		}
		this.renderMode = renderMode;
		
		this.blendMode = BlendMode.NORMAL;
		this.touchable = false;
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		
		#if flash
		this._byteColor = new ByteArray(16);
		this._byteColor.endian = Endian.LITTLE_ENDIAN;
		this._byteColor.writeFloat(this._red);
		this._byteColor.writeFloat(this._green);
		this._byteColor.writeFloat(this._blue);
		this._byteColor.writeFloat(this.__alpha);
		#else
		this._vectorColor = new Vector<Float>(4, true, [this._red, this._green, this._blue, this.__alpha]);
		#end
		
		updateElements();
		
		if (defaultJuggler == null) defaultJuggler = Starling.currentJuggler;
		if (this._juggler == null) this._juggler = defaultJuggler;
	}
	
	override public function dispose():Void 
	{
		disposeBuffers();
		if (this._program != null)
		{
			this._program.dispose();
			this._program = null;
		}
		this._texture = null;
		
		super.dispose();
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function addedToStage(evt:Event):Void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		
		Starling.current.addEventListener(Event.CONTEXT3D_CREATE, contextCreated);
		
		if (!this._buffersCreated) updateBuffers();
		if (this._program == null) updateProgram();
		if (this._autoHandleJuggler) this._juggler.add(this);
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function removedFromStage(evt:Event):Void
	{
		this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		
		Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, contextCreated);
		
		if (this._autoHandleJuggler) this._juggler.remove(this);
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function contextCreated(evt:Event):Void
	{
		updateBuffers();
	}
	
	/**
	   
	**/
	private function updateProgram():Void
	{
		if (this._isUserProgram) return;
		
		if (this._texture != null)
		{
			if (this._useColor)
			{
				if (this._texture.format == Context3DTextureFormat.COMPRESSED)
				{
					if (this._texture.premultipliedAlpha)
					{
						if (programColorTextureCompressedPMA == null)
						{
							programColorTextureCompressedPMA = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programColorTextureCompressedPMA;
					}
					else
					{
						if (programColorTextureCompressed == null)
						{
							programColorTextureCompressed = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programColorTextureCompressed;
					}
				}
				else if (this._texture.format == Context3DTextureFormat.COMPRESSED_ALPHA)
				{
					if (this._texture.premultipliedAlpha)
					{
						if (programColorTextureCompressedAlphaPMA == null)
						{
							programColorTextureCompressedAlphaPMA = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programColorTextureCompressedAlphaPMA;
					}
					else
					{
						if (programColorTextureCompressedAlpha == null)
						{
							programColorTextureCompressedAlpha = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programColorTextureCompressedAlpha;
					}
				}
				else
				{
					if (this._texture.premultipliedAlpha)
					{
						if (programColorTextureDefaultPMA == null)
						{
							programColorTextureDefaultPMA = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programColorTextureDefaultPMA;
					}
					else
					{
						if (programColorTextureDefault == null)
						{
							programColorTextureDefault = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programColorTextureDefault;
					}
				}
			}
			else
			{
				if (this._texture.format == Context3DTextureFormat.COMPRESSED)
				{
					if (this._texture.premultipliedAlpha)
					{
						if (programNoColorTextureCompressedPMA == null)
						{
							programNoColorTextureCompressedPMA = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programNoColorTextureCompressedPMA;
					}
					else
					{
						if (programNoColorTextureCompressed == null)
						{
							programNoColorTextureCompressed = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programNoColorTextureCompressed;
					}
				}
				else if (this._texture.format == Context3DTextureFormat.COMPRESSED_ALPHA)
				{
					if (this._texture.premultipliedAlpha)
					{
						if (programNoColorTextureCompressedAlphaPMA == null)
						{
							programNoColorTextureCompressedAlphaPMA = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programNoColorTextureCompressedAlphaPMA;
					}
					else
					{
						if (programNoColorTextureCompressedAlpha == null)
						{
							programNoColorTextureCompressedAlpha = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programNoColorTextureCompressedAlpha;
					}
				}
				else
				{
					if (this._texture.premultipliedAlpha)
					{
						if (programNoColorTextureDefaultPMA == null)
						{
							programNoColorTextureDefaultPMA = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programNoColorTextureDefaultPMA;
					}
					else
					{
						if (programNoColorTextureDefault == null)
						{
							programNoColorTextureDefault = createProgramWithTexture(this._useColor, this._texture);
						}
						this._program = programNoColorTextureDefault;
					}
				}
			}
		}
		else
		{
			if (this._useColor)
			{
				if (programColorNoTexture == null)
				{
					programColorNoTexture = createProgramWithoutTexture(this._useColor);
				}
				this._program = programColorNoTexture;
			}
			else
			{
				if (programNoColorNoTexture == null)
				{
					programNoColorNoTexture = createProgramWithoutTexture(this._useColor);
				}
				this._program = programNoColorNoTexture;
			}
		}
	}
	
	private function createProgramWithTexture(useColor:Bool, texture:Texture):Program
	{
		var vertexShader:String;
		var fragmentShader:String;
		
		if (useColor)
		{
			vertexShader = 
			"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
			"mov v0, va1      \n" + // pass texture coordinates to fragment program
			"mul v1, va2, vc4 \n";  // multiply alpha (vc4) with color (va2), pass to fp
			fragmentShader = RenderUtil.createAGALTexOperation("ft0", "v0", 0, texture) ; // read texel color
			fragmentShader += "mul oc, ft0, v1  \n";  // multiply color with texel color
		}
		else
		{
			vertexShader = 
			"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
			"mov v0, va1      \n" ; // pass texture coordinates to fragment program
			fragmentShader = RenderUtil.createAGALTexOperation("oc", "v0", 0, texture); // output color is texel color
		}
		
		return Program.fromSource(vertexShader, fragmentShader);
	}
	
	private function createProgramWithoutTexture(useColor:Bool):Program
	{
		var vertexShader:String;
		var fragmentShader:String;
		
		if (useColor)
		{
			vertexShader = 
			"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
			"mul v0, va1, vc4 \n";  // multiply alpha (vc4) with color (va1)
			fragmentShader =
			"mov oc, v0";       // output color
		}
		else
		{
			vertexShader = 
			"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
			"sge v0, va0, va0" ; // this is a hack that always produces "1"
			fragmentShader =
			"mov oc, v0";       // output color
		}
		
		return Program.fromSource(vertexShader, fragmentShader);
	}
	
	/**
	   
	**/
	private function updateBuffers():Void
	{
		disposeBuffers();
		
		var context:Context3D = Starling.currentContext;
		if (context == null)
		{
			throw new MissingContextError();
		}
		
		if (this._vertexBuffers == null)
		{
			this._vertexBuffers = new Array<VertexBuffer3D>();
		}
		
		this._vertexBufferIndex = -1;
		
		#if flash
		this._zeroBytes.length = this._bufferSize * MassiveConstants.VERTICES_PER_QUAD * this._elementsPerQuad;
		#end
		
		for (i in 0...this._numBuffers)
		{
			this._vertexBuffers[i] = context.createVertexBuffer(this._bufferSize * MassiveConstants.VERTICES_PER_QUAD, this._elementsPerVertex, Context3DBufferUsage.DYNAMIC_DRAW);
			#if flash
			this._vertexBuffers[i].uploadFromByteArray(this._zeroBytes, 0, 0, this._bufferSize * MassiveConstants.VERTICES_PER_QUAD);
			#end
		}
		
		this._indexBuffer = context.createIndexBuffer(this._bufferSize * 6);
		
		#if flash
		if (_byteIndices == null)
		{
			var numVertices:Int = 0;
			_byteIndices = new ByteArray();
			_byteIndices.endian = Endian.LITTLE_ENDIAN;
			
			for (i in 0...MassiveConstants.MAX_QUADS)
			{
				_byteIndices.writeShort(numVertices);
				_byteIndices.writeShort(numVertices + 1);
				_byteIndices.writeShort(numVertices + 2);
				_byteIndices.writeShort(numVertices + 1);
				_byteIndices.writeShort(numVertices + 2);
				_byteIndices.writeShort(numVertices + 3);
				
				numVertices += MassiveConstants.VERTICES_PER_QUAD;
			}
		}
		this._indexBuffer.uploadFromByteArray(_byteIndices, 0, 0, this._bufferSize * 6);
		#else
		if (_uint16Indices == null)
		{
			var numVertices:UInt = 0;
			_uint16Indices = new UInt16Array(MassiveConstants.MAX_QUADS * MassiveConstants.INDICES_PER_QUAD);
			
			var position:Int = -1;
			for (i in 0...MassiveConstants.MAX_QUADS)
			{
				_uint16Indices[++position] = numVertices;
				_uint16Indices[++position] = numVertices + 1;
				_uint16Indices[++position] = numVertices + 2;
				_uint16Indices[++position] = numVertices + 1;
				_uint16Indices[++position] = numVertices + 2;
				_uint16Indices[++position] = numVertices + 3;
				
				numVertices += MassiveConstants.VERTICES_PER_QUAD;
			}
		}
		this._indexBuffer.uploadFromTypedArray(_uint16Indices, this._bufferSize * 6);
		#end
		
		this._buffersCreated = true;
	}
	
	/**
	 * 
	 */
	private function disposeBuffers():Void
	{
		if (this._indexBuffer != null)
		{
			this._indexBuffer.dispose();
			this._indexBuffer = null;
		}
		
		if (this._vertexBuffers != null)
		{
			for (vBuffer in this._vertexBuffers)
			{
				vBuffer.dispose();
			}
			this._vertexBuffers.resize(0);
		}
		
		this._buffersCreated = false;
	}
	
	private function updateColor():Void
	{
		if (this.pma) return;
		
		#if flash
		this._byteColor.position = 0;
		this._byteColor.writeFloat(this._red);
		this._byteColor.writeFloat(this._green);
		this._byteColor.writeFloat(this._blue);
		#else
		this._vectorColor[0] = this._red;
		this._vectorColor[1] = this._green;
		this._vectorColor[2] = this._blue;
		#end
	}
	
	private function updateData():Void
	{
		if (this._useByteArray && this._byteData != null)
		{
			#if flash
			if (this._useByteArrayDomainMemory)
			{
				this._byteData.length = this._bufferSize * this._elementsPerQuad * 4 + 1024; // for some reason if we don't add 1024 to the byte array's length it will fail on release mode
			}
			else
			{
			#end
			this._byteData.length = this._bufferSize * this._elementsPerQuad * 4;
			#if flash
			}
			#end
		}
		#if !flash
		else if (this._useFloat32Array && this._float32Data != null) this._float32Data = new Float32Array(this._bufferSize * this._elementsPerQuad);
		#end
	}
	
	/**
	 * 
	 */
	private function updateElements():Void
	{
		this._elementsPerVertex = 2;
		if (this._texture != null) 
		{
			this._elementsPerVertex += 2;
			this._uvOffset = 2;
		}
		else
		{
			this._uvOffset = 0;
		}
		if (this._useColor) 
		{
			if (this._simpleColorMode)
			{
				this._elementsPerVertex += 1;
			}
			else
			{
				this._elementsPerVertex += 4;
			}
			this._colorOffset = this._uvOffset + 2;
		}
		else
		{
			this._colorOffset = 0;
		}
		
		this._elementsPerQuad = MassiveConstants.VERTICES_PER_QUAD * this._elementsPerVertex;
	}
	
	/**
	   Adds specified layer on top of other existing layers
	   @param	layer
	**/
	public function addLayer(layer:MassiveLayer):Void
	{
		layer.display = this;
		this._layers[this._layers.length] = layer;
	}
	
	/**
	   Adds specified layer at specified index
	   @param	layer
	   @param	index
	**/
	public function addLayerAt(layer:MassiveLayer, index:Int):Void
	{
		layer.display = this;
		#if flash
		this._layers.insertAt(index, layer);
		#else
		this._layers.insert(index, layer);
		#end
	}
	
	/**
	   Returns layer with specified name, or null if no layer with that name is found
	   @param	name
	   @return
	**/
	public function getLayer(name:String):MassiveLayer
	{
		this._numLayers = this._layers.length;
		for (i in 0...this._numLayers)
		{
			if (this._layers[i].name == name) return this._layers[i];
		}
		return null;
	}
	
	/**
	   Returns layer at specified index
	   @param	index
	   @return
	**/
	public function getLayerAt(index:Int):MassiveLayer
	{
		return this._layers[index];
	}
	
	/**
	   Removes specified layer, optionnally disposing it
	   @param	layer
	   @param	dispose
	   @return
	**/
	public function removeLayer(layer:MassiveLayer, dispose:Bool = false):MassiveLayer
	{
		var index:Int = this._layers.indexOf(layer);
		if (index != -1)
		{
			#if flash
			this._layers.removeAt(index);
			#else
			this._layers.splice(index, 1);
			#end
			layer.display = null;
			if (dispose) layer.dispose();
			return layer;
		}
		return null;
	}
	
	/**
	   Removes layer at specified index, optionnally disposing it
	   @param	index
	   @param	dispose
	   @return
	**/
	public function removeLayerAt(index:Int, dispose:Bool = false):MassiveLayer
	{
		var layer:MassiveLayer = this._layers[index];
		#if flash
		this._layers.removeAt(index);
		#else
		this._layers.splice(index, 1);
		#end
		layer.display = null;
		if (dispose) layer.dispose();
		return layer;
	}
	
	/**
	   Removes layer ith specified name, optionnally disposing it
	   @param	name
	   @param	dispose
	   @return
	**/
	public function removeLayerWithName(name:String, dispose:Bool = false):MassiveLayer
	{
		this._numLayers = this._layers.length;
		for (i in 0...this._numLayers)
		{
			if (this._layers[i].name == name)
			{
				return removeLayerAt(i, dispose);
			}
		}
		return null;
	}
	
	/**
	   advances time for all animated layers
	   @param	time
	**/
	public function advanceTime(time:Float):Void
	{
		this._numLayers = this._layers.length;
		for (i in 0...this._numLayers)
		{
			if (this._layers[i].animate) this._layers[i].advanceTime(time);
		}
		
		setRequiresRedraw();
	}
	
	/**
	   
	   @param	painter
	**/
	override public function render(painter:Painter):Void 
	{
		this._numLayers = this._layers.length;
		if (this._numLayers == 0) return;
		
		painter.excludeFromCache(this);
		
		var context:Context3D = Starling.currentContext;
		if (context == null)
		{
			throw new MissingContextError();
		}
		
		this._numQuads = 0;
		
		painter.finishMeshBatch();
		
		painter.setupContextDefaults();
		painter.state.blendMode = this.__blendMode;
		painter.prepareToDraw();
		
		var alpha:Float = painter.state.alpha * this.__alpha;
		if (this._useColor)
		{
			#if flash
			if (this.pma)
			{
				this._byteColor.position = 0;
				this._byteColor.writeFloat(this._red * alpha);
				this._byteColor.writeFloat(this._green * alpha);
				this._byteColor.writeFloat(this._blue * alpha);
				this._byteColor.writeFloat(alpha);
			}
			else
			{
				this._byteColor.position = 12;
				this._byteColor.writeFloat(alpha);
			}
			context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, this._colorOffset, 1, this._byteColor, 0);
			#else
			if (this.pma)
			{
				this._vectorColor[0] = this._red * alpha;
				this._vectorColor[1] = this._green * alpha;
				this._vectorColor[2] = this._blue * alpha;
			}
			this._vectorColor[3] = alpha;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, this._colorOffset, this._vectorColor, 1);
			#end
		}
		
		this._program.activate(context);
		if (this._texture != null)
		{
			context.setTextureAt(0, this._texture.base);
			RenderUtil.setSamplerStateAt(0, this._texture.mipMapping, this._textureSmoothing, this._textureRepeat);
		}
		
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, painter.state.mvpMatrix3D, true);
		
		var forceBuffer:Bool = true;
		
		var layerDone:Bool;
		var layerIndex:Int = 0;
		this._renderData.clear();
		
		if (this._useByteArray)
		{
			#if flash
			if (this._useByteArrayDomainMemory)
			{
				var prevByteArray:ByteArray = ApplicationDomain.currentDomain.domainMemory;
				Memory.select(this._byteData);
				while (layerIndex < this._numLayers)
				{
					if (!this._layers[layerIndex].visible) continue;
					layerDone = this._layers[layerIndex].writeDataBytesMemory(this._byteData, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode, this._renderData);
					if (this._renderData.numQuads == this._bufferSize)
					{
						nextBuffer(context, forceBuffer);
						forceBuffer = false;
						this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
						context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
						this._renderData.render();
						++painter.drawCount;
					}
					if (layerDone) ++layerIndex;
				}
				if (this._renderData.numQuads != 0)
				{
					nextBuffer(context, forceBuffer);
					forceBuffer = false;
					this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
					context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
					this._renderData.render();
					++painter.drawCount;
				}
				Memory.select(prevByteArray);
			}
			else
			{
			#end
				this._byteData.position = 0;
				while (layerIndex < this._numLayers)
				{
					if (!this._layers[layerIndex].visible) continue;
					layerDone = this._layers[layerIndex].writeDataBytes(this._byteData, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode, this._renderData);
					if (this._renderData.numQuads == this._bufferSize)
					{
						nextBuffer(context, forceBuffer);
						forceBuffer = false;
						this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
						context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
						this._renderData.render();
						++painter.drawCount;
					}
					if (layerDone) ++layerIndex;
				}
				if (this._renderData.numQuads != 0)
				{
					nextBuffer(context, forceBuffer);
					forceBuffer = false;
					this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
					context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
					this._renderData.render();
					++painter.drawCount;
				}
			#if flash
			}
			#end
		}
		#if !flash
		else if (this._useFloat32Array)
		{
			while (layerIndex < this._numLayers)
			{
				if (!this._layers[layerIndex].visible) continue;
				layerDone = this._layers[layerIndex].writeDataFloat32Array(this._float32Data, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode, this._renderData);
				if (this._renderData.numQuads == this._bufferSize)
				{
					nextBuffer(context, forceBuffer);
					forceBuffer = false;
					this._vertexBuffer.uploadFromTypedArray(this._float32Data, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD * 4); // uploadFromTypedArray's byteLength param is currently not used
					context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
					this._renderData.render();
					++painter.drawCount;
				}
				if (layerDone) ++layerIndex;
			}
			if (this._renderData.numQuads != 0)
			{
				nextBuffer(context, forceBuffer);
				forceBuffer = false;
				this._vertexBuffer.uploadFromTypedArray(this._float32Data, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD * 4); // uploadFromTypedArray's byteLength param is currently not used
				context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
				this._renderData.render();
				++painter.drawCount;
				
			}
		}
		#end
		else
		{
			while (layerIndex < this._numLayers)
			{
				if (!this._layers[layerIndex].visible) continue;
				layerDone = this._layers[layerIndex].writeDataVector(this._vectorData, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode, this._renderData);
				if (this._renderData.numQuads == this._bufferSize)
				{
					nextBuffer(context, forceBuffer);
					forceBuffer = false;
					this._vertexBuffer.uploadFromVector(this._vectorData, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
					context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
					this._renderData.render();
					++painter.drawCount;
				}
				if (layerDone) ++layerIndex;
			}
			if (this._renderData.numQuads != 0)
			{
				nextBuffer(context, forceBuffer);
				forceBuffer = false;
				this._vertexBuffer.uploadFromVector(this._vectorData, 0, this._renderData.numQuads * MassiveConstants.VERTICES_PER_QUAD);
				context.drawTriangles(this._indexBuffer, 0, this._renderData.numQuads * 2);
				this._renderData.render();
				++painter.drawCount;
			}
		}
		
		for (i in new ReverseIterator(this.contextBufferIndex, 0))
		{
			context.setVertexBufferAt(i, null);
		}
		
		if (this._texture != null)
		{
			context.setTextureAt(0, null);
		}
	}
	
	private function nextBuffer(context:Context3D, forced:Bool = false):Void
	{
		var prevBuffer:VertexBuffer3D = this._vertexBuffer;
		this._vertexBufferIndex = ++this._vertexBufferIndex % this._numBuffers;
		this._vertexBuffer = this._vertexBuffers[this._vertexBufferIndex];
		
		if (forced || this._vertexBuffer != prevBuffer)
		{
			this.contextBufferIndex = -1;
			context.setVertexBufferAt(++this.contextBufferIndex, this._vertexBuffer, this._positionOffset, Context3DVertexBufferFormat.FLOAT_2);
			if (this._texture != null)
			{
				context.setVertexBufferAt(++this.contextBufferIndex, this._vertexBuffer, this._uvOffset, Context3DVertexBufferFormat.FLOAT_2);
			}
			
			if (this._useColor)
			{
				if (this._simpleColorMode)
				{
					context.setVertexBufferAt(++this.contextBufferIndex, this._vertexBuffer, this._colorOffset, Context3DVertexBufferFormat.BYTES_4);
				}
				else
				{
					context.setVertexBufferAt(++this.contextBufferIndex, this._vertexBuffer, this._colorOffset, Context3DVertexBufferFormat.FLOAT_4);
				}
			}
		}
	}
	
	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle 
	{
		if (targetSpace == this || targetSpace == null)
		{
			if (this.boundsRect != null)
			{
				return this.boundsRect;
			}
			else if (this.stage != null)
			{
				// return full stage size to support filters ... may be expensive, but we have no other options, do we?
				if (out == null) out = new Rectangle();
				out.setTo(0, 0, this.stage.stageWidth, this.stage.stageHeight);
				return out;
			}
			else
			{
				getTransformationMatrix(targetSpace, _helperMatrix);
				MatrixUtil.transformCoords(_helperMatrix, 0, 0, _helperPoint);
				if (out == null) out = new Rectangle();
				out.setTo(_helperPoint.x, _helperPoint.y, 0, 0);
				return out;
			}
		}
		else if (targetSpace != null)
		{
			if (out == null) out = new Rectangle();
			
			if (this.boundsRect != null)
			{
				getTransformationMatrix(targetSpace, _helperMatrix);
				MatrixUtil.transformCoords(_helperMatrix, this.boundsRect.x, this.boundsRect.y, _helperPoint);
				out.x = _helperPoint.x;
				out.y = _helperPoint.y;
				MatrixUtil.transformCoords(_helperMatrix, this.boundsRect.width, this.boundsRect.height, _helperPoint);
				out.width = _helperPoint.x;
				out.height = _helperPoint.y;
			}
			else if (this.stage != null)
			{
				// return full stage size to support filters ... may be pretty expensive
				out.setTo(0, 0, stage.stageWidth, stage.stageHeight);
			}
			else
			{
				getTransformationMatrix(targetSpace, _helperMatrix);
				MatrixUtil.transformCoords(_helperMatrix, 0, 0, _helperPoint);
				out.setTo(_helperPoint.x, _helperPoint.y, 0, 0);
			}
			
			return out;
		}
		else
		{
			return out == null ? new Rectangle() : out;
		}
	}
	
	/**
	 * call this before calling updateExactBounds if needed. This does *NOT* render anything
	 */
	public function renderData():Void
	{
		this._numQuads = 0;
		this._numLayers = this._layers.length;
		if (this._useByteArray)
		{
			#if flash
			if (this._useByteArrayDomainMemory)
			{
				var prevByteArray:ByteArray = ApplicationDomain.currentDomain.domainMemory;
				Memory.select(this._byteData);
				//for (i in 0...this._numLayers)
				//{
					//if (!this._layers[i].visible) continue;
					//this._numQuads += this._layers[i].writeDataBytesMemory(this._byteData, this._numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode);
				//}
				Memory.select(prevByteArray);
			}
			else
			{
			#end
				this._byteData.position = 0;
				for (i in 0...this._numLayers)
				{
					if (!this._layers[i].visible) continue;
					//this._numQuads += this._layers[i].writeDataBytes(this._byteData, this._numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode);
				}
			#if flash
			}
			#end
		}
		#if !flash
		else if (this._useFloat32Array)
		{
			for (i in 0...this._numLayers)
			{
				if (!this._layers[i].visible) continue;
				//this._numQuads += this._layers[i].writeDataFloat32Array(this._float32Data, this._numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode);
			}
		}
		#end
		else
		{
			for (i in 0...this._numLayers)
			{
				if (!this._layers[i].visible) continue;
				//this._numQuads += this._layers[i].writeDataVector(this._vectorData, this._numQuads, this.renderOffsetX, this.renderOffsetY, this.pma, this._useColor, this._simpleColorMode);
			}
		}
	}
	
	/**
	   Calculates exact bounds for this MassiveDisplay instance and stores it in boundsRect
	   Caution : this can be really expensive !
	**/
	public function updateExactBounds():Void
	{
		if (this.boundsRect == null) this.boundsRect = new Rectangle();
		
		if (this._numQuads == 0)
		{
			this.boundsRect.x = this.__x;
			this.boundsRect.y = this.__y;
			this.boundsRect.width = 0;
			this.boundsRect.height = 0;
			return;
		}
		
		var quadPos:Int;
		var pos:Int;
		
		var minX:Float = MathUtils.FLOAT_MAX;
		var maxX:Float = MathUtils.FLOAT_MIN;
		var minY:Float = MathUtils.FLOAT_MAX;
		var maxY:Float = MathUtils.FLOAT_MIN;
		
		var tX:Float;
		var tY:Float;
		
		if (this._useByteArray)
		{
			#if flash
			if (this._useByteArrayDomainMemory)
			{
				var prevByteArray:ByteArray = ApplicationDomain.currentDomain.domainMemory;
				Memory.select(this._byteData);
				for (i in 0...this._numQuads)
				{
					quadPos = i * this._elementsPerQuad << 2;
					
					pos = quadPos;
					tX = Memory.getFloat(pos);
					tY = Memory.getFloat(pos + 4);
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
					
					pos += this._elementsPerVertex << 2;
					tX = Memory.getFloat(pos);
					tY = Memory.getFloat(pos + 4);
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
					
					pos += this._elementsPerVertex << 2;
					tX = Memory.getFloat(pos);
					tY = Memory.getFloat(pos + 4);
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
					
					pos += this._elementsPerVertex << 2;
					tX = Memory.getFloat(pos);
					tY = Memory.getFloat(pos + 4);
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
				}
				Memory.select(prevByteArray);
			}
			else
			{
			#end
				for (i in 0...this._numQuads)
				{
					quadPos = i * this._elementsPerQuad << 2;
					
					pos = quadPos;
					this._byteData.position = pos;
					tX = this._byteData.readFloat();
					tY = this._byteData.readFloat();
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
					
					pos += this._elementsPerVertex << 2;
					this._byteData.position = pos;
					tX = this._byteData.readFloat();
					tY = this._byteData.readFloat();
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
					
					pos += this._elementsPerVertex << 2;
					this._byteData.position = pos;
					tX = this._byteData.readFloat();
					tY = this._byteData.readFloat();
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
					
					pos += this._elementsPerVertex << 2;
					this._byteData.position = pos;
					tX = this._byteData.readFloat();
					tY = this._byteData.readFloat();
					
					if (minX > tX) minX = tX;
					if (maxX < tX) maxX = tX;
					if (minY > tY) minY = tY;
					if (maxY < tY) maxY = tY;
				}
			#if flash
			}
			#end
		}
		#if !flash
		else if (this._useFloat32Array)
		{
			for (i in 0...this._numQuads)
			{
				quadPos = i * this._elementsPerQuad;
				
				pos = quadPos;
				tX = this._float32Data[pos];
				tY = this._float32Data[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
				
				pos += this._elementsPerVertex;
				tX = this._float32Data[pos];
				tY = this._float32Data[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
				
				tX = this._float32Data[pos];
				tY = this._float32Data[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
				
				tX = this._float32Data[pos];
				tY = this._float32Data[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
			}
		}
		#end
		else
		{
			for (i in 0...this._numQuads)
			{
				quadPos = i * this._elementsPerQuad;
				
				pos = quadPos;
				tX = this._vectorData[pos];
				tY = this._vectorData[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
				
				pos += this._elementsPerVertex;
				tX = this._vectorData[pos];
				tY = this._vectorData[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
				
				pos += this._elementsPerVertex;
				tX = this._vectorData[pos];
				tY = this._vectorData[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
				
				pos += this._elementsPerVertex;
				tX = this._vectorData[pos];
				tY = this._vectorData[pos + 1];
				
				if (minX > tX) minX = tX;
				if (maxX < tX) maxX = tX;
				if (minY > tY) minY = tY;
				if (maxY < tY) maxY = tY;
			}
		}
		
		this.boundsRect.x = this.__x + minX - this.renderOffsetX;
		this.boundsRect.y = this.__y + minY - this.renderOffsetY;
		this.boundsRect.width = maxX - minX;
		this.boundsRect.height = maxY - minY;
	}
	
}