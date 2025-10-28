//
//  CampusMapOverlay.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/21/25.
//

import MapKit

/// 1) A simple MKOverlay that covers a rectangular boundingMapRect.
class CampusMapOverlay: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect
    let overlayImage: UIImage
    
    init(center: CLLocationCoordinate2D, radiusMeters: CLLocationDistance, image: UIImage) {
        self.coordinate = center
        self.overlayImage = image
        
        // Create a bounding map rect around the center,
        // converting radius in meters to MKMapPoints for width/height.
        let centerMapPoint = MKMapPoint(center)
        let pointsPerMeter = MKMapPointsPerMeterAtLatitude(center.latitude)
        let mapRectSize = radiusMeters * pointsPerMeter * 2 // diameter
        let origin = MKMapPoint(x: centerMapPoint.x - mapRectSize/2,
                                y: centerMapPoint.y - mapRectSize/2)
        
        self.boundingMapRect = MKMapRect(origin: origin, size: MKMapSize(width: mapRectSize, height: mapRectSize))
        
        super.init()
    }
}

/// 2) An MKOverlayRenderer that draws overlayImage to fill boundingMapRect
class CampusOverlayRenderer: MKOverlayRenderer {
    let overlayImage: UIImage
    
    init(overlay: MKOverlay, overlayImage: UIImage) {
        self.overlayImage = overlayImage
        super.init(overlay: overlay)
    }
    
    override func draw(_ mapRect: MKMapRect,
                       zoomScale: MKZoomScale,
                       in context: CGContext) {
        guard let overlay = self.overlay as? CampusMapOverlay else { return }
        
        let overlayRect = rect(for: overlay.boundingMapRect)
        
        // Draw the image to fit the bounding rect
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -overlayRect.size.height)
        context.draw(overlayImage.cgImage!,
                     in: CGRect(origin: overlayRect.origin,
                                size: overlayRect.size))
    }
}
