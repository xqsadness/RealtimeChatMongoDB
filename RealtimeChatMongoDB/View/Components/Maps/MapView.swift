//
//  MapView.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 02/06/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    let location: CLLocationCoordinate2D
    let annotationItems: [MyAnnotationItem]
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: MapDefaults.latitude, longitude: MapDefaults.longitude),
        span: MKCoordinateSpan(latitudeDelta: MapDefaults.zoomedOut, longitudeDelta: MapDefaults.zoomedOut))
    
    private enum MapDefaults {
        static let latitude = 51.507222
        static let longitude = -0.1275
        static let zoomedOut = 2.0
        static let zoomedIn = 0.01
    }
    
    var body: some View {
        Map(coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            annotationItems: annotationItems) { item in
            MapMarker(coordinate: item.coordinate)
        }
        .onAppear(perform: setupLocation)
    }
    
    func setupLocation() {
        region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: MapDefaults.zoomedIn, longitudeDelta: MapDefaults.zoomedIn))
    }
}
