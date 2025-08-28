//
//  BloomApplicationTests.swift
//  BloomApplicationTests
//
//  Created by Himanshu on 21/08/25.
//

import XCTest
import BloomCore
import BloomApplication

final class PeriodOverviewServiceTests: XCTestCase {
    
    func test_fetchAllPeriods_returnsEmptyListOnNoData() {
        let sut = makeSUT()
        XCTAssertEqual(sut.getAllPeriods(), [])
    }
    
    func test_fetchAllPeriods_returnsEntryOnSingleEntry() {
        let period = Period(startDate: Date())
        let sut = makeSUT(withPeriods: [period])
        
        XCTAssertEqual(sut.getAllPeriods(), [period])
    }
    
    func test_fetchAllPeriods_returnsAllEntriesOnMultipleEntries() {
        let periods = [
            Period(startDate: Date()),
            Period(startDate: Date(timeIntervalSince1970: 1)),
            Period(startDate: Date(timeIntervalSince1970: 54)),
            Period(startDate: Date(timeIntervalSince1970: 444))
        ]
        let sut = makeSUT(withPeriods: periods)
        
        XCTAssertEqual(sut.getAllPeriods(), periods)
    }
    
    func test_predictNextPeriod_throwsErrorOnEmptyData() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.predictNextPeriod(fromDate: Date()))
    }
    
    func test_predictNextPeriod_returnsNextPeriodDateOnValidData() throws {
        let startDate = Date(timeIntervalSince1970: 0)
        let period = Period(startDate: startDate, endDate: startDate.addingTimeInterval(4*24*60*60))
        let sut = makeSUT(withPeriods: [period])
        
        let next = try sut.predictNextPeriod(fromDate: startDate)
        
        let expected = startDate.addingTimeInterval(28*24*60*60)
        XCTAssertEqual(next, expected)
    }
    
    func test_getFertileWindow_throwsErrorOnEmptyData() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.getFertileWindow(forDate: Date()))
    }
    
    func test_getFertileWindow_throwsErrorOnInvalidData() throws {
        let startDate = Date(timeIntervalSince1970: 0)
        let period = Period(startDate: startDate)
        let sut = makeSUT(withPeriods: [period])
        
        do {
            _ = try sut.getFertileWindow(forDate: startDate)
        } catch {
            XCTAssertEqual(error as! CycleError, CycleError.notEnoughData)
        }
    }
    
    func test_getFertileWindow_returnsExpectedWindowOnValidData() throws {
        let startDate = Date(timeIntervalSince1970: 0)
        let nextPeriod = Calendar.current.date(byAdding: .day, value: 28, to: startDate)!
        let p1 = Period(startDate: startDate)
        let p2 = Period(startDate: nextPeriod)
        let sut = makeSUT(withPeriods: [p1, p2])
        let ovulationDate = Calendar.current.date(byAdding: .day, value: 14, to: nextPeriod)!
        let expectedStart = Calendar.current.date(byAdding: .day, value: -5, to: ovulationDate)!
        let expectedEnd = Calendar.current.date(byAdding: .day, value: 5, to: ovulationDate)!
        
        let window = try! sut.getFertileWindow(forDate: startDate)
        
        XCTAssertEqual(window.start, expectedStart)
        XCTAssertEqual(window.end, expectedEnd)
    }
    
    func test_getAverageCycleLength_returnsZeroOnNoData() {
        let sut = makeSUT()
        let averageCycleLength = sut.getAverageCycleLength(maxRecentCycles: nil)
        XCTAssertEqual(averageCycleLength, 28)
    }
    
    func test_getAverageCycleLength_returnsExpectedAverageOnValidData() {
        let first = Date(timeIntervalSince1970: 0)
        let second = Calendar.current.date(byAdding: .day, value: 28, to: first)!
        let third = Calendar.current.date(byAdding: .day, value: 57, to: first)!
        
        let periods = [Period(startDate: first), Period(startDate: second), Period(startDate: third)]
        let sut = makeSUT(withPeriods: periods)
        
        let avg = sut.getAverageCycleLength(maxRecentCycles: nil)
        
        XCTAssertEqual(avg, 29)
    }
    
    func test_getAverageCycleLength_returnsCycleLengthOnMaxRecentCyclesValue1() {
        let first = Date(timeIntervalSince1970: 0)
        let second = Calendar.current.date(byAdding: .day, value: 28, to: first)!
        let third = Calendar.current.date(byAdding: .day, value: 57, to: first)!
        
        let periods = [Period(startDate: first), Period(startDate: second), Period(startDate: third)]
        let sut = makeSUT(withPeriods: periods)
        
        let avg = sut.getAverageCycleLength(maxRecentCycles: 1)
        
        XCTAssertEqual(avg, 29)
    }
    
    func test_getAverageCycleLength_respectsMaxRecentCycle() {
        let first = Date(timeIntervalSince1970: 0)
        let second = Calendar.current.date(byAdding: .day, value: 30, to: first)!
        let third = Calendar.current.date(byAdding: .day, value: 61, to: first)!
        
        let periods = [Period(startDate: first), Period(startDate: second), Period(startDate: third)]
        let sut = makeSUT(withPeriods: periods)
        
        let avg = sut.getAverageCycleLength(maxRecentCycles: 2)
        
        XCTAssertEqual(avg, 31)
    }
    
    func test_getAveragePeriodLength_throwsErrorOnNoData() {
        let sut = makeSUT()
        
        XCTAssertThrowsError(try sut.getAveragePeriodLength())
    }
    
    func test_getAveragePeriodLength_returnsExpectedAverage() throws {
        let start = Date(timeIntervalSince1970: 0)
        let p1 = Period(startDate: start, endDate: start.addingTimeInterval(5*24*60*60))
        let p2 = Period(startDate: start.addingTimeInterval(30*24*60*60),
                        endDate: start.addingTimeInterval(35*24*60*60))
        let sut = makeSUT(withPeriods: [p1, p2])
        
        let avg = try sut.getAveragePeriodLength()
        
        XCTAssertEqual(avg, 6)
    }
    
    func test_getOvulationDate_throwsErrorOnEmptyData() {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.getOvulationDate(forDate: Date()))
    }
    
    func test_getOvulationDate_throwsErrorOnInvalidData() {
        let start = Date(timeIntervalSince1970: 0)
        let p1 = Period(startDate: start)
        let sut = makeSUT(withPeriods: [p1])
        
        do {
            _ = try sut.getOvulationDate(forDate: start)
        } catch {
            XCTAssertEqual(error as! CycleError, CycleError.notEnoughData)
        }
    }
    
    func test_getOvulationDate_returnsExpectedDateOnValidData() throws {
        let startDate = Date(timeIntervalSince1970: 0)
        let nextPeriod = Calendar.current.date(byAdding: .day, value: 28, to: startDate)!
        
        let p1 = Period(startDate: startDate)
        let p2 = Period(startDate: nextPeriod)
        let sut = makeSUT(withPeriods: [p1, p2])
        
        let ovulation = try sut.getOvulationDate(forDate: nextPeriod)
        let expected = Calendar.current.date(byAdding: .day, value: 14, to: nextPeriod)!
        
        XCTAssertEqual(Calendar.current.startOfDay(for: ovulation),
                       Calendar.current.startOfDay(for: expected))
    }
    
    private func makeSUT(withPeriods periods: [Period] = [], file: StaticString = #filePath, line: UInt = #line) -> PeriodOverviewService {
        let repository = PeriodRepositorySpy()
        let tracker = CycleTracker()
        repository.saved = periods
        tracker.periods = periods
        trackForMemoryLeaks(instance: tracker, file: file, line: line)
        trackForMemoryLeaks(instance: repository, file: file, line: line)
        
        return PeriodOverviewService(tracker: tracker, repository: repository)
    }
}

final class PeriodRepositorySpy: PeriodRepository {
    var saved: [Period] = []
    var deleted: [Period] = []
    
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

