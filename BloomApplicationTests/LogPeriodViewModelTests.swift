//
//  LogPeriodViewModelTests.swift
//  BloomApplicationTests
//
//  Created by Himanshu on 28/08/25.
//

import XCTest
import BloomCore
import BloomApplication

final class LogPeriodServiceTests: XCTestCase {

    func test_addPeriod_savesSinglePeriodToTrackerAndRepository() async throws {
        let period = Period(startDate: Date(), endDate: nil)
        let (sut, tracker, repository) = makeSUT()
        
        try await sut.addPeriod(period)
        
        XCTAssertEqual(tracker.periods, [period])
        XCTAssertEqual(repository.saved, [period])
    }
    
    func test_addPeriod_savesMultiplePeriodsToTrackerAndRepository() async throws {
        let period1 = Period(startDate: Date(), endDate: nil)
        let period2 = Period(startDate: Date().addingTimeInterval(12), endDate: nil)
        let period3 = Period(startDate: Date().addingTimeInterval(123), endDate: nil)
        let (sut, tracker, repository) = makeSUT()
        
        try await sut.addPeriod(period1)
        try await sut.addPeriod(period2)
        try await sut.addPeriod(period3)
        
        XCTAssertEqual(tracker.periods, [period1, period2, period3])
        XCTAssertEqual(repository.saved, [period1, period2, period3])
    }
    
    private func makeSUT(withPeriods periods: [Period] = [], file: StaticString = #filePath, line: UInt = #line) -> (sut: LogPeriodServiceProtocol, tracker: CycleTracker, repository: PeriodRepositorySpy) {
        let repository = PeriodRepositorySpy()
        let tracker = CycleTracker()
        repository.saved = periods
        tracker.periods = periods
        let sut = LogPeriodService(tracker: tracker, repository: repository)
        trackForMemoryLeaks(instance: tracker, file: file, line: line)
        trackForMemoryLeaks(instance: repository, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        
        return (sut, tracker, repository)
    }
}
