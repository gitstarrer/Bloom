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

    private func makeSUT() -> CycleTracker {
        CycleTracker()
    }
}
