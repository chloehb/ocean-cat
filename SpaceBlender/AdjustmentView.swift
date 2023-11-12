//
//  AdjustmentView.swift
//  SpaceBlender
//
//  Created by akai on 11/9/23.
//

import SceneKit
import SwiftUI

private var NodeTypeKey: UInt8 = 0 // We need this to make our new property



struct AdjustmentView: UIViewRepresentable {
    @State var index: Int
    // the id of selected Node
    var adjustment: AttachedResult
    
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
        
        let a = adjustment.length / 2
        let b = adjustment.width / 2
        
        // add floor
        let newFloor = SCNBox(
            width: CGFloat(adjustment.width),
            height: CGFloat(0.2),
            length: CGFloat(adjustment.length),
            chamferRadius: 0
        )
        // add four walls
        newFloor.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
        newFloor.firstMaterial?.transparency = 0.5
        let newNodeFloor = SCNNode(geometry: newFloor)
        newNodeFloor.name = "floor"
        newNodeFloor.position = SCNVector3(0, 0, 0)
        newNodeFloor.rotation = SCNVector4(0, 1, 0, Float.pi / 2)
        scene.rootNode.addChildNode(newNodeFloor)
        
        // add four walls according to the size of floor
        let newWallEast = SCNBox(width: 2 * CGFloat(b), height: 3, length: 0.2, chamferRadius: 0) // todo: store the original height of wall
        newWallEast.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 1, blue: 0.85, alpha: 1)
        newWallEast.firstMaterial?.transparency = 0.5
        let newNodeWallEast = SCNNode(geometry: newWallEast)
        newNodeWallEast.name = "walleast"
        newNodeWallEast.position = SCNVector3(a, 1, 0)
        newNodeWallEast.rotation = SCNVector4(0, 1, 0, Float.pi / 2)
        scene.rootNode.addChildNode(newNodeWallEast)
        
        let newWallWest = SCNBox(width: 2 * CGFloat(b), height: 3, length: 0.2, chamferRadius: 0) // todo: store the original height of wall
        newWallWest.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 1, blue: 0.85, alpha: 1)
        newWallWest.firstMaterial?.transparency = 0.5
        let newNodeWallWest = SCNNode(geometry: newWallWest)
        newNodeWallWest.name = "wallwest"
        newNodeWallWest.position = SCNVector3(-a, 1, 0)
        newNodeWallWest.rotation = SCNVector4(0, 1, 0, Float.pi / 2)
        scene.rootNode.addChildNode(newNodeWallWest)
        
        let newWallNorth = SCNBox(width: 2 * CGFloat(a), height: 3, length: 0.2, chamferRadius: 0)
        newWallNorth.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 1, blue: 0.85, alpha: 1)
        newWallNorth.firstMaterial?.transparency = 0.5
        let newNodeWallNorth = SCNNode(geometry: newWallNorth)
        newNodeWallNorth.name = "wallnorth"
        newNodeWallNorth.position = SCNVector3(0, 1, -b)
        scene.rootNode.addChildNode(newNodeWallNorth)
        
        let newWallSouth = SCNBox(width: 2 * CGFloat(a), height: 3, length: 0.2, chamferRadius: 0)
        newWallSouth.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 1, blue: 0.85, alpha: 1)
        newWallSouth.firstMaterial?.transparency = 0.5
        let newNodeWallSouth = SCNNode(geometry: newWallSouth)
        newNodeWallSouth.name = "wallnorth"
        newNodeWallSouth.position = SCNVector3(0, 1, b)
        scene.rootNode.addChildNode(newNodeWallSouth)
        
        for i in 0..<adjustment.beds.count {
            let bed = adjustment.beds[i]
//            print("\(i): ", bed)
            let newBed = SCNBox(width: CGFloat(bed.width), height: CGFloat(bed.height), length: CGFloat(bed.length), chamferRadius: 2)
            newBed.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 0.85, blue: 0, alpha: 1)
            newBed.firstMaterial?.transparency = 0.5
            let newNodeBed = SCNNode(geometry: newBed)
            newNodeBed.name = "bed\(i)"
            if let x = bed.position.x, let y = bed.position.y, let z = bed.position.z {
                newNodeBed.position = SCNVector3(x, y, z)
            } else {
                print("x or y or z is not specified")
                newNodeBed.position = SCNVector3(5, 0.5, 5)
            }
            if let rot = bed.facing {
//                print(rot)
                switch rot {
                case .North:
                    break
                case .East:
                    newNodeBed.rotation = SCNVector4(0, 1, 0, Float.pi / 2)
                case .South:
                    newNodeBed.rotation = SCNVector4(0, 1, 0, Float.pi)
                case .West:
                    newNodeBed.rotation = SCNVector4(0, 1, 0, Float.pi * 3 / 2)
                }
            }
            scene.rootNode.addChildNode(newNodeBed)
        }
        print(a)
        print(b)
        for i in 0..<adjustment.desks.count {
            let desk = adjustment.desks[i]
            print("\(i): ", desk)
            let newDesk = SCNBox(width: CGFloat(desk.width), height: CGFloat(desk.height), length: CGFloat(desk.length), chamferRadius: 2)
            newDesk.firstMaterial?.diffuse.contents = UIColor(red: 0.85, green: 1, blue: 0, alpha: 1)
            newDesk.firstMaterial?.transparency = 0.5
            let newNodeDesk = SCNNode(geometry: newDesk)
            newNodeDesk.name = "bed\(i)"
            if let x = desk.position.x, let y = desk.position.y, let z = desk.position.z {
                newNodeDesk.position = SCNVector3(x, y, z)
            } else {
                print("x or y or z is not specified")
                newNodeDesk.position = SCNVector3(5, 0.5, 5)
            }
            if let rot = desk.facing {
                print(rot)
                switch rot {
                case .North:
                    newNodeDesk.rotation = SCNVector4(0, 1, 0, Float.pi / 2)
                case .East:
                    newNodeDesk.rotation = SCNVector4(0, 1, 0, Float.pi)
                case .South:
                    newNodeDesk.rotation = SCNVector4(0, 1, 0, Float.pi * 3 / 2)
                case .West:
                    newNodeDesk.rotation = SCNVector4(0, 1, 0, Float.pi * 2)
                }
            }
            scene.rootNode.addChildNode(newNodeDesk)
        }
        
        for i in 0..<adjustment.windows.count {
            let window = adjustment.windows[i]
            let newWindow = SCNBox(width: CGFloat(window.width), height: CGFloat(window.height), length: CGFloat(0.3), chamferRadius: 0.5)
            newWindow.firstMaterial?.diffuse.contents = UIColor(red: 0.85, green: 0, blue: 0, alpha: 1)
            newWindow.firstMaterial?.transparency = 0.5
            let newNodeWindow = SCNNode(geometry: newWindow)
            newNodeWindow.name = "window\(i)"
            if let x = window.position.x, let y = window.position.y, let z = window.position.z {
                newNodeWindow.position = SCNVector3(x, y, z)
                if abs(x) < a + 0.1 && abs(x) > a - 0.1 { // attached on the wallWest or wallEast, rotate 90
                    newNodeWindow.rotation = SCNQuaternion(0, 1, 0, Float.pi / 2)
                }
            } else {
                print("x or y or z is not specified")
                newNodeWindow.position = SCNVector3(5, 0.5, 5)
            }
            scene.rootNode.addChildNode(newNodeWindow)
        }
        
        // currently, only take care of the first door
        if let door = adjustment.doors.first {
            let newDoor = SCNBox(width: CGFloat(door.width), height: CGFloat(door.height), length: CGFloat(0.3), chamferRadius: 0.5)
            newDoor.firstMaterial?.diffuse.contents = UIColor(red: 0.85, green: 0, blue: 0, alpha: 1)
            newDoor.firstMaterial?.transparency = 0.5
            let newDoorNode = SCNNode(geometry: newDoor)
            newDoorNode.name = "door0"
//            print("b: \(b)")
            if let x = door.position.x, let y = door.position.y, let z = door.position.z {
                newDoorNode.position = SCNVector3(x, y, z)
//                print("x: \(x), y: \(y), z: \(z)")
                if abs(x) < a + 0.1 && abs(x) > a - 0.1 { // attached on the wallWest or wallEast, rotate 90
                    newDoorNode.rotation = SCNQuaternion(0, 1, 0, Float.pi / 2)
                }
            } else {
                print("x or y or z is not specified")
                newDoorNode.position = SCNVector3(5, 0.5, 5)
            }
            scene.rootNode.addChildNode(newDoorNode)
        }
