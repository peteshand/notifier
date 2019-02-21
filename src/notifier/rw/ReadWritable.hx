package notifier.rw;

import notifier.watch.Watchable;

/**
 * @author Thomas Byrne
 */
class ReadWritable<T> extends Watchable<T> implements IReadWritable<T>
{
    public function read():T return this.value;
	public function write(value:T) this.value = value;
}