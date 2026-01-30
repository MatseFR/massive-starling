package demo.scene;
import display.CameraDebugUI;
import hexagon.Hex;
import hexagon.camera.HexCamera;
import hexagon.definition.HexDefinition;
import hexagon.grid.HexGrid;
import hexagon.path.HexPathFinder;
import massive.data.Frame;
import massive.data.ImageData;
import massive.display.MassiveDisplay;
import massive.display.ImageLayer;
#if flash
import openfl.Vector;
#end
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.Pool;

/**
 * ...
 * @author Matse
 */
class CameraScene extends Scene implements IAnimatable
{
	public var atlasTexture:Texture;
	public var grid:HexGrid;
	public var hexDefinition:HexDefinition;
	public var selectionFrames:#if flash Vector<Frame> #else Array<Frame>#end;
	public var viewRatio:Float = 0.75;
	
	private var _pathFinder:HexPathFinder;
	
	private var _camera:HexCamera;
	private var _cameraDebug:CameraDebugUI;
	private var _display:MassiveDisplay;
	private var _hexLayer:ImageLayer;
	private var _costLayer:ImageLayer;
	private var _selectionLayer:ImageLayer;
	private var _rolloverLayer:ImageLayer;
	private var _touchQuad:Quad;
	
	private var _rolloverHex:Hex;
	private var _rolloverImage:ImageData;
	private var _selectedHex:Hex;
	private var _selectedImage:ImageData;
	private var _selectionHexList:Array<Hex> = new Array<Hex>();
	private var _selectionImageList:Array<ImageData> = new Array<ImageData>();
	
	private var _hexList:Array<Hex> = new Array<Hex>();
	#if flash
	private var _hexDataList:Vector<ImageData> = new Vector<ImageData>();
	private var _costDataList:Vector<ImageData> = new Vector<ImageData>();
	#else
	private var _hexDataList:Array<ImageData> = new Array<ImageData>();
	private var _costDataList:Array<ImageData> = new Array<ImageData>();
	#end
	
	private var _keyPressed:Map<UInt, Bool> = new Map<UInt, Bool>();
	private var _touchID:Int = -1;
	
	private var _selectFunction:Hex->Void;
	private var _selectPostFunction:Hex->Void;
	private var _rolloverFunction:Hex->Void;

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	override public function dispose():Void 
	{
		if (this._pathFinder != null)
		{
			this._pathFinder.dispose();
			this._pathFinder = null;
		}
		
		super.dispose();
	}
	
	private function addedToStageHandler(evt:Event):Void
	{
		var stageWidth:Float = this.stage.stageWidth;
		var stageHeight:Float = this.stage.stageHeight;
		
		this._pathFinder = new HexPathFinder();
		this._pathFinder.grid = this.grid;
		
		this._touchQuad = new Quad(stageWidth, stageHeight, 0x000000);
		addChild(this._touchQuad);
		this._touchQuad.addEventListener(TouchEvent.TOUCH, onTouch);
		
		_display = new MassiveDisplay(this.atlasTexture);
		this._display.textureSmoothing = TextureSmoothing.TRILINEAR;
		addChild(this._display);
		
		this._hexLayer = new ImageLayer(this._hexDataList);
		this._display.addLayer(this._hexLayer);
		
		this._costLayer = new ImageLayer(this._costDataList);
		this._costLayer.visible = false;
		this._display.addLayer(this._costLayer);
		
		this._selectionLayer = new ImageLayer();
		this._display.addLayer(this._selectionLayer);
		
		this._rolloverLayer = new ImageLayer();
		this._display.addLayer(this._rolloverLayer);
		
		this._rolloverImage = new ImageData();
		this._rolloverImage.green = 0.75;
		this._rolloverImage.blue = 0;
		this._rolloverImage.setFrames(this.selectionFrames);
		this._rolloverLayer.addImage(this._rolloverImage);
		
		this._selectedImage = new ImageData();
		this._selectedImage.red = 0;
		this._selectedImage.green = 0.25;
		this._selectedImage.setFrames(this.selectionFrames);
		this._selectedImage.visible = false;
		this._rolloverLayer.addImage(this._selectedImage);
		
		this._camera = new HexCamera();
		this._camera.width = stageWidth * this.viewRatio;
		this._camera.height = stageHeight * this.viewRatio;
		this._camera.init(this.grid, this.hexDefinition);
		
		this._display.x = (stageWidth - this._camera.width) / 2 + this._camera.displayOffsetX;
		this._display.y = (stageHeight - this._camera.height) / 2 + this._camera.displayOffsetY;
		
		this._cameraDebug = new CameraDebugUI();
		this._cameraDebug.x = 8;
		this._cameraDebug.y = stageHeight - this._cameraDebug.height - 8;
		addChild(this._cameraDebug);
		
		Starling.currentJuggler.add(this);
		
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
		
		//this.stage.starling.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
		setMode(DemoMode.NONE);
	}
	
