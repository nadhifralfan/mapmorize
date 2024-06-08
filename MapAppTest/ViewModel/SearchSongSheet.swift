//
//  SearchSongSheet.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 22/05/24.
//

import SwiftUI
import MusicKit

import SwiftUI
import MusicKit

struct SearchSongSheet: View {
    @Binding var musicPlayer: MusicManager
    @Binding var isSelectingSong: Bool
    @Binding var selectedSong: Song?
    @State var searchingSong = false
    @State private var searchText: String = ""
    @State var searchResults: [Song] = []
    
    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                TextField("Search song", text: $searchText)
                    .autocorrectionDisabled()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        Task {
                            await searchSongs()
                        }
                    }
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .padding(.trailing, 8)
                }
            }
            Spacer()
            List {
                ForEach(searchResults, id: \.id) { song in
                    HStack {
                        ArtworkImage((song.artwork)!, width: 30, height: 30)
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.artistName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            selectedSong = song
                            isSelectingSong = false
                        }) {
                            Image(systemName: isSelected(song: song) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.pink)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .padding()
        .onChange(of: searchText) {
            Task {
                await searchSongs()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    private func searchSongs() async {
        searchingSong = true
        if searchText.isEmpty {
            self.searchResults = []
            searchingSong = false
        } else {
            do {
                let request = MusicCatalogSearchRequest(term: self.searchText, types: [Song.self])
                let response = try await request.response()
                self.searchResults = Array(response.songs)
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
    SearchSongSheet(musicPlayer: .constant(MusicManager()), isSelectingSong: .constant(true), selectedSong: .constant(nil))
}
