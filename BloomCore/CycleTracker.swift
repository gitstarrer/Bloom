//
//  CycleTracker.swift
//  Bloom
//
//  Created by Himanshu on 19/08/25.
//

import Foundation

public class CycleTracker {
    public var cycleDates: [Cycle] = []
    
    public init() {}
    
    private var defaultCycleLength: Int = 28
    
    public func logCycleDate(_ cycleDate: Cycle) throws {
        if let endDate = cycleDate.endDate, cycleDate.startDate > endDate {
            throw CycleError.invalidDateRange
        }
        
        cycleDates.removeAll { $0.startDate == cycleDate.startDate }
        cycleDates.append(cycleDate)
        cycleDates.sort { $0.startDate < $1.startDate }
    }
    
    public func delete(cycleDate date: Cycle) {
        cycleDates.removeAll(where: { $0.startDate == date.startDate })
    }
    
    public func calculateAverageCycleLength(maxRecentCycles: Int? = nil) -> Int {
        guard cycleDates.count > 1 else { return defaultCycleLength }

        var sortedCycleDates = cycleDates.sorted { $0.startDate < $1.startDate }
        if let maxRecentCycles {
            sortedCycleDates = sortedCycleDates.suffix(maxRecentCycles)
        }
        
        var cycleDays = [Int]()
        for i in 1..<sortedCycleDates.count {
            let days = Calendar.current.dateComponents([.day], from: sortedCycleDates[i-1].startDate, to: sortedCycleDates[i].startDate).day ?? 0
            cycleDays.append(days)
        }
        
        let totalDays = cycleDays.reduce(0, +)
        return totalDays / cycleDays.count
    }
    
    public func predictNextCycleStartDay() throws -> Int {
        if cycleDates.isEmpty {
            throw CycleError.noDataAvailable
        }
        return defaultCycleLength
    }
}
