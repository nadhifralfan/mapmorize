import SwiftUI
import MapKit
import MusicKit
import SwiftData

struct SidebarCardView: View {
    @Query var memoryLocations: [MemoryLocation]
    
    @Binding var positionMap: MapCameraPosition
    @Binding var musicPlayer: MusicManager
    @Binding var isAddingMemoryLocation: Bool
    
    @State var searchText: String = ""
    @State private var searchIsActive = false
    @State private var locationService = LocationService(completer: .init())
    @State var searchResults: [SearchResult] = []
    @State var searchResult: SearchResult = SearchResult(location: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    var filteredMemoryLocations: [MemoryLocation] {
        if searchText.isEmpty {
            return memoryLocations
        } else {
            return memoryLocations.filter { memoryLocation in
                memoryLocation.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredLocationResults: [SearchCompletions] {
        if searchText.isEmpty {
            return []
        } else {
            let endIndex = min(locationService.completions.count, 5)
            return Array(locationService.completions[..<endIndex])
        }
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: 5.0)
            .frame(width: 40, height: 5)
            .foregroundColor(Color.secondary)
            .offset(y: 5)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Search", text: $searchText)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                    .onSubmit {
                        Task {
                            searchResults = (try? await locationService.search(with: searchText)) ?? []
                        }
                    }
                
                //TODO: Change color of Result Location (Same with + Add Memory button)
                if !filteredLocationResults.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Locations")
                            .font(.headline)
                            .padding(.top, 10)
                        ForEach(filteredLocationResults){ completion in
                            Button(action: {
                                didTapOnCompletion(completion)
                            })
                            {
                                Button(action: { didTapOnCompletion(completion) }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(completion.title)
                                            .font(.headline)
                                            .fontDesign(.rounded)
                                        Text(completion.subTitle)
                                    }
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                    
                if !filteredMemoryLocations.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Memories")
                            .font(.headline)
                            .padding(.top, 10)
                        ForEach(filteredMemoryLocations) { memoryLocation in
                            MemoryCardView(memoryLocation: memoryLocation, positionMap: $positionMap)
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }
                //TODO: Change + Add Memory button, user think it isn't button when searching location
                Button {
                    isAddingMemoryLocation.toggle()
                } label: {
                    Label("Add Memory", systemImage: "plus")
                }
                .padding(.top, 10)
                }
            }
            .onChange(of: searchText) {
                locationService.update(queryFragment: searchText)
            }
        }
        
    private func updateMapPosition(to coordinate: CLLocationCoordinate2D) {
        positionMap = .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    func didTapOnCompletion(_ completion: SearchCompletions) {
        Task {
            if let singleLocation = try? await locationService.search(with: "\(completion.title) \(completion.subTitle)").first {
                searchResult = singleLocation
                updateMapPosition(to: singleLocation.self.location)
            }
        }
    }
}
