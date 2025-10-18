package massive.data;
import openfl.Vector;
import openfl.errors.ArgumentError;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class Frame 
{
	/**
	 * 
	 * @param	texture
	 * @return
	 */
	static public function fromTexture(texture:Texture):Frame
	{
		var frame:Frame;
		
		if (Std.isOfType(texture, SubTexture))
		{
			var subTexture:SubTexture = cast texture;
			frame = new Frame(texture.root.nativeWidth, texture.root.nativeHeight, subTexture.region.x,
				subTexture.region.y, subTexture.region.width, subTexture.region.height, subTexture.rotated);
		}
		else
		{
			frame = new Frame(texture.width, texture.height, 0, 0, texture.width, texture.height, false);
		}
		
		return frame;
	}
	
	/**
	 * 
	 * @param	texture
	 * @param	horizontalAlign
	 * @param	verticalAlign
	 * @return
	 */
	static public function fromTextureWithAlign(texture:Texture, horizontalAlign:String, verticalAlign:String):Frame
	{
		var frame:Frame = fromTexture(texture);
		frame.alignPivot(horizontalAlign, verticalAlign);
		return frame;
	}
	
	/**
	 * 
	 * @param	texture
	 * @param	pivotX
	 * @param	pivotY
	 * @return
	 */
	static public function fromTextureWithPivot(texture:Texture, pivotX:Float, pivotY:Float):Frame
	{
		var frame:Frame = fromTexture(texture);
		frame.setPivot(pivotX, pivotY);
		return frame;
	}
	
	/**
	 * 
	 * @param	textures
	 * @return
	 */
	static public function fromTextureArray(textures:Array<Texture>):Array<Frame>
	{
		if (textures == null || textures.length == 0) return null;
		
		var frame:Frame;
		var frameList:Array<Frame> = new Array<Frame>();
		
		for (texture in textures)
		{
			frame = fromTexture(texture);
			frameList[frameList.length] = frame;
		}
		
		return frameList;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	horizontalAlign
	 * @param	verticalAlign
	 * @return
	 */
	static public function fromTextureArrayWithAlign(textures:Array<Texture>, horizontalAlign:String,
		verticalAlign:String):Array<Frame>
	{
		if (textures == null || textures.length == 0) return null;
		
		var frame:Frame;
		var frameList:Array<Frame> = new Array<Frame>();
		
		for (texture in textures)
		{
			frame = fromTextureWithAlign(texture, horizontalAlign, verticalAlign);
			frameList[frameList.length] = frame;
		}
		
		return frameList;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	pivotX
	 * @param	pivotY
	 * @return
	 */
	static public function fromTextureArrayWithPivot(textures:Array<Texture>, pivotX:Float, pivotY:Float):Array<Frame>
	{
		if (textures == null || textures.length == 0) return null;
		
		var frame:Frame;
		var frameList:Array<Frame> = new Array<Frame>();
		
		for (texture in textures)
		{
			frame = fromTextureWithPivot(texture, pivotX, pivotY);
			frameList[frameList.length] = frame;
		}
		
		return frameList;
	}
	
	/**
	 * 
	 * @param	textures
	 * @return
	 */
	static public function fromTextureVector(textures:Vector<Texture>):Array<Frame>
	{
		if (textures == null || textures.length == 0) return null;
		
		var frame:Frame;
		var frameList:Array<Frame> = new Array<Frame>();
		
		for (texture in textures)
		{
			frame = fromTexture(texture);
			frameList[frameList.length] = frame;
		}
		
		return frameList;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	horizontalAlign
	 * @param	verticalAlign
	 * @return
	 */
	static public function fromTextureVectorWithAlign(textures:Vector<Texture>, horizontalAlign:String,
		verticalAlign:String):Array<Frame>
	{
		if (textures == null || textures.length == 0) return null;
		
		var frame:Frame;
		var frameList:Array<Frame> = new Array<Frame>();
		
		for (texture in textures)
		{
			frame = fromTextureWithAlign(texture, horizontalAlign, verticalAlign);
			frameList[frameList.length] = frame;
		}
		
		return frameList;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	pivotX
	 * @param	pivotY
	 * @return
	 */
	static public function fromTextureVectorWithPivot(textures:Vector<Texture>, pivotX:Float, pivotY:Float):Array<Frame>
	{
		if (textures == null || textures.length == 0) return null;
		
		var frame:Frame;
		var frameList:Array<Frame> = new Array<Frame>();
		
		for (texture in textures)
		{
			frame = fromTextureWithPivot(texture, pivotX, pivotY);
			frameList[frameList.length] = frame;
		}
		
		return frameList;
	}
	
	public var halfWidth:Float;
	public var halfHeight:Float;
	public var u1:Float;
	public var v1:Float;
	public var u2:Float;
	public var v2:Float;
	public var rotated:Bool;
	
	public var width:Float;
	public var height:Float;
	
	public var pivotX:Float;
	public var pivotY:Float;
	
	public var leftWidth:Float;
	public var rightWidth:Float;
	public var topHeight:Float;
	public var bottomHeight:Float;
	
	public function new(nativeTextureWidth:Float, nativeTextureHeight:Float, x:Float, y:Float,
						width:Float, height:Float, rotated:Bool) 
	{
		this.u1 = x / nativeTextureWidth;
		this.v1 = y / nativeTextureHeight;
		this.u2 = (x + width) / nativeTextureWidth;
		this.v2 = (y + height) / nativeTextureHeight;
		
		this.width = width;
		this.height = height;
		
		this.halfWidth = width / 2;
		this.halfHeight = height / 2;
		this.rotated = rotated;
		
		this.setPivot(0, 0);
	}
	
	public function alignPivot(horizontalAlign:String, verticalAlign:String):Void 
	{
		if (horizontalAlign == Align.LEFT) this.pivotX = 0;
		else if (horizontalAlign == Align.CENTER) this.pivotX = width / 2;
		else if (horizontalAlign == Align.RIGHT) this.pivotX = width;
		else throw new ArgumentError("Invalid horizontal alignment : " + horizontalAlign);
		
		if (verticalAlign == Align.TOP) this.pivotY = 0;
		else if (verticalAlign == Align.CENTER) this.pivotY = height / 2;
		else if (verticalAlign == Align.BOTTOM) this.pivotY = height;
		else throw new ArgumentError("Invalid vertical alignment : " + verticalAlign);
		
		pivotUpdate();
	}
	
	public function setPivot(pivotX:Float, pivotY:Float):Void 
	{
		this.pivotX = pivotX;
		this.pivotY = pivotY;
		
		pivotUpdate();
	}
	
	/**
	 * 
	 */
	public function pivotUpdate():Void
	{
		this.leftWidth = this.pivotX;
		this.rightWidth = this.width - this.pivotX;
		this.topHeight = this.pivotY;
		this.bottomHeight = this.height - this.pivotY;
	}
	
}