package notifier.api;

interface IReadable<T> extends IWatchable<T> {
	public var value(get, null):Null<T>;
	function read():T;
}
