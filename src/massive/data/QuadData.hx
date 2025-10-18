package massive.data;
import openfl.errors.ArgumentError;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class QuadData extends DisplayData
{
	static private var _POOL:Array<QuadData> = new Array<QuadData>();
	
	static public function fromPool():QuadData
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new QuadData();
	}
	
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
	
	static public function toPool(quad:QuadData):Void
	{
		quad.clear();
		_POOL[_POOL.length] = quad;
	}
	
	static public function toPoolArray(quadList:Array<QuadData>):Void
	{
		for (quad in quadList)
		{
			quad.pool();
		}
	}
	
	/* size from left border to pivotX */
	public var leftWidth:Float;
	/* size from pivotX to right border */
	public var rightWidth:Float;
	/* size from top border to pivotY */
	public var topHeight:Float;
	/* size from pivotY to bottom border */
	public var bottomHeight:Float;
	
	public var width:Float;
	public var height:Float;
	
	public var pivotX:Float;
	public var pivotY:Float;
	
	public function new() 
	{
		super();
	}
	
	override public function clear():Void 
	{
		super.clear();
	}
	
	public function pool():Void 
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
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