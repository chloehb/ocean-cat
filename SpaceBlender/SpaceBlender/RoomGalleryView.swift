//
//  RoomGalleryView.swift
//  SpaceBlender
//
//  Created by akai on 10/20/23.
//

import Foundation
import SwiftUI

struct RoomGalleryView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    var body: some View {
        NavigationStack {
            VStack {
                Text("Space Blender-room gallery view").font(.title)
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

