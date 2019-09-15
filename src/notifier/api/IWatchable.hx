package notifier.api;

/**
 * @author Thomas Byrne
 */
interface IWatchable<T> {
	function watch(handler:T->Void, ?priority:Null<Int>):IWatchable<T>;
	function unwatch(handler:T->Void):Void;
}
