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
        let cycleDate = createCycleDate(startDate: date("2025-05-26"), endDate: date("2025-05-30"))
        let sut = makeSUT()
        
        sut.logCycleDate(cycleDate)
        
        #expect(sut.cycleDates == [cycleDate])
    }
    
    @Test
    func test_logCycleDate_capturesCurrentDateWhenCycleDatesIsNotEmpty() {
        let firstCycleDate = createCycleDate(startDate: date("2025-03-28"), endDate: date("2025-04-01"))
        let secondCycleDate = createCycleDate(startDate: date("2025-05-26"), endDate: date("2025-05-30"))
        let sut = makeSUT()
        
        sut.logCycleDate(firstCycleDate)
        sut.logCycleDate(secondCycleDate)
        
        #expect(sut.cycleDates == [firstCycleDate, secondCycleDate])
    }

    @Test
    func test_logCycleDate_capturesLatestDateAfterEditing() {
        let oldCycleDate = createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03"))
        let newCycleDate = createCycleDate(startDate: date("2025-03-28"), endDate: date("2025-04-01"))
        let sut = makeSUT()
        
        sut.logCycleDate(oldCycleDate)
        sut.logCycleDate(newCycleDate, at: 0)

        #expect(sut.cycleDates == [newCycleDate])
    }
    
    @Test
    func test_deleteCycleDate_resetsDateToNilWhenCycleDatesHasOneItem() {
        let sut = makeSUT()
        let cycleDate = createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03"))
        
        sut.logCycleDate(cycleDate)
        sut.deleteCycleDate(at: 0)
        
        #expect(sut.cycleDates.isEmpty)
    }
    
    @Test
    func test_deleteCycleDate_resetsDateToNilWhenCycleDatesHasMoreThanOneItem() {
        let sut = makeSUT()
        
        let firstCycleDate = createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03"))
        let secondCycleDate = createCycleDate(startDate: date("2025-03-28"), endDate: date("2025-04-01"))
        let thirdCycleDate = createCycleDate(startDate: date("2025-04-26"), endDate: date("2025-04-30"))
        
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
        let cycle1 = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05"))
        let cycle2 = createCycleDate(startDate: date("2025-01-31"), endDate: date("2025-02-02"))
        
        sut.logCycleDate(cycle1)
        sut.logCycleDate(cycle2)
        
        #expect(sut.calculateAverageCycleLength() == 30)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithMultipleEntries() {
        let sut = CycleTracker()

        // Simulate 7 cycles with varying start dates
        // Jan 1, Jan 29 (28 days later), Feb 27 (29 days later), Mar 28 (29 days later),
        // Apr 26 (29 days later), May 26 (30 days later), Jun 25 (30 days later)
        let cycles = [
            createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05")),
            createCycleDate(startDate: date("2025-01-29"), endDate: date("2025-02-02")),
            createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03")),
            createCycleDate(startDate: date("2025-03-28"), endDate: date("2025-04-01")),
            createCycleDate(startDate: date("2025-04-26"), endDate: date("2025-04-30")),
            createCycleDate(startDate: date("2025-05-26"), endDate: date("2025-05-30")),
            createCycleDate(startDate: date("2025-06-25"), endDate: date("2025-06-29"))
        ]

        cycles.forEach { sut.logCycleDate($0) }

        // We expect the average over last 6 intervals:
        // [28, 29, 29, 29, 30, 30] → sum = 175 → avg = 29
        let average = sut.calculateAverageCycleLength()

        #expect(average == 29)
    }

    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func createCycleDate(startDate: Date, endDate: Date) -> CycleDate {
        CycleDate(startDate: startDate, endDate: endDate)
    }
    
    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }
}
