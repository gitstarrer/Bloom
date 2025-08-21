//
//  BloomApplicationTests.swift
//  BloomApplicationTests
//
//  Created by Himanshu on 21/08/25.
//

import XCTest
import BloomCore
import BloomApplication

final class DefaultPeriodServiceTests: XCTestCase {

    private var repository: PeriodRepositorySpy!
    private var tracker: CycleTracker!
    private var sut: DefaultPeriodService!

    override func setUp() {
        super.setUp()
        repository = PeriodRepositorySpy()
        tracker = CycleTracker()
        sut = DefaultPeriodService(tracker: tracker, repository: repository)
    }

    override func tearDown() {
        sut = nil
        tracker = nil
        repository = nil
        super.tearDown()
    }

    func test_addPeriod_savesToTrackerAndRepository() async throws {
        let period = Period(startDate: Date(), endDate: nil)

        try await sut.addPeriod(period)

        XCTAssertTrue(tracker.periods.contains(where: { $0 == period }))
        XCTAssertTrue(repository.saved.contains(where: { $0 == period }))
    }

    func test_deletePeriod_removesFromTrackerAndRepository() async throws {
        let period = Period(startDate: Date(), endDate: nil)
        try await sut.addPeriod(period)

        try await sut.deletePeriod(period)

        XCTAssertTrue(tracker.periods.isEmpty)
        XCTAssertTrue(repository.deleted.contains(where: { $0 == period }))
    }

    func test_getAllPeriods_returnsTrackerPeriods() async throws {
        let period1 = Period(startDate: Date(), endDate: nil)
        let period2 = Period(startDate: Date().addingTimeInterval(86400), endDate: nil)

        try await sut.addPeriod(period1)
        try await sut.addPeriod(period2)

        let result = sut.getAllPeriods()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first, period1)
    }

    func test_addPeriod_invalidThrows() async {
        let invalid = Period(startDate: Date(), endDate: Date().addingTimeInterval(-86400))
        do {
            try await sut.addPeriod(invalid)
            XCTFail("Expected to throw CycleError.invalidDateRange but succeeded")
        } catch {
            XCTAssertEqual(error as? CycleError, CycleError.invalidDateRange)
        }
    }
}


final class PeriodRepositorySpy: PeriodRepository {
    private(set) var saved: [Period] = []
    private(set) var deleted: [Period] = []
    
    func save(_ period: Period) throws {
        saved.append(period)
    }
    
    func delete(_ period: Period) {
        deleted.append(period)
    }
    
    func fetchAll() async -> [BloomCore.Period] {
        return saved
    }
}

