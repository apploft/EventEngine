//
// Created by apploft on 19.03.18.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/// A protocol which represents the state and its associated properties and operations an event can have.
@objc public protocol EventState: NSObjectProtocol {
    var name: String { get }
    var firstOccurrence: TimeInterval { get }
    var lastOccurrence: TimeInterval { get }
    var count: Int { get }
    var disabled: Bool { get set }
    var logString: String { get }
    
    func update(incrementBy: Int)
    func reset()
    
    func occurredInLastDay() -> Bool
}

/// A protocol which should be adapted by all event engines. This protocol makes sure that an event engine implements the essential
/// operations for managing events.
@objc public protocol EventEngine: NSObjectProtocol {
    var loggingEnabled: Bool { get set }
    
    func fire(event: String, incrementBy: Int)
    func reset(event: String)
    func disable(event: String)
    func enable(event: String)
    func state(ofEvent: String) -> EventState
    
    // Persist the in memory state
    func synchronize()
}

/// This calss is a factory class, which generates event engines.
@objc public class EventEngineFactory: NSObject {
    
    /// This property returns an event engine, which persists its events in the user defaults.
    static public var userDefaultsBasedEventEngine: EventEngine {
        return EventEngineImpl()
    }
}
