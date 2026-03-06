package massive.data;
#if flash
import openfl.Vector;
#end
import openfl.errors.ArgumentError;
import starling.utils.Align;

/**
 * Quad display object
 * @author Matse
 */
class QuadData extends DisplayData
{
	static private var _POOL:Array<QuadData> = new Array<QuadData>();
	
	/**
	   Returns a QuadData from pool if there's at least one in pool, or a new one otherwise
	   @return
	**/
	static public function fromPool():QuadData
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new QuadData();
	}
	
	/**
	   Returns an Array of ImageData, taken from pool if possible and created otherwise
	   @param	numQuads
	   @param	quads
	   @return
	**/
	static public function fromPoolArray(numQuads:Int, quads:Array<QuadData> = null):Array<QuadData>
	{
		if (quads == null) quads = new Array<QuadData>();
		
		while (numQuads != 0)
		{
			if (_POOL.length == 0) break;
			quads[quads.length] = _POOL.pop();
			numQuads--;
		}
		
		while (numQuads != 0)
		{
			quads[quads.length] = new QuadData();
			numQuads--;
		}
		
		return quads;
	}
	
	#if flash
	/**
	   Returns a Vector of QuadData, taken from pool if possible and created otherwise
	   @param	numQuads
	   @param	quads
	   @return
	**/
	static public function fromPoolVector(numQuads:Int, quads:Vector<QuadData> = null):Vector<QuadData>
	{
		if (quads == null) quads = new Vector<QuadData>();
		
		while (numQuads != 0)
		{
			if (_POOL.length == 0) break;
			quads[quads.length] = _POOL.pop();
			numQuads--;
		}
		
		while (numQuads != 0)
		{
			quads[quads.length] = new QuadData();
			numQuads--;
		}
		
		return quads;
	}
	#end
	
	/**
	   Equivalent to calling QuadData's pool function
	   @param	quad
	**/
	static public function toPool(quad:QuadData):Void
	{
		quad.clear();
		_POOL[_POOL.length] = quad;
	}
	
	/**
	   Pools all QuadData objects in the specified Array
	   @param	quads
	**/
	static public function toPoolArray(quads:Array<QuadData>):Void
	{
		var count:Int = quads.length;
		for (i in 0...count)
		{
			quads[i].pool();
		}
	}
	
	#if flash
	/**
	   Pools all QuadData objects in the specified Vector
	   @param	quads
	**/
	static public function toPoolVector(quads:Array<QuadData>):Void
	{
		var count:Int = quads.length;
		for (i in 0...count)
		{
			quads[i].pool();
		}
	}
	#end
	
	/**
	   Size from left border to pivotX
	**/
	public var leftWidth:Float;
	/**
	   Size from pivotX to right border
	**/
	public var rightWidth:Float;
	/**
	   Size from top border to pivotY
	**/
	public var topHeight:Float;
	/**
	   Size from pivotY to bottom border
	**/
	public var bottomHeight:Float;
	/**
	   Base width
	**/
	public var width:Float;
	/**
	   Base height
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
	   Constructor
	**/
	public function new() 
	{
		super();
	}
	
	/**
	   @inheritDoc
	**/
	override public function clear():Void 
	{
		super.clear();
	}
	
	/**
	   @inheritDoc
	**/
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	/**
	   Sets pivotX and pivotY based on specified Align values and calls pivotUpdate
	   @param	horizontalAlign
	   @param	verticalAlign
	**/
	public function alignPivot(horizontalAlign:String, verticalAlign:String):Void 
	{
		if (horizontalAlign == Align.LEFT) this.pivotX = 0;
		else if (horizontalAlign == Align.CENTER) this.pivotX = this.width / 2;
		else if (horizontalAlign == Align.RIGHT) this.pivotX = this.width;
		else throw new ArgumentError("Invalid horizontal alignment : " + horizontalAlign);
		
		if (verticalAlign == Align.TOP) this.pivotY = 0;
		else if (verticalAlign == Align.CENTER) this.pivotY = this.height / 2;
		else if (verticalAlign == Align.BOTTOM) this.pivotY = this.height;
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
	 * Updates pivot-related values
	 */
	public function pivotUpdate():Void
	{
		this.leftWidth = this.pivotX;
		this.rightWidth = this.width - this.pivotX;
		this.topHeight = this.pivotY;
		this.bottomHeight = this.height - this.pivotY;
	}
	
}