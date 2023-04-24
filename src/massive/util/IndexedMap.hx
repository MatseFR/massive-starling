package massive.util;

/**
 * ...
 * @author Chris Speciale
 */
class IndexedMap<K, V> 
{
	private var keys:Array<K> = [];
	private var values:Array<V> = [];
	private var map:Map<K, Int> = new Map<K, Int>();

	public function new() {}

	public function set(key:K, value:V):Void
	{
		if (map.exists(key)) {
			values[map.get(key)] = value;
		} else {
			map.set(key, keys.length);
			keys.push(key);
			values.push(value);
		}
	}
	
	public function get(key:K):Null<V>
	{
		if (map.exists(key)) {
			return values[map.get(key)];
		} else {
			return null;
		}
	}
	
	public function remove(key:K):Void
	{
		if (map.exists(key)) {
			var index:Int = map.get(key);
			keys.splice(index, 1);
			values.splice(index, 1);
			map.remove(key);
			for (i in index...keys.length) {
				map.set(keys[i], i);
			}
		}
	}
	
	public function exists(key:K):Bool
	{
		return map.exists(key);
	}
	
	public function iterator():Iterator<V>
	{
		return values.iterator();
	}
	
	public function keysIterator():Iterator<K>
	{
		return keys.iterator();
	}
	
	public function valuesIterator():Iterator<V>
	{
		return values.iterator();
	}
	
	public function getKeys():Array<K>
	{
		return keys.copy();
	}
	
	public function getValues():Array<V>
	{
		return values.copy();
	}
}