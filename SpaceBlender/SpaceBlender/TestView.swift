//
//  TestView.swift
//  SpaceBlender
//
//  Created by akai on 10/20/23.
//

import Foundation
import SwiftUI

struct TestView: View {
    @ObservedObject var store = ModelStore.shared
    var body: some View {
        NavigationStack {
            VStack {
                Text("Space Blender-onboarding").font(.title)
                Text("There are \(store.models.count) model(s)")
                Spacer().frame(height: 40)
                Text("I don't know why I create such test view but currently we use it as a test.")
                Spacer().frame(height: 40)
                NavigationLink(destination: MainView(), label: {Text("Back to MainView")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            }
        }
    }
}

