//
//  DefaultPeriodService.swift
//  BloomApplication
//
//  Created by Himanshu on 21/08/25.
//

import Foundation
import BloomCore

public protocol PeriodService {
    func addPeriod(_ period: Period) async throws
    func deletePeriod(_ period: Period) async throws
    func getAllPeriods() -> [Period]
}

public protocol PeriodOverviewProtocol {
    func getAllPeriods() -> [Period]
    func predictNextPeriod(fromDate date: Date) throws -> Date
    func getFertileWindow(forDate currentDate: Date) throws -> (start: Date, end: Date)
    func getAverageCycleLength(maxRecentCycles: Int?) -> Int
    func getAveragePeriodLength() throws -> Int
    func getOvulationDate(forDate currentDate: Date) throws -> Date
}

public final class DefaultPeriodService: PeriodOverviewProtocol {
    private let tracker: PredictionServiceProtocol
    private let repository: PeriodRepository

    public init(tracker: PredictionServiceProtocol, repository: PeriodRepository) {
        self.tracker = tracker
        self.repository = repository
    }

    public func addPeriod(_ period: Period) async throws {
        try tracker.addPeriod(period)
        try await repository.save(period)
    }

    public func deletePeriod(_ period: Period) async throws {
        tracker.deletePeriod(cycleDate: period)
        try await repository.delete(period)
    }

    public func getAllPeriods() -> [Period] {
        return tracker.periods
    }
    
    public func predictNextPeriod(fromDate date: Date) throws -> Date {
        try tracker.predictNextPeriod(fromDate: date)
    }
    
    public func getFertileWindow(forDate currentDate: Date) throws -> (start: Date, end: Date) {
        try tracker.getFertileWindow(forDate: currentDate)
    }
    
    public func getAverageCycleLength(maxRecentCycles: Int?) -> Int {
        tracker.getAverageCycleLength(maxRecentCycles: maxRecentCycles)
    }
    
    public func getAveragePeriodLength() throws -> Int {
        try tracker.getAveragePeriodLength()
    }
    
    public func getOvulationDate(forDate currentDate: Date) throws -> Date {
        try tracker.getOvulationDate(forDate: currentDate)
    }
}
