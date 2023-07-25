package massive.data.valedit;

import massive.data.ImageData;
import starling.display.Image;
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class ImageDataProxy extends Image 
{
	public var imageData(get, set):ImageData;
	private var _imageData:ImageData;
	private function get_imageData():ImageData { return this._imageData; }
	private function set_imageData(value:ImageData):ImageData
	{
		return this._imageData = value;
	}
	
	//@:setter(x)
	override function set_x(value:Float):Float 
	{
		if (this._imageData != null)
		{
			this._imageData.x = value;
		}
		return super.set_x(value);
	}
	
	//@:setter(y)
	override function set_y(value:Float):Float 
	{
		if (this._imageData != null)
		{
			this._imageData.y = value;
		}
		return super.set_y(value);
	}
	
	public var offsetX(get, set):Float;
	private var _offsetX:Float;
	private function get_offsetX():Float { return this._offsetX; }
	private function set_offsetX(value:Float):Float
	{
		if (this._imageData != null)
		{
			this._imageData.offsetX = value;
		}
		return this._offsetX = value;
	}
	
	public var offsetY(get, set):Float;
	private var _offsetY:Float;
	private function get_offsetY():Float { return this._offsetY; }
	private function set_offsetY(value:Float):Float
	{
		if (this._imageData != null)
		{
			this._imageData.offsetY = value;
		}
		return this._offsetY = value;
	}
	
	//@:setter(rotation)
	override function set_rotation(value:Float):Float 
	{
		if (this._imageData != null)
		{
			this._imageData.rotation = value;
		}
		return super.set_rotation(value);
	}
	
	//@:setter(scaleX)
	override function set_scaleX(value:Float):Float 
	{
		if (this._imageData != null)
		{
			this._imageData.scaleX = value;
		}
		return super.set_scaleX(value);
	}
	
	//@:setter(scaleY)
	override function set_scaleY(value:Float):Float 
	{
		if (this._imageData != null)
		{
			this._imageData.scaleY = value;
		}
		return super.set_scaleY(value);
	}
	
	//@:setter(visible)
	override function set_visible(value:Bool):Bool 
	{
		if (this._imageData != null)
		{
			this._imageData.visible = value;
		}
		return super.set_visible(value);
	}
	
	public var invertX(get, set):Bool;
	private var _invertX:Bool;
	private function get_invertX():Bool { return this._invertX; }
	private function set_invertX(value:Bool):Bool
	{
		if (this._imageData != null)
		{
			this._imageData.invertX = value;
		}
		return this._invertX = value;
	}
	
	public var invertY(get, set):Bool;
	private var _invertY:Bool;
	private function get_invertY():Bool { return this._invertY; }
	private function set_invertY(value:Bool):Bool
	{
		if (this._imageData != null)
		{
			this._imageData.invertY = value;
		}
		return this._invertY = value;
	}

	public function new(texture:Texture) 
	{
		super(texture);
	}
	
}