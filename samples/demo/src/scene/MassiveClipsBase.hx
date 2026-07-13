package scene;

import massive.animation.Animation;
import massive.animation.Animator;
import massive.data.Frame;
import massive.data.VertexPositionData;
import massive.display.BasicClip;
import massive.display.Clip;
import massive.display.ClipContainer;
import massive.display.ImgContainer;
import massive.display.MixedContainer;
import massive.display.MassiveDisplay;
import massive.display.base.ContainerBase;
import massive.util.AnimUtils;
import massive.util.DisplayUtils;
import massive.util.MathUtils;
import openfl.Vector;
import openfl.errors.Error;
import scene.object.IMassiveClip;
import starling.animation.IAnimatable;
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
abstract class MassiveClipsBase extends Scene implements IAnimatable
{
	public var containerType:String;
	public var colorMode:String;
	public var frameDeltaBase:Float = 0.1;
	public var frameDeltaVariance:Float = 0.5;
	public var numObjects:Int = 1000;
	public var renderMode:String;
	public var useBlurFilter:Bool;
	public var useRandomAlpha:Bool;
	public var useRandomColor:Bool;
	public var useRandomRotation:Bool;
	public var useSprite3D:Bool;
	public var imgScale:Float = 1;
	#if flash
	public var atlasTextures:Vector<Texture> = new Vector<Texture>();
	#else
	public var atlasTextures:Array<Texture> = new Array<Texture>();
	#end
	public var textures:Array<Vector<Texture>>;
	
	override function set_animation(value:Bool):Bool 
	{
		if (this._display != null)
		{
			this._display.animate = value;
		}
		return super.set_animation(value);
	}
	
	override function set_autoUpdateBounds(value:Bool):Bool 
	{
		if (this._display != null)
		{
			this._display.autoUpdateBounds = value;
		}
		return super.set_autoUpdateBounds(value);
	}
	
	private var _display:MassiveDisplay;
	private var _numTextures:Int;
	#if flash
	private var _clipList:Vector<IMassiveClip>;
	#else
	private var _clipList:Array<IMassiveClip>;
	#end
	private var _velocityBase:Float = 30;
	private var _velocityRange:Float = 150;
	
	private var _sprite3D:Sprite3D;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	public function addAtlases(atlases:Array<TextureAtlas>):Void
	{
		for (i in 0...atlases.length)
		{
			this.atlasTextures[this.atlasTextures.length] = atlases[i].texture;
		}
	}
	
	@:access(massive.display.Clip)
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		this._numTextures = this.atlasTextures.length;
		
		//var animation:Animation;
		//#if flash
		//var frames:Vector<Frame> = new Vector<Frame>();
		//#else
		//var frames:Array<Frame> = new Array<Frame>();
		//#end
		//
		//for (i in 0...this._numTextures)
		//{
			//Frame.fromTextureVectorWithAlign(this.textures[i], Align.CENTER, Align.CENTER, frames);
			//animation = AnimUtils.createAnimation(frames);
			//animation.loop = true;
			//this._animations[this._animations.length] = animation;
			//
			//#if flash
			//frames.length = 0;
			//#else
			//frames.resize(0);
			//#end
		//}
		
		// vertex animation test
		//animation = this._animations[0];
		//var bend:Float = 50.0;
		//var bendStart:Float = -bend;
		//var bendStep:Float = (bend * 2) / animation.lastFrame;
		//var clip:Clip = Clip.fromPool();
		////clip.scaleX = 0.2;
		////clip.scaleY = 0.2;
		//clip.play(animation);
		//var vertexData:VertexData;
		//for (i in 0...animation.numFrames)
		//{
			//clip.frameIndex = i;
			//DisplayUtils.updateTransform(clip);
			//vertexData = VertexData.fromPool(clip._x1, clip._x2, clip._x3, clip._x4, clip._y1, clip._y2, clip._y3, clip._y4);
			//vertexData.x1 += bendStart + bendStep * i;
			//vertexData.x2 += bendStart + bendStep * i;
			//for (j in 0...numTextures)
			//{
				//this._animations[j].frames[i].vertexData = vertexData;
			//}
		//}
		//
		//for (i in 0...numTextures)
		//{
			//this._animations[i].ready();
		//}
		//\vertex animation test
		
		// test with black quads
		//var tex:Texture = Texture.fromColor(64, 64, 0x000000);
		//frames = new Vector<Frame>();
		//frames.push(Frame.fromTextureWithAlign(tex, Align.CENTER, Align.CENTER));
		//this._frames.push(frames);
		//timings = [0.0];
		//this._timings.push(timings);
		//numTextures = 1;
		
		//var stageWidth:Float = this.stage.stageWidth;
		//var stageHeight:Float = this.stage.stageHeight;
		
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
		
		//var layer:ContainerBase;
		#if flash
		this._clipList = new Vector<IMassiveClip>();
		#else
		this._clipList = new Array<IMassiveClip>();
		#end
		//var clip:MassiveClip;
		//var speedVariance:Float;
		//var variant:Int;
		//var velocity:Float;
		
		this._display = new MassiveDisplay(this.atlasTextures, this.renderMode, this.colorMode, this.numObjects);
		this._display.animate = this._animation;
		this._display.autoUpdateBounds = this._autoUpdateBounds;
		//this._display.colorOffsetMode = ColorOffsetMode.OBJECT;
		
		//switch (this.containerType)
		//{
			//case ContainerType.CLIP :
				//layer = new ClipContainer();
			//
			//case ContainerType.IMG :
				//layer = new ImgContainer();
			//
			//case ContainerType.MIXED :
				//layer = new MixedContainer();
			//
			//default :
				//throw new Error("unknown container type " + this.containerType);
		//}
		//
		//layer.animate = true;
		//this._display.addLayer(layer);
		
