package notifier.ext;

import notifier.Notifier;

/**
 * @author Thomas Byrne
 */
class NotifierEx<T> extends Notifier<T>
{
    var _setHandlers:Array<T->Void>;
	var _unsetHandlers:Array<T->Void>;
    
	override function get_value():Null<T> {
		return _value;
	}

    override function set_value(value:Null<T>):Null<T> 
	{
		value = applyModifiers(value);
		if (!changeRequired(value)) return value;
        applyUnsets();
		_value = value;
        applySets();
		this.dispatch();
		return value;
	}

    inline function applyUnsets()
	{
		if (_value != null && _unsetHandlers != null) {
			for(handler in _unsetHandlers) handler(_value);
		}
	}

    inline function applySets()
	{
		if (_value != null && _setHandlers != null) {
			for(handler in _setHandlers) handler(_value);
		}
	}

    public function set(handler:T->Void):NotifierEx<T> 
	{
		if (_setHandlers == null)_setHandlers = [];
		_setHandlers.push(handler);
		return this;
	}
	
	/**
	 * unset handlers are unshifted onto the stack so that unbinding happens in 
	 * the reverse direction to binding (last added first).
	 */
	public function unset(handler:T->Void):NotifierEx<T>
	{
		if (_unsetHandlers == null)_unsetHandlers = [];
		_unsetHandlers.unshift(handler);
		return this;
	}
}