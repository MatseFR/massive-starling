package;

import feathers.data.ArrayCollection;
import massive.data.Frame;
import massive.data.ImageData;
import massive.display.MassiveDisplay;
import massive.particle.Particle;
import massive.particle.ParticleSystem;
#if (desktop || air)
import openfl.filesystem.File;
import openfl.filesystem.FileStream;
#else
import openfl.net.FileReference;
#end
import openfl.Vector;
import starling.core.Starling;
import starling.textures.Texture;
import starling.utils.Align;
import valedit.ExposedCollection;
import valedit.value.ExposedBool;
import valedit.value.base.ExposedValue;
import valeditor.ValEditor;
import valeditor.data.Data;
import valeditor.editor.base.ValEditorSimpleStarling;
import valeditor.editor.file.FileController;
import valeditor.ui.feathers.data.MenuItem;

/**
 * ...
 * @author Matse
 */
class ParticleEditor extends ValEditorSimpleStarling 
{
	private var _massive:MassiveDisplay;
	private var _ps:ParticleSystem<Particle>;
	private var _psCollection:ExposedCollection;
	
	// file menu
	private var _fileMenuCollection:ArrayCollection<MenuItem>;
	private var _fileOpenItem:MenuItem;
	private var _fileSaveItem:MenuItem;
	private var _fileSaveAsItem:MenuItem;
	
	// edit menu
	private var _editMenuCollection:ArrayCollection<MenuItem>;
	private var _undoItem:MenuItem;
	private var _redoItem:MenuItem;
	
	#if (desktop || air)
	private var _fileStream:FileStream = new FileStream();
	#end

	public function new() 
	{
		super();
	}
	
	override function exposeData():Void 
	{
		Data.exposeMassive();
		Data.exposeOpenFL_geom();
		Data.exposeStarling();
	}
	
	override function ready():Void 
	{
		super.ready();
		
		// file menu
		this._fileOpenItem = new MenuItem("file_open", "Open", true, "Ctrl+O");
		this._fileSaveItem = new MenuItem("file_save", "Save", true, "Ctrl+S");
		this._fileSaveAsItem = new MenuItem("file_save_as", "Save as", true, "Ctrl+Shift+S");
		this._fileMenuCollection = new ArrayCollection<MenuItem>([
			this._fileOpenItem,
			this._fileSaveItem,
			this._fileSaveAsItem
		]);
		this.editView.addMenu("file", "File", onFileMenuCallback, onFileMenuOpen, this._fileMenuCollection);
		
		// edit menu
		this._undoItem = new MenuItem("undo", "Undo", false, "Ctrl+Z");
		this._redoItem = new MenuItem("redo", "Redo", false, "Ctrl+Y");
		this._editMenuCollection = new ArrayCollection<MenuItem>([
			this._undoItem,
			this._redoItem
		]);
		this.editView.addMenu("edit", "Edit", onEditMenuCallback, onEditMenuOpen, this._editMenuCollection);
		
		var texture:Texture;
		var frame:Frame;
		#if flash
		var frames:Vector<Frame>;
		#else
		var frames:Array<Frame>;
		#end
		
		texture = Texture.fromColor(2, 2);
		frame = Frame.fromTextureWithAlign(texture, Align.CENTER, Align.CENTER);
		#if flash
		frames = new Vector<Frame>();
		#else
		frames = new Array<Frame>();
		#end
		frames[0] = frame;
		
		this._massive = new MassiveDisplay();
		this._massive.texture = texture;
		addChild(this._massive);
		
		this._ps = new ParticleSystem<Particle>();
		#if flash
		this._ps.particlesFromPoolFunction = Particle.fromPoolVector;
		this._ps.particlesToPoolFunction = Particle.toPoolVector;
		#else
		this._ps.particlesFromPoolFunction = Particle.fromPoolArray;
		this._ps.particlesToPoolFunction = Particle.toPoolArray;
		#end
		this._ps.addFrames(frames);
		this._massive.addLayer(this._ps);
		
		this._ps.start();
		
		//var t = Type.typeof(this._ps);
		//var t = $type(this._ps);
		this._psCollection = ValEditor.edit(this._ps);
	}
	
	@:access(starling.core.Starling)
	override function onDisplayResize(evt:openfl.events.Event):Void 
	{
		super.onDisplayResize(evt);
		
		if (Starling.current.showStats)
		{
			Starling.current.__statsDisplay.x = this.editView.displayRect.x;
			Starling.current.__statsDisplay.y = this.editView.displayRect.y;
		}
		
		if (this._ps == null) return;
		this._ps.emitterX = this.editView.displayCenter.x;
		this._ps.emitterY = this.editView.displayCenter.y;
		//this._psCollection.read();
	}
	
	@:access(starling.core.Starling)
	override function updateViewPort(width:Int, height:Int):Void 
	{
		super.updateViewPort(width, height);
		
		if (Starling.current.showStats)
		{
			Starling.current.__statsDisplay.x = this.editView.displayRect.x;
			Starling.current.__statsDisplay.y = this.editView.displayRect.y;
		}
	}
	
	private function onEditMenuOpen(evt:openfl.events.Event):Void
	{
		this._undoItem.enabled = ValEditor.actionStack.canUndo;
		this._redoItem.enabled = ValEditor.actionStack.canRedo;
		this._editMenuCollection.updateAll();
	}
	
	private function onEditMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "undo" :
				ValEditor.actionStack.undo();
			
			case "redo" :
				ValEditor.actionStack.redo();
		}
	}
	
	private function onFileMenuOpen(evt:openfl.events.Event):Void
	{
		
	}
	
	private function onFileMenuCallback(item:MenuItem):Void
	{
		switch (item.id)
		{
			case "file_open" :
				FileController.open(fileOpen);
			
			case "file_save" :
				
			
			case "file_save_as" :
				
		}
	}
	
	#if (desktop || air)
	private function fileOpen(file:File):Void
	{
		
	}
	#else
	private function fileOpen(fileRef:FileReference):Void
	{
		
	}
	#end
	
}