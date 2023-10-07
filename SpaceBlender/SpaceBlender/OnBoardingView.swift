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
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "camera.metering.matrix")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Roomscanner").font(.title)
                Spacer().frame(height: 40)
                Text("Scan the room by pointing the camera at all surfaces. Model export supports usdz and obj format.")
                Spacer().frame(height: 40)
                NavigationLink(destination: ScanningView(), label: {Text("Start Scan")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            }
        }
    }
}
