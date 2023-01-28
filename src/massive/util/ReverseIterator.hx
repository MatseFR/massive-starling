package massive.util;

/**
 * ...
 * @author Matse
 */
class ReverseIterator 
{
	var end:Int;
	var i:Int;

	public inline function new(start:Int, end:Int) {
		this.i = start;
		this.end = end;
	}

	public inline function hasNext() return i >= end;
	public inline function next() return i--;
}

/*for (i in new ReverseIterator(5, 0)) {
	trace(i);
}*/