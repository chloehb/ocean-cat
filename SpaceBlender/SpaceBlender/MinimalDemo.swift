//
//  ModelViewController.swift
//  SpaceBlender
//
//  Created by akai on 10/22/23.
//
// some ideas (todo list)
// 1. change the effect of tap to highlight the selected furniture and show an additional memu
// 2. based on 1, add explict arrows to the movable object and use the arrow to move objects
// 3. add collision boundaries
// 4. store the result of moving objects
// 5. add another pan gesture as a way to rotate camera at z-axis, i.e. if two fingers, do this.
// 6. lower the transparency of walls which blocks the view of furniture objects

import SceneKit
import SwiftUI

private var NodeTypeKey: UInt8 = 0 // We need this to make our new property

extension SCNNode {
    enum State {
        case UnSelected
        case Selected
    }
    var state: State? {
        get {
            return objc_getAssociatedObject(self, &NodeTypeKey) as? State
        }
        set(newNodeType) {
            objc_setAssociatedObject(self, &NodeTypeKey, newNodeType, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


struct SceneKitView: UIViewRepresentable {
    @ObservedObject var store = ModelStore.shared
    // the id of selected Node
    
    var scene = SCNScene()
    var options: [Any]
    var view = SCNView()
    @Binding var selectedName: String?
    
    func makeUIView(context: Context) -> SCNView {
        view.scene = scene
        // Disable the default camera control
//        view.allowsCameraControl = true
        
        scene.background.contents = Color.black
        scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
        
        let roomScan = store.models[0].model!
        
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
            newNode.movabilityHint = .fixed
            newNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: newNode))
            newNode.physicsBody?.categoryBitMask = roomScan.objects.endIndex
            for j in 0...(roomScan.objects.endIndex-1) {
                newNode.physicsBody?.collisionBitMask = j
            }
            scene.rootNode.addChildNode(newNode)
        }
        
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
            newNode.movabilityHint = .fixed
            newNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: newNode))
            newNode.physicsBody?.categoryBitMask = roomScan.objects.endIndex
            for j in 0...(roomScan.objects.endIndex-1) {
                newNode.physicsBody?.collisionBitMask = j
            }
            
