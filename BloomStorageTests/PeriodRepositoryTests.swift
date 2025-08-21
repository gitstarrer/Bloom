//
//  PeriodRepositoryTests.swift
//  Bloom
//
//  Created by Himanshu on 21/08/25.
//


import Testing
import BloomCore

@Suite("PeriodRepository Tests")
struct PeriodRepositoryTests {
    
    @Test("fetchAll delegates to store")
    func test_fetchAllDelegates() async {
        let store = MockStore(savedPeriods: [Period(startDate: .now, endDate: .now)])
        let sut = PrimaryPeriodRepository(store: store)
        
        _ = await sut.fetchAll()
        
        #expect(store.fetchCalled, "Expected fetchAll to be called on store")
    }
    
    @Test("save delegates to store")
    func test_saveDelegates() async {
        let store = MockStore(savedPeriods: [])
        let sut = PrimaryPeriodRepository(store: store)
        let period = Period(startDate: .now, endDate: .now.addingTimeInterval(100))
        
        await sut.save(period)
        
        #expect(store.saveCalled, "Expected save to be called on store")
        #expect(store.savedPeriods.contains(period))
    }
    
    @Test("delete delegates to store")
    func test_deleteDelegates() async {
        let store = MockStore(savedPeriods: [Period(startDate: .now, endDate: .now)])
        let sut = PrimaryPeriodRepository(store: store)
        let period = store.savedPeriods.first!
        
        await sut.delete(period)
        
        #expect(store.deleteCalled, "Expected delete to be called on store")
        #expect(!store.savedPeriods.contains(period))
    }
    
    class MockStore: PeriodStore {
        var savedPeriods: [Period] = []
        var fetchCalled = false
        var saveCalled = false
        var deleteCalled = false
        
        init(savedPeriods: [Period], fetchCalled: Bool = false, saveCalled: Bool = false, deleteCalled: Bool = false) {
            self.savedPeriods = savedPeriods
            self.fetchCalled = fetchCalled
            self.saveCalled = saveCalled
            self.deleteCalled = deleteCalled
        }
        
        func fetchAll() async -> [BloomCore.Period] {
            fetchCalled = true
            return savedPeriods
        }
        
        func save(_ period: BloomCore.Period) async {
            saveCalled = true
            savedPeriods.append(period)
        }
        
        func delete(_ period: BloomCore.Period) async {
            deleteCalled = true
            savedPeriods.removeAll { $0 == period }
        }
        
        func deleteAll() async {
            deleteCalled = true
        }
    }
}
