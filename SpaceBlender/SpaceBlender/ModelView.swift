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

struct TextDocument: FileDocument {
    var text: String = ""
    
    init(_ text: String = "") {
        self.text = text
    }
    
    static public var readableContentTypes: [UTType] =
    [.json]
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    func fileWrapper(configuration: WriteConfiguration)
    throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

struct MinimalDemoView: View {
    @Binding var showing: Bool
    @State var selectedName: String? = nil
    @ObservedObject var store = ModelStore.shared
    //    @State var showUsdzShareSheet = false
    @State var showJsonShareSheet = false
    //    @State var exportUsdzUrl: URL?
    @State var exportJsonUrl: URL?
    //    @State var shareableUrl: URL?
    @State private var text = ""
    @State private var jsonFileName = "export.json"
    
    func exportJson() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional, for pretty-printed JSON
            if let firstModel = store.models.first { // todo: only the first model
                let jsonData = try encoder.encode(firstModel.model)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print(jsonString)
//                    exportJsonUrl = FileManager.default.temporaryDirectory.appending(path: "\(firstModel.name ?? "scan").json")
                    jsonFileName = "\(firstModel.name ?? "export").json"
                    text = jsonString
//                    try firstModel.model?.export(to: exportJsonUrl!)
                }
            } else {
                print("No model")
                return
            }
        } catch {
            print("Error exporting json.")
            return
        }
    }
    
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
