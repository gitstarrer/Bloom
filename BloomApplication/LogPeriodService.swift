//
//  LogPeriodService.swift
//  Bloom
//
//  Created by Himanshu on 28/08/25.
//

import BloomCore

public protocol LogPeriodServiceProtocol {
    func addPeriod(_ period: Period) async throws
}

public final class LogPeriodService: LogPeriodServiceProtocol {
    private let tracker: PredictionServiceProtocol
    private let repository: PeriodRepositoryProtocol

    public init(tracker: PredictionServiceProtocol, repository: PeriodRepositoryProtocol) {
        self.tracker = tracker
        self.repository = repository
    }
    
    public func addPeriod(_ period: Period) async throws {
        try tracker.addPeriod(period)
        try await repository.save(period)
    }
}
