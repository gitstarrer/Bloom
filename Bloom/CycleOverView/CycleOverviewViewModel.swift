//
//  CycleOverviewViewModel.swift
//  Bloom
//
//  Created by Himanshu on 22/08/25.
//

import Foundation
import BloomCore
import BloomApplication

class CycleOverviewViewModel: ObservableObject {
    let periodService: PeriodOverviewProtocol
    
    @Published var periodList: [Period] = []
    
    @Published var lastPeriodText: String = ""
    @Published var cycleDayText: String = ""
    @Published var nextPeriodText: String = ""
    @Published var fertileWindowText: String = ""
    @Published var averageCycleLengthText: String = ""
    @Published var averagePeriodLengthText: String = ""
    @Published var ovulationDateText: String = ""
    
    var lastPeriod: Period? {
        periodList.last
    }
    
    init(periodService: PeriodOverviewProtocol) {
        self.periodService = periodService
        loadData()
        setupTexts()
    }
    
    func loadData() {
        periodList = periodService.getAllPeriods()
    }
    
    func setupTexts(withCurrentDate currentDate: Date = Date()) {
        if let lastPeriod = lastPeriod {
            let startDate = lastPeriod.getDates().startDate
            setLastPeriodText(withDate: startDate)
            setCycleDayText(withDate: startDate, fromDate: currentDate)
            try? setNextPeriodText(withDate: startDate, fromDate: currentDate)
            try? setFertileWindowText(forDate: startDate)
            try? setOvulationDateText(forDate: startDate)
        }
        
        setAverageCycleLengthText(withMaxRecentCycles: nil)
        try? setAveragePeriodLengthText()
    }
    
    func setLastPeriodText(withDate date: Date) {
        lastPeriodText = "Last period: \(date.formatted(date: .abbreviated, time: .omitted))"
    }
    
    func setCycleDayText(withDate date: Date, fromDate currentDate: Date = Date()) {
        let day = Calendar.current.dateComponents([.day], from: date, to: currentDate).day ?? 0
        cycleDayText = "Day \(day + 1)"
    }

    func setNextPeriodText(withDate date: Date, fromDate currentDate: Date = Date()) throws {
        let nextPeriod = try periodService.predictNextPeriod(fromDate: Date())
        nextPeriodText = "Next period: \(nextPeriod.formatted(date: .abbreviated, time: .omitted))"
    }
     
    func setFertileWindowText(forDate date: Date) throws {
        let fertileWindow = try periodService.getFertileWindow(forDate: Date())
        fertileWindowText = "Fertile window: \(fertileWindow.start.formatted(date: .abbreviated, time: .omitted)) – \(fertileWindow.end.formatted(date: .abbreviated, time: .omitted))"
    }
    
    func setAverageCycleLengthText(withMaxRecentCycles maxCycles: Int?) {
        let avgCycleLength = periodService.getAverageCycleLength(maxRecentCycles: maxCycles)
        averageCycleLengthText = "Average cycle length: \(avgCycleLength) days"
    }
    
    func setAveragePeriodLengthText() throws {
        let avgPeriodLength = try periodService.getAveragePeriodLength()
        averagePeriodLengthText = "Average period duration: \(avgPeriodLength) days"
    }
    
    func setOvulationDateText(forDate date: Date) throws {
        let ovulationDate = try periodService.getOvulationDate(forDate: date)
        ovulationDateText = "Ovulation: \(ovulationDate.formatted(date: .abbreviated, time: .omitted))"
    }
}
