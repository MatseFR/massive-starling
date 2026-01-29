package;

import demo.DemoMode;
import demo.HexTemplate;
import demo.scene.CameraScene;
import demo.scene.Scene;
import hexagon.Hex;
import hexagon.HexMode;
import hexagon.definition.HexDefinition;
import hexagon.definition.HexDefinitionFlat;
import hexagon.definition.HexDefinitionPointy;
import hexagon.grid.HexGrid;
import massive.data.Frame;
import massive.data.ImageData;
import openfl.Vector;
import openfl.geom.Point;
import openfl.system.Capabilities;
import openfl.utils.Assets;
import starling.assets.AssetManager;
import starling.core.Starling;
import starling.display.Button;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.textures.ConcreteTexture;
import starling.textures.RenderTexture;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.utils.Align;
import starling.utils.Pool;

/**
 * ...
 * @author Matse
 */
class MassiveHexGridDemo extends Sprite 
{
	public var assetManager:AssetManager;
	
	public var templateNames:Array<String> = ["dirt", "grass", "rock", "sand", "trees"];
	public var templateCosts:Map<String, Int> = ["dirt" => 3, "grass" => 1, "rock" =>-1, "sand" => 5, "trees" => 2];
	public var templateBlockLoS:Map<String, Bool> = ["dirt" => false, "grass" => false, "rock" => true, "sand" => false, "trees" => false];
	public var templateTraversable:Map<String, Bool> = ["dirt" => true, "grass" => true, "rock" => false, "sand" => true, "trees" => true];
	
	public var flatAtlas:TextureAtlas;
	public var flatDefinition:HexDefinitionFlat;
	public var flatTemplates:Map<String, HexTemplate> = new Map<String, HexTemplate>();
	public var flatSelectionFrames:#if flash Vector<Frame> #else Array<Frame> #end;
	#if flash
	public var flatMoveCostFrames:Map<Int, Vector<Frame>> = new Map<Int, Vector<Frame>>();
	#else
	public var flatMoveCostFrames:Map<Int, Array<Frame>> = new Map<Int, Array<Frame>>();
	#end
	
	public var pointyAtlas:TextureAtlas;
	public var pointyDefinition:HexDefinitionPointy;
	public var pointyTemplates:Map<String, HexTemplate> = new Map<String, HexTemplate>();
	public var pointySelectionFrames:#if flash Vector<Frame> #else Array<Frame> #end;
	#if flash
	public var pointyMoveCostFrames:Map<Int, Vector<Frame>> = new Map<Int, Vector<Frame>>();
	#else
	public var pointyMoveCostFrames:Map<Int, Array<Frame>> = new Map<Int, Array<Frame>>();
	#end
	
	private var atlas:TextureAtlas;
	private var definition:HexDefinition;
	private var templates:Map<String, HexTemplate>;
	private var selectionFrames:#if flash Vector<Frame> #else Array<Frame> #end;
	private var hexMode:String;
	private var numRows:Int = 30;
	private var numColumns:Int = 30;
	private var wrapAroundQ:Bool = true;
	private var wrapAroundR:Bool = true;
	
	private var _sceneList:Array<Scene>;
	
