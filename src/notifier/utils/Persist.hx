package notifier.utils;

import utils.DocStore;
import notifier.Notifier;
import notifier.MapNotifier;
import notifier.MapNotifier3;
import haxe.Serializer;
import haxe.Unserializer;

@:access(notifier.Notifier)
class Persist {
	static var notifiers = new Map<String, Notifier<Dynamic>>();
	static var maps = new Map<String, MapNotifier3<Dynamic, Dynamic>>();

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

	static function resetMap(map:MapNotifier3<Dynamic, Dynamic>) {
		if (map == null)
			return;

		map.clear();
	}

	public static function registerMap(notifier:MapNotifier<Dynamic>, id:String) {
		var data = getNPData(id);
		if (data.localData != null) {
			var a:Array<Dynamic> = data.localData;
			for (i in 0...a.length)
				notifier.add(a[i]);
		}

		var onChange = function(a:Array<Dynamic> = null) {
			data.sharedObject.setProperty("value", notifier.allItems);
			data.sharedObject.flush();
		}

		notifier.onAdd.add(onChange);
		notifier.onChange.add(onChange);
		notifier.onRemove.add(onChange);
	}

	public static function registerMap3(map3:MapNotifier3<Dynamic, Dynamic>, id:String) {
		var data = getNPData(id);
		if (data.localData != null) {
			var a:String = data.localData;
			if (a != null) {
				var unserializer = new Unserializer(a);
				map3.value = unserializer.unserialize();
			}
		}

		var serializer = function() {
			data.sharedObject.setProperty("value", Serializer.run(map3.value));
			data.sharedObject.flush();
		}

		map3.onAdd.add((key:Dynamic, value:Dynamic) -> serializer());
		map3.onChange.add((key:Dynamic, value:Dynamic) -> serializer());
		map3.onRemove.add((key:Dynamic) -> serializer());
		map3.add(() -> serializer());

		maps.set(id, map3);
	}

	static function getNPData(id:String):NPData {
		var sharedObject:DocStore = DocStore.getLocal("notifiers/" + id);
		return {
			sharedObject: sharedObject,
			localData: Reflect.getProperty(sharedObject.data, "value")
		}
	}
}

typedef NPData = {
	sharedObject:DocStore,
	localData:Dynamic
}
