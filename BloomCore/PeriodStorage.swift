protocol PeriodStorage {
    func savePeriod(_ entry: PeriodEntry) throws
    func updatePeriod(_ entry: PeriodEntry) throws
    func deletePeriod(id: UUID) throws
    func fetchAllPeriods() throws -> [PeriodEntry]
    func fetchPeriods(in range: DateInterval) throws -> [PeriodEntry]
    func fetchLatestPeriod() throws -> PeriodEntry?
    func clearAll() throws
}