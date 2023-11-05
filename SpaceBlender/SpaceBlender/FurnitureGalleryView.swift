//
//  FurnitureGalleryView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 10/23/23.
//

import Foundation
import SwiftUI

struct FurnitureGalleryView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    @State private var isPresentingFurnitureScan = false
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
                Spacer()
                Button {
                    isPresentingFurnitureScan.toggle()
                } label: {
                    Text("New Furniture Model")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                .padding()
            }
            .navigationDestination(isPresented: $isPresentingFurnitureScan) {
                FurnitureScanView(isPresented: $isPresentingFurnitureScan)
            }
            
        }
    }
}
