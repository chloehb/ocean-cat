//
//  MainView.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import SwiftUI

enum DestinationMainView {
    case RoomGallery
    case FurnitureGallery
    case SelectMethod
    case Capture
}

struct MainView: View {
    @ObservedObject
    private var store = ModelStore.shared
    @State var destination: DestinationMainView? = nil
    @State var isPresentingDestination: Bool = false
    //    @ObservedObject var exchangeModel: SceneKitViewModel
    
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
                Menu {
                    Button("Cancel", role: .destructive) {
                    }
                    Button {
                        destination = .Capture
                        isPresentingDestination.toggle()
                    } label: {
                        Text("Create Furniture Model")
                            .padding()
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 250, height: 70)
                    }
                    Button {
                        destination = .SelectMethod
                        isPresentingDestination.toggle()
                    } label: {
                        Text("Create Room Model")
                            .padding()
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(width: 250, height: 70)
                    }
                } label: {
                    Label("Create New Model", systemImage: "")
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
                    destination = .RoomGallery
                    isPresentingDestination.toggle()
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
                    destination = .FurnitureGallery
                    isPresentingDestination.toggle()
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
            .navigationDestination(isPresented: $isPresentingDestination) {
                switch destination {
                case .RoomGallery:
                    RoomGalleryView()
                case .FurnitureGallery:
                    FurnitureGalleryView()
                case .SelectMethod:
                    SelectMethodView()
                case _:
                    FurnitureInputView()
                }
            }
        }
    }
}