	override public function stageResize(width:Float, height:Float):Void 
	{
		this._camera.width = width * this.viewRatio;
		this._camera.height = height * this.viewRatio;
		
		this._display.x = (width - this._camera.width) / 2 + this._camera.displayOffsetX;
		this._display.y = (height - this._camera.height) / 2 + this._camera.displayOffsetY;
		
		this._touchQuad.readjustSize(width, height);
		
		this._cameraDebug.y = height - this._cameraDebug.height - 8;
		this._cameraDebug.update(this._camera);
		
		super.stageResize(width, height);
	}
	
	public function advanceTime(time:Float):Void
	{
		var speed:Float = 5;
		
		if (this._keyPressed[Keyboard.LEFT] || this._keyPressed[Keyboard.Q] || this._keyPressed[Keyboard.A])
		{
			this._camera.x -= speed;
		}
		
		if (this._keyPressed[Keyboard.RIGHT] || this._keyPressed[Keyboard.D])
		{
			this._camera.x += speed;
		}
		
		if (this._keyPressed[Keyboard.UP] || this._keyPressed[Keyboard.Z] || this._keyPressed[Keyboard.W])
		{
			this._camera.y -= speed;
		}
		
		if (this._keyPressed[Keyboard.DOWN] || this._keyPressed[Keyboard.S])
		{
			this._camera.y += speed;
		}
		
		var count:Int = this._hexList.length;
		for (i in 0...count)
		{
			this._hexList[i].visible = false;
		}
		this._hexList.resize(0);
		this._camera.getHexes(this._hexList);
		cameraRender(this._hexList, this._camera.x, this._camera.y);
		
		this._cameraDebug.update(this._camera);
	}
	
	private function cameraRender(hexList:Array<Hex>, offsetX:Float, offsetY:Float):Void
	{
		this._display.renderOffsetX = -offsetX;
		this._display.renderOffsetY = -offsetY;
		
		#if flash
		this._hexDataList.length = 0;
		this._costDataList.length = 0;
		#else
		this._hexDataList.resize(0);
		this._costDataList.resize(0);
		#end
		var index:Int = -1;
		var costIndex:Int = -1;
		var hex:Hex;
		var count:Int = hexList.length;
		for (i in  0...count)
		{
			hex = hexList[i];
			hex.visible = true;
			hex.imageData.offsetX = hex.offsetX;
			hex.imageData.offsetY = hex.offsetY;
			this._hexDataList[++index] = hex.imageData;
			if (hex.costImageData != null)
			{
				hex.costImageData.offsetX = hex.offsetX;
				hex.costImageData.offsetY = hex.offsetY;
				this._costDataList[++costIndex] = hex.costImageData;
			}
		}
		
		if (this._rolloverHex != null)
		{
			this._rolloverImage.offsetX = this._rolloverHex.offsetX;
			this._rolloverImage.offsetY = this._rolloverHex.offsetY;
			this._rolloverImage.visible = this._rolloverHex.visible;
		}
		
		if (this._selectedHex != null)
		{
			this._selectedImage.offsetX = this._selectedHex.offsetX;
			this._selectedImage.offsetY = this._selectedHex.offsetY;
			this._selectedImage.visible = this._selectedHex.visible;
		}
		
		count = this._selectionHexList.length;
		for (i in 0...count)
		{
			this._selectionImageList[i].offsetX = this._selectionHexList[i].offsetX;
			this._selectionImageList[i].offsetY = this._selectionHexList[i].offsetY;
			this._selectionImageList[i].visible = this._selectionHexList[i].visible;
		}
	}
	
