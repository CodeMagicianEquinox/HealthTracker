extension HealthViewModel {
    func addEntry(
        _ entry: DiaryEntry,
        useHealthKit: Bool,
        onSuccess: @escaping () -> Void
    ) {
        if useHealthKit {
            addToHealthKit(entry, onSuccess)
        } else {
            addToLocalStorage(entry, onSuccess)
        }
    }
    
    
    private func addToHealthKit(_ entry: DiaryEntry, _ onSuccess: @escaping () -> Void) {
        Task {
            do {
                try await HealthStoreDataManager.shared.addEntry(entry)
                await refreshDailyTotalsFromHealthKit()
                onSuccess()
            } catch {
                await MainActor.run {
                    addToLocalStorage(entry, onSuccess)
                }
                
            }
        }
    }
    
    private func addToLocalStorage(_ entry: DiaryEntry, _ onSuccess: @escaping () -> Void) {
        StorageManager.shared.addEntry(entry)
        refreshDailyTotals()
        onSuccess()
    }
    
}
