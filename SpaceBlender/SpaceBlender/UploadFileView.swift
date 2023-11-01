//
//  UploadFileView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 10/29/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import RoomPlan

func loadCapturedRoomFromJSONFile(filePath: URL) -> CapturedRoom? {
    do {
        let jsonData = try Data(contentsOf: filePath)
        let decoder = JSONDecoder()
        let capturedRoom = try decoder.decode(CapturedRoom.self, from: jsonData)
        
        return capturedRoom
    } catch {
        print("Error loading JSON file: \(error)")
        return nil
    }
}
struct UploadFileView: View {
    @Binding var isPresented: Bool
    @ObservedObject var store = ModelStore.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDocumentPicker = false
    var body: some View {
//        HStack {
//            Button {
//                //isPresentingSelectMethod.toggle()
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
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                // rgb: 168, 182, 234
                Image("file_upload")
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fit/*@END_MENU_TOKEN@*/)
                    .padding(.all)
                Button {
                    showDocumentPicker.toggle()
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
            }.fileImporter(isPresented: $showDocumentPicker, allowedContentTypes: [UTType.json], allowsMultipleSelection: false) {
                result in
                switch result {
                case .success(let urls):
                    
                    if let url = urls.first {
                        // Securely access the URL to save a bookmark
                        guard url.startAccessingSecurityScopedResource() else {
                            // Handle the failure here.
                            print("fail to get access to \(url)")
                            return
                        }
                        
                        // We have to stop accessing the resource no matter what
                        defer { url.stopAccessingSecurityScopedResource() }
                        //                        print("Selected URLs: \(url)")
                        let fileName = url.lastPathComponent
                        let addCapturedRoom = loadCapturedRoomFromJSONFile(filePath: url)
                        store.addNewModel(RoomModel(identifier: addCapturedRoom?.identifier, name: fileName, model: addCapturedRoom, date: Date().formatted()))
                        dismiss() // todo: after upload file, go back to the home page or room gallery page
                    } else {
                        print("Empty URLS")
                    }
                case .failure(let error):
                    print("File picker error: \(error.localizedDescription)")
                }
            }
        }

    }
}
