//
//  CycleTrackerTests.swift
//  BloomCoreTests
//
//  Created by Himanshu on 18/08/25.
//

import Testing
import Foundation

struct CycleDate: Equatable {
    var startDate: Date
    var endDate: Date
}

class CycleTracker {
    var cycleDates: [CycleDate] = []
    
    func logCycleDate(_ cycleDate: CycleDate, at index: Int? = nil) {
        if let index, index < cycleDates.count {
            cycleDates[index] = cycleDate
        } else {
            cycleDates.append(cycleDate)
        }
    }
    
    func deleteCycleDate(at index: Int) {
        if index < cycleDates.count {
            cycleDates.remove(at: index)
        }
    }
    
    func calculateAverageCycleLength(maxRecentCycles: Int? = nil) -> Int {
        guard !cycleDates.isEmpty else { return 28 }

        var sortedCycleDates = cycleDates.sorted { $0.startDate < $1.startDate }
        if let maxRecentCycles {
            sortedCycleDates = sortedCycleDates.suffix(maxRecentCycles)
        }
        
        var cycleDays = [Int]()
        for i in 1..<sortedCycleDates.count {
            let days = Calendar.current.dateComponents([.day], from: sortedCycleDates[i-1].startDate, to: sortedCycleDates[i].startDate).day ?? 0
            cycleDays.append(days)
        }
        
        let totalDays = cycleDays.reduce(0, +)
        return totalDays / cycleDays.count
    }
}


struct CycleTrackerTests {

    @Test
    func test_logCycleDate_capturesCurrentDateWhenCycleDatesIsEmpty() {
        let cycleDate = CycleDate(startDate: Date(), endDate: Date(timeIntervalSinceNow: 1234))
        let sut = makeSUT()
        
        sut.logCycleDate(cycleDate)
        
        #expect(sut.cycleDates.first?.startDate == cycleDate.startDate)
        #expect(sut.cycleDates.first?.endDate == cycleDate.endDate)
    }
    
    @Test
    func test_logCycleDate_capturesCurrentDateWhenCycleDatesIsNotEmpty() {
        let firstCycleDate = CycleDate(startDate: Date(), endDate: Date(timeIntervalSinceNow: 1234))
        let secondCycleDate = createCycleDate(Date(timeIntervalSince1970: 123), Date(timeIntervalSinceNow: 5656))
        let sut = makeSUT()
        
        sut.logCycleDate(firstCycleDate)
        sut.logCycleDate(secondCycleDate)
        
        #expect(sut.cycleDates == [firstCycleDate, secondCycleDate])
    }

    @Test
    func test_logCycleDate_capturesLatestDateAfterEditing() {
        let oldCycleDate = createCycleDate(Date(timeIntervalSince1970: 123), Date(timeIntervalSinceNow: 99))
        let newCycleDate = createCycleDate(Date(timeIntervalSince1970: 245), Date(timeIntervalSinceNow: 999))
        let sut = makeSUT()
        
        sut.logCycleDate(oldCycleDate)
        sut.logCycleDate(newCycleDate, at: 0)

        #expect(sut.cycleDates.first?.startDate == newCycleDate.startDate)
        #expect(sut.cycleDates.first?.endDate == newCycleDate.endDate)
    }
    
    @Test
    func test_deleteCycleDate_resetsDateToNilWhenCycleDatesHasOneItem() {
        let sut = makeSUT()
        let cycleDate = createCycleDate()
        
        sut.logCycleDate(cycleDate)
        sut.deleteCycleDate(at: 0)
        
        #expect(sut.cycleDates.isEmpty)
    }
    
    @Test
    func test_deleteCycleDate_resetsDateToNilWhenCycleDatesHasMoreThanOneItem() {
        let sut = makeSUT()
        let firstCycleDate = createCycleDate()
        let secondCycleDate = createCycleDate(Date(timeIntervalSince1970: 9090), Date(timeIntervalSinceNow: 1010))
        let thirdCycleDate = createCycleDate(Date(timeIntervalSince1970: 123), Date(timeIntervalSinceNow: 5656))
        
        sut.logCycleDate(firstCycleDate)
        sut.logCycleDate(secondCycleDate)
        sut.logCycleDate(thirdCycleDate)
        sut.deleteCycleDate(at: 1)
        
        #expect(sut.cycleDates == [firstCycleDate, thirdCycleDate])
    }

    @Test
    func test_calculateAverageCycleLength_returnsNilWhenCycleDatesIsEmpty() {
        let sut = makeSUT()
        let averageCycleLength = sut.calculateAverageCycleLength()
        #expect(sut.cycleDates == [])
        #expect(averageCycleLength == 28)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithTwoEntries() {
        let sut = CycleTracker()
        let cycle1 = CycleDate(
            startDate: Date(timeIntervalSince1970: 0),       // Jan 1
            endDate: Date(timeIntervalSince1970: 86400 * 5)  // Jan 6
        )
        let cycle2 = CycleDate(
            startDate: Date(timeIntervalSince1970: 86400 * 33), // Feb 3
            endDate: Date(timeIntervalSince1970: 86400 * 37)    // Feb 7
        )
        
        sut.logCycleDate(cycle1)
        sut.logCycleDate(cycle2)
        
        #expect(sut.calculateAverageCycleLength() == 33)
    }

    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func createCycleDate(_ startDate: Date = Date(), _ endDate: Date = Date(timeIntervalSinceNow: 23)) -> CycleDate {
        CycleDate(startDate: startDate, endDate: endDate)
    }
}
