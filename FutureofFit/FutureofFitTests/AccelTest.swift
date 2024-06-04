import SwiftUI
import ScalarAccel

struct ContentView: View {
    @State private var accelerometerDataProcessor = AccelerometerDataProcessor()
    @State private var isReadingData = false
    @State private var scalarAcceleration: Double = 0.0

    var body: some View {
        VStack {
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
        accelerometerDataProcessor.stopAccelerometer()
        isReadingData = false
    } else {
        accelerometerDataProcessor.startAccelerometer()
        isReadingData = true
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            // Attempt to fetch the latest scalar acceleration value
            if let acceleration = accelerometerDataProcessor.getScalarAcceleration() {
                self.scalarAcceleration = acceleration
            }
            // No need to invalidate the timer or set isReadingData to false here
            // If the value is nil, simply do nothing and wait for the next update
        }
    }
   }

}
