package notifier.api;

/**
 * @author Thomas Byrne
 */
interface IReadWritable<T> extends IReadable<T> extends IWritable<T> {
	public var value(get, set):Null<T>;
}
