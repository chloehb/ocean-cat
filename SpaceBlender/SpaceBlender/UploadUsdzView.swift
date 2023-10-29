//
//  UploadUsdzView.swift
//  SpaceBlender
//
//  Created by akai on 10/29/23.
//

import SwiftUI
import RoomPlan

import UIKit
import MobileCoreServices

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeText)], in: .import)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ pickerController: DocumentPicker) {
            self.parent = pickerController
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.fileURL = url
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
    }
}

struct UploadUsdzView: View {
    @State private var fileURL: URL?
    @State private var showDocumentPicker = false
    
    var body: some View {
        VStack {
            Button("Open Document Picker") {
                showDocumentPicker = true
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(fileURL: $fileURL)
        }
    }
}
