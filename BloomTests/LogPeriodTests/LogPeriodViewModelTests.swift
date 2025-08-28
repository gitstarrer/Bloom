//
//  LogPeriodViewModelTests.swift
//  BloomTests
//
//  Created by Himanshu on 28/08/25.
//

import Foundation
import XCTest
@testable import Bloom
import BloomCore
import BloomApplication

@MainActor
class LogPeriodViewModelTests: XCTestCase {
    
    func test_init() {
        let sut = makeSUT()
        XCTAssertEqual(sut.flowLevel, 1)
        XCTAssertTrue(sut.symptoms.isEmpty)
        XCTAssertTrue(sut.moods.isEmpty)
        XCTAssertTrue(sut.activities.isEmpty)
        XCTAssertTrue(sut.journal.isEmpty)
        XCTAssertEqual(sut.allSymptoms.count, 6)
        XCTAssertEqual(sut.allMoods.count, 6)
        XCTAssertEqual(sut.allActivities.count, 6)
    }
    
    private func makeSUT(withPeriods periods: [Period] = [], file: StaticString = #filePath, line: UInt = #line) -> LogPeriodViewModel {
        let repository = PeriodRepositorySpy()
        let tracker = CycleTracker()
        repository.saved = periods
        tracker.periods = periods
        let periodService = LogPeriodService(tracker: tracker, repository: repository)
        let sut = LogPeriodViewModel(logPeriodService: periodService)
        
        trackForMemoryLeaks(instance: periodService, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        
        return sut
    }
}

public final class PeriodRepositorySpy: PeriodRepositoryProtocol {
    var saved: [Period] = []
    var deleted: [Period] = []
    
    public func save(_ period: Period) throws {
        saved.append(period)
    }
    
    public func delete(_ period: Period) {
        deleted.append(period)
    }
    
    public func fetchAll() async -> [BloomCore.Period] {
        return saved
    }
}

extension XCTestCase {
    public func trackForMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Possible memory leak.",file: file, line: line)
        }
    }
}

