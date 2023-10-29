//
//  UploadUsdzView.swift
//  SpaceBlender
//
//  Created by akai on 10/29/23.
//

import SwiftUI
import SceneKit

import UIKit
import MobileCoreServices

import UniformTypeIdentifiers

struct UploadUsdzView: View {
    @State private var fileURL: URL?
    @State private var showDocumentPicker = false
    
    var body: some View {
        VStack {
            Button("Open Document Picker") {
                showDocumentPicker = true
            }.fileImporter(isPresented: $showDocumentPicker, allowedContentTypes: [UTType.usdz], allowsMultipleSelection: false) {
                result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        print("Selected URLs: \(url)")
                        do {
                            let scene = try SCNScene(url: url, options: nil)
                            let rootNode = scene.rootNode
                            for cNode in rootNode.childNodes {
                                print(cNode.name ?? "no name")
                            }
                        } catch {
                            print("Error loading USDZ file: \(error.localizedDescription)")
                        }
                    } else {
                        print("Empty URLS")
                    }
                case .failure(let error):
                    print("File picker error: \(error.localizedDescription)")
                }
            }
        }
    }
}
