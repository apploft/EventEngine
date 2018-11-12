EventEngine
===========

A simple framework to count events in an app. An event is basically just a named counter an can be used to implement a score engine which counts different events. These events can for 
instance be used to make score based decisions like showing a rating dialog when a certain score has been reached.

Swift:

```swift
	import EventEngine
	
	let eventEngine = EventEngineFactory.userDefaultsBasedEventEngine

	eventEngine.fire(event: "AnEventName", incrementBy: 1)

	// Persist the current state of the modified events
	eventEngine.synchronize()
```
