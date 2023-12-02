//
//  SelectMethodView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 10/29/23.
//

import Foundation
import SwiftUI

struct SelectMethodView: View {
    @ObservedObject var store = ModelStore.shared
    @State private var isPresentingOnBoarding = false
    @State private var isPresentingMainView = false
    @State private var isPresentingUploadFile = false
    
    var body: some View {
//        HStack {
//            Button {
//                isPresentingMainView.toggle()
//            } label: {
//                Text("Back")
//                    .padding()
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .frame(width: 80, height: 38)
//            }
//            .foregroundColor(.white)
//            .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
//            .cornerRadius(10)
//            .shadow(color: .blue, radius: 3, y: 3)
//            .padding()
//            Spacer()
//        }
//        .navigationDestination(isPresented: $isPresentingMainView) {
//            MainView(isPresented: $isPresentingMainView)
//        }
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                // rgb: 168, 182, 234
                Text("Choose a way to generate your room model")
                    .multilineTextAlignment(.center)
                    .padding()
                    .font(.largeTitle)
                    .frame(width: 300, height: 300)
                Button {
                    isPresentingOnBoarding.toggle()
                } label: {
                    Text("3D Scan")
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
                    isPresentingUploadFile.toggle()
                } label: {
                    Text("Upload File")
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
            .navigationDestination(isPresented: $isPresentingOnBoarding) {
                OnBoardingView(isPresented: $isPresentingOnBoarding)
            }
            .navigationDestination(isPresented: $isPresentingUploadFile) {
                UploadFileView(isPresented: $isPresentingUploadFile)
            }
        }

    }
}
