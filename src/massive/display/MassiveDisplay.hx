package massive.display;

import massive.data.MassiveConstants;
import massive.util.MathUtils;
import openfl.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DBlendFactor;
import openfl.display3D.Context3DBufferUsage;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.errors.Error;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import openfl.utils.Endian;
#if !flash
import openfl.utils._internal.Float32Array;
#end
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
import massive.util.ReverseIterator;

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
	   If left null it will default to Starling.currentJuggler
	**/
	static public var defaultJuggler:Juggler;
	
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
	   How many quads/images the MassiveDisplay instance should be prepared to draw, max is 16383 per instance.
	   @default 16383
	**/
	public var bufferSize(get, set):Int;
	/**
	   Amount of blue tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var colorBlue(get, set):Float;
	/**
	   Amount of green tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var colorGreen(get, set):Float;
	/**
	   Amount of red tinting applied to the whole MassiveDisplay instance, from -1 to 10.
	   This has no effect when useColor is turned off.
	   @default 1
	**/
	public var colorRed(get, set):Float;
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
	   Tells how many VertexBuffer3D to use : if more than one, the MassiveDisplay instance will use a different one on each render.
	   @default 1
	**/
	public var numBuffers(get, set):Int;
	/**
	   Tells how many layers this MassiveDisplay instance currently has.
	**/
	public var numLayers(get, never):Int;
	/**
	   Tells how many quads were rendered on the last render call
	**/
	public var numQuads(get, never):Int;
	/**
	   The shader used by this MassiveDisplay instance
	**/
	public var program(get, set):Program;
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
	/**
	   Tells the MassiveDisplay instance to use a ByteArray to store and upload vertex data. This seems to result in faster upload on flash/air target, but at a higher cpu cost.
	**/
	public var useByteArray(get, set):Bool;
	/**
	   Tells whether to have color data for tinting/colorizing, this results in bigger vertex data and more complex shader so disabling it is a good idea if you don't need it
	   @default true
	**/
	public var useColor(get, set):Bool;
	#if !flash
	/**
	   Tells the MassiveDisplay instance to use a Float32Array to store and upload vertex data, this offers the best performance on non-flash targets
	**/
	public var useFloat32Array(get, set):Bool;
	#end
	
	override function set_alpha(value:Float):Float 
	{
		super.set_alpha(value);
		
		if (this._useByteArray)
		{
			if (this._byteColor != null)
			{
				this._byteColor.position = 12;
				this._byteColor.writeFloat(this.__alpha);
			}
		}
		else if (this._vectorColor != null)
		{
			this._vectorColor[3] = this.__alpha;
		}
		
		return this.__alpha;
	}
	
	private var _autoHandleJuggler:Bool = true;
	private function get_autoHandleJuggler():Bool { return this._autoHandleJuggler; }
	private function set_autoHandleJuggler(value:Bool):Bool
	{
		return this._autoHandleJuggler = value;
	}
	
	override function set_blendMode(value:String):String 
	{
		if (this.__blendMode == value) return value;
		this.__blendMode = value;
		updateBlendMode();
		return this.__blendMode;
	}
	
	private var _bufferSize:Int = MassiveConstants.MAX_QUADS;
	private function get_bufferSize():Int { return this._bufferSize; }
	private function set_bufferSize(value:Int):Int
	{
		if (this._bufferSize == value) return value;
		if (value > MassiveConstants.MAX_QUADS)
		{
			value = MassiveConstants.MAX_QUADS;
		}
		if (this._buffersCreated)
		{
			// TODO : better buffer resizing
			createBuffers(this._numBuffers, value);
		}
		return this._bufferSize = value;
	}
	
	private var _colorBlue:Float = 1;
	private function get_colorBlue():Float { return this._colorBlue; }
	private function set_colorBlue(value:Float):Float
	{
		if (this._useByteArray)
		{
			if (this._byteColor != null)
			{
				this._byteColor.position = 8;
				this._byteColor.writeFloat(value);
			}
		}
		else if (this._vectorColor != null)
		{
			this._vectorColor[2] = value;
		}
		return this._colorBlue = value;
	}
	
	private var _colorGreen:Float = 1;
	private function get_colorGreen():Float { return this._colorGreen; }
	private function set_colorGreen(value:Float):Float
	{
		if (this._useByteArray)
		{
			if (this._byteColor != null)
			{
				this._byteColor.position = 4;
				this._byteColor.writeFloat(value);
			}
		}
		else if (this._vectorColor != null)
		{
			this._vectorColor[1] = value;
		}
		return this._colorGreen = value;
	}
	
	private var _colorRed:Float = 1;
	private function get_colorRed():Float { return this._colorRed; }
	private function set_colorRed(value:Float):Float
	{
		if (this._useByteArray)
		{
			if (this._byteColor != null)
			{
				this._byteColor.position = 0;
				this._byteColor.writeFloat(value);
			}
		}
		else if (this._vectorColor != null)
		{
			this._vectorColor[0] = value;
		}
		return this._colorRed = value;
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
	
	private var _numBuffers:Int = 1;
	private function get_numBuffers():Int { return this._numBuffers; }
	private function set_numBuffers(value:Int):Int
	{
		if (this._numBuffers == value) return value;
		if (this._buffersCreated)
		{
			// TODO : better buffer creation/destruction
			createBuffers(value, this._bufferSize);
		}
		return this._numBuffers = value;
	}
	
	private function get_numLayers():Int { return this._layers.length; }
	
	private var _numQuads:Int = 0;
	private function get_numQuads():Int { return this._numQuads; }
	
	private var _program:Program;
	private function get_program():Program { return this._program; }
	private function set_program(value:Program):Program
	{
		if (value == null && this._program != null)
		{
			this._program.dispose();
		}
		return this._program = value;
	}
	
	private var _texture:Texture;
	private function get_texture():Texture { return this._texture; }
	private function set_texture(value:Texture):Texture
	{
		this._texture = value;
		updateBlendMode();
		updateElements();
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
	
	private var _useByteArray:Bool = false;
	private function get_useByteArray():Bool { return this._useByteArray; }
	private function set_useByteArray(value:Bool):Bool
	{
		return this._useByteArray = value;
	}
	
	private var _useColor:Bool = true;
	private function get_useColor():Bool { return this._useColor; }
	private function set_useColor(value:Bool):Bool
	{
		this._useColor = value;
		updateElements();
		return this._useColor;
	}
	
	#if !flash
	private var _useFloat32Array:Bool = true;
	private function get_useFloat32Array():Bool { return this._useFloat32Array; }
	private function set_useFloat32Array(value:Bool):Bool
	{
		return this._useFloat32Array = value;
	}
	#end
	
	#if flash
	private var _layers:Vector<MassiveLayer> = new Vector<MassiveLayer>();
	#else
	private var _layers:Array<MassiveLayer> = new Array<MassiveLayer>();
	#end
	private var _numLayers:Int;
	
	private var _buffersCreated:Bool = false;
	
	private var _indexBuffer:IndexBuffer3D;
	private var _vertexBuffer:VertexBuffer3D;
	private var _vertexBufferIndex:Int = -1;
	private var _vertexBuffers:Array<VertexBuffer3D>;
	
	private var _vectorColor:Vector<Float>;
	private var _byteColor:ByteArray;
	private var _vectorData:Vector<Float>;
	private var _byteData:ByteArray;
	#if !flash
	private var _float32Data:Float32Array;
	#end
	private var _vectorIndices:Vector<UInt>;
	private var _byteIndices:ByteArray;
	
	private var _realBlendMode:String;
	
	private var _positionOffset:Int = 0;
	private var _colorOffset:Int;
	private var _uvOffset:Int;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		super();
		this.blendMode = BlendMode.NORMAL;
		this.touchable = false;
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
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
		
		if (this._useByteArray)
		{
			if (this._byteColor == null)
			{
				this._byteColor = new ByteArray(16);
				this._byteColor.endian = Endian.LITTLE_ENDIAN;
				this._byteColor.writeFloat(this._colorRed);
				this._byteColor.writeFloat(this._colorGreen);
				this._byteColor.writeFloat(this._colorBlue);
				this._byteColor.writeFloat(this.__alpha);
			}
			
			if (this._byteData == null)
			{
				this._byteData = new ByteArray();
				this._byteData.endian = Endian.LITTLE_ENDIAN;
			}
		}
		else
		{
			if (this._vectorColor == null)
			{
				this._vectorColor = new Vector<Float>();
				this._vectorColor[0] = this._colorRed;
				this._vectorColor[1] = this._colorGreen;
				this._vectorColor[2] = this._colorBlue;
				this._vectorColor[3] = this.__alpha;
			}
			
			#if flash
			if (this._vectorData == null)
			{
				this._vectorData = new Vector<Float>();
			}
			#else
			if (this._useFloat32Array)
			{
				if (this._float32Data == null)
				{
					this._float32Data = new Float32Array(this._bufferSize * this._elementsPerQuad);
				}
			}
			else
			{
				if (this._vectorData == null)
				{
					this._vectorData = new Vector<Float>();
				}
			}
			#end
		}
		
		if (!this._buffersCreated) createBuffers(this._numBuffers, this._bufferSize);
		if (this._program == null) createProgram();
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
		createBuffers(this._numBuffers, this._bufferSize);
	}
	
	
	private function createProgram():Program
	{
		var vertexShader:String, fragmentShader:String;
		if (this._texture != null)
		{
			vertexShader = 
			"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
			"mov v0, va1      \n" ; // pass texture coordinates to fragment program
			if (this._useColor) 
			{
				vertexShader += "mul v1, va2, vc4 \n";  // multiply alpha (vc4) with color (va2), pass to fp
			}
			
			if (this._useColor)
			{
				fragmentShader = RenderUtil.createAGALTexOperation("ft0", "v0", 0, this._texture) ; // read texel color
				fragmentShader += "mul oc, ft0, v1  \n";  // multiply color with texel color
			}
			else
			{
				fragmentShader = RenderUtil.createAGALTexOperation("oc", "v0", 0, this._texture); // output color is texel color
			}
		}
		else
		{
			vertexShader = "m44 op, va0, vc0 \n" ; // 4x4 matrix transform to output clip-space
			if (this._useColor)
			{
				vertexShader += "mul v0, va1, vc4 \n";  // multiply alpha (vc4) with color (va1)
			}
			else
			{
				vertexShader += "sge v0, va0, va0" ; // this is a hack that always produces "1"
			}
			fragmentShader =
				"mov oc, v0";       // output color
		}
		
		this._program = Program.fromSource(vertexShader, fragmentShader);
		return this._program;
	}
	
	/**
	 * 
	 * @param	numBuffers
	 * @param	bufferSize
	 */
	public function createBuffers(numBuffers:Int = 2, bufferSize:Int = MassiveConstants.MAX_QUADS):Void
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
		
		this._bufferSize = bufferSize;
		this._numBuffers = numBuffers;
		this._vertexBufferIndex = -1;
		
		for (i in 0...this._numBuffers)
		{
			this._vertexBuffers[i] = context.createVertexBuffer(this._bufferSize * MassiveConstants.VERTICES_PER_QUAD, this._elementsPerVertex, Context3DBufferUsage.DYNAMIC_DRAW);
		}
		
		this._indexBuffer = context.createIndexBuffer(this._bufferSize * 6);
		
		var numVertices:Int = 0;
		if (this._useByteArray)
		{
			if (this._byteIndices == null)
			{
				this._byteIndices = new ByteArray();
				this._byteIndices.endian = Endian.LITTLE_ENDIAN;
				
				for (i in 0...MassiveConstants.MAX_QUADS)
				{
					this._byteIndices.writeShort(numVertices);
					this._byteIndices.writeShort(numVertices + 1);
					this._byteIndices.writeShort(numVertices + 2);
					
					this._byteIndices.writeShort(numVertices + 1);
					this._byteIndices.writeShort(numVertices + 2);
					this._byteIndices.writeShort(numVertices + 3);
					
					numVertices += MassiveConstants.VERTICES_PER_QUAD;
				}
			}
			
			this._indexBuffer.uploadFromByteArray(this._byteIndices, 0, 0, this._bufferSize * 6);
		}
		else
		{
			if (this._vectorIndices == null)
			{
				this._vectorIndices = new Vector<UInt>();
				
				var position:Int = -1;
				for (i in 0...MassiveConstants.MAX_QUADS)
				{
					this._vectorIndices[++position] = numVertices;
					this._vectorIndices[++position] = numVertices + 1;
					this._vectorIndices[++position] = numVertices + 2;
					
					this._vectorIndices[++position] = numVertices + 1;
					this._vectorIndices[++position] = numVertices + 2;
					this._vectorIndices[++position] = numVertices + 3;
					
					numVertices += MassiveConstants.VERTICES_PER_QUAD;
				}
			}
			
			this._indexBuffer.uploadFromVector(this._vectorIndices, 0, this._bufferSize * 6);
		}
		
		this._buffersCreated = true;
	}
	
	/**
	 * 
	 */
	public function disposeBuffers():Void
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
			this._elementsPerVertex += 4;
			this._colorOffset = this._uvOffset + 2;
		}
		else
		{
			this._colorOffset = 0;
		}
		
		this._elementsPerQuad = MassiveConstants.VERTICES_PER_QUAD * this._elementsPerVertex;
	}
	
	public function addLayer(layer:MassiveLayer):Void
	{
		layer.display = this;
		layer.useColor = this._useColor;
		this._layers[this._layers.length] = layer;
	}
	
	public function addLayerAt(layer:MassiveLayer, index:Int):Void
	{
		layer.display = this;
		layer.useColor = this._useColor;
		#if flash
		this._layers.insertAt(index, layer);
		#else
		this._layers.insert(index, layer);
		#end
	}
	
	public function getLayer(name:String):MassiveLayer
	{
		this._numLayers = this._layers.length;
		for (i in 0...this._numLayers)
		{
			if (this._layers[i].name == name) return this._layers[i];
		}
		return null;
	}
	
	public function getLayerAt(index:Int):MassiveLayer
	{
		return this._layers[index];
	}
	
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
	
	public function advanceTime(time:Float):Void
	{
		this._numLayers = this._layers.length;
		for (i in 0...this._numLayers)
		{
			if (this._layers[i].animate) this._layers[i].advanceTime(time);
		}
		
		setRequiresRedraw();
	}
	
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
		var contextBufferIndex:Int = 0;
		
		painter.finishMeshBatch();
		++painter.drawCount;
		
		painter.setupContextDefaults();
		painter.state.blendMode = this._realBlendMode;
		painter.prepareToDraw();
		
		this._program.activate(context);
		if (this._texture != null)
		{
			context.setTextureAt(0, this._texture.base);
			RenderUtil.setSamplerStateAt(0, this._texture.mipMapping, this._textureSmoothing, this._textureRepeat);
		}
		
		this._vertexBufferIndex = ++this._vertexBufferIndex % this._numBuffers;
		this._vertexBuffer = this._vertexBuffers[this._vertexBufferIndex];
		
		if (this._useByteArray)
		{
			this._byteData.length = 0;
			for (i in 0...this._numLayers)
			{
				this._numQuads += this._layers[i].writeDataBytes(this._byteData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
			}
			
			this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._numQuads * MassiveConstants.VERTICES_PER_QUAD);
		}
		else
		{
			#if flash
			for (i in 0...this._numLayers)
			{
				this._numQuads += this._layers[i].writeDataVector(this._vectorData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
			}
			
			this._vertexBuffer.uploadFromVector(this._vectorData, 0, this._numQuads * MassiveConstants.VERTICES_PER_QUAD);
			#else
			if (this._useFloat32Array)
			{
				//trace("Float32Array");
				for (i in 0...this._numLayers)
				{
					this._numQuads += this._layers[i].writeDataFloat32Array(this._float32Data, this._numQuads, this.renderOffsetX, this.renderOffsetY);
				}
				
				this._vertexBuffer.uploadFromTypedArray(this._float32Data);
			}
			else
			{
				//trace("Vector");
				for (i in 0...this._numLayers)
				{
					this._numQuads += this._layers[i].writeDataVector(this._vectorData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
				}
				
				this._vertexBuffer.uploadFromVector(this._vectorData, 0, this._numQuads * MassiveConstants.VERTICES_PER_QUAD);
			}
			#end
		}
		context.setVertexBufferAt(contextBufferIndex, this._vertexBuffer, this._positionOffset, Context3DVertexBufferFormat.FLOAT_2);
		contextBufferIndex++;
		if (this._texture != null)
		{
			context.setVertexBufferAt(contextBufferIndex, this._vertexBuffer, this._uvOffset, Context3DVertexBufferFormat.FLOAT_2);
			contextBufferIndex++;
		}
		
		if (this._useColor)
		{
			context.setVertexBufferAt(contextBufferIndex, this._vertexBuffer, this._colorOffset, Context3DVertexBufferFormat.FLOAT_4);
			contextBufferIndex++;
			
			if (this._useByteArray)
			{
				context.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, this._colorOffset, 1, this._byteColor, 0);
			}
			else
			{
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, this._colorOffset, this._vectorColor, 1);
			}
		}
		
		context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, painter.state.mvpMatrix3D, true);
		
		context.drawTriangles(this._indexBuffer, 0, this._numQuads * 2);
		
		for (i in new ReverseIterator(contextBufferIndex-1, 0))
		{
			context.setVertexBufferAt(i, null);
		}
		
		if (this._texture != null)
		{
			context.setTextureAt(0, null);
		}
	}
	
	/**
	 * call this before calling updateExactBounds if needed. This does *NOT* render anything
	 */
	public function renderData():Void
	{
		this._numQuads = 0;
		this._numLayers = this._layers.length;
		if (this.useByteArray)
		{
			this._byteData.length = 0;
			for (i in 0...this._numLayers)
			{
				this._numQuads += this._layers[i].writeDataBytes(this._byteData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
			}
		}
		else
		{
			for (i in 0...this._numLayers)
			{
				this._numQuads += this._layers[i].writeDataVector(this._vectorData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
			}
		}
	}
	
	private function updateBlendMode():Void
	{
		if (this.__blendMode == BlendMode.NORMAL)
		{
			var pma:Bool = this._texture != null ? this._texture.premultipliedAlpha : true;
			if (pma)
			{
				this._realBlendMode = Context3DBlendFactor.SOURCE_ALPHA + ", " + Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				if (!BlendMode.isRegistered(this._realBlendMode))
				{
					BlendMode.register(this._realBlendMode, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				}
			}
			else
			{
				this._realBlendMode = this.__blendMode;
			}
		}
		else
		{
			this._realBlendMode = this.__blendMode;
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
		}
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