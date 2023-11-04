//
//  RoomGalleryView.swift
//  SpaceBlender
//
//  Created by akai on 10/20/23.
//

import Foundation
import SwiftUI

struct RoomGalleryView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    @State var isPresentingDemo: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Room Gallery").font(.title)
                Text("There are \(store.models.count) model(s)")
                List(store.models, id: \.name) { //identifer was not unique
                    model in
                    //Text(model.date!)
                    //Text(model.name!)
                    //Text(model.image!)
                    
                    let image = "ex_room"
                    let date = model.date!
                    let name = model.name!
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
                        NavigationLink(destination: MinimalDemoView(showing: $isPresentingDemo), label: {Text("")}).simultaneousGesture(TapGesture().onEnded{
                            isPresentingDemo.toggle()
                            // todo: need to specify which room model is shown, currently, always the first one
                        }).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
                    }
                    .padding()
                    .background(Rectangle().foregroundColor(.white).cornerRadius(15).shadow(radius: 15))
                    .padding()
                    
                }
                // ONE room card:
                
            }
        }
    }
}

