//
//  PredictionServiceProtocol.swift
//  Bloom
//
//  Created by Himanshu on 22/08/25.
//

import Foundation

public protocol PredictionServiceProtocol {
    var periods: [Period] { get }
    func addPeriod(_ period: Period) throws
    func delete(period date: Period)
    func getAverageCycleLength(maxRecentCycles: Int?) -> Int
    func predictNextPeriod(fromDate date: Date) throws -> Date
    func getAveragePeriodLength() throws -> Int
    func getOvulationDate(forDate currentDate: Date) throws -> Date
    func getFertileWindow(forDate currentDate: Date) throws -> (start: Date, end: Date)
}
