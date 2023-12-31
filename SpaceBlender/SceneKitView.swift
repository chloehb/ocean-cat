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

func printFiles(path: URL) {
    do {
        let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
        print("content of \(path) has \(contents.count) urls")
        for url in contents {
            if url.hasDirectoryPath {
                printFiles(path: url)
            } else {
                print(url)
            }
        }
    } catch {
        print("Error reading directory: \(error)")
    }
}

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
        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
//         Update your 3D scene here
        if exchanged {
            if let select = selectedName {
                let url = exchanged_url!
                
//                printFiles(path: url.deletingLastPathComponent())
                let mdlAsset = MDLAsset(url: url)
//                print(exchanged_url!)
                // Load the textures for the model
                mdlAsset.loadTextures()

                // Extract the first object from the asset and create a node
                let asset = mdlAsset.object(at: 0)
                let assetNode = SCNNode(mdlObject: asset)

                // Replace the existing node in the scene
                // This assumes you have a way to identify the node to be replaced
                assetNode.name = select
                
                if let nodeToReplace = uiView.scene?.rootNode.childNode(withName: select, recursively: true) {
                    let selectIndex = Int(select)!
                    print("find original node")
                    assetNode.transform = nodeToReplace.transform
                    let model_y = assetNode.boundingBox.max.y - assetNode.boundingBox.min.y
                    let real_y = store.models[index].model!.objects[selectIndex].dimensions.y
                    let scale: Float = real_y / model_y
                    let scaleMatrix = matrix_float4x4(diagonal: SIMD4<Float>(scale, scale, scale, 1))
                    assetNode.transform = SCNMatrix4Mult(assetNode.transform, SCNMatrix4(scaleMatrix))
                    let aftersize = SCNVector3(x: assetNode.boundingBox.max.x - assetNode.boundingBox.min.x, y: assetNode.boundingBox.max.y - assetNode.boundingBox.min.y, z: assetNode.boundingBox.max.z - assetNode.boundingBox.min.z)
                    print("Object Size: \(aftersize)")
                    let resNode = assetNode.flattenedClone()
                    resNode.movabilityHint = .movable
                    resNode.state = .Selected
                    print(resNode.name ?? "no name")
                    uiView.scene?.rootNode.replaceChildNode(nodeToReplace, with: resNode) // Add the new node
//                    SCNTransaction.begin()
//
//                    SCNTransaction.commit()
                }
            }
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
                print(result.node.name ?? "no name")
                print(result.node.movabilityHint)
                switch result.node.movabilityHint {
                case .fixed:
                    return
                case .movable:
                    let name = result.node.name! // what if failed here?
                    print("tap: \(name)")
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
                        if let _ = selectedNode?.geometry {
                            selectedNode?.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0, green: 0.8, blue: 0, alpha: 1)
                        }
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


