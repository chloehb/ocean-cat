//
//  OnBoarding.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import Foundation
import SwiftUI

struct OnBoardingView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    var body: some View {
        NavigationStack {
            VStack {
                Text("Space Blender-onboarding").font(.title)
                Text("There are \(store.models.count) model(s)")
                Spacer().frame(height: 40)
                Text("Scan the room by pointing the camera at all surfaces. Model export supports usdz and obj format.")
                Spacer().frame(height: 40)
                NavigationLink(destination: ScanningView(), label: {Text("Start Scan")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
                NavigationLink(destination: UploadUsdzView(), label: {Text("Upload File")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            }
        }
    }
}
