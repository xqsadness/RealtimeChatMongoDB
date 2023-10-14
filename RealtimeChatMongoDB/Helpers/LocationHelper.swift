//
//  LocationHelper.swift
//  RChat
//
//  Created by Andrew Morgan on 24/11/2020.
//

import CoreLocation

struct MyAnnotationItem: Identifiable {
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}


class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let shared = LocationHelper()
    static let DefaultLocation = CLLocationCoordinate2D(latitude: 51.506520923981554, longitude: -0.10689139236939127)
    
    @Published var currentLocation: CLLocationCoordinate2D = DefaultLocation
    
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
}

