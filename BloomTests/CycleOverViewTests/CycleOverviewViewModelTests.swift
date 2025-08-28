//
//  CycleOverviewViewModelTests.swift
//  Bloom
//
//  Created by Himanshu on 22/08/25.
//

import Foundation
import XCTest
import BloomCore
import BloomApplication
@testable import Bloom

final class CycleOverviewViewModelTests: XCTestCase {
    
    func test_init_emptyPeriodList() {
        let sut = makeSUT()
        XCTAssertTrue(sut.periodList.isEmpty)
        XCTAssertNil(sut.lastPeriod)
    }
    
    func test_loadData_fetchesEmptyPeriodListOnEmptyData() {
        let sut = makeSUT()
        sut.loadData()
        XCTAssertTrue(sut.periodList.isEmpty)
        XCTAssertNil(sut.lastPeriod)
    }
    
    func test_loadData_fetchesEmptyPeriodListWithMultipleEntries() {
        let periods: [BloomCore.Period] = Array(repeating: .init(startDate: Date()), count: 7)
        let sut = makeSUT(periods: periods)
        sut.loadData()
        XCTAssertEqual(sut.periodList, periods)
        XCTAssertEqual(sut.lastPeriod, periods.last)
    }
    
    func test_getLastPeriodText_returnsNilIfEmpty() {
        let sut = makeSUT()
        XCTAssertNil(sut.lastPeriod)
        XCTAssertEqual(sut.lastPeriodText, "")
    }
    
    func test_setupTexts_updatesAllTexts() {
        let periods: [BloomCore.Period] = [.init(startDate: date("2025-08-21"))]
        let sut = makeSUT(periods: periods, forDay: date("2025-08-23"))
        XCTAssertEqual(sut.lastPeriodText, "Last period: \(sut.lastPeriod!.getDates().startDate.formatted(date: .abbreviated, time: .omitted))")
        XCTAssertEqual(sut.cycleDayText, "Day 3")
        XCTAssertEqual(sut.nextPeriodText, "Next period: \(date("2025-09-25").formatted(date: .abbreviated, time: .omitted))")
        XCTAssertEqual(sut.fertileWindowText, "Fertile window: \(date("2025-08-23").formatted(date: .abbreviated, time: .omitted)) – \(date("2025-09-02").formatted(date: .abbreviated, time: .omitted))")
        XCTAssertEqual(sut.averageCycleLengthText, "Average cycle length: 23 days")
        XCTAssertEqual(sut.averagePeriodLengthText, "Average period duration: 8 days")
        XCTAssertEqual(sut.ovulationDateText, "Ovulation: 28 Aug 2025")
    }
    
    func test_loadData_handlesPredictNextPeriodError() {
        let service = MockPeriodService(periods: [.init(startDate: date("2025-08-21"))])
        service.shouldThrowOnPredictNextPeriod = true
        let sut = CycleOverviewViewModel(periodService: service)
        
        sut.loadData()
        
        XCTAssertEqual(sut.nextPeriodText, "")
    }
    
    func test_loadData_handlesFertileWindowError() {
        let service = MockPeriodService(periods: [.init(startDate: date("2025-08-21"))])
        service.shouldThrowOnFertileWindow = true
        let sut = CycleOverviewViewModel(periodService: service)
        
        sut.loadData()
        
        XCTAssertEqual(sut.fertileWindowText, "")
    }
    
    func test_loadData_handlesAveragePeriodLengthError() {
        let service = MockPeriodService(periods: [.init(startDate: date("2025-08-21"))])
        service.shouldThrowOnAveragePeriodLength = true
        let sut = CycleOverviewViewModel(periodService: service)
        
        sut.loadData()
        
        XCTAssertEqual(sut.averagePeriodLengthText, "")
    }
    
    func test_loadData_handlesOvulationDateError() {
        let service = MockPeriodService(periods: [.init(startDate: date("2025-08-21"))])
        service.shouldThrowOnOvulationDate = true
        let sut = CycleOverviewViewModel(periodService: service)
        
        sut.loadData()
        
        XCTAssertEqual(sut.ovulationDateText, "")
    }
    
    
    //Helpers
    func makeSUT(periods: [BloomCore.Period] = [], forDay day: Date = Date()) -> CycleOverviewViewModel {
        return CycleOverviewViewModel(
            periodService: MockPeriodService(periods: periods),
            forDay: day
        )
    }
    
    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }
    
    class MockPeriodService: PeriodOverviewServiceProtocol {
        var periods: [BloomCore.Period]
        
        var shouldThrowOnPredictNextPeriod = false
        var shouldThrowOnFertileWindow = false
        var shouldThrowOnAveragePeriodLength = false
        var shouldThrowOnOvulationDate = false
        
        init(periods: [BloomCore.Period]) {
            self.periods = periods
        }
        
        func getAllPeriods() -> [BloomCore.Period] { periods }
        
        func predictNextPeriod(fromDate date: Date) throws -> Date {
            if shouldThrowOnPredictNextPeriod { throw NSError(domain: "test", code: 1) }
            return Calendar.current.date(byAdding: .day, value: 28, to: date) ?? Date()
        }
        
        func getFertileWindow(forDate currentDate: Date) throws -> (start: Date, end: Date) {
            if shouldThrowOnFertileWindow { throw NSError(domain: "test", code: 2) }
            let startDate = Calendar.current.date(byAdding: .day, value: -5, to: currentDate) ?? Date()
            let endDate = Calendar.current.date(byAdding: .day, value: 5, to: currentDate) ?? Date()
            return (start: startDate, end: endDate)
        }
        
        func getAverageCycleLength(maxRecentCycles: Int?) -> Int { 23 }
        
        func getAveragePeriodLength() throws -> Int {
            if shouldThrowOnAveragePeriodLength { throw NSError(domain: "test", code: 3) }
            return 8
        }
        
        func getOvulationDate(forDate currentDate: Date) throws -> Date {
            if shouldThrowOnOvulationDate { throw NSError(domain: "test", code: 4) }
            return Date()
        }
    }
}

