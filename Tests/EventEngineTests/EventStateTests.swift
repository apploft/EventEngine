//
// Created by apploft on 11.06.20.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import XCTest
@testable import EventEngine

final class EventStateTests: XCTestCase {
    
    private let appLaunchesEventName = "appLaunches"
    private let eventEngine = EventEngineFactory.userDefaultPersistingEventEngine
    private lazy var eventState = eventEngine.state(ofEvent: appLaunchesEventName)
    
    override func tearDown() {
        super.tearDown()
        
        eventState.reset()
        eventState.disabled = false
    }
    
    func testEventNameEqual() {
        // Given
        let expectedEventName = appLaunchesEventName
        
        // When
        let eventStateName = eventState.name
        
        // Then
        XCTAssertEqual(eventStateName, expectedEventName,
                       "Eventname musst be equal")
    }
    
    func testFirstOccurrenceNotEqual() {
        // Given
        let timeIntervalBeforeFirstOccurence = Date.timeIntervalSinceReferenceDate
        
        // When
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 1)
        
        // Then
        XCTAssertNotEqual(eventState.firstOccurrence, timeIntervalBeforeFirstOccurence,
                          "First occurrence musst not be equal to a time interval before the first occurence")
    }
    
    func testFirstOccurrenceNotEqualLastOccurence() {
        // When
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 1)
        eventEngine.fire(event: appLaunchesEventName, incrementBy: 2)
        
        // Then
        XCTAssertNotEqual(eventState.firstOccurrence, eventState.lastOccurrence,
                          "FirstOccurrence is not equal to the LastOccurence after two updates")
    }
    
    func testUpdate() {
        // Given
        let expectedCount = 2
        
        // When
        eventState.update(incrementBy: expectedCount)
        
        // Then
        XCTAssertEqual(eventState.count, expectedCount,
                       "Updating the event state did not provide the expected count")
    }
    
    func testDisabled() {
        // Given
        let expectedCountWhenDisabled = 0
        
        // When
        eventState.update(incrementBy: 2)
        eventState.disabled = true
        
        // Then
        XCTAssertEqual(eventState.count, expectedCountWhenDisabled,
                       "A disabeld event state should return the count of 0")
    }
    
    func testReset() {
        // Given
        let expectedCountWhenRested = 0
        let expectedFirstOccurrenceWhenRested = 0.0
        let expectedLastOccurrenceWhenRested = 0.0
        
        // When
        eventState.update(incrementBy: 2)
        eventState.update(incrementBy: 4)
        eventState.reset()
        
        // Then
        XCTAssertEqual(eventState.count, expectedCountWhenRested,
                       "A reseted event state musst have a count of 0")
        XCTAssertEqual(eventState.firstOccurrence, expectedFirstOccurrenceWhenRested,
                       "A reseted event state musst have a firstOccurrence of 0")
        XCTAssertEqual(eventState.lastOccurrence, expectedLastOccurrenceWhenRested,
                       "A reseted event state musst have a lastOccurrence of 0")
    }
    
    func testOccurredInLastDayTrue() {
        // When
        eventState.update(incrementBy: 2)
        
        // Then
        XCTAssertTrue(eventState.occurredInLastDay(),
                      "A just updated eventstate musst be occurred in the last day")
    }
    
    static var allTests = [
        ("testEventNameEqual", testEventNameEqual),
        ("testFirstOccurrenceNotEqual", testFirstOccurrenceNotEqual),
        ("testFirstOccurrenceNotEqualLastOccurence", testFirstOccurrenceNotEqualLastOccurence),
        ("testUpdate", testUpdate),
        ("testDisabled", testDisabled),
        ("testReset", testReset)
    ]
}
