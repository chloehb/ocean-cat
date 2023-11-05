//
//  RequestSurveyView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 11/5/23.
//

import Foundation
import SwiftUI

struct RequestSurveyView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    @State private var isPresentingSurvey = false
    @State private var isPresentingEditModel = false
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                // rgb: 168, 182, 234
                Text("Would you like to receive a recommended room layout?")
                    .multilineTextAlignment(.center)
                    .padding()
                    .font(.largeTitle)
                    .frame(width: 300, height: 300)
                Button {
                    isPresentingSurvey.toggle()
                } label: {
                    Text("Yes")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 250, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                Button {
                    isPresentingEditModel.toggle()
                } label: {
                    Text("No")
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
            .navigationDestination(isPresented: $isPresentingSurvey) {
                SurveyView(isPresented: $isPresentingSurvey)
            }
            .navigationDestination(isPresented: $isPresentingEditModel) {
                EditModelView(isPresented: $isPresentingEditModel)
            }
        }

    }
}
