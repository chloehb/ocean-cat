//
//  RoomGalleryView.swift
//  SpaceBlender
//
//  Created by akai on 10/20/23.
//

import Foundation
import SwiftUI

struct RoomGalleryView: View {
    @ObservedObject var store = ModelStore.shared
    @State var isPresentingDemo: Bool = false
    @State private var isPresentingSelectMethod = false
//    @ObservedObject var viewModel: SceneKitViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Room Gallery").font(.title)
                Text("There are \(store.models.count) model(s)")
                List(0..<store.models.count) { //identifer was not unique
                    
                    index in
                    let image = "ex_room"
                    let date = store.models[index].date!
                    let name = store.models[index].name!
                    
                    VStack(alignment: .leading, spacing: 20.0) {
                        
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(15)
                        HStack {
                            Spacer()
                            Text(date + " " + name).font(.title).multilineTextAlignment(.center)
                            Spacer()
                        }
                        NavigationLink(destination: EditModelView(index: index), label: {Text("")})
                        .buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
                    }
                    .padding()
                    .background(Rectangle().foregroundColor(.white).cornerRadius(15).shadow(radius: 15))
                    .padding()
                    
                }
                Spacer()
                Button {
                    isPresentingSelectMethod.toggle()
                } label: {
                    Text("New Room Model")
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
            }
            .navigationDestination(isPresented: $isPresentingSelectMethod) {
                SelectMethodView()
            }
        }
    }
}

