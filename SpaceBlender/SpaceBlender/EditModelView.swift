//
//  EditModelView.swift
//  SpaceBlender
//
//  Created by Chloe Bentley on 11/5/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct EditModelView: View {
    @State private var isPresentingRoomGallery = false
    @State private var isPresentingRequestSurvey = false
    @State private var isPresentingSelectFurniture = false
    @State var index: Int
    //@Binding var showing: Bool
    @State var selectedName: String? = nil
    @State var showJsonShareSheet = false
    @State var exportJsonUrl: URL?
    @State private var text = ""
    @State private var jsonFileName = "export.json"
    @ObservedObject var store = ModelStore.shared
    
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
                Spacer()
                SceneKitView(index: index, options: [], selectedName: $selectedName)
                    .allowsHitTesting(true)
                
                    .ignoresSafeArea()
                
                Spacer()
                VStack() {
                    Button {
                        isPresentingRequestSurvey.toggle()
                    } label: {
                        Text("Auto-Layout")
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
                    Spacer()
                    Button {
                        isPresentingSelectFurniture.toggle()
                    } label: {
                        Text("Select Furniture")
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
                    Spacer()
                    Button {
                        isPresentingRoomGallery.toggle()
                    } label: {
                        Text("Save to Gallery")
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
                    Spacer()
                    Button {
                        exportJson()
                        DispatchQueue.global().async {
                            // After the work is done, switch back to the main thread
                            DispatchQueue.main.async {
                                showJsonShareSheet = true
                            }
                        }
                    } label: {
                        Text("Export Json File")
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
                Spacer()
            }
            .navigationDestination(isPresented: $isPresentingRoomGallery) {
                RoomGalleryView(isPresented: $isPresentingRoomGallery)
            }
            .navigationDestination(isPresented: $isPresentingRequestSurvey) {
                RequestSurveyView(isPresented: $isPresentingRequestSurvey, index: 0)
            }
            .navigationDestination(isPresented: $isPresentingSelectFurniture) {
                SelectFurnitureView(isPresented: $isPresentingSelectFurniture)
            }
        }

    }
}

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
