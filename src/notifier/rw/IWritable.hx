package notifier.rw;

/**
 * @author Thomas Byrne
 */
interface IWritable <T>
{
	function write(value:T):Void;
}