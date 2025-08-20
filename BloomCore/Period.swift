//
//  Cycle.swift
//  Bloom
//
//  Created by Himanshu on 19/08/25.
//

import Foundation

public struct Period: Equatable, Hashable {
    var startDate: Date
    var endDate: Date?
    
    var duration: Int {
        guard let end = endDate else { return 5 }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? 0
        return days + 1
    }
    
    public init(startDate: Date, endDate: Date? = nil) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public static func == (lhs: Period, rhs: Period) -> Bool {
        lhs.startDate == rhs.startDate
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(startDate)
    }
}

public enum CycleError: Error {
    case invalidDateRange
    case notEnoughData
}
