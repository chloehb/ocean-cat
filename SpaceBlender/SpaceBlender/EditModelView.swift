//
//  EditModelView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 11/5/23.
//

import Foundation
import SwiftUI

struct EditModelView: View {
    @Binding var isPresented: Bool
    @State private var isPresentingRoomGallery = false
    @State private var isPresentingRequestSurvey = false
    @State private var isPresentingSelectFurniture = false
    var body: some View {
//        HStack {
//            Button {
//                //isPresentingSelectMethod.toggle()
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
        
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                // rgb: 168, 182, 234
                Spacer()
                let image_name = "ex_roommodel"
                Image(image_name)
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                    .padding(.all)
                Spacer()
                VStack() {
                    Button {
                        isPresentingRequestSurvey.toggle()
                    } label: {
                        Text("Auto-Layout")
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
                    Button {
                        isPresentingSelectFurniture.toggle()
                    } label: {
                        Text("Select Furniture")
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
                    Button {
                        isPresentingRoomGallery.toggle()
                    } label: {
                        Text("Save to Gallery")
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
                Spacer()
            }
            .navigationDestination(isPresented: $isPresentingRoomGallery) {
                RoomGalleryView(isPresented: $isPresentingRoomGallery)
            }
            .navigationDestination(isPresented: $isPresentingRequestSurvey) {
                RequestSurveyView(isPresented: $isPresentingRequestSurvey, index: 0)
            }
            .navigationDestination(isPresented: $isPresentingSelectFurniture) {
                SelectFurnitureView(isPresented: $isPresentingSelectFurniture)
            }
        }

    }
}
