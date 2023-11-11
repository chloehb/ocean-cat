//
//  Adjuster.swift
//  SpaceBlender
//
//  Created by akai on 11/7/23.
//

import RoomPlan
import SceneKit
import SwiftUI

enum FurnitureType: Codable {
    case Bed
    case Table
    case Door // we need the position of Door and Window
    case Window
}

enum Direction: Codable {
    case North
    case East
    case South
    case West
}

struct Position: Codable {
    var x: Float?
    var y: Float?
    var z: Float?
}

struct Furniture: Codable {
    var type: FurnitureType
    // the final result of adjuster, geometric center of a box, (x, y, z)
    var position: Position
    // the final result of adjuster
    var facing: Direction?
    
    var width: Float
    var length: Float // for window/door, 0
    var height: Float // for floor, 0
    init(type: FurnitureType, position: (Float?, Float?, Float?) = (nil, nil, nil), facing: Direction? = nil, width: Float, length: Float = 0, height: Float = 0) {
        self.type = type
        self.position = Position(x: position.0, y: position.1, z: position.2)
        self.width = width
        self.length = length
        self.height = height
    }
}

struct AttachedResult: Codable {
    var length: Float = 0 // for convenience, length >= width in any case
    var width: Float = 0
    var doors: [Furniture]
    var windows: [Furniture]
    var beds: [Furniture]
    var desks: [Furniture]
    
    init() {
        self.doors = []
        self.windows = []
        self.beds = []
        self.desks = []
    }
    
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
        
