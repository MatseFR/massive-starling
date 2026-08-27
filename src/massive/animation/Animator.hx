package massive.animation;

import massive.display.Clip;
import massive.display.EventClip;
import massive.event.MassiveEventType;
import massive.particle.Particle;
import massive.particle.ParticleSystem;
import starling.animation.IAnimatable;
#if flash
import openfl.Vector;
#end

/**
 * Animates clips
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
	private var _clipLists:Vector<Vector<Clip>>;
	private var _clips:Vector<Clip>;
	private var _eventClipLists:Vector<Vector<EventClip>>;
	private var _eventClips:Vector<EventClip>;
	private var _basicParticleLists:Vector<Vector<Particle>>;
	private var _particleLists:Vector<Vector<Particle>>;
	private var _particleSystemList:Vector<Vector<ParticleSystem>>;
	private var _particleSystems:Vector<ParticleSystem>;
	#else
	private var _basicClipLists:Array<Array<Clip>>;
	private var _basicClips:Array<Clip>;
	private var _clipLists:Array<Array<Clip>>;
	private var _clips:Array<Clip>;
	private var _eventClipLists:Array<Array<EventClip>>;
	private var _eventClips:Array<EventClip>;
	private var _basicParticleLists:Array<Array<Particle>>;
	private var _particleLists:Array<Array<Particle>>;
	private var _particleSystemList:Array<Array<ParticleSystem>>;
	private var _particleSystems:Array<ParticleSystem>;
	#end
	
	public function new()
	{
		#if flash
		this._basicClipLists = new Vector<Vector<Clip>>();
		this._basicClips = new Vector<Clip>();
		this._clipLists = new Vector<Vector<Clip>>();
		this._clips = new Vector<Clip>();
		this._eventClipLists = new Vector<Vector<EventClip>>();
		this._eventClips = new Vector<EventClip>();
		this._basicParticleLists = new Vector<Vector<Particle>>();
		this._particleLists = new Vector<Vector<Particle>>();
		this._particleSystemList = new Vector<Vector<ParticleSystem>>();
		this._particleSystems = new Vector<ParticleSystem>();
		#else
		this._basicClipLists = new Array<Array<Clip>>();
		this._basicClips = new Array<Clip>();
		this._clipLists = new Array<Array<Clip>>();
		this._clips = new Array<Clip>();
		this._eventClipLists = new Array<Array<EventClip>>();
		this._eventClips = new Array<EventClip>();
		this._basicParticleLists = new  Array<Array<Particle>>();
		this._particleLists = new Array<Array<Particle>>();
		this._particleSystemList = new Array<Array<ParticleSystem>>();
		this._particleSystems = new Array<ParticleSystem>();
		#end
	}
	
	public function clear():Void
	{
		#if flash
		this._basicClipLists.length = 0;
		this._basicClips.length = 0;
		this._clipLists.length = 0;
		this._clips.length = 0;
		this._eventClipLists.length = 0;
		this._eventClips.length = 0;
		this._basicParticleLists.length = 0;
		this._particleLists.length = 0;
		this._particleSystemList.length = 0;
		this._particleSystems.length = 0;
		#else
		this._basicClipLists.resize(0);
		this._basicClips.resize(0);
		this._clipLists.resize(0);
		this._clips.resize(0);
		this._eventClipLists.resize(0);
		this._eventClips.resize(0);
		this._basicParticleLists.resize(0);
		this._particleLists.resize(0);
		this._particleSystemList.resize(0);
		this._particleSystems.resize(0);
		#end
	}
	
	// Basic clips
	/**
	   adds clip as a basic clip, meaning it will be animated very simply : 
	   it won't skip frames if framerate is low and will slow down instead.
	   Animation's vertex position, vertex color and vertex color offset will be ignored.
	   @param	clip
	**/
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
	
	/**
	   adds clips as basic clips, meaning they will be animated very simply : 
	   they won't skip frames if framerate is low and will slow down instead.
	   Animation's vertex position, vertex color and vertex color offset will be ignored.
	   @param	clips
	**/
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
	//\ Basic clips
	
	// Clips
	public function addClip(clip:Clip):Void
	{
		this._clips[this._clips.length] = clip;
	}
	
	public function hasClip(clip:Clip):Bool
	{
		return this._clips.indexOf(clip) != -1;
	}
	
	public function removeClip(clip:Clip):Void
	{
		#if flash
		this._clips.removeAt(this._clips.indexOf(clip));
		#else
		this._clips.splice(this._clips.indexOf(clip), 1);
		#end
	}
	
	#if flash
	public function addClipList(clips:Vector<Clip>):Void
	#else
	public function addClipList(clips:Array<Clip>):Void
	#end
	{
		this._clipLists[this._clipLists.length] = clips;
	}
	
	#if flash
	public function hasClipList(clips:Vector<Clip>):Bool
	#else
	public function hasClipList(clips:Array<Clip>):Bool
	#end
	{
		return this._clipLists.indexOf(clips) != -1;
	}
	
	#if flash
	public function removeClipList(clips:Vector<Clip>):Void
	#else
	public function removeClipList(clips:Array<Clip>):Void
	#end
	{
		#if flash
		this._clipLists.removeAt(this._clipLists.indexOf(clips));
		#else
		this._clipLists.splice(this._clipLists.indexOf(clips), 1);
		#end
	}
	//\Clips
	
	// Event clips
	public function addEventClip(clip:EventClip):Void
	{
		this._eventClips[this._eventClips.length] = clip;
	}
	
	public function hasEventClip(clip:EventClip):Bool
	{
		return this._eventClips.indexOf(clip) != -1;
	}
	
	public function removeEventClip(clip:EventClip):Void
	{
		#if flash
		this._eventClips.removeAt(this._eventClips.indexOf(clip));
		#else
		this._eventClips.splice(this._eventClips.indexOf(clip), 1);
		#end
	}
	
	#if flash
	public function addEventClipList(clips:Vector<EventClip>):Void
	#else
	public function addEventClipList(clips:Array<EventClip>):Void
	#end
	{
		this._eventClipLists[this._eventClipLists.length] = clips;
	}
	
	#if flash
	public function hasEventClipList(clips:Vector<EventClip>):Bool
	#else
	public function hasEventClipList(clips:Array<EventClip>):Bool
	#end
	{
		return this._eventClipLists.indexOf(clips) != -1;
	}
	
	#if flash
	public function removeEventClipList(clips:Vector<EventClip>):Void
	#else
	public function removeEventClipList(clips:Array<EventClip>):Void
	#end
	{
		#if flash
		this._eventClipLists.removeAt(this._eventClipLists.indexOf(clips));
		#else
		this._eventClipLists.splice(this._eventClipLists.indexOf(clips), 1);
		#end
	}
	//\Event clips
	
	// Particles
	#if flash
	public function addBasicParticleList(particles:Vector<Particle>):Void
	#else
	public function addBasicParticleList(particles:Array<Particle>):Void
	#end
	{
		this._basicParticleLists[this._basicParticleLists.length] = particles;
	}
	
	#if flash
	public function hasBasicParticleList(particles:Vector<Particle>):Bool
	#else
	public function hasBasicParticleList(particles:Array<Particle>):Bool
	#end
	{
		return this._basicParticleLists.indexOf(particles) != -1;
	}
	
	#if flash
	public function removeBasicParticleList(particles:Vector<Particle>):Void
	#else
	public function removeBasicParticleList(particles:Array<Particle>):Void
	#end
	{
		#if flash
		this._basicParticleLists.removeAt(this._basicParticleLists.indexOf(particles));
		#else
		this._basicParticleLists.splice(this._basicParticleLists.indexOf(particles), 1);
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
	//\Particles
	
	public function addParticleSystem(system:ParticleSystem):Void
	{
		this._particleSystems[this._particleSystems.length] = system;
	}
	
	public function hasParticleSystem(system:ParticleSystem):Bool
	{
		return this._particleSystems.indexOf(system) != -1;
	}
	
	public function removeParticleSystem(system:ParticleSystem):Void
	{
		#if flash
		this._particleSystems.removeAt(this._particleSystems.indexOf(system));
		#else
		this._particleSystems.splice(this._particleSystems.indexOf(system), 1);
		#end
	}
	
	#if flash
	public function addParticleSystemList(systems:Vector<ParticleSystem>):Void
	#else
	public function addParticleSystemList(systems:Array<ParticleSystem>):Void
	#end
	{
		this._particleSystemList[this._particleSystemList.length] = systems;
	}
	
	#if flash
	public function hasParticleSystemList(systems:Vector<ParticleSystem>):Bool
	#else
	public function hasParticleSystemList(systems:Array<ParticleSystem>):Bool
	#end
	{
		return this._particleSystemList.indexOf(systems) != -1;
	}
	
	#if flash
	public function removeParticleSystemList(systems:Vector<ParticleSystem>):Void
	#else
	public function removeParticleSystemList(systems:Array<ParticleSystem>):Void
	#end
	{
		#if flash
		this._particleSystemList.removeAt(this._particleSystemList.indexOf(systems));
		#else
		this._particleSystemList.splice(this._particleSystemList.indexOf(systems), 1);
		#end
	}
	
	public function advanceTime(time:Float):Void
	{
		if (!this.animate) return;
		
		var count:Int;
		
		if (this._basicClips.length != 0) animateBasicClips(this._basicClips, time);
		count = this._basicClipLists.length;
		for (i in 0...count)
		{
			animateBasicClips(this._basicClipLists[i], time);
		}
		
		if (this._clips.length != 0) animateClips(this._clips, time);
		count = this._clipLists.length;
		for (i in 0...count)
		{
			animateClips(this._clipLists[i], time);
		}
		
		if (this._eventClips.length != 0) animateEventClips(this._eventClips, time);
		count = this._eventClipLists.length;
		for (i in 0...count)
		{
			animateEventClips(this._eventClipLists[i], time);
		}
		
		if (this._particleSystems.length != 0) advanceParticleSystems(this._particleSystems, time);
		count = this._particleSystemList.length;
		for (i in 0...count)
		{
			advanceParticleSystems(this._particleSystemList[i], time);
		}
		
		count = this._basicParticleLists.length;
		for (i in 0...count)
		{
			animateBasicParticles(this._basicParticleLists[i], time);
		}
		
		count = this._particleLists.length;
		for (i in 0...count)
		{
			animateParticles(this._particleLists[i], time);
		}
	}
	
	#if flash
	inline private function advanceParticleSystems(systems:Vector<ParticleSystem>, time:Float):Void
	#else
	inline private function advanceParticleSystems(systems:Array<ParticleSystem>, time:Float):Void
	#end
	{
		var count:Int = systems.length;
		for (i in 0...count)
		{
			systems[i].advanceTime(time);
		}
	}
	
	@:access(massive.display.Clip)
	#if flash
	inline private function animateBasicClips(clips:Vector<Clip>, time:Float):Void
	#else
	inline private function animateBasicClips(clips:Array<Clip>, time:Float):Void
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
					++clip.frameIndexBasic;
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
	
	@:access(massive.display.Clip)
	#if flash
	inline private function animateClips(clips:Vector<Clip>, time:Float):Void
	#else
	inline private function animateClips(clips:Array<Clip>, time:Float):Void
	#end
	{
		var clip:Clip;
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
					if (clip.frameTime < clip.frameTimingCurrent) break;
				}
				clip.frameIndex = frameIndex;
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
	
	@:access(massive.particle.Particle)
	#if flash
	inline private function animateBasicParticles(particles:Vector<Particle>, time:Float):Void
	#else
	inline private function animateBasicParticles(particles:Array<Particle>, time:Float):Void
	#end
	{
		var particle:Particle;
		var count:Int = particles.length;
		for (i in 0...count)
		{
			particle = particles[i];
			if (!particle.animate) continue;
			
			particle.frameTime += time * particle.frameDelta;
			if (particle.frameTime >= particle.frameTimingCurrent)
			{
				if (particle._frameIndex < particle.lastFrameIndex)
				{
					++particle.frameIndexBasic;
				}
				else if (particle.loop && (particle.numLoops == 0 || particle.loopCount < particle.numLoops))
				{
					particle.frameIndex = particle.animation.loopFrame;
					particle.frameTime -= particle.animation.loopDuration;
					++particle.loopCount;
				}
				else
				{
					particle.animationComplete = true;
					if (particle.animation.nextAnimationID != null)
					{
						particle.playWithID(particle.animation.nextAnimationID);
					}
					else if (particle._animationQueue.length != 0)
					{
						particle.playNextFromQueue();
					}
				}
			}
		}
	}
	
	@:access(massive.particle.Particle)
	#if flash
	inline private function animateParticles(particles:Vector<Particle>, time:Float):Void
	#else
	inline private function animateParticles(particles:Array<Particle>, time:Float):Void
	#end
	{
		var particle:Particle;
		var frameIndex:Int;
		var count:Int = particles.length;
		for (i in 0...count)
		{
			particle = particles[i];
			if (!particle.animate) continue;
			
			particle.frameTime += time * particle.frameDelta;
			if (particle.frameTime >= particle.frameTimingCurrent)
			{
				frameIndex = particle._frameIndex;
				while (true)
				{
					if (frameIndex < particle.lastFrameIndex)
					{
						++frameIndex;
						particle.frameTimingCurrent = particle._timings[frameIndex];
					}
					else if (particle.loop && (particle.numLoops == 0 || particle.loopCount < particle.numLoops))
					{
						frameIndex = particle.animation.loopFrame;
						++particle.loopCount;
						particle.frameTime -= particle.animation.loopDuration;
						particle.frameTimingCurrent = particle._timings[frameIndex];
					}
					else
					{
						particle.animationComplete = true;
						if (particle.animation.nextAnimationID != null)
						{
							particle.playWithID(particle.animation.nextAnimationID);
						}
						else if (particle._animationQueue.length != 0)
						{
							particle.playNextFromQueue();
						}
					}
					if (particle.frameTime < particle.frameTimingCurrent) break;
				}
				particle.frameIndex = frameIndex;
			}
		}
	}
	
}