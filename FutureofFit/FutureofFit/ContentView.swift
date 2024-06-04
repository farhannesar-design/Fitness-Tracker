import SwiftUI
import CoreLocation
import MapKit

enum Sensor: String {
    case inertialMeasurementUnit = "Inertial Measurement Unit"
    case ambientLightSensor = "Ambient Light Sensor"
    case accelerometerSensor = "Accelerometer Sensor"
    case finalResults = "Final Results" // New case for final results page
    case none = "None" // New case for representing no sensor selected
}

let backgroundGradient: some View = LinearGradient(
    colors: [Color.gray, Color.gray],
    startPoint: .top,
    endPoint: .bottom
)
.ignoresSafeArea()

struct SensorSelectionView: View {
    @Binding var selectedSensor: Sensor?
    @State private var accelerometerDataProcessor = AccelerometerDataProcessor()
    @State private var isReadingData = false
    @State private var scalarAcceleration: Double = 0.0
    @State private var weight: Int = 0
    @StateObject var videoStream = CameraStream()
    @StateObject var viewCounting = ViewCounting()
    @ObservedObject private var locationManager = LocationManager()
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject var sharedAccel: SharedAccel
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                VStack {
                    Text("The Future of Fit")
                        .font(.title)
                        .padding()
                    
                    Text("Select Sensor")
                        .font(.title)
                        .padding()
                    
                    
                    Button(action: {
                        self.selectedSensor = .ambientLightSensor
                    }) {
                        Text("Ambient Light Sensor")
                            .font(.custom("San Francisco", size: 30))
                    }
                    .padding()
                    
                    Button(action: {
                        self.selectedSensor = .finalResults // Navigate to final results page
                    }) {
                        Text("Final Results")
                        .font(.custom("San Francisco", size: 30))
                    }
                    .padding()
                    
                    Button(action: toggleAccelerometer) {
                        Text(isReadingData ? "Stop Reading Data" : "Start Reading Data")
                    }
                    .padding()
                    .background(isReadingData ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationBarHidden(true)
            }
            
        }
    }
    
    func toggleAccelerometer() {
        if isReadingData {
            accelerometerDataProcessor.sharedAccel = sharedAccel
            accelerometerDataProcessor.stopAccelerometer(mass: weight)

            isReadingData = false
        } else {
            accelerometerDataProcessor.startDeviceMotionUpdates()
            isReadingData = true
        }
    }
}

struct FinalResultsView: View {
    var body: some View {
        Text("Final Results Page")
            .font(.title)
            
    }
}

struct SensorDataView: View {
    @ObservedObject var locationManager: LocationManager
    @StateObject var videoStream = CameraStream()
    @StateObject var viewCounting = ViewCounting()
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject var sharedAccel: SharedAccel
    @Binding var selectedSensor: Sensor?
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                VStack {
                    Text("Sensor Data:")
                        .font(.title)
                        .font(.custom("San Francisco", size: 16))
                        .foregroundColor(.black)
                    Text("\(selectedSensor?.rawValue ?? "")")
                        .font(.title)
                        .font(.custom("San Francisco", size: 16))
                        .foregroundColor(.black)
                    
                    Text(sharedAccel.someString)
                    if let sensor = selectedSensor {
                        if sensor == .ambientLightSensor {
                            if (!videoStream.cameraAccess) {
                                Text("This app requires authorization to access your camera in order to work correctly. You may grant this access from your device settings menu.")
                                    .font(.title)
                                    .padding()
                                    .multilineTextAlignment(.center)
                            } else {
                                VStack {
                                    if (videoStream.session != nil) {
                                        VideoPreviewHolder(runningSession: videoStream.session)
                                            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
                                    } else {
                                        ProgressView()
                                    }
                                    Text(String(format: "%.0f  Lux", videoStream.luminosityReading))
                                        .font(.system(size: 18))
                                        .padding()
                                        .toolbar {
                                            ToolbarItem(id: "ReferenceButton", placement: .bottomBar) {
                                                NavigationLink(destination: ReferenceView()) {
                                                    Image(systemName: "info.circle")
                                                }
                                            }
                                        }
                                }.onAppear{
                                    print("View has been loaded \(viewCounting.viewCounter) times.")
                                    
                                    if viewCounting.viewCounter > 10 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                                            requestReview()
                                        })
                                    } else {
                                        viewCounting.viewCounter += 1
                                        UserDefaults.standard.set(viewCounting.viewCounter, forKey: "ViewCounter")
                                    }
                                }
                            }
                        }
                        else if sensor == .inertialMeasurementUnit {
                        }
                        else if sensor == .finalResults {
                            FinalResultsView()
                        }
                    }
                }
                .navigationBarItems(
                    leading: Button("Back") {
                        selectedSensor = nil
                    }
                    .foregroundColor(.white)
                    .font(.custom("San Francisco", size: 18))
                    .multilineTextAlignment(.center))
            }
        }
    }
}


struct ContentView: View {
    @State private var selectedSensor: Sensor? = nil
    @ObservedObject private var locationManager = LocationManager()
    @State private var isTracking = false
    @State private var showMap = false
    
    var body: some View {
        ZStack {
            backgroundGradient
            VStack {
                if selectedSensor == nil {
                    SensorSelectionView(selectedSensor: $selectedSensor)
                } else {
                    NavigationLink(destination: SensorSelectionView(selectedSensor: $selectedSensor)) {
                        EmptyView()
                    }
                    .hidden()
                    SensorDataView(locationManager: locationManager, selectedSensor: $selectedSensor)
                }
                if !isTracking {
                    Button(action: {
                        startTracking()
                    }) {
                        Text("Start Tracking")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                    Button(action: {
                        stopTracking()
                    }) {
                        Text("Stop Tracking")
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                if showMap {
                    MapView(locations: locationManager.locations)
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .padding()
        }
    }
    
    private func startTracking() {
        isTracking = true
        showMap = true
    }
    
    private func stopTracking() {
        isTracking = false
        showMap = false
    }
}

class ViewCounting: ObservableObject {
    public var viewCounter: Int = (UserDefaults.standard.object(forKey: "ViewCounter") as? Int) ?? 0
}
