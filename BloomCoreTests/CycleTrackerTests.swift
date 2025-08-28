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
        
        try? sut.addPeriod(cycleDate)
        
        #expect(sut.periods == [cycleDate])
    }
    
    @Test
    func test_logCycleDate_throwsInvalidInputErrorWhenStartDateIsGreaterThanEndDate() {
        let cycleDate = createCycleDate(startDate: date("2025-01-05"), endDate: date("2025-01-02"))
        let sut = makeSUT()
        
        #expect(throws: CycleError.invalidDateRange, performing: {
            try sut.addPeriod(cycleDate)
        })
    }

    @Test
    func test_logCycleDate_logsDateWhenCycleDatesIsEmpty() {
        let cycleDate = createMultipleCycleDates(count: 1)[0]
        let sut = makeSUT()
        
        try? sut.addPeriod(cycleDate)
        
        #expect(sut.periods == [cycleDate])
    }
    
    @Test
    func test_logCycleDate_logsDateWhenCycleDatesIsNotEmpty() {
        let cycles = createMultipleCycleDates(count: 2)
        let sut = makeSUT()
        
        cycles.forEach { try? sut.addPeriod($0) }
        
        #expect(sut.periods == [cycles[0], cycles[1]])
    }
    
    @Test
    func test_logCycleDate_replacesDateWhenLoggingWithTheSameStartDateTwice() {
        let cycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05"))
        let updatedCycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-03"))
        let sut = makeSUT()
        
        try? sut.addPeriod(cycleDate)
        try? sut.addPeriod(updatedCycleDate)
        
        #expect(sut.periods == [updatedCycleDate])
    }
    
    @Test
    func test_logCycleDate_hasSortedDatesWhenMultipleEntriesAreLogged() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        let reversedCycles = cycles.reversed()
        
        reversedCycles.forEach { try? sut.addPeriod($0) }
        
        #expect(sut.periods == cycles)
    }
    
    @Test
    func test_logCycleDate_hasSortedAndUniqueDatesWhenMultipleEntriesAreLoggedWithDuplicateEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let cyclesWithDuplicates: [Period] = cycles + cycles
        let sut = makeSUT()
        
        cyclesWithDuplicates.forEach { try? sut.addPeriod($0) }
        
        #expect(sut.periods == cycles)
    }

    @Test
    func test_logCycleDate_updatesDateAfterEditingWithOneEntry() {
        let cycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-05"))
        let updatedCycleDate = createCycleDate(startDate: date("2025-01-01"), endDate: date("2025-01-03"))
        let sut = makeSUT()
        
        try? sut.addPeriod(cycleDate)
        try? sut.addPeriod(updatedCycleDate)

        #expect(sut.periods == [updatedCycleDate])
    }
    
    @Test
    func test_logCycleDate_updatesCorrectDateAfterEditingWithMultipleEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        cycles.forEach { try? sut.addPeriod($0) }
        #expect(sut.periods == cycles)
        
        let newCycleDate = createCycleDate(startDate: date("2024-02-22"), endDate: date("2024-02-25"))
        try? sut.addPeriod(newCycleDate)

        #expect(sut.periods.count == cycles.count)
        #expect(sut.periods[3] == newCycleDate)
    }
    
    @Test
    func test_deleteCycleDate_removesDateWhenCycleDateHasOneItem() {
        let sut = makeSUT()
        let cycleDate = createCycleDate(startDate: date("2025-02-27"), endDate: date("2025-03-03"))
        
        try? sut.addPeriod(cycleDate)
        sut.delete(period: cycleDate)
        
        #expect(sut.periods.isEmpty)
    }
    
    @Test
    func test_deleteCycleDate_removesDateWhenCycleDatesHasMoreThanOneItem() {
        let sut = makeSUT()
        let cycleDates = createMultipleCycleDates(count: 3)
        cycleDates.forEach { try? sut.addPeriod($0) }
        
        sut.delete(period: cycleDates[1])
        
        #expect(sut.periods == [cycleDates[0], cycleDates[2]])
    }
    
    @Test
    func test_deleteCycleDate_removesUpdatedDateAfterUpdating() {
        let sut = makeSUT()
        let cycleDates = createMultipleCycleDates(count: 3)
        cycleDates.forEach { try? sut.addPeriod($0) }
        let updatedCycleDate = createCycleDate(startDate: date("2023-12-24"), endDate: date("2023-12-25"))
        try? sut.addPeriod(updatedCycleDate)
        
        sut.delete(period: cycleDates[1])
        
        #expect(sut.periods == [cycleDates[0], cycleDates[2]])
    }

    @Test
    func test_calculateAverageCycleLength_returnsDefaultCycleLengthWhenCycleDatesIsEmpty() {
        let sut = makeSUT()
        let averageCycleLength = sut.getAverageCycleLength()
        #expect(sut.periods == [])
        #expect(averageCycleLength == 28)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsDefaultAverageCycleLengthWithOneEntry() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 1)
        
        try? sut.addPeriod(cycles[0])
        
        #expect(sut.getAverageCycleLength() == 28)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithTwoEntries() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 2)
        cycles.forEach{ try? sut.addPeriod($0) }
        #expect(sut.getAverageCycleLength() == 29)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithMultipleEntries() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 7)
        cycles.forEach { try? sut.addPeriod($0) }

        let average = sut.getAverageCycleLength()

        #expect(average == 30)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsAverageCycleLengthWithMultipleEntriesForMaxRecentCycles() {
        let sut = CycleTracker()
        let cycles = createMultipleCycleDates(count: 7)
        cycles.forEach { try? sut.addPeriod($0) }

        let average = sut.getAverageCycleLength(maxRecentCycles: 2)

        #expect(average == 30)
    }
    
    @Test
    func test_predictNextCycleStartDay_throwsErrorWhenNoDataAvailable() {
        let sut = makeSUT()
        #expect(throws: CycleError.notEnoughData, performing: {
            try sut.predictNextPeriod()
        })
    }
    
    @Test
    func test_predictNextCycleStartDay_returnsDefaultAverageCycleWithOneEntry() {
        let cycleDate = createMultipleCycleDates(count: 1)[0]
        let currentDate: Date = date("2024-03-17")
        let expectedNextStartDate = getExpectedCycleDay(from: date("2023-11-25"), withAverageCycle: 28, fromDate: currentDate)

        let sut = makeSUT()
        try? sut.addPeriod(cycleDate)
        
        let nextCycleStartDay = try? sut.predictNextPeriod(fromDate: currentDate)
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_predictNextCycleStartDay_returnsAverageCycleWithTwoEntries() {
        let cycleDates = createMultipleCycleDates(count: 2)
        let currentDate: Date = date("2024-06-01")
        let expectedNextStartDate = getExpectedCycleDay(from: date("2023-12-24"), withAverageCycle: 29, fromDate: currentDate)
        
        let sut = makeSUT()
        cycleDates.forEach{ try? sut.addPeriod($0) }

        let nextCycleStartDay = try? sut.predictNextPeriod(fromDate: currentDate)
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_predictNextCycleStartDay_returnsAverageCycleWithMultipleEntries() {
        let cycleDates = createMultipleCycleDates(count: 7)
        let expectedNextStartDate = getExpectedCycleDay(from: date("2024-05-21"), withAverageCycle: 30)
        
        let sut = makeSUT()
        cycleDates.forEach{ try? sut.addPeriod($0) }

        let nextCycleStartDay = try? sut.predictNextPeriod()
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_predictNextCycleStartDay_updatesAfterDeletingCycle() {
        let cycleDates = createMultipleCycleDates(count: 5)
        let currentDate: Date = date("2024-06-01")
        let expectedNextStartDate = getExpectedCycleDay(from: date("2023-12-24"), withAverageCycle: 29, fromDate: currentDate)
        let sut = makeSUT()
        cycleDates.forEach{ try? sut.addPeriod($0) }
        sut.delete(period: cycleDates[2])
        sut.delete(period: cycleDates[3])
        sut.delete(period: cycleDates[4])
        
        let nextCycleStartDay = try? sut.predictNextPeriod(fromDate: currentDate)
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_predictNextCycleStartDay_returnsAverageCycleWithMultipleEntriesInLeapYear() {
        let leapYearCycleDates = createMultipleCycleDates(count: 6)
        let expectedNextStartDate = getExpectedCycleDay(from: date("2024-04-21"), withAverageCycle: 30, fromDate: date("2024-04-27"))
        
        let sut = makeSUT()
        leapYearCycleDates.forEach{ try? sut.addPeriod($0) }

        let nextCycleStartDay = try? sut.predictNextPeriod(fromDate: date("2024-04-27"))
        
        #expect(nextCycleStartDay == expectedNextStartDate)
    }
    
    @Test
    func test_calculateAveragePeriodLength_throwsErrorOnEmptyList() {
        let sut = makeSUT()
        #expect(throws: CycleError.notEnoughData, performing: {
            try sut.getAveragePeriodLength()
        })
    }
    
    @Test
    func test_duration_returnsOneWhenStartAndEndSameDay() {
        let date = Date()
        let period = Period(startDate: date, endDate: date)
        let sut = makeSUT()
        try? sut.addPeriod(period)
        
        let averagePeriodLength = try? sut.getAveragePeriodLength()
        
        #expect(averagePeriodLength == 1)
    }
    
    @Test
    func test_calculateAveragePeriodLength_returnsDefaultForOngoingPeriod() {
        let period = Period(startDate: Date())
        let sut = makeSUT()
        try? sut.addPeriod(period)
        
        let averagePeriodLength = try? sut.getAveragePeriodLength()
        
        #expect(averagePeriodLength == 5)
    }
    
    @Test
    func test_calculateAveragePeriodLength_returnsPeriodLengthForSingleEntry() {
        let cycles = createMultipleCycleDates(count: 1)
        let sut = makeSUT()
        try? sut.addPeriod(cycles[0])
        
        let averagePeriodLength = try? sut.getAveragePeriodLength()
        
        #expect(averagePeriodLength == 2)
    }
    
    @Test
    func test_calculateAveragePeriodLength_returnsAveragePeriodLengthWithOneOngoingPeriod() {
        let sut = makeSUT()
        let ended = Period(startDate: date("2025-01-01"), endDate: date("2025-01-03"))
        let ongoing = Period(startDate: date("2025-02-01"), endDate: nil)
        
        try? sut.addPeriod(ended)
        try? sut.addPeriod(ongoing)
        
        let average = try? sut.getAveragePeriodLength()
        
        #expect(average == 4)
    }
    
    @Test
    func test_calculateAveragePeriodLength_allOngoing() {
        let sut = makeSUT()
        (1...3).forEach { i in
            let ongoing = Period(startDate: Date().addingTimeInterval(Double(i) * -86400), endDate: nil)
            try? sut.addPeriod(ongoing)
        }
        
        let average = try? sut.getAveragePeriodLength()
        
        #expect(average == 5)
    }
    
    @Test
    func test_calculateAveragePeriodLength_returnsPeriodLengthForMultipleEntries() {
        let cycles = createMultipleCycleDates(count: 7)
        let sut = makeSUT()
        cycles.forEach{ try? sut.addPeriod($0) }
        
        let averagePeriodLength = try? sut.getAveragePeriodLength()
        
        #expect(averagePeriodLength == 3)
    }
    
    @Test
    func test_getOvulationDate_throwsErrorOnEmptyList() {
        let sut = makeSUT()
        #expect(throws: CycleError.notEnoughData, performing: {
            try sut.getOvulationDate()
        })
    }
    
    @Test
    func test_getOvulationDate_throwsErrorWithOneEntry() {
        let period = createMultipleCycleDates(count: 1)[0]
        let sut = makeSUT()
        try? sut.addPeriod(period)
        
        #expect(throws: CycleError.notEnoughData, performing: {
            try sut.getOvulationDate()
        })
    }
    
    @Test
    func test_getOvulationDate_handlesYearBoundary() {
        let sut = makeSUT()
        let periods = [
            createCycleDate(startDate: date("2024-11-01")),
            createCycleDate(startDate: date("2024-12-01"))
        ]
        periods.forEach { try? sut.addPeriod($0) }
        
        let ovulationDate = try? sut.getOvulationDate(forDate: date("2024-12-15"))
        
        #expect(ovulationDate == date("2024-12-17"))
    }
    
    @Test
    func test_getOvulationDate_withIrregularCyclesStillReturnsValidDate() {
        let sut = makeSUT()
        let periods = [
            createCycleDate(startDate: date("2024-08-01")),
            createCycleDate(startDate: date("2024-08-28")),
            createCycleDate(startDate: date("2024-10-02")),
            createCycleDate(startDate: date("2024-10-31"))
        ]
        periods.forEach { try? sut.addPeriod($0) }
        
        let ovulationDate = try? sut.getOvulationDate(forDate: date("2024-10-31"))
        
        #expect(ovulationDate != nil)
        #expect(Calendar.current.component(.day, from: ovulationDate!) > 0)
    }
    
    @Test
    func test_getOvulationDate_returnsDateWithMultipleEntries() {
        let periods = createMultipleCycleDates(count: 5)
        let sut = makeSUT()
        periods.forEach{ try? sut.addPeriod($0) }
        
        let ovulationDate = try? sut.getOvulationDate(forDate: date("2024-10-31"))
        
        #expect(ovulationDate == date("2024-11-03"))
    }
    
    @Test
        func test_getOvulationDate_ignoresTimeComponents() {
            let sut = makeSUT()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let periods = [
                createCycleDate(startDate: formatter.date(from: "2024-10-01 15:30")!),
                createCycleDate(startDate: formatter.date(from: "2024-10-30 09:45")!)
            ]
            periods.forEach { try? sut.addPeriod($0) }
            
            let ovulationDate = try? sut.getOvulationDate(forDate: date("2024-10-30"))
            
//            #expect(ovulationDate == date("2024-11-13"))
        }
    
    @Test
    func test_getFertileWindow_throwsErrorOnEmptyList() {
        let sut = makeSUT()
        #expect(throws: CycleError.notEnoughData, performing: {
            try sut.getFertileWindow()
        })
    }
    
    @Test
    func test_getFertileWindow_throwsErrorWithOneEntry() {
        let period = createMultipleCycleDates(count: 1)[0]
        let sut = makeSUT()
        try? sut.addPeriod(period)
        
        #expect(throws: CycleError.notEnoughData, performing: {
            try sut.getFertileWindow()
        })
    }
    
    @Test
    func test_getFertileWindow_returnsDateWithMultipleEntries() {
        let periods = createMultipleCycleDates(count: 5)
        let sut = makeSUT()
        periods.forEach{ try? sut.addPeriod($0) }
        
        let fertileWindow = try? sut.getFertileWindow(forDate: date("2024-10-31"))
        
        #expect(fertileWindow?.start == date("2024-10-29"))
        #expect(fertileWindow?.end == date("2024-11-08"))
    }
    
    //Helpers
    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func getExpectedCycleDay(from startDate: Date, withAverageCycle days: Int, fromDate date: Date = Date()) -> Date? {
        
        var expectedNextStartDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)
        
        while let predictedDate = expectedNextStartDate, predictedDate < date {
            expectedNextStartDate =  Calendar.current.date(byAdding: .day, value: days, to: predictedDate)
        }
        
        return expectedNextStartDate
    }
    
    private func createMultipleCycleDates(count: Int) -> [Period] {
        let cycles = [
            createCycleDate(startDate: date("2023-11-25"), endDate: date("2023-11-26")),
            createCycleDate(startDate: date("2023-12-24"), endDate: date("2023-12-25")),
            
            createCycleDate(startDate: date("2024-01-23"), endDate: date("2024-01-27")),
            createCycleDate(startDate: date("2024-02-22"), endDate: date("2024-02-23")),
            createCycleDate(startDate: date("2024-03-22"), endDate: date("2024-03-23")),
            createCycleDate(startDate: date("2024-04-21"), endDate: date("2024-04-23")),
            createCycleDate(startDate: date("2024-05-21"), endDate: date("2024-05-22")),
            createCycleDate(startDate: date("2024-06-20"), endDate: date("2024-06-24")),
        ]
        // 29, 30, 30, 29, 30, 30, 30
        return Array(cycles.prefix(upTo: count))
    }
    
    private func createCycleDate(startDate: Date, endDate: Date? = nil) -> Period {
        Period(startDate: startDate, endDate: endDate)
    }
    
    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: string)!
    }
}
