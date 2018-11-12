//
//  EventEngine.swift
//  EventEngine
//
//  Created by Tino Rachui on 19.03.18.
//  Copyright © 2018 apploft. All rights reserved.
//

import Foundation

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

@objc public class EventEngineFactory: NSObject {
    static public var userDefaultsBasedEventEngine: EventEngine {
        return EventEngineImpl()
    }
}
