import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var locations: [CLLocation]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.mapType = .satellite // Set map type to satellite
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        
        if !locations.isEmpty {
            var coordinates: [CLLocationCoordinate2D] = locations.map { $0.coordinate }
            let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
            uiView.addOverlay(polyline)
            
            let bounds = polyline.boundingMapRect
            uiView.setVisibleMapRect(bounds, animated: true)
        }
    }
}
