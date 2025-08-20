//
//  CycleTrackerTests.swift
//  BloomCoreTests
//
//  Created by Himanshu on 18/08/25.
//

import Testing
import Foundation
import BloomCore

struct CycleTrackerTests {
    
    @Test
    func test_logCycleDate_logsDateWhenEndDateIsNil() {
        let cycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: nil)
        let sut = makeSUT()
        
        try? sut.logCycleDate(cycleDate)
        
        #expect(sut.cycles == [cycleDate])
    }
    
    @Test
    func test_logCycleDate_throwsInvalidInputErrorWhenStartDateIsGreaterThanEndDate() {
        let cycleDate = createCycleDate(startDate: date("2025-01-05"), endDate: date("2025-01-02"))
        let sut = makeSUT()
        
        #expect(throws: CycleError.invalidDateRange, performing: {
            try sut.logCycleDate(cycleDate)
        })
    }

    @Test
    func test_logCycleDate_logsDateWhenCycleDatesIsEmpty() {
        let cycleDate = createMultipleCycleDates(count: 1)[0]
        let sut = makeSUT()
        
        try? sut.logCycleDate(cycleDate)
        
        #expect(sut.cycles == [cycleDate])
    }
    
    @Test
    func test_logCycleDate_logsDateWhenCycleDatesIsNotEmpty() {
        let cycles = createMultipleCycleDates(count: 2)
        let sut = makeSUT()
        
        cycles.forEach { try? sut.logCycleDate($0) }
        
        #expect(sut.cycles == [cycles[0], cycles[1]])
    }
    
    @Test
    func test_logCycleDate_replacesDateWhenLoggingWithTheSameStartDateTwice() {
        let cycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05"))
        let updatedCycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-03"))
        let sut = makeSUT()
        
        try? sut.logCycleDate(cycleDate)
        try? sut.logCycleDate(updatedCycleDate)
        
        #expect(sut.cycles == [updatedCycleDate])
    }
    
    @Test
    func test_logCycleDate_hasSortedDatesWhenMultipleEntriesAreLogged() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        let reversedCycles = cycles.reversed()
        
        reversedCycles.forEach { try? sut.logCycleDate($0) }
        
        #expect(sut.cycles == cycles)
    }
    
    @Test
    func test_logCycleDate_hasSortedAndUniqueDatesWhenMultipleEntriesAreLoggedWithDuplicateEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let cyclesWithDuplicates: [Cycle] = cycles + cycles
        let sut = makeSUT()
        
        cyclesWithDuplicates.forEach { try? sut.logCycleDate($0) }
        
        #expect(sut.cycles == cycles)
    }

    @Test
    func test_logCycleDate_updatesDateAfterEditingWithOneEntry() {
        let cycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05"))
        let updatedCycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-03"))
        let sut = makeSUT()
        
        try? sut.logCycleDate(cycleDate)
        try? sut.logCycleDate(updatedCycleDate)

        #expect(sut.cycles == [updatedCycleDate])
    }
    
    @Test
    func test_logCycleDate_updatesCorrectDateAfterEditingWithMultipleEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        cycles.forEach { try? sut.logCycleDate($0) }
        #expect(sut.cycles == cycles)
        
        let newCycleDate = createCycleDate(startDate: date("2025-03-28"), endDate: date("2025-03-31"))
        try? sut.logCycleDate(newCycleDate)

        #expect(sut.cycles.count == cycles.count)
        #expect(sut.cycles[3] == newCycleDate)
    }
    
    @Test
    func test_deleteCycleDate_removesDateWhenCycleDateHasOneItem() {
        let sut = makeSUT()
        let cycleDate = createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03"))
        
        try? sut.logCycleDate(cycleDate)
        sut.delete(cycleDate: cycleDate)
        
        #expect(sut.cycles.isEmpty)
    }
    
    @Test
    func test_deleteCycleDate_removesDateWhenCycleDatesHasMoreThanOneItem() {
        let sut = makeSUT()
        let cycleDates = createMultipleCycleDates(count: 3)
        cycleDates.forEach { try? sut.logCycleDate($0) }
        
        sut.delete(cycleDate: cycleDates[1])
        
        #expect(sut.cycles == [cycleDates[0], cycleDates[2]])
    }
    
    @Test
    func test_deleteCycleDate_removesUpdatedDateAfterUpdating() {
        let sut = makeSUT()
        let cycleDates = createMultipleCycleDates(count: 3)
        cycleDates.forEach { try? sut.logCycleDate($0) }
        let updatedCycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-04"))
        try? sut.logCycleDate(updatedCycleDate)
        
        sut.delete(cycleDate: cycleDates[1])
        
        #expect(sut.cycles == [cycleDates[0], cycleDates[2]])
    }

    @Test
    func test_calculateAverageCycleLength_returnsDefaultCycleLengthWhenCycleDatesIsEmpty() {
        let sut = makeSUT()
        let averageCycleLength = sut.calculateAverageCycleLength()
        #expect(sut.cycles == [])
        #expect(averageCycleLength == 28)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsDefaultAverageCycleLengthWithOneEntry() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 1)
        
        try? sut.logCycleDate(cycles[0])
        
        #expect(sut.calculateAverageCycleLength() == 28)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithTwoEntries() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 2)
        cycles.forEach{ try? sut.logCycleDate($0) }
        #expect(sut.calculateAverageCycleLength() == 30)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithMultipleEntries() {
        let sut = CycleTracker()

        // Simulate 7 cycles with varying start dates
        // Jan 1, Jan 29 (28 days later), Feb 27 (29 days later), Mar 28 (29 days later),
        // Apr 26 (29 days later), May 26 (30 days later), Jun 25 (30 days later)
        let cycles = createMultipleCycleDates(count: 7)

        cycles.forEach { try? sut.logCycleDate($0) }

        // We expect the average over last 6 intervals:
        // [31, 29, 29, 29, 30, 30] → sum = 177 → avg = 29
        let average = sut.calculateAverageCycleLength()

        #expect(average == 29)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithMultipleEntriesForMaxRecentCycles() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 7)
        cycles.forEach { try? sut.logCycleDate($0) }

        // We expect the average over last 2 intervals:
        // [29, 29, 30, 30] → sum = 60 → avg = 30
        let average = sut.calculateAverageCycleLength(maxRecentCycles: 2)

        #expect(average == 30)
    }
    
    @Test
    func test_predictNextCycleStartDay_throwsErrorWhenNoDataAvailable() {
        let sut = makeSUT()
        #expect(throws: CycleError.noDataAvailable, performing: {
            try sut.predictNextCycleStartDate()
        })
    }
    
    @Test
    func test_predictNextCycleStartDay_returnsDefaultAverageCycleWithOneEntry() {
        let cycleDate = createMultipleCycleDates(count: 1)[0]
        let expectedNextStartDate = getExpectedCycleDay(from: date("2025-01-01"), withAverageCycle: 28)

        let sut = makeSUT()
        try? sut.logCycleDate(cycleDate)
        
        let nextCycleStartDay = try? sut.predictNextCycleStartDate()
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_predictNextCycleStartDay_returnsAverageCycleWithTwoEntries() {
        let cycleDates = createMultipleCycleDates(count: 2)
        let expectedNextStartDate = getExpectedCycleDay(from: date("2025-01-31"), withAverageCycle: 30)
        
        let sut = makeSUT()
        cycleDates.forEach{ try? sut.logCycleDate($0) }

        let nextCycleStartDay = try? sut.predictNextCycleStartDate()
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_predictNextCycleStartDay_returnsAverageCycleWithMultipleEntries() {
        let cycleDates = createMultipleCycleDates(count: 7)
        let expectedNextStartDate = getExpectedCycleDay(from: date("2025-06-25"), withAverageCycle: 29)
        
        let sut = makeSUT()
        cycleDates.forEach{ try? sut.logCycleDate($0) }

        let nextCycleStartDay = try? sut.predictNextCycleStartDate()
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_predictNextCycleStartDay_updatesAfterDeletingCycle() {
        let cycleDates = createMultipleCycleDates(count: 5)
        let expectedNextStartDate = getExpectedCycleDay(from: date("2025-01-31"), withAverageCycle: 30)
        let sut = makeSUT()
        cycleDates.forEach{ try? sut.logCycleDate($0) }
        sut.delete(cycleDate: cycleDates[2])
        sut.delete(cycleDate: cycleDates[3])
        sut.delete(cycleDate: cycleDates[4])
        
        let nextCycleStartDay = try? sut.predictNextCycleStartDate()
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    //Helpers
    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func getExpectedCycleDay(from startDate: Date, withAverageCycle days: Int) -> Date? {
        var expectedNextStartDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)
        while let date = expectedNextStartDate, date < Date() {
            expectedNextStartDate =  Calendar.current.date(byAdding: .day, value: days, to: date)
        }
        return expectedNextStartDate
    }
    
    private func createMultipleCycleDates(count: Int) -> [Cycle] {
        let cycles = [
            createCycleDate(startDate: date("2023-11-25"), endDate: date("2023-11-29")),
            createCycleDate(startDate: date("2023-12-24"), endDate: date("2023-12-28")),
            
            createCycleDate(startDate: date("2024-01-23"), endDate: date("2024-01-27")),
            createCycleDate(startDate: date("2024-02-22"), endDate: date("2024-02-26")),
            createCycleDate(startDate: date("2024-03-22"), endDate: date("2024-03-26")),
            createCycleDate(startDate: date("2024-04-21"), endDate: date("2024-04-25")),
            createCycleDate(startDate: date("2024-05-21"), endDate: date("2024-05-25")),
            createCycleDate(startDate: date("2024-06-20"), endDate: date("2024-06-24")),
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
