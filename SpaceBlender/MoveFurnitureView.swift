//
//  MoveFurnitureView.swift
//  RotationTutorial
//
//  Created by Chloe Bentley on 11/21/23.
//

import SwiftUI
import SceneKit

struct MoveFurnitureView: View {
    @State private var degrees = 0.0
    @State private var x_pos = 25.0
    @State private var z_pos = 25.0
    // this section below is just for testing -> displays cube instead of linking to furniture object
    var scene = SCNScene(named: "TestScene.scn")
    var cameraNode: SCNNode? {
        scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    var object: SCNNode? {
        scene?.rootNode.childNode(withName: "box", recursively: false)
    }
    
    var body: some View {
        VStack {
            Spacer()
            SceneView(
                scene: scene,
                pointOfView: cameraNode,
                options: [.allowsCameraControl]
                
            )
            .frame(width:400, height: 400)
//            object?.worldPosition = SCNVector3((object?.worldPosition.x ?? 0.0) + Float(x_pos), object?.worldPosition.y ?? 0.0, (object?.worldPosition.z ?? 0.0) + Float(z_pos))
            //object?.worldOrientation =
            
            LinearGradient(gradient:Gradient(colors:[.yellow,.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(width:200, height: 100)
                .cornerRadius(10)
                .rotation3DEffect(.degrees(degrees), axis: (x: 0, y: 1, z: 0))
            Spacer()
            HStack {
                VStack {
                    Spacer()
                    Text("X-axis:")
                    Spacer()
                    Text("Z-axis:")
                    Spacer()
                    Text("Rotation:")
                    Spacer()
                }
                VStack {
                    Slider(value: $x_pos, in: 0...50
                    ).padding()
                    Slider(value: $z_pos, in: 0...50
                    ).padding()
                    Slider(value: $degrees, in: 0...270
                    ).padding()
                    
                }
                
            }
            HStack {
                Button {
                    withAnimation {
                        self.degrees -= 90
                    }
                } label: {
                    Text("Rotate -90")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 145, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
                Button {
                    withAnimation {
                        self.degrees += 90
                    }
                } label: {
                    Text("Rotate 90")
                        .padding()
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 145, height: 70)
                }
                .foregroundColor(.white)
                .background(Color(red:0.3, green:0.4, blue:0.7, opacity: 0.3))
                .cornerRadius(20)
                .shadow(color: .blue, radius: 3, y: 3)
            }
        }
        .padding()
    }
}

#Preview {
    MoveFurnitureView()
}
