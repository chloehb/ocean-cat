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
    @State private var isPresentingMoveFurniture = false
    @State private var isPresentingExchange = false
    @State var exchanged = false
    @State var exchanged_url: URL?
    @State var index: Int
    //@Binding var showing: Bool
    @State var selectedName: String? = nil
    @State var showJsonShareSheet = false
    @State var exportJsonUrl: URL?
    @State private var text = ""
    @State private var jsonFileName = "export.json"
    @ObservedObject var store = ModelStore.shared
    @State private var degrees: Float = 0.0
    @State private var x_pos: Float = 0.0
    @State private var z_pos: Float = 0.0
    //    @ObservedObject var viewModel: SceneKitViewModel
    
    @State private var showingAlert = false
    
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
                // if adjustment already exists, load adjustment view
                // todo: use a new way to perform SceneKitView
                if let adj = store.models[index].adjustment {
                    AdjustmentView(index: index, adjustment: adj, options: [], selectedName: $selectedName)
                } else {
                    SceneKitView(index: index, x_pos: $x_pos, z_pos: $z_pos, degrees: $degrees, options: [], selectedName: $selectedName, exchanged: $exchanged, exchanged_url: $exchanged_url)
                        .allowsHitTesting(true)
                        .ignoresSafeArea()
                }
                Spacer()
                VStack() {
                    if let selected = selectedName {
                        VStack {
                            Text(selected)
                            
                            HStack {
                                Button {
                                    showingAlert = true
                                } label: {
                                    Text("exchange furniture model")
                                        .padding()
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .alert(isPresented: $showingAlert) {
                                    Alert(
                                        title: Text("Attention"),
                                        message: Text("Is this the position you want to replace the white box？"),
                                        primaryButton: .destructive(Text("NO")),
                                        secondaryButton: .default(Text("Yes"), action: {
                                            isPresentingExchange = true
                                        })
                                    )
                                }
                                .foregroundColor(.white)
                                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                                .cornerRadius(20)
                                .shadow(color: .blue, radius: 3, y: 3)
                                .padding()
                            }
                            
                            HStack {
                                Spacer()
                                Text("X-axis:")
                                Spacer()
                                Slider(value: $x_pos, in: -5...5
                                ).padding()
                                    .tint(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.6))
                                    .frame(width:280)
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Text("Z-axis:")
                                Spacer()
                                Slider(value: $z_pos, in: -5...5
                                ).padding()
                                    .tint(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.6))
                                    .frame(width:280)
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Text("Rotation:")
                                Spacer()
                                Slider(value: $degrees, in: 0...270
                                ).padding()
                                    .tint(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.6))
                                    .frame(width:280)
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation {
                                        self.degrees -= 90
                                    }
                                } label: {
                                    Image("ccwise")
                                        .padding()
                                        .frame(width: 60.0, height: 60.0)
                                }
                                .foregroundColor(.white)
                                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                                .cornerRadius(20)
                                .shadow(color: .blue, radius: 3, y: 3)
                                .padding()
                                Button {
                                    withAnimation {
                                        self.degrees += 90
                                    }
                                } label: {
                                    Image("cwise")
                                        .padding()
                                        .frame(width: 60.0, height: 60.0)
                                }
                                .foregroundColor(.white)
                                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                                .cornerRadius(20)
                                .shadow(color: .blue, radius: 3, y: 3)
                                Spacer()
                            }
                        }
                    } else {
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
                    
                }
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
            .navigationDestination(isPresented: $isPresentingRoomGallery) {
                RoomGalleryView()
            }
            .navigationDestination(isPresented: $isPresentingRequestSurvey) {
                RequestSurveyView(isPresented: $isPresentingRequestSurvey, index: index)
            }
            .navigationDestination(isPresented: $isPresentingMoveFurniture) {
                MoveFurnitureView()
            }
            .sheet(isPresented: $isPresentingExchange, onDismiss: {
                exchanged = false
            }) {
                FurnitureSelectionView(exchanged: $exchanged, exchanged_url: $exchanged_url, isPresented: $isPresentingExchange, x_pos: $x_pos, z_pos: $z_pos, degrees: $degrees, selectedName: $selectedName, index: $index)
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
