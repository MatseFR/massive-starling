package;

import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display3D.Context3DRenderMode;
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
		
		if (this.stage != null) start();
		else addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(event:openfl.events.Event):Void
	{
		removeEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
		
		start();
	}
	
	private function start():Void
	{
		this.stage.scaleMode = StageScaleMode.NO_SCALE;
		
		this._starling = new Starling(MassiveDemo, this.stage, null, null, Context3DRenderMode.AUTO, "auto");
		//this._starling.enableErrorChecking = Capabilities.isDebugger;
		this._starling.showStats = true;
		this._starling.skipUnchangedFrames = true;
		this._starling.supportBrowserZoom = true;
		this._starling.supportHighResolutions = false;
		this._starling.simulateMultitouch = false;
		
		this._starling.start();
	}
	
}
