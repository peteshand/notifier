package notifier.utils;

import delay.Delay;
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
			silentlySet:Bool = true, ?serializerType:SerializerType) {
		if (map != null) {
			registerMap(map, id, key);
		} else if (array != null) {
			registerArray(array, id);
		} else if (notifier != null) {
			registerNotifier(notifier, id, silentlySet, serializerType);
		}
	}

	static function registerNotifier<T>(notifier:Notifier<T>, id:String, silentlySet:Bool = true, ?serializerType:SerializerType) {
		var data = getNPData(id, serializerType);
		var value:T = data.value;
		if (value != null) {
			if (silentlySet)
				notifier.silentlySet(value);
			else
				notifier.value = value;
		}

		var serializer = function() {
			var _value:String = serialize(notifier.value, serializerType);
			if (id == 'content/names') {
				trace("_value = " + _value);
			}
			data.sharedObject.setProperty("value", _value);
			data.sharedObject.flush();
		}
		notifier.add(() -> {
			Delay.killDelay(serializer);
			Delay.nextFrame(serializer);
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
			var map:{h:Dynamic} = data.value;
			if (map != null) {
				var local:Dynamic = map.h;
				if (local != null) {
					var fields = Reflect.fields(local);
					for (field in fields) {
						var value = Reflect.getProperty(local, field);
						mapNotifier.value.set(untyped field, value);
					}
				}
			}
		} else {
			var local:T = data.value;
			if (local != null) {
				mapNotifier.value.set(key, local);
			}
		}

		var serializer = function() {
			var _key:String = null;
			var _value:String = null;

			if (key == null) {
				_key = 'value';
				_value = serialize(mapNotifier.value);
				// data.sharedObject.setProperty("value", serialize(mapNotifier.value));
			} else {
				_key = Std.string(key);
				_value = serialize(mapNotifier.value.get(key));
				// data.sharedObject.setProperty(Std.string(key), serialize(mapNotifier.value.get(key)));
			}

			if (id == 'content/names') {
				trace([_key, _value]);
			}

			data.sharedObject.setProperty(_key, _value);
			data.sharedObject.flush();
		}

		mapNotifier.onAdd.add((key:K, value:T) -> {
			Delay.killDelay(serializer);
			Delay.nextFrame(serializer);
		});
		mapNotifier.onChange.add((key:K, value:T) -> {
			Delay.killDelay(serializer);
			Delay.nextFrame(serializer);
		});
		mapNotifier.onRemove.add((key:K) -> {
			Delay.killDelay(serializer);
			Delay.nextFrame(serializer);
		});
		mapNotifier.add(() -> {
			Delay.killDelay(serializer);
			Delay.nextFrame(serializer);
		});

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
			var _value:String = serialize(arrayNotifier.value);
			if (id == 'content/names') {
				trace("_value = " + _value);
			}
			data.sharedObject.setProperty("value", _value);
			data.sharedObject.flush();
		}

		arrayNotifier.onChange.add((key:Int, value:T) -> {
			Delay.killDelay(serializer);
			Delay.nextFrame(serializer);
		});
		arrayNotifier.add(() -> {
			Delay.killDelay(serializer);
			Delay.nextFrame(serializer);
		});

		arrays.set(id, arrayNotifier);
	}

	static var sharedObjects = new Map<String, DocStore>();

	static function getNPData<K>(id:String, key:String = null, ?serializerType:SerializerType):NPData {
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
				value = unserialize(valueObj, serializerType);
			} catch (e:Dynamic) {
				trace(e);
			}
		}
		return {
			sharedObject: sharedObject,
			value: value
		}
	}

	static function serialize(value:Dynamic, ?serializerType:SerializerType):String {
		if (serializerType == SerializerType.HAXE_SERIALIZER)
			return Serializer.run(value);
		else if (serializerType == SerializerType.JSON)
			return haxe.Json.stringify(value);
		return value;
	}

	static function unserialize(value:Dynamic, ?serializerType:SerializerType):String {
		if (serializerType == SerializerType.HAXE_SERIALIZER) {
			var unserializer = new Unserializer(value);
			return unserializer.unserialize();
		} else if (serializerType == SerializerType.JSON)
			return haxe.Json.parse(value);
		return value;
	}
}

typedef NPData = {
	sharedObject:DocStore,
	value:Dynamic
}

@:enum abstract SerializerType(String) from String to String {
	public var HAXE_SERIALIZER = 'haxeSerializer';
	public var JSON = 'json';
	public var NONE = 'none';
}
