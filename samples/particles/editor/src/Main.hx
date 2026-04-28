package;

import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display3D.Context3DRenderMode;
import openfl.events.Event;
import starling.core.Starling;

/**
 * ...
 * @author Matse
 */
class Main extends Sprite 
{
	private var _starling:Starling;
	
	public function new() 
	{
		super();
		
		if (stage != null) start();
		else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(event:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		start();
	}
	
	private function start():Void
	{
		_starling = new Starling(ParticleEditor, stage, null, null, Context3DRenderMode.AUTO, "auto");
		//_starling.enableErrorChecking = true;
		_starling.showStats = true;
		_starling.skipUnchangedFrames = true;
		_starling.supportBrowserZoom = true;
		_starling.supportHighResolutions = false;
		_starling.simulateMultitouch = false;
		
		_starling.start();
	}

}
