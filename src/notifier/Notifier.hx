/*
Copyright 2018 P.J.Shand
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package notifier;

import signal.Signal;
class Notifier<T> extends Signal 
{
	public var requireChange:Bool = true;
	var _value:T;
	
	public var value(get, set):Null<T>;
	
	public function new(?defaultValue:T) 
	{
		_value = defaultValue;
		super();
	}
	
	function toString():String
	{
		return cast this.value;
	}
	
	function get_value():Null<T> 
	{
		return _value;
	}
	
	function set_value(value:Null<T>):Null<T> 
	{
		
		if (!changeRequired(value)) return value;
		_value = value;
		this.dispatch();
		return value;
	}

	public function silentlySet(value:T)
	{
		_value = value;
	}
	
	inline function changeRequired(value:Null<T>):Bool
	{
		return _value != value || !requireChange;
	}
}