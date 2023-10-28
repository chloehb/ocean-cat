//
//  ModelViewController.swift
//  SpaceBlender
//
//  Created by akai on 10/22/23.
//


import SceneKit
import SwiftUI


struct SceneKitView: UIViewRepresentable {
    @ObservedObject var store = ModelStore.shared
    
    var scene = SCNScene()
    var options: [Any]
    var view = SCNView()
    
    func makeUIView(context: Context) -> SCNView {
        view.scene = scene
        view.allowsCameraControl = true
        
        scene.background.contents = Color.black
        let roomScan = store.models[0].model!
        
        // add all walls
        for i in 0...(roomScan.walls.endIndex-1) {
            
            //Generate new wall geometry
            let scannedWall = roomScan.walls[i]
            
            let length = 0.2
            let width = scannedWall.dimensions.x
            let height = scannedWall.dimensions.y
            let newWall = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(length),
                chamferRadius: 0
            )
            
            newWall.firstMaterial?.diffuse.contents = UIColor.red
            newWall.firstMaterial?.transparency = 1
            
            //Generate new SCNNode
            let newNode = SCNNode(geometry: newWall)
            newNode.simdTransform = scannedWall.transform
            
            scene.rootNode.addChildNode(newNode)
        }
        // all floors
        for i in 0...(roomScan.floors.endIndex-1) {
            
            //Generate new wall geometry
            let scannedFloor = roomScan.floors[i]
            
            let length = 0.2
            let width = scannedFloor.dimensions.x
            let height = scannedFloor.dimensions.y
            let newFloor = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(length),
                chamferRadius: 0
            )
            
            newFloor.firstMaterial?.diffuse.contents = UIColor.blue
            newFloor.firstMaterial?.transparency = 1
            
            //Generate new SCNNode
            let newNode = SCNNode(geometry: newFloor)
            newNode.simdTransform = scannedFloor.transform
            
            scene.rootNode.addChildNode(newNode)
        }
        
        for i in 0...(roomScan.objects.endIndex-1) {
            
            //Generate new wall geometry
            let scannedObject = roomScan.objects[i]
            
            let length = scannedObject.dimensions.z
            let width = scannedObject.dimensions.x
            let height = scannedObject.dimensions.y
            let newObject = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(length),
                chamferRadius: 0
            )
            
            newObject.firstMaterial?.diffuse.contents = UIColor.green
            newObject.firstMaterial?.transparency = 1
            
            //Generate new SCNNode
            let newNode = SCNNode(geometry: newObject)
            newNode.simdTransform = scannedObject.transform
            
            scene.rootNode.addChildNode(newNode)
        }
        
        // Create directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light!.type = .directional
        directionalLight.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
        
        let myAmbientLight = SCNLight()
        myAmbientLight.type = .ambient
        myAmbientLight.intensity = 100
        let myAmbientLightNode = SCNNode()
        myAmbientLightNode.light = myAmbientLight
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 10, y: 10, z: 10)
        let centerConstraint = SCNLookAtConstraint(target: scene.rootNode.childNodes[0])
        cameraNode.constraints = [centerConstraint]
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(directionalLight)
        scene.rootNode.addChildNode(myAmbientLightNode)
        
//        let panRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        
        // Add gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        
        view.addGestureRecognizer(tapGesture)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update your 3D scene here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view)
    }
    
    class Coordinator: NSObject {
        private let view: SCNView
        init(_ view: SCNView) {
            self.view = view
            super.init()
        }
        
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            // check what nodes are tapped
            let p = gestureRecognize.location(in: view)
            let hitResults = view.hitTest(p, options: [:])
            
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                
                // retrieved the first clicked object
                let result = hitResults[0]
         
                // get material for selected geometry element
                let material = result.node.geometry!.materials[(result.geometryIndex)]
                
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                // on completion - unhighlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    
                    material.emission.contents = UIColor.black
                  
                    SCNTransaction.commit()
                }
                material.emission.contents = UIColor.green
                SCNTransaction.commit()
            }
        }
    }
}

/*
class MinimalDemo: ObservableObject {
    // now we only render the first room object
    @ObservedObject var store = ModelStore.shared
    
    let name: String
    let description: String
    
    let iconName = "circlebadge"
    
    var scene: SCNScene = SCNScene()
    
    var target_node: SCNNode? = nil
    
    init(
        name: String,
        description: String
    ) {
        self.name = name
        self.description = description
        
        scene.background.contents = Color.black
        let roomScan = store.models[0].model!
        
        // add all walls
        for i in 0...(roomScan.walls.endIndex-1) {
            
            //Generate new wall geometry
            let scannedWall = roomScan.walls[i]
            
            let length = 0.2
            let width = scannedWall.dimensions.x
            let height = scannedWall.dimensions.y
            let newWall = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(length),
                chamferRadius: 0
            )
            
            newWall.firstMaterial?.diffuse.contents = UIColor.red
            newWall.firstMaterial?.transparency = 1
            
            //Generate new SCNNode
            let newNode = SCNNode(geometry: newWall)
            newNode.simdTransform = scannedWall.transform
            
            scene.rootNode.addChildNode(newNode)
        }
        // all floors
        for i in 0...(roomScan.floors.endIndex-1) {
            
            //Generate new wall geometry
            let scannedFloor = roomScan.floors[i]
            
            let length = 0.2
            let width = scannedFloor.dimensions.x
            let height = scannedFloor.dimensions.y
            let newFloor = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(length),
                chamferRadius: 0
            )
            
            newFloor.firstMaterial?.diffuse.contents = UIColor.blue
            newFloor.firstMaterial?.transparency = 1
            
            //Generate new SCNNode
            let newNode = SCNNode(geometry: newFloor)
            newNode.simdTransform = scannedFloor.transform
            
            scene.rootNode.addChildNode(newNode)
        }
        
        for i in 0...(roomScan.objects.endIndex-1) {
            
            //Generate new wall geometry
            let scannedObject = roomScan.objects[i]
            
            let length = scannedObject.dimensions.z
            let width = scannedObject.dimensions.x
            let height = scannedObject.dimensions.y
            let newObject = SCNBox(
                width: CGFloat(width),
                height: CGFloat(height),
                length: CGFloat(length),
                chamferRadius: 0
            )
            
            newObject.firstMaterial?.diffuse.contents = UIColor.green
            newObject.firstMaterial?.transparency = 1
            
            //Generate new SCNNode
            let newNode = SCNNode(geometry: newObject)
            newNode.simdTransform = scannedObject.transform
            
            scene.rootNode.addChildNode(newNode)
            target_node = newNode
        }
        // Create directional light
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light!.type = .directional
        directionalLight.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
        
        let myAmbientLight = SCNLight()
        myAmbientLight.type = .ambient
        myAmbientLight.intensity = 100
        let myAmbientLightNode = SCNNode()
        myAmbientLightNode.light = myAmbientLight
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 10, y: 10, z: 10)
        let centerConstraint = SCNLookAtConstraint(target: target_node)
        cameraNode.constraints = [centerConstraint]
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(directionalLight)
        scene.rootNode.addChildNode(myAmbientLightNode)
        //        scene.rootNode.addChildNode(sphereNode1)
        //        scene.rootNode.addChildNode(sphereNode2)
    }
}
*/
