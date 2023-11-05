//
//  SelectFurnitureView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 11/5/23.
//

import Foundation
import SwiftUI

struct SelectFurnitureView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    
    var body: some View {
        HStack {
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
            Spacer()
            Button {
                //todo: add navigation
            } label: {
                Text("Select")
                    .padding()
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 95, height: 38)
            }
            .foregroundColor(.white)
            .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
            .cornerRadius(10)
            .shadow(color: .blue, radius: 3, y: 3)
            .padding()
        }
        ZStack {
            Color(.white)
                .ignoresSafeArea()
        }
        VStack {
            Spacer()
            ZStack {
                Color(red:0.3, green:0.4, blue:0.7, opacity: 1.0)
                HStack {
                    Spacer()
                    Button {
                        //isPresentingRoomGallery.toggle()
                    } label: {
                        Image("ChairIcon")
                            .padding()
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(height: 70)
                    }
                    Spacer()
                    Button {
                        //isPresentingRoomGallery.toggle()
                    } label: {
                        Image("BedIcon")
                            .padding()
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(height: 70)
                    }
                    Spacer()
                    Button {
                        //isPresentingRoomGallery.toggle()
                    } label: {
                        Image("CouchIcon")
                            .padding()
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(height: 70)
                    }
                    Spacer()
                    Button {
                        //isPresentingRoomGallery.toggle()
                    } label: {
                        Image("DeskIcon")
                            .padding()
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(height: 70)
                    }
                    Spacer()
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
        }.edgesIgnoringSafeArea(.bottom)
    }
}

