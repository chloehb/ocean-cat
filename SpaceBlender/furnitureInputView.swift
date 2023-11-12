//
//  furnitureInputView.swift
//  SpaceBlender
//
//  Created by 周晓玮 on 11/11/23.
//

import Foundation
import SwiftUI



struct FurnitureInputView: View {
    @State var name: String = ""
    @State  var selectFurniture = "Bed"
//    @State  var  = "Bed"
    @State private var isNavigating = false
    @State private var isUploading = false
    
    var furnitureType = ["Bed", "Desk", "Others", "waitingForImplement"]
    
    
    var body: some View {
        VStack {
            Image(systemName: "house.circle.fill")
                .resizable()  // 允许图像大小可调
                .frame(width: 80, height: 80) // 设置图像的宽度和高度
            Spacer()
            HStack {
//                Image(systemName: "lamp.desk.fill")
                TextField("named your scanned furniture", text: $name, onCommit: {
                })
                .multilineTextAlignment(.center)
            }
            
            Divider()
            HStack {
                Picker("Please choose your furniture type", selection: $selectFurniture) {
                               ForEach(furnitureType, id: \.self) {
                                   Text($0)
                               }
                           }
                           Text("You selected: \(selectFurniture)")
            }
            
            Spacer()
            Spacer()
            
            Button(action: {
                isNavigating = true
            }) {
                Text("continue to scan")
                    .fontWeight(.semibold)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .navigationDestination(isPresented: $isNavigating) {
                ContentView(name: $name, selectFurniture: $selectFurniture)
            }
            
            Button(action: {
                isUploading = true
            }) {
                Text("continue to upload")
                    .fontWeight(.semibold)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .navigationDestination(isPresented: $isUploading) {
                furnitureUpload(name: $name, selectFurniture: $selectFurniture)
            }
            
            Spacer()
            
            
        }
        .padding(.top, 100)
        .padding(.leading)
        .padding(.trailing)
        
    }
}



