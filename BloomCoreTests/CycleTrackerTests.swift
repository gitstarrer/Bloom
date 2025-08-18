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
    func test_logCycleEndDate_capturesLatestStartDateAfterEditing() {
        let oldStartDate = Date()
        let newStartDate = Date(timeIntervalSinceNow: 1234)
        
        let sut = makeSUT()
        
        sut.logCycleStartDate(oldStartDate)
        sut.logCycleStartDate(newStartDate)

        #expect(sut.cycleStartDate == newStartDate)
    }
    
    @Test
    func test_logCycleEndDate_capturesLatestEndDateAfterEditing() {
        let oldEndDate = Date()
        let newEndDate = Date(timeIntervalSinceNow: 1234)
        
        let sut = makeSUT()
        
        sut.logCycleEndDate(oldEndDate)
        sut.logCycleEndDate(newEndDate)

        #expect(sut.cycleEndDate == newEndDate)
    }
    
    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
}
