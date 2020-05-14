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

import signals.Signal.BaseSignal;
import haxe.extern.EitherType;
import utils.FunctionUtil;
import notifier.api.IReadWritable;

typedef Func0or1<T> = EitherType<Void->Void, T->Void>;

@:expose("Notifier")
class Notifier<T> extends BaseSignal<Func0or1<T>> implements IReadWritable<T> {
	#if js
	@:noCompletion private static function __init__() {
		untyped Object.defineProperties(Notifier.prototype, {
			"value": {
				get: untyped js.Syntax.code("function () { return this.get_value (); }"),
				set: untyped js.Syntax.code("function (v) { return this.set_value (v); }")
			},
		});
	}
	#end

	public var requireChange:Bool = true;

	var modifiers:Array<T->T>;
	var defaultValue:T;
	var _value:T;

	public var value(get, set):Null<T>;

	var id:String;

	public function new(?defaultValue:T, ?id:String, ?fireOnAdd:Bool = false) {
		_value = this.defaultValue = defaultValue;
		this.id = id;
		super(fireOnAdd);
	}

	function toString():String {
		return cast this.value;
	}

	function get_value():Null<T> {
		return applyModifiers(_value);
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

	/*override function dispatchCallback(callback:Func0or1<T>) {
		try {
			callback1 = callback;
		} catch (e:Dynamic) {
			try {
				callback0 = callback;
			} catch (e:Dynamic) {
				throw "callback should match Void -> Void or T -> Void";
			}
		}
		if (callback1 != null) {
			callback1(value);
		} else if (callback0 != null) {
			callback0();
		}
	}*/
	override function dispatchCallback(callback:Void->Void) {
		callback();
	}

	override function dispatchCallback1(callback:Dynamic->Void) {
		callback(value);
	}

	override function dispatchCallback2(callback:Dynamic->Dynamic->Void) {
		throw "Notifier does not support two param dispatch";
	}

	@:deprecated public inline function addAction(action:T->T) {
		var warningMessage:String = "\nWARNING: addAction methed will be removed in a future release, use addModifier instead";
		#if js
		untyped __js__('console.warn(warningMessage)');
		#else
		trace(warningMessage);
		#end
		addModifier(action);
	}

	public function addModifier(modifier:T->T) {
		if (modifiers == null)
			modifiers = [];
		modifiers.push(modifier);
	}

	inline function applyModifiers(value:Null<T>) {
		if (modifiers != null)
			for (i in 0...modifiers.length)
				value = modifiers[i](value);
		return value;
	}

	public function read():T
		return this.value;

	public function write(value:T)
		this.value = value;

	// alternative to .add
	public inline function watch(handler:T->Void, ?priority:Null<Int> = null) {
		if (priority != null) {
			var warningMessage:String = "\nWARNING:the priority param will be removed from 'Notifier.watch' in a future release\nInstead use daisy chain methods, eg: obj.watch(callback).priority(1000);";
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
