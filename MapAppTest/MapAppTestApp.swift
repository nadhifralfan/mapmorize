//
//  MapAppTestApp.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 16/05/24.
//

import SwiftUI
import SwiftData
import MapKit

@main
struct MapAppTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MemoryLocation.self)
    }
}
