//
//  MemoryCardView.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 17/05/24.
//

import SwiftUI
import MusicKit
import MapKit
import SwiftData

struct MemoryCardView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var memoryLocations: [MemoryLocation]
    @ObservedObject var memoryLocation: MemoryLocation
    @Binding var positionMap: MapCameraPosition
    @State private var showSliderView = false
    @State private var isShowDetail = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                updateMapPosition(to: memoryLocation.coordinate())
            }) {
                VStack(alignment: .leading) {
                    Text(memoryLocation.name)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(memoryLocation.date, style: .date)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    showSliderView = true
                    updateMapPosition(to: memoryLocation.coordinate())
                }, label: {
                    Image(systemName: "play.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.secondary.opacity(0.2))
                        )
                })

                Button(action: {
                    showDeleteConfirmation = true
                }, label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.secondary.opacity(0.2))
                        )
                })
                .confirmationDialog("Are you sure you want to delete this memory?", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        deleteMemoryLocation()
                    }
                }
            }
        }
        
        .fullScreenCover(isPresented: $showSliderView) {
            let imageData = $memoryLocation.image.wrappedValue
            let uiImages: [UIImage] = imageData.compactMap { data in
                guard let data = data else { return nil }
                return UIImage(data: data)
            }

            PhotoSliderView(images: .constant(uiImages), isPresented: $showSliderView)
                .semiTransparentBackground()
        }

        .frame(maxWidth: 450)
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
    
    private func updateMapPosition(to coordinate: CLLocationCoordinate2D) {
        positionMap = .region(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    private func deleteMemoryLocation() {
        modelContext.delete(memoryLocation)
    }
}

struct SemiTransparentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
}

extension View {
    func semiTransparentBackground() -> some View {
        self.modifier(SemiTransparentBackgroundModifier())
    }
}
