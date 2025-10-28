import CoreLocation
import Combine
import SwiftUI
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // Request authorization
        manager.requestWhenInUseAuthorization()
        // Start updating location
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = loc.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
}

struct LocationPickerView: View {
    // A closure to pass back the chosen coordinate
    var onCoordinateSelected: (CLLocationCoordinate2D) -> Void
    
    // Location manager to get user location
    @StateObject private var locationManager = LocationManager()
    
    // Default region (some fallback)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 29.742745, longitude: -95.428103),
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002) // smaller delta = more zoom
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region)
                .ignoresSafeArea()
                // Update region center once we have userLocation
                .onReceive(locationManager.$userLocation) { loc in
                    if let loc = loc {
                        region.center = loc
                    }
                }
            
            // A custom pin image at the center
            Image(systemName: "mappin.and.ellipse")
                .font(.title)
                .foregroundColor(.red)
                .offset(y: -20) // adjust so the point is the actual center
            
            // "Done" button at top-right
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Use region.center as the chosen location
                        onCoordinateSelected(region.center)
                    }) {
                        Text("Done")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}
