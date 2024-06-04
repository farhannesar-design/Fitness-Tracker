//
//  ScalarAccel.swift
//  FutureofFit
//
//  Created by Liston Mehserle March 2024
//
import Foundation
import CoreMotion
import Combine

class SharedAccel: ObservableObject {
    @Published var someString: String = ""
}


class AccelerometerDataProcessor {
    
    var sharedAccel: SharedAccel?

    private var motionManager: CMMotionManager
    private var accelData: [(timestamp: TimeInterval, vertAccel: Double)] = []
    private var peaks = [Double]()
    private var vGRFs = [Double]()

    private var alpha = 0.71537
    internal var lastX = 0.0, lastY = 0.0, lastZ = 0.0

    
    init() {
        self.motionManager = CMMotionManager()
    }
    

    /// Starts deviceMotion, which is accelerometer data with gravity removed
    func startDeviceMotionUpdates() {
        /// Check if device motion is availabl
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02 /// 50 Hz per 2x observed motion
            /// Start receiving device motion updates
            motionManager.startDeviceMotionUpdates(to: .main) { (deviceMotion, error) in
                guard let deviceMotion = deviceMotion, error == nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                /// Extract the gravity and user acceleration components
                let gravity = deviceMotion.gravity
                let userAcceleration = deviceMotion.userAcceleration
                /// Calculate the vertical acceleration
                let verticalAcceleration = self.calculateVerticalAcceleration(gravity: gravity, userAcceleration: userAcceleration)
                /// update accelData array with updateAccelerometerData()
                let timestamp = deviceMotion.timestamp
                self.updateAccelerometerData(timestamp: timestamp, z: verticalAcceleration)
            }
        }
    }
    
    private func calculateVerticalAcceleration(gravity: CMAcceleration, userAcceleration: CMAcceleration) -> Double {
        /// normalize Gravity vector
        let gravityVector = normalize(vector: gravity)
        let userAccelerationVector = vector(x: userAcceleration.x, y: userAcceleration.y, z: userAcceleration.z)
        /// Project userAcceleration on gravity vector for vertical component
        let verticalAcceleration = dotProduct(vector1: userAccelerationVector, vector2: gravityVector)

        return verticalAcceleration
    }
    
    private func updateAccelerometerData(timestamp: TimeInterval, z: Double) {
        /// Update accelData array with low pass filtered values
        lastZ = (z * alpha) + (lastZ * (1.0 - alpha))
        accelData.append((timestamp, lastZ))
    }
    
    /// Stops accelerometer updates.
    func stopAccelerometer(mass: Int) -> String {
        if motionManager.isDeviceMotionAvailable { // Checks for accelerometer
            motionManager.stopDeviceMotionUpdates()
        }
        
        peaks = findMax(data: accelData)
        
        for peak in peaks {
            vGRFs.append(calculateVGRF(accVert: peak, mass: mass))
        }
        
        sharedAccel?.someString = createRec(peaks: vGRFs)
        return createRec(peaks: vGRFs)
    }
    
    private func createRec(peaks: [Double]) -> String {
        
        var steps: Double = Double(peaks.count)
        let sum = peaks.reduce(0.0, +) // Sum all elements in the array
        let avgPeak = sum / steps // Divide by the count of elements
                        
        let calcHigh = 7000 / log(steps-3700) + 300
        let calcLow = 9000 / log(steps-2850) - 400
        
        let highRisk: String = "Accelerometer data indicates high potential for injury. This is a component of Ground Reaction Force and step count. Reduce training load."
        let lowRisk: String = "Accelerometer data indicates moderate potential for injury. This is a component of Ground Reaction Force and step count. Be mindful of training load."
        let noRisk: String = "Accelerometer data does not indicate increased potential for injury."
        
        if steps > 3700 {
            if calcHigh < avgPeak {
                return highRisk
            } else if calcLow < avgPeak {
                return lowRisk
            }
        } else if steps > 2850 {
            if calcLow < avgPeak {
                return lowRisk
            }
        }
        return noRisk
    }
    
    
    private func calculateVGRF(accVert: Double, mass: Int) -> Double {
        /// Coefficients from research paper
        let a0 = 5.247
        let a1 = 0.271
        let a2 = 0.014
        let a3 = 0.934
        let a4 = -0.261
        let typeOfLocomotion = 1 ///vGRF calculated for running only
        
        let a1func = (a1 * accVert)
        let a2func = (a2 * Double(mass))
        let a3func = (a3 * Double(typeOfLocomotion))
        let a4func = (a4 * accVert * Double(typeOfLocomotion))

        let predicted_Z = a0 + a1func + a2func + a3func + a4func
        let vGFR = exp(predicted_Z)
        
        return vGRF
    }

    func findMax(data: [(timestamp: TimeInterval, vertAccel: Double)]) -> [Double] {
        var maxValues = [Double]()
        var previousAccel =  0.0
        var currentAccel = 0.0
        var currentMax = 0.0
        maxValues.append(0.0)


        for (_, point) in data.enumerated() {
            currentAccel = point.vertAccel
            if (currentAccel * previousAccel < 0) && (currentAccel > 0) {
                maxValues.append(0.0)
    //            maxValues.append(currentMax)
                currentMax = 0.0
            }
            if currentAccel > 0 && currentAccel > currentMax {
                maxValues[maxValues.index(before: maxValues.endIndex)] = currentAccel
                currentMax = currentAccel
            }
            previousAccel = currentAccel
        }
        return maxValues
    }
    
    private func vector(x: Double, y: Double, z: Double) -> (x: Double, y: Double, z: Double) {
        return (x: x, y: y, z: z)
    }

    private func normalize(vector: CMAcceleration) -> (x: Double, y: Double, z: Double) {
        let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        return (vector.x / length, vector.y / length, vector.z / length)
    }

    private func dotProduct(vector1: (x: Double, y: Double, z: Double), vector2: (x: Double, y: Double, z: Double)) -> Double {
        return vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z
    }
    
}

