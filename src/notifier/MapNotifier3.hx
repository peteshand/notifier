package notifier;

import haxe.Json;
import signals.Signal1;
import signals.Signal2;
import notifier.Notifier;

class MapNotifier3<K, T> extends Notifier<Map<K, T>> {
	#if js
	@:noCompletion private static function __init__() {
		untyped Object.defineProperties(MapNotifier3.prototype, {
			"array": {
				get: untyped __js__("function () { return this.get_array (); }"),
				set: untyped __js__("function (v) { return this.set_array (v); }")
			},
		});
	}
	#end

	public var onAdd = new Signal2<K, T>();
	public var onRemove = new Signal1<K>();
	public var onChange = new Signal2<K, T>();
	public var array(get, null):Array<T>;

	var notifiers = new Map<String, Notifier<T>>();

	public function new(?defaultValue:Map<K, T>, ?id:String, ?fireOnAdd:Bool = false) {
		if (defaultValue == null)
			defaultValue = untyped new Map<String, T>();
		super(defaultValue, id, fireOnAdd);
	}

	public function get(k:K):T {
		return value.get(k);
	}

	public function set(k:K, v:T):Void {
		var alreadyExists:Bool = exists(k);
		var currentValue:T = value.get(k);
		value.set(k, v);
		if (alreadyExists) {
			if (currentValue != v) {
				onChange.dispatch(k, v);
				dispatchNotifiers(k, v);
				this.dispatch();
			}
		} else {
			onAdd.dispatch(k, v);
			dispatchNotifiers(k, v);
			this.dispatch();
		}
	}

	public function exists(k:K):Bool {
		if (value == null)
			return false;
		return value.exists(k);
	}

	public function removeItem(k:K):Bool {
		if (value == null)
			return false;
		var removed:Bool = value.remove(k);
		onRemove.dispatch(k);
		dispatchNotifiers(k, null);
		this.dispatch();
		return removed;
	}

	public function keys():Iterator<K> {
		return value.keys();
	}

	public function iterator():Iterator<T> {
		return value.iterator();
	}

	public function keyValueIterator():KeyValueIterator<K, T> {
		return value.keyValueIterator();
	}

	public function copy():Map<K, T> {
		return value.copy();
	}

	override public function toString() {
		return value.toString();
	}

	function get_array():Array<T> {
		var a:Array<T> = [];
		for (item in this.iterator()) {
			a.push(item);
		}
		return a;
	}

	public function clear() {
		for (key in keys()) {
			removeItem(key);
		}
	}

	/////////////////////////////////////////////////

	public function getNotifier(key:K):Notifier<T> {
		var notifier = notifiers.get(Std.string(key));
		if (notifier == null) {
			notifier = new Notifier<T>();
			notifiers.set(Std.string(key), notifier);
		}
		return notifier;
	}

	inline function dispatchNotifiers(key:K, value:T) {
		var notifier = notifiers.get(Std.string(key));
		if (notifier != null) {
			notifier.value = value;
		}
	}
}
