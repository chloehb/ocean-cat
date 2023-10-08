//
//  SpaceBlenderApp.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import SwiftUI

@main
struct SpaceBlenderApp: App {
    init() {
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                OnBoardingView()
            }
        }
    }
}
