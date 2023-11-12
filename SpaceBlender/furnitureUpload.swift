import SwiftUI
import QuickLook

struct furnitureUpload: View {
    @Binding var name: String
    @Binding var selectFurniture: String
    @State private var showingARQuickLook = false
    
    @ObservedObject var store = furnitureStore.shared
    
     @State var fileName = "no file chosen"
     @State var openFile = false
     @State var fileURL : URL?
 
    var body: some View {
        VStack(spacing: 25){
        
            Text(self.fileName)
            
            Button {
                self.openFile.toggle()
            } label: {
                Text("Import your furniture and saved")
            }
            Spacer()
            
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
                ARQuickLookController(modelFile: fileURL ?? nil, showingARQuickLook: $showingARQuickLook)
            }
            
        }
        
        .fileImporter( isPresented: $openFile, allowedContentTypes: [.usdz], allowsMultipleSelection: false, onCompletion: {
            (Result) in
            
            do{
                let fileURLs = try Result.get()
                fileURL = fileURLs[0]
                print(fileURL)
                self.fileName = fileURL.first?.lastPathComponent ?? "file not available"
                store.addNewModel(furnitureModel(name: name, type: selectFurniture, url: fileURL))
//                Text("successfully saved")
                
            }
            catch{
               print("error reading file \(error.localizedDescription)")
            }
            
        })
       
    }
}


private struct ARQuickLookController: UIViewControllerRepresentable {
//    static let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem,
//                                category: "ARQuickLookController")

let modelFile: URL
//let endCaptureCallback: () -> Void
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
