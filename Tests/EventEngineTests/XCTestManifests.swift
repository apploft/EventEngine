import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EventEngineTests.allTests),
        testCase(EventStateTests.allTests),
    ]
}
#endif
