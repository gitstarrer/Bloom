//
//  PeriodStore.swift
//  Bloom
//
//  Created by Himanshu on 20/08/25.
//

import Foundation

public protocol PeriodStore {
    func save(_ period: Period) async
    func delete(_ period: Period) async
    func fetchAll() async -> [Period] 
//    func fetch(in range: DateInterval) throws -> [Period]
//    func fetchLatestPeriod() throws -> Period?
    func deleteAll() async
}