	private function onTouch(evt:TouchEvent):Void
	{
		var touch:Touch = evt.getTouch(this._touchQuad);
		if (touch == null)
		{
			if (this._rolloverHex != null)
			{
				rollOut(this._rolloverHex);
				this._rolloverHex = null;
			}
			this._touchID = -1;
			return;
		}
		
		var pt:Point = Pool.getPoint();
		touch.getLocation(this._touchQuad, pt);
		
		var previousRolloverHex:Hex = this._rolloverHex;
		this._rolloverHex = this.grid.pixelToHex(pt.x - (this._display.x - this._display.pivotX + this._display.renderOffsetX), pt.y - (this._display.y - this._display.pivotY + this._display.renderOffsetY), this.hexDefinition);
		Pool.putPoint(pt);
		
		if (this._rolloverHex != previousRolloverHex)
		{
			if (previousRolloverHex != null)
			{
				rollOut(previousRolloverHex);
			}
			if (this._rolloverHex != null)
			{
				rollOver(this._rolloverHex);
			}
			if (this._rolloverFunction != null && this._selectedHex != null) _rolloverFunction(this._rolloverHex);
		}
		
		if (this._touchID == -1 && touch.phase == TouchPhase.BEGAN)
		{
			this._touchID = touch.id;
		}
		else if (this._touchID == touch.id && touch.phase == TouchPhase.ENDED)
		{
			this._touchID = -1;
			if (this._selectFunction != null) _selectFunction(this._rolloverHex);
			if (this._selectPostFunction != null) _selectPostFunction(this._selectedHex);
		}
	}
	
	private function rollOver(hex:Hex):Void
	{
		this._rolloverImage.x = hex.x;
		this._rolloverImage.y = hex.y;
		this._rolloverImage.offsetX = hex.offsetX;
		this._rolloverImage.offsetY = hex.offsetY;
		this._rolloverImage.alpha = 1;
	}
	
	private function rollOut(hex:Hex):Void
	{
		this._rolloverImage.alpha = 0;
	}
	
	private function createSelectedImage(hex:Hex):ImageData
	{
		var img:ImageData = ImageData.fromPool();
		img.setFrames(this.selectionFrames);
		img.x = hex.x;
		img.y = hex.y;
		img.red = 0;
		img.green = 0.5;
		this._selectionImageList[this._selectionImageList.length] = img;
		this._selectionHexList[this._selectionHexList.length] = hex;
		this._selectionLayer.addImage(img);
		return img;
	}
	
	private function clearSelection():Void
	{
		this._selectionLayer.removeAllData();
		ImageData.toPoolArray(this._selectionImageList);
		this._selectionImageList.resize(0);
		this._selectionHexList.resize(0);
	}
	
	private function defaultSelect(hex:Hex):Void
	{
		clearSelection();
		this._selectedHex = hex;
		this._selectedImage.x = hex.x;
		this._selectedImage.y = hex.y;
		this._selectedImage.visible = true;
	}
	
