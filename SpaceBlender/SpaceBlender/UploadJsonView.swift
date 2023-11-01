//
//  UploadUsdzView.swift
//  SpaceBlender
//
//  Created by akai on 10/29/23.
//

import SwiftUI
import RoomPlan
import UniformTypeIdentifiers

func loadCapturedRoomFromJSONFile(filePath: URL) -> CapturedRoom? {
    do {
        let jsonData = try Data(contentsOf: filePath)
//        if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//            print(jsonObject)
//            print(jsonObject["version"] ?? "no version")
//        }
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            let decoder = JSONDecoder()
//            print(jsonString)
            let capturedRoom = try decoder.decode(CapturedRoom.self, from: jsonData)
            
            return capturedRoom
        } else {
            print("Can't load string")
            return nil
        }
    } catch {
        print("Error loading JSON file: \(error)")
        return nil
    }
}

struct UploadUsdzView: View {
    @State private var showDocumentPicker = false
    @ObservedObject var store = ModelStore.shared
    
    var body: some View {
        VStack {
            
            Button("Select json file") {
                showDocumentPicker = true
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
