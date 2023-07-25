package massive.data.valedit;

import massive.data.Frame;
import starling.display.Image;
import starling.textures.Texture;

/**
 * ...
 * @author Matse
 */
class FrameProxy extends Image 
{
	public var frame(get, set):Frame;
	private var _frame:Frame;
	private function get_frame():Frame { return this._frame; }
	private function set_frame(value:Frame):Frame
	{
		return this._frame = value;
	}
	
	//public var realTexture(get, set):Dynamic;
	//private var _realTexture:Dynamic;
	//private function get_realTexture():Dynamic { return this._realTexture; }
	//private function set_realTexture(value:Dynamic):Dynamic
	//{
		//return this._realTexture = value;
	//}
	
	//@:setter(texture)
	override function set_texture(value:Texture):Texture 
	{
		super.set_texture(value);
		if (value != null)
		{
			super.readjustSize();
			this.width = value.width;
			this.height = value.height;
		}
		return value;
	}
	
	//@:setter(pivotX)
	override function set_pivotX(value:Float):Float 
	{
		if (this._frame != null)
		{
			this._frame.pivotX = value;
			this._frame.pivotUpdate();
		}
		return super.set_pivotX(value);
	}
	
	//@:setter(pivotY)
	override function set_pivotY(value:Float):Float 
	{
		if (this._frame != null)
		{
			this._frame.pivotY = value;
			this._frame.pivotUpdate();
		}
		return super.set_pivotY(value);
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		if (this._frame != null)
		{
			this._frame.width = value;
			this._frame.pivotUpdate();
		}
		return super.set_width(value);
	}
	
	//@:setter(height)
	override function set_height(value:Float):Float 
	{
		if (this._frame != null)
		{
			this._frame.height = value;
			this._frame.pivotUpdate();
		}
		return super.set_height(value);
	}
	
	public function new(texture:Texture) 
	{
		super(texture);
		
	}
	
}