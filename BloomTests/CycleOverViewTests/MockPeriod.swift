//
//  MockPeriod.swift
//  Bloom
//
//  Created by Himanshu on 22/08/25.
//

import Foundation
import Testing
import BloomCore
import BloomApplication
@testable import Bloom

final class MockPredictionService: PredictionServiceProtocol {
    var periods: [Period] = []
    
    var nextPeriodDate: Date?
    var ovulationDate: Date?
    var fertileWindow: (start: Date, end: Date)?
    var averageCycleLength: Int = 28
    var averagePeriodLength: Int = 5
    
    var shouldThrowError: Bool = false
    
    func addPeriod(_ period: Period) throws {
        if shouldThrowError { throw NSError(domain: "MockPredictionService", code: 1) }
        periods.append(period)
    }
    
    func deletePeriod(cycleDate date: Period) {
        periods.removeAll {
            $0.getDates().startDate == date.getDates().startDate
            && $0.getDates().endDate == date.getDates().endDate
        }
    }
    
    func getAverageCycleLength(maxRecentCycles: Int?) -> Int {
        return averageCycleLength
    }
    
    func predictNextPeriod(fromDate date: Date) throws -> Date {
        if shouldThrowError { throw NSError(domain: "MockPredictionService", code: 2) }
        return nextPeriodDate ?? Calendar.current.date(byAdding: .day, value: averageCycleLength, to: date)!
    }
    
    func getAveragePeriodLength() throws -> Int {
        if shouldThrowError { throw NSError(domain: "MockPredictionService", code: 3) }
        return averagePeriodLength
    }
    
    func getOvulationDate(forDate currentDate: Date) throws -> Date {
        if shouldThrowError { throw NSError(domain: "MockPredictionService", code: 4) }
        return ovulationDate ?? Calendar.current.date(byAdding: .day, value: averageCycleLength / 2, to: currentDate)!
    }
    
    func getFertileWindow(forDate currentDate: Date) throws -> (start: Date, end: Date) {
        if shouldThrowError { throw NSError(domain: "MockPredictionService", code: 5) }
        if let fertileWindow = fertileWindow {
            return fertileWindow
        } else {
            let start = Calendar.current.date(byAdding: .day, value: 10, to: currentDate)!
            let end = Calendar.current.date(byAdding: .day, value: 15, to: currentDate)!
            return (start, end)
        }
    }
}

final class MockPeriodService: PeriodService {
    private(set) var periods: [Period] = []
    var shouldThrowError = false
    
    func addPeriod(_ period: Period) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockPeriodService", code: 1)
        }
        periods.append(period)
    }
    
    func deletePeriod(_ period: Period) async throws {
        if shouldThrowError {
            throw NSError(domain: "MockPeriodService", code: 2)
        }
        periods.removeAll { $0.getDates().startDate == period.getDates().startDate && $0.getDates().endDate == period.getDates().endDate }
    }
    
    func getAllPeriods() -> [Period] {
        return periods
    }
}

struct MockPeriod: Equatable {
    let startDate: Date
    let endDate: Date
    
    func getDates() -> (startDate: Date, endDate: Date?) {
        (startDate, endDate)
    }
}
