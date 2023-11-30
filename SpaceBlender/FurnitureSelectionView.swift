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




struct FurnitureRowView: View {
//    var furniture: FurnitureModel
    @ObservedObject var store = furnitureStore.shared
    var id: Int
    @Binding var selectedFurniture: furnitureModel?
    @Binding var selectedFurnitureName: String?
    @Binding var selectedURL:URL?
    @Binding var showingARQuickLook: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            let type = store.models[id].type!
            let name = store.models[id].name!
            let url = store.models[id].url!
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
            
//            Button(action: {
//                self.showingARQuickLook.toggle()
//            }) {
//                Text("Preview in AR")
//                    .fontWeight(.semibold)
//                    .frame(minWidth: 0, maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(40)
//                    .shadow(radius: 5)
//            }
//            .padding(.horizontal)
//            .sheet(isPresented: $showingARQuickLook) {
//                ARQuickLookController(modelFile: url, showingARQuickLook: $showingARQuickLook)
//            }
        }
        .onTapGesture {
            self.selectedFurniture = store.models[id] // Handle selection
            self.selectedFurnitureName = store.models[id].name
//            self.selectedURL = store.models[index].url// Handle selection
        }
        .padding()
        .cornerRadius(15)
        .shadow(radius: 15)
        .background(self.selectedFurnitureName == store.models[id].name ? Color.gray.opacity(0.3) : Color.white)
        .padding()
        
    }
    
}

// Main view that shows the furniture types and list
struct FurnitureSelectionView: View {
    @Binding var exchanged: Bool
    @Binding var exchanged_url: URL?
    @State private var isPresentingCaptured = false
    @Binding var isPresented: Bool
    @Binding var x_pos: Float
    @Binding var z_pos: Float
    @Binding var degrees: Float
    @Binding var selectedName: String?
    @Binding var index: Int
    @State private var showingARQuickLook = false
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store = furnitureStore.shared
    @State private var selectedFurniture: furnitureModel?
    @State private var selectedFurnitureName: String?
//    @State private var selectedNUM = self.store.models.count
    @State private var selectedURL:URL?

    let persistenceController = PersistenceController.shared

    
    //tab area:
    @State private var selectedType = "ALL"
    var furnitureType = ["Bed", "Desk", "Others", "waitingForImplement"]
    
    var body: some View {
        NavigationStack {
            VStack {
                
                
                Text("Furniture Gallery").font(.title)
                
//                Text("There are \(store.models.count) furnitures(s)")
                
                if selectedType == "ALL" {
                    List(0..<store.models.count) { id in
                        FurnitureRowView(id: id,selectedFurniture: $selectedFurniture, selectedFurnitureName: $selectedFurnitureName, selectedURL: $selectedURL, showingARQuickLook: $showingARQuickLook)
                                    }
                            } else {
                                List(0..<store.models.count) { id in
                                    if store.models[index].type == selectedType{
                                        FurnitureRowView(id: id, selectedFurniture: $selectedFurniture, selectedFurnitureName: $selectedFurnitureName, selectedURL: $selectedURL, showingARQuickLook: $showingARQuickLook)
                                    }
                                                }
                    }
                Button("Confirm") {
//                    var scene_view = SceneKitView(index: index, x_pos: $x_pos, z_pos: $z_pos, degrees: $degrees, options: [], selectedName: $selectedName)
                    exchanged = true
//                    print(scene_view.exchanged)
                    exchanged_url = (selectedFurniture?.url)!
//                    self.isPresented = false
                    presentationMode.wrappedValue.dismiss() }
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
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Bed") { selectedType = "Bed" }
                        Spacer()
                        Button("Desk") { selectedType = "Desk" }
                        Spacer()
                        Button("ALL") { selectedType = "ALL" }
                        Spacer()
                        Button("Others") { selectedType = "Others" }
                        Spacer()
                        Button("Implement") { selectedType = "Implement" }
                    }
                    .padding(.horizontal) // Optional, for padding on the sides
                }
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
