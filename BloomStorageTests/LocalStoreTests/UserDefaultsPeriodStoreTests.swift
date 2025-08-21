//
//  UserDefaultsPeriodStoreTests.swift
//  BloomStorageTests
//
//  Created by Himanshu on 20/08/25.
//

import XCTest
import BloomCore

final class UserDefaultsPeriodStoreTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!
    private var sut: PeriodStore!
    
    override func setUp() {
        super.setUp()
        suiteName = "test-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        sut = UserDefaultsPeriodStore(userDefaults: defaults)
    }
    
    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        suiteName = nil
        defaults = nil
        sut = nil
        super.tearDown()
    }
    
    func test_init_fetchesEmptyResults() async {
        await expect(sut, toCompleteWith: [])
    }
    
    func test_save_savesPeriod() async {
        let periodEntry = Period(startDate: Date(), endDate: Date(timeIntervalSinceNow: 100))
        await sut.save(periodEntry)
        await expect(sut, toCompleteWith: [periodEntry])
    }
    
    func test_save_multiplePeriods() async {
        let p1 = Period(startDate: Date(), endDate: Date().addingTimeInterval(100))
        let p2 = Period(startDate: Date().addingTimeInterval(200), endDate: Date().addingTimeInterval(300))
        
        await sut.save(p1)
        await sut.save(p2)
        
        await expect(sut, toCompleteWith: [p1, p2])
    }

    func test_fetchAll_fromNewInstance_returnsSavedData() async {
        let p = Period(startDate: Date(), endDate: Date().addingTimeInterval(100))
        await sut.save(p)
        
        // create a new store with the same defaults
        let newSut = UserDefaultsPeriodStore(userDefaults: defaults)
        await expect(newSut, toCompleteWith: [p])
    }
    
    func test_fetchAll_withCorruptedData_returnsEmptyArray() async {
        defaults.set(Data("corrupted".utf8), forKey: "com.bloom.stored_periods")
        await expect(sut, toCompleteWith: [])
    }

    func test_delete_removesPeriodFromStore() async {
        let periodEntry = Period(startDate: Date(), endDate: Date(timeIntervalSinceNow: 100))
        await sut.save(periodEntry)
        await sut.delete(periodEntry)
        
        await expect(sut, toCompleteWith: [])
    }
    
    func test_delete_nonExistingPeriod_doesNothing() async {
        let p1 = Period(startDate: Date(), endDate: Date().addingTimeInterval(100))
        let p2 = Period(startDate: Date().addingTimeInterval(200), endDate: Date().addingTimeInterval(300))
        
        await sut.save(p1)
        await sut.delete(p2) // not saved before

        await expect(sut, toCompleteWith: [p1])
    }
    
    func test_delete_onEmptyStore_doesNothing() async {
        let p = Period(startDate: Date(), endDate: Date().addingTimeInterval(100))
        await sut.delete(p) // nothing saved yet
        
        await expect(sut, toCompleteWith: [])
    }
    
    func test_deleteAll_clearsTheStore() async {
        let p1 = Period(startDate: Date(), endDate: Date().addingTimeInterval(100))
        let p2 = Period(startDate: Date().addingTimeInterval(200), endDate: Date().addingTimeInterval(300))
        await sut.save(p1)
        await sut.save(p2)
        
        await sut.deleteAll()
        
        await expect(sut, toCompleteWith: [])
    }
    
    func test_deleteAll_onEmptyStore_leavesItEmpty() async {
        await sut.deleteAll()
        await expect(sut, toCompleteWith: [])
    }

    private func expect(_ sut: PeriodStore, toCompleteWith expectedResult: [Period]) async {
        let result = await sut.fetchAll()
        XCTAssertEqual(result, expectedResult)
    }
}
