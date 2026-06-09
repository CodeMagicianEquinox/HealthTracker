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
        static let userGoals = "user_goals"
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
        self.saveEntries(allTimeEntries)
    }

    func getTodayEntries() -> [DiaryEntry] {
        let entries = loadEntries()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }

    func getTodayTotal(for type: EntryType) -> Double {
        self.getTodayEntries()
            .filter { $0.type == type }
            .reduce(0) { $0 + $1.value }
    }

    // MARK: - Settings Business Logic
    func saveNewGoals(_ goals: UserGoals) {
        if let encodedGoals = try? encoder.encode(goals) {
            storage.set(encodedGoals, forKey: Keys.userGoals)
        }
    }

    func loadCurrentGoals() -> UserGoals {
        guard let rawGoals = storage.data(forKey: Keys.userGoals),
              let userGoals = try? decoder.decode(UserGoals.self, from: rawGoals) else {
            return UserGoals.defaultGoals
        }
        return userGoals
    }
}
