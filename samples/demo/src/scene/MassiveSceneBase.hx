package scene;
import massive.data.Frame;
import massive.data.VertexColorData;
import massive.data.VertexPositionData;
import massive.display.Img;
import massive.display.ImgContainer;
import massive.display.MassiveDisplay;
import massive.display.MixedContainer;
import massive.util.AnimUtils;
import massive.util.MathUtils;
import openfl.Vector;
import scene.massive.IMassiveImg;
import starling.animation.IAnimatable;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Sprite3D;
import starling.events.Event;
import starling.filters.BlurFilter;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
abstract class MassiveSceneBase extends Scene implements IAnimatable
{
	#if flash
	public var atlasTextures:Vector<Texture> = new Vector<Texture>();
	#else
	public var atlasTextures:Array<Texture> = new Array<Texture>();
	#end
	public var colorMode:String;
	public var colorOffsetMode:String;
	public var colorOffsetAlphaRange:Float = 1.0;
	public var colorOffsetRange:Float = 1.0;
	public var colorAlphaRange:Float = 1.0;
	public var colorRange:Float = 1.0;
	public var colorValueLow:Float = 0.0;
	public var containerType:String;
	public var numObjects:Int = 1000;
	public var numObjectsPerContainer:Int = 100;
	public var objectScale:Float = 1;
	public var renderMode:String;
	public var textures:Array<Vector<Texture>>;
	public var useBlurFilter:Bool;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	public var useRandomAlphaOffset:Bool;
	public var useRandomColorOffset:Bool;
	public var useRandomRotation:Bool;
	public var useSprite3D:Bool;
	public var vertexColorAnimation:Bool;
	public var vertexColorOffsetAnimation:Bool;
	public var vertexPositionAnimation:Bool;
	
	override function set_autoUpdateBounds(value:Bool):Bool 
	{
		if (this._display != null)
		{
			this._display.autoUpdateBounds = value;
		}
		return super.set_autoUpdateBounds(value);
	}
	