//        for i in 0..<adjustment.doors.count {
//            let door = adjustment.doors[i]
//
//        }
        
        //(0, 0, 0)
        let newObject = SCNSphere(radius: 0.1)
        let newNode = SCNNode(geometry: newObject)
        newObject.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        newObject.firstMaterial?.transparency = 1
        //        newNode.name = String(roomScan.objects.count) // only objects have name
        //        newNode.simdTransform = simd_float4x4([[0.5, 0.0, -0.26714072, 0.0], [0.0, 0.99999994, 0.0, 0.0], [0.26714072, 0.0, 0.96365756, 0.0], [1.5175736, -0.2107589, -0.1796678, 0.99999994]])
        //        print("object \(roomScan.objects.count): \(newNode.simdTransform)")
        newNode.position = SCNVector3(0, 0, 0)
        newNode.movabilityHint = .movable
        newNode.name = "(0, 0, 0)"
        newNode.state = .UnSelected
        scene.rootNode.addChildNode(newNode)
        
        //(1, 0, 0)
        let newObject1 = SCNSphere(radius: 0.1)
        let newNode1 = SCNNode(geometry: newObject1)
        newObject1.firstMaterial?.diffuse.contents = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1)
        newObject1.firstMaterial?.transparency = 1
        newNode1.movabilityHint = .movable
        newNode1.position = SCNVector3(1, 0, 0)
        newNode1.name = "(1, 0, 0)"
        newNode1.state = .UnSelected
        scene.rootNode.addChildNode(newNode1)
        
        //(0, 0, 1)
        let newObject2 = SCNSphere(radius: 0.1)
        let newNode2 = SCNNode(geometry: newObject2)
        newObject2.firstMaterial?.diffuse.contents = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        newObject2.firstMaterial?.transparency = 1
        newNode2.movabilityHint = .movable
        newNode2.position = SCNVector3(0, 0, 1)
        newNode2.name = "(0, 0, 1)"
        newNode2.state = .UnSelected
        scene.rootNode.addChildNode(newNode2)
        //        let angleInRadians: Float = .pi / 4  // 45 degrees in radians
        //        var rotationQuaternion: SCNQuaternion? = nil
        
        //        for child in scene.rootNode.childNodes {
        //            let position = child.position
        //            let newObject2 = SCNSphere(radius: 0.1)
        //            let newNode2 = SCNNode(geometry: newObject2)
        //            newObject2.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
        //            newObject2.firstMaterial?.transparency = 1
        //            newNode2.movabilityHint = .movable
        //            newNode2.position = position
        //            newNode2.name = "pos"
        //            newNode2.state = .UnSelected
        //            scene.rootNode.addChildNode(newNode2)
        ////            print("node \(child.name ?? "no name"): \(child.position); \(child.rotation); \(child.orientation)")
        //        }
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 3
        camera.zNear = 0
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 0)
        let centerConstraint = SCNLookAtConstraint(target: scene.rootNode.childNodes[0])
        cameraNode.constraints = [centerConstraint]
        scene.rootNode.addChildNode(cameraNode)
        
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
                            //                            let arrowNode = SCNNode(geometry: createArrowGeometry())
                            //                            arrowNode.transform = selectedNode?.transform ?? SCNMatrix4()
                            //                            arrowNode.name = "arrow"
                            //                            // Add the arrow as a child node to the selected object
                            //                            selectedNode?.addChildNode(arrowNode)
                        }
                    case .Selected:
                        selectedNodeMove = nil
                        selectedNode?.state = .UnSelected
                        selectedNode?.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
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
            //            print(sceneView.pointOfView!.eulerAngles, sceneView.pointOfView!.position)
            
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


