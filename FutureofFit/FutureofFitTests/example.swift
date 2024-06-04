import CoreMotion

class AccelerometerDataProcessor {
    private var motionManager: CMMotionManager
    private var pedometer: CMPedometer
    private var accelData: [(timestamp: TimeInterval, z: Double)] = []
    private var runData: [(timestamp: TimeInterval, z: Double)] = []
    private var runningPeriods: [(start: TimeInterval, end: TimeInterval)] = []

    // Existing properties and init method...

    init() {
        self.motionManager = CMMotionManager()
        self.pedometer = CMPedometer()
    }

    // Existing methods...

    func startUpdates() {
        startPedometerUpdates()
        startDeviceMotionUpdates()
    }
    
    func startPedometerUpdates() {
        if CMPedometer.isPaceAvailable() {
            let runningPaceThreshold = 0.45 ///anything faster than 12 min/mile is running
            pedometer.startUpdates(from: Date()) { [weak self] (pedometerData, error) in
                guard let data = pedometerData, error == nil else {
                    return
                }
                
                // If current pace exists and indicates running, log the period
                if let currentPace = data.currentPace, currentPace.doubleValue < runningPaceThreshold {
                    // Assuming a pace threshold that defines running, you'll need to determine what this value is based on your needs
                    let timestamp = Date().timeIntervalSinceReferenceDate
                    self?.runningPeriods.append((start: timestamp, end: timestamp)) // Modify this as needed to accurately capture start and end times
                }
            }
        }
    }
    
    func trimAccelDataForRunning() {
        runData = accelData.filter { dataPoint in
            // Check if the timestamp falls within any of the running periods
            for period in runningPeriods {
                if dataPoint.timestamp >= period.start && dataPoint.timestamp <= period.end {
                    return true
                }
            }
            return false
        }
    }
}
