//
//  PhotoSliderView.swift
//  MapAppTest
//
//  Created by Nadhif Rahman Alfan on 22/05/24.
//

import SwiftUI

struct PhotoSliderView: View {
    @Binding var images: [UIImage]
    @Binding var isPresented: Bool
    public let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @State private var selection = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selection) {
                ForEach(0..<images.count, id: \.self) { i in
                    ZStack {
                        GeometryReader { geo in
                            Image(uiImage: images[i])
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width)
                                .clipped()
                                .ignoresSafeArea()
                                .overlay{
                                    RoundedRectangle(cornerRadius: 0)
                                        .fill(Color.yellow)
                                        .opacity(0.1)
                                        .frame(width: geo.size.width, height: geo.size.height)
                                }
                            Image("frame")
                                .resizable()
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .tag(i)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .onReceive(timer) { _ in
                withAnimation {
                    selection = (selection + 1) % images.count
                }
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.height > 100 {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
        )
    }
}

struct SliderView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoSliderView(images: .constant([UIImage(named: "sushi tuna")!, UIImage(named: "sushi tamago")!, UIImage(named: "sushi shrimp")!]), isPresented: .constant(true))
    }
}