            scene.rootNode.addChildNode(newNode)
        }
        
        // add all objects
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
            newNode.name = String(i) // only objects have name
            newNode.simdTransform = scannedObject.transform
            newNode.movabilityHint = .movable
            newNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: newNode))
            newNode.physicsBody?.categoryBitMask = i
            newNode.physicsBody?.collisionBitMask = roomScan.objects.endIndex
            newNode.state = .UnSelected
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
        
        let targetNode = SCNNode() // question: need to initialize it probably
        targetNode.isHidden = true // hide the node
        scene.rootNode.addChildNode(targetNode)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 10, y: 20, z: 10)
        let centerConstraint = SCNLookAtConstraint(target: targetNode)
        centerConstraint.isGimbalLockEnabled = true
        cameraNode.constraints = [centerConstraint]
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(directionalLight)
        scene.rootNode.addChildNode(myAmbientLightNode)
        
        // Add gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        let objectPanGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleObjectPan(_:)))
        
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(objectPanGesture)
        
        //        let panRecognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(_:)))
        let rotationRecognizer = UIRotationGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleRotation(_:)))
        
        //        view.addGestureRecognizer(panRecognizer)
        view.addGestureRecognizer(pinchRecognizer)
        view.addGestureRecognizer(rotationRecognizer)
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update your 3D scene here
        print("update called")
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view, selected: self.$selectedName)
    }
    
    class Coordinator: NSObject {
        enum MoveDirection {
            case XAxis
            case ZAxis
        }
        private let view: SCNView
        @Binding var selectedName: String?
        var selectedNodeMove: SCNNode?
        var selectedNode: SCNNode? // To keep track of the selected node
        var oldNode: SCNNode?
        var lastPanLocation: CGPoint = .zero // To store the last pan location
        var lastMoveDirection: MoveDirection? = nil
        
        init(_ view: SCNView, selected: Binding<String?>) {
            self.view = view
            self._selectedName = selected
            super.init()
        }
        
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            // check what nodes are tapped
            let p = gestureRecognize.location(in: view)
            let hitResults = view.hitTest(p, options: [:])
            
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // only take effects on objects
                let result = hitResults[0]
                switch result.node.movabilityHint {
                case .fixed:
                    return
                case .movable:
                    let name = result.node.name! // what if failed here?
                    let selectedNode = view.scene?.rootNode.childNode(withName: name, recursively: true)
                    switch selectedNode!.state { // very bad
                    case .UnSelected:
                        if let _ = selectedNodeMove {
                            // pass
                        } else {
                            selectedNodeMove = selectedNode
                            selectedNode?.state = .Selected
                            selectedNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                            selectedName = name
                            let arrowNode = SCNNode(geometry: createArrowGeometry())
                            arrowNode.transform = selectedNode?.transform ?? SCNMatrix4()
                            arrowNode.name = "arrow"
                            // Add the arrow as a child node to the selected object
                            selectedNode?.addChildNode(arrowNode)
                        }
                    case .Selected:
                        selectedNodeMove = nil
                        selectedNode?.state = .UnSelected
                        selectedNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                        if let arrowNode = selectedNode?.childNode(withName: "arrow", recursively: true) {
                            arrowNode.removeFromParentNode()
                        }
                        selectedName = nil
                    case nil:
                        break
                    }
                @unknown default:
                    return
                }
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            // Camera pinch (zoom) logic
            // Get the view that the user pinched on
            //            print("handle pinch")
            guard let sceneView = gesture.view as? SCNView else {
                return
            }
            
            // Get the scale from the pinch gesture
            let scale = Float(gesture.scale)
            
            // Adjust the camera's field of view to simulate zoom
            sceneView.pointOfView?.camera?.fieldOfView /= CGFloat(scale)
            
            // Reset the gesture's scale to 1 to avoid cumulative scaling
            gesture.scale = 1
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            // Camera rotation logic
            //            print("handle rotation")
            guard let sceneView = gesture.view as? SCNView else {
                return
            }
            
            let delta = -Float(gesture.rotation) * 10
            
            // calculate delta_x and delta_z according to delta in a very rough way
            let original = atan(sceneView.pointOfView!.position.z / sceneView.pointOfView!.position.x)
            let theta = delta / (10 * sqrt(2))
            let deltaX = 10 * sqrt(2) * cos(theta + original)
            let deltaZ = 10 * sqrt(2) * sin(theta + original)
            
            // todo: make some adjustment to ensure a continuous rotation
            sceneView.pointOfView?.position.x = deltaX
            sceneView.pointOfView?.position.z = deltaZ
            print(sceneView.pointOfView!.eulerAngles, sceneView.pointOfView!.position)
            
            // Reset the gesture's rotation to avoid cumulative rotation
            gesture.rotation = 0
        }
        
        @objc func handleObjectPan(_ gesture: UIPanGestureRecognizer) {
            // Object pan logic
            //            print("handle object pan")
            guard let sceneView = gesture.view as? SCNView else { return }
            if gesture.state == .began {
                // Handle the start of the pan gesture (e.g., select the node)
                let location = gesture.location(in: sceneView)
                let hitResults = sceneView.hitTest(location, options: nil)
                if let hitNode = hitResults.first?.node {
                    switch hitNode.movabilityHint {
                    case .fixed:
                        return
                    case .movable:
                        selectedNode = hitNode;
                        oldNode = hitNode;
                    @unknown default:
                        return
                    }
                }
            } else if gesture.state == .changed {
                // Handle the ongoing pan gesture (e.g., move the selected node)
                let translation = gesture.translation(in: sceneView)
                if let selectedNode = selectedNode {
                    // todo: add boundary to movement
                    oldNode = selectedNode // copy the oldNode
                    if let _ = lastMoveDirection {
                        // nothing changes
                    } else {
                        if translation.x > translation.y {
                            lastMoveDirection = .XAxis
                        } else {
                            lastMoveDirection = .ZAxis
                        }
                    }
                    //                    print(translation)
                    //                    switch lastMoveDirection {
                    //                    case .XAxis:
                    //                        print("XAxis")
                    //                    case .ZAxis:
                    //                        print("ZAxis")
                    //                    case nil:
                    //                        print("nil")
                    //                    }
                    let deltaX = Float(translation.x - lastPanLocation.x)
                    let deltaZ = Float(translation.y - lastPanLocation.y)
                    selectedNode.position.x += deltaX / 100 // Adjust the scale as needed
                    selectedNode.position.z += deltaZ / 100
                    lastPanLocation = translation
                }
            } else if gesture.state == .ended {
                // Handle the end of the pan gesture (e.g., deselect the node)
                selectedNode = nil
                oldNode = nil
            }
        }
    }
}

func createArrowGeometry() -> SCNGeometry {
    // Define arrow parameters
    let shaftLength: CGFloat = 1.0
    let shaftRadius: CGFloat = 0.1
    let headLength: CGFloat = 0.2
    let headRadius: CGFloat = 0.2
    
    // Create the arrow's shaft (cylinder)
    let shaft = SCNCylinder(radius: shaftRadius, height: shaftLength)
    shaft.firstMaterial?.diffuse.contents = UIColor.red // Set the material color
    
    // Create the arrow's head (cone)
    let head = SCNCone(topRadius: 0, bottomRadius: headRadius, height: headLength)
    head.firstMaterial?.diffuse.contents = UIColor.red // Set the material color
    
    // Combine the shaft and head geometries
    let arrowGeometry = SCNGeometry(sources: [shaft.sources.first!, head.sources.first!], elements: [shaft.elements.first!, head.elements.first!])
    
    
    return arrowGeometry
}


