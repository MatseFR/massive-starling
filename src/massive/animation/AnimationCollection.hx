package massive.animation;
#if flash
import openfl.Vector;
#end

/**
 * ...
 * @author Matse
 */
class AnimationCollection 
{
	static private var _POOL:Array<AnimationCollection> = new Array<AnimationCollection>();
	
	#if flash
	static public function fromPool(animations:Vector<Animation> = null):AnimationCollection
	#else
	static public function fromPool(animations:Array<Animation> = null):AnimationCollection
	#end
	{
		if (_POOL.length != 0) return _POOL.pop().setFromPool(animations);
		return new AnimationCollection(animations);
	}
	
	private var _animationMap:Map<String, Animation> = new Map<String, Animation>();
	
	#if flash
	public function new(animations:Vector<Animation> = null) 
	#else
	public function new(animations:Array<Animation> = null) 
	#end
	{
		if (animations != null) addList(animations);
	}
	
	public function clear():Void
	{
		this._animationMap.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	#if flash
	private function setFromPool(animations:Vector<Animation>):AnimationCollection
	#else
	private function setFromPool(animations:Array<Animation>):AnimationCollection
	#end
	{
		if (animations != null) addList(animations);
		return this;
	}
	
	public function add(animation:Animation):Void
	{
		this._animationMap.set(animation.id, animation);
	}
	
	#if flash
	public function addList(animations:Vector<Animation>):Void
	#else
	public function addList(animations:Array<Animation>):Void
	#end
	{
		var count:Int = animations.length;
		for (i in 0...count)
		{
			this._animationMap.set(animations[i].id, animations[i]);
		}
	}
	
	public function get(animationID:String):Animation
	{
		return this._animationMap.get(animationID);
	}
	
	public function remove(animation:Animation):Void
	{
		this._animationMap.remove(animation.id);
	}
	
	#if flash
	public function removeList(animations:Vector<Animation>):Void
	#else
	public function removeList(animations:Vector<Animation>):Void
	#end
	{
		var count:Int = animations.length;
		for (i in 0...count)
		{
			this._animationMap.remove(animations[i].id);
		}
	}
	
	public function removeWithID(animationID:String):Void
	{
		this._animationMap.remove(animationID);
	}
	
}