//
//  BloomApplication.swift
//  BloomApplication
//
//  Created by Himanshu on 21/08/25.
//

import BloomCore

// Application Layer
public protocol PeriodService {
    func addPeriod(_ period: Period) async throws
    func deletePeriod(_ period: Period) async throws
    func getAllPeriods() -> [Period]
}

public final class DefaultPeriodService: PeriodService {
    private let tracker: CycleTracker
    private let repository: PeriodRepository

    public init(tracker: CycleTracker, repository: PeriodRepository) {
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
}
