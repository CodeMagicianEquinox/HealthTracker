import Foundation
import Combine

struct UserGoals: Codable {
    var dailyCaloriesGoal: Double
    var dailyWaterGoal: Double
    
    static let defaultGoals = UserGoals(
        dailyCaloriesGoal: 2000,
        dailyWaterGoal: 2000)
}
