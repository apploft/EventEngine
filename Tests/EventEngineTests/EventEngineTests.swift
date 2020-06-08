//
// Created by apploft on 19.03.18.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import XCTest
@testable import EventEngine

final class EventEngineTests: XCTestCase {
    
    let appLaunchesEventName = "appLaunches"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        let eventEngine = EventEngineFactory.userDefaultPersistingEventEngine
        
        eventEngine.reset(event: appLaunchesEventName)
        eventEngine.synchronize()
    }
    
    func testFireEvent() {
        let eventEngine = EventEngineFactory.userDefaultPersistingEventEngine
        
        XCTAssertTrue(eventEngine.state(ofEvent: appLaunchesEventName).count == 0, "App launches event must have a count of 0")
        
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 1)
        
        XCTAssertTrue(eventEngine.state(ofEvent: appLaunchesEventName).count == 1, "App launches event must have a count 0f 1")
        
        eventEngine.synchronize()
    }
    
    
    static var allTests = [
        ("testFireEvent", testFireEvent),
    ]
}