		//this.numObjects = 0;
		//var tX:Float = stageWidth / 2 - 200.0;
		//var tY:Float = stageHeight / 2;
		//variant = 0;
		//clip = new MassiveClip();
		//clip.textureIndex = variant;
		//clip.frameDelta = 0.2;
		//clip.play(this._animations[variant]);
		//clip.x = tX;
		//clip.y = tY;
		//layer.addChild(clip);
		//
		//tX += 100.0;
		//variant = 1;
		//clip = new MassiveClip();
		//clip.textureIndex = variant;
		//clip.frameDelta = 0.2;
		//clip.invertX = true;
		//clip.play(this._animations[variant]);
		//clip.x = tX;
		//clip.y = tY;
		//layer.addChild(clip);
		
		//this.numObjects = 2;
		//for (i in 0...this.numObjects)
		//{
			//variant = Std.random(this._numTextures);
			//
			//clip = new MassiveClip();
			//
			//// vertex color test
			////clip.uniformColor = false;
			////clip.color3 = img.color4 = 0x000000;
			////clip.uniformColorOffset = false;
			////clip.redOffset1 = 1.0;
			////clip.blueOffset4 = 1.0;
			////clip.colorOffset = 0xff0000;
			////clip.colorOffset3 = 0xff0000;
			////clip.colorOffset2 = 0x00ff00;
			////clip.colorOffset4 = 0x00ff00;
			////clip.alphaOffset = -1;
			////\vertex color test
			//
			//clip.textureIndex = variant;
			//clip.play(this._animations[variant]);
			//clip.x = MathUtils.random() * stageWidth;
			//clip.y = MathUtils.random() * stageHeight;
			//clip.scaleX = clip.scaleY = this.imgScale;
			//if (this.useRandomRotation) clip.rotation = MathUtils.random() * MathUtils.PI2;
			//
			//if (this.useRandomAlpha) clip.alpha = MathUtils.random();
			//if (this.useRandomColor)
			//{
				//clip.red = MathUtils.random();
				//clip.green = MathUtils.random();
				//clip.blue = MathUtils.random();
			//}
			//
			//speedVariance = MathUtils.random();
			//clip.frameDelta = this.frameDeltaBase + speedVariance * this.frameDeltaVariance;
			//
			//velocity = this._velocityBase + speedVariance * this._velocityRange;
			//clip.velocityX = Math.cos(clip.rotation) * velocity;
			//clip.velocityY = Math.sin(clip.rotation) * velocity;
			//
			//if (clip.velocityX < 0.0) clip.invertY = true;
			//
			//this._clipList[this._clipList.length] = clip;
			////layer.addChild(clip);
		//}
		
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
	
	private function initClip(clip:IMassiveClip):Int
	{
		var variant:Int = Std.random(this._numTextures);
		
		//var clip:MassiveClip = new MassiveClip();
		
		// vertex color test
		//clip.uniformColor = false;
		//clip.color3 = img.color4 = 0x000000;
		//clip.uniformColorOffset = false;
		//clip.redOffset1 = 1.0;
		//clip.blueOffset4 = 1.0;
		//clip.colorOffset = 0xff0000;
		//clip.colorOffset3 = 0xff0000;
		//clip.colorOffset2 = 0x00ff00;
		//clip.colorOffset4 = 0x00ff00;
		//clip.alphaOffset = -1;
		//\vertex color test
		
		clip.textureIndex = variant;
		//clip.play(this._animations[variant]);
		clip.x = MathUtils.random() * this.stage.stageWidth;
		clip.y = MathUtils.random() * this.stage.stageHeight;
		clip.scaleX = clip.scaleY = this.imgScale;
		if (this.useRandomRotation) clip.rotation = MathUtils.random() * MathUtils.PI2;
		
		if (this.useRandomAlpha) clip.alpha = MathUtils.random();
		if (this.useRandomColor)
		{
			clip.red = MathUtils.random();
			clip.green = MathUtils.random();
			clip.blue = MathUtils.random();
		}
		
		var speedVariance:Float = MathUtils.random();
		clip.frameDelta = this.frameDeltaBase + speedVariance * this.frameDeltaVariance;
		
		var velocity:Float = this._velocityBase + speedVariance * this._velocityRange;
		clip.velocityX = Math.cos(clip.rotation) * velocity;
		clip.velocityY = Math.sin(clip.rotation) * velocity;
		
		if (clip.velocityX < 0.0) clip.invertY = true;
		
		this._clipList[this._clipList.length] = clip;
		
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
		
		if (!this.useRandomRotation && this._clipList != null)
		{
			var stageHeight:Float = this.stage.stageHeight;
			
			for (i in 0...this.numObjects)
			{
				this._clipList[i].y = MathUtils.random() * stageHeight;
			}
		}
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this);
		
		super.dispose();
	}
	
	public function advanceTime(time:Float):Void
	{
		if (this.useSprite3D)
		{
			this._sprite3D.rotationY += 0.01;
		}
		
		//var clip:IMassiveClip;
		//for (i in 0...this.numObjects)
		//{
			//clip = this._clipList[i];
			//if (this._movement)
			//{
				//clip.x += clip.velocityX * time;
				//clip.y += clip.velocityY * time;
				//
				//if (clip.x < this._left)
				//{
					//clip.x = this._right;
				//}
				//else if (clip.x > this._right)
				//{
					//clip.x = this._left;
				//}
				//
				//if (clip.y < this._top)
				//{
					//clip.y = this._bottom;
				//}
				//else if (clip.y > this._bottom)
				//{
					//clip.y = this._top;
				//}
			//}
		//}
	}
	
}