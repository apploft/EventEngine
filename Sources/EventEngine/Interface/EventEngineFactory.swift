//
// Created by apploft on 08.06.20.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

/// This class is a factory class, which generates event engines.
/// Here a small example how the app start can be saved and fetched with an user default persisting event engine:
/**
 *Example*
 
     let eventEngine = EventEngineFactory.userDefaultPersistingEventEngine
     eventEngine.fire(event: "AppStart", incrementBy: 1)

     // Persist the current state of the modified event
     eventEngine.synchronize()
      
     let appStartEventState = eventEngine.state(ofEvent: "AppStart")
     let appStartCount = appStartEventState.count
 */
public struct EventEngineFactory {
    
    /// This property returns an event engine, which persists its events in the user defaults.
    static public var userDefaultPersistingEventEngine: EventEngine {
        return UserDefaultPersistingEventEngine()
    }
}
