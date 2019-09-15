package notifier.api;

/**
 * @author Thomas Byrne
 */
interface IReadable<T> extends IWatchable<T> {
	public var value(get, null):Null<T>;
	function read():T;
}
