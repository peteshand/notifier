package notifier.utils;

import utils.DocStore;
import notifier.Notifier;
import notifier.MapNotifier;
import haxe.Serializer;
import haxe.Unserializer;

@:access(notifier.Notifier)
class Persist {
	static var maps = new Map<String, MapNotifier<Dynamic, Dynamic>>();
	static var arrays = new Map<String, ArrayNotifier<Dynamic>>();
	static var notifiers = new Map<String, Notifier<Dynamic>>();

	public static function register<T>(?map:MapNotifier<Dynamic, T>, ?array:ArrayNotifier<T>, ?notifier:Notifier<T>, id:String, ?key:Dynamic,
			silentlySet:Bool = true) {
		if (map != null) {
			registerMap(map, id);
		} else if (array != null) {
			registerArray(array, id);
		} else if (notifier != null) {
			registerNotifier(notifier, id, key);
		}
	}

	static function registerNotifier<T>(notifier:Notifier<T>, id:String, silentlySet:Bool = true) {
		var data = getNPData(id);
		var value:T = data.value;
		if (value != null) {
			if (silentlySet)
				notifier.silentlySet(value);
			else
				notifier.value = value;
		}
		notifier.add(() -> {
			data.sharedObject.setProperty("value", Serializer.run(notifier.value));
			data.sharedObject.flush();
		});
		notifiers.set(id, notifier);
	}

	public static function clear(id:String, wildcard:Bool = false) {
		if (wildcard) {
			for (key in notifiers.keys()) {
				if (key.indexOf(id) == 0) {
					reset(notifiers.get(key));
				}
			}
			for (key in maps.keys()) {
				if (key.indexOf(id) == 0) {
					resetMap(maps.get(key));
				}
			}
		} else {
			reset(notifiers.get(id));
			resetMap(maps.get(id));
			resetArray(arrays.get(id));
		}
	}

	static function reset(notifier:Notifier<Dynamic>) {
		if (notifier == null)
			return;
		notifier.value = notifier.defaultValue;
	}

	static function resetMap(map:MapNotifier<Dynamic, Dynamic>) {
		if (map == null)
			return;
		map.clear();
	}

	static function resetArray(array:ArrayNotifier<Dynamic>) {
		if (array == null)
			return;
		array.resize(0);
	}

	// use register(...) instead
	static function registerMap<K, T>(mapNotifier:MapNotifier<K, T>, id:String, ?key:Dynamic) {
		var data = getNPData(id, key);
		if (key == null) {
			var local:Map<K, T> = data.value;
			if (local != null) {
				for (key => value in local.keyValueIterator()) {
					mapNotifier.value.set(key, value);
				}
			}
		} else {
			var local:T = data.value;
			if (local != null) {
				mapNotifier.value.set(key, local);
			}
		}

		var serializer = function() {
			if (key == null) {
				data.sharedObject.setProperty("value", Serializer.run(mapNotifier.value));
			} else {
				data.sharedObject.setProperty(Std.string(key), Serializer.run(mapNotifier.value.get(key)));
			}

			data.sharedObject.flush();
		}

		mapNotifier.onAdd.add((key:K, value:T) -> serializer());
		mapNotifier.onChange.add((key:K, value:T) -> serializer());
		mapNotifier.onRemove.add((key:K) -> serializer());
		mapNotifier.add(() -> serializer());

		maps.set(id, mapNotifier);
	}

	// use register(...) instead
	static function registerArray<T>(arrayNotifier:ArrayNotifier<T>, id:String) {
		var data = getNPData(id);
		var local:Array<T> = data.value;
		if (local != null) {
			for (i in 0...local.length) {
				arrayNotifier.value[i] = local[i];
			}
		}

		var serializer = function() {
			data.sharedObject.setProperty("value", Serializer.run(arrayNotifier.value));
			data.sharedObject.flush();
		}

		arrayNotifier.onChange.add((key:Int, value:T) -> serializer());
		arrayNotifier.add(() -> serializer());

		arrays.set(id, arrayNotifier);
	}

	static var sharedObjects = new Map<String, DocStore>();

	static function getNPData<K>(id:String, key:String = null):NPData {
		var _uid:String = "notifiers/" + id;
		var sharedObject:DocStore = sharedObjects.get(_uid);
		if (sharedObject == null) {
			sharedObject = DocStore.getLocal(_uid);
			sharedObjects.set(_uid, sharedObject);
		}
		if (key == null)
			key = untyped 'value';
		var valueObj:Dynamic = Reflect.getProperty(sharedObject.data, Std.string(key));
		var value:Dynamic = null;
		if (valueObj != null) {
			try {
				var unserializer = new Unserializer(valueObj);
				value = unserializer.unserialize();
			} catch (e:Dynamic) {
				trace(e);
			}
		}
		return {
			sharedObject: sharedObject,
			value: value
		}
	}
}

typedef NPData = {
	sharedObject:DocStore,
	value:Dynamic
}
