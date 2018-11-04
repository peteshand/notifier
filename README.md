## Overview

Notifiers are a scalable and lightweight way to listen to changes to an object's value. Essentially they allow you to wrap any Type within a Notifier object and then listen to changes to the value.

Benefits:

* Mantain type safety / type hinting through use of generics.
* Add new fundamental object to build complex systems on top of.
* Removes the need to create getter/setters that check if the value has changed.
* Can act similar to single property Signals.

You can view some examples of notifier usage [here](https://github.com/peteshand/notifier).

### Importing

The Notifier class can be imported through notifier.Notifier

```haxe
import notifier.Notifier;
```

### Basic usage

This is an example of how to create a Notifier of type Int and give it a default value of 5.

```haxe
var notifier:Notifier<Int> = new Notifier<Int>(5);
```

Add a standard callback listener to value changes on *notifier*.

```haxe
notifier.add(() -> {
    trace("A: value = " + notifier.value);
});
```

Add a standard callback listener to value changes on *notifier* that is automatically removed after the first value change.

```
notifier.add(() -> {
    trace("B: value = " + notifier.value);
}, true);
```

Add a standard callback listener to value changes on *notifier* with a priority of 10 (higher priorities are called first).

```
notifier.add(() -> {
    trace("C: value = " + notifier.value);
}, 10);
```

Add a standard callback listener to value changes on *notifier* that is automatically removed after the first value change and with a priority of 100.

```
notifier.add(() -> {
    trace("D: value = " + notifier.value);
}, true, 100);
```

set the value of *notifier* to *10*

```haxe
notifier.value = 10;

// trace out:
// D: value = 10
// C: value = 10
// A: value = 10
// B: value = 10
```

set the value of *notifier* to *100*

```haxe
notifier.value = 100;

// trace out:
// C: value = 100
// A: value = 100
```

set the value of *notifier* to 200

```haxe
notifier.value = 200;

// trace out:
// C: value = 200
// A: value = 200
```

again set the value of *notifier* to 200, no callbacks will be triggered, as the value hasn't changed.

```haxe
notifier.value = 200;
```

setting *requireChange* to false will result in callbacks being fired regardless of if the notifer's value is changed or not when it's value is set.

```haxe
notifier.requireChange = false;
```

set the value of *notifier* to 200 callbacks; C, and A will be fired in that order.

```haxe
notifier.value = 200;

// trace out:
// C: value = 200
// A: value = 200
```

calling notifier.silentlySet(value) allows you to change the value of the notifier without any callbacks being triggered.

```haxe
notifier.silentlySet(100);
```

Manually dispatch.

```haxe
notifier.dispatch();
```

### Extending

Extending Notifers are super simple

```haxe
class MyNotifier extends Notifier<Bool>
{
	public function new()
	{
	    // passing 'true' as the default value
		super(true);
	}
}
```

Alternatively if you'll like to expose the Generic Type property, simply pass the Generic Type to the Notifier when extending it.

```haxe
class MyNotifier<T> extends Notifier<T>
{
	public function new(?defaultValue:T)
	{
		super(defaultValue);
	}
}
```
