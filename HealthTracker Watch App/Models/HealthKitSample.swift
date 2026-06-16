import Foundation
import Combine
import HealthKit

func createHealthKitSampleFromQuantityTypes(
    type: HKQuantityType,
    unit: HKUnit,
    value: Double,
    timestamp: Date
) -> HKQuantitySample {
    let quantity = HKQuantity(unit: unit, doubleValue: value)

    return HKQuantitySample(
        type: type,
        quantity: quantity,
        start: timestamp,
        end: timestamp
    )
}
