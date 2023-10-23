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
    @State private var isPresentingFurnitureGallery = false
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                // rgb: 168, 182, 234
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                    .padding(.all)
                Button {
                    isPresentingOnBoarding.toggle()
                } label: {
                    Text("Create New Model")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                .padding(.top)
                Button {
                    isPresentingRoomGallery.toggle()
                } label: {
                    Text("Room Gallery")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                Button {
                    isPresentingFurnitureGallery.toggle()
                } label: {
                    Text("Furniture Gallery")
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
            .padding()
            .navigationDestination(isPresented: $isPresentingOnBoarding) {
                OnBoardingView(isPresented: $isPresentingOnBoarding)
            }
            .navigationDestination(isPresented: $isPresentingRoomGallery) {
                RoomGalleryView(isPresented: $isPresentingRoomGallery)
            }
            .navigationDestination(isPresented: $isPresentingFurnitureGallery) {
                FurnitureGalleryView(isPresented: $isPresentingFurnitureGallery)
            }
        }
    }
}
