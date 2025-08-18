//
//  CycleTrackerTests.swift
//  BloomCoreTests
//
//  Created by Himanshu on 18/08/25.
//

import Testing
import Foundation

struct CycleDate: Equatable {
    var startDate: Date?
    var endDate: Date?
}

class CycleTracker {
    var cycleDates: [CycleDate] = []
    
    var cycleStartDate: Date?
    var cycleEndDate: Date?
    
    func logCycleDate(_ cycleDate: CycleDate, at index: Int? = nil) {
        if let index, index < cycleDates.count {
            cycleDates[index] = cycleDate
        } else {
            cycleDates.append(cycleDate)
        }
    }
    
    func logCycleStartDate(_ date: Date) {
        cycleStartDate = date
    }
    
    func logCycleEndDate(_ date: Date) {
        cycleEndDate = date
    }
    
    func deleteCycleStartDate() {
        cycleStartDate = nil
    }
    
    func deleteCycleEndDate() {
        cycleEndDate = nil
    }
    
    func calculateAverageCycleLength() -> Int {
        28
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
    func test_logCycleEndDate_capturesLatestEndDateAfterEditing() {
        let (oldEndDate, newEndDate) = createEditingDates(withOffset: 1234)
        let sut = makeSUT()
        
        sut.logCycleEndDate(oldEndDate)
        sut.logCycleEndDate(newEndDate)

        #expect(sut.cycleEndDate == newEndDate)
    }
    
    @Test
    func test_deleteCycleStartDate_resetsStartDateToNil() {
        let sut = makeSUT()
        
        sut.logCycleStartDate(Date())
        sut.deleteCycleStartDate()
        
        #expect(sut.cycleStartDate == nil)
    }
    
    @Test
    func test_deleteCycleEndDate_resetsEndDateToNil() {
        let sut = makeSUT()
        
        sut.logCycleEndDate(Date())
        sut.deleteCycleEndDate()
        
        #expect(sut.cycleEndDate == nil)
    }
    
    @Test
    func test_calculateAverageCycleLength_returnsNilWhenCycleDatesIsEmpty() {
        let sut = makeSUT()
        let averageCycleLength = sut.calculateAverageCycleLength()
        #expect(sut.cycleDates == [])
        #expect(averageCycleLength == 28)
    }
    
    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func createEditingDates(withOffset offset: TimeInterval) -> (oldDate: Date, newDate: Date) {
        (Date(), Date(timeIntervalSinceNow: offset))
    }
    
    private func createCycleDate(_ startDate: Date = Date(), _ endDate: Date = Date(timeIntervalSinceNow: 23)) -> CycleDate {
        CycleDate(startDate: startDate, endDate: endDate)
    }
}
