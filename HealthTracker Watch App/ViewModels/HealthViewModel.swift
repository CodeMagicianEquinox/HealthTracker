import Foundation
import Combine
import WatchKit

class HealthViewModel: ObservableObject {
    // MARK: - Published Variables
    @Published var todaysWater: Double = 0
    @Published var todaysCalories: Double = 0
    @Published var goals: UserGoals

    // MARK: - Computed Properties
    var caloriesProgress: Double {
        min(todaysCalories / goals.dailyCaloriesGoal, 1)
    }

    var waterProgress: Double {
        min(todaysWater / goals.dailyWaterGoal, 1)
    }

    // MARK: - Services/Managers --> Access the class by putting "<ClassName>.shared"
    private let storageManager = StorageManager.shared

    init() {
        goals = storageManager.loadCurrentGoals()
        refreshDailyTotals()
    }

    func updateGoals(calories: Double, water: Double) {
        goals = UserGoals(
            dailyCaloriesGoal: calories,
            dailyWaterGoal: water
        )
        storageManager.saveNewGoals(goals)
        WKInterfaceDevice.current().play(.success)
    }

    func refreshDailyTotals() {
        todaysCalories = storageManager.getTodayTotal(for: .calories)
        todaysWater = storageManager.getTodayTotal(for: .water)
    }

    func addCalories(_ amount: Double) {
        storageManager.addEntry(DiaryEntry(type: .calories, value: amount))
    }

    func addWater(_ amount: Double) {
        storageManager.addEntry(DiaryEntry(type: .water, value: amount))
    }
}

