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
        let sut = makeSUT(periods: periods)
        XCTAssertEqual(sut.lastPeriodText, "Last period: \(sut.lastPeriod!.getDates().startDate.formatted(date: .abbreviated, time: .omitted))")
        XCTAssertEqual(sut.cycleDayText, "Day 2")
        XCTAssertEqual(sut.nextPeriodText, "Next period: \(date("2025-09-19").formatted(date: .abbreviated, time: .omitted))")
        XCTAssertEqual(sut.fertileWindowText, "Fertile window: \(date("2025-08-17").formatted(date: .abbreviated, time: .omitted)) – \(date("2025-08-27").formatted(date: .abbreviated, time: .omitted))")
        XCTAssertEqual(sut.averageCycleLengthText, "Average cycle length: 23 days")
        XCTAssertEqual(sut.averagePeriodLengthText, "Average period duration: 8 days")
        XCTAssertEqual(sut.ovulationDateText, "Ovulation: 22 Aug 2025")
    }
    
    //Helpers
    func makeSUT(periods: [BloomCore.Period] = []) -> CycleOverviewViewModel {
        return try! CycleOverviewViewModel(
            periodService: MockPeriodService(periods: periods)
        )
    }
    
    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }
    
    class MockPeriodService: PeriodOverviewProtocol {
        var periods: [BloomCore.Period]
        
        init(periods: [BloomCore.Period]) {
            self.periods = periods
        }
        
        func addPeriod(_ period: BloomCore.Period) async throws {
            periods.append(period)
        }
        
        func deletePeriod(_ period: BloomCore.Period) async throws {
            periods.removeAll(where: { $0 == period })
        }
        
        func getAllPeriods() -> [BloomCore.Period] { periods }
        
        func predictNextPeriod(fromDate date: Date) throws -> Date {
            return Calendar.current.date(byAdding: .day, value: 28, to: date) ?? Date()
        }
        
        func getFertileWindow(forDate currentDate: Date) throws -> (start: Date, end: Date) {
            let startDate = Calendar.current.date(byAdding: .day, value: -5, to: currentDate) ?? Date()
            let endDate = Calendar.current.date(byAdding: .day, value: 5, to: currentDate) ?? Date()
            return (start: startDate, end: endDate)
        }
        
        func getAverageCycleLength(maxRecentCycles: Int?) -> Int { 23 }
        
        func getAveragePeriodLength() throws -> Int { 8 }
        
        func getOvulationDate(forDate currentDate: Date) throws -> Date { Date() }
    }
}

