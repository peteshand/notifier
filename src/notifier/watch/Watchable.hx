package notifier.watch;

import notifier.ext.NotifierEx;
import signal.Signal1;

/**
 * @author Thomas Byrne
 */
class Watchable<T> extends NotifierEx<T>
{
	public function watch(handler:T->Void, ?priority:Null<Int>)
	{
		add(handler, priority);
	}

	public function unwatch(handler:T->Void)
	{
		remove(handler);
	}
}