package massive.display;

import massive.data.MassiveConstants;
import openfl.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DBlendFactor;
import openfl.display3D.Context3DBufferUsage;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
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
import massive.util.ReverseIterator;

/**
 * ...
 * @author Matse
 */
class MassiveDisplay extends DisplayObject implements IAnimatable
{
	/**
	 * The default Juggler instance to use for all MassiveDisplay objects when their juggler property is null.
	 * If left null it will default to Starling.currentJuggler
	 */
	static public var defaultJuggler:Juggler;
	
	static private var _helperMatrix:Matrix = new Matrix();
	static private var _helperPoint:Point = new Point();
	
	/**
	 * If set to true, the MassiveDisplay instancce will automatically add itself to the juggler 
	 * when added to stage and remove itself when removed from stage. Default is true.
	 * @default true
	 */
	public var autoHandleJuggler(get, set):Bool;
	private var _autoHandleJuggler:Bool = true;
	private function get_autoHandleJuggler():Bool { return this._autoHandleJuggler; }
	private function set_autoHandleJuggler(value:Bool):Bool
	{
		return this._autoHandleJuggler = value;
	}
	
	/**
	 * The Juggler instance that this MassiveDisplay object will use if autoHandleJuggler is true.
	 * If null, MassiveDisplay.defaultJuggler will be used.
	 */
	public var juggler(get, set):Juggler;
	private var _juggler:Juggler;
	private function get_juggler():Juggler { return this._juggler; }
	private function set_juggler(value:Juggler):Juggler
	{
		return this._juggler = value;
	}
	
	/**
	 * @default 16383
	 */
	public var bufferSize(get, set):Int;
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
	
	/**
	 * @default 2
	 */
	public var numBuffers(get, set):Int;
	private var _numBuffers:Int = 3;
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
	
	override function set_blendMode(value:String):String 
	{
		if (this.__blendMode == value) return value;
		this.__blendMode = value;
		updateBlendMode();
		return this.__blendMode;
	}
	
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
	
	public var colorBlue(get, set):Float;
	private var _colorBlue:Float = 1;
	private function get_colorBlue():Float { return this._colorBlue; }
	private function set_colorBlue(value:Float):Float
	{
		if (_useByteArray)
		{
			if (_byteColor != null)
			{
				_byteColor.position = 8;
				_byteColor.writeFloat(value);
			}
		}
		else if (_vectorColor != null)
		{
			_vectorColor[2] = value;
		}
		return this._colorBlue = value;
	}
	
	public var colorGreen(get, set):Float;
	private var _colorGreen:Float = 1;
	private function get_colorGreen():Float { return this._colorGreen; }
	private function set_colorGreen(value:Float):Float
	{
		if (_useByteArray)
		{
			if (_byteColor != null)
			{
				_byteColor.position = 4;
				_byteColor.writeFloat(value);
			}
		}
		else if (_vectorColor != null)
		{
			_vectorColor[1] = value;
		}
		return this._colorGreen = value;
	}
	
	public var colorRed(get, set):Float;
	private var _colorRed:Float = 1;
	private function get_colorRed():Float { return this._colorRed; }
	private function set_colorRed(value:Float):Float
	{
		if (_useByteArray)
		{
			if (_byteColor != null)
			{
				_byteColor.position = 0;
				_byteColor.writeFloat(value);
			}
		}
		else if (_vectorColor != null)
		{
			_vectorColor[0] = value;
		}
		return this._colorRed = value;
	}
	
	public var elementsPerQuad(get, never):Int;
	private var _elementsPerQuad:Int;
	private function get_elementsPerQuad():Int { return this._elementsPerQuad; }
	
	public var elementsPerVertex(get, never):Int;
	private var _elementsPerVertex:Int;
	private function get_elementsPerVertex():Int { return this._elementsPerVertex; }
	
	public var numQuads(get, never):Int;
	private var _numQuads:Int = 0;
	private function get_numQuads():Int { return this._numQuads; }
	
	public var renderOffsetX:Float = 0;
	public var renderOffsetY:Float = 0;
	
