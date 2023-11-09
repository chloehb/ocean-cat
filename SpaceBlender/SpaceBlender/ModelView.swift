//
//  TestView.swift
//  SpaceBlender
//
//  Created by akai on 10/20/23.
//

import Foundation
import SwiftUI
import SceneKit
import MobileCoreServices
import UniformTypeIdentifiers
import RoomPlan

// This file is not used now.


struct MinimalDemoView: View {
    @State var index: Int
    //@Binding var showing: Bool
    @State var selectedName: String? = nil
    @ObservedObject var store = ModelStore.shared
    //    @State var showUsdzShareSheet = false
    @State var showJsonShareSheet = false
    //    @State var exportUsdzUrl: URL?
    @State var exportJsonUrl: URL?
    //    @State var shareableUrl: URL?
    @State private var text = ""
    @State private var jsonFileName = "export.json"
    @State private var isPresentingSurvey = false
    func exportJson() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(store.models[index].model)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                jsonFileName = "\(store.models[index].name ?? "export").json"
                text = jsonString
            }
        } catch {
            print("Error exporting json.")
            return
        }
    }
    
//    func modifyCapturedRoom() {
//        do {
//            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted // Optional, for pretty-printed JSON
//            let jsonData = try encoder.encode(store.models[index].model)
//            if var jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//                // Successfully decoded the JSON - print it out
////                print(jsonDictionary)
//                if var objects = jsonDictionary["objects"] {
//                    
//                }
//            }
//        } catch {
//            print("Error exporting json.")
//            return
//        }
//    }
//    
    var body: some View {
        ZStack {
            
            // Scene itself
            SceneKitView(index: index, options: [], selectedName: $selectedName)
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
                        Button {
                            exportJson()
                            DispatchQueue.global().async {
                                // After the work is done, switch back to the main thread
                                DispatchQueue.main.async {
                                    showJsonShareSheet = true
                                }
                            }
                            
                        } label: {
                            Label("Export file", systemImage: "square.and.arrow.up")
                        }
                    }
                    .foregroundColor(.primary)
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(30)
                    .fileExporter(isPresented: $showJsonShareSheet,
                                  document: TextDocument(text),
                                  contentType: .json,
                                  defaultFilename: jsonFileName) { result in
                        if case .failure(let error) = result {
                            print(error)
                        }
                    }
                    
                    Spacer()
                }
//                NavigationLink(destination: SurveyView(isPresented: $isPresentingSurvey, index: index), label: {Text("Auto-layout")}).buttonStyle(.borderedProminent).cornerRadius(40).font(.title2).padding()
            }
            .padding()
        }
    }
}

