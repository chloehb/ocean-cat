//
//  TestView.swift
//  SpaceBlender
//
//  Created by akai on 10/20/23.
//

import Foundation
import SwiftUI
import SceneKit

struct MinimalDemoView: View {
    @Binding var showing: Bool
    @State var selectedName: String? = nil
    
    var body: some View {
        ZStack {
            
            // Scene itself
            SceneKitView(options: [], selectedName: $selectedName)
            .allowsHitTesting(true)
            
            .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Bottom Center Panel
                HStack(alignment: .bottom) {
                    VStack {
                        Button {
                            print(selectedName ?? "nil")
                        } label: {
                            Text("test selectedName")
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(30)
                    
                    Spacer()
                }
            }
            .padding()
        }
    }
}

struct ModelView: View {
    @ObservedObject var store = ModelStore.shared
    @State private var isPresentingDemo = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Space Blender-model view").font(.title)
                Text("There are \(store.models.count) model(s)")
                Spacer().frame(height: 40)
                Spacer().frame(height: 40)
                NavigationLink(destination: MainView(), label: {Text("Back to MainView")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
                NavigationLink(destination: MinimalDemoView(showing: $isPresentingDemo), label: {Text("Test Model View")}).simultaneousGesture(TapGesture().onEnded{
                    isPresentingDemo.toggle()
                    // todo: need to specify which room model is shown, currently, always the first one
                }).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2)
            }
        }
    }
}
