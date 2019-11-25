package notifier;

import haxe.Json;
import signals.Signal1;
import signals.Signal2;
import notifier.Notifier;

@:forward
class ArrayNotifier<T> extends Notifier<Array<T>> {
	#if js
	@:noCompletion private static function __init__() {
		untyped Object.defineProperties(ArrayNotifier.prototype, {
			"array": {
				get: untyped __js__("function () { return this.get_array (); }"),
				set: untyped __js__("function (v) { return this.set_array (v); }")
			},
		});
	}
	#end

	public var onChange = new Signal2<Int, T>();
	var notifiers = new Map<Int, Notifier<T>>();

	// var example = new ArrayNotifier<String>([]);
	public function new(defaultValue:Array<T>, ?id:String, ?fireOnAdd:Bool = false) {
		super(defaultValue, id, fireOnAdd);
	}

	@:arrayAccess
	public inline function get(index:Int):T {
		return this.value[index];
	}

	@:arrayAccess
	public inline function set(index:Int, v:T):T {
		var currentValue = this.value[index];
		this.value[index] = v;
		if (currentValue != v){
			change(index, v);
		}
		
		return v;
	}

	inline function change(index:Int, v:T){
		onChange.dispatch(index, v);
		dispatchNotifiers(index, v);
		this.dispatch();
	}
	

	/*override public function toString() {
		return value.toString();
	}*/

	/////////////////////////////////////////////////

	public function getNotifier(index:Int):Notifier<T> {
		var notifier = notifiers.get(index);
		if (notifier == null) {
			notifier = new Notifier<T>();
			notifiers.set(index, notifier);
		}
		return notifier;
	}

	inline function dispatchNotifiers(index:Int, value:T) {
		var notifier = notifiers.get(index);
		if (notifier != null) {
			notifier.value = value;
		}
	}



	/////////////////////////////////////////////////



	public var length(get, null):Int;

	public function get_length():Int
	{
		return value.length;
	}

	function concat(a:Array<T>):Array<T>
	{
		return value.concat(a);
	}

	public function join(sep:String):String
	{
		return value.join(sep);
	}
	
	public function pop():Null<T>
	{
		return value.pop();
	}
	
	public function push(x:T):Int
	{
		var v = value.push(x);
		change(value.length-1, x);
		return v;
	}
	
	public function reverse():Void
	{
		value.reverse();
	}
	
	public function shift():Null<T>
	{
		return value.shift();
	}
	
	public function slice(pos:Int, ?end:Int):Array<T>
	{
		return value.slice(pos, end);
	}
	
	public function sort(f:T->T->Int):Void
	{
		value.sort(f);
	}
	
	public function splice(pos:Int, len:Int):Array<T>
	{
		return value.splice(pos, len);
	}
	
	public function unshift(x:T):Void
	{
		value.unshift(x);
	}

	public  function insert(pos:Int, x:T):Void {
		value.insert(pos, x);
	}

	//public function remove(x:T):Bool {
	//	return value.remove(x);
	//}

	public function indexOf(x:T, ?fromIndex:Int):Int {
		return value.indexOf(x, fromIndex);
	}

	public function lastIndexOf(x:T, ?fromIndex:Int):Int {
		return value.lastIndexOf(x, fromIndex);
	}
	
	public function copy():Array<T>{
		return value.copy();
	}

	public function resize(len:Int):Void {
		value.resize(len);
	}
}
