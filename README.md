# EventEngine

A simple framework to count events in an app. An event is a named counter. Events can be saved by an event engine which manages different events. These events can for instance be used to make score based decisions like showing a rating dialog when a certain score has been reached. The event engine also persists the events.

## Table of Contents

- [Installation](#installation)
  - [Swift Package](#swiftpackage)
- [Usage](#usage)
- [Architecture](#architecture)
- [License](#license)

## Installation

### [Swift Package](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescription.md#supportedplatform)

Just integrate the EventEngine via Xcode 11 - that's it!

## Usage

Here a small and simple example how this package can be used to track the number of App starts:

```
import EventEngine

func applicationDidFinishLaunching() {

    let eventEngine = EventEngineFactory.userDefaultPersistingEventEngine

    eventEngine.fire(event: "AppStart", incrementBy: 1)

    // Persist the current state of the modified event in user defaults
    eventEngine.synchronize()
}
```

To ask for the current event state of an event an event engine musst be used:

```
let eventEngine = EventEngineFactory.userDefaultPersistingEventEngine

let appStartEventState = eventEngine.state(ofEvent: "AppStart")
let appStartCount = appStartEventState.count
```

### Event states

Event states have multiple functionalities. They store:

- the counter of an event.
- its first occurrence and its last occurrence as a timer interval.
- if the event is disabled or enabled (a disabled event returns the count of 0).
- if the event occurred in the last 24 hours.

## Interface

<img src="/Resources/EventEngineUML.png">

## License

**EventEngine** is available under the MIT license. See the [LICENSE](https://github.com/apploft/EventEngine/blob/master/LICENSE) file for more info.
