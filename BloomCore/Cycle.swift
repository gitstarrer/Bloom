//
//  Cycle.swift
//  Bloom
//
//  Created by Himanshu on 19/08/25.
//

import Foundation

public struct Cycle: Equatable, Hashable {
    var startDate: Date
    var endDate: Date?
    
    public init(startDate: Date, endDate: Date? = nil) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public static func == (lhs: Cycle, rhs: Cycle) -> Bool {
        lhs.startDate == rhs.startDate
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(startDate)
    }
}

public enum CycleError: Error {
    case invalidDateRange
    case noDataAvailable
}
