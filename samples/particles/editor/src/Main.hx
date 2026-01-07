package;

import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display3D.Context3DRenderMode;
import starling.core.Starling;
import starling.events.Event;

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
		else addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(event:Dynamic):Void
	{
		removeEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		start();
	}
	
	private function start():Void
	{
		_starling = new Starling(ParticleEditor, stage, null, null, Context3DRenderMode.AUTO, "auto");
		//_starling.enableErrorChecking = Capabilities.isDebugger;
		_starling.showStats = true;//Capabilities.isDebugger;
		_starling.skipUnchangedFrames = true;
		_starling.supportBrowserZoom = true;
		_starling.supportHighResolutions = false;
		_starling.simulateMultitouch = false;
		
		_starling.start();
	}

}
