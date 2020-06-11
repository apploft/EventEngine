//
// Created by apploft on 08.06.20.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

internal class UserDefaultPersistingEventEngine: EventEngine {
    
    //MARK:- Properties
    public var loggingEnabled: Bool = false
    var inMemoryDB: [String:EventState] = [:]
    
    //MARK:- Init
    init() {
        self.migratePreviouslyPersistedDataIfNecessary()
    }
    
    //MARK:- Interface
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
    
    public func synchronize() {
        NSKeyedUnarchiver.setClass(BasicEventState.self, forClassName: "EventEngine.EventStateImpl")
        
        let userDefaults = UserDefaults.standard
        
        inMemoryDB.forEach { (key, eventState) in
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: eventState, requiringSecureCoding: false)
                userDefaults.set(data, forKey: key)
            } catch {
                log("Could not persist: \(eventState). Abording synchronization")
                return
            }
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
            
            // Cannot use new method +unarchivedObjectOfClass:fromData:error:,
            // because Value of protocol type 'EventState' cannot conform to
            // 'NSCoding'.
            eventState = NSKeyedUnarchiver.unarchiveObject(with: eventStateData) as? EventState
            inMemoryDB[event] = eventState
        }
        
        if eventState == nil {
            eventState = BasicEventState(name: event)
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
    
    private func migratePreviouslyPersistedDataIfNecessary() {
        NSKeyedUnarchiver.setClass(BasicEventState.self, forClassName: "EventEngine.EventStateImpl")
    }
}
