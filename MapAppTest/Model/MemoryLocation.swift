//
//  MemoryLocation.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 17/05/24.
//

import Foundation
import MapKit
import MusicKit
import SwiftData

@Model
class MemoryLocation: Identifiable, ObservableObject, Hashable {
    let name: String
    let longitude: Double
    let latitude: Double
    var isPlayingMusic: Bool = false
    let date: Date
    @Attribute(.externalStorage)
    var image: [Data?]
    let desc: String
    let maxRadius: Int
    let musicItemID: String
    let id: String
    
    init(name: String, latitude: Double,longitude: Double, date: Date, image: [Data], desc: String, maxRadius: Int, musicItemID: String, id: String) {
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
        self.date = date
        self.image = image
        self.desc = desc
        self.maxRadius = maxRadius
        self.musicItemID = musicItemID
        self.id = id

        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.notificationLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: CLLocationDistance(maxRadius), memoryName: name)
    }

    
    func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

    static func == (lhs: MemoryLocation, rhs: MemoryLocation) -> Bool {
        lhs.id == rhs.id
    }
    
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func location() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
