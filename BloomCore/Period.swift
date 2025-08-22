//
//  Cycle.swift
//  Bloom
//
//  Created by Himanshu on 19/08/25.
//

import Foundation

public struct Period: Equatable, Hashable, Identifiable, Codable {
    public let id: UUID
    var startDate: Date
    var endDate: Date?
    
    var duration: Int {
        guard let end = endDate else { return 5 }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: end).day ?? 0
        return days + 1
    }
    
    public init(id: UUID = UUID(), startDate: Date, endDate: Date? = nil) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
    }
    
    public func getDates() -> (startDate: Date, endDate: Date?) {
        (startDate: startDate, endDate: endDate)
    }
}

public enum CycleError: Error {
    case invalidDateRange
    case notEnoughData
}
