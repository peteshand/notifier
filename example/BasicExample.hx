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

package;

import notifier.Notifier;

class BasicExample
{
	public static function main()
	{
		new BasicExample();
	}

	var intNotifier:Notifier<Int>;

	public function new()
	{
		// This is an example of how to create a Notifier 
		// of type Int and give it a default value of 5
		intNotifier = new Notifier<Int>(5);
		
		// Add a standard callback listener to value changes on `intNotifier`
		intNotifier.add(onValueChangeA);

		// Add a standard callback listener to value changes on `intNotifier` that is 
		// automatically removed after the first value change
		intNotifier.add(onValueChangeB, true);
		
		// Add a standard callback listener to value changes on `intNotifier` with a 
		// priority of 10 (higher is called first)
		intNotifier.add(onValueChangeC, 10);

		// Add a standard callback listener to value changes on `intNotifier` that is automatically 
		// removed after the first value change and with a priority of 100 (higher is called first)
		intNotifier.add(onValueChangeD, true, 100);
		
		// set the value of `intNotifier` to 10
		// callbacks; D, C, A, and B will be fired in that order
		intNotifier.value = 10;

		// set the value of `intNotifier` to 100
		// callbacks; C, and A will be fired in that order
		intNotifier.value = 100;
		
		// set the value of `intNotifier` to 200
		// callbacks; C, and A will be fired in that order
		intNotifier.value = 200;

		// again set the value of `intNotifier` to 200, 
		// no callbacks will be triggered, as the value hasn't changed
		intNotifier.value = 200;
		
		// setting `requireChange` to false will result in callbacks being fired 
		// regardless of if the notifer's value is changed or not when it's value is set.
		intNotifier.requireChange = false;

		// set the value of `intNotifier` to 200
		// callbacks; C, and A will be fired in that order
		intNotifier.value = 200;

		// calling notifier.silentlySet(value) allows you to change the 
		// value of the notifier without any callbacks being triggered
		intNotifier.silentlySet(100);

		// Manually dispatch
		intNotifier.dispatch();
	}

	function onValueChangeA()
	{
		trace("A: value = " + intNotifier.value);
	}

	function onValueChangeB()
	{
		trace("B: value = " + intNotifier.value);
	}

	function onValueChangeC()
	{
		trace("C: value = " + intNotifier.value);
	}

	function onValueChangeD()
	{
		trace("D: value = " + intNotifier.value);
	}
}
