////
////  AddMemoryLocationView.swift
////  MapAppTest
////
////  Created by Nadhif Rahman Alfan on 17/05/24.
////
//
//import SwiftUI
//import MapKit
//import MusicKit
//import PhotosUI
//
//struct AddMemoryLocationView: View {
//    @State private var name: String = ""
//    
//    @Binding var isShowingAddMemoryLocation: Bool
//    
//    @Binding var musicPlayer: MusicPlayer
//    @Binding var longitude: CLLocationDegrees
//    @Binding var latitude: CLLocationDegrees
//    
//    @State var isFilled = false
//    
//    @State var isSelectingPhotos = false
//    @State var searchingSong = false
//    @State var selectedImages: [UIImage]?
//    @State var date: Date?
//    @State private var searchText: String = ""
//    @State var searchResults: [Song] = []
//    @State var selectedSong: Song?
//    @State var description: String = ""
//    @State var maxRadius: Double = 50
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            Text("Add Memory Location")
//                .font(.headline)
//                .fontWeight(.bold)
//            
//            TextField("Name", text: $name)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal, 16)
//                .accentColor(.pink)
//                .onChange(of: name) {
//                }
//            
//            TextField("Description", text: $description)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal, 16)
//                .accentColor(.pink)
//                .onChange(of: description) {
//                }
//            
//            TextField("Search Songs", text: $searchText, onCommit: {
//                Task {
//                    await searchSongs()
//                }
//            })
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .padding(.horizontal, 16)
//            .accentColor(.pink)
//            
//            if(searchingSong) {
//                ProgressView()
//            }
//            
//            List {
//                ForEach(searchResults, id: \.id) { song in
//                    HStack {
//                        ArtworkImageTest(song: song, size: 50)
//                        VStack(alignment: .leading) {
//                            Text(song.title)
//                                .font(.headline)
//                            Text(song.artistName)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                        Spacer()
//                        Button(action: {
//                            self.selectedSong = song
//                        }) {
//                            Image(systemName: isSelected(song: song) ? "checkmark.circle.fill" : "circle")
//                                .foregroundColor(.pink)
//                        }
//                    }
//                }
//            }
//            .accentColor(.pink)
//            
//            Button(action: {
//                self.isSelectingPhotos.toggle()
//            }) {
//                Text("Add Image")
//                    .font(.headline)
//                    .fontWeight(.bold)
//                    .padding()
//                    .background(Color.pink)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            
//            Spacer()
//            HStack{
//                Button(action: {
//                    if let selectedSong = self.selectedSong {
//                        let imageDataArray: [Data] = selectedImages!.compactMap { image in
//                            return image.pngData()
//                        }
//
//                        // Initialize MemoryLocation
//                        let memoryLocation = MemoryLocation(
//                            name: name,
//                            latitude: latitude,
//                            longitude: longitude,
//                            date: Date(),
//                            image: imageDataArray,
//                            description: self.description,
//                            maxRadius: Int(self.maxRadius),
//                            musicItemID: Int(selectedSong.id),
//                            id: UUID().uuidString
//                        )
//                        arrayMemoryLocations.append(memoryLocation)
//                        self.isShowingAddMemoryLocation = false
//                    }
//                }) {
//                    Text("Save")
//                        .font(.headline)
//                        .fontWeight(.bold)
//                        .padding()
//                        .background(isFilled ? Color.accentColor : Color.gray)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//                .disabled(isFilled == false)
//            }
//        }
//        .onAppear {
//            Task {
//                await searchSongs()
//            }
//        }
//        .sheet(isPresented: $isSelectingPhotos) {
//            CustomPhotoPickerView(selectedImages: $selectedImages)
//        }
//    }
//    
//    private func searchSongs() async {
//        searchingSong = true
//        if self.searchText.isEmpty {
//            self.searchResults = []
//            searchingSong = false
//        } else {
//            do {
//                let request = MusicCatalogSearchRequest(term: self.searchText, types: [Song.self])
//                let response = try await request.response()
//                for case let song in response.songs {
//                    self.searchResults.append(song)
//                }
//                searchingSong = false
//            } catch {
//                print(error)
//                searchingSong = false
//            }
//        }
//    }
//    
//    private func isSelected(song: Song) -> Bool {
//        return self.selectedSong?.id == song.id
//    }
//}
//
//struct ArtworkImageTest: View {
//    var song: Song
//    var size: CGFloat
//    
//    var body: some View {
//        if let url = song.artwork?.url(width: Int(size), height: Int(size)) {
//            AsyncImage(url: url) { image in
//                image.resizable()
//                     .aspectRatio(contentMode: .fit)
//                     .frame(width: size, height: size)
//            } placeholder: {
//                ProgressView()
//                    .frame(width: size, height: size)
//            }
//        } else {
//            Color.gray
//                .frame(width: size, height: size)
//        }
//    }
//}
//
//#Preview{
//    AddMemoryLocationView(isShowingAddMemoryLocation: .constant(true), musicPlayer: .constant(MusicPlayer()), longitude: .constant(0.0), latitude: .constant(0.0))
//}
