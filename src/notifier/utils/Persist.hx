package notifier.utils;

import utils.DocStore;
import notifier.Notifier;
import notifier.MapNotifier;
import haxe.Serializer;
import haxe.Unserializer;

@:access(notifier.Notifier)
class Persist {
	static var notifiers = new Map<String, Notifier<Dynamic>>();
	static var maps = new Map<String, MapNotifier<Dynamic, Dynamic>>();

	public static function register(notifier:Notifier<Dynamic>, id:String, silentlySet:Bool = true) {
		var data = getNPData(id);

		if (data.localData != null) {
			if (silentlySet)
				notifier.silentlySet(data.localData);
			else
				notifier.value = data.localData;
		}
		notifier.add(() -> {
			data.sharedObject.setProperty("value", notifier.value);
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

	@:deprecated public static function registerMap3(map3:MapNotifier<Dynamic, Dynamic>, id:String, ?key:Dynamic) {
		registerMap(map3, id, key);
	}

	public static function registerMap(map3:MapNotifier<Dynamic, Dynamic>, id:String, ?key:Dynamic) {
		var data = getNPData(id, key);
		if (data.localData != null) {
			var a:String = data.localData;
			if (a != null) {
				try {
					var unserializer = new Unserializer(a);
					if (key == null) {
						var local:MapNotifier<Dynamic, Dynamic> = unserializer.unserialize();
						trace(local);
						for (key => value in local.keyValueIterator()) {
							map3.value.set(key, value);
						}
					} else {
						var v = unserializer.unserialize();
						trace(v);
						map3.value.set(key, unserializer.unserialize());
					}
				} catch (e:Dynamic) {
					trace(e);
					trace(a);
				}
			}
		}

		var serializer = function() {
			if (key == null) {
				data.sharedObject.setProperty("value", Serializer.run(map3.value));
			} else {
				data.sharedObject.setProperty(key, Serializer.run(map3.value.get(key)));
			}

			data.sharedObject.flush();
		}

		map3.onAdd.add((key:Dynamic, value:Dynamic) -> serializer());
		map3.onChange.add((key:Dynamic, value:Dynamic) -> serializer());
		map3.onRemove.add((key:Dynamic) -> serializer());
		map3.add(() -> serializer());

		maps.set(id, map3);
	}

	static function getNPData(id:String, key:Dynamic = 'value'):NPData {
		var sharedObject:DocStore = DocStore.getLocal("notifiers/" + id);
		return {
			sharedObject: sharedObject,
			localData: Reflect.getProperty(sharedObject.data, key)
		}
	}
}

typedef NPData = {
	sharedObject:DocStore,
	localData:Dynamic
}
