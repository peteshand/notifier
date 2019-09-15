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

import signal.Signal.BaseSignal;
import haxe.extern.EitherType;
import utils.FunctionUtil;
import notifier.api.IReadWritable;

// Void -> Void || Generic -> Void
typedef Func0or1<T> = EitherType<Void->Void, T->Void>;

/**
 * @author P.J.Shand
 */
class Notifier<T> extends BaseSignal<Func0or1<T>> implements IReadWritable<T> {
	#if js
	@:noCompletion private static function __init__() {
		untyped Object.defineProperties(Notifier.prototype, {
			"value": {
				get: untyped __js__("function () { return this.get_value (); }"),
				set: untyped __js__("function (v) { return this.set_value (v); }")
			},
		});
	}
	#end

	public var requireChange:Bool = true;

	var _value:T;

	public var value(get, set):Null<T>;

	var id:String;

	public function new(?defaultValue:T, ?id:String, ?fireOnAdd:Bool = false) {
		_value = defaultValue;
		this.id = id;
		super(fireOnAdd);
	}

	function toString():String {
		return cast this.value;
	}

	function get_value():Null<T> {
		return _value;
	}

	function set_value(value:Null<T>):Null<T> {
		if (!changeRequired(value))
			return value;
		_value = value;
		this.dispatch();
		return value;
	}

	public function silentlySet(value:T) {
		_value = value;
	}

	inline function changeRequired(value:Null<T>):Bool {
		return _value != value || !requireChange;
	}

	public function dispatch() {
		sortPriority();
		dispatchCallbacks();
	}

	var callback0:Void->Void;
	var callback1:T->Void;

	override function dispatchCallback(callback:Func0or1<T>) {
		#if (haxe_ver >= 4.0)
		if (Std.is(callback, Void -> Void)) {
			callback0 = untyped callback;
			callback0();
		} else {
			callback1 = untyped callback;
			callback1(value);
		}
		#else
		try {
			callback1 = callback;
			callback1(value);
		} catch (e:Dynamic) {
			callback0 = callback;
			callback0();
		}
		#end
	}

	public function read():T
		return this.value;

	public function write(value:T)
		this.value = value;

	// alternative to .add
	public inline function watch(handler:T->Void, ?priority:Null<Int>) {
		if (priority != 0) {
			var warningMessage:String = "\nWARNING:the rpriority param will be removed from 'Notifier.watch' in a future release\nInstead use daisy chain methods, eg: obj.watch(callback).priority(1000);";
			#if js
			untyped __js__('console.warn(warningMessage)');
			#else
			trace(warningMessage);
			#end
		}
		add(handler).priority(priority);
		return this;
	}

	// alternative to .remove
	public inline function unwatch(handler:T->Void) {
		remove(handler);
	}
}
