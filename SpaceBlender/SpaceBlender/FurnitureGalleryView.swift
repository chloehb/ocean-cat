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
            }
        }
    }
}
