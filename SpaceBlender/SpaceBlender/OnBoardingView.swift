//
//  OnBoarding.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import Foundation
import SwiftUI

struct OnBoardingView: View {
    @ObservedObject var store = ModelStore.shared
    var body: some View {
        NavigationStack {
            VStack {
                Text("Space Blender").font(.title)
                Text("There are \(store.models.count) model(s)")
                Spacer().frame(height: 40)
                Text("Scan the room by pointing the camera at all surfaces. Model export supports usdz and obj format.")
                Spacer().frame(height: 40)
//                Button("Test model amount") {
//                    print("There are \(store.models.count) model(s)")
//                }
                NavigationLink(destination: ScanningView(), label: {Text("Start Scan")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            }
        }
    }
}
