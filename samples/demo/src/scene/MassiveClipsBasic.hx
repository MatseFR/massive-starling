package scene;
import massive.animation.Animator;
import massive.animation.BasicAnimation;
import massive.data.Frame;
import massive.display.BasicClip;
import massive.display.Clip;
import massive.display.ImgContainer;
import massive.display.MixedContainer;
import massive.particle.Particle;
import massive.util.AnimUtils;
import openfl.Vector;
import scene.object.MovingBasicClip;
import starling.core.Starling;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class MassiveClipsBasic extends MassiveClipsBase 
{
	private var _animations:Array<BasicAnimation> = new Array<BasicAnimation>();
	private var _animator:Animator = new Animator();
	#if flash
	private var _clips:Vector<BasicClip> = new Vector<BasicClip>();
	#else
	private var _clips:Array<BasicClip> = new Array<BasicClip>();
	#end

	public function new() 
	{
		super();
	}
	
	override public function dispose():Void 
	{
		Starling.currentJuggler.remove(this._animator);
		this._animator.clear();
		
		var count:Int = this._animations.length;
		for (i in 0...count)
		{
			this._animations[i].pool();
		}
		
		super.dispose();
	}
	
	private function init():Void
	{
		var animation:BasicAnimation;
		#if flash
		var frames:Vector<Frame> = new Vector<Frame>();
		#else
		var frames:Array<Frame> = new Array<Frame>();
		#end
		
		for (i in 0...this._numTextures)
		{
			Frame.fromTextureVectorWithAlign(this.textures[i], Align.CENTER, Align.CENTER, frames);
			animation = AnimUtils.createBasicAnimation(frames);
			animation.loop = true;
			this._animations[this._animations.length] = animation;
			
			#if flash
			frames.length = 0;
			#else
			frames.resize(0);
			#end
		}
		
		var clip:MovingBasicClip;
		var variant:Int;
		
		if (this.containerType == ContainerType.IMG)
		{
			var imgLayer:ImgContainer = new ImgContainer();
			this._display.addLayer(imgLayer);
			
			for (i in 0...this.numObjects)
			{
				clip = new MovingBasicClip();
				variant = initClip(clip);
				clip.play(this._animations[variant]);
				this._clips[this._clips.length] = clip;
				imgLayer.addChild(clip);
			}
		}
		else
		{
			var mixedLayer:MixedContainer = new MixedContainer();
			this._display.addLayer(mixedLayer);
			
			for (i in 0...this.numObjects)
			{
				clip = new MovingBasicClip();
				initClip(clip);
				this._clips[this._clips.length] = clip;
				mixedLayer.addChild(clip);
			}
		}
		
		this._animator.addBasicClipList(this._clips);
		
		Starling.currentJuggler.add(this._animator);
		
		//var layer:MixedContainer = new MixedContainer();
		//this._display.addLayer(layer);
		//
		//for (i in 0...this.numObjects)
		//{
			//layer.addChild(createClip());
		//}
	}
	
}