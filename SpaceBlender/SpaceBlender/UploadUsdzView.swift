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

struct ModelPreview: UIViewRepresentable {
    @Binding var fileURL: URL?
    
    var view = SCNView()
    func makeUIView(context: Context) -> SCNView {
        if let scene = try? SCNScene(url: fileURL!, options: nil) {
            view.scene = scene
            let newFloor = SCNBox(
                width: CGFloat(5),
                height: CGFloat(5),
                length: CGFloat(0.2),
                chamferRadius: 0
            )
            
            newFloor.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
            newFloor.firstMaterial?.transparency = 1
            
            //Generate new SCNNode
            let newNode = SCNNode(geometry: newFloor)
            view.scene?.rootNode.addChildNode(newNode)
            print("load scene success")
        } else {
            print("can't load scene")
        }
        
        // Set up camera and lighting (adjust as needed)
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 5, y: 5, z: 5)
        view.scene?.rootNode.addChildNode(cameraNode)

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.5, alpha: 1.0)
        view.scene?.rootNode.addChildNode(ambientLight)
        view.allowsCameraControl = true
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update your 3D scene here
        print("update called")
    }
}

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
//                        do {
//                            let scene = try SCNScene(url: url, options: nil)
//                            let rootNode = scene.rootNode
//                            for cNode in rootNode.childNodes {
//                                print(cNode.name ?? "no name")
//                            }
//                        } catch {
//                            print("Error loading USDZ file: \(error.localizedDescription)")
//                        }
                        fileURL = url
                    } else {
                        print("Empty URLS")
                    }
                case .failure(let error):
                    print("File picker error: \(error.localizedDescription)")
                }
            }
            if let existUrl = fileURL {
                ModelPreview(fileURL: $fileURL)
            } else {
                Text("not upload yet")
            }
        }
    }
}
