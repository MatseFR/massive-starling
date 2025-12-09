package massive.data;
#if flash
import openfl.Vector;
#end
import openfl.errors.ArgumentError;
import starling.utils.Align;

/**
 * ...
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
	   @param	quadList
	   @return
	**/
	static public function fromPoolArray(numQuads:Int, quadList:Array<QuadData> = null):Array<QuadData>
	{
		if (quadList == null) quadList = new Array<QuadData>();
		
		while (numQuads != 0)
		{
			if (_POOL.length == 0) break;
			quadList[quadList.length] = _POOL.pop();
			numQuads--;
		}
		
		while (numQuads != 0)
		{
			quadList[quadList.length] = new QuadData();
			numQuads--;
		}
		
		return quadList;
	}
	
	#if flash
	/**
	   Returns an Array of QuadData, taken from pool if possible and created otherwise
	   @param	numQuads
	   @param	quadList
	   @return
	**/
	static public function fromPoolVector(numQuads:Int, quadList:Vector<QuadData> = null):Vector<QuadData>
	{
		if (quadList == null) quadList = new Vector<QuadData>();
		
		while (numQuads != 0)
		{
			if (_POOL.length == 0) break;
			quadList[quadList.length] = _POOL.pop();
			numQuads--;
		}
		
		while (numQuads != 0)
		{
			quadList[quadList.length] = new QuadData();
			numQuads--;
		}
		
		return quadList;
	}
	#end
	
	/**
	   Equivalent to calling ImageData's pool function
	   @param	quad
	**/
	static public function toPool(quad:QuadData):Void
	{
		quad.clear();
		_POOL[_POOL.length] = quad;
	}
	
	/**
	   Pools all ImageData objects in the specified Array
	   @param	quadList
	**/
	static public function toPoolArray(quadList:Array<QuadData>):Void
	{
		for (quad in quadList)
		{
			quad.clear();
			_POOL[_POOL.length] = quad;
		}
	}
	
	#if flash
	/**
	   Pools all ImageData objects in the specified Vector
	   @param	quadList
	**/
	static public function toPoolVector(quadList:Array<QuadData>):Void
	{
		for (quad in quadList)
		{
			quad.clear();
			_POOL[_POOL.length] = quad;
		}
	}
	#end
	
	/* size from left border to pivotX */
	public var leftWidth:Float;
	/* size from pivotX to right border */
	public var rightWidth:Float;
	/* size from top border to pivotY */
	public var topHeight:Float;
	/* size from pivotY to bottom border */
	public var bottomHeight:Float;
	/* base width */
	public var width:Float;
	/* base height */
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