	public var texture(get, set):Texture;
	private var _texture:Texture;
	private function get_texture():Texture { return this._texture; }
	private function set_texture(value:Texture):Texture
	{
		if (value != null)
		{
			this._premultipliedAlpha = value.premultipliedAlpha;
		}
		this._texture = value;
		updateBlendMode();
		updateElements();
		return this._texture;
	}
	
	public var textureRepeat(get, set):Bool;
	private var _textureRepeat:Bool = false;
	private function get_textureRepeat():Bool { return this._textureRepeat; }
	private function set_textureRepeat(value:Bool):Bool
	{
		return this._textureRepeat = value;
	}
	
	public var textureSmoothing(get, set):String;
	private var _textureSmoothing:String = TextureSmoothing.BILINEAR;
	private function get_textureSmoothing():String { return this._textureSmoothing; }
	private function set_textureSmoothing(value:String):String
	{
		return this._textureSmoothing = value;
	}
	
	public var useByteArray(get, set):Bool;
	private var _useByteArray:Bool = true;
	private function get_useByteArray():Bool { return this._useByteArray; }
	private function set_useByteArray(value:Bool):Bool
	{
		return this._useByteArray = value;
	}
	
	public var useColor(get, set):Bool;
	private var _useColor:Bool = true;
	private function get_useColor():Bool { return this._useColor; }
	private function set_useColor(value:Bool):Bool
	{
		this._useColor = value;
		updateElements();
		return this._useColor;
	}
	
	private var _layers:Array<MassiveLayer> = new Array<MassiveLayer>();
	
	private var _buffersCreated:Bool = false;
	
	private var _indexBuffer:IndexBuffer3D;
	private var _vertexBuffer:VertexBuffer3D;
	private var _vertexBufferIndex:Int = -1;
	private var _vertexBuffers:Array<VertexBuffer3D>;
	
	private var _vectorColor:Vector<Float>;
	private var _byteColor:ByteArray;
	private var _vectorData:Vector<Float>;
	private var _byteData:ByteArray;
	private var _vectorIndices:Vector<UInt>;
	private var _byteIndices:ByteArray;
	
	private var _premultipliedAlpha:Bool;
	
	private var _program:Program;
	
	private var _positionOffset:Int = 0;
	private var _colorOffset:Int;
	private var _uvOffset:Int;
	
	//private var _isInitialized:Bool = false;
	private var _zeroBytes:ByteArray;
	
	private var _boundsRect:Rectangle = new Rectangle();
	
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
		if (_juggler == null) _juggler = defaultJuggler;
		
