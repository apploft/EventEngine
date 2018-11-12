//
//  EventEngineImpl.swift
//  EventEngine
//
//  Created by Tino Rachui on 19.03.18.
//  Copyright © 2018 apploft. All rights reserved.
//

import Foundation

@objc public class EventStateImpl: NSObject, EventState, NSCoding {
    public var name: String
    public var firstOccurrence: TimeInterval = 0
    public var lastOccurrence: TimeInterval = 0
    var count_: Int = 0
    
    public var count: Int {
        return disabled ? 0 : count_
    }
    
    public var disabled: Bool = false
    
    public var logString: String {
        return "\(name): { first: \(firstOccurrence), last: \(lastOccurrence), count: \(count_) }"
    }
    
    init(name: String) {
        self.name = name
        firstOccurrence = 0
        lastOccurrence = 0
        count_ = 0
        disabled = false
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameKey) as! String
        firstOccurrence = aDecoder.decodeDouble(forKey: firstOccurrenceKey)
        lastOccurrence = aDecoder.decodeDouble(forKey: lastOccurrenceKey)
        count_ = Int(aDecoder.decodeInt64(forKey: countKey))
        disabled = aDecoder.decodeBool(forKey: disabledKey)
        
        super.init()
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(firstOccurrence, forKey: firstOccurrenceKey)
        aCoder.encode(lastOccurrence, forKey: lastOccurrenceKey)
        aCoder.encode(count_, forKey: countKey)
        aCoder.encode(disabled, forKey: disabledKey)
    }
    
    public func update(incrementBy: Int = 1) {
        count_ += incrementBy
        
        lastOccurrence = Date.timeIntervalSinceReferenceDate
        
        if (firstOccurrence == 0) {
            firstOccurrence = lastOccurrence
        }
    }
    
    public func reset() {
        count_ = 0
        firstOccurrence = 0
        lastOccurrence = 0
    }
    
    public func occurredInLastDay() -> Bool {
        return Date.timeIntervalSinceReferenceDate - lastOccurrence < EventStateImpl.OneDay
    }
    //
    // Private declaration
    //
    private static let OneDay: TimeInterval = 60 * 60 * 24
    
    private let nameKey = "EventState_NameKey"
    private let firstOccurrenceKey = "EventState_FirstOccurenceKey"
    private let lastOccurrenceKey = "EventState_LastOccurrenceKey"
    private let countKey = "EventState_CountKey"
    private let disabledKey = "EventState_DisabledKey"
}


@objc public class EventEngineImpl: NSObject, EventEngine {
    public var loggingEnabled: Bool = false
    var inMemoryDB: [String:EventState] = [:]
    
    public func fire(event: String, incrementBy: Int = 1) {
        let eventState = getEventState(event: event)
        
        eventState.update(incrementBy: incrementBy)
        
        log("Updated event '\(event)' by: \(incrementBy)")
    }
    
    public func reset(event: String) {
        let eventState = getEventState(event: event)
        
        eventState.reset()
        
        log("Reset event '\(event)'")
    }
    
    public func disable(event: String) {
        let eventState = getEventState(event: event)
        
        eventState.disabled = true
        
        log("Disabled event '\(event)'")
    }
    
    public func enable(event: String) {
        let eventState = getEventState(event: event)
        
        eventState.disabled = false
        
        log("Enabled event '\(event)'")
    }
    
    public func state(ofEvent: String) -> EventState {
        let eventState = getEventState(event:ofEvent)
        
        log(eventState.logString)
        
        return eventState
    }
    
    // Persist the in memory state
    public func synchronize() {
        let userDefaults = UserDefaults.standard
        
        inMemoryDB.forEach { (key, eventState) in
            let data = NSKeyedArchiver.archivedData(withRootObject: eventState)
            
            userDefaults.set(data, forKey: key)
        }
        
        userDefaults.synchronize()
        
        log("Synchronized in memory event engine database")
    }
    
    private func getEventState(event: String) -> EventState {
        var eventState = inMemoryDB[event]
        let userDefaults = UserDefaults.standard
        
        if eventState == nil, let eventStateData = userDefaults.object(forKey: event) as? Data {
            eventState = NSKeyedUnarchiver.unarchiveObject(with: eventStateData) as? EventState
            inMemoryDB[event] = eventState
        }
        
        if eventState == nil {
            eventState = EventStateImpl(name: event)
            inMemoryDB[event] = eventState
        }
        return eventState!
    }
    
    private func log(_ message: String) {
        guard loggingEnabled else {
            return
        }
        
        print(message)
    }
}
