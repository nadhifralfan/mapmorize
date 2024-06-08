//
//  GeoLocation.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 17/05/24.
//

import Foundation
import MapKit

struct GeoLocation {
    let name: String
    let streetName: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    init(with placemark: CLPlacemark) {
            self.name           = placemark.name ?? ""
            self.streetName     = placemark.thoroughfare ?? ""
            self.city           = placemark.locality ?? ""
            self.state          = placemark.administrativeArea ?? ""
            self.zipCode        = placemark.postalCode ?? ""
            self.country        = placemark.country ?? ""
        }

}
