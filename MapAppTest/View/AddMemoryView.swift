//
//  AddMemory.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 20/05/24.
//

import SwiftUI
import MapKit
import MusicKit
import PhotosUI
import SwiftData

struct AddMemoryView : View {
    @Environment(\.modelContext) var modelContext
    
    @State private var name: String = ""
    
    @Binding var isShowingAddMemoryLocation: Bool
    
    @Binding var musicPlayer: MusicManager
    
    @Binding var positionMap: MapCameraPosition
    @Binding var longitude: CLLocationDegrees
    @Binding var latitude: CLLocationDegrees
    @State var locationName: String
    
    @State var isSelectingPhotos = false
    @State var searchingLocation = false
    @State var isSelectingSong = false
    @State var searchingSong = false
    @State var selectedImages: [UIImage]?
    @State var date: Date = Date()
    @State private var searchText: String = ""
    @State var searchResults: [Song] = []
    @State var selectedSong: Song?
    @State var description: String = ""
    @State var maxRadius: Double = 50
    @State var searchResultsLocation: [SearchResult] = []
    private var isFormValid: Bool {
            !name.isEmpty &&
            !locationName.isEmpty &&
            selectedImages != nil &&
            selectedSong != nil
        }
    
    var body: some View {
        Spacer()
        HStack {
            Button(action: {
                isShowingAddMemoryLocation = false
            }, label: {
                Text("Cancel")
            })
            Spacer()
            Text("Add Memory Location")
                .font(.title3)
            .fontWeight(.bold)
            Spacer()
            Button(action: {
                let newMemory = MemoryLocation(name: name, latitude: latitude, longitude: longitude, date: date, image: selectedImages!.map { $0.pngData()!}, desc: description, maxRadius: Int(maxRadius), musicItemID: selectedSong!.id.rawValue, id: UUID().uuidString)
                modelContext.insert(newMemory)
                isShowingAddMemoryLocation = false
            }, label: {
                Text("Save")
            }).disabled(!isFormValid)
        }
        .padding(.horizontal, 16)
        Form{
            Section("Name"){
                TextField("High School Graduation", text: $name)
            }
            Section("Description"){
                TextField("SMA Tadika Mesra Class of 2023", text: $description, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
            }
            Section("Date"){
                DatePicker("Date of Events:", selection: $date, displayedComponents: .date)
            }
            Section(header: Text("Location"), footer: Text("You can select location from the map or search the location.")){
                ZStack(alignment: .leading){
                    TextField(locationName, text: $locationName)
                        .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    HStack {
                        Spacer()
                        Button(action: {
                            searchingLocation.toggle()
                        }, label: {
                            Text("Search Location")
                        })
                    }
                }
            }.sheet(isPresented: $searchingLocation, content: {
                SearchLocationSheet(searchResults: $searchResultsLocation, isSearchingLocation: $searchingLocation)
            }).onChange(of: searchResultsLocation) {
                recodeLocation()
            }
            Section(header: Text("Radius"), footer: Text("The radius of the memory location, you will be notified when you enter the radius.")){
                Text("Radius Trigger: \(Int(maxRadius))")
                    .foregroundStyle(.secondary)
                Slider(value: $maxRadius, in: 0...200, step: 1)
            }
            Section(header: Text("Music"), footer: Text("Music will play when you enter the radius of the memory location, you can disabled this on the settings.")){
                ZStack(alignment: .leading){
                    Text(selectedSong?.title ?? "No Song Selected")
                        .foregroundStyle(.secondary)
                    HStack {
                        Spacer()
                        Button(action: {
                            isSelectingSong = true
                        }, label: {
                            Text("Select Song")
                        })
                    }
                }
            }.onChange(of: selectedSong) {
            }
            Section(header: Text("Photos"), footer: Text("Photos will be shown when you click on the slide show")){
                ZStack(alignment: .leading){
                    Text("Selected \(selectedImages?.count ?? 0) photos")
                        .foregroundStyle(.secondary)
                    HStack {
                        Spacer()
                        Button(action: {
                            isSelectingPhotos = true
                        }, label: {
                            Text("Select Photos")
                        })
                    }
                }
            }
        }.sheet(isPresented: $isSelectingPhotos) {
            CustomPhotoPickerView(selectedImages: $selectedImages)
        }.sheet(isPresented: $isSelectingSong) {
            SearchSongSheet(musicPlayer: $musicPlayer, isSelectingSong:
                $isSelectingSong, selectedSong: $selectedSong)
        }
    }
    
    private func recodeLocation() {
        latitude = searchResultsLocation.first!.location.latitude
        longitude = searchResultsLocation.first!.location.longitude
        positionMap = .region(MKCoordinateRegion(
            center: searchResultsLocation.first!.location,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
        
        let coordinate = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(coordinate) { placemarks, error in
            guard let placemark = placemarks?.first else { return }
            let reversedGeoLocation = GeoLocation(with: placemark)
            locationName = reversedGeoLocation.name
        }
    }
    
    private func searchSongs() async {
        searchingSong = true
        if self.searchText.isEmpty {
            self.searchResults = []
            searchingSong = false
        } else {
            do {
                let request = MusicCatalogSearchRequest(term: self.searchText, types: [Song.self])
                let response = try await request.response()
                for case let song in response.songs {
                    self.searchResults.append(song)
                }
                searchingSong = false
            } catch {
                print(error)
                searchingSong = false
            }
        }
    }
    
    private func isSelected(song: Song) -> Bool {
        return self.selectedSong?.id == song.id
    }
    
}

#Preview {
    AddMemoryView(isShowingAddMemoryLocation: .constant(true), musicPlayer: .constant(MusicManager()), positionMap: .constant(MapCameraPosition.automatic), longitude: .constant(0.0), latitude: .constant(0.0),locationName: "SMA", selectedImages: [UIImage()], date: Date())
}
