package;

/**
 * ...
 * @author Matse
 */
class ClipType 
{

	static public inline var CLIP:String = "Clip";
	static public inline var CLIP_BASIC:String = "Clip (basic)";
	static public inline var EVENT_CLIP:String = "EventClip";
	
	static public function getValues():Array<String> { return [CLIP_BASIC, CLIP, EVENT_CLIP]; }
	
}