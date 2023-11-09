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
//                NavigationLink(destination: ScanningView(), label: {Text("Start Scan")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
                NavigationLink {
                    ScanningView()
                } label: {
                    Text("Start Scan")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
            }
        }
    }
}
