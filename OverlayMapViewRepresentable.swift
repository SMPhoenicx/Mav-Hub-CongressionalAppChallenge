//
//  OverlayMapViewRepresentable.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/21/25.
//

import SwiftUI
import MapKit

struct OverlayMapViewRepresentable: UIViewRepresentable {
    
    @Binding var region: MKCoordinateRegion
    let onCoordinateSelected: (CLLocationCoordinate2D) -> Void
    
    // A sample overlay config
    let overlayCenter: CLLocationCoordinate2D
    let overlayRadius: CLLocationDistance
    let overlayImage: UIImage
    
    private let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        // Set initial region
        mapView.region = region
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        // Add the custom overlay
        let campusOverlay = CampusMapOverlay(
            center: overlayCenter,
            radiusMeters: overlayRadius,
            image: overlayImage
        )
        mapView.addOverlay(campusOverlay)
        
        // If you want the user's actual location:
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Keep the map region in sync if it changed
        uiView.setRegion(region, animated: false)
    }
    
    // Coordinator for overlay renderer, coordinate selection if needed
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: OverlayMapViewRepresentable
        
        init(_ parent: OverlayMapViewRepresentable) {
            self.parent = parent
        }
        
        // Return a renderer for our campus overlay
        func mapView(_ mapView: MKMapView,
                     rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let campusOverlay = overlay as? CampusMapOverlay {
                return CampusOverlayRenderer(
                    overlay: campusOverlay,
                    overlayImage: campusOverlay.overlayImage
                )
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
