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
import ARKit
import SceneKit.ModelIO

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

final class AllLocRec: ObservableObject {
    static let shared = AllLocRec()
    var res: [(Float, Float, Float)];
    private init() {
        res = []
    }
    func loadAllLoc(index: Int) {
        @ObservedObject var store = ModelStore.shared
        if !res.isEmpty {
            res.removeAll()
        }
        let roomScan = store.models[index].model!
        var deltaPos: SCNVector3? = nil
        for i in 0...(roomScan.floors.endIndex-1) {
            let scannedFloor = roomScan.floors[i]
            let newNode = SCNNode()
            newNode.simdTransform = scannedFloor.transform
            deltaPos = SCNVector3(0 - newNode.position.x, 0 - newNode.position.y, 0 - newNode.position.z)
        }
        if roomScan.objects.endIndex != 0 {
            for i in 0...(roomScan.objects.endIndex-1) {
                let scannedObject = roomScan.objects[i]
                //Generate new SCNNode
                let newNode = SCNNode()
                newNode.simdTransform = scannedObject.transform
                if let delta = deltaPos {
                    newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
                }
                print(newNode.rotation.w)
                res.append((newNode.position.x, newNode.position.z, newNode.rotation.w))
            }
        }
//        for i in 0...(roomScan.objects.endIndex-1) {
//            let scannedObject = roomScan.objects[i]
//            //Generate new SCNNode
//            let newNode = SCNNode()
//            newNode.simdTransform = scannedObject.transform
//            if let delta = deltaPos {
//                newNode.position = SCNVector3(newNode.position.x + delta.x, newNode.position.y + delta.y, newNode.position.z + delta.z)
//            }
//            print(newNode.rotation.w)
//            res.append((newNode.position.x, newNode.position.z, newNode.rotation.w))
//        }
    }
    
    func updateLoc(ind: String, new_x: Float?, new_z: Float?, new_w: Float?) {
        if let i = Int(ind), let x = new_x, let z = new_z, var w = new_w {
            w = w.truncatingRemainder(dividingBy: (2 * Float.pi))
            res[i] = (x, z, w)
        }
    }
}

//class SceneKitViewModel: ObservableObject {
//    @Published var exchanged = false
//}

struct SceneKitView: UIViewRepresentable {
    @ObservedObject var store = ModelStore.shared
    @ObservedObject var locRec = AllLocRec.shared
    @State var index: Int
//    @ObservedObject var viewModel: SceneKitViewModel
    
//    @State var exchange_url: URL?
    @Binding var x_pos: Float
    @Binding var z_pos: Float
    @Binding var degrees: Float
    // the id of selected Node
    
    var scene = SCNScene()
    var options: [Any]
    var view = SCNView()
    @Binding var selectedName: String?
    
//    var _exchanged = false
//    var _exchanged_url = URL(string: "https://www.example.com")
    @Binding var exchanged: Bool
    @Binding var exchanged_url: URL?
    
//    var exchanged_url: URL {
//        get {
//            return _exchanged_url!
//        }
//        set {
//            _exchanged_url = newValue
//        }
//    }
//    
//    var exchanged: Bool {
//        get {
//            return _exchanged
//        }
//        set {
//            _exchanged = newValue
//        }
//    }
    
//    init(store: ModelStore, locRec: AllLocRec, viewModel: SceneKitViewModel, /* other properties */) {
//            self.store = store
//            self.locRec = locRec
//            self.viewModel = viewModel
//            // ... initialize other properties ...
//    }
    
    func makeUIView(context: Context) -> SCNView {
        view.scene = scene
        // Disable the default camera control
        view.allowsCameraControl = true
        
        scene.background.contents = Color.black
        scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
        var deltaPos: SCNVector3? = nil
        let roomScan = store.models[index].model!
        
        locRec.loadAllLoc(index: index)
        
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
                
                newFloor.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.85, blue: 1, alpha: 1)
                newFloor.firstMaterial?.transparency = 0.5
                
                //Generate new SCNNode
                let newNode = SCNNode(geometry: newFloor)
                newNode.simdTransform = scannedFloor.transform
                newNode.name = "floor \(i)"
                newNode.movabilityHint = .fixed
                deltaPos = SCNVector3(0 - newNode.position.x, 0 - newNode.position.y, 0 - newNode.position.z)
                newNode.position = SCNVector3(0, 0, 0)
                scene.rootNode.addChildNode(newNode)
            }
        }
        
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
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
//         Update your 3D scene here
        if exchanged {
            if let select = selectedName {
                let selectIndex = Int(select)!
                let (or_x, or_z, or_w) = locRec.res[selectIndex]
                
                let mdlAsset = MDLAsset(url: exchanged_url!)
                print(exchanged)
                // Load the textures for the model
                mdlAsset.loadTextures()

                // Extract the first object from the asset and create a node
                let asset = mdlAsset.object(at: 0)
                let assetNode = SCNNode(mdlObject: asset)

                // Replace the existing node in the scene
                // This assumes you have a way to identify the node to be replaced
                let sname = selectedName!
                assetNode.name = sname
                assetNode.position.x = or_x
                assetNode.position.z = or_z
                assetNode.rotation.w = or_w
                if let nodeToReplace = uiView.scene?.rootNode.childNode(withName: sname, recursively: true) {
                    nodeToReplace.removeFromParentNode() // Remove the old node
                    uiView.scene?.rootNode.addChildNode(assetNode) // Add the new node
//                    SCNTransaction.begin()
//
//                    SCNTransaction.commit()
                }
            }
            exchanged = false
            }

        
        if let select = selectedName {
            let selectIndex = Int(select)!
            if let target = uiView.scene?.rootNode.childNode(withName: select, recursively: true) {
                let (or_x, or_z, or_w) = locRec.res[selectIndex]
                target.position.x = or_x + x_pos
                target.position.z = or_z + z_pos
                target.rotation.w = or_w + degrees
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view, selected: self.$selectedName, x_pos: self.$x_pos, z_pos: self.$z_pos, degrees: self.$degrees)
    }
    
    class Coordinator: NSObject {
        enum MoveDirection {
            case XAxis
            case ZAxis
        }
        private let view: SCNView
        @ObservedObject var locRec = AllLocRec.shared
        @Binding var selectedName: String?
        @Binding var x_pos: Float
        @Binding var z_pos: Float
        @Binding var degrees: Float
        var selectedNodeMove: SCNNode?
        var selectedNode: SCNNode? // To keep track of the selected node
        var oldNode: SCNNode?
        var lastPanLocation: CGPoint = .zero // To store the last pan location
        var lastMoveDirection: MoveDirection? = nil
        
        init(_ view: SCNView, selected: Binding<String?>, x_pos: Binding<Float>, z_pos: Binding<Float>, degrees: Binding<Float>) {
            self.view = view
            self._selectedName = selected
            self._x_pos = x_pos
            self._z_pos = z_pos
            self._degrees = degrees
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
                        }
                    case .Selected:
                        selectedNodeMove = nil
                        selectedNode?.state = .UnSelected
                        selectedNode?.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
                        selectedName = nil
                        locRec.updateLoc(ind: name, new_x: selectedNode?.position.x, new_z: selectedNode?.position.z, new_w: selectedNode?.rotation.w)
                        x_pos = 0
                        z_pos = 0
                        degrees = 0
                    case nil:
                        break
                    }
                @unknown default:
                    return
                }
            }
        }
    }
}


