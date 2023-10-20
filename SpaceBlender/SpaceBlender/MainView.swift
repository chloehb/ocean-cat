//
//  MainView.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import SwiftUI


struct MainView: View {
    @ObservedObject
    private var store = ModelStore.shared
    @State private var isPresentingOnBoarding = false
    @State private var isPresentingRoomGallery = false
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button {
                isPresentingOnBoarding.toggle()
            } label: {
                Text("start scanning")
            }
            Button {
                isPresentingRoomGallery.toggle()
            } label: {
                Text("room gallery")
            }
            Text("There are \(store.models.count) model(s)")
        }
        .padding()
        .navigationDestination(isPresented: $isPresentingOnBoarding) {
            OnBoardingView(isPresented: $isPresentingOnBoarding)
        }
        .navigationDestination(isPresented: $isPresentingRoomGallery) {
            RoomGalleryView(isPresented: $isPresentingRoomGallery)
        }
    }
}