        var rotate: Float = 0
        for i in 0..<(room?.walls.count ?? 0) {
            let wall = room!.walls[i]
            if wall.dimensions.x > length - 0.1 { // the longest wall
                let newNode = SCNNode(geometry: SCNSphere(radius: 0.1))
                newNode.simdTransform = wall.transform
                newNode.position = SCNVector3(newNode.position.x + delta.0, newNode.position.y + delta.1, newNode.position.z + delta.2)
                print("find the longest wall: \(newNode.position)")
                let a = newNode.position.x
                let b = newNode.position.z
                if (a > 0 && b > 0) || (a < 0 && b < 0) {
                    rotate = atanf(a / b)
                } else if (a > 0 && b < 0) || (a < 0 && b > 0) {
                    rotate = Float.pi + atanf(a / b)
                } else if b == 0 {
                    rotate = Float.pi / 2
                }
                break
            }
        }
        if let room = self.room {
            // question: whether it should be better if we suppose to have only one door
            for door in room.doors {
                let tempDoor = SCNNode()
                tempDoor.simdTransform = door.transform
                let td = tempDoor.position
                tempDoor.position = SCNVector3(td.x + delta.0, td.y + delta.1, td.z + delta.2)
//                print("postion before: \(tempDoor.position)")
                tempDoor.simdRotate(by: simd_quatf(generateYawRotationMatrix(rotate)), aroundTarget: simd_float3(0, 0, 0))
//                print("rotate!: \(rotate), postion now: \(tempDoor.position)")
                
                doors.append(Furniture(type: FurnitureType.Door, position: (tempDoor.position.x, tempDoor.position.y, tempDoor.position.z), width: door.dimensions.x, height: door.dimensions.y))
            }
            for window in room.windows {
                let tempWindow = SCNNode()
                tempWindow.simdTransform = window.transform
                let tw = tempWindow.position
                tempWindow.position = SCNVector3(tw.x + delta.0, tw.y + delta.1, tw.z + delta.2)
//                print("postion before: \(tempWindow.position)")
                tempWindow.simdRotate(by: simd_quatf(generateYawRotationMatrix(rotate)), aroundTarget: simd_float3(0, 0, 0))
//                print("rotate!: \(rotate), postion now: \(tempWindow.position)")
                windows.append(Furniture(type: FurnitureType.Window, position: (tempWindow.position.x, tempWindow.position.y, tempWindow.position.z), width: window.dimensions.x, height: window.dimensions.y))
            }
            for obj in room.objects {
                let wid = obj.dimensions.x
                let len = obj.dimensions.z
                let height = obj.dimensions.y
                switch obj.category {
                case .bed:
                    beds.append(Furniture(type: FurnitureType.Bed, width: wid, length: len, height: height))
                case .table:
                    tables.append(Furniture(type: FurnitureType.Table, width: wid, length: len, height: height))
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
            tables.append(Furniture(type: FurnitureType.Table, width: 0.5, length: 1, height: 1)) // default size of a table
        }
        while beds.count < requiredNum {
            beds.append(Furniture(type: FurnitureType.Table, width: 1.5, length: 2, height: 0.5)) // default size of a bed
        }
        
    }
    
    // todo: before smartAdjust, we need to check whether the survey is completed, if not, we need to set some default value/let users select again
    
    mutating func smartAdjust(){
        // length corresponds to x axis
        // width corresponds to z axis
        
        // Game PLAN
        // If you have a roommate we place your beds as specified together/apart and automatically put all furniture we can on the outside walls
        // If you do not have a roommate, we attempt to place object under window, orientate bed, and then place remaining furniture on the outside of the room
        
        var beds1: Furniture = Furniture(type: FurnitureType.Bed, width: 1.5)
        var beds2 : Furniture = Furniture(type: FurnitureType.Bed, width: 1.5)
        var tables1: Furniture = Furniture(type: FurnitureType.Table, width: 1)
        var tables2: Furniture = Furniture(type: FurnitureType.Table, width: 1)
        var windowindex: Int = -1
        
        if let hasRoommate {
            if hasRoommate { // 2 people in room
                if let bedsTogether {
                    if  bedsTogether {
                        // bed positions next to each other on West Wall towards East wall
                        if beds[0].width + beds[1].width <= width {
                            beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2 + beds[0].length/2, beds[0].height/2, -width/2 + beds[0].width/2), facing: Direction.East, width: beds[0].width, length: beds[0].length, height: beds[0].height))
                            beds2 = (Furniture(type: FurnitureType.Bed, position: (-length/2 + beds[1].length/2, beds[1].height/2, -width/2 + beds[0].width + beds[1].width/2), facing: Direction.East, width: beds[1].width, length: beds[1].length, height: beds[1].height))
                            // position desk on East Wall
                            if (beds[0].length + tables[0].width >= length) {
                                tables1 = (Furniture(type: FurnitureType.Table, position: (length/2 - tables[0].width/2, tables[0].height/2, -width/2 + tables[0].length/2), facing: Direction.West, width: tables[0].width, length: tables[0].length, height: tables[0].height))
                                // position desk 2 on east wall
                                if tables[0].length + tables[1].length <= width {
                                    tables2 = (Furniture(type: FurnitureType.Bed, position: (length/2 - tables[1].width/2, tables[1].height/2, width/2 - tables[1].width/2), facing: Direction.West, width: tables[1].width, length: tables[1].length, height: tables[1].height))
                                }
                                else if (beds[0].width + beds[1].width + tables[2].width <= width){ // try to place 2nd deskon top wall
                                    tables2 = (Furniture(type: FurnitureType.Bed, position: (length/2 - tables[1].width - tables[2].width/2 - 0.5, tables[1].height/2, width/2 - tables[2].width/2), facing: Direction.South, width: tables[1].width, length: tables[1].length, height: tables[1].height))
                                }
                            }
                        }
                        else if (beds[0].width + beds[1].width <= length && beds[0].length <= width && beds[1].length <= width) {
                            //poisiton beds next to each other on the south wall
                            beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2 + beds[0].width/2, beds[0].height/2, width/2 - beds[0].length/2), facing: Direction.North, width: beds[0].width, length: beds[0].length, height: beds[0].height))
                            beds2 = (Furniture(type: FurnitureType.Bed, position: (-length/2 + beds[0].width + beds[1].width/2, beds[1].height/2, width/2 - beds[1].length/2), facing: Direction.North, width: beds[1].width, length: beds[1].length, height: beds[1].height))
                            // place desks on North wall next to each other
                            if (beds[0].length + tables[0].width <= width && beds[1].length + tables[1].width <= width) {
                                tables1 = (Furniture(type: FurnitureType.Table, position: (-length/2 + tables[0].length/2, tables[0].height/2, -width/2 + tables[0].width/2), facing: Direction.South, width: tables[0].width, length: tables[0].length, height: tables[0].height))
                                tables2 = (Furniture(type: FurnitureType.Table, position: (-length/2 + tables[0].length + tables[1].length/2, tables[1].height/2, -width/2 + tables[1].width/2), facing: Direction.South, width: tables[1].width, length: tables[1].length, height: tables[1].height))
                            }
                            // position desks on East wall next to each other
                            else if (tables[0].length + tables[1].length <= width && beds[0].width + beds[1].width + max(tables[0].width, tables[1].width) <= length ) {
                                tables1 = (Furniture(type: FurnitureType.Table, position: (length/2 - tables[0].width/2, tables[0].height/2, -width/2 + tables[0].length/2), facing: Direction.West, width: tables[0].width, length: tables[0].length, height: tables[0].height))
                                tables2 = (Furniture(type: FurnitureType.Table, position: (length/2 - tables[1].width/2, tables[1].height/2, width/2 - tables[1].length/2), facing: Direction.West, width: tables[1].width, length: tables[1].length, height: tables[1].height))
                                
                            }
                        }
                    }
                    else  { // 2 beds apart on left wall and on right wall, place desks on top wall and bottom wall !!!!
                        print("beds - apart")
                        if (beds[0].length <= width && beds[0].width + beds[1].width <= length) {
                            print("beds on left and right wall, on south wall")
                            beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2 + beds[0].width/2, beds[0].height/2, width/2 - beds[0].length/2), facing: Direction.North, width: beds[0].width, length: beds[0].length, height: beds[0].height))
                            beds2 = (Furniture(type: FurnitureType.Bed, position: (length/2 - beds[1].width/2, beds[1].height/2, width/2 - beds[1].length/2), facing: Direction.North, width: beds[1].width, length: beds[1].length, height: beds[1].height))
                            // ensure tables fit
                            if (beds[0].width + beds[1].width + max(tables[0].length, tables[1].length) <= length) {
                                tables1 = (Furniture(type: FurnitureType.Table, position: (-length/2 + beds[0].width + tables[0].width/2, tables[0].height/2, -width/2), facing: Direction.South, width: tables[0].width, length: tables[0].length, height: tables[0].height))
                                tables2 = (Furniture(type: FurnitureType.Table, position: (-length/2 + beds[0].width + tables[1].width/2, tables[1].height/2, width/2), facing: Direction.North, width: tables[1].width, length: tables[1].length, height: tables[1].height))
                            }
                        }
                        // 2 beds apart of top and bottom wall facing East Wall
                        else if (beds[0].length < length && beds[0].width + beds[1].width <= width) {
                            print("beds on top and bottom wall")
                            beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2 + beds[0].length/2, beds[0].height/2, -width/2 + beds[0].width/2), facing: Direction.East, width: beds[0].width, length: beds[0].length, height: beds[0].height))
                            beds2 = (Furniture(type: FurnitureType.Bed, position: (-length/2 + beds[1].length/2, beds[1].height/2, width/2 - beds[1].width/2), facing: Direction.East, width: beds[1].width, length: beds[1].length, height: beds[1].height))
                            // place desks on right wall
                            if (max(beds[0].length, beds[1].length) + max(tables[0].width, tables[1].width) <= length && tables[0].length + tables[1].length <= width) {
                                tables1 = (Furniture(type: FurnitureType.Table, position: (length/2 - tables[0].width/2, tables[0].height/2, -width/2 + tables[0].length/2), facing: Direction.West, width: tables[0].width, length: tables[0].length, height: tables[0].height))
                                tables2 = (Furniture(type: FurnitureType.Table, position: (-length/2 + tables[1].width/2, tables[1].height/2, width/2 - tables[1].length/2), facing: Direction.West, width: tables[1].width, length: tables[1].length, height: tables[1].height))
                            }
                        }
                    }
                } // if let bedsTogether
            } // if has roommate
        } // if let has roomamate
        
        // for skeletal just simply place bed
        var for_skeletal: Bool = true
        if let hasRoommate {
            if !hasRoommate && for_skeletal {
                if beds[0].width + tables[0].width <= length {
                    beds1 = (Furniture(type: FurnitureType.Bed, position: (length/2 - beds[0].width/2, beds[0].height/2, -width/2 + beds[0].length/2), facing: Direction.South, width: beds[0].width, length: beds[0].length, height: beds[0].height))
                    tables1 = (Furniture(type: FurnitureType.Table, position: (-length/2 + tables[0].width/2, tables[0].height/2, 0), facing: Direction.East, width: tables[0].width, length: tables[0].length, height: tables[0].height))
                }
            }
            else { // 1 people in room for MVP
                // For more complicated Algo for MVP
                // table1 is the users desk
                if windows.count > 0 {
                    if let objectByWindow {
                        if objectByWindow == "Desk" {
                            tables1 = (Furniture(type: FurnitureType.Table, position: (windows[0].position.x, 0, windows[0].position.z), facing: windows[0].facing, width: tables[0].width, length: tables[0].length))
                        }
                        if objectByWindow == "Bed" {
                            // if there are multiple windows place bed under first window possible, length >= width guaranteed
                            var count = 0
                            for window in windows {
                                if width >= beds[0].length {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (window.position.x, 0, window.position.z), width: beds[0].width, length: beds[0].length, height: beds[0].height))
                                    var temp: Direction? = nil
                                    if window.facing == Direction.East {
                                        temp = Direction.West
                                    }
                                    if window.facing == Direction.West {
                                        temp = Direction.East
                                    }
                                    if window.facing == Direction.South {
                                        temp = Direction.North
                                    }
                                    if window.facing == Direction.North {
                                        temp = Direction.South
                                    }
                                    windowindex = count
                                    tables1 = (Furniture(type: FurnitureType.Table, position: (-1 * window.position.x!, 0, -1 * window.position.z!), facing: temp, width: tables[0].width, length: tables[0].length, height: tables[0].height))
                                    break
                                    
                                }
                                count = count + 1
                            } // for
                        }
                    }
                } // windows.count > 0
                // check orientation of bed
                if let bedFacingDoor {
                    if bedFacingDoor && doors.count >= 1 {
                        if let objectByWindow {
                            if objectByWindow == "Desk" {
                                // bed has not been placed anywhere yet
                                // door is on the left wall
                                print("DOORS POSITION for bed across from door", doors[0].position.x, doors[0].position.y, doors[0].position.z)
                                if (doors[0].position.x == -length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (length/2, 0, 0), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on right wall
                                else if (doors[0].position.x == length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2, 0, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on bottom wall -> in last two cases bed could be unplaced
                                else if (doors[0].position.z == -width/2 && width >= beds[0].length) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (0, 0, width/2), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on top wall
                                else if (doors[0].position.z == width/2 && width >= beds[0].length) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (0, 0, -width/2), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                            }
                            else if objectByWindow == "Bed" && windowindex != -1 {
                                // object by window is bed, rotate bed if possible
                                // what would happen if bed hadnt been placed?
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (windows[windowindex].position.x, 0, windows[windowindex].position.z), width: beds[0].width, length: beds[0].length))
                                let x = beds1.position.x
                                let z = beds1.position.z
                                
                                if (doors[0].position.x == -length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on right wall
                                else if (doors[0].position.x == length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on bottom wall -> in last two cases bed could be unplaced
                                else if (doors[0].position.z == -width/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                    
                                }
                                // door is on top wall
                                else if (doors[0].position.z == width/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                            }
                        }
                    }
                    if !bedFacingDoor {
                        if objectByWindow == "Desk" { // bed has not been placed anywhere yet
                            // door is on the left or right wall, place bed on bottom wall
                            if (doors[0].position.x == -length/2 || doors[0].position.x == length/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (0, 0, -width/2), facing: Direction.North, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on bottom or top wall, place bed on left wall
                            else if (doors[0].position.y == -width/2 && doors[0].position.y == width/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2, 0, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                            }
                        }
                        else if objectByWindow == "Bed" && windowindex != -1 {
                            // object by window is bed, rotate bed if possible away from door, // what would happen if bed hadnt been placed?
                            beds1 = (Furniture(type: FurnitureType.Bed, position: (windows[windowindex].position.x, 0, windows[windowindex].position.z), width: beds[0].width, length: beds[0].length))
                            let x = beds1.position.x
                            let z = beds1.position.z
                            // door is on left wall
                            if (doors[0].position.x == -length/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on right wall
                            else if (doors[0].position.x == length/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on bottom wall
                            else if (doors[0].position.y == -width/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on top wall
                            else if (doors[0].position.y == width/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, 0, z), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                            }
                        }
                    }
                }
            }
        }
//        print(beds1)
//        print(tables1)
        
        beds[0] = beds1
        tables[0] = tables1
        if let hasRoommate {
            if hasRoommate {
                beds[1] = beds2
                tables[1] = tables2
            }
        }
    
    }
    
    func generateResult() -> AttachedResult {
        return AttachedResult(length: length, width: width, doors: doors, windows: windows, beds: beds, desks: tables)
    }
}
