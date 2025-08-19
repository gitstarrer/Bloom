//
//  CycleTrackerTests.swift
//  BloomCoreTests
//
//  Created by Himanshu on 18/08/25.
//

import Testing
import Foundation

struct Cycle: Equatable, Hashable {
    var startDate: Date
    var endDate: Date?
    
    static func == (lhs: Cycle, rhs: Cycle) -> Bool {
        lhs.startDate == rhs.startDate
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(startDate)
    }
}

class CycleTracker {
    var cycleDates: [Cycle] = []
    
    func logCycleDate(_ cycleDate: Cycle) {
        cycleDates.removeAll { $0.startDate == cycleDate.startDate }
        cycleDates.append(cycleDate)
        cycleDates.sort { $0.startDate < $1.startDate }
    }
    
    func delete(cycleDate date: Cycle) {
        cycleDates.removeAll(where: { $0.startDate == date.startDate })
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
    func test_logCycleDate_logsDateWhenCycleDatesIsEmpty() {
        let cycleDate = createMultipleCycleDates(count: 1)[0]
        let sut = makeSUT()
        
        sut.logCycleDate(cycleDate)
        
        #expect(sut.cycleDates == [cycleDate])
    }
    
    @Test
    func test_logCycleDate_logsDateWhenCycleDatesIsNotEmpty() {
        let cycles = createMultipleCycleDates(count: 2)
        let sut = makeSUT()
        
        cycles.forEach { sut.logCycleDate($0) }
        
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
        let cyclesWithDuplicates: [Cycle] = cycles + cycles
        let sut = makeSUT()
        
        cyclesWithDuplicates.forEach { sut.logCycleDate($0) }
        
        #expect(sut.cycleDates == cycles)
    }

    @Test
    func test_logCycleDate_updatesDateAfterEditingWithOneEntry() {
        let cycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05"))
        let updatedCycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-03"))
        let sut = makeSUT()
        
        sut.logCycleDate(cycleDate)
        sut.logCycleDate(updatedCycleDate)

        #expect(sut.cycleDates == [updatedCycleDate])
    }
    
    @Test
    func test_logCycleDate_updatesCorrectDateAfterEditingWithMultipleEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        cycles.forEach { sut.logCycleDate($0) }
        #expect(sut.cycleDates == cycles)
        
        let newCycleDate = createCycleDate(startDate: date("2025-03-28"), endDate: date("2025-03-31"))
        sut.logCycleDate(newCycleDate)

        #expect(sut.cycleDates.count == cycles.count)
        #expect(sut.cycleDates[3] == newCycleDate)
    }
    
    @Test
    func test_deleteCycleDate_removesDateWhenCycleDateHasOneItem() {
        let sut = makeSUT()
        let cycleDate = createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03"))
        
        sut.logCycleDate(cycleDate)
        sut.delete(cycleDate: cycleDate)
        
        #expect(sut.cycleDates.isEmpty)
    }
    
    @Test
    func test_deleteCycleDate_removesDateWhenCycleDatesHasMoreThanOneItem() {
        let sut = makeSUT()
        let cycleDates = createMultipleCycleDates(count: 3)
        cycleDates.forEach { sut.logCycleDate($0) }
        
        sut.delete(cycleDate: cycleDates[1])
        
        #expect(sut.cycleDates == [cycleDates[0], cycleDates[2]])
    }
    
    @Test
    func test_deleteCycleDate_removesUpdatedDateAfterUpdating() {
        let sut = makeSUT()
        let cycleDates = createMultipleCycleDates(count: 3)
        cycleDates.forEach { sut.logCycleDate($0) }
        let updatedCycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-04"))
        sut.logCycleDate(updatedCycleDate)
        
        sut.delete(cycleDate: cycleDates[1])
        
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
        cycles.forEach{ sut.logCycleDate($0) }
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
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithMultipleEntriesForMaxRecentCycles() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 7)
        cycles.forEach { sut.logCycleDate($0) }

        // We expect the average over last 2 intervals:
        // [29, 29, 30, 30] → sum = 60 → avg = 30
        let average = sut.calculateAverageCycleLength(maxRecentCycles: 2)

        #expect(average == 30)
    }

    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func createMultipleCycleDates(count: Int) -> [Cycle] {
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
    
    private func createCycleDate(startDate: Date, endDate: Date? = nil) -> Cycle {
        Cycle(startDate: startDate, endDate: endDate)
    }
    
    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }
}
