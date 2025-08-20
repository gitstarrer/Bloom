//
//  CycleTracker.swift
//  Bloom
//
//  Created by Himanshu on 19/08/25.
//

import Foundation

public class CycleTracker {
    public var cycles: [Period] = []
    
    public init() {}
    
    private var defaultCycleLength: Int = 28
    
    public func logCycleDate(_ cycleDate: Period) throws {
        if let endDate = cycleDate.endDate, cycleDate.startDate > endDate {
            throw CycleError.invalidDateRange
        }
        
        cycles.removeAll { $0.startDate == cycleDate.startDate }
        cycles.append(cycleDate)
        cycles.sort { $0.startDate < $1.startDate }
    }
    
    public func delete(cycleDate date: Period) {
        cycles.removeAll(where: { $0.startDate == date.startDate })
    }
    
    public func calculateAverageCycleLength(maxRecentCycles: Int? = nil) -> Int {
        guard cycles.count > 1 else { return defaultCycleLength }

        var sortedCycleDates = cycles.sorted { $0.startDate < $1.startDate }
        if let maxRecentCycles {
            sortedCycleDates = sortedCycleDates.suffix(maxRecentCycles)
        }
        
        var cycleDays = [Int]()
        for i in 1..<sortedCycleDates.count {
            if let days = Calendar.current.dateComponents([.day], from: sortedCycleDates[i-1].startDate, to: sortedCycleDates[i].startDate).day {
                cycleDays.append(days)
            }
        }
        
        let totalDays = cycleDays.reduce(0, +)
        let average = Double(totalDays) / Double(cycleDays.count)
        return Int(average.rounded())
    }
    
    public func predictNextCycleStartDate(fromDate date: Date = Date()) throws -> Date {
        guard let lastStartDate = cycles.last?.startDate else {
            throw CycleError.notEnoughData
        }
        
        let cycleLength = cycles.count > 1 ? calculateAverageCycleLength() : defaultCycleLength
        
        var predictedDate = Calendar.current.date(byAdding: .day, value: cycleLength, to: lastStartDate)
        
        while let predictedCycleDate = predictedDate, predictedCycleDate < date {
            predictedDate =  Calendar.current.date(byAdding: .day, value: cycleLength, to: predictedCycleDate)
        }
        
        guard let nextCycleDate = predictedDate else {
            throw CycleError.notEnoughData
        }
        
        return nextCycleDate
    }

    public func calculateAveragePeriodLength() throws -> Int {
        guard !cycles.isEmpty else { throw CycleError.notEnoughData }
        
        let cumulativePeriodLength = cycles.map(\.duration).reduce(0, +)
        let averagePeriodLength = Double(cumulativePeriodLength) / Double(cycles.count)
        
        return Int(averagePeriodLength.rounded())
    }
}
