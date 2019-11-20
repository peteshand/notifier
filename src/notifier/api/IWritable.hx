package notifier.api;

interface IWritable<T> {
	public var value(null, set):Null<T>;
	function write(value:T):Void;
}
