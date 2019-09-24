package notifier.api;

interface IReadWritable<T> extends IReadable<T> extends IWritable<T> {
	public var value(get, set):Null<T>;
}