	private var menuSprite:Sprite;
	private var gridSizeButtons:Array<Button> = new Array<Button>();
	private var gridMenuSprite:Sprite;
	private var demoModeButtons:Array<Button> = new Array<Button>();
	private var allGridbuttons:Array<Button> = new Array<Button>();
	private var buttonTextureON:RenderTexture;
	private var buttonTextureOFF:RenderTexture;
	private var mediumButtonTextureON:RenderTexture;
	private var mediumButtonTextureOFF:RenderTexture;
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		this.assetManager = new AssetManager();
		this.assetManager.verbose = Capabilities.isDebugger;
		this.assetManager.enqueue([
			Assets.getPath("img/hex_flat.png"),
			Assets.getPath("img/hex_flat.xml"),
			Assets.getPath("img/hex_pointy.png"),
			Assets.getPath("img/hex_pointy.xml")
		]);
		this.assetManager.loadQueue(assetsLoaded);
	}
	
	private function assetsLoaded():Void
	{
		var template:HexTemplate;
		var texture:Texture;
		var textures:Vector<Texture>;
		var alignH:String = Align.CENTER;
		var alignV:String = Align.CENTER;
		
		this.flatAtlas = assetManager.getTextureAtlas("hex_flat");
		texture = this.flatAtlas.getTexture("grass");
		this.flatDefinition = new HexDefinitionFlat();
		this.flatDefinition.fromDimensions(texture.width, texture.height);
		textures = this.flatAtlas.getTextures("selection");
		this.flatSelectionFrames = Frame.fromTextureVectorWithAlign(textures, alignH, alignV);
		
		for (i in 1...6)
		{
			textures = this.flatAtlas.getTextures("cost_" + i);
			if (textures.length != 0)
			{
				this.flatMoveCostFrames[i] = Frame.fromTextureVectorWithAlign(textures, alignH, alignV);
			}
		}
		
		this.pointyAtlas = assetManager.getTextureAtlas("hex_pointy");
		texture = this.pointyAtlas.getTexture("grass");
		this.pointyDefinition = new HexDefinitionPointy();
		this.pointyDefinition.fromDimensions(texture.width, texture.height);
		textures = this.pointyAtlas.getTextures("selection");
		this.pointySelectionFrames = Frame.fromTextureVectorWithAlign(textures, alignH, alignV);
		
		for (i in 1...6)
		{
			textures = this.pointyAtlas.getTextures("cost_" + i);
			if (textures.length != 0)
			{
				this.pointyMoveCostFrames[i] = Frame.fromTextureVectorWithAlign(textures, alignH, alignV);
			}
		}
		
		for (name in this.templateNames)
		{
			// template for flat orientation
			template = new HexTemplate();
			template.cost = this.templateCosts[name];
			template.isBlockingLoS = this.templateBlockLoS[name];
			template.isTraversable = this.templateTraversable[name];
			textures = this.flatAtlas.getTextures(name);
			template.frames = Frame.fromTextureVectorWithAlign(textures, alignH, alignV);
			template.costFrames = this.flatMoveCostFrames[template.cost];
			this.flatTemplates[name] = template;
			
			// template for pointy orientation
			template = new HexTemplate();
			template.cost = this.templateCosts[name];
			template.isBlockingLoS = this.templateBlockLoS[name];
			template.isTraversable = this.templateTraversable[name];
			textures = this.pointyAtlas.getTextures(name);
			template.frames = Frame.fromTextureVectorWithAlign(textures, alignH, alignV);
			template.costFrames = this.pointyMoveCostFrames[template.cost];
			this.pointyTemplates[name] = template;
		}
		
		var colorUP:Int = 0xcccccc;
		var colorOVER:Int = 0xffffff;
		var quad:Quad = new Quad(300, 24);
		var mediumQuad:Quad = new Quad(150, 24);
		
		quad.color = colorUP;
		this.buttonTextureOFF = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		this.buttonTextureOFF.draw(quad);
		this.buttonTextureOFF.root.onRestore = function(tex:ConcreteTexture):Void
		{
			quad.color = colorUP;
			this.buttonTextureOFF.clear();
			this.buttonTextureOFF.draw(quad);
		}
		
		quad.color = colorOVER;
		this.buttonTextureON = new RenderTexture(Std.int(quad.width), Std.int(quad.height));
		this.buttonTextureON.draw(quad);
		this.buttonTextureON.root.onRestore = function(tex:ConcreteTexture):Void
		{
			quad.color = colorOVER;
			this.buttonTextureON.clear();
			this.buttonTextureON.draw(quad);
		}
		
		mediumQuad.color = colorUP;
		this.mediumButtonTextureOFF = new RenderTexture(Std.int(mediumQuad.width), Std.int(mediumQuad.height));
		this.mediumButtonTextureOFF.draw(mediumQuad);
		this.mediumButtonTextureOFF.root.onRestore = function(tex:ConcreteTexture):Void
		{
			mediumQuad.color = colorUP;
			this.mediumButtonTextureOFF.clear();
			this.mediumButtonTextureOFF.draw(mediumQuad);
		}
		
		mediumQuad.color = colorOVER;
		this.mediumButtonTextureON = new RenderTexture(Std.int(mediumQuad.width), Std.int(mediumQuad.height));
		this.mediumButtonTextureON.draw(mediumQuad);
		this.mediumButtonTextureON.root.onRestore = function(tex:ConcreteTexture):Void
		{
			mediumQuad.color = colorOVER;
			this.mediumButtonTextureON.clear();
			this.mediumButtonTextureON.draw(mediumQuad);
		}
		
		var btn:Button;
		var gap:Float = 8;
		var tY:Float = 0;
		
		// DEMO MENU
		this.menuSprite = new Sprite();
		
		var tf:TextField = new TextField(0, 0, "warning : big grids can take several seconds to create");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		
		tY += tf.height + gap;
		btn = new Button(this.numColumns == 30 && this.numRows == 30 ? this.buttonTextureON : this.buttonTextureOFF, "30x30", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_size);
		this.gridSizeButtons.push(btn);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.numColumns == 100 && this.numRows == 100 ? this.buttonTextureON : this.buttonTextureOFF, "100x100", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_size);
		this.gridSizeButtons.push(btn);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.numColumns == 500 && this.numRows == 500 ? this.buttonTextureON : this.buttonTextureOFF, "500x500", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_size);
		this.gridSizeButtons.push(btn);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.numColumns == 1000 && this.numRows == 1000 ? this.buttonTextureON : this.buttonTextureOFF, "1000x1000", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_size);
		this.gridSizeButtons.push(btn);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap * 6;
		
		btn = new Button(this.buttonTextureOFF, "Flat EvenQ grid", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, flat_evenQ);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "Flat OddQ grid", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, flat_oddQ);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "Pointy EvenR grid", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, pointy_evenR);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.buttonTextureOFF, "Pointy OddR grid", null, this.buttonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, pointy_oddR);
		this.menuSprite.addChild(btn);
		
		tY += btn.height + gap;
		var tf:TextField = new TextField(0, 0, "terrain assets from www.kenney.nl");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.buttonTextureOFF.width - tf.width) / 2;
		this.menuSprite.addChild(tf);
		
		// GRID MENU
		tY = 0;
		this.gridMenuSprite = new Sprite();
		
		btn = new Button(this.mediumButtonTextureOFF, "Menu", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, backToMenu);
		this.gridMenuSprite.addChild(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.mediumButtonTextureOFF, "Pathfinding", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_pathfinding);
		this.gridMenuSprite.addChild(btn);
		this.demoModeButtons.push(btn);
		this.allGridbuttons.push(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.mediumButtonTextureOFF, "Range", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_range);
		this.gridMenuSprite.addChild(btn);
		this.demoModeButtons.push(btn);
		this.allGridbuttons.push(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.mediumButtonTextureOFF, "Ring", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_ring);
		this.gridMenuSprite.addChild(btn);
		this.demoModeButtons.push(btn);
		this.allGridbuttons.push(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.mediumButtonTextureOFF, "Line", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_line);
		this.gridMenuSprite.addChild(btn);
		this.demoModeButtons.push(btn);
		this.allGridbuttons.push(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.mediumButtonTextureOFF, "Spiral 2", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_spiral);
		this.gridMenuSprite.addChild(btn);
		this.demoModeButtons.push(btn);
		this.allGridbuttons.push(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.mediumButtonTextureOFF, "Line of Sight 8", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_los);
		this.gridMenuSprite.addChild(btn);
		this.demoModeButtons.push(btn);
		this.allGridbuttons.push(btn);
		
		tY += btn.height + gap;
		btn = new Button(this.mediumButtonTextureOFF, "Move costs", null, this.mediumButtonTextureON);
		btn.y = tY;
		btn.addEventListener(Event.TRIGGERED, grid_moveCosts);
		this.gridMenuSprite.addChild(btn);
		this.allGridbuttons.push(btn);
		
		tY += btn.height + gap;
		var tf:TextField = new TextField(0, 0, "click hex to select");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.mediumButtonTextureOFF.width - tf.width) / 2;
		this.gridMenuSprite.addChild(tf);
		
		tY += tf.height + gap;
		var tf:TextField = new TextField(0, 0, "arrow keys\nor WASD\nor ZQSD\nto scroll");
		tf.format.color = 0xffffff;
		tf.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
		tf.y = tY;
		tf.x = (this.mediumButtonTextureOFF.width - tf.width) / 2;
		this.gridMenuSprite.addChild(tf);
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
		
		updateUIPositions();
		showMenu();
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
		updateUIPositions();
		
		if (this._sceneList != null)
		{
			for (scene in this._sceneList)
			{
				scene.stageResize(stage.stageWidth, stage.stageHeight);
			}
		}
	}
	
	private function updateViewPort(width:Int, height:Int):Void
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		stage.stageWidth = Std.int(width / scale);
		stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width = width;
		current.viewPort.height = height;
	}
	
	private function updateUIPositions():Void
	{
		this.menuSprite.x = (stage.stageWidth - this.menuSprite.width) / 2;
		this.menuSprite.y = (stage.stageHeight - this.menuSprite.height) / 2;
		
		var spacing:Float = 8;
		this.gridMenuSprite.x = stage.stageWidth - this.gridMenuSprite.width - spacing;
		this.gridMenuSprite.y = spacing;
	}
	
	private function showMenu():Void
	{
		addChild(this.menuSprite);
	}
	
	private function hideMenu():Void
	{
		removeChild(this.menuSprite);
	}
	
	private function showSceneList(scenes:Array<Scene>):Void
	{
		hideMenu();
		
		this._sceneList = scenes;
		for (scene in this._sceneList)
		{
			addChild(scene);
		}
		
		addChild(this.gridMenuSprite);
	}
	
	private function backToMenu(evt:Event):Void
	{
		for (scene in this._sceneList)
		{
			scene.removeFromParent(true);
		}
		this._sceneList = null;
		
		unselectAllGridButtons();
		this.gridMenuSprite.removeFromParent();
		
		showMenu();
	}
	
	private function grid_size(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		for (otherBtn in this.gridSizeButtons)
		{
			if (otherBtn == btn) continue;
			otherBtn.upState = this.buttonTextureOFF;
		}
		
		var str:String = btn.text;
		var index:Int = str.indexOf("x");
		this.numColumns = Std.parseInt(str.substring(0, index));
		this.numRows = Std.parseInt(str.substring(index + 1, str.length));
		btn.upState = this.buttonTextureON;
	}
	
	private function flat_evenQ():Void
	{
		this.hexMode = HexMode.FLAT_EVEN_Q;
		this.atlas = this.flatAtlas;
		this.definition = this.flatDefinition;
		this.templates = this.flatTemplates;
		this.selectionFrames = this.flatSelectionFrames;
		
		startScene();
	}
	
	private function flat_oddQ():Void
	{
		this.hexMode = HexMode.FLAT_ODD_Q;
		this.atlas = this.flatAtlas;
		this.definition = this.flatDefinition;
		this.templates = this.flatTemplates;
		this.selectionFrames = this.flatSelectionFrames;
		
		startScene();
	}
	
	private function pointy_evenR():Void
	{
		this.hexMode = HexMode.POINTY_EVEN_R;
		this.atlas = this.pointyAtlas;
		this.definition = this.pointyDefinition;
		this.templates = this.pointyTemplates;
		this.selectionFrames = this.pointySelectionFrames;
		
		startScene();
	}
	
	private function pointy_oddR():Void
	{
		this.hexMode = HexMode.POINTY_ODD_R;
		this.atlas = this.pointyAtlas;
		this.definition = this.pointyDefinition;
		this.templates = this.pointyTemplates;
		this.selectionFrames = this.pointySelectionFrames;
		
		startScene();
	}
	
	private function startScene():Void
	{
		var grid:HexGrid = HexGrid.fromHexMode(this.hexMode);
		grid.build(this.numColumns, this.numRows, false, this.wrapAroundQ, this.wrapAroundR);
		
		var templateName:String;
		var imgData:ImageData;
		var pt:Point = Pool.getPoint();
		var hex:Hex;
		var hexes:Array<Hex> = grid.allHexes;
		var count:Int = hexes.length;
		for (i in 0...count)
		{
			hex = hexes[i];
			grid.hexToPixel(hex, this.definition, pt);
			imgData = new ImageData();
			hex.x = imgData.x = pt.x;
			hex.y = imgData.y = pt.y;
			hex.imageData = imgData;
			templateName = this.templateNames[Std.random(this.templateNames.length)];
			assignHexTemplate(hex, this.templates[templateName]);
		}
		Pool.putPoint(pt);
		
		var scene:CameraScene = new CameraScene();
		scene.grid = grid;
		scene.hexDefinition = this.definition;
		scene.atlasTexture = this.atlas.texture;
		scene.selectionFrames = this.selectionFrames;
		
		showSceneList([scene]);
	}
	
	private function assignHexTemplate(hex:Hex, template:HexTemplate):Void
	{
		hex.cost = template.cost;
		hex.isBlockingLoS = template.isBlockingLoS;
		hex.isTraversable = template.isTraversable;
		hex.imageData.setFrames(template.frames);
		
		if (template.costFrames != null)
		{
			hex.costImageData = new ImageData();
			hex.costImageData.x = hex.x;
			hex.costImageData.y = hex.y;
			hex.costImageData.setFrames(template.costFrames);
		}
	}
	
	private function unselectDemoModeButtons():Void
	{
		for (btn in demoModeButtons)
		{
			btn.upState = this.mediumButtonTextureOFF;
		}
	}
	
	private function unselectAllGridButtons():Void
	{
		for (btn in allGridbuttons)
		{
			btn.upState = this.mediumButtonTextureOFF;
		}
	}
	
	private function grid_pathfinding(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		if (btn.upState == this.mediumButtonTextureOFF)
		{
			unselectDemoModeButtons();
			btn.upState = this.mediumButtonTextureON;
			this._sceneList[0].setMode(DemoMode.PATHFINDING);
		}
		else
		{
			btn.upState = this.mediumButtonTextureOFF;
			this._sceneList[0].setMode(DemoMode.NONE);
		}
	}
	
	private function grid_line(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		if (btn.upState == this.mediumButtonTextureOFF)
		{
			unselectDemoModeButtons();
			btn.upState = this.mediumButtonTextureON;
			this._sceneList[0].setMode(DemoMode.LINE);
		}
		else
		{
			btn.upState = this.mediumButtonTextureOFF;
			this._sceneList[0].setMode(DemoMode.NONE);
		}
	}
	
	private function grid_los(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		if (btn.upState == this.mediumButtonTextureOFF)
		{
			unselectDemoModeButtons();
			btn.upState = this.mediumButtonTextureON;
			this._sceneList[0].setMode(DemoMode.LOS);
		}
		else
		{
			btn.upState = this.mediumButtonTextureOFF;
			this._sceneList[0].setMode(DemoMode.NONE);
		}
	}
	
	private function grid_range(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		if (btn.upState == this.mediumButtonTextureOFF)
		{
			unselectDemoModeButtons();
			btn.upState = this.mediumButtonTextureON;
			this._sceneList[0].setMode(DemoMode.RANGE);
		}
		else
		{
			btn.upState = this.mediumButtonTextureOFF;
			this._sceneList[0].setMode(DemoMode.NONE);
		}
	}
	
	private function grid_ring(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		if (btn.upState == this.mediumButtonTextureOFF)
		{
			unselectDemoModeButtons();
			btn.upState = this.mediumButtonTextureON;
			this._sceneList[0].setMode(DemoMode.RING);
		}
		else
		{
			btn.upState = this.mediumButtonTextureOFF;
			this._sceneList[0].setMode(DemoMode.NONE);
		}
	}
	
	private function grid_spiral(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		if (btn.upState == this.mediumButtonTextureOFF)
		{
			unselectDemoModeButtons();
			btn.upState = this.mediumButtonTextureON;
			this._sceneList[0].setMode(DemoMode.SPIRAL);
		}
		else
		{
			btn.upState = this.mediumButtonTextureOFF;
			this._sceneList[0].setMode(DemoMode.NONE);
		}
	}
	
	private function grid_moveCosts(evt:Event):Void
	{
		var btn:Button = cast evt.target;
		if (btn.upState == this.mediumButtonTextureOFF)
		{
			btn.upState = this.mediumButtonTextureON;
			this._sceneList[0].toggleMoveCosts(true);
		}
		else
		{
			btn.upState = this.mediumButtonTextureOFF;
			this._sceneList[0].toggleMoveCosts(false);
		}
	}
	
}