package notifier.watch;

/**
 * @author Thomas Byrne
 */
interface IWatchable<T> 
{
	function watch(handler:T->Void, ?priority:Null<Int>):Void;
	function unwatch(handler:T->Void):Void;
}