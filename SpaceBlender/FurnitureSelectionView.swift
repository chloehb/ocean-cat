//
//  ExchangeView.swift
//  SpaceBlender
//
//  Created by Lisa Wang on 11/29/23.
//

import Foundation
import SwiftUI
import RealityKit
import CoreData
import QuickLook

//// Assuming furnitureModel is defined like this:
//struct FurnitureModel: Identifiable {
//    let id = UUID()
//    let name: String
//    let type: String
//    let url: URL
//}

struct FurnitureRowView: View {
//    var furniture: FurnitureModel
    @ObservedObject var store = furnitureStore.shared
    let index: Int
    @Binding var selectedFurnitureName: String?
    @Binding var showingARQuickLook: Bool

    var body: some View {
        let type = store.models[index].type!
        let name = store.models[index].name!
        let url = store.models[index].url!
        
        
        VStack(alignment: .leading, spacing: 20.0) {
            
            HStack {
                Spacer()
//                            let path = NSString(string: url.absoluteString).expandingTildeInPath
//                            let fileDoesExist = FileManager.default.fileExists(atPath: path)
//                            Text(fileDoesExist.description)
                
                Text(type + " " + name).font(.title).multilineTextAlignment(.center)
//                            Text(url.absoluteString)
                
//                            Text(url_string)
                Spacer()
            }
            
            Button(action: {
                self.showingARQuickLook.toggle()
            }) {
                Text("Preview in AR")
                    .fontWeight(.semibold)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)
            .sheet(isPresented: $showingARQuickLook) {
                ARQuickLookController(modelFile: url, showingARQuickLook: $showingARQuickLook)
            }
        }
        .padding()
        .background(selectedFurnitureName == store.models[index].name ? Color.gray.opacity(0.3) : Color.white)
        .cornerRadius(15)
        .shadow(radius: 15)
        .onTapGesture {
            self.selectedFurnitureName = store.models[index].name // Handle selection
        }
        .padding()
        
    }
//                Button {
//                    isPresentingCaptured.toggle()
//                } label: {
//                    Text("Add a new furniture object")
//                        .padding()
//                        .font(.title3)
//                        .fontWeight(.bold)
//                        .frame(width: 300, height: 70)
//                }
    
}

// Main view that shows the furniture types and list
struct FurnitureSelectionView: View {

    @State private var isPresentingCaptured = false
    @Binding var isPresented: Bool
    @State private var showingARQuickLook = false
    
//    @ObservedObject var store = ModelStore.shared
    let persistenceController = PersistenceController.shared
    @ObservedObject var store = furnitureStore.shared
    @State private var selectedFurnitureName: String?
//    @FetchRequest(sortDescriptors: []) var furnitures: FetchedResults<FurObject>
    
//    let endCaptureCallback: () -> Void
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Furniture Gallery").font(.title)
                Text("There are \(store.models.count) furnitures(s)")
                
                List(0..<store.models.count) { index in
                    FurnitureRowView(index: index, selectedFurnitureName: $selectedFurnitureName, showingARQuickLook: $showingARQuickLook)
                                }
                
//                List(0..<store.models.count) {
//                    index in
////                    let image = "ex_room"
//                    let type = store.models[index].type!
//                    let name = store.models[index].name!
//                    let url = store.models[index].url!
//                    
//                    
//                    VStack(alignment: .leading, spacing: 20.0) {
//                        
//                        HStack {
//                            Spacer()
////                            let path = NSString(string: url.absoluteString).expandingTildeInPath
////                            let fileDoesExist = FileManager.default.fileExists(atPath: path)
////                            Text(fileDoesExist.description)
//                            
//                            Text(type + " " + name).font(.title).multilineTextAlignment(.center)
////                            Text(url.absoluteString)
//                            
////                            Text(url_string)
//                            Spacer()
//                        }
//                        
//                        Button(action: {
//                            self.showingARQuickLook.toggle()
//                        }) {
//                            Text("Preview in AR")
//                                .fontWeight(.semibold)
//                                .frame(minWidth: 0, maxWidth: .infinity)
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(40)
//                                .shadow(radius: 5)
//                        }
//                        .padding(.horizontal)
//                        .sheet(isPresented: $showingARQuickLook) {
//                            ARQuickLookController(modelFile: url, showingARQuickLook: $showingARQuickLook)
//                        }
//                    }
//                    .padding()
//                    .background(selectedFurnitureID == store.models[index].id ? Color.gray.opacity(0.3) : Color.white)
//                    .cornerRadius(15)
//                    .shadow(radius: 15)
//                    .onTapGesture {
//                        self.selectedFurnitureID = store.models[index].id // Handle selection
//                    }
//                    .padding()
//                    
//                }
////                Button {
////                    isPresentingCaptured.toggle()
////                } label: {
////                    Text("Add a new furniture object")
////                        .padding()
////                        .font(.title3)
////                        .fontWeight(.bold)
////                        .frame(width: 300, height: 70)
////                }
//                
//                // Confirm button
//             
                Button("Confirm") {
                    // Handle confirmation action
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
                
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .padding()
            .navigationDestination(isPresented: $isPresentingCaptured) {
//                ContentView()
                FurnitureInputView()
            }
        }
    }
}




//func fileExists(at url: URL) -> Bool {
//    let fileManager = FileManager.default
//    return fileManager.fileExists(atPath: url.path)
//}

private struct ARQuickLookController: UIViewControllerRepresentable {
//    static let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem,
//                                category: "ARQuickLookController")

    let modelFile: URL
//    let endCaptureCallback: () -> Void
    @Binding var showingARQuickLook: Bool

    func makeUIViewController(context: Context) -> QLPreviewControllerWrapper {
        let controller = QLPreviewControllerWrapper()
        controller.qlvc.dataSource = context.coordinator
        controller.qlvc.delegate = context.coordinator
        return controller
    }

    func makeCoordinator() -> ARQuickLookController.Coordinator {
        return Coordinator(parent: self)
    }

    func updateUIViewController(_ uiViewController: QLPreviewControllerWrapper, context: Context) {}

    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: ARQuickLookController

        init(parent: ARQuickLookController) {
            self.parent = parent
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.modelFile as QLPreviewItem
        }

        func previewControllerWillDismiss(_ controller: QLPreviewController) {
//            ARQuickLookController.logger.log("Exiting ARQL ...")
//            parent.endCaptureCallback()
            parent.showingARQuickLook = false
        }
    }
}

private class QLPreviewControllerWrapper: UIViewController {
    let qlvc = QLPreviewController()
    var qlPresented = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !qlPresented {
            present(qlvc, animated: false, completion: nil)
            qlPresented = true
        }
    }
}
