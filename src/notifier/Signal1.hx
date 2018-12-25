package notifier;

import notifier.Signal.BaseSignal;

class Signal1<T> extends BaseSignal<T -> Void>
{
    public var value:T;

	public function dispatch(value1:T)
	{
		sortPriority();
		this.value = value1;
		disptachCallbacks();
	}

	override function disptachCallback(callback:T -> Void)
	{
		callback(value);
	}
}