//
//  TestView.swift
//  SpaceBlender
//
//  Created by akai on 10/20/23.
//

import Foundation
import SwiftUI

struct ModelView: View {
    @ObservedObject var store = ModelStore.shared
    var body: some View {
        NavigationStack {
            VStack {
                Text("Space Blender-model view").font(.title)
                Text("There are \(store.models.count) model(s)")
                Spacer().frame(height: 40)
                Spacer().frame(height: 40)
                NavigationLink(destination: MainView(), label: {Text("Back to MainView")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            }
        }
    }
}

