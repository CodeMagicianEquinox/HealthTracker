import Foundation
import Combine

class HealthViewModel: ObservableObject {
    // MARK: - Published Variables
    @Published var todaysWater: Double = 0
    @Published var todaysCalories: Double = 0

    // MARK: - Services/Managers --> Access the class by putting "<ClassName>.shared"
    private let storageManager = StorageManager.shared
    
    init() {
        self.refreshDailyTotals()
    }
    
    func refreshDailyTotals() {
        todaysCalories = storageManager.getTodayTotal(for: .calories)
        todaysWater = storageManager.getTodayTotal(for: .water)
    }
    
    func addCalories(_ amount: Double) {}
    func addWater(_ amount: Double) {}
}


