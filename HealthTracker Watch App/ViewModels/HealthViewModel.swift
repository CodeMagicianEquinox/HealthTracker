import Foundation
import Combine
import WatchKit

enum HealthAuthorizationState {
    case unknown
    case unavailable
    case authorized
    case denied
}

class HealthViewModel: ObservableObject {
    // MARK: - Published Variables
    @Published var todaysWater: Double = 0
    @Published var todaysCalories: Double = 0
    @Published var goals: UserGoals
    @Published var authorizationState: HealthAuthorizationState = .unknown
    @Published var healthErrorMessage: String?
    @Published var isRefreshingTotals: Bool = false
    @Published var currentHeartRate: HeartRateSample?

    @Published var currentQuote: MotivationalQuote?
    @Published var isLoadingQuote: Bool = false
    @Published var showQuoteOverlay: Bool = false

    // MARK: - Computed Properties
    var caloriesProgress: Double {
        min(todaysCalories / goals.dailyCaloriesGoal, 1)
    }

    var waterProgress: Double {
        min(todaysWater / goals.dailyWaterGoal, 1)
    }

    // MARK: - Services/Managers --> Access the class by putting "<ClassName>.shared"
    private let storageManager = StorageManager.shared
    private let healthStoreDataManager = HealthStoreDataManager.shared
    private let motivationalQuoteService = MotivationalQuoteService.shared

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

    func prepareHealthKit() async {
        guard healthStoreDataManager.isHealthKitAvailable else {
            authorizationState = .unavailable
            healthErrorMessage = "Health data is unavailable on this device."
            refreshDailyTotals()
            return
        }

        do {
            try await healthStoreDataManager.requestAuthorization()
            authorizationState = healthStoreDataManager.checkCriticalAuthorizationStatus()
                ? .authorized
                : .denied
            await refreshDailyTotalsFromHealthKit()
            startHeartRateMonitoring()
        } catch {
            authorizationState = .denied
            healthErrorMessage = error.localizedDescription
            refreshDailyTotals()
        }
    }

    func refreshDailyTotalsFromHealthKit() async {
        guard authorizationState == .authorized else {
            refreshDailyTotals()
            return
        }

        isRefreshingTotals = true
        defer { isRefreshingTotals = false }

        do {
            todaysCalories = try await healthStoreDataManager.getTodaysTotal(for: .calories)
            todaysWater = try await healthStoreDataManager.getTodaysTotal(for: .water)
            healthErrorMessage = nil
        } catch {
            healthErrorMessage = error.localizedDescription
            refreshDailyTotals()
        }
    }

    func addCalories(_ amount: Double) async {
        await addEntry(type: .calories, amount: amount)
    }

    func addWater(_ amount: Double) async {
        await addEntry(type: .water, amount: amount)
    }

    private func addEntry(type: EntryType, amount: Double) async {
        let entry = DiaryEntry(type: type, value: amount)
        fetchQuoteAfterEntry()

        storageManager.addEntry(entry)

        guard authorizationState == .authorized else {
            refreshDailyTotals()
            return
        }

        do {
            try await healthStoreDataManager.addEntry(entry)
            await refreshDailyTotalsFromHealthKit()
            healthErrorMessage = nil
        } catch {
            healthErrorMessage = error.localizedDescription
            refreshDailyTotals()
        }
    }

    func startHeartRateMonitoring() {
        healthStoreDataManager.startHeartRateMonitor { [weak self] samples in
            self?.currentHeartRate = samples.last
        }
    }

    // MARK: - Motivational Quotes
    func fetchQuoteAfterEntry() {
        isLoadingQuote = true
        showQuoteOverlay = true

        Task {
            currentQuote = await motivationalQuoteService.fetchQuote()
            isLoadingQuote = false

            try? await Task.sleep(nanoseconds: 5_000_000_000)
            showQuoteOverlay = false
        }
    }
}
