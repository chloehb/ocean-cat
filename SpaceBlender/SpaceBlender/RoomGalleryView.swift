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
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Room Gallery").font(.title)
                Text("There are \(store.models.count) model(s)")
                List(store.models, id: \.identifier) {
                    model in
                    Text(model.date!)
                    Text(model.name!)
                    Text(model.image!)
                }
                // ONE room card:
                var image = "ex_room"
                var date = "1/1/23"
                var name = "Dorm1"
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
                }
                .padding()
                .background(Rectangle().foregroundColor(.white).cornerRadius(15).shadow(radius: 15))
                .padding()
            }
        }
    }
}

