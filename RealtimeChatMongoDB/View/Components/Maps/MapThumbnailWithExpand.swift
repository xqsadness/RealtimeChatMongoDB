//
//  MapThumbnailWithExpand.swift
//  RealtimeChatMongoDB
//
//  Created by darktech4 on 02/06/2023.
//

import SwiftUI
import MapKit

struct MapThumbnailWithExpand: View {
    let location: [Double]
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
    @State private var annotationItems = [MyAnnotationItem]()
    @State private var position = CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
    
    private enum Dimensions {
        static let frameSize: CGFloat = 100
        static let imageSize: CGFloat = 150
        static let buttonSize: CGFloat = 30
        static let radius: CGFloat = 8
        static let buttonPadding: CGFloat = 4
    }
    
    var body: some View {
        VStack {
            NavigationLink {
                MapView(location: position, annotationItems: annotationItems)
            } label: {
                Map(coordinateRegion: $region, annotationItems: annotationItems) { item in
                    MapMarker(coordinate: item.coordinate)
                }
                .frame(height: Dimensions.imageSize, alignment: .center)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: Dimensions.radius))
            }
        }
        .onAppear(perform: setupLocation)
    }
    
    func setupLocation() {
        position = CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
        region = MKCoordinateRegion(
            center: position,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        annotationItems.append(MyAnnotationItem(coordinate: position))
    }
}

