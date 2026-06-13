import Foundation
import Combine
import HealthKit

class HealthStoreDataManager {
    static let shared = HealthStoreDataManager()
    private init() {}

    // This is the main interface to interact with health store / HealthKit
    let healthStore = HKHealthStore()

    // MARK: - HealthKit Types
    // Create the Health Data Types to work with
    private let caloriesType = HKQuantityType.quantityType(
        forIdentifier: .dietaryEnergyConsumed
    )!
    private let waterType = HKQuantityType.quantityType(
        forIdentifier: .dietaryWater
    )!
    private let heartRateType = HKQuantityType.quantityType(
        forIdentifier: .heartRate
    )!
    private let characteristicType =
    HKCharacteristicType.characteristicType(forIdentifier: .bloodType)!

    // MARK: - Units
    private let heartRateUnits = HKUnit(from: "count/min")
    private let caloriesUnit = HKUnit.kilocalorie()
    private let waterUnit = HKUnit.literUnit(with: .milli)

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        let typesToRead: Set<HKObjectType> = [
            caloriesType,
            waterType,
            heartRateType,
            characteristicType
        ]

        let typesToWrite: Set<HKSampleType> = [caloriesType, waterType]

        try await healthStore.requestAuthorization(
            toShare: typesToWrite,
            read: typesToRead
        )
    }

    func checkCriticalAuthorizationStatus() -> Bool {
        let caloriesAuthStatus = healthStore.authorizationStatus(for: caloriesType)
        let waterAuthStatus = healthStore.authorizationStatus(for: waterType)

        return (
            caloriesAuthStatus == HKAuthorizationStatus.sharingAuthorized &&
            waterAuthStatus == HKAuthorizationStatus.sharingAuthorized
        )
    }

    func checkSecondaryAuthorizationStatus() -> Bool {
        healthStore.authorizationStatus(for: heartRateType) ==
        HKAuthorizationStatus.sharingAuthorized
    }

    // This function queries and returns one single element
    // The query here is a one time operation
    // To get this data point again you must call the func again on a high frequency basis
    func fetchLatestHeartRate() async throws -> HeartRateSample? {
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false // We get data in descending order. Newest to oldest
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil, // This is a TIME predicate (Time Windows, from Date A -> Date B)
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in // Samples = Health Data
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                // Even with 1 element in the limit property
                // queries will always return an ARRAY, so we would get an array
                // with only one element

                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }

                // Sample right now is a HKQuantitySample which is a good complex
                // Contentful structure, so our app doesnt need a struct in that complex
                //
                let bpm = sample.quantity.doubleValue(for: self.heartRateUnits)
                let heartRateSample = HeartRateSample(
                    bpm: bpm, timestamp: sample.startDate
                )

                continuation.resume(returning: heartRateSample)
            }

            healthStore.execute(query)
        }
    }

    // This function get heart rarte in real time via updates
    func startHeartRateMonitor(onUpdateHandler: @escaping ([HeartRateSample]) -> Void) {

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil, // nil ensures communications stays open
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
        }

        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self else { return }
        }

        healthStore.execute(query)
    }
}
