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
    let index: Int
    @Binding var selectedFurnitureName: String?
    @Binding var selectedURL:URL?
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
            self.selectedFurnitureName = store.models[index].name
            self.selectedURL = store.models[index].url// Handle selection
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
    
    @Environment(\.presentationMode) var presentationMode
//    @ObservedObject var store = ModelStore.shared
    let persistenceController = PersistenceController.shared
    @ObservedObject var store = furnitureStore.shared
    @State private var selectedFurnitureName: String?
    @State private var selectedURL:URL?
//    @State private var selectedNUM = self.store.models.count

    
    //tab area:
    @State private var selectedType: String = "ALL"
    var furnitureType = ["Bed", "Desk", "Others", "waitingForImplement"]
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                
                Text("Furniture Gallery").font(.title)
//                Text("There are \(store.models.count) furnitures(s)")
                
                if selectedType == "ALL" {
                    List(0..<store.models.count) { index in
                        FurnitureRowView(index: index, selectedFurnitureName: $selectedFurnitureName, selectedURL: $selectedURL, showingARQuickLook: $showingARQuickLook)
                                    }
                            } else {
                                List(0..<store.models.count) { index in
                                    if store.models[index].type == selectedType{
                                        FurnitureRowView(index: index, selectedFurnitureName: $selectedFurnitureName, selectedURL: $selectedURL, showingARQuickLook: $showingARQuickLook)
                                    }
                                                }
                    }
                
               
       
                Button("Confirm") {
                    // Handle confirmation action
                    presentationMode.wrappedValue.dismiss()
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
