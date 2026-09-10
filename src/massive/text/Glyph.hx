package massive.text;
import massive.data.Frame;

/**
 * ...
 * @author Matse
 */
class Glyph 
{
	public var charID(default, null):Int;
	public var frame(default, null):Frame;
	public var height(default, null):Float;
	public var isLetter:Bool = true;
	public var isNumber:Bool;
	public var isPunctuation:Bool;
	public var isSpace:Bool;
	public var isVowel:Bool;
	public var width(default, null):Float;
	public var xAdvance(default, null):Float;
	public var xOffset(default, null):Float;
	public var yOffset(default, null):Float;
	
	private var _kernings:Map<Int, Float>;
	
	public function new(charID:Int, frame:Frame, xOffset:Float, yOffset:Float, xAdvance:Float) 
	{
		this.charID = charID;
		this.frame = frame;
		this.height = frame != null ? frame.height : 0.0;
		this.width = frame != null ? frame.width : 0.0;
		this.xOffset = xOffset;
		this.yOffset = yOffset;
		this.xAdvance = xAdvance;
	}
	
	public function addKerning(charID:Int, amount:Float):Void
	{
		if (this._kernings == null) this._kernings = new Map<Int, Float>();
		
		this._kernings.set(charID, amount);
	}
	
	public function getKerning(charID:Int):Float
	{
		if (this._kernings == null || !this._kernings.exists(charID)) return 0.0;
		return this._kernings.get(charID);
	}
	
}