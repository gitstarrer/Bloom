//
//  CycleTrackerTests.swift
//  BloomCoreTests
//
//  Created by Himanshu on 18/08/25.
//

import Testing
import Foundation

class CycleTracker {
    var cycleStartDate: Date?
    var cycleEndDate: Date?
    
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
    
}


struct CycleTrackerTests {

    @Test
    func test_logCycleStartDate_capturesCurrentStartDate() {
        let startDate = Date()
        let sut = makeSUT()
        
        sut.logCycleStartDate(startDate)
        
        #expect(sut.cycleStartDate == startDate)
    }
    
    @Test
    func test_logCycleEndDate_capturesCurrentEndDate() {
        let endDate = Date()
        let sut = makeSUT()
        
        sut.logCycleEndDate(endDate)
        
        #expect(sut.cycleEndDate == endDate)
    }

    @Test
    func test_logCycleStartDate_capturesLatestStartDateAfterEditing() {
        let (oldStartDate, newStartDate) = createEditingDates(withOffset: 345)
        let sut = makeSUT()
        
        sut.logCycleStartDate(oldStartDate)
        sut.logCycleStartDate(newStartDate)

        #expect(sut.cycleStartDate == newStartDate)
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
    
    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
    
    private func createEditingDates(withOffset offset: TimeInterval) -> (oldDate: Date, newDate: Date) {
        (Date(), Date(timeIntervalSinceNow: offset))
    }
}
