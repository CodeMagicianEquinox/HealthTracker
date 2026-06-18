import Foundation
import Combine
import CoreMotion

class MotionManager: ObservableObject {
    
    static let shared = MotionManager()
    
    @Published var accelerationData: (x:Double, y:Double, z:Double) = (0,0,0)
    @Published var gyroscopeData: (x:Double, y:Double, z:Double) = (0,0,0)
    
    @Published var shakeDetected: Bool = false
    @Published var currentActivity: ActivityType = .unknown
    @Published var errorMessage: String?
    
    private let motionManager = CMMotionManager()
    private let activityManager = CMMotionActivityManager()
    
    private let updateInterval: TimeInterval = 0.1 // 10hz
    
    private let shakeThreshold: Double = 2.5
    
    
    // Debounce Variance (time based debounce)
    private var lastShakeTime: Date = .distantPast // 1/1/1999T00:00:00:00
    private var shakeDebounce: TimeInterval = 1.0 // To prevent multiple shake triggers
    
    
    // Check if all sensors need for this app are available
    var isNecessarySensoringAvailable: Bool {
        motionManager.isAccelerometerAvailable &&
        motionManager.isGyroAvailable &&
        CMMotionActivityManager.isActivityAvailable()
    }
    
    private init() {
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.gyroUpdateInterval = updateInterval
    }
    
    private func detectShake(from acceleration: CMAcceleration) {
        let magnitude = sqrt(
            pow(acceleration.x, 2) +
            pow(acceleration.y, 2) +
            pow(acceleration.z, 2)
        )
        
        let now = Date()
        guard magnitude > shakeThreshold,
              now.timeIntervalSince(lastShakeTime) > shakeDebounce else {
            return
        }
        
        lastShakeTime = now
        shakeDetected = true
    }
    
    private func startAccelerometer() {
        guard isNecessarySensoringAvailable else {
            errorMessage = "Accelerometer not Available"
            return
        }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            
            self.accelerationData = (
                x: data.acceleration.x,
                y: data.acceleration.y,
                z: data.acceleration.z
            )
            
            self.detectShake(from: data.acceleration)
        }
    }
    
    private func startActivityUpdates() {
        guard isNecessarySensoringAvailable else { return }
        
        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            self.currentActivity = ActivityType.from(activity: activity)
        }
    }
        
}
    

enum ActivityType: String {
    case stationary = "Staionary"
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case automotive = "Automotive"
    case unknown = "Unknown"
    
    
    static func from(activity: CMMotionActivity) -> ActivityType {
        if activity.running {
            return .running
        } else if activity.cycling {
            return .cycling
        } else if activity.walking {
            return .walking
        } else if activity.stationary {
            return .stationary
        } else if activity.automotive {
            return .automotive
        } else {
            return .unknown
        }
    }
    
}
