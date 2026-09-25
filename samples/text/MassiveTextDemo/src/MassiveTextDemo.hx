package;

import massive.display.Img;
import massive.display.ImgContainer;
import massive.display.MassiveDisplay;
import massive.text.GlyphLocation;
import massive.text.MassiveFont;
import massive.text.MassiveText;
import massive.text.Text;
import massive.text.TextAlign;
import massive.text.TextFormat;
import massive.text.TextOptions;
import massive.text.internal.TextLayoutResult;
import massive.text.lang.LangRules;
import massive.text.lang.LatinDefaultRules;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
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
	private var _options:TextOptions;
	private var _langRules:LangRules;
	
	private var _text:Text;
	private var _result:TextLayoutResult;

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		trace(this.stage.stageWidth);
		
		MassiveDisplay.init();
		
		this._font = new MassiveFont("mini");
		this._font.createFontStyle();
		MassiveText.registerFont(this._font);
		
		this._display = new MassiveDisplay(this._font.defaultStyle.texture);
		this._display.setTextureSmoothingAt(0, TextureSmoothing.NONE);
		addChild(this._display);
		
		this._container = new ImgContainer();
		this._display.addLayer(this._container);
		
		//this._format = new TextFormat("mini", "default", this._font.size * 2, 0xffffff, TextAlign.JUSTIFY);
		this._format = new TextFormat("mini", "default", this._font.size * 4, 0xffffff, TextAlign.JUSTIFY);
		
		this._options = new TextOptions();
		this._options.padding = 24;
		
		this._langRules = new LatinDefaultRules();
		
		var str:String;
		//str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
		//str += "\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?";
		//str = "But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born and I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure. To take a trivial example, which of us ever undertakes laborious physical exercise, except to obtain some advantage from it? But who has any right to find fault with a man who chooses to enjoy a pleasure that has no annoying consequences, or one who avoids a pain that produces no resultant pleasure?";
		//str += "\n\nOn the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish. In a free hour, when our power of choice is untrammelled and when nothing prevents our being able to do what we like best, every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims of duty or the obligations of business it will frequently occur that pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds in these matters to this principle of selection: he rejects pleasures to secure other greater pleasures, or else he endures pains to avoid worse pains.";
		
		//str = "over-confident master-builder ";
		//for (i in 0...20)
		//{
			//str += "over-confident master-builder ";
		//}
		str = 'Here is some text !{"format":{"color":"0xff0000"}, "animIn":{"id":"fadeIn"}, "animOut":{"id":"fadeOut"}}!and here is some text in red which will suddenly switch back to !{"format":{"color":"0xffffff"}}!white again and then go!{"format":{"color":"0xffff00"}}! yellow because why not... !{"format":{"color":"0x00ffff"}}!Or electric blue maybe ?';
		this._text = MassiveText.parseText(str);
		this._text.format = this._format;
		this._text.options = this._options;
		
		var textWidth:Int = this.stage.stageWidth;
		var textHeight:Int = this.stage.stageHeight;
		this._result = MassiveText.processText(textWidth, textHeight, this._text, this._langRules);
		this._result.getImages(this._display, this._container.datas);
		GlyphLocation.rechargePool();
		this._result.pool();
		
		//this._font.fillContainer(this._container, this.stage.stageWidth, this.stage.stageHeight, this._text, this._format, true);
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
		
		trace(this.stage.stageWidth);
		
		#if flash
		Img.toPoolVector(this._container.datas);
		#else
		Img.toPoolArray(this._container.datas);
		#end
		this._container.removeAllChildren();
		
		var textWidth:Int = this.stage.stageWidth;
		var textHeight:Int = this.stage.stageHeight;
		this._result = MassiveText.processText(textWidth, textHeight, this._text, this._langRules);
		this._result.getImages(this._display, this._container.datas);
		GlyphLocation.rechargePool();
		this._result.pool();
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