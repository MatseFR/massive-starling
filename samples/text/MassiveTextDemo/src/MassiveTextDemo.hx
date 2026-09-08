package;

import massive.display.Img;
import massive.display.ImgContainer;
import massive.display.MassiveDisplay;
import massive.text.MassiveFont;
import massive.text.TextAlign;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.text.TextFormat;
import starling.textures.TextureSmoothing;

/**
 * ...
 * @author Matse
 */
class MassiveTextDemo extends Sprite 
{
	private var _display:MassiveDisplay;
	private var _container:ImgContainer;
	private var _font:MassiveFont;
	private var _format:TextFormat;
	
	private var _text:String;

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		MassiveDisplay.init();
		
		this._font = new MassiveFont();
		this._font.padding = 24;
		
		this._display = new MassiveDisplay(this._font.texture);
		this._display.setTextureSmoothingAt(0, TextureSmoothing.NONE);
		addChild(this._display);
		
		this._container = new ImgContainer();
		this._display.addLayer(this._container);
		
		this._format = new TextFormat("mini", this._font.size * 2, 0xffffff, TextAlign.JUSTIFY);
		
		this._text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?";
		this._font.fillContainer(this._container, this.stage.stageWidth, this.stage.stageHeight, this._text, this._format, true);
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
		
		#if flash
		Img.toPoolVector(this._container.datas);
		#else
		Img.toPoolArray(this._container.datas);
		#end
		this._container.removeAllChildren();
		this._font.fillContainer(this._container, this.stage.stageWidth, this.stage.stageHeight, this._text, this._format, true);
	}

	private function updateViewPort(width:Int, height:Int):Void 
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		this.stage.stageWidth  = Std.int(width  / scale);
		this.stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width  = this.stage.stageWidth  * scale;
		current.viewPort.height = this.stage.stageHeight * scale;
	}
	
}