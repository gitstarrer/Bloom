//
//  PrimaryPeriodRepository.swift
//  Bloom
//
//  Created by Himanshu on 21/08/25.
//

public final class PrimaryPeriodRepository: PeriodRepositoryProtocol {
    private var store: PeriodStore
    
    public init(store: PeriodStore) {
        self.store = store
    }
    
    public func fetchAll() async -> [Period] {
        await store.fetchAll()
    }
    
    public func save(_ period: Period) async {
        await store.save(period)
    }
    
    public func delete(_ period: Period) async {
        await store.delete(period)
    }
}