	override public function setMode(mode:String):Void 
	{
		clearSelection();
		switch (mode)
		{
			case DemoMode.LINE :
				this._selectFunction = defaultSelect;
				this._selectPostFunction = null;
				this._rolloverFunction = line_rollover;
			
			case DemoMode.LOS :
				this._selectFunction = defaultSelect;
				this._selectPostFunction = LoS;
				this._rolloverFunction = null;
				if (this._selectedHex != null) LoS(_selectedHex);
			
			case DemoMode.PATHFINDING :
				this._selectFunction = defaultSelect;
				this._selectPostFunction = null;
				this._rolloverFunction = pathfinding_rollover;
			
			case DemoMode.RANGE :
				this._selectFunction = defaultSelect;
				this._selectPostFunction = null;
				this._rolloverFunction = range_rollover;
			
			case DemoMode.RING :
				this._selectFunction = defaultSelect;
				this._selectPostFunction = null;
				this._rolloverFunction = ring_rollover;
			
			case DemoMode.SPIRAL :
				this._selectFunction = defaultSelect;
				this._selectPostFunction = null;
				this._rolloverFunction = spiral_rollover;
			
			default :
				this._selectFunction = defaultSelect;
				this._selectPostFunction = null;
				this._rolloverFunction = null;
		}
	}
	
	override public function toggleMoveCosts(show:Bool):Void 
	{
		this._costLayer.visible = show;
	}
	
	private function pathfinding_rollover(hex:Hex):Void
	{
		clearSelection();
		if (hex == null) return;
		if (!hex.isTraversable) return;
		var toHex:Hex = hex;
		if (!hex.isTraversable || hex.isOccupied) 
		{
			var eligibleNeighbors:Array<Hex> = new Array<Hex>();
			for (neighbor in hex.neighbors)
			{
				if (neighbor.isTraversable && !neighbor.isOccupied)
				{
					eligibleNeighbors.push(neighbor);
				}
			}
			if (eligibleNeighbors.length != 0)
			{
				toHex = eligibleNeighbors[Std.random(eligibleNeighbors.length)];
			}
			else
			{
				return;
			}
		}
		var path:Array<Hex> = this._pathFinder.getPath(this._selectedHex, toHex, null, true, false, true);
		for (hex in path)
		{
			createSelectedImage(hex);
		}
	}
	
	private function line_rollover(hex:Hex):Void
	{
		clearSelection();
		if (hex == null) return;
		var line:Array<Hex> = grid.getHexLine(this._selectedHex, hex);
		for (hex in line)
		{
			createSelectedImage(hex);
		}
	}
	
	private function range_rollover(hex:Hex):Void
	{
		clearSelection();
		if (hex == null) return;
		var distance:Int = this.grid.getHexDistance(this._selectedHex, hex);
		var range:Array<Hex> = this.grid.getHexRange(this._selectedHex, distance);
		for (hex in range)
		{
			createSelectedImage(hex);
		}
	}
	
	private function ring_rollover(hex:Hex):Void
	{
		clearSelection();
		if (hex == null) return;
		var distance:Int = this.grid.getHexDistance(this._selectedHex, hex);
		var ring:Array<Hex> = this.grid.getHexRing(this._selectedHex, distance);
		for (hex in ring)
		{
			createSelectedImage(hex);
		}
	}
	
	private function spiral_rollover(hex:Hex):Void
	{
		clearSelection();
		if (hex == null) return;
		var distance:Int = this.grid.getHexDistance(this._selectedHex, hex);
		var minRadius:Int = distance - 1;
		var spiral:Array<Hex> = this.grid.getHexSpiral(this._selectedHex, minRadius, distance);
		for (hex in spiral)
		{
			createSelectedImage(hex);
		}
	}
	
	private function LoS(hex:Hex):Void
	{
		clearSelection();
		if (hex == null) return;
		var los:Array<Hex> = this.grid.getHexLoS(hex, 8);
		for (hex in los)
		{
			createSelectedImage(hex);
		}
	}
	
	private function keyDown(evt:KeyboardEvent):Void
	{
		this._keyPressed[evt.keyCode] = true;
	}
	
	private function keyUp(evt:KeyboardEvent):Void
	{
		this._keyPressed[evt.keyCode] = false;
	}
	
	private function mouseWheel(evt:MouseEvent):Void
	{
		var zoomStep:Float = 0.05;
		this._camera.zoom += evt.delta * zoomStep;
		this._display.scale = this._camera.zoom;
	}
	
}