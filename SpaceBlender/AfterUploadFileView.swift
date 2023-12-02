//
//  AfterUploadFileView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 10/29/23.
//

import Foundation
import SwiftUI

struct AfterUploadFileView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    @State private var isPresentingRoomGallery = false
    @State private var isPresentingSelectMethod = false
//    @ObservedObject var viewModel: SceneKitViewModel

    var body: some View {
//        HStack {
//            Button {
//                isPresentingSelectMethod.toggle()
//            } label: {
//                Text("Back")
//                    .padding()
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .frame(width: 80, height: 38)
//            }
//            .foregroundColor(.white)
//            .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
//            .cornerRadius(10)
//            .shadow(color: .blue, radius: 3, y: 3)
//            .padding()
//            Spacer()
//        }
//        .navigationDestination(isPresented: $isPresentingSelectMethod) {
//            SelectMethodView(isPresented: $isPresentingSelectMethod)
//        }
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                // rgb: 168, 182, 234
                let image_name = "ex_roommodel"
                Image(image_name)
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                    .padding(.all)
                Spacer()
                Button {
                    isPresentingRoomGallery.toggle()
                } label: {
                    Text("Accept")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                .padding()
                Spacer()
            }
            .navigationDestination(isPresented: $isPresentingRoomGallery) {
                RoomGalleryView()
            }
        }

    }
}
