//
//  LocationFetcher.swift
//  NetterForget
//
//  Created by Cathal Farrell on 18/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation
import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.first else {
            print("No location received")
            return
        }

        lastKnownLocation = location.coordinate
        print("✨ Location received: \(location.coordinate)")
    }

    func getLocation() -> CLLocationCoordinate2D {
        if let lastLocation = lastKnownLocation {
            return lastLocation
        } else {
            // Return default zero location
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(0.0),
                                          longitude: CLLocationDegrees(0.0))
        }
    }
}
