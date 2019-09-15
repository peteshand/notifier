package notifier.api;

/**
 * @author Thomas Byrne
 */
interface IWritable<T> {
	public var value(null, set):Null<T>;
	function write(value:T):Void;
}