	private var _display:MassiveDisplay;
	#if flash
	private var _frames:Vector<Vector<Frame>> = new Vector<Vector<Frame>>();
	private var _animationPositions:Vector<Vector<VertexPositionData>> = new Vector<Vector<VertexPositionData>>();
	private var _animationColors:Vector<VertexColorData> = new Vector<VertexColorData>();
	private var _animationColorOffsets:Vector<VertexColorData> = new Vector<VertexColorData>();
	private var _imageList:Vector<Img> = new Vector<Img>();
	#else
	private var _frames:Array<Array<Frame>> = new Array<Array<Frame>>();
	private var _animationPositions:Array<Array<VertexPositionData>> = new Array<Array<VertexPositionData>>();
	private var _animationColors:Array<VertexColorData> = new Array<VertexColorData>();
	private var _animationColorOffsets:Array<VertexColorData> = new Array<VertexColorData>();
	private var _imageList:Array<Img> = new Array<Img>();
	#end
	private var _imgLayer:ImgContainer;
	private var _mixedLayer:MixedContainer;
	private var _numTextures:Int;
	private var _sprite3D:Sprite3D;
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	private var _useMultipleContainers:Bool;
	private var _containerObjectCount:Int = 0;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this);
		
		var count:Int;
		#if flash
		var frames:Vector<Frame>;
		#else
		var frames:Array<Frame>;
		#end
		
		for (i in 0...this._numTextures)
		{
			frames = this._frames[i];
			count = frames.length;
			for (j in 0...count)
			{
				if (!frames[j].isInPool) frames[j].pool();
			}
		}
		
		if (this.vertexPositionAnimation)
		{
			#if flash
			var positions:Vector<VertexPositionData>;
			#else
			var positions:Array<VertexPositionData>;
			#end
			for (i in 0...this._numTextures)
			{
				positions = this._animationPositions[i];
				count = positions.length;
				for (j in 0...count)
				{
					if (!positions[j].isInPool) positions[j].pool();
				}
			}
		}
		
		if (this.vertexColorAnimation)
		{
			count = this._animationColors.length;
			for (i in 0...count)
			{
				if (!this._animationColors[i].isInPool) this._animationColors[i].pool();
			}
		}
		
		if (this.vertexColorOffsetAnimation)
		{
			count = this._animationColors.length;
			for (i in 0...count)
			{
				if (!this._animationColorOffsets[i].isInPool) this._animationColors[i].pool();
			}
		}
		
		super.dispose();
	}
	
	public function addAtlases(atlases:Array<TextureAtlas>):Void
	{
		for (i in 0...atlases.length)
		{
			this.atlasTextures[this.atlasTextures.length] = atlases[i].texture;
		}
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		this._numTextures = this.atlasTextures.length;
		
		var count:Int;
		#if flash
		var frames:Vector<Frame>;
		#else
		var frames:Array<Frame>;
		#end
		
		// create animation frames
		for (i in 0...this._numTextures)
		{
			frames = Frame.fromTextureVectorWithAlign(this.textures[i], Align.CENTER, Align.CENTER);
			AnimUtils.repeatFrames(frames, 7);
			this._frames[i] = frames;
		}
		
		// Vertex Position animation
		if (this.vertexPositionAnimation)
		{
			var position:VertexPositionData;
			#if flash
			var positions:Vector<VertexPositionData>;
			var positions2:Vector<VertexPositionData> = new Vector<VertexPositionData>();
			var animPositions:Vector<VertexPositionData>;
			#else
			var positions:Array<VertexPositionData>;
			var positions2:Array<VertexPositionData> = new Array<VertexPositionData>();
			var animPositions:Array<VertexPositionData>;
			#end
			
			var xMove:Float = 50.0;
			var yMove:Float = -50.0;
			
			var transitionIn:Float->Float = Transitions.getTransition(Transitions.EASE_IN);
			var transitionOut:Float->Float = Transitions.getTransition(Transitions.EASE_OUT);
			
			for (i in 0...this._numTextures)
			{
				// create vertex positions from frames
				positions = AnimUtils.createVertexPositionSequenceFromFrames(this._frames[i]);
				// clone vertex positions for target values
				VertexPositionData.cloneSequence(positions, positions2);
				count = positions.length;
				for (j in 0...16)
				{
					// target values for interpolation
					position = positions2[j];
					position.x2 += xMove;
					position.y2 += yMove;
				}
				// create animation
				animPositions = AnimUtils.animateVertexPositionSequence(positions, positions2, 0, 16, transitionIn);
				for (j in 16...32)
				{
					// source values for interpolation
					position = positions[j];
					position.x2 += xMove;
					position.y2 += yMove;
				}
				// add back animation
				AnimUtils.animateVertexPositionSequence(positions, positions2, 16, 32, transitionOut, animPositions);
				for (j in 32...48)
				{
					position = positions2[j];
					position.x1 -= xMove;
					position.y1 += yMove;
				}
				AnimUtils.animateVertexPositionSequence(positions, positions2, 32, 48, transitionIn, animPositions);
				for (j in 48...64)
				{
					position = positions[j];
					position.x1 -= xMove;
					position.y1 += yMove;
				}
				AnimUtils.animateVertexPositionSequence(positions, positions2, 48, 64, transitionOut, animPositions);
				this._animationPositions[i] = animPositions;
				VertexPositionData.poolSequence(positions);
				VertexPositionData.poolSequence(positions2);
				#if flash
				positions2.length = 0;
				#else
				positions2.resize(0);
				#end
			}
		}
		//\Vertex Position animation
		
		// Vertex Color animation
		if (this.vertexColorAnimation)
		{
			var color1:VertexColorData = VertexColorData.fromPool();
			color1.red1 = this.colorRange;
			color1.green1 = this.colorValueLow;
			color1.blue1 = this.colorValueLow;
			color1.red3 = this.colorRange;
			color1.green3 = this.colorValueLow;
			color1.blue3 = this.colorValueLow;
			var color2:VertexColorData = VertexColorData.fromPool();
			color2.red1 = this.colorValueLow;
			color2.green1 = this.colorRange;
			color2.blue1 = this.colorValueLow;
			color2.red2 = this.colorValueLow;
			color2.green2 = this.colorRange;
			color2.blue2 = this.colorValueLow;
			var color3:VertexColorData = VertexColorData.fromPool();
			color3.red2 = this.colorValueLow;
			color3.green2 = this.colorValueLow;
			color3.blue2 = this.colorRange;
			color3.red4 = this.colorValueLow;
			color3.green4 = this.colorValueLow;
			color3.blue4 = this.colorRange;
			var color4:VertexColorData = VertexColorData.fromPool();
			color4.red3 = this.colorValueLow;
			color4.green3 = this.colorRange;
			color4.blue3 = this.colorRange;
			//color4.alpha3 = 0.0;
			color4.red4 = this.colorValueLow;
			color4.green4 = this.colorRange;
			color4.blue4 = this.colorRange;
			//color4.alpha4 = 0.0;
			
			AnimUtils.animateVertexColor(color1, color2, AnimUtils.getDuration(16, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColors);
			AnimUtils.animateVertexColor(color2, color3, AnimUtils.getDuration(16, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColors);
			AnimUtils.animateVertexColor(color3, color4, AnimUtils.getDuration(16, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColors);
			AnimUtils.animateVertexColor(color4, color1, AnimUtils.getDuration(16, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColors);
			
			color1.pool();
			color2.pool();
			color3.pool();
			color4.pool();
		}
		//\Vertex Color animation
		
		// Vertex Color Offset animation
		if (this.vertexColorOffsetAnimation)
		{
			var offset1:VertexColorData = VertexColorData.fromPool(0, 0, 0, 0);
			offset1.red1 = this.colorOffsetRange;
			//offset1.alpha1 = -1.0;
			var offset2:VertexColorData = VertexColorData.fromPool(0, 0, 0, 0);
			offset2.green2 = this.colorOffsetRange;
			//offset2.alpha2 = -1.0;
			var offset3:VertexColorData = VertexColorData.fromPool(0, 0, 0, 0);
			offset3.blue3 = this.colorOffsetRange;
			//offset3.alpha3 = -1.0;
			var offset4:VertexColorData = VertexColorData.fromPool(0, 0, 0, 0);
			offset4.red4 = this.colorOffsetRange;
			offset4.blue4 = this.colorOffsetRange;
			//offset4.alpha4 = -1.0;
			
			AnimUtils.animateVertexColor(offset1, offset2, AnimUtils.getDuration(8, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColorOffsets);
			AnimUtils.animateVertexColor(offset2, offset3, AnimUtils.getDuration(8, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColorOffsets);
			AnimUtils.animateVertexColor(offset3, offset4, AnimUtils.getDuration(8, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColorOffsets);
			AnimUtils.animateVertexColor(offset4, offset1, AnimUtils.getDuration(8, 60), Transitions.getTransition(Transitions.LINEAR), 60, this._animationColorOffsets);
			AnimUtils.repeatVertexColors(this._animationColorOffsets, 1);
			
			offset1.pool();
			offset2.pool();
			offset3.pool();
			offset4.pool();
		}
		//\Vertex Color Offset animation
		
		updateBounds();
		
		if (this.useSprite3D)
		{
			this._sprite3D = new Sprite3D();
			this._sprite3D.pivotX = this.stage.stageWidth / 2;
			this._sprite3D.pivotY = this.stage.stageHeight / 2;
			this._sprite3D.x = this._sprite3D.pivotX;
			this._sprite3D.y = this._sprite3D.pivotY;
			addChild(this._sprite3D);
		}
		
		this._display = new MassiveDisplay(this.atlasTextures, this.renderMode, this.colorMode, this.numObjects, this.colorOffsetMode);
		this._display.autoUpdateBounds = this._autoUpdateBounds;
		
		if (this.containerType == ContainerType.IMG)
		{
			this._imgLayer = new ImgContainer();
			this._display.addLayer(this._imgLayer);
		}
		else
		{
			this._mixedLayer = new MixedContainer();
			this._display.addLayer(this._mixedLayer);
			
			this._useMultipleContainers = this.containerType == ContainerType.MULTIPLE;
		}
		
		if (this.useSprite3D)
		{
			this._sprite3D.addChild(this._display);
		}
		else
		{
			addChild(this._display);
		}
		
		if (this.useBlurFilter)
		{
			this.filter = new BlurFilter();
		}
		
		Starling.currentJuggler.add(this);
		
		init();
	}
	
	abstract private function init():Void;
	
	private function initImg(img:IMassiveImg, setFrame:Bool = true):Int
	{
		var variant:Int = Std.random(this._numTextures);
		
		if (setFrame)
		{
			var frameIndex:Int = Std.random(this._frames[variant].length);
			img.frame = this._frames[variant][frameIndex];
			if (this.vertexPositionAnimation) img.vertexPosition = this._animationPositions[variant][frameIndex];
			if (this.vertexColorAnimation) img.vertexColor = this._animationColors[frameIndex];
			if (this.vertexColorOffsetAnimation) img.vertexColorOffset = this._animationColorOffsets[frameIndex];
		}
		
		img.textureIndex = variant;
		img.x = MathUtils.random() * this.stage.stageWidth;
		img.y = MathUtils.random() * this.stage.stageHeight;
		img.scaleX = img.scaleY = this.objectScale;
		if (this.useRandomRotation) img.rotation = MathUtils.random() * MathUtils.PI2;
		
		if (this.useRandomAlpha)
		{
			img.alpha = MathUtils.random() * this.colorAlphaRange;
		}
		else
		{
			img.alpha = this.colorAlphaRange;
		}
		if (this.useRandomColor)
		{
			img.red = MathUtils.random() * this.colorRange;
			img.green = MathUtils.random() * this.colorRange;
			img.blue = MathUtils.random() * this.colorRange;
		}
		else
		{
			img.red = this.colorRange;
			img.green = this.colorRange;
			img.blue = this.colorRange;
		}
		if (this.useRandomAlphaOffset)
		{
			img.alphaOffset = MathUtils.random() * this.colorOffsetAlphaRange;
		}
		else
		{
			img.alphaOffset = this.colorOffsetAlphaRange;
		}
		if (this.useRandomColorOffset)
		{
			img.redOffset = MathUtils.random() * this.colorOffsetRange;
			img.greenOffset = MathUtils.random() * this.colorOffsetRange;
			img.blueOffset = MathUtils.random() * this.colorOffsetRange;
		}
		//else
		//{
			//img.redOffset = this.colorOffsetRange;
			//img.greenOffset = this.colorOffsetRange;
			//img.blueOffset = this.colorOffsetRange;
		//}
		
		img.speedVariance = MathUtils.random();
		var velocity:Float = this._velocityBase + img.speedVariance * this._velocityRange;
		img.velocityX = Math.cos(img.rotation) * velocity;
		img.velocityY = Math.sin(img.rotation) * velocity;
		
		if (img.velocityX < 0.0)
		{
			if (this.vertexPositionAnimation)
			{
				img.invertX = true;
			}
			else
			{
				img.invertY = true;
			}
		}
		
		this._imageList[this._imageList.length] = cast img;
		
		if (this._useMultipleContainers)
		{
			if (this._imgLayer == null || this._containerObjectCount == this.numObjectsPerContainer)
			{
				this._imgLayer = new ImgContainer();
				this._mixedLayer.addChild(this._imgLayer);
				this._containerObjectCount = 0;
			}
			this._imgLayer.addChild(cast img);
			this._containerObjectCount++;
		}
		else if (this._mixedLayer != null)
		{
			this._mixedLayer.addChild(cast img);
		}
		else
		{
			this._imgLayer.addChild(cast img);
		}
		
		return variant;
	}
	
	override public function updateBounds():Void 
	{
		super.updateBounds();
		
		if (this._sprite3D != null)
		{
			this._sprite3D.pivotX = this.stage.stageWidth / 2;
			this._sprite3D.pivotY = this.stage.stageHeight / 2;
			this._sprite3D.x = this._sprite3D.pivotX;
			this._sprite3D.y = this._sprite3D.pivotY;
		}
		
		if (!this.useRandomRotation && this._imageList.length == this.numObjects)
		{
			var stageHeight:Float = this.stage.stageHeight;
			
			for (i in 0...this.numObjects)
			{
				this._imageList[i].y = MathUtils.random() * stageHeight;
			}
		}
	}
	
	public function advanceTime(time:Float):Void
	{
		if (this.useSprite3D)
		{
			this._sprite3D.rotationY += 0.01;
		}
	}
	
}