		_zeroBytes = new ByteArray();
	}
	
	override public function dispose():Void 
	{
		disposeBuffers();
		
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
		
		this.addEventListener(Event.CONTEXT3D_CREATE, contextCreated);
		
		if (_useByteArray)
		{
			if (_byteColor == null)
			{
				_byteColor = new ByteArray(16);
				_byteColor.endian = Endian.LITTLE_ENDIAN;
				_byteColor.writeFloat(this._colorRed);
				_byteColor.writeFloat(this._colorGreen);
				_byteColor.writeFloat(this._colorBlue);
				_byteColor.writeFloat(this.__alpha);
			}
			
			if (_byteData == null)
			{
				_byteData = new ByteArray();
				_byteData.endian = Endian.LITTLE_ENDIAN;
			}
		}
		else
		{
			if (_vectorColor == null)
			{
				_vectorColor = new Vector<Float>();
				_vectorColor[0] = this._colorRed;
				_vectorColor[1] = this._colorGreen;
				_vectorColor[2] = this._colorBlue;
				_vectorColor[3] = this.__alpha;
			}
			
			if (_vectorData == null)
			{
				_vectorData = new Vector<Float>();
			}
		}
		
		if (!_buffersCreated) createBuffers(_numBuffers, _bufferSize);
		if (_program == null) createProgram();
		if (_autoHandleJuggler) _juggler.add(this);
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function removedFromStage(evt:Event):Void
	{
		this.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		
		this.removeEventListener(Event.CONTEXT3D_CREATE, contextCreated);
		
		if (_autoHandleJuggler) _juggler.remove(this);
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function contextCreated(evt:Event):Void
	{
		createBuffers(_numBuffers, _bufferSize);
	}
	
	
	private function createProgram():Program
	{
		var vertexShader:String, fragmentShader:String;
		if (this._texture != null)
		{
			vertexShader = 
			"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clip-space
			"mov v0, va1      \n" ; // pass texture coordinates to fragment program
			if (_useColor) 
			{
				vertexShader += "mul v1, va2, vc4 \n";  // multiply alpha (vc4) with color (va2), pass to fp
			}
			
			if (_useColor)
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
			if (_useColor)
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
		
		_program = Program.fromSource(vertexShader, fragmentShader);
		return _program;
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
		
		if (_vertexBuffers == null)
		{
			_vertexBuffers = new Array<VertexBuffer3D>();
		}
		
		_bufferSize = bufferSize;
		_numBuffers = numBuffers;
		_vertexBufferIndex = -1;
		
		_zeroBytes.length = _bufferSize * MassiveConstants.VERTICES_PER_QUAD * _elementsPerQuad;
		
		for (i in 0..._numBuffers)
		{
			_vertexBuffers[i] = context.createVertexBuffer(_bufferSize * MassiveConstants.VERTICES_PER_QUAD,
				_elementsPerVertex, Context3DBufferUsage.DYNAMIC_DRAW);
			_vertexBuffers[i].uploadFromByteArray(_zeroBytes, 0, 0, _bufferSize * MassiveConstants.VERTICES_PER_QUAD);
		}
		
		_indexBuffer = context.createIndexBuffer(_bufferSize * 6);
		
		var numVertices:Int = 0;
		if (_useByteArray)
		{
			if (_byteIndices == null)
			{
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
			
			_indexBuffer.uploadFromByteArray(_byteIndices, 0, 0, _bufferSize * 6);
		}
		else
		{
			if (_vectorIndices == null)
			{
				_vectorIndices = new Vector<UInt>();
				
				var position:Int = -1;
				for (i in 0...MassiveConstants.MAX_QUADS)
				{
					_vectorIndices[++position] = numVertices;
					_vectorIndices[++position] = numVertices + 1;
					_vectorIndices[++position] = numVertices + 2;
					
					_vectorIndices[++position] = numVertices + 1;
					_vectorIndices[++position] = numVertices + 2;
					_vectorIndices[++position] = numVertices + 3;
					
					numVertices += MassiveConstants.VERTICES_PER_QUAD;
				}
			}
			
			_indexBuffer.uploadFromVector(_vectorIndices, 0, _bufferSize * 6);
		}
		
		_buffersCreated = true;
	}
	
	/**
	 * 
	 */
	public function disposeBuffers():Void
	{
		if (_indexBuffer != null)
		{
			_indexBuffer.dispose();
			_indexBuffer = null;
		}
		
		if (_vertexBuffers != null)
		{
			for (vBuffer in _vertexBuffers)
			{
				vBuffer.dispose();
			}
			_vertexBuffers.resize(0);
		}
		
		_buffersCreated = false;
	}
	
	/**
	 * 
	 */
	private function updateElements():Void
	{
		_elementsPerVertex = 2;
		if (_texture != null) 
		{
			_elementsPerVertex += 2;
			_uvOffset = 2;
		}
		else
		{
			_uvOffset = 0;
		}
		if (_useColor) 
		{
			_elementsPerVertex += 4;
			_colorOffset = _uvOffset + 2;
		}
		else
		{
			_colorOffset = 0;
		}
		
		_elementsPerQuad = MassiveConstants.VERTICES_PER_QUAD * _elementsPerVertex;
	}
	
	public function addLayer(layer:MassiveLayer):Void
	{
		layer.display = this;
		layer.useColor = this._useColor;
		this._layers.push(layer);
	}
	
	public function getLayer(name:String):MassiveLayer
	{
		for (layer in _layers)
		{
			if (layer.name == name) return layer;
		}
		return null;
	}
	
	public function getLayerAt(index:Int):MassiveLayer
	{
		return this._layers[index];
	}
	
	public function removeLayer(layer:MassiveLayer, dispose:Bool = false):MassiveLayer
	{
		if (this._layers.remove(layer))
		{
			layer.display = null;
			if (dispose) layer.dispose();
			return layer;
		}
		return null;
	}
	
	public function removeLayerAt(index:Int, dispose:Bool = false):MassiveLayer
	{
		var layer:MassiveLayer = _layers[index];
		_layers.splice(index, 1);
		layer.display = null;
		if (dispose) layer.dispose();
		return layer;
	}
	
	public function removeLayerWithName(name:String, dispose:Bool = false):MassiveLayer
	{
		var layer:MassiveLayer;
		var count:Int = _layers.length;
		for (i in 0...count)
		{
			if (_layers[i].name == name)
			{
				layer = _layers[i];
				_layers.splice(i, 1);
				layer.display = null;
				if (dispose) layer.dispose();
				return layer;
			}
		}
		return null;
	}
	
	public function advanceTime(time:Float):Void
	{
		for (layer in _layers)
		{
			if (layer.animate) layer.advanceTime(time);
		}
		
		setRequiresRedraw();
	}
	
	override public function render(painter:Painter):Void 
	{
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
			for (layer in this._layers)
			{
				this._numQuads += layer.writeDataBytes(this._byteData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
			}
			
			this._vertexBuffer.uploadFromByteArray(this._byteData, 0, 0, this._numQuads * MassiveConstants.VERTICES_PER_QUAD);
		}
		else
		{
			for (layer in this._layers)
			{
				this._numQuads += layer.writeDataVector(this._vectorData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
			}
			
			this._vertexBuffer.uploadFromVector(this._vectorData, 0, this._numQuads * MassiveConstants.VERTICES_PER_QUAD);
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
		_numQuads = 0;
		if (this.useByteArray)
		{
			_byteData.length = 0;
			for (layer in this._layers)
			{
				this._numQuads += layer.writeDataBytes(this._byteData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
			}
		}
		else
		{
			for (layer in this._layers)
			{
				this._numQuads += layer.writeDataVector(this._vectorData, this._numQuads, this.renderOffsetX, this.renderOffsetY);
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
				this.__blendMode = Context3DBlendFactor.SOURCE_ALPHA + ", " + Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				if (!BlendMode.isRegistered(this.__blendMode))
				{
					BlendMode.register(this.__blendMode, Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				}
			}
		}
	}
	
	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle 
	{
		if (targetSpace == this || targetSpace == null)
		{
			if (this._boundsRect != null)
			{
				return this._boundsRect;
			}
			else if (stage != null)
			{
				// return full stage size to support filters ... may be expensive, but we have no other options, do we?
				if (out == null) out = new Rectangle();
				out.setTo(0, 0, stage.stageWidth, stage.stageHeight);
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
			
			if (this._boundsRect != null)
			{
				getTransformationMatrix(targetSpace, _helperMatrix);
				MatrixUtil.transformCoords(_helperMatrix, this._boundsRect.x, this._boundsRect.y, _helperPoint);
				out.x = _helperPoint.x;
				out.y = _helperPoint.y;
				MatrixUtil.transformCoords(_helperMatrix, this._boundsRect.width, this._boundsRect.height, _helperPoint);
				out.width = _helperPoint.x;
				out.height = _helperPoint.y;
			}
			else if (stage != null)
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
		if (_boundsRect == null) _boundsRect = new Rectangle();
		
		if (this._numQuads == 0)
		{
			this._boundsRect.x = this.__x;
			this._boundsRect.y = this.__y;
			this._boundsRect.width = 0;
			this._boundsRect.height = 0;
			return;
		}
		
		var quadPos:Int;
		var pos:Int;
		
		var minX:Float = MassiveConstants.FLOAT_MAX;
		var maxX:Float = MassiveConstants.FLOAT_MIN;
		var minY:Float = MassiveConstants.FLOAT_MAX;
		var maxY:Float = MassiveConstants.FLOAT_MIN;
		
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
		
		this._boundsRect.x = this.__x + minX - this.renderOffsetX;
		this._boundsRect.y = this.__y + minY - this.renderOffsetY;
		this._boundsRect.width = maxX - minX;
		this._boundsRect.height = maxY - minY;
	}
	
}