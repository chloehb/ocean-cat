//
//  SurveyAlgoView.swift
//  SpaceBlender
//
//  Created by Ellen Paradis on 10/29/23.
//

// reference: third-party object capture tool: https://developer.apple.com/augmented-reality/object-capture/

import Foundation
import SwiftUI
import RoomPlan
import SceneKit

struct SurveyView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    @State private var isPresentingPostAlgo = false
    @State var index: Int
    @State var hasRoommate: Bool? = nil
    @State var bedsTogether: Bool? = nil
    @State var objectByWindow: String? = nil
    @State var bedFacingDoor: Bool? = nil
    @State var floorSpace: Bool? = nil
    @State var adjustment: AttachedResult = AttachedResult()
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .center){
                Text("Survey Questions").font(.title).multilineTextAlignment(.center).fontWeight(.bold)
                    .padding()
                Text("Do you have a roommate?").multilineTextAlignment(.center)
                HStack {
                    Button {
                        self.hasRoommate = true
                    } label: {
                        Text("Yes")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(hasRoommate == true ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                    Button {
                        self.hasRoommate = false
                    } label: {
                        Text("No")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(hasRoommate == false ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                }
                Spacer()
                Text("If you have a roommate, do you want your beds next to each other?").multilineTextAlignment(.center)
                HStack {
                    Button {
                        self.bedsTogether = true
                    } label: {
                        Text("Yes")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(bedsTogether == true ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                    Button {
                        self.bedsTogether = false
                    } label: {
                        Text("No")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(bedsTogether == false ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                }
                Spacer()
                Text("Do you prefer your desk to be by your window?").multilineTextAlignment(.center)
                HStack {
                    Button {
                        self.objectByWindow = "Desk"
                    } label: {
                        Text("Yes")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(objectByWindow == "Desk" ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                    Button {
                        self.objectByWindow = "No"
                    } label: {
                        Text("No")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(objectByWindow == "No" ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                }
                Spacer()
                Text("Do you want your bed to face towards your door?").multilineTextAlignment(.center)
                HStack {
                    Button {
                        self.bedFacingDoor = true
                    } label: {
                        Text("Yes")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(bedFacingDoor == true ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                    Button {
                        self.bedFacingDoor = false
                    } label: {
                        Text("No")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(bedFacingDoor == false ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                }
                Spacer()
                
                Text("Do you want to maximize the open floor space in your room?").multilineTextAlignment(.center)
                HStack {
                    Button {
                        self.floorSpace = true
                    } label: {
                        Text("Yes")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(floorSpace == true ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                    Button {
                        self.floorSpace = false
                    } label: {
                        Text("No")
                            .padding()
                            .fontWeight(.bold)
                            .frame(width: 90, height: 40)
                    }
                    .foregroundColor(.white)
                    .background(floorSpace == false ? Color(red:0.3, green:0.4, blue:0.7, opacity: 0.8) : Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 3, y: 3)
                }
                Spacer()
                Text("Please ensure requests are reasonable with regards to room size and fixtures").multilineTextAlignment(.center).font(.footnote)
                Button {
                    // will go to next page
                    isPresentingPostAlgo.toggle()
                    print(isPresentingPostAlgo)
                    var adj = Adjuster(index: index, hasRoommate: hasRoommate, bedsTogether: bedsTogether, bedFacingDoor: bedFacingDoor, objectByWindow: objectByWindow, floorSpace: floorSpace)
                    adj.smartAdjust()
                    adjustment = adj.generateResult()
                } label: {
                    Text("Submit")
                        .padding()
                        .fontWeight(.bold)
                        .frame(width: 120, height: 40)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
            } 
            .padding()
            .navigationDestination(isPresented: $isPresentingPostAlgo) {
                PostAlgo(isPresented: $isPresentingPostAlgo ,adjustment: adjustment, index: index)
            }
        }
        
    }
}


