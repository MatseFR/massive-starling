package massive.data;
import openfl.errors.ArgumentError;
import starling.utils.Align;

/**
 * ...
 * @author Matse
 */
class QuadData extends DisplayData
{
	private static var POOL:Array<QuadData> = new Array<QuadData>();
	
	public static function fromPool():QuadData
	{
		if (POOL.length != 0) return POOL.pop();
		return new QuadData();
	}
	
	public static function fromPoolArray(numQuads:Int, quadList:Array<QuadData> = null):Array<QuadData>
	{
		if (quadList == null) quadList = new Array<QuadData>();
		
		while (numQuads != 0)
		{
			if (POOL.length == 0) break;
			quadList[quadList.length] = POOL.pop();
			numQuads--;
		}
		
		while (numQuads != 0)
		{
			quadList[quadList.length] = new QuadData();
			numQuads--;
		}
		
		return quadList;
	}
	
	public static function toPool(quad:QuadData):Void
	{
		quad.clear();
		POOL[POOL.length] = quad;
	}
	
	public static function toPoolArray(quadList:Array<QuadData>):Void
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
		POOL[POOL.length] = this;
	}
	
	public function alignPivot(horizontalAlign:String, verticalAlign:String):Void 
	{
		if (horizontalAlign == Align.LEFT) pivotX = 0;
		else if (horizontalAlign == Align.CENTER) pivotX = width / 2;
		else if (horizontalAlign == Align.RIGHT) pivotX = width;
		else throw new ArgumentError("Invalid horizontal alignment : " + horizontalAlign);
		
		if (verticalAlign == Align.TOP) pivotY = 0;
		else if (verticalAlign == Align.CENTER) pivotY = height / 2;
		else if (verticalAlign == Align.BOTTOM) pivotY = height;
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
		leftWidth = pivotX;
		rightWidth = width - pivotX;
		topHeight = pivotY;
		bottomHeight = height - pivotY;
	}
	
}