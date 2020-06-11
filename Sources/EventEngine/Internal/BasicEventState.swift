//
// Created by apploft on 19.03.18.
// Copyright © 2019 apploft GmbH.
// MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation

internal class BasicEventState: NSObject, EventState, NSCoding {

    //MARK:- Properties
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
    
    //MARK:- Init
    init(name: String) {
        self.name = name
        firstOccurrence = 0
        lastOccurrence = 0
        count_ = 0
        disabled = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameKey) as! String
        firstOccurrence = aDecoder.decodeDouble(forKey: firstOccurrenceKey)
        lastOccurrence = aDecoder.decodeDouble(forKey: lastOccurrenceKey)
        count_ = Int(aDecoder.decodeInt64(forKey: countKey))
        disabled = aDecoder.decodeBool(forKey: disabledKey)
    }
    
    //MARK:- Interface
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
        return Date.timeIntervalSinceReferenceDate - lastOccurrence < BasicEventState.OneDay
    }

    //MARK:- Private Properties
    private static let OneDay: TimeInterval = 60 * 60 * 24
    
    private let nameKey = "EventState_NameKey"
    private let firstOccurrenceKey = "EventState_FirstOccurenceKey"
    private let lastOccurrenceKey = "EventState_LastOccurrenceKey"
    private let countKey = "EventState_CountKey"
    private let disabledKey = "EventState_DisabledKey"
}
