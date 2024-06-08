//
//  LocationSearchView.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 20/05/24.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    @State private var position = MapCameraPosition.automatic
    @State private var searchResults = [SearchResult]()
    @State private var selectedLocation: SearchResult?
    @State private var isSheetPresented: Bool = true
    @State private var scene: MKLookAroundScene?

    var body: some View {
        VStack {
            Map(position: $position, selection: $selectedLocation) {
                ForEach(searchResults) { result in
                    Marker(coordinate: result.location) {
                        Image(systemName: "mappin")
                    }
                    .tag(result)
                }
            }
            .overlay(alignment: .bottom) {
                if selectedLocation != nil {
                    Button("Select") {
                        isSheetPresented = false
                    }
                }
            }
            .ignoresSafeArea()
            .onChange(of: selectedLocation) {
                if let selectedLocation {
                    Task {
                        scene = try? await fetchScene(for: selectedLocation.location)
                    }
                }
                isSheetPresented = selectedLocation == nil
            }
            .onChange(of: searchResults) {
                if let firstResult = searchResults.first, searchResults.count == 1 {
                    selectedLocation = firstResult
                }
            }
        }
    }

    private func fetchScene(for coordinate: CLLocationCoordinate2D) async throws -> MKLookAroundScene? {
        let lookAroundScene = MKLookAroundSceneRequest(coordinate: coordinate)
        return try await lookAroundScene.scene
    }
}

#Preview {
    LocationSearchView()
}
