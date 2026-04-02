package massive.display;

import massive.data.ImageData;
import massive.data.MassiveConstants;
import massive.util.MathUtils;
import massive.util.ReverseIterator;
import openfl.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DBufferUsage;
import openfl.display3D.Context3DProfile;
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
import lime.graphics.opengl.GL;
import lime.utils.UInt16Array;
import openfl.utils._internal.Float32Array;
#end
#if flash
import flash.system.ApplicationDomain;
import openfl.Memory;
#end

/**
 * MassiveDisplay is a starling DisplayObject
 * in order to display anything you need to add at least a layer to it, and then add data to that layer
 * @author Matse
 */
class MassiveDisplay extends DisplayObject implements IAnimatable
{
	static public function clearProgramCache():Void
	{
		for (program in programCache)
		{
			program.dispose();
		}
		programCache.clear();
	}
	
	/**
	   Call this to initialize Massive
	   if you don't, it will be called by the first MassiveDisplay instance you create
	**/
	static public function init():Void
	{
		if (_initDone) return;
		
		if (Starling.current == null)
		{
			throw new Error("MassiveDisplay.init should be called after Starling is started");
		}
		
		_isBaseline = Starling.current.profile == Context3DProfile.BASELINE ||
					  Starling.current.profile == Context3DProfile.BASELINE_CONSTRAINED ||
					  Starling.current.profile == Context3DProfile.BASELINE_EXTENDED;
		
		if (_isBaseline)
		{
			maxNumTextures = 5;
			ImageData.TEXTURE_INDEX_MULTIPLIER = 0.25;
		}
		else
		{
			#if flash
			maxNumTextures = 16; // TODO : find a way to detect max simultaneous textures on flash/air target
			#else
			maxNumTextures = GL.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
			#end
			ImageData.TEXTURE_INDEX_MULTIPLIER = 1.0;
		}
		
		_initDone = true;
	}
	
	static private var _POOL:Array<MassiveDisplay> = new Array<MassiveDisplay>();
	
