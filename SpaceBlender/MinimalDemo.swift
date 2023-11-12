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

//func getDiffRotation(q1: SCNQuaternion, q2: SCNQuaternion) -> SCNQuaternion {
//    let abs1 = sqrt(q1.x * q1.x + q1.y * q1.y + q1.z * q1.z + q1.w * q1.w)
//    let inv = SCNQuaternion(q1.x / abs1, -q1.y / abs1, -q1.z / abs1, -q1.w / abs1)
//    return q2 * inv
//}

// the yaw rotation only
func generateYawRotationMatrix(_ theta: Float) -> simd_float4x4 {
    let costheta = cosf(theta)
    let sintheta = sinf(theta)
    return simd_float4x4(
        SIMD4(costheta, 0 ,sintheta, 0),
        SIMD4(0, 1, 0, 0),
        SIMD4(-sintheta, 0, costheta, 0),
        SIMD4(0, 0, 0, 1))
}

struct SceneKitView: UIViewRepresentable {
    @ObservedObject var store = ModelStore.shared
    @State var index: Int
    // the id of selected Node
    
    var scene = SCNScene()
    var options: [Any]
    var view = SCNView()
    @Binding var selectedName: String?
    
    func makeUIView(context: Context) -> SCNView {
        view.scene = scene
        // Disable the default camera control
        view.allowsCameraControl = true
        
        scene.background.contents = Color.black
        scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
        var deltaPos: SCNVector3? = nil
//        var deltaRotate: SCNQuaternion? = nil
        let roomScan = store.models[index].model!
//        var width: Float = 0
//        var length: Float = 0
//        var rotate: Float = 0
        
        // all floors
        if roomScan.floors.endIndex > 0 {
            for i in 0...(roomScan.floors.endIndex-1) {
                
                //Generate new wall geometry
                let scannedFloor = roomScan.floors[i]
                
                let newFloor = SCNBox(
                    width: CGFloat(scannedFloor.dimensions.x),
                    height: CGFloat(scannedFloor.dimensions.y),
                    length: CGFloat(0.2),
                    chamferRadius: 0
                )
                
//                if scannedFloor.dimensions.x > scannedFloor.dimensions.y {
//                    length = scannedFloor.dimensions.x
//                    width = scannedFloor.dimensions.y
//                } else {
//                    length = scannedFloor.dimensions.y
//                    width = scannedFloor.dimensions.x
//                }
                
                
                newFloor.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
                newFloor.firstMaterial?.transparency = 0.5
                
                //Generate new SCNNode
                let newNode = SCNNode(geometry: newFloor)
                newNode.simdTransform = scannedFloor.transform
                newNode.name = "floor \(i)"
                newNode.movabilityHint = .fixed
                deltaPos = SCNVector3(0 - newNode.position.x, 0 - newNode.position.y, 0 - newNode.position.z)
                newNode.position = SCNVector3(0, 0, 0)
//                newNode.rotation = SCNVector4(x: -1, y: 0, z: 0, w: Float.pi / 2)
                
//                newNode.rotate(by: <#T##SCNQuaternion#>, aroundTarget: SCNVector3(0, 0, 0))
                scene.rootNode.addChildNode(newNode)
            }
        }
        
        // find the rotation angle
//        if roomScan.walls.endIndex > 0 {
//            for i in 0...(roomScan.walls.endIndex-1) {
//                let wall = roomScan.walls[i]
//                if wall.dimensions.x > length - 0.1 { // the longest wall
//                    let newNode = SCNNode(geometry: SCNSphere(radius: 0.1))
//                    newNode.simdTransform = wall.transform
//                    if let delta = deltaPos {
//    //                    print("change position")
//                        newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
//                    }
//                    print("find the longest wall: \(newNode.position)")
//                    let a = newNode.position.x
//                    let b = newNode.position.z
//                    if (a > 0 && b > 0) || (a < 0 && b < 0) {
//                        rotate = atanf(a / b)
//                    } else if (a > 0 && b < 0) || (a < 0 && b > 0) {
//                        rotate = Float.pi + atanf(a / b)
//                    } else if b == 0 {
//                        rotate = Float.pi / 2
//                    }
//                }
//            }
//        }
        
        // all doors
        if roomScan.doors.endIndex > 0 {
            for i in 0...(roomScan.floors.endIndex-1) {
                
                //Generate new wall geometry
                let scannedDoor = roomScan.doors[i]
                
                let length = 0.3
                let width = scannedDoor.dimensions.x
                let height = scannedDoor.dimensions.y
                let newDoor = SCNBox(
                    width: CGFloat(width),
                    height: CGFloat(height),
                    length: CGFloat(length),
                    chamferRadius: 0
                )
                
                newDoor.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
                newDoor.firstMaterial?.transparency = 0.9
                
                //Generate new SCNNode
                let newNode = SCNNode(geometry: newDoor)
                newNode.simdTransform = scannedDoor.transform
                if let delta = deltaPos {
//                    print("change position")
                    newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
                }
//                newNode.simdRotate(by: simd_quatf(generateYawRotationMatrix(rotate)), aroundTarget: simd_float3(0, 0, 0))
                newNode.name = "door \(i)"
                newNode.movabilityHint = .fixed
                scene.rootNode.addChildNode(newNode)
            }
            // try to get the correct position of the door here
//            let scannedDoor = roomScan.doors[0]
//            let newObject = SCNSphere(radius: 0.1)
//            newObject.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0, blue: 0, alpha: 1) // black point
//            newObject.firstMaterial?.transparency = 1
//            let newNode = SCNNode(geometry: newObject)
//            newNode.simdTransform = scannedDoor.transform
//            if let delta = deltaPos {
//                newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
//            }
//            newNode.simdRotate(by: simd_quatf(generateYawRotationMatrix(rotate)), aroundTarget: simd_float3(0, 0, 0))
//            scene.rootNode.addChildNode(newNode)
        }
        
        // add all windows
        if roomScan.windows.endIndex > 0 {
            for i in 0...(roomScan.windows.endIndex-1) {
                
                //Generate new wall geometry
                let scannedWindow = roomScan.windows[i]
                
                let length = 0.3
                let width = scannedWindow.dimensions.x
                let height = scannedWindow.dimensions.y
                let newWindow = SCNBox(
                    width: CGFloat(width),
                    height: CGFloat(height),
                    length: CGFloat(length),
                    chamferRadius: 0
                )
                
                newWindow.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
                newWindow.firstMaterial?.transparency = 0.9
                
                //Generate new SCNNode
                let newNode = SCNNode(geometry: newWindow)
                newNode.simdTransform = scannedWindow.transform
                if let delta = deltaPos {
                    newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
                }
                newNode.name = "door \(i)"
                newNode.movabilityHint = .fixed
                scene.rootNode.addChildNode(newNode)
            }
        }
        
        // add all walls
        if roomScan.walls.endIndex-1 > 0 {
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
                
                newWall.firstMaterial?.diffuse.contents = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
                newWall.firstMaterial?.transparency = 0.5
                
                //Generate new SCNNode
                let newNode = SCNNode(geometry: newWall)
                newNode.simdTransform = scannedWall.transform
                if let delta = deltaPos {
//                    print("change position")
                    newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
                }
                newNode.name = "wall \(i)"
                newNode.movabilityHint = .fixed
                scene.rootNode.addChildNode(newNode)
            }
        }
        
        // add all objects
        if roomScan.objects.endIndex-1 > 0 {
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
                
                newObject.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
                newObject.firstMaterial?.transparency = 0.5
                
                //Generate new SCNNode
                let newNode = SCNNode(geometry: newObject)
                newNode.name = String(i) // only objects have name
                newNode.simdTransform = scannedObject.transform
                newNode.movabilityHint = .movable
                newNode.state = .UnSelected
                if let delta = deltaPos {
//                    print("change position")
                    newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
                }
                scene.rootNode.addChildNode(newNode)
            }
        }
        
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


