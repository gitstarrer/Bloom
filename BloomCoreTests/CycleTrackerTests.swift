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
    
    
    func logCycleStartDate(_ date: Date) {
        cycleStartDate = date
    }
}


struct CycleTrackerTests {

    @Test
    func test_addCycleStartDate_capturesCurrentStartDate() {
        let startDate = Date()
        let sut = CycleTracker()
        sut.logCycleStartDate(startDate)
        
        #expect(sut.cycleStartDate == startDate)
    }

}
