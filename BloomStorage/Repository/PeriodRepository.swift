//
//  PeriodRepository.swift
//  Bloom
//
//  Created by Himanshu on 21/08/25.
//

public protocol PeriodRepository {
    func fetchAll() async -> [Period]
    func save(_ period: Period) async throws
    func delete(_ period: Period) async throws
}
