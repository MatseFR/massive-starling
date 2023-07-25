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
			quadList.push(POOL.pop());
			numQuads--;
		}
		
		while (numQuads != 0)
		{
			quadList.push(new QuadData());
			numQuads--;
		}
		
		return quadList;
	}
	
	public static function toPool(quad:QuadData):Void
	{
		POOL.push(quad);
	}
	
	public static function toPoolArray(quadList:Array<QuadData>):Void
	{
		for (quad in quadList)
		{
			POOL.push(quad);
		}
	}
	
	public var leftWidth:Float;
	public var rightWidth:Float;
	public var topHeight:Float;
	public var bottomHeight:Float;
	
	public var width:Float;
	public var height:Float;
	
	public var pivotX:Float;
	public var pivotY:Float;
	
	public function new() 
	{
		super();
	}
	
	override public function alignPivot(horizontalAlign:String, verticalAlign:String):Void 
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
	
	override public function setPivot(pivotX:Float, pivotY:Float):Void 
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