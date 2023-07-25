package massive.data.valedit;

import massive.data.QuadData;
import starling.display.Quad;

/**
 * ...
 * @author Matse
 */
class QuadDataProxy extends Quad 
{
	public var quadData(get, set):QuadData;
	private var _quadData:QuadData;
	private function get_quadData():QuadData { return this._quadData; }
	private function set_quadData(value:QuadData):QuadData
	{
		return this._quadData = value;
	}
	
	private var _xReal:Float = 0;
	//@:getter(x)
	override function get_x():Float 
	{
		return this._xReal;
	}
	//@:setter(x)
	override function set_x(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.x = value;
		}
		super.set_x(value + this._offsetX);
		return this._xReal = value;
	}
	
	private var _yReal:Float = 0;
	//@:getter(y)
	override function get_y():Float 
	{
		return this._yReal;
	}
	//@:setter(y)
	override function set_y(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.y = value;
		}
		super.set_y(value + this._offsetY);
		return this._yReal = value;
	}
	
	public var offsetX(get, set):Float;
	private var _offsetX:Float;
	private function get_offsetX():Float { return this._offsetX; }
	private function set_offsetX(value:Float):Float
	{
		if (this._quadData != null)
		{
			this._quadData.offsetX = value;
		}
		super.set_x(this._xReal + value);
		return this._offsetX = value;
	}
	
	public var offsetY(get, set):Float;
	private var _offsetY:Float;
	private function get_offsetY():Float { return this._offsetY; }
	private function set_offsetY(value:Float):Float
	{
		if (this._quadData != null)
		{
			this._quadData.offsetY = value;
		}
		super.set_y(this._yReal + value);
		return this._offsetY = value;
	}
	
	//@:setter(rotation)
	override function set_rotation(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.rotation = value;
		}
		return super.set_rotation(value);
	}
	
	//@:setter(scaleX)
	override function set_scaleX(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.scaleX = value;
		}
		return super.set_scaleX(value);
	}
	
	//@:setter(scaleY)
	override function set_scaleY(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.scaleY = value;
		}
		return super.set_scaleY(value);
	}
	
	//@:setter(visible)
	override function set_visible(value:Bool):Bool 
	{
		if (this._quadData != null)
		{
			this._quadData.visible = value;
		}
		return super.set_visible(value);
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.width = value;
			this._quadData.pivotUpdate();
		}
		var rotation:Float = this.rotation;
		this.rotation = 0;
		this.readjustSize(value, this.height);
		this.rotation = rotation;
		return super.set_width(value);
	}
	
	//@:setter(height)
	override function set_height(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.height = value;
			this._quadData.pivotUpdate();
		}
		var rotation:Float = this.rotation;
		this.rotation = 0;
		this.readjustSize(this.width, value);
		this.rotation = rotation;
		return super.set_height(value);
	}
	
	//@:setter(pivotX)
	override function set_pivotX(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.pivotX = value;
			this._quadData.pivotUpdate();
		}
		return super.set_pivotX(value);
	}
	
	//@:setter(pivotY)
	override function set_pivotY(value:Float):Float 
	{
		if (this._quadData != null)
		{
			this._quadData.pivotY = value;
			this._quadData.pivotUpdate();
		}
		return super.set_pivotY(value);
	}

	public function new(width:Float, height:Float, color:UInt=0xffffff) 
	{
		super(width, height, color);
	}
	
}