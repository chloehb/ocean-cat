//
//  FurnitureGalleryView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 10/23/23.
//

import Foundation
import SwiftUI
import RealityKit


struct FurnitureGalleryView: View {
    @State private var isPresentingCaptured = false
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    var body: some View {
        NavigationStack {
            VStack {
                Text("Furniture Gallery").font(.title)
                Text("There are \(store.models.count) model(s)")
                List(store.models, id: \.identifier) {
                    model in
                    Text(model.date!)
                    Text(model.name!)
                }
                Button {
                    isPresentingCaptured.toggle()
                } label: {
                    Text("Scan Object")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 300, height: 70)
                }
                
            }
            .padding()
            .navigationDestination(isPresented: $isPresentingCaptured) {
                ContentView()
            }
        }
    }
}
