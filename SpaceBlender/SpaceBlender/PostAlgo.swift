//
//  PostAlgo.swift
//  SpaceBlender
//
//  Created by Ellen Paradis on 11/2/23.
//

import Foundation
import SwiftUI

struct PostAlgo: View {
    @Binding var isPresented: Bool
    @State private var isPresentingRoomGallery = false
    @State private var isPresentingFurnitureGallery = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Adjustment Suceeded!")
                Button {
                    isPresentingFurnitureGallery.toggle()
                } label: {
                    Text("Select Furniture")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                Button {
                    isPresentingRoomGallery.toggle()
                } label: {
                    Text("Save to Gallery")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                Spacer()
            }
            .navigationDestination(isPresented: $isPresentingRoomGallery) {
                RoomGalleryView(isPresented: $isPresentingRoomGallery)
            }
            .navigationDestination(isPresented: $isPresentingFurnitureGallery) {
                FurnitureGalleryView(isPresented: $isPresentingFurnitureGallery)
            }
        }
    }
}
