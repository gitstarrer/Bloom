//
//  CycleTrackerTests.swift
//  BloomCoreTests
//
//  Created by Himanshu on 18/08/25.
//

import Testing
import Foundation

struct CycleDate: Equatable, Hashable {
    var startDate: Date
    var endDate: Date?
}

class CycleTracker {
    var cycleDates: [CycleDate] = []
    
    func logCycleDate(_ cycleDate: CycleDate, at index: Int? = nil) {
        if let index, index < cycleDates.count {
            cycleDates[index] = cycleDate
        } else {
            cycleDates.append(cycleDate)
        }
        cycleDates = Array(Set(cycleDates))
        cycleDates.sort { $0.startDate < $1.startDate }
    }
    
    func deleteCycleDate(at index: Int) {
        if index < cycleDates.count {
            cycleDates.remove(at: index)
        }
    }
    
    func calculateAverageCycleLength(maxRecentCycles: Int? = nil) -> Int {
        guard cycleDates.count > 1 else { return 28 }

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
        let cycles = createMultipleCycleDates(count: 2)
        let sut = makeSUT()
        
        sut.logCycleDate(cycles[0])
        sut.logCycleDate(cycles[1])
        
        #expect(sut.cycleDates == [cycles[0], cycles[1]])
    }
    
    @Test
    func test_logCycleDate_hasSortedDatesWhenMultipleEntriesAreLogged() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        let reversedCycles = cycles.sorted { $0.startDate > $1.startDate }
        
        reversedCycles.forEach { sut.logCycleDate($0) }
        
        #expect(sut.cycleDates == cycles)
    }
    
    @Test
    func test_logCycleDate_hasSortedAndUniqueDatesWhenMultipleEntriesAreLoggedWithDuplicateEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let cyclesWithDuplicates: [CycleDate] = cycles + cycles
        let sut = makeSUT()
        
        cyclesWithDuplicates.forEach { sut.logCycleDate($0) }
        
        #expect(sut.cycleDates == cycles)
    }

    @Test
    func test_logCycleDate_capturesLatestDateAfterEditingWithOneEntry() {
        let cycles = createMultipleCycleDates(count: 2)
        let sut = makeSUT()
        
        sut.logCycleDate(cycles[0])
        sut.logCycleDate(cycles[1], at: 0)

        #expect(sut.cycleDates == [cycles[1]])
    }
    
    @Test
    func test_logCycleDate_updatesCorrectDateAfterEditingWithMultipleEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        cycles.forEach { sut.logCycleDate($0) }
        #expect(sut.cycleDates == cycles)
        
        let newCycleDate = createCycleDate(startDate: date("2025-03-25"), endDate: date("2025-03-29"))
        sut.logCycleDate(newCycleDate, at: 3)

        #expect(sut.cycleDates.count == cycles.count)
        #expect(sut.cycleDates[3] == newCycleDate)
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
        let cycleDates = createMultipleCycleDates(count: 3)
        
        sut.logCycleDate(cycleDates[0])
        sut.logCycleDate(cycleDates[1])
        sut.logCycleDate(cycleDates[2])
        sut.deleteCycleDate(at: 1)
        
        #expect(sut.cycleDates == [cycleDates[0], cycleDates[2]])
    }

    @Test
    func test_calculateAverageCycleLength_returnsDefaultCycleLengthWhenCycleDatesIsEmpty() {
        let sut = makeSUT()
        let averageCycleLength = sut.calculateAverageCycleLength()
        #expect(sut.cycleDates == [])
        #expect(averageCycleLength == 28)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsDefaultAverageCycleLengthWithOneEntry() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 1)
        
        sut.logCycleDate(cycles[0])
        
        #expect(sut.calculateAverageCycleLength() == 28)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithTwoEntries() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 2)
        
        sut.logCycleDate(cycles[0])
        sut.logCycleDate(cycles[1])
        
        #expect(sut.calculateAverageCycleLength() == 30)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithMultipleEntries() {
        let sut = CycleTracker()

        // Simulate 7 cycles with varying start dates
        // Jan 1, Jan 29 (28 days later), Feb 27 (29 days later), Mar 28 (29 days later),
        // Apr 26 (29 days later), May 26 (30 days later), Jun 25 (30 days later)
        let cycles = createMultipleCycleDates(count: 7)

        cycles.forEach { sut.logCycleDate($0) }

        // We expect the average over last 6 intervals:
        // [31, 29, 29, 29, 30, 30] → sum = 177 → avg = 29
        let average = sut.calculateAverageCycleLength()

        #expect(average == 29)
    }

    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func createMultipleCycleDates(count: Int) -> [CycleDate] {
        let cycles = [
            createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05")),
            createCycleDate(startDate: date("2025-01-31"), endDate: date("2025-02-02")),
            createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03")),
            createCycleDate(startDate: date("2025-03-28"), endDate: date("2025-04-01")),
            createCycleDate(startDate: date("2025-04-26"), endDate: date("2025-04-30")),
            createCycleDate(startDate: date("2025-05-26"), endDate: date("2025-05-30")),
            createCycleDate(startDate: date("2025-06-25"), endDate: date("2025-06-29"))
        ]
        
        return Array(cycles.prefix(upTo: count))
    }
    
    private func createCycleDate(startDate: Date, endDate: Date? = nil) -> CycleDate {
        CycleDate(startDate: startDate, endDate: endDate)
    }
    
    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }
}
