//
// Created by apploft on 19.03.18.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/// A protocol which represents the state and its associated properties and operations an event can have.
public protocol EventState: NSObjectProtocol {
    /// The name of the associated event.
    var name: String { get }
    /// The first occurrence of the associated event, saved as a time interval.
    var firstOccurrence: TimeInterval { get }
    /// The last occurrence of the associated event, saved as a time interval.
    var lastOccurrence: TimeInterval { get }
    /// The current count of the associated event. If The event is disabled the count returns 0.
    var count: Int { get }
    /// A bool which indicates if the associated event is disabled. The count of a disabled event is 0.
    var disabled: Bool { get set }
    /// This property presents the name, the first plus last occurrence and the count of the associated event.
    var logString: String { get }
    
    /// Updates the count of the event by a given number.
    /// - Parameter incrementBy: The number which will be added to the count. The number can be negative.
    func update(incrementBy: Int)
    /// Resets the count, the first and last occurrence of the associated event to 0.
    func reset()
    
    /// This function indicates whether the associated event occurred in the last 24 hours.
    /// - returns: A bool indicating whether the event occurred in the last 24 hours.
    func occurredInLastDay() -> Bool
}

/// A protocol which is be adapted by all event engines. This protocol makes sure that an event engine
/// implements the essential operations for managing events.
public protocol EventEngine {
    
    /// This property toggles whether the event engine should log its operations to the console.
    /**
    *Example*
        eventEngine.loggingEnabled = true
        eventEngine.fire("App Start", incrementBy: 1)
        -> Console prints: "Updated event App Start by: 1"
     */
    var loggingEnabled: Bool { get set }
    
    /// This function increments the counter of an event.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be updated.
    /// - Parameter incrementBy: The number which will be added to the
    ///                          counter of an event state. The number can also be negative.
    func fire(event: String, incrementBy: Int)
    /// This function resets an event. A reset sets the the count, the first and last occurrence of the associated event to 0.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be reseted.
    func reset(event: String)
    /// This function disables an event.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be disabled.
    func disable(event: String)
    /// This function enables an event.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be enabled.
    func enable(event: String)
    /// This function returns the event state of an event.
    /// - Parameter event: The name of the event.
    /// - returns: The event state of the event.
    func state(ofEvent: String) -> EventState
    
    /// This function persists all event changes stored in the memory cache to the user defaults.
    /// Call this function before terminating the app to make sure all changes are saved.
    func synchronize()
}
