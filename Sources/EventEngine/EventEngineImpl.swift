//
// Created by apploft on 19.03.18.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/// This class implements an basic event state an event can have.
/// One trait of this event state class is that a deactivated event returns a count of 0.
/// In addition, reseting an event sets it's count, first plus last occurrence to 0 and enables it.
@objc public class EventStateImpl: NSObject, EventState, NSCoding {
    
    //MARK:- Public Properties
    /// The name of the event.
    public var name: String
    /// The first occurrence of the event, saved as a time interval.
    public var firstOccurrence: TimeInterval = 0
    /// The last occurrence of the event, saved as a time interval.
    public var lastOccurrence: TimeInterval = 0
    var count_: Int = 0
    
    /// The current count of the event. If The event is disabled the count returns 0.
    public var count: Int {
        return disabled ? 0 : count_
    }
    
    /// A bool which indicates if the event is disabled. The count of a disabled event is 0.
    public var disabled: Bool = false
    
    /// This property presents the name, the first plus last occurrence and the count of the event.
    public var logString: String {
        return "\(name): { first: \(firstOccurrence), last: \(lastOccurrence), count: \(count_) }"
    }
    
    //MARK:- Init
    /// Use this Initializer to create an EventState.
    /// Default values: First and last occurrence is set to 0, aswell as the count. The EventState is set to enabled.
    /// - Parameter name: The name of the event.
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
    
    //MARK:- Interface
     /// Use this function to encode an event state.
    /// - Parameter aCoder: A class which enables archiving and will encode the event state.
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(firstOccurrence, forKey: firstOccurrenceKey)
        aCoder.encode(lastOccurrence, forKey: lastOccurrenceKey)
        aCoder.encode(count_, forKey: countKey)
        aCoder.encode(disabled, forKey: disabledKey)
    }
    
    /// Updates the count of the event by a given number.
    /// - Parameter incrementBy: The number which will be added to the count. The number can be negative.
    public func update(incrementBy: Int = 1) {
        count_ += incrementBy
        
        lastOccurrence = Date.timeIntervalSinceReferenceDate
        
        if (firstOccurrence == 0) {
            firstOccurrence = lastOccurrence
        }
    }
    
    /// Resets the count, the first and last occurrence of the event.
    public func reset() {
        count_ = 0
        firstOccurrence = 0
        lastOccurrence = 0
    }
    
    /// This function indicates whether the event occurred in the last 24 hours.
    /// - returns: A bool indicating whether the event occurred in the last 24 hours.
    public func occurredInLastDay() -> Bool {
        return Date.timeIntervalSinceReferenceDate - lastOccurrence < EventStateImpl.OneDay
    }

    //MARK:- Private Properties
    private static let OneDay: TimeInterval = 60 * 60 * 24
    
    private let nameKey = "EventState_NameKey"
    private let firstOccurrenceKey = "EventState_FirstOccurenceKey"
    private let lastOccurrenceKey = "EventState_LastOccurrenceKey"
    private let countKey = "EventState_CountKey"
    private let disabledKey = "EventState_DisabledKey"
}

/// This class is an event engine which persists its cache into user defaults.
/// Here a small example how the app start can be saved and fetched as an event:
/**
 *Example*
 
     let eventEngine = EventEngineImpl()
     eventEngine.fire(event: "AppStart", incrementBy: 1)

     // Persist the current state of the modified event
     eventEngine.synchronize()
      
     let appStartEventState = eventEngine.state(ofEvent: "AppStart")
     let appStartCount = appStartEventState.count
 */
@objc public class EventEngineImpl: NSObject, EventEngine {
    
    //MARK:- Properties
    
    /// This property toggles whether the event engine should log its operations to the console.
    /**
    *Example*
               
        eventEngine.fire("App Start", incrementBy: 1)
        -> Console prints: "Updated event App Start by: 1"
     */
    public var loggingEnabled: Bool = false
    var inMemoryDB: [String:EventState] = [:]
    
    //MARK:- Interface
    /// This function increments the counter of an event.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be updated.
    /// - Parameter incrementBy: The number which will be added to the
    ///                          counter of an event state. The number can also be negative.
    public func fire(event: String, incrementBy: Int = 1) {
        let eventState = getEventState(event: event)
        
        eventState.update(incrementBy: incrementBy)
        
        log("Updated event '\(event)' by: \(incrementBy)")
    }
    
    /// This function resets an event.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be reseted.
    public func reset(event: String) {
        let eventState = getEventState(event: event)
        
        eventState.reset()
        
        log("Reset event '\(event)'")
    }

    /// This function disables an event.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be disabled.
    public func disable(event: String) {
        let eventState = getEventState(event: event)
        
        eventState.disabled = true
        
        log("Disabled event '\(event)'")
    }

    /// This function enables an event.
    /// The change is stored in the memory cache.
    /// - Parameter event: The name of the event, which will be enabled.
    public func enable(event: String) {
        let eventState = getEventState(event: event)
        
        eventState.disabled = false
        
        log("Enabled event '\(event)'")
    }
    
    /// This function returns the event state of an event.
    /// - Parameter event: The name of the event.
    /// - returns: The event state of the event.
    public func state(ofEvent: String) -> EventState {
        let eventState = getEventState(event:ofEvent)
        
        log(eventState.logString)
        
        return eventState
    }
    
    /// This function persists all event changes stored in the memory cache to the user defaults.
    /// Call this function to make sure all changes are saved for the next app start.
    public func synchronize() {
        let userDefaults = UserDefaults.standard
        
        inMemoryDB.forEach { (key, eventState) in
            let data = NSKeyedArchiver.archivedData(withRootObject: eventState)
            
            userDefaults.set(data, forKey: key)
        }
        
        userDefaults.synchronize()
        
        log("Synchronized in memory event engine database")
    }
    
    //MARK:- Helpers
    private func getEventState(event: String) -> EventState {
        var eventState = inMemoryDB[event]
        let userDefaults = UserDefaults.standard
        
        if eventState == nil,
            let eventStateData = userDefaults.object(forKey: event) as? Data {
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
