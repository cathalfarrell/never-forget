//
//  Contact.swift
//  NetterForget
//
//  Created by Cathal Farrell on 16/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

struct Contact: Identifiable, Codable, Comparable, Hashable {

    var name = ""
    var id = "\(UUID())"
    var image = UIImage(named: "placeholderImage")
    var latitude = ""
    var longitude = ""

    var location: CLLocationCoordinate2D {
        guard !latitude.isEmpty, !longitude.isEmpty, let lat = Double(latitude), let long = Double(longitude) else {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(0.0), longitude: CLLocationDegrees(0.0))
        }

        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return location
    }

    var locationAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        print("✅ Return annotation: \(location)")
        return annotation
    }

    enum CodingKeys: String, CodingKey {
        case name, id, latitude, longitude
    }

    static func < (lhs: Contact, rhs: Contact) -> Bool {
        lhs.name < rhs.name
    }
}
extension Contact {
    static var sampleContact: Contact {
        return Contact(name: "Cathal Farrell")
    }
}
