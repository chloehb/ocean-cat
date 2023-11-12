//
//  FurnitureScanOnboarding.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 11/5/23.
//

import Foundation
import SwiftUI

struct FurnitureScanView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Furniture Scan").font(.title)
                Spacer()
                NavigationLink {
                    ScanningView()
                } label: {
                    Text("Start Scan")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
            }
        }
    }
}
