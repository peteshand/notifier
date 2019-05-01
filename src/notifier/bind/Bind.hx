package notifier.bind;

class Bind
{
	public static function property(notifier:Notifier<Dynamic>, object:Dynamic, propName:String, fireOnAdd:Bool=true)
	{
		return base(notifier, fireOnAdd, () -> { 
			Reflect.setProperty(object, propName, notifier.value);
		});
	}

    public static function toggle(notifier:Notifier<Null<Bool>>, active:Void -> Void, inactive:Void -> Void, fireOnAdd:Bool=true)
	{
		return base(notifier, fireOnAdd, () -> { 
			if (notifier.value == true) active();
			else if (notifier.value == false) inactive();
		});
	}

	static function base(notifier:Notifier<Dynamic>, fireOnAdd:Bool, func:Void -> Void)
	{
		notifier.add(func);
		if (fireOnAdd) func();
		return () -> { notifier.remove(func); };
	}
}