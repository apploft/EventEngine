//
// Created by apploft on 19.03.18.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import XCTest
@testable import EventEngine

final class EventEngineTests: XCTestCase {
    
    private let appLaunchesEventName = "appLaunches"
    private let eventEngine = EventEngineFactory.userDefaultPersistingEventEngine
    
    override func tearDown() {
        super.tearDown()
        
        eventEngine.reset(event: appLaunchesEventName)
        eventEngine.enable(event: appLaunchesEventName)
        eventEngine.synchronize()
    }
    
    func testFireEvent() {
        // Given
        let incrementationValue = 1
        let expectedCount = incrementationValue
        
        // When
        eventEngine.fire(event: appLaunchesEventName, incrementBy: incrementationValue)
        
        // Then
        XCTAssertEqual(eventEngine.state(ofEvent: appLaunchesEventName).count,
                       expectedCount,
                      "App launches event must have a count 0f 1")
    }
    
    
    func testResetEvent() {
        // Given
        let expectedCountAfterReset = 0
        
        // When
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 1)
        eventEngine.reset(event: appLaunchesEventName)
        
        // Then
        XCTAssertEqual(eventEngine.state(ofEvent: appLaunchesEventName).count,
                       expectedCountAfterReset,
                       "Reseted event musst have a count of 0")
    }
    
    func testDisableEvent() {
        // Given
        let expectedCountAfterDisabled = 0
        
        // When
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 1)
        eventEngine.disable(event: appLaunchesEventName)
        
        // Then
        XCTAssertEqual(eventEngine.state(ofEvent: appLaunchesEventName).count,
                       expectedCountAfterDisabled,
                       "Disabled Event musst have a count of 0")
    }
    
    func testeEnableEvent() {
        // Given
        let incrementationValue = 1
        let expectedCount = incrementationValue
        
        // When
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 1)
        eventEngine.disable(event: appLaunchesEventName)
        eventEngine.enable(event: appLaunchesEventName)
        
        // Then
        XCTAssertEqual(eventEngine.state(ofEvent: appLaunchesEventName).count,
                       expectedCount,
                       "Enabled Event musst have a count of 1 after increment by 1")
    }
    
    func testSynchornisation() {
        // Given
        let differentEventEngine = EventEngineFactory.userDefaultPersistingEventEngine
        let incrementationValue = 1
        let expectedCount = incrementationValue
        
        // When
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 1)
        eventEngine.synchronize()
        
        // Then
        XCTAssertEqual(differentEventEngine.state(ofEvent: appLaunchesEventName).count,
                       expectedCount,
                       "Synchronizing failed. The persisted value is not the expected one.")
    }
    
    
    static var allTests = [
        ("testFireEvent", testFireEvent),
        ("testResetEvent", testResetEvent),
        ("testDisableEvent", testDisableEvent),
        ("testeEnableEvent", testeEnableEvent),
        ("testSynchornisation", testSynchornisation)
    ]
}
