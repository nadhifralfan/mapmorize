//
//  ContentView.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 16/05/24.
//

import SwiftUI
import MapKit
import MusicKit
import SwiftData

struct ContentView: View {
    @Query var memoryLocations: [MemoryLocation]
    
    @State private var musicPlayer = MusicManager()
    @State var placeName: String = ""
    @State private var positionMap: MapCameraPosition = MapCameraPosition.userLocation(fallback: .automatic)
    
    @State private var longitude: CLLocationDegrees = 0
    @State private var latitude: CLLocationDegrees = 0
    @State private var userLocation: CLLocation? = nil
    
    @State var searchLocationResult: [SearchResult] = []
    @State var isSearchingLocation: Bool = false
    
    @State private var isAddingMemoryLocation: Bool = false
    @State private var isShowingMemoryLocation: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Map(position: $positionMap) {
                    UserAnnotation()
                    ForEach(memoryLocations, id: \.id) { memoryLocation in
                        Annotation(
                            "", coordinate: CLLocationCoordinate2D(latitude: memoryLocation.latitude, longitude: memoryLocation.longitude),
                            content: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.blue)
                                    Text("🎓")
                                        .padding(5)
                                }
                            }
                        )
                        MapCircle(center: memoryLocation.coordinate(), radius: CLLocationDistance(memoryLocation.maxRadius))
                            .foregroundStyle(.teal.opacity(0.60))
                            .mapOverlayLevel(level: .aboveLabels)
                    }
                }
                .padding(.top, 15)
                .onMapCameraChange(frequency: .onEnd) { context in
                    let cameraCenter = context.camera.centerCoordinate
                    longitude = cameraCenter.longitude
                    latitude = cameraCenter.latitude
                    
                    let cameraLocation = CLLocation(latitude: cameraCenter.latitude, longitude: cameraCenter.longitude)
                    self.userLocation = cameraLocation
                    
                    CLGeocoder().reverseGeocodeLocation(cameraLocation) { placemarks, error in
                        guard let placemark = placemarks?.first else { return }
                        let reversedGeoLocation = GeoLocation(with: placemark)
                        placeName = reversedGeoLocation.name
                    }
                    
                    checkAndPlayMusic(for: cameraLocation)
                    checkAndNotifyUser(for: cameraLocation)
                }
                .animation(.easeIn(duration: 1), value: positionMap)
                .mapControls {
                    MapUserLocationButton()
                        .mapControlVisibility(.automatic)
                        .padding()
                    MapPitchToggle()
                }
                .frame(height: UIScreen.main.bounds.height - 10)
            }
            
            Image(systemName: "scope")
                .resizable()
                .frame(width: 30, height: 30)
                .opacity(0.6)
                .padding(.top, 15)
            
            VStack {
                MusicPlayerView(musicPlayer: musicPlayer)
                    .frame(maxWidth: 450, maxHeight: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 150/255, green: 150/255, blue: 150/255, opacity: 0.2), lineWidth: 1)
                            .shadow(radius: 1)
                    )
                    .background()
                    .frame(width: 450)
                    .cornerRadius(10)
                    .onAppear {
                        musicPlayer.updateCurrentTrackInfo()
                    }
                Text("\(placeName)")
                    .cornerRadius(10)
                    .padding(.top, 10)
                    .opacity(0.6)
                Spacer()
            }.padding(.top, 30)
            
            SlideOverCard {
                VStack(spacing: 15) {
                    Handle()
                    SidebarCardView(positionMap: $positionMap, musicPlayer: $musicPlayer, isAddingMemoryLocation: $isAddingMemoryLocation)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isAddingMemoryLocation) {
            AddMemoryView(isShowingAddMemoryLocation: $isAddingMemoryLocation, musicPlayer: $musicPlayer, positionMap: $positionMap, longitude: $longitude, latitude: $latitude, locationName: placeName)
                .padding(.top, 10)
        }
    }
    
    private func checkAndPlayMusic(for cameraLocation: CLLocation) {
        for memoryLocation in memoryLocations {
            let targetLocation = memoryLocation.location()
            let targetRadius = CLLocationDistance(memoryLocation.maxRadius)
            
            if cameraLocation.distance(from: targetLocation) <= targetRadius {
                if !memoryLocation.isPlayingMusic {
                    musicPlayer.play(songID: MusicItemID(String(memoryLocation.musicItemID)))
                    memoryLocation.isPlayingMusic = true
                }
            } else {
                if memoryLocation.isPlayingMusic {
                    musicPlayer.stop()
                    memoryLocation.isPlayingMusic = false
                }
            }
        }
    }
    
    private func checkAndNotifyUser(for cameraLocation: CLLocation) {
        for memoryLocation in memoryLocations {
            let targetLocation = memoryLocation.location()
            let targetRadius = CLLocationDistance(memoryLocation.maxRadius)
            
            if cameraLocation.distance(from: targetLocation) <= targetRadius {
                NotificationManager.shared.notificationLocation(coordinate: memoryLocation.coordinate(), radius: targetRadius, memoryName: memoryLocation.name)
            }
        }
    }
}

#Preview {
    ContentView()
}


extension CLLocationCoordinate2D {
    static let greenOfficePark = CLLocationCoordinate2D(latitude: -6.301616, longitude: 106.651096)
    static let appleDeveloperAcademy = CLLocationCoordinate2D(latitude: -6.299931, longitude: 106.640952)
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: -6.301616, longitude: 106.651096)
    }
}
extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
    }
}
