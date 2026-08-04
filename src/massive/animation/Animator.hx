package massive.animation;

import massive.display.Clip;
import massive.display.EventClip;
import massive.event.MassiveEventType;
import massive.particle.Particle;
import starling.animation.IAnimatable;
#if flash
import openfl.Vector;
#end

/**
 * Animates textures and generates timings
 * @author Matse
 */
//class Animator<B:BasicClip = BasicClip, C:Clip = Clip, P:Particle = Particle> implements IAnimatable
class Animator implements IAnimatable
{
	/**
	 * @default	true
	 */
	public var animate:Bool = true;
	
	#if flash
	private var _basicClipLists:Vector<Vector<Clip>>;
	private var _basicClips:Vector<Clip>;
	private var _clipLists:Vector<Vector<EventClip>>;
	private var _clips:Vector<EventClip>;
	private var _particleLists:Vector<Vector<Particle>>;
	#else
	private var _basicClipLists:Array<Array<Clip>>;
	private var _basicClips:Array<Clip>;
	private var _clipLists:Array<Array<EventClip>>;
	private var _clips:Array<EventClip>;
	private var _particleLists:Array<Array<Particle>>;
	#end
	
	public function new()
	{
		#if flash
		this._basicClipLists = new Vector<Vector<Clip>>();
		this._basicClips = new Vector<Clip>();
		this._clipLists = new Vector<Vector<EventClip>>();
		this._clips = new Vector<EventClip>();
		this._particleLists = new Vector<Vector<Particle>>();
		#else
		this._basicClipLists = new Array<Array<Clip>>();
		this._basicClips = new Array<Clip>();
		this._clipLists = new Array<Array<EventClip>>();
		this._clips = new Array<EventClip>();
		this._particleLists = new Array<Array<Particle>>();
		#end
	}
	
	public function clear():Void
	{
		#if flash
		this._basicClipLists.length = 0;
		this._basicClips.length = 0;
		this._clipLists.length = 0;
		this._clips.length = 0;
		this._particleLists.length = 0;
		#else
		this._basicClipLists.resize(0);
		this._basicClips.resize(0);
		this._clipLists.resize(0);
		this._clips.resize(0);
		this._particleLists.resize(0);
		#end
	}
	
	public function addBasicClip(clip:Clip):Void
	{
		this._basicClips[this._basicClips.length] = clip;
	}
	
	public function hasBasicClip(clip:Clip):Bool
	{
		return this._basicClips.indexOf(clip) != -1;
	}
	
	public function removeBasicClip(clip:Clip):Void
	{
		#if flash
		this._basicClips.removeAt(this._basicClips.indexOf(clip));
		#else
		this._basicClips.splice(this._basicClips.indexOf(clip), 1);
		#end
	}
	
	#if flash
	public function addBasicClipList(clips:Vector<Clip>):Void
	#else
	public function addBasicClipList(clips:Array<Clip>):Void
	#end
	{
		this._basicClipLists[this._basicClipLists.length] = clips;
	}
	
	#if flash
	public function hasBasicClipList(clips:Vector<Clip>):Bool
	#else
	public function hasBasicClipList(clips:Array<Clip>):Bool
	#end
	{
		return this._basicClipLists.indexOf(clips) != -1;
	}
	
	#if flash
	public function removeBasicClipList(clips:Vector<Clip>):Void
	#else
	public function removeBasicClipList(clips:Array<Clip>):Void
	#end
	{
		#if flash
		this._basicClipLists.removeAt(this._basicClipLists.indexOf(clips));
		#else
		this._basicClipLists.splice(this._basicClipLists.indexOf(clips), 1);
		#end
	}
	
	public function addClip(clip:EventClip):Void
	{
		this._clips[this._clips.length] = clip;
	}
	
	public function hasClip(clip:EventClip):Bool
	{
		return this._clips.indexOf(clip) != -1;
	}
	
	public function removeClip(clip:EventClip):Void
	{
		#if flash
		this._clips.removeAt(this._clips.indexOf(clip));
		#else
		this._clips.splice(this._clips.indexOf(clip), 1);
		#end
	}
	
	#if flash
	public function addClipList(clips:Vector<EventClip>):Void
	#else
	public function addClipList(clips:Array<EventClip>):Void
	#end
	{
		this._clipLists[this._clipLists.length] = clips;
	}
	
	#if flash
	public function hasClipList(clips:Vector<EventClip>):Bool
	#else
	public function hasClipList(clips:Array<EventClip>):Bool
	#end
	{
		return this._clipLists.indexOf(clips) != -1;
	}
	
	#if flash
	public function removeClipList(clips:Vector<EventClip>):Void
	#else
	public function removeClipList(clips:Array<EventClip>):Void
	#end
	{
		#if flash
		this._clipLists.removeAt(this._clipLists.indexOf(clips));
		#else
		this._clipLists.splice(this._clipLists.indexOf(clips), 1);
		#end
	}
	
	#if flash
	public function addParticleList(particles:Vector<Particle>):Void
	#else
	public function addParticleList(particles:Array<Particle>):Void
	#end
	{
		this._particleLists[this._particleLists.length] = particles;
	}
	
	#if flash
	public function hasParticleList(particles:Vector<Particle>):Bool
	#else
	public function hasParticleList(particles:Array<Particle>):Bool
	#end
	{
		return this._particleLists.indexOf(particles) != -1;
	}
	
