import Combine
import Foundation

//Singleton Pattern
class StorageManager {
    static let shared = StorageManager()
    private init() {}
    
    private let storage = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private enum Keys {
        static let diaryEntries = "diary_Entries"
    }
    
    // MARK: - Entries Business Logic
    func saveEntries(_ entries: [DiaryEntry]) {
        if let encoded  = try? encoder.encode(entries) {
            storage.set(encoded, forKey: Keys.diaryEntries)
        }
    }
    
    
    func loadEntries() -> [DiaryEntry] {
        guard let rawJsonData = storage.data(forKey: Keys.diaryEntries),
              let diaryEntries = try? decoder.decode([DiaryEntry].self, from:
                rawJsonData) else {
            return []
        }
        return diaryEntries
    }
    
    func addEntry(_ entry: DiaryEntry) {
        var allTimeEntries = loadEntries()
        allTimeEntries.append(entry)
        saveEntries(allTimeEntries)
    }
    
    func getTodayEntries() -> [DiaryEntry] {
        let entries = loadEntries()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }
    
}
