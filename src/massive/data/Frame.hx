package massive.data;
import openfl.Vector;
import openfl.errors.ArgumentError;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.utils.Align;

/**
 * Stores the info needed by an ImageData to display a texture (typically a SubTexture from a TextureAtlas)
 * Use the static helper function to create those
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
	static public function fromTextureArray(textures:Array<Texture>, frames:#if flash Vector<Frame> #else Array<Frame> #end = null):#if flash Vector<Frame> #else Array<Frame> #end
	{
		if (textures == null || textures.length == 0) return null;
		if (frames == null) frames = #if flash new Vector<Frame>() #else new Array<Frame>() #end ;
		
		var frame:Frame;
		
		for (texture in textures)
		{
			frame = fromTexture(texture);
			frames[frames.length] = frame;
		}
		
		return frames;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	horizontalAlign
	 * @param	verticalAlign
	 * @return
	 */
	static public function fromTextureArrayWithAlign(textures:Array<Texture>, horizontalAlign:String, 
		verticalAlign:String, frames:#if flash Vector<Frame> #else Array<Frame> #end = null):#if flash Vector<Frame> #else Array<Frame> #end
	{
		if (textures == null || textures.length == 0) return null;
		if (frames == null) frames = #if flash new Vector<Frame>() #else new Array<Frame>() #end ;
		
		var frame:Frame;
		
		for (texture in textures)
		{
			frame = fromTextureWithAlign(texture, horizontalAlign, verticalAlign);
			frames[frames.length] = frame;
		}
		
		return frames;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	pivotX
	 * @param	pivotY
	 * @return
	 */
	static public function fromTextureArrayWithPivot(textures:Array<Texture>, pivotX:Float, pivotY:Float, frames:#if flash Vector<Frame> #else Array<Frame> #end = null):#if flash Vector<Frame> #else Array<Frame> #end
	{
		if (textures == null || textures.length == 0) return null;
		if (frames == null) frames = #if flash new Vector<Frame>() #else new Array<Frame>() #end ;
		
		var frame:Frame;
		
		for (texture in textures)
		{
			frame = fromTextureWithPivot(texture, pivotX, pivotY);
			frames[frames.length] = frame;
		}
		
		return frames;
	}
	
	/**
	 * 
	 * @param	textures
	 * @return
	 */
	static public function fromTextureVector(textures:Vector<Texture>, frames:#if flash Vector<Frame> #else Array<Frame> #end = null):#if flash Vector<Frame> #else Array<Frame> #end
	{
		if (textures == null || textures.length == 0) return null;
		if (frames == null) frames = #if flash new Vector<Frame>() #else new Array<Frame>() #end ;
		
		var frame:Frame;
		
		for (texture in textures)
		{
			frame = fromTexture(texture);
			frames[frames.length] = frame;
		}
		
		return frames;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	horizontalAlign
	 * @param	verticalAlign
	 * @return
	 */
	static public function fromTextureVectorWithAlign(textures:Vector<Texture>, horizontalAlign:String,
		verticalAlign:String, frames:#if flash Vector<Frame> #else Array<Frame> #end = null):#if flash Vector<Frame> #else Array<Frame> #end
	{
		if (textures == null || textures.length == 0) return null;
		if (frames == null) frames = #if flash new Vector<Frame>() #else new Array<Frame>() #end ;
		
		var frame:Frame;
		
		for (texture in textures)
		{
			frame = fromTextureWithAlign(texture, horizontalAlign, verticalAlign);
			frames[frames.length] = frame;
		}
		
		return frames;
	}
	
	/**
	 * 
	 * @param	textures
	 * @param	pivotX
	 * @param	pivotY
	 * @return
	 */
	static public function fromTextureVectorWithPivot(textures:Vector<Texture>, pivotX:Float, pivotY:Float, frames:#if flash Vector<Frame> #else Array<Frame> #end = null):#if flash Vector<Frame> #else Array<Frame> #end
	{
		if (textures == null || textures.length == 0) return null;
		if (frames == null) frames = #if flash new Vector<Frame>() #else new Array<Frame>() #end ;
		
		var frame:Frame;
		
		for (texture in textures)
		{
			frame = fromTextureWithPivot(texture, pivotX, pivotY);
			frames[frames.length] = frame;
		}
		
		return frames;
	}
	
	/**
	   Left texture coordinate
	**/
	public var u1:Float;
	/**
	   Top texture coordinate
	**/
	public var v1:Float;
	/**
	   Right texture coordinate
	**/
	public var u2:Float;
	/**
	   Bottom texture coordinate
	**/
	public var v2:Float;
	/**
	   Tells whether the texture is rotated or not
	**/
	public var rotated:Bool;
	/**
	   Width of the texture in pixels
	**/
	public var width:Float;
	/**
	   Height of the texture in pixels
	**/
	public var height:Float;
	/**
	   Pivot location on x-axis
	   If you set this value directly you should call pivotUpdate afterwards
	**/
	public var pivotX:Float;
	/**
	   Pivot location on y-axis
	   If you set this value directly you should call pivotUpdate afterwards
	**/
	public var pivotY:Float;
	/**
	   How many pixels from 0 to pivotX
	**/
	public var leftWidth:Float;
	/**
	   How many pixels from pivotX to width
	**/
	public var rightWidth:Float;
	/**
	   How many pixels from 0 to pivotY
	**/
	public var topHeight:Float;
	/**
	   How many pixels from pivotY to height
	**/
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
		
		this.rotated = rotated;
		
		this.setPivot(0, 0);
	}
	
	/**
	   Sets pivotX and pivotY based on specified Align values and calls pivotUpdate
	   @param	horizontalAlign
	   @param	verticalAlign
	**/
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
	
	/**
	   Sets pivotX and pivotY values and calls pivotUpdate
	   @param	pivotX
	   @param	pivotY
	**/
	public function setPivot(pivotX:Float, pivotY:Float):Void 
	{
		this.pivotX = pivotX;
		this.pivotY = pivotY;
		
		pivotUpdate();
	}
	
	/**
	 * updates pivot-related values
	 */
	public function pivotUpdate():Void
	{
		this.leftWidth = this.pivotX;
		this.rightWidth = this.width - this.pivotX;
		this.topHeight = this.pivotY;
		this.bottomHeight = this.height - this.pivotY;
	}
	
}