	static public function fromPool(textureOrTextures:Dynamic = null, renderMode:String = null, colorMode:String = null, maxQuads:Int = MassiveConstants.MAX_QUADS):MassiveDisplay
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(textureOrTextures, renderMode, colorMode, maxQuads);
		return new MassiveDisplay(textureOrTextures, renderMode, colorMode, maxQuads);
	}
	
	/**
	   The default Juggler instance to use for all MassiveDisplay objects when their juggler property is null.
	   If left null it will default to Starling.currentJuggler.
	**/
	static public var defaultJuggler:Juggler;
	
	/**
	   Default colorMode, used when colorMode parameter is null.
	**/
	static public var defaultColorMode:String = ColorMode.EXTENDED;
	
	/**
	   Default colorOffsetMode, used when colorOffsetMode parameter is null.
	**/
	static public var defaultColorOffsetMode:String = ColorOffsetMode.NONE;
	
	/**
	   Default renderMode, used when renderMode parameter is null.
	**/
	static public var defaultRenderMode:String = #if flash RenderMode.BYTEARRAY_DOMAIN_MEMORY #else RenderMode.FLOAT32ARRAY #end;
	
	/**
	 * Default texture smoothing
	 */
	static public var defaultTextureSmoothing:String = TextureSmoothing.BILINEAR;
	
	/**
	   Maximum number of textures for a single MassiveDisplay instance.
	**/
	static public var maxNumTextures(default, null):Int;
	
	/**
	   stores non-user programs until <code>MassiveDisplay.clearProgramCache()</code> is called
	**/
	static public var programCache(default, null):Map<String, Program> = new Map<String, Program>();
	
	static private var _initDone:Bool = false;
	static private var _isBaseline:Bool;
	#if flash
	static private var _byteIndices:ByteArray;
	#else
	static private var _uint16Indices:UInt16Array;
	#end
	static private var _helperMatrix:Matrix = new Matrix();
	static private var _helperPoint:Point = new Point();
	static private var _baselineMultiTextureIndices:Vector<Float> = new Vector<Float>([0.125, 0.375, 0.625, 0.875, 1, 0, 0, 0]);
	
	/**
	   @default	0
	**/
	public var alphaOffset(get, set):Float;
	/**
	   Tells whether to animate layers
	   @default true
	**/
	public var animate:Bool = true;
	/**
	   If set to true, the MassiveDisplay instance will automatically add itself to the juggler 
	   when added to stage and remove itself when removed from stage. Default is true.
	   @default true
	**/
	public var autoHandleJuggler(get, set):Bool;
	/**
	   Tells whether exact bounds should be updated every frame.
	   Caution : this can be very expensive with tens of thousands of quads.
	   @default	false
	**/
	public var autoUpdateBounds(get, set):Bool;
	/**
	   By default a MassiveDisplay instance will use stage bounds, set this if you need different bounds.
	   @default null
	**/
	public var boundsRect:Rectangle;
	/**
	   Color as Int
	**/
	public var color(get, set):Int;
	/**
	   Tells how to handle color, see massive.display.ColorMode for possible values and details about them.
	**/
	public var colorMode(get, set):String;
	/**
	   Color offset as Int
	**/
	public var colorOffset(get, set):Int;
	/**
	   Tells how to handle color offset, see massive.display.ColorOffsetMode for possible values and details about them.
	**/
	public var colorOffsetMode(get, set):String;
	/**
	   Amount of blue tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var blue(get, set):Float;
	/**
	   @default	0
	**/
	public var blueOffset(get, set):Float;
	/**
	   Amount of green tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var green(get, set):Float;
	/**
	   @default	0
	**/
	public var greenOffset(get, set):Float;
	/**
	   Amount of red tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var red(get, set):Float;
	/**
	   @default	0
	**/
	public var redOffset(get, set):Float;
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
	 * Tells how many textures have been added
	 */
	public var numTextures(get, never):Int;
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
	public var renderOffsetX:Float = 0.0;
	/**
	   Offsets all layers by the specified amount on y axis when rendering
	   @default 0
	**/
	public var renderOffsetY:Float = 0.0;
	/**
	   Default texture
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
	
	override function set_alpha(value:Float):Float 
	{
		return this.__alpha = value;
	}
	
	private var _alphaOffset:Float = 0.0;
	private function get_alphaOffset():Float { return this._alphaOffset; }
	private function set_alphaOffset(value:Float):Float
	{
		return this._alphaOffset = value;
	}
	
	private var _autoHandleJuggler:Bool = true;
	private function get_autoHandleJuggler():Bool { return this._autoHandleJuggler; }
	private function set_autoHandleJuggler(value:Bool):Bool
	{
		return this._autoHandleJuggler = value;
	}
	
	private var _autoUpdateBounds:Bool = false;
	private function get_autoUpdateBounds():Bool { return this._autoUpdateBounds; }
	private function set_autoUpdateBounds(value:Bool):Bool
	{
		return this._autoUpdateBounds = value;
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
			case ColorMode.ALPHA :
				this._useColor = false;
				this._useDisplayColor = true;
				this._useAlpha = true;
				this._simpleColorMode = false;
			
			case ColorMode.DISPLAY :
				this._useColor = false;
				this._useDisplayColor = true;
				this._useAlpha = false;
				this._simpleColorMode = false;
			
			case ColorMode.EXTENDED :
				this._useColor = true;
				this._useDisplayColor = true;
				this._useAlpha = true;
				this._simpleColorMode = false;
			
			case ColorMode.REGULAR :
				this._useColor = true;
				this._useDisplayColor = true;
				this._useAlpha = true;
				this._simpleColorMode = true;
			
			case ColorMode.NONE :
				this._useColor = false;
				this._useDisplayColor = false;
				this._useAlpha = false;
				this._simpleColorMode = false;
		}
		
		this._renderData.useColor = this._useColor;
		this._renderData.useDisplayColor = this._useDisplayColor;
		this._renderData.useAlpha = this._useAlpha;
		this._renderData.useSimpleColor = this._simpleColorMode;
		
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
	
	private function get_colorOffset():Int
	{
		var r:Float = this._redOffset > 1.0 ? 1.0 : this._redOffset < 0.0 ? 0.0 : this._redOffset;
		var g:Float = this._greenOffset > 1.0 ? 1.0 : this._greenOffset < 0.0 ? 0.0 : this._greenOffset;
		var b:Float = this._blueOffset > 1.0 ? 1.0 : this._blueOffset < 0.0 ? 0.0 : this._blueOffset;
		return Std.int(r * 255) << 16 | Std.int(g * 255) << 8 | Std.int(b * 255);
	}
	private function set_colorOffset(value:Int):Int
	{
		this._redOffset = (Std.int(value >> 16) & 0xFF) / 255.0;
        this._greenOffset = (Std.int(value >> 8) & 0xFF) / 255.0;
        this._blueOffset = (value & 0xFF) / 255.0;
		updateColorOffset();
		return value;
	}
	
	private var _colorOffsetMode:String;
	private function get_colorOffsetMode():String { return this._colorOffsetMode; }
	private function set_colorOffsetMode(value:String):String
	{
		if (this._colorOffsetMode == value) return value;
		
		switch (value)
		{
			case ColorOffsetMode.DISPLAY :
				this._useColorOffset = false;
				this._useDisplayColorOffset = true;
			
			case ColorOffsetMode.DISPLAY_AND_OBJECT :
				this._useColorOffset = true;
				this._useDisplayColorOffset = true;
			
			case ColorOffsetMode.NONE :
				this._useColorOffset = false;
				this._useDisplayColorOffset = false;
			
			case ColorOffsetMode.OBJECT :
				this._useColorOffset = true;
				this._useDisplayColorOffset = false;
		}
		
		this._renderData.useColorOffset = this._useColorOffset;
		
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
		
		return this._colorOffsetMode = value;
	}
	
	private var _blue:Float = 1.0;
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
	
	private var _blueOffset:Float = 0.0;
	private function get_blueOffset():Float { return this._blueOffset; }
	private function set_blueOffset(value:Float):Float
	{
		if (!this.pma)
		{
			#if flash
			this._byteColorOffset.position = 8;
			this._byteColorOffset.writeFloat(value);
			#else
			this._vectorColorOffset[2] = value;
			#end
		}
		return this._blueOffset = value;
	}
	
	private var _green:Float = 1.0;
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
	
	private var _greenOffset:Float = 0.0;
	private function get_greenOffset():Float { return this._greenOffset; }
	private function set_greenOffset(value:Float):Float
	{
		if (!this.pma)
		{
			#if flash
			this._byteColorOffset.position = 4;
			this._byteColorOffset.writeFloat(value);
			#else
			
			#end
		}
		return this._greenOffset = value;
	}
	
	private var _red:Float = 1.0;
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
	
	private var _redOffset:Float = 0.0;
	private function get_redOffset():Float { return this._redOffset; }
	private function set_redOffset(value:Float):Float
	{
		if (!this.pma)
		{
			#if flash
			this._byteColorOffset.position = 0;
			this._byteColorOffset.writeFloat(value);
			#else
			this._vectorColorOffset[0] = value;
			#end
		}
		return this._redOffset = value;
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
	
	private function get_numTextures():Int { return this._textures.length; }
	
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
			case RenderMode.BYTEARRAY :
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
			case RenderMode.BYTEARRAY_DOMAIN_MEMORY :
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
			case RenderMode.FLOAT32ARRAY :
				this._useFloat32Array = true;
				this._float32Data = new Float32Array(this._bufferSize * this._elementsPerQuad);
				this._useByteArray = false;
				this._byteData = null;
				this._vectorData = null;
			#end
			
			case RenderMode.VECTOR :
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
	
	private function get_texture():Texture { return this._textures.length == 0 ? null : this._textures[0]; }
	private function set_texture(value:Texture):Texture
	{
		if (this._textures.length != 0 && this._textures[0] == value) return value;
		if (value == null)
		{
			if (this._textures.length != 0)
			{
				removeTextureAt(0);
			}
		}
		else
		{
			this._textures[0] = value;
			this._textureKeys[0] = Std.string(getTextureKey(value));
			updateTextures();
		}
		return value;
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
	
	private var _useAlpha:Bool;
	/**
	   Tells whether to have color data for tinting/colorizing, this results in bigger vertex data and more complex shader so disabling it is a good idea if you don't need it
	**/
	private var _useColor:Bool;
	
	private var _useColorOffset:Bool;
	
	private var _useDisplayColor:Bool;
	
	private var _useDisplayColorOffset:Bool;
	
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
	private var _boundsData:Vector<Float> = new Vector<Float>();
	private var _byteColor:ByteArray;
	private var _byteColorOffset:ByteArray;
	#else
	private var _boundsData:Array<Float> = new Array<Float>();
	private var _vectorColor:Vector<Float>;
	private var _vectorColorOffset:Vector<Float>;
	#end
	private var _vectorData:Vector<Float>;
	private var _byteData:ByteArray;
	#if !flash
	private var _float32Data:Float32Array;
	#end
	
	private var _isUserProgram:Bool;
	
	private var _positionVertexOffset:Int = -1;
	private var _colorVertexOffset:Int = -1;
	private var _colorOffsetVertexOffset:Int = -1;
	private var _uvVertexOffset:Int = -1;
	private var _textureVertexOffset:Int = -1;
	
	private var _positionVertexProgramIndex:Int = -1;
	private var _colorVertexProgramIndex:Int = -1;
	private var _colorOffsetVertexProgramIndex:Int = -1;
	private var _uvVertexProgramIndex:Int = -1;
	private var _textureVertexProgramIndex:Int = -1;
	
	#if flash
	private var _zeroBytes:ByteArray = new ByteArray();
	#end
	
	private var _contextBufferIndex:Int;
	private var _renderData:RenderData = new RenderData();
	
	private var _textures:Array<Texture> = new Array<Texture>();
	private var _textureKeys:Array<String> = new Array<String>();
	private var _textureProgramKey:String;
	private var _numTextures:Int = 0;
	private var _multiTexturing:Bool = false;
	private var _isMultiTexturingProgram:Bool = false;
	private var _multiTexturingConstants:Vector<Float>;
	
	private var _colorVertexConstantsIndex:Int;
	private var _colorOffsetVertexConstantsIndex:Int;
	private var _viewMatrixVertexConstantsIndex:Int;
	
	private var _multiTexturingFragmentConstantsIndex:Int = 0;
	
	/**
	   
	   @param	textureOrTextures	either a Texture or an Array<Texture>
	   @param	renderMode
	   @param	colorMode
	   @param	maxQuads
	   @param	colorOffsetMode
	**/
	public function new(textureOrTextures:Dynamic = null, renderMode:String = null, colorMode:String = null, maxQuads:Int = MassiveConstants.MAX_QUADS, colorOffsetMode:String = null)
	{
		super();
		
		if (!_initDone) init();
		
		if (_isBaseline)
		{
			this._multiTexturingConstants = _baselineMultiTextureIndices;
		}
		else
		{
			this._multiTexturingConstants = new Vector<Float>();
		}
		
		if (textureOrTextures != null)
		{
			if (Std.isOfType(textureOrTextures, Texture))
			{
				addTexture(cast textureOrTextures);
			}
			else
			{
				addTextures(cast textureOrTextures);
			}
		}
		this.maxQuads = maxQuads;
		
		if (colorMode == null) colorMode = defaultColorMode;
		if (colorMode == null) colorMode = ColorMode.EXTENDED;
		this.colorMode = colorMode;
		
		if (renderMode == null) renderMode = defaultRenderMode;
		if (renderMode == null)
		{
			#if flash
			renderMode = RenderMode.BYTEARRAY_DOMAIN_MEMORY;
			#else
			renderMode = RenderMode.FLOAT32ARRAY;
			#end
		}
		this.renderMode = renderMode;
		
		if (colorOffsetMode == null) colorOffsetMode = defaultColorOffsetMode;
		if (colorOffsetMode == null) colorOffsetMode = ColorOffsetMode.NONE;
		this.colorOffsetMode = colorOffsetMode;
		
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
		
		this._byteColorOffset = new ByteArray(16);
		this._byteColorOffset.endian = Endian.LITTLE_ENDIAN;
		this._byteColorOffset.writeFloat(this._redOffset);
		this._byteColorOffset.writeFloat(this._greenOffset);
		this._byteColorOffset.writeFloat(this._blueOffset);
		this._byteColorOffset.writeFloat(this._alphaOffset);
		#else
		this._vectorColor = new Vector<Float>(4, true, [this._red, this._green, this._blue, this.__alpha]);
		this._vectorColorOffset = new Vector<Float>(4, true, [this._redOffset, this._greenOffset, this._blueOffset, this._alphaOffset]);
		#end
		
		if (defaultJuggler == null) defaultJuggler = Starling.currentJuggler;
		if (this._juggler == null) this._juggler = defaultJuggler;
	}
	
	private function setFromPool(textureOrTextures:Dynamic, renderMode:String, colorMode:String, maxQuads:Int):MassiveDisplay
	{
		if (textureOrTextures != null)
		{
			if (Std.isOfType(textureOrTextures, Texture))
			{
				addTexture(cast textureOrTextures);
			}
			else
			{
				addTextures(cast textureOrTextures);
			}
		}
		this.maxQuads = maxQuads;
		
		if (colorMode == null) colorMode = defaultColorMode;
		if (colorMode == null) colorMode = ColorMode.EXTENDED;
		this.colorMode = colorMode;
		
		if (renderMode == null) renderMode = defaultRenderMode;
		if (renderMode == null)
		{
			#if flash
			renderMode = RenderMode.BYTEARRAY_DOMAIN_MEMORY;
			#else
			renderMode = RenderMode.FLOAT32ARRAY;
			#end
		}
		this.renderMode = renderMode;
		return this;
	}
	
	override public function dispose():Void 
	{
		disposeBuffers();
		if (!this._isUserProgram && this._isMultiTexturingProgram && this._program != null)
		{
			this._program.dispose();
		}
		this._program = null;
		removeAllLayers(true, false);
		this._textures = null;
		
		super.dispose();
	}
	
	public function clear(disposeLayers:Bool = true, poolDatas:Bool = true):Void
	{
		disposeBuffers();
		if (!this._isUserProgram && this._isMultiTexturingProgram && this._program != null)
		{
			this._program.dispose();
		}
		this._program = null;
		removeAllLayers(disposeLayers, poolDatas);
		this._textures.resize(0);
		
		this.animate = true;
		this._autoHandleJuggler = true;
		this._autoUpdateBounds = false;
		this.blendMode = BlendMode.NORMAL;
		this.boundsRect = null;
		this.alpha = this.blue = this.green = this.red = 1.0;
		this._juggler = defaultJuggler;
		this.renderOffsetX = this.renderOffsetY = 0.0;
		this._textureRepeat = false;
		this._textureSmoothing = defaultTextureSmoothing;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
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
	
	public function addTexture(texture:Texture, update:Bool = true):Void
	{
		this._textures[this._textures.length] = texture;
		this._textureKeys[this._textureKeys.length] = Std.string(getTextureKey(texture));
		if (update) updateTextures();
	}
	
	public function addTextureAt(texture:Texture, index:Int, update:Bool = true):Void
	{
		this._textures.insert(index, texture);
		this._textureKeys.insert(index, Std.string(getTextureKey(texture)));
		if (update) updateTextures();
	}
	
	public function addTextures(textures:Array<Texture>, update:Bool = true):Void
	{
		for (i in 0...textures.length)
		{
			this._textures[this._textures.length] = textures[i];
			this._textureKeys[this._textureKeys.length] = Std.string(getTextureKey(textures[i]));
		}
		if (update) updateTextures();
	}
	
	public function addTexturesAt(textures:Array<Texture>, index:Int, update:Bool = true):Void
	{
		for (i in 0...textures.length)
		{
			this._textures.insert(index + i, textures[i]);
			this._textureKeys.insert(index + i, Std.string(getTextureKey(textures[i])));
		}
		if (update) updateTextures();
	}
	
	public function clearTextures(update:Bool = true):Void
	{
		this._textures.resize(0);
		this._textureKeys.resize(0);
		if (update) updateTextures();
	}
	
	public function getTextureAt(index:Int):Texture
	{
		return this._textures[index];
	}
	
	private function getTextureKey(texture:Texture):Int
	{
		var key:Int = texture.premultipliedAlpha ? 1 : 0;
		var format = texture.format;
		if (format == Context3DTextureFormat.COMPRESSED)
		{
			key += 0 << 2;
		}
		else if (format == Context3DTextureFormat.COMPRESSED_ALPHA)
		{
			key += 1 << 2;
		}
		else
		{
			key += 2 << 2;
		}
		return key;
	}
	
	public function removeTexture(texture:Texture, update:Bool = true):Void
	{
		var index:Int = this._textures.indexOf(texture);
		if (index != -1)
		{
			this._textures.splice(index, 1);
			this._textureKeys.splice(index, 1);
			if (update) updateTextures();
		}
	}
	
	public function removeTextureAt(index:Int, update:Bool = true):Void
	{
		this._textures.splice(index, 1);
		this._textureKeys.splice(index, 1);
		if (update) updateTextures();
	}
	
	public function removeTextures(textures:Array<Texture>, update:Bool = true):Void
	{
		var index:Int;
		for (i in 0...textures.length)
		{
			index = this._textures.indexOf(textures[i]);
			if (index != -1)
			{
				this._textures.splice(index, 1);
				this._textureKeys.splice(index, 1);
			}
		}
		if (update) updateTextures();
	}
	
	public function setTextureAt(texture:Texture, index:Int, update:Bool = true):Void
	{
		this._textures[index] = texture;
		this._textureKeys[index] = Std.string(getTextureKey(texture));
		if (update) updateTextures();
	}
	
	public function setTextures(textures:Array<Texture>, update:Bool = true):Void
	{
		this._textures.resize(0);
		this._textureKeys.resize(0);
		addTextures(textures, update);
	}
	
	public function setTexturesAt(textures:Array<Texture>, index:Int, update:Bool = true):Void
	{
		for (i in 0...textures.length)
		{
			this._textures[index + i] = textures[i];
			this._textureKeys[index + i] = Std.string(getTextureKey(textures[i]));
		}
		if (update) updateTextures();
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
	
	private function updateColorOffset():Void
	{
		if (this.pma) return;
		
		#if flash
		this._byteColorOffset.position = 0;
		this._byteColorOffset.writeFloat(this._redOffset);
		this._byteColorOffset.writeFloat(this._greenOffset);
		this._byteColorOffset.writeFloat(this._blueOffset);
		#else
		this._vectorColorOffset[0] = this._redOffset;
		this._vectorColorOffset[1] = this._greenOffset;
		this._vectorColorOffset[2] = this._blueOffset;
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
		// x/y position is not optionnal
		this._positionVertexOffset = 0;
		this._elementsPerVertex = 2;
		this._positionVertexProgramIndex = 0;
		this._viewMatrixVertexConstantsIndex = 0;
		
		var constantIndex:Int = 4; // view matrix takes the first 4 registers
		var index:Int = 0;
		var offset:Int = 2;
		
		if (this._numTextures > 0) 
		{
			this._elementsPerVertex += 2;
			this._uvVertexOffset = offset;
			offset += 2;
			this._uvVertexProgramIndex = ++index;
		}
		else
		{
			this._uvVertexOffset = -1;
			this._uvVertexProgramIndex = -1;
		}
		
		if (this._useColor) 
		{
			this._colorVertexOffset = offset;
			if (this._simpleColorMode)
			{
				this._elementsPerVertex += 1;
				offset += 1;
			}
			else
			{
				this._elementsPerVertex += 4;
				offset += 4;
			}
			this._colorVertexProgramIndex = ++index;
		}
		else
		{
			this._colorVertexOffset = -1;
			this._colorVertexProgramIndex = -1;
		}
		
		if (this._useDisplayColor)
		{
			this._colorVertexConstantsIndex = constantIndex++;
		}
		else
		{
			this._colorVertexConstantsIndex = -1;
		}
		
		if (this._useColorOffset)
		{
			this._colorOffsetVertexOffset = offset;
			if (this._simpleColorMode)
			{
				this._elementsPerVertex += 1;
				offset += 1;
			}
			else
			{
				this._elementsPerVertex += 4;
				offset += 4;
			}
			this._colorOffsetVertexProgramIndex = ++index;
		}
		else
		{
			this._colorOffsetVertexOffset = -1;
			this._colorOffsetVertexProgramIndex = -1;
		}
		
		if (this._useDisplayColorOffset)
		{
			this._colorOffsetVertexConstantsIndex = constantIndex++;
		}
		else
		{
			this._colorOffsetVertexConstantsIndex = -1;
		}
		
		if (this._numTextures > 1)
		{
			this._elementsPerVertex += 1;
			this._textureVertexOffset = offset;
			offset += 1;
			this._textureVertexProgramIndex = ++index;
		}
		else
		{
			this._textureVertexOffset = -1;
			this._textureVertexProgramIndex = -1;
		}
		
		this._elementsPerQuad = MassiveConstants.VERTICES_PER_QUAD * this._elementsPerVertex;
	}
	
	private function getProgramKey():String
	{
		var key:String;
		var displayKey:Int = this._useColor ? 1 : 0;
		displayKey += (this._useDisplayColor ? 1 : 0) << 1;
		displayKey += (this._useColorOffset ? 1 : 0) << 1;
		displayKey += (this._useDisplayColorOffset ? 1 : 0) << 1;
		displayKey += (this.pma ? 1 : 0) << 1;
		key = Std.string(displayKey);
		if (this._numTextures > 0)
		{
			key += "|" + this._textureProgramKey;
		}
		return key;
	}
	
	/**
	   
	**/
	private function updateProgram():Void
	{
		if (this._isUserProgram) return;
		
		if (this._isMultiTexturingProgram)
		{
			this._isMultiTexturingProgram = false;
			if (!_isBaseline) this._multiTexturingConstants.length = 0;
		}
		
		var programKey:String = getProgramKey();
		this._program = programCache.get(programKey);
		
		if (this._program == null)
		{
			if (this._numTextures == 0)
			{
				this._program = createProgramWithoutTexture();
			}
			else if (this._numTextures == 1)
			{
				this._program = createProgramWithTexture(this._textures[0]);
			}
			else
			{
				this._program = createProgramWithMultiTexture(this._textures);
			}
			programCache.set(programKey, this._program);
		}
		
		if (this._numTextures > 1)
		{
			this._isMultiTexturingProgram = true;
			
			if (!_isBaseline)
			{
				//fc0
				this._multiTexturingConstants[0] = 0.5;
				this._multiTexturingConstants[1] = 1.5;
				this._multiTexturingConstants[2] = 2.5;
				this._multiTexturingConstants[3] = 3.5;
				if (this._numTextures > 4)
				{
					//fc1
					this._multiTexturingConstants[4] = 4.5;
					this._multiTexturingConstants[5] = 5.5;
					this._multiTexturingConstants[6] = 6.5;
					this._multiTexturingConstants[7] = 7.5;
					if (this._numTextures > 8)
					{
						//fc2
						this._multiTexturingConstants[8] = 8.5;
						this._multiTexturingConstants[9] = 9.5;
						this._multiTexturingConstants[10] = 10.5;
						this._multiTexturingConstants[11] = 11.5;
						if (this._numTextures > 12)
						{
							//fc3
							this._multiTexturingConstants[12] = 12.5;
							this._multiTexturingConstants[13] = 13.5;
							this._multiTexturingConstants[14] = 14.5;
							this._multiTexturingConstants[15] = 15.5;
						}
					}
				}
			}
		}
	}
	
	private function createProgramWithoutTexture():Program
	{
		var vertexShader:String;
		var fragmentShader:String;
		
		var register:Int = -1;
		
		var colorRegister:Int = -1;
		var colorOffsetRegister:Int = -1;
		
		vertexShader = 
			"m44 op, va" + this._positionVertexProgramIndex + ", vc" + this._viewMatrixVertexConstantsIndex + "\n";	// 4x4 matrix transform to output clip-space
		
		if (this._useColor)
		{
			colorRegister = ++register;
			vertexShader += "mul v" + colorRegister + ", va" + this._colorVertexProgramIndex + ", vc" + this._colorVertexConstantsIndex + "\n"; // multiply object color with display color, pass to fp
		}
		else if (this._useDisplayColor)
		{
			colorRegister = ++register;
			vertexShader += "mov v" + colorRegister + ", vc" + this._colorVertexConstantsIndex + "\n"; // pass display color to fp
		}
		
		if (this._useColorOffset)
		{
			colorOffsetRegister = ++register;
			if (this._useDisplayColorOffset)
			{
				vertexShader += "add v" + colorOffsetRegister + ", va" + this._colorOffsetVertexProgramIndex + ", vc" + this._colorOffsetVertexConstantsIndex + "\n"; // add object color offset with display color offset, pass to fp
			}
			else
			{
				vertexShader += "mov v" + colorOffsetRegister + ", va" + this._colorOffsetVertexProgramIndex + "\n"; // pass object color offset to fp
			}
		}
		else if (this._useDisplayColorOffset)
		{
			colorOffsetRegister = ++register;
			vertexShader += "mov v" + colorOffsetRegister + ", vc" + this._colorOffsetVertexConstantsIndex + "\n"; // pass display color offset to fp
		}
		
		if (!this._useColor && !this._useDisplayColor && !this._useColorOffset && !this._useDisplayColorOffset)
		{
			++register;
			vertexShader += "sge v" + register + ", va" + this._positionVertexProgramIndex + ", va" + this._positionVertexProgramIndex ; // this is a hack that always produces "1"
			
			fragmentShader = "mov oc, v" + register; // output color
		}
		else
		{
			if (this._useColor || this._useDisplayColor)
			{
				if (this._useColorOffset || this._useDisplayColorOffset)
				{
					fragmentShader = "add oc, v" + colorRegister + ", v" + colorOffsetRegister;
				}
				else
				{
					fragmentShader = "mov oc, v" + colorRegister;
				}
			}
			else //if (this._useColorOffset || this._useDisplayColorOffset)
			{
				fragmentShader = "mov oc, v" + colorOffsetRegister;
			}
		}
		
		return Program.fromSource(vertexShader, fragmentShader);
	}
	
	private function createProgramWithTexture(texture:Texture):Program
	{
		var vertexShader:String;
		var fragmentShader:String;
		
		var register:Int = -1;
		
		var colorRegister:Int = -1;
		var colorOffsetRegister:Int = -1;
		var uvRegister:Int = ++register;
		
		vertexShader = 
		"m44 op, va" + this._positionVertexProgramIndex + ", vc" + this._viewMatrixVertexConstantsIndex + "\n" + 	// 4x4 matrix transform to output clip-space
		"mov v" + uvRegister + ", va" + this._uvVertexProgramIndex + "\n"; 											// pass texture coordinates to fragment program
		if (this._useColor)
		{
			colorRegister = ++register;
			vertexShader += "mul v" + colorRegister + ", va" + this._colorVertexProgramIndex + ", vc" + this._colorVertexConstantsIndex + "\n";
		}
		else if (this._useDisplayColor)
		{
			colorRegister = ++register;
			vertexShader += "mov v" + colorRegister + ", vc" + this._colorVertexConstantsIndex + "\n";
		}
		
		if (this._useColorOffset)
		{
			colorOffsetRegister = ++register;
			if (this._useDisplayColorOffset)
			{
				vertexShader += "add v" + colorOffsetRegister + ", va" + this._colorOffsetVertexProgramIndex + ", vc" + this._colorOffsetVertexConstantsIndex + "\n";
			}
			else
			{
				vertexShader += "mov v" + colorOffsetRegister + ", va" + this._colorOffsetVertexProgramIndex + "\n";
			}
		}
		else if (this._useDisplayColorOffset)
		{
			colorOffsetRegister = ++register;
			vertexShader += "mov v" + colorOffsetRegister + ", vc" + this._colorOffsetVertexConstantsIndex + "\n";
		}
		
		if (!this._useColor && ! this._useDisplayColor && !this._useColorOffset && !this._useDisplayColorOffset)
		{
			fragmentShader = RenderUtil.createAGALTexOperation("oc", "v" + uvRegister, 0, texture);
		}
		else
		{
			fragmentShader = RenderUtil.createAGALTexOperation("ft0", "v" + uvRegister, 0, texture);
			if (this._useColor || this._useDisplayColor)
			{
				if (this._useColorOffset || this._useDisplayColorOffset)
				{
					fragmentShader += "mul ft0, ft0, v" + colorRegister + "\n";
				}
				else
				{
					fragmentShader += "mul oc, ft0, v" + colorRegister + "\n";
				}
			}
			
			if (this._useColorOffset || this._useDisplayColorOffset)
			{
				fragmentShader += "mul ft1, v" + colorOffsetRegister + ", ft0.wwww + \n";
				fragmentShader += "add oc, ft0, ft1 \n";
			}
		}
		
		return Program.fromSource(vertexShader, fragmentShader, _isBaseline ? 1 : 2);
	}
	
	private function createProgramWithMultiTexture(textures:Array<Texture>):Program
	{
		var numTextures:Int = textures.length;
		var fragmentShader:Array<String> = new Array<String>();
		var vertexShader:String;
		
		var register:Int = -1;
		
		var colorRegister:Int = -1;
		var colorOffsetRegister:Int = -1;
		var textureRegister:Int = -1;
		var uvRegister:Int = ++register;
		
		vertexShader = 
		"m44 op, va" + this._positionVertexProgramIndex + ", vc" + this._viewMatrixVertexConstantsIndex + "\n" + 	// 4x4 matrix transform to output clip-space
		"mov v" + uvRegister + ", va" + this._uvVertexProgramIndex + "\n"; 											// pass texture coordinates to fragment program
		if (this._useColor)
		{
			colorRegister = ++register;
			vertexShader += "mul v" + colorRegister + ", va" + this._colorVertexProgramIndex + ", vc" + this._colorVertexConstantsIndex + "\n";
		}
		else if (this._useDisplayColor)
		{
			colorRegister = ++register;
			vertexShader += "mov v" + colorRegister + ", vc" + this._colorVertexConstantsIndex + "\n";
		}
		
		if (this._useColorOffset)
		{
			colorOffsetRegister = ++register;
			if (this._useDisplayColorOffset)
			{
				vertexShader += "add v" + colorOffsetRegister + ", va" + this._colorOffsetVertexProgramIndex + ", vc" + this._colorOffsetVertexConstantsIndex + "\n";
			}
			else
			{
				vertexShader += "mov v" + colorOffsetRegister + ", va" + this._colorOffsetVertexProgramIndex + "\n";
			}
		}
		else if (this._useDisplayColorOffset)
		{
			colorOffsetRegister = ++register;
			vertexShader += "mov v" + colorOffsetRegister + ", vc" + this._colorOffsetVertexConstantsIndex + "\n";
		}
		
		textureRegister = ++register;
		vertexShader += "mov, v" + textureRegister + ", va" + this._textureVertexProgramIndex;
		
		if (_isBaseline)
		{
			fragmentShader[fragmentShader.length] = "slt ft4, v" + textureRegister + ".xxxx, fc0";
			fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft0", "v" + uvRegister, 0, textures[0]);
			fragmentShader[fragmentShader.length] = "min ft5, ft4.xxxx, ft0";
			
			fragmentShader[fragmentShader.length] = "sub ft6, fc1.xxxx, ft4";
			fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft1", "v" + uvRegister, 1, textures[1]);
			
			if (numTextures > 2)
			{
				fragmentShader[fragmentShader.length] = "min ft6.xyz, ft6.xyz, ft4.yzw";
				fragmentShader[fragmentShader.length] = "min ft0, ft6.xxxx, ft1";
				fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
				fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft2", "v" + uvRegister, 2, textures[2]);
				fragmentShader[fragmentShader.length] = "min ft0, ft6.yyyy, ft2";
				
				if (numTextures > 3)
				{
					fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
					fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft3", "v" + uvRegister, 3, textures[3]);
					fragmentShader[fragmentShader.length] = "min ft0, ft6.zzzz, ft3";
					
					if (numTextures > 4)
					{
						fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
						fragmentShader[fragmentShader.length] = RenderUtil.createAGALTexOperation("ft4", "v" + uvRegister, 4, textures[4]);
						fragmentShader[fragmentShader.length] = "min ft0, ft6.wwww, ft4";
					}
				}
			}
			else
			{
				fragmentShader[fragmentShader.length] = "min ft0, ft6.xxxx, ft1";
			}
			fragmentShader[fragmentShader.length] = "add ft5, ft5, ft0";
			
			if (!this._useColor && ! this._useDisplayColor && !this._useColorOffset && !this._useDisplayColorOffset)
			{
				fragmentShader[fragmentShader.length] = "mov oc, ft5";
			}
			else
			{
				if (this._useColor || this._useDisplayColor)
				{
					if (this._useColorOffset || this._useDisplayColorOffset)
					{
						fragmentShader[fragmentShader.length] = "mul ft5, ft5, v" + colorRegister + "\n";
					}
					else
					{
						fragmentShader[fragmentShader.length] = "mul oc, ft5, v" + colorRegister + "\n";
					}
				}
				
				if (this._useColorOffset || this._useDisplayColorOffset)
				{
					fragmentShader[fragmentShader.length] = "mul ft1, v" + colorOffsetRegister + ", ft5.wwww + \n";
					fragmentShader[fragmentShader.length] = "add oc, ft5, ft1 \n";
				}
			}
		}
		else
		{
			multiTexturing(textures, "ft0", "v" + textureRegister + ".x", 0, fragmentShader);
			
			if (!this._useColor && ! this._useDisplayColor && !this._useColorOffset && !this._useDisplayColorOffset)
			{
				fragmentShader[fragmentShader.length] = "mov oc, ft0";
			}
			else
			{
				if (this._useColor || this._useDisplayColor)
				{
					if (this._useColorOffset || this._useDisplayColorOffset)
					{
						fragmentShader[fragmentShader.length] = "mul ft0, ft0, v" + colorRegister + "\n";
					}
					else
					{
						fragmentShader[fragmentShader.length] = "mul oc, ft0, v" + colorRegister + "\n";
					}
				}
				
				if (this._useColorOffset || this._useDisplayColorOffset)
				{
					fragmentShader[fragmentShader.length] = "mul ft1, v" + colorOffsetRegister + ", ft0.wwww + \n";
					fragmentShader[fragmentShader.length] = "add oc, ft0, ft1 \n";
				}
			}
		}
		
		return Program.fromSource(vertexShader, fragmentShader.join("\n"), _isBaseline ? 1 : 2, !_isBaseline);
	}
	
	/**
	   Generates the AGAL code required to handle the specified textures (max 16)
	   
	   output is equivalent to this for 16 textures
	   
		fragmentShader.push("ifl v2.x fc1.w");
		// tex 0-7
			fragmentShader.push("ifl v2.x fc0.w");
			// tex 0-3
				fragmentShader.push("ifl v2.x fc0.y");
				// tex 0-1
					fragmentShader.push("ifl v2.x fc0.x");
						// tex 0
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 0, textures[0]));
					fragmentShader.push("els");
						// tex 1
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 1, textures[1]));
					fragmentShader.push("eif");
				fragmentShader.push("els");
				// tex 2-3
					fragmentShader.push("ifl v2.x fc0.z");
						// tex 2
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 2, textures[2]));
					fragmentShader.push("els");
						// tex 3
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 3, textures[3]));
					fragmentShader.push("eif");
				fragmentShader.push("eif");
			fragmentShader.push("els");
			// tex 4-7
				fragmentShader.push("ifl v2.x fc1.y");
				// tex 4-5
					fragmentShader.push("ifl v2.x fc1.x");
						// tex 4
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 4, textures[4]));
					fragmentShader.push("els");
						// tex 5
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 5, textures[5]));
					fragmentShader.push("eif");
				fragmentShader.push("els");
				// tex 6-7
					fragmentShader.push("ifl v2.x fc1.z");
						// tex 6
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 6, textures[6]));
					fragmentShader.push("els");
						// tex 7
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 7, textures[7]));
					fragmentShader.push("eif");
				fragmentShader.push("eif");
			fragmentShader.push("eif");
		
		fragmentShader.push("els");
		// tex 8-15
			fragmentShader.push("ifl v2.x fc2.w");
			// tex 8-11
				fragmentShader.push("ifl v2.x fc2.y");
				// tex 8-9
					fragmentShader.push("ifl v2.x fc2.x");
						// tex 8
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 8, textures[8]));
					fragmentShader.push("els");
						// tex 9
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 9, textures[9]));
					fragmentShader.push("eif");
				fragmentShader.push("els");
				// tex 2-3
					fragmentShader.push("ifl v2.x fc2.z");
						// tex 10
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 10, textures[10]));
					fragmentShader.push("els");
						// tex 11
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 11, textures[11]));
					fragmentShader.push("eif");
				fragmentShader.push("eif");
			fragmentShader.push("els");
			// tex 12-15
				fragmentShader.push("ifl v2.x fc3.y");
				// tex 12-13
					fragmentShader.push("ifl v2.x fc3.x");
						// tex 12
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 12, textures[12]));
					fragmentShader.push("els");
						// tex 13
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 13, textures[13]));
					fragmentShader.push("eif");
				fragmentShader.push("els");
				// tex 14-15
					fragmentShader.push("ifl v2.x fc3.z");
						// tex 14
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 14, textures[14]));
					fragmentShader.push("els");
						// tex 15
						fragmentShader.push(RenderUtil.createAGALTexOperation("ft5", "v0", 15, textures[15]));
					fragmentShader.push("eif");
				fragmentShader.push("eif");
			fragmentShader.push("eif");
		fragmentShader.push("eif");
	   
	   @param	textures
	   @param	textureRegister
	   @param	textureIndexSource
	   @param	constantsStartIndex
	   @param	fragmentShader
	   @return
	**/
	private function multiTexturing(textures:Array<Texture>, textureRegister:String = "ft0", textureIndexSource:String = "v2.x", constantsStartIndex:Int = 0, ?fragmentShader:Array<String>):Array<String>
	{
		if (fragmentShader == null) fragmentShader = new Array<String>();
		multiTex(fragmentShader, textures, textures.length, 0, textureRegister, textureIndexSource, constantsStartIndex);
		return fragmentShader;
	}
	
	private function multiTex(data:Array<String>, textures:Array<Texture>, numTextures:Int, textureOffset:Int, textureRegister:String, textureIndexSource:String, constantsStartIndex:Int):Void
	{
		if (numTextures <= 2)
		{
			if (numTextures == 2)
			{
				checkTexIndex(data, textureOffset, textureIndexSource, constantsStartIndex);
				data[data.length] = RenderUtil.createAGALTexOperation(textureRegister, "v0", textureOffset, textures[textureOffset]);
				data[data.length] = "els";
				data[data.length] = RenderUtil.createAGALTexOperation(textureRegister, "v0", textureOffset + 1, textures[textureOffset + 1]);
				data[data.length] = "eif";
			}
			else
			{
				data[data.length] = RenderUtil.createAGALTexOperation(textureRegister, "v0", textureOffset, textures[textureOffset]);
			}
		}
		else
		{
			var halfNumTextures:Int = Math.ceil(numTextures / 2);
			var remainingTextures:Int = numTextures - halfNumTextures;
			
			checkTexIndex(data, textureOffset + halfNumTextures - 1, textureIndexSource, constantsStartIndex);
			multiTex(data, textures, halfNumTextures, textureOffset, textureRegister, textureIndexSource, constantsStartIndex);
			data[data.length] = "els";
			multiTex(data, textures, remainingTextures, textureOffset + halfNumTextures, textureRegister, textureIndexSource, constantsStartIndex);
			data[data.length] = "eif";
		}
	}
	
	private function checkTexIndex(data:Array<String>, textureNum:Int, textureIndexSource:String, constantsStartIndex:Int):Void
	{
		var constantIndex:Int = constantsStartIndex + Math.floor(textureNum / 4);
		var constantSubIndex:Int = textureNum % 4;
		var constant:String;
		
		switch (constantSubIndex)
		{
			case 0 :
				constant = " fc" + constantIndex + ".x";
			
			case 1 :
				constant = " fc" + constantIndex + ".y";
			
			case 2 :
				constant = " fc" + constantIndex + ".z";
			
			case 3 :
				constant = " fc" + constantIndex + ".w";
			
			default :
				throw new Error("incorrect constant sub index");
		}
		
		data[data.length] = "ifl " + textureIndexSource + constant;
	}
	
	private function updateTextures():Void
	{
		this._numTextures = this._textures.length;
		this._multiTexturing = this._numTextures > 1;
		this._renderData.multiTexturing = this._multiTexturing;
		this._textureProgramKey = this._textureKeys.join("");
		
		this.pma = this._numTextures == 0 ? true : this._textures[0].premultipliedAlpha;
		this._renderData.pma = this.pma;
		
		updateElements();
		if (this._buffersCreated) updateBuffers();
		updateData();
		if (this._program != null) updateProgram();
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
	   Removes all layers, optionally disposing them and/or pooling their data
	   @param	dispose
	   @param	poolDatas
	**/
	public function removeAllLayers(dispose:Bool = true, poolDatas:Bool = true):Void
	{
		this._numLayers = this._layers.length;
		for (i in 0...this._numLayers)
		{
			this._layers[i].display = null;
			if (dispose)
			{
				this._layers[i].dispose(poolDatas);
			}
			else if (poolDatas)
			{
				this._layers[i].removeAllData(poolDatas);
			}
		}
		#if flash
		this._layers.length = 0;
		#else
		this._layers.resize(0);
		#end
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
		if (this.animate)
		{
			this._numLayers = this._layers.length;
			for (i in 0...this._numLayers)
			{
				if (this._layers[i].animate) this._layers[i].advanceTime(time);
			}
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
		
		painter.finishMeshBatch();
		
		painter.setupContextDefaults();
		painter.state.blendMode = this.__blendMode;
		painter.prepareToDraw();
		
		var alpha:Float = painter.state.alpha * this.__alpha;
		
		if (this._useDisplayColor)
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
			context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, this._colorVertexConstantsIndex, 1, this._byteColor, 0);
			#else
			if (this.pma)
			{
				this._vectorColor[0] = this._red * alpha;
				this._vectorColor[1] = this._green * alpha;
				this._vectorColor[2] = this._blue * alpha;
			}
			this._vectorColor[3] = alpha;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, this._colorVertexConstantsIndex, this._vectorColor, 1);
			#end
		}
		
		if (this._useDisplayColorOffset)
		{
			#if flash
			this._byteColorOffset.position = 0;
			this._byteColorOffset.writeFloat(this._redOffset);
			this._byteColorOffset.writeFloat(this._greenOffset);
			this._byteColorOffset.writeFloat(this._blueOffset);
			this._byteColorOffset.writeFloat(this._alphaOffset);
			context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, this._colorOffsetVertexConstantsIndex, 1, this._byteColorOffset, 0);
			#else
			if (this.pma)
			{
				this._vectorColorOffset[0] = this._redOffset * alpha;
				this._vectorColorOffset[1] = this._greenOffset * alpha;
				this._vectorColorOffset[2] = this._blueOffset * alpha;
			}
			this._vectorColorOffset[3] = alpha;
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, this._colorOffsetVertexConstantsIndex, this._vectorColorOffset, 1);
			#end
		}
		
		this._program.activate(context);
		for (i in 0...this._numTextures)
		{
			context.setTextureAt(i, this._textures[i].base);
			RenderUtil.setSamplerStateAt(i, this._textures[i].mipMapping, this._textureSmoothing, this._textureRepeat);
		}
		
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, this._viewMatrixVertexConstantsIndex, painter.state.mvpMatrix3D, true);
		
		if (this._multiTexturing)
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, this._multiTexturingFragmentConstantsIndex, this._multiTexturingConstants, -1);
		}
		
		var forceBuffer:Bool = true;
		var boundsData:#if flash Vector<Float> #else Array<Float> #end = this._autoUpdateBounds ? this._boundsData : null;
		#if flash
		if (boundsData != null) boundsData.length = 0;
		#else
		if (boundsData != null)boundsData.resize(0);
		#end
		
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
					layerDone = this._layers[layerIndex].writeDataBytesMemory(this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this._renderData, boundsData);
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
					layerDone = this._layers[layerIndex].writeDataBytes(this._byteData, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this._renderData, boundsData);
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
				layerDone = this._layers[layerIndex].writeDataFloat32Array(this._float32Data, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this._renderData, boundsData);
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
				layerDone = this._layers[layerIndex].writeDataVector(this._vectorData, this._bufferSize - this._renderData.numQuads, this.renderOffsetX, this.renderOffsetY, this._renderData, boundsData);
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
		
		this._numQuads = this._renderData.totalQuads;
		if (this._autoUpdateBounds) updateExactBounds();
		
		for (i in new ReverseIterator(this._contextBufferIndex, 0))
		{
			context.setVertexBufferAt(i, null);
		}
		
		for (i in 0...this._numTextures)
		{
			context.setTextureAt(i, null);
		}
	}
	
	private function nextBuffer(context:Context3D, forced:Bool = false):Void
	{
		var prevBuffer:VertexBuffer3D = this._vertexBuffer;
		this._vertexBufferIndex = ++this._vertexBufferIndex % this._numBuffers;
		this._vertexBuffer = this._vertexBuffers[this._vertexBufferIndex];
		
		if (forced || this._vertexBuffer != prevBuffer)
		{
			this._contextBufferIndex = -1;
			context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._positionVertexOffset, Context3DVertexBufferFormat.FLOAT_2);
			if (this._numTextures > 0)
			{
				context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._uvVertexOffset, Context3DVertexBufferFormat.FLOAT_2);
			}
			
			if (this._useColor)
			{
				if (this._simpleColorMode)
				{
					context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._colorVertexOffset, Context3DVertexBufferFormat.BYTES_4);
				}
				else
				{
					context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._colorVertexOffset, Context3DVertexBufferFormat.FLOAT_4);
				}
			}
			
			if (this._useColorOffset)
			{
				if (this._simpleColorMode)
				{
					context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._colorOffsetVertexOffset, Context3DVertexBufferFormat.BYTES_4);
				}
				else
				{
					context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._colorOffsetVertexOffset, Context3DVertexBufferFormat.FLOAT_4);
				}
			}
			
			if (this._multiTexturing)
			{
				context.setVertexBufferAt(++this._contextBufferIndex, this._vertexBuffer, this._textureVertexOffset, Context3DVertexBufferFormat.FLOAT_1);
			}
		}
	}
	
	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle 
	{
		if (targetSpace == this || targetSpace == null)
		{
			if (this.boundsRect != null)
			{
				if (out == null)
				{
					return this.boundsRect;
				}
				else
				{
					out.copyFrom(this.boundsRect);
					return out;
				}
			}
			else if (this.stage != null)
			{
				// return full stage size to support filters
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
				// return full stage size to support filters
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
	public function writeBoundsData():Void
	{
		#if flash
		this._boundsData.length = 0;
		#else
		this._boundsData.resize(0);
		#end
		this._renderData.clear();
		this._numLayers = this._layers.length;
		
		for (i in 0...this._numLayers)
		{
			if (!this._layers[i].visible) continue;
			this._layers[i].writeBoundsData(this._boundsData, this.renderOffsetX, this.renderOffsetY);
		}
		
		this._numQuads = this._renderData.totalQuads;
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
		
		var pos:Int = -1;
		
		var minX:Float = MathUtils.FLOAT_MAX;
		var maxX:Float = MathUtils.FLOAT_MIN;
		var minY:Float = MathUtils.FLOAT_MAX;
		var maxY:Float = MathUtils.FLOAT_MIN;
		
		var tX:Float;
		var tY:Float;
		
		for (i in 0...this._numQuads)
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
		
		this.boundsRect.setTo(this.__x + minX - this.renderOffsetX, this.__y + minY - this.renderOffsetY, maxX - minX, maxY - minY);
	}
	
}