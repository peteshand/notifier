package notifier.rw;

import notifier.watch.IWatchable;

/**
 * @author Thomas Byrne
 */
interface IReadable<T> extends IWatchable<T> 
{
	function read():T;
}