//
//  furnitureInputView.swift
//  SpaceBlender
//
//  Created by 周晓玮 on 11/11/23.
//
//reference: log in page implementation: https://medium.com/mop-developers/build-your-first-swiftui-app-part-3-create-the-login-screen-334d90ef1763
// reference: imgae from sf database

import Foundation
import SwiftUI



struct FurnitureInputView: View {
    @State var name: String = ""
    @State  var selectFurniture = "Bed"
    //    @State  var  = "Bed"
    @State private var isNavigating = false
    @State private var showAlert = false
    @State private var isUploading = false
    @ObservedObject var store = furnitureStore.shared
    
    var furnitureType = ["Bed", "Desk", "Others", "waitingForImplement"]
    
    
    //    let filteredFurniture = store.models.filter { furniture in
    //                furniture.name == name
    //        }
    
    
    var body: some View {
        VStack {
            Image(systemName: "house.circle.fill")
                .resizable()  
                .frame(width: 80, height: 80) 
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
                
                
                let filteredFurniture = store.models.filter { furniture in
                    furniture.name == name
                }
                if (filteredFurniture.count > 0){
                    
                }
                if filteredFurniture.count > 0 {
                    showAlert = true
                } else {
                    isNavigating = true
                }
                
                //                isNavigating = true
                
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Furniture Found"),
                    message: Text("We have found some furniture that matches your input name."),
                    dismissButton: .default(Text("OK")) {
                        // Reload the view or perform other actions after dismissing the alert
                        // This could be reloading data or resetting state variables
                        name =  ""
                        selectFurniture = "Bed"
                        isNavigating = false
                        showAlert = false
                        isUploading = false
                    }
                )
            }
            .navigationDestination(isPresented: $isNavigating) {
                ContentView(name: $name, selectFurniture: $selectFurniture)
            }
            
            Button(action: {
                let filteredFurniture = store.models.filter { furniture in
                    furniture.name == name
                }
                if (filteredFurniture.count > 0){
                    
                }
                if filteredFurniture.count > 0 {
                    showAlert = true
                } else {
                    isUploading = true
                }
//                isUploading = true
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Furniture Found"),
                    message: Text("We have found some furniture that matches your input name."),
                    dismissButton: .default(Text("OK")) {
                        // Reload the view or perform other actions after dismissing the alert
                        // This could be reloading data or resetting state variables
                        name =  ""
                        selectFurniture = "Bed"
                        isNavigating = false
                        showAlert = false
                        isUploading = false
                    }
                )
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



