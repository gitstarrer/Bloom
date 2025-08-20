//
//  CycleTracker.swift
//  Bloom
//
//  Created by Himanshu on 19/08/25.
//

import Foundation

public class CycleTracker {
    public var periods: [Period] = []
    
    public init() {}
    
    private var defaultCycleLength: Int = 28
    
    public func addPeriod(_ period: Period) throws {
        if let endDate = period.endDate, period.startDate > endDate {
            throw CycleError.invalidDateRange
        }
        
        periods.removeAll { $0.startDate == period.startDate }
        periods.append(period)
        periods.sort { $0.startDate < $1.startDate }
    }
    
    public func deletePeriod(cycleDate date: Period) {
        periods.removeAll(where: { $0.startDate == date.startDate })
    }
    
    public func getAverageCycleLength(maxRecentCycles: Int? = nil) -> Int {
        guard periods.count > 1 else { return defaultCycleLength }

        var sortedCycleDates = periods.sorted { $0.startDate < $1.startDate }
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
    
    public func predictNextPeriod(fromDate date: Date = Date()) throws -> Date {
        guard let lastStartDate = periods.last?.startDate else {
            throw CycleError.notEnoughData
        }
        
        let cycleLength = periods.count > 1 ? getAverageCycleLength() : defaultCycleLength
        
        var predictedDate = Calendar.current.date(byAdding: .day, value: cycleLength, to: lastStartDate)
        
        while let predictedCycleDate = predictedDate, predictedCycleDate < date {
            predictedDate =  Calendar.current.date(byAdding: .day, value: cycleLength, to: predictedCycleDate)
        }
        
        guard let nextCycleDate = predictedDate else {
            throw CycleError.notEnoughData
        }
        
        return nextCycleDate
    }

    public func getAveragePeriodLength() throws -> Int {
        guard !periods.isEmpty else { throw CycleError.notEnoughData }
        
        let cumulativePeriodLength = periods.map(\.duration).reduce(0, +)
        let averagePeriodLength = Double(cumulativePeriodLength) / Double(periods.count)
        
        return Int(averagePeriodLength.rounded())
    }
    
    public func getOvulationDate(forDate currentDate: Date = Date()) throws -> Date {
        guard periods.count > 1 else { throw CycleError.notEnoughData }
        let date = try predictNextPeriod(fromDate: currentDate)
        guard let ovulationDate = Calendar.current.date(byAdding: .day, value: -14, to: date) else { throw CycleError.notEnoughData }
        return ovulationDate
    }
    
    public func getFertileWindow(forDate currentDate: Date = Date()) throws -> (start: Date, end: Date){
        guard periods.count > 1 else { throw CycleError.notEnoughData }
        
        let ovulationDate = try getOvulationDate(forDate: currentDate)
        
        let fertileWindowStartDate = Calendar.current.date(byAdding: .day, value: -5, to: ovulationDate)
        let fertileWindowEndDate = Calendar.current.date(byAdding: .day, value: 5, to: ovulationDate)
        
        guard let fertileWindowStartDate, let fertileWindowEndDate else { throw CycleError.notEnoughData }
        
        return (start: fertileWindowStartDate, end: fertileWindowEndDate)
    }
}
