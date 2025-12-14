package display;

import hexagon.camera.HexCamera;
import starling.display.Quad;
import starling.display.Sprite;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class CameraDebugUI extends Sprite 
{
	private var background:Quad;
	private var textSprite:Sprite;
	
	private var xLabel:TextField;
	private var xValue:TextField;
	private var yLabel:TextField;
	private var yValue:TextField;
	
	private var qLeftLabel:TextField;
	private var qLeftValue:TextField;
	private var qRightLabel:TextField;
	private var qRightValue:TextField;
	private var rTopLabel:TextField;
	private var rTopValue:TextField;
	private var rBottomLabel:TextField;
	private var rBottomValue:TextField;
	
	private var mapXminLabel:TextField;
	private var mapXminValue:TextField;
	private var mapXmaxLabel:TextField;
	private var mapXmaxValue:TextField;
	private var mapYminLabel:TextField;
	private var mapYminValue:TextField;
	private var mapYmaxLabel:TextField;
	private var mapYmaxValue:TextField;

	public function new() 
	{
		super();
		
		var tY:Float = 0;
		var gap:Float = 2;
		var spacing:Float;
		
		this.background = new Quad(10, 10, 0x000000);
		this.background.alpha = 0.5;
		addChild(this.background);
		
		this.textSprite = new Sprite();
		addChild(this.textSprite);
		
		this.xLabel = createLabel("x");
		this.xLabel.y = tY;
		this.textSprite.addChild(this.xLabel);
		
		this.xValue = createValue();
		this.xValue.x = this.xLabel.width + gap;
		this.xValue.y = tY;
		this.textSprite.addChild(this.xValue);
		
		spacing = this.xLabel.height + gap;
		
		tY += spacing;
		this.yLabel = createLabel("y");
		this.yLabel.y = tY;
		this.textSprite.addChild(this.yLabel);
		
		this.yValue = createValue();
		this.yValue.x = this.yLabel.width + gap;
		this.yValue.y = tY;
		this.textSprite.addChild(this.yValue);
		
		tY += spacing;
		this.qLeftLabel = createLabel("qLeft");
		this.qLeftLabel.y = tY;
		this.textSprite.addChild(this.qLeftLabel);
		
		this.qLeftValue = createValue();
		this.qLeftValue.x = this.qLeftLabel.width + gap;
		this.qLeftValue.y = tY;
		this.textSprite.addChild(this.qLeftValue);
		
		tY += spacing;
		this.qRightLabel = createLabel("qRight");
		this.qRightLabel.y = tY;
		this.textSprite.addChild(this.qRightLabel);
		
		this.qRightValue = createValue();
		this.qRightValue.x = this.qRightLabel.width + gap;
		this.qRightValue.y = tY;
		this.textSprite.addChild(this.qRightValue);
		
		tY += spacing;
		this.rTopLabel = createLabel("rTop");
		this.rTopLabel.y = tY;
		this.textSprite.addChild(this.rTopLabel);
		
		this.rTopValue = createValue();
		this.rTopValue.x = this.rTopLabel.width + gap;
		this.rTopValue.y = tY;
		this.textSprite.addChild(this.rTopValue);
		
		tY += spacing;
		this.rBottomLabel = createLabel("rBottom");
		this.rBottomLabel.y = tY;
		this.textSprite.addChild(this.rBottomLabel);
		
		this.rBottomValue = createValue();
		this.rBottomValue.x = this.rBottomLabel.width + gap;
		this.rBottomValue.y = tY;
		this.textSprite.addChild(this.rBottomValue);
		
		tY += spacing;
		this.mapXminLabel = createLabel("map x min");
		this.mapXminLabel.y = tY;
		this.textSprite.addChild(this.mapXminLabel);
		
		this.mapXminValue = createValue();
		this.mapXminValue.x = this.mapXminLabel.width + gap;
		this.mapXminValue.y = tY;
		this.textSprite.addChild(this.mapXminValue);
		
		tY += spacing;
		this.mapXmaxLabel = createLabel("map x max");
		this.mapXmaxLabel.y = tY;
		this.textSprite.addChild(this.mapXmaxLabel);
		
		this.mapXmaxValue = createValue();
		this.mapXmaxValue.x = this.mapXmaxLabel.width + gap;
		this.mapXmaxValue.y = tY;
		this.textSprite.addChild(this.mapXmaxValue);
		
		tY += spacing;
		this.mapYminLabel = createLabel("map y min");
		this.mapYminLabel.y = tY;
		this.textSprite.addChild(this.mapYminLabel);
		
		this.mapYminValue = createValue();
		this.mapYminValue.x = this.mapYminLabel.width + gap;
		this.mapYminValue.y = tY;
		this.textSprite.addChild(this.mapYminValue);
		
		tY += spacing;
		this.mapYmaxLabel = createLabel("map y max");
		this.mapYmaxLabel.y = tY;
		this.textSprite.addChild(this.mapYmaxLabel);
		
		this.mapYmaxValue = createValue();
		this.mapYmaxValue.x = this.mapYmaxLabel.width + gap;
		this.mapYmaxValue.y = tY;
		this.textSprite.addChild(this.mapYmaxValue);
	}
	
	public function update(camera:HexCamera):Void
	{
		this.xValue.text = Std.string(camera.x);
		this.yValue.text = Std.string(camera.y);
		
		this.qLeftValue.text = Std.string(camera.qLeft);
		this.qRightValue.text = Std.string(camera.qRight);
		this.rTopValue.text = Std.string(camera.rTop);
		this.rBottomValue.text = Std.string(camera.rBottom);
		
		this.mapXminValue.text = Std.string(camera.mapXmin);
		this.mapXmaxValue.text = Std.string(camera.mapXmax);
		this.mapYminValue.text = Std.string(camera.mapYmin);
		this.mapYmaxValue.text = Std.string(camera.mapYmax);
		
		this.background.width = this.textSprite.width;
		this.background.height = this.textSprite.height;
	}
	
	private function createLabel(text:String = ""):TextField
	{
		var tf:TextField = new TextField(80, 0, text);
		tf.format.color = 0xffffff;
		tf.format.horizontalAlign = Align.RIGHT;
		tf.autoSize = TextFieldAutoSize.VERTICAL;
		return tf;
	}
	
	private function createValue():TextField
	{
		var tf:TextField = new TextField(0, 0);
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		return tf;
	}
	
}