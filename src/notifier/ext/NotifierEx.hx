package notifier.ext;

import notifier.Notifier;

class NotifierEx extends Notifer
{
    var _setHandlers:Array<T->Void>;
	var _unsetHandlers:Array<T->Void>;
    var actions:Array<T->T>;

    override function set_value(value:Null<T>):Null<T> 
	{
		value = applyActions(value);
		if (!changeRequired(value)) return value;
        applyUnsets();
		_value = value;
        applySets();
		this.dispatch();
		return value;
	}
    
    public function addAction(action:T->T) 
	{
		if (actions == null) actions = [];
		actions.push(action);
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