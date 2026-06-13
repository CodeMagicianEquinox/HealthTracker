import Combine
import CoreMotion
import Foundation

final class MotionViewModel: ObservableObject {
    @Published var accelerationX = 0.0
    @Published var accelerationY = 0.0
    @Published var accelerationZ = 0.0

    @Published var rotationRateX = 0.0
    @Published var rotationRateY = 0.0
    @Published var rotationRateZ = 0.0

    @Published var isTracking = false
    @Published var errorMessage: String?

    private let motionManager = CMMotionManager()

    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            errorMessage = "Motion data is unavailable on this device."
            return
        }

        errorMessage = nil
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self else { return }

            if let error {
                self.errorMessage = error.localizedDescription
                self.stopTracking()
                return
            }

            guard let motion else { return }

            self.accelerationX = motion.userAcceleration.x
            self.accelerationY = motion.userAcceleration.y
            self.accelerationZ = motion.userAcceleration.z

            self.rotationRateX = motion.rotationRate.x
            self.rotationRateY = motion.rotationRate.y
            self.rotationRateZ = motion.rotationRate.z
        }
        isTracking = true
    }

    func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
