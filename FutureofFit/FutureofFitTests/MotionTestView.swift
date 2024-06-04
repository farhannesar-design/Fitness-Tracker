//
//  MotionTestView.swift
//  FutureofFit
//
//  Created by Liston Mehserle on 3/29/24.
//

import SwiftUI

struct MotionTestView: View {
    @State private var accelerometerDataProcessor = AccelerometerDataProcessor()
    @State private var isReadingData = false
//    @State private var gravity: (x: Double, y: Double, z: Double)
    @State private var scalarAcceleration: Double = 0.0
    @State private var gravStr: String = ""
    @State private var accStr2: String = ""

    private var userWeight: Int = 125 //test value, UI needs to take in int for user's weight

    var body: some View {
        VStack {
            Text(gravStr)
                .padding()
                .onAppear {
                }
            Text(accStr2)
                .padding()
                .onAppear {
                }
            Text("Scalar Acceleration: \(scalarAcceleration, specifier: "%.2f")")
                .padding()
                .onAppear {
                    // This ensures the accelerometer does not start automatically.
                    // You could initiate any required setup here if needed.
                }
            
            Button(action: toggleAccelerometer) {
                Text(isReadingData ? "Stop Reading Data" : "Start Reading Data")
            }
            .padding()
            .background(isReadingData ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
  func toggleAccelerometer() {
    if isReadingData {
        accelerometerDataProcessor.stopAccelerometer(mass: userWeight)
        isReadingData = false
    } else {
        accelerometerDataProcessor.startDeviceMotionUpdates()
        isReadingData = true
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            // Attempt to fetch the latest scalar acceleration value
            let grav = accelerometerDataProcessor.gravityStr
            let acc = accelerometerDataProcessor.accStr
            let acceleration = accelerometerDataProcessor.lastZ
            self.gravStr = grav
            self.accStr2 = acc
            self.scalarAcceleration = acceleration

            // If the value is nil, simply do nothing and wait for the next update
        }
            // No need to invalidate the timer or set isReadingData to false here
            // If the value is nil, simply do nothing and wait for the next update
    }
   }

}


#Preview {
    MotionTestView()
}
