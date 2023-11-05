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
            Spacer()
            Button {
                //isPresentingSelectMethod.toggle()
            } label: {
                Text("Select")
                    .padding()
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 80, height: 38)
            }
            .foregroundColor(.white)
            .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
            .cornerRadius(10)
            .shadow(color: .blue, radius: 3, y: 3)
            .padding()
            Spacer()
        }
        NavigationStack {
            VStack {
                Text("Select Furniture").font(.title)
            }
        }
    }
}

