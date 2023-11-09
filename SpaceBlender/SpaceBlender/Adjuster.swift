//
//  Adjuster.swift
//  SpaceBlender
//
//  Created by akai on 11/7/23.
//

import RoomPlan
import SceneKit
import SwiftUI

enum FurnitureType {
    case Bed
    case Table
    case Door // we need the position of Door and Window
    case Window
}

enum Direction {
    case North
    case East
    case South
    case West
}

struct Furniture {
    var type: FurnitureType
    // the final result of adjuster, geometric center of a box, (x, y, z)
    var position: (Float, Float, Float)?
    // the final result of adjuster
    var facing: Direction?
    
    var width: Float
    var length: Float // for window/door, 0
    var height: Float // for floor, 0
    init(type: FurnitureType, position: (Float, Float, Float)? = nil, width: Float, length: Float = 0, height: Float = 0) {
        self.type = type
        self.position = position
        self.width = width
        self.length = length
        self.height = height
    }
}

struct AttachedResult {
    private var length: Float = 0 // for convenience, length >= width in any case
    private var width: Float = 0
    private var doors: [Furniture]
    private var windows: [Furniture]
    private var beds: [Furniture]
    private var desks: [Furniture]
    
    init(length: Float, width: Float, doors: [Furniture], windows: [Furniture], beds: [Furniture], desks:[Furniture]) {
        self.length = length
        self.width = width
        self.doors = doors
        self.windows = windows
        self.beds = beds
        self.desks = desks
    }
}

struct Adjuster {
    // everything needed to be initialize
    // dimensions : ()
    // bed : [location] 1/2 bed
    // desk : [location]
    // door : [location]
    // window : [location]
    // 1. read the boolean and the index of room model, and initialize everything needed
    // 2. use the initalized info fill in the properties as much as we can (use the categories)
    // 3. clear all the objects
    // 4. add bed and desk back
    private var room: CapturedRoom? = nil // meta data
    private var length: Float = 0 // for convenience, length >= width in any case
    private var width: Float = 0
    private var hasRoommate: Bool? = nil
    private var bedsTogether: Bool? = nil
    private var bedFacingDoor: Bool? = nil
    private var objectByWindow: String? = nil
    private var floorSpace: Bool? = nil
    private var doors: [Furniture]
    private var windows: [Furniture]
    private var requiredNum: Int = 1 // default: no roommate
    // these two are the final results
    private var beds: [Furniture]
    private var tables: [Furniture]
    
    @ObservedObject var store = ModelStore.shared
    
    init(index: Int, hasRoommate: Bool?, bedsTogether: Bool?, bedFacingDoor: Bool?,
         objectByWindow: String?, floorSpace: Bool?){
        self.beds = []
        self.tables = []
        self.doors = []
        self.windows = []
        self.room = store.models[index].model
        self.length = (room?.floors[0].dimensions.y)! // invalid if a model has no floor
        self.width = (room?.floors[0].dimensions.x)!
        let tempFloor = SCNNode()
        tempFloor.simdTransform = (room?.floors[0].transform)!
        let tf = tempFloor.position
        let delta: (Float, Float, Float) = (-tf.x, -tf.y, -tf.z)
        if self.length < self.width {
            swap(&self.length, &self.width)
        }
        self.hasRoommate = hasRoommate
        self.bedsTogether = bedsTogether
        self.bedFacingDoor = bedFacingDoor
        self.objectByWindow = objectByWindow
        self.floorSpace = floorSpace
        if let room = self.room {
            // question: whether it should be better if we suppose to have only one door
            for door in room.doors {
                let tempDoor = SCNNode()
                tempDoor.simdTransform = door.transform
                let tp = tempDoor.position
                // try to get the orientation according to the rotation
                
                doors.append(Furniture(type: FurnitureType.Door, position: (tp.x + delta.0, tp.y + delta.1, tp.z + delta.2), width: door.dimensions.x, height: door.dimensions.y))
            }
            for window in room.windows {
                let tempWindow = SCNNode()
                tempWindow.simdTransform = window.transform
                let tw = tempWindow.position
                windows.append(Furniture(type: FurnitureType.Window, position: (tw.x + delta.0, tw.y + delta.1, tw.z + delta.2), width: window.dimensions.x, height: window.dimensions.y))
            }
            for obj in room.objects {
                var wid = obj.dimensions.x
                var len = obj.dimensions.z
                if wid > len {
                    swap(&wid, &len)
                }
                switch obj.category {
                case .bed:
                    beds.append(Furniture(type: FurnitureType.Bed, width: wid, length: len))
                case .table:
                    tables.append(Furniture(type: FurnitureType.Table, width: wid, length: len))
                default:
                    continue
                }
            }
        }
        // ensure that there are enough beds/tables
        if let hasRoommate = hasRoommate {
            if hasRoommate {
                requiredNum = 2
            }
        }
        while tables.count < requiredNum {
            tables.append(Furniture(type: FurnitureType.Table, width: 0.5, length: 1)) // default size of a table
        }
        while beds.count < requiredNum {
            beds.append(Furniture(type: FurnitureType.Table, width: 1.5, length: 2)) // default size of a bed
        }
        
    }
    
    // todo: smartAdjust
    func smartAdjust(){
        // A matrix that defines the surface’s position and orientation in the scene.
        // var transform: simd_float4x4 { get }

        if let hasRoommate {
            if let bedsTogether {
                if  bedsTogether {
                    
                }
                else {
                    
                }
            }
        }
        
        // check orientation of bed
        if let bedFacingDoor {
            
        }
            
        
        // find cooordinates of window
        // enum CapturedElementCategory - > window
        // check width of desk to ensure it can go on same wall as window
        // center desk under window
        
        if let objectByWindow {
            if objectByWindow == "Desk" {
                
            }
        }
           
        // find coordinates of window
        // check width of bed to ensure it can go on same wall as window
        // place bed on the same wall (do not center, line up in a corner)
        if let objectByWindow {
            if objectByWindow == "Bed" {
            }
        }
            
            
        if let floorSpace {
            // place furniture on parameter near walls
            if let bedsTogether {
                // Don't moved bed, move all other furniture
            }
        }
    }
    
    // todo: generate an attached record which will be rendered in SceneKit instead of the original capturedroom
    func generateResult() -> AttachedResult {
        return AttachedResult(length: length, width: width, doors: doors, windows: windows, beds: beds, desks: tables)
    }
}
