//
//  SearchLocationSheet.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 20/05/24.
//

import SwiftUI
import MapKit

struct SearchLocationSheet: View {
    @State private var locationService = LocationService(completer: .init())
    @State private var search: String = ""
    @Binding var searchResults: [SearchResult]
    @Binding var isSearchingLocation: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .leading){
                TextField("Search location", text: $search)
                    .autocorrectionDisabled()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        Task {
                            searchResults = (try? await locationService.search(with: search)) ?? []
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
                ForEach(locationService.completions) { completion in
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
            .scrollContentBackground(.hidden)
        }
        .padding()
        .onChange(of: search) {
            locationService.update(queryFragment: search)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    private func didTapOnCompletion(_ completion: SearchCompletions) {
        Task {
            if let singleLocation = try? await locationService.search(with: "\(completion.title) \(completion.subTitle)").first {
                searchResults = [singleLocation]
                isSearchingLocation = false
            }
        }
    }
}
