/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A wrapper for AR QuickLook viewer that shows the reconstructed USDZ model
 file directly.
*/

import ARKit
import QuickLook
import SwiftUI
import UIKit
import os
import CoreData


struct CaptureModelView: View {
//   @Environment(\.managedObjectContext) var moc
   @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store = furnitureStore.shared
//    @FetchRequest(sortDescriptors: []) var furnitures: FetchedResults<FurObject>
    let modelFile: URL
    @State private var showingARQuickLook = false
//    @State private var backtomain = false
    
    let endCaptureCallback: () -> Void
    
    @Binding var name: String
    @Binding var selectFurniture: String
    

    var body: some View {
        // Add a button to the view
        // Add a button to present the AR Quick Look
        VStack{
            
        }
        
        // test
        
        .onAppear(){
            print("Name: \(name)")
            print("Selected Furniture: \(selectFurniture)")
            print("output: \(modelFile)")
            print("Start Saving in data")
//            let context = PersistenceController.shared.container.viewContext
//            let object = FurObject(context: context)
//            object.name = name
//            object.type = selectFurniture
//            object.url = modelFile
//            do {
//                try context.save()
//            } catch {
//                // Handle the error
//                print("Not saved properly")
//            }
            store.addNewModel(furnitureModel(name: name, type: selectFurniture, url: modelFile))
        }
        //test
        
        
        Text("Your model is automatically saved to the furniture gallery.")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top)
        
        
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
            ARQuickLookController(modelFile: modelFile, endCaptureCallback: endCaptureCallback, showingARQuickLook: $showingARQuickLook)
        }
        

        Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//            backtomain.toggle()
            endCaptureCallback()
        }) {
            Text("Scan again")
                .fontWeight(.semibold)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(40)
                .shadow(radius: 5)
        }
        .padding(.horizontal)
//        .navigationDestination(isPresented: $backtomain) {
//            MainView()
//        }
    }
    
    // Here's the new function to set showingARQuickLook to false.
    private func dismissARQuickLook() {
        self.showingARQuickLook = false
    }
}

private struct ARQuickLookController: UIViewControllerRepresentable {
//    static let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem,
//                                category: "ARQuickLookController")

    let modelFile: URL
    let endCaptureCallback: () -> Void
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