	#if flash
	public function removeParticleList(particles:Vector<Particle>):Void
	#else
	public function removeParticleList(particles:Array<Particle>):Void
	#end
	{
		#if flash
		this._particleLists.removeAt(this._particleLists.indexOf(particles));
		#else
		this._particleLists.splice(this._particleLists.indexOf(particles), 1);
		#end
	}
	
	public function advanceTime(time:Float):Void
	{
		if (!this.animate) return;
		
		var count:Int;
		
		if (this._basicClips.length != 0) animateClips(this._basicClips, time);
		count = this._basicClipLists.length;
		for (i in 0...count)
		{
			animateClips(this._basicClipLists[i], time);
		}
		
		if (this._clips.length != 0) animateEventClips(this._clips, time);
		count = this._clipLists.length;
		for (i in 0...count)
		{
			animateEventClips(this._clipLists[i], time);
		}
		
		//count = this._particleLists.length;
		//for (i in 0...count)
		//{
			//
		//}
	}
	
	@:access(massive.display.Clip)
	#if flash
	inline private function animateClips(clips:Vector<Clip>, time:Float):Void
	#else
	inline private function animateClips(clips:Array<Clip>, time:Float):Void
	#end
	{
		var clip:Clip;
		var count:Int = clips.length;
		for (i in 0...count)
		{
			clip = clips[i];
			if (!clip.animate) continue;
			
			clip.frameTime += time * clip.frameDelta;
			if (clip.frameTime >= clip.frameTimingCurrent)
			{
				if (clip._frameIndex < clip.lastFrameIndex)
				{
					++clip.frameIndex;
				}
				else if (clip.loop && (clip.numLoops == 0 || clip.loopCount < clip.numLoops))
				{
					clip.frameIndex = clip.animation.loopFrame;
					clip.frameTime -= clip.animation.loopDuration;
					++clip.loopCount;
				}
				else
				{
					clip.animationComplete = true;
					if (clip.animationCompleteCallback != null) clip.animationCompleteCallback(clip);
					if (clip.animation.nextAnimationID != null)
					{
						clip.playWithID(clip.animation.nextAnimationID);
					}
					else if (clip._animationQueue.length != 0)
					{
						clip.playNextFromQueue();
					}
					else if (clip.completeCallback != null)
					{
						clip.completeCallback(clip);
					}
				}
			}
		}
	}
	
	@:access(massive.display.EventClip)
	#if flash
	inline private function animateEventClips(clips:Vector<EventClip>, time:Float):Void
	#else
	inline private function animateEventClips(clips:Array<EventClip>, time:Float):Void
	#end
	{
		var clip:EventClip;
		var frameIndex:Int;
		var count:Int = clips.length;
		for (i in 0...count)
		{
			clip = clips[i];
			if (!clip.animate) continue;
			
			clip.frameTime += time * clip.frameDelta;
			if (clip.frameTime >= clip.frameTimingCurrent)
			{
				frameIndex = clip._frameIndex;
				while (true)
				{
					if (frameIndex < clip.lastFrameIndex)
					{
						++frameIndex;
						clip.frameTimingCurrent = clip._timings[frameIndex];
						if (clip._events[frameIndex] != null)
						{
							clip.dispatchEventWith(clip._events[frameIndex], false, clip._eventParams[frameIndex]);
						}
					}
					else if (clip.loop && (clip.numLoops == 0 || clip.loopCount < clip.numLoops))
					{
						frameIndex = clip.animation.loopFrame;
						++clip.loopCount;
						clip.frameTime -= clip.animation.loopDuration;
						clip.frameTimingCurrent = clip._timings[frameIndex];
					}
					else
					{
						// animation complete
						clip.animationComplete = true;
						clip.dispatchEventWith(MassiveEventType.ANIMATION_COMPLETE);
						if (clip.animationCompleteCallback != null) clip.animationCompleteCallback(clip);
						if (clip.animation.nextAnimationID != null)
						{
							clip.playWithID(clip.animation.nextAnimationID);
						}
						else if (clip._animationQueue.length != 0)
						{
							clip.playNextFromQueue();
						}
						else
						{
							clip.dispatchEventWith(MassiveEventType.CLIP_COMPLETE);
							if (clip.completeCallback != null)
							{
								clip.completeCallback(clip);
							}
						}
						break;
					}
					if (clip.frameTime < clip.frameTimingCurrent) break;
				}
				clip.frameIndex = frameIndex;
			}
		}
	}
	
	//@:access(massive.display.Particle)
	//#if flash
	//public function animateParticles(clips:Vector<P>, time:Float):Void
	//#else
	//public function animateParticles(clips:Array<P>, time:Float):Void
	//#end
	//{
		//var clip:P;
		//var count:Int = clips.length;
		//for (i in 0...count)
		//{
			//clip = clips[i];
			//if (!clip.animate) continue;
			//
			//clip.frameTime += time * clip.frameDelta;
			//if (clip.frameTime >= clip.frameTimingCurrent)
			//{
				//if (clip._frameIndex < clip.lastFrameIndex)
				//{
					//++clip.frameIndex;
				//}
				//else if (clip.loop && (clip.numLoops == 0 || clip.loopCount < clip.numLoops))
				//{
					//clip.frameIndex = clip.animation.loopFrame;
					//clip.frameTime -= clip.animation.loopDuration;
					//++clip.loopCount;
				//}
			//}
		//}
	//}
	
}