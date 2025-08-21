//
//  UserDefaultsPeriodStore.swift
//  Bloom
//
//  Created by Himanshu on 21/08/25.
//

import Foundation

public actor UserDefaultsPeriodStore: PeriodStore {
    
    private let defaults: UserDefaults
    private let storageKey = "com.bloom.stored_periods"
    
    public init(userDefaults: UserDefaults) {
        self.defaults = userDefaults
    }
    
    public func save(_ period: Period) async {
        var periodList = await fetchAll()
        
        periodList.append(period)
        if let data = try? JSONEncoder().encode(periodList) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    public func delete(_ period: Period) async {
        var periodList = await fetchAll()
        periodList.removeAll(where: { $0 == period })
        if let data = try? JSONEncoder().encode(periodList) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    public func fetchAll() async -> [Period] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([Period].self, from: data)) ?? []
    }
    
    public func deleteAll() async {
        defaults.set(nil, forKey: storageKey)
    }
}
