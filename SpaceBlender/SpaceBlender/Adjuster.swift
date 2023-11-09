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
    init(type: FurnitureType, position: (Float, Float, Float)? = nil, facing: Direction? = nil, width: Float, length: Float = 0, height: Float = 0) {
        self.type = type
        self.position = position
        self.width = width
        self.length = length
        self.height = height
    }
}

struct AttachedResult {
    
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
        // it may be incorrect to assume the length is greater than the width?
        // does it still align to the correct x and y planes - I am assuming width has to do with the x axis and length the y otherwise difficult to ensure furniture fits in a wall
        
        // Game PLAN - simplified for skeletal
        // If you have a roommate we place your beds as specified together/apart and automatically put all furniture we can on the outside walls
        // If you do not have a roommate, we attempt to place object under window, orientate bed, and then place remaining furniture on the outside of the room
        
        var beds1: Furniture
        var beds2 : Furniture
        var tables1: Furniture
        var tables2: Furniture
        var windowindex: Int = -1
        
        if let hasRoommate {
            if hasRoommate { // 2 people in room
                if let bedsTogether {
                    if  bedsTogether {
                        // bed positions next to each other, towards east wall, 1 foot btwn
                        if beds[0].width + beds[1].width + 1 <= width {
                            beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2, 0, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                            beds2 = (Furniture(type: FurnitureType.Bed, position: (-length/2, beds[0].width + 1, 0), facing: Direction.East, width: beds[1].width, length: beds[1].length))
                            tables1 = (Furniture(type: FurnitureType.Table, position: (length/2, 0, 0), facing: Direction.West, width: tables[0].width, length: tables[0].length))
                            if tables[0].length + tables[1].length <= width {
                                tables2 = (Furniture(type: FurnitureType.Bed, position: (length/2, tables[0].width, 0), facing: Direction.West, width: tables[1].width, length: tables[1].length))
                            }
                            else { // place on top wall
                                tables2 = (Furniture(type: FurnitureType.Bed, position: (length/2, width/2, 0), facing: Direction.South, width: tables[1].width, length: tables[1].length))
                            }
                        }
                    }
                }
                else  { // 2 beds apart on left wall and on right wall, place desks on top wall and bottom wall
                    if (beds[0].length < width) {
                        beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2, 0, 0), facing: Direction.South, width: beds[0].width, length: beds[0].length))
                        beds2 = (Furniture(type: FurnitureType.Bed, position: (length/2.0, 0, 0), facing: Direction.South, width: beds[1].width, length: beds[1].length))
                        tables1 = (Furniture(type: FurnitureType.Table, position: (0, -width/2, 0), facing: Direction.North, width: tables[0].width, length: tables[0].length))
                        tables2 = (Furniture(type: FurnitureType.Table, position: (0, width/2, 0), facing: Direction.South, width: tables[0].width, length: tables[0].length))
                    }
                    // 2 beds apart of top and bottom wall, place desks on left and right wall
                    else if (beds[0].length < length) {
                        beds1 = (Furniture(type: FurnitureType.Bed, position: (0, -width/2, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                        beds2 = (Furniture(type: FurnitureType.Bed, position: (0, width/2, 0), facing: Direction.East, width: beds[1].width, length: beds[1].length))
                        tables1 = (Furniture(type: FurnitureType.Table, position: (-length/2, 0, 0), facing: Direction.East, width: tables[0].width, length: tables[0].length))
                        tables2 = (Furniture(type: FurnitureType.Table, position: (length/2, 0, 0), facing: Direction.West, width: tables[1].width, length: tables[1].length))
                    }
                }
            }
            else { // no roommates
                // table1 is the users desk
                if windows.count > 0 {
                    if let objectByWindow {
                        if objectByWindow == "Desk" {
                            tables1 = (Furniture(type: FurnitureType.Table, position: (windows[0].position!.0, windows[0].position!.1, 0), width: tables[0].width, length: tables[0].length))
                        }
                    }
                    if let objectByWindow {
                        if objectByWindow == "Bed" {
                            // if there are multiple windows place bed under first window possible, length >= width guaranteed
                            var count = 0
                            for window in windows {
                                if width >= beds[0].length {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (window.position!.0, window.position!.1, 0), width: beds[0].width, length: beds[0].length))
                                    
                                    // place desk here!!! if on left wall palce on right * -1 would be inverse
                                    tables1 = (Furniture(type: FurnitureType.Table, position: (-1 * window.position!.0, -1 * window.position!.1, 0), width: beds[0].width, length: beds[0].length))
                                    
                                    windowindex = count
                                    break
                                }
                                count = count + 1
                            }
                        }
                    }
                }
                // check orientation of bed
                if let bedFacingDoor {
                    if bedFacingDoor && doors.count >= 1 {
                        if let objectByWindow {
                            if objectByWindow == "Desk" {
                                // bed has not been placed anywhere yet
                                // door is on the left wall
                                if (doors[0].position!.0 == -length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (length/2, 0, 0), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on right wall
                                else if (doors[0].position!.0 == length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2, 0, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on bottom wall -> in last two cases bed could be unplaced
                                else if (doors[0].position!.1 == -width/2 && width >= beds[0].length) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (0, width/2, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on top wall
                                else if (doors[0].position!.1 == width/2 && width >= beds[0].length) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (0, -width/2, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                            }
                            else if objectByWindow == "Bed" && windowindex != -1 {
                                // object by window is bed, rotate bed if possible
                                // what would happen if bed hadnt been placed?
                                
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (windows[windowindex].position!.0, windows[windowindex].position!.1, 0), width: beds[0].width, length: beds[0].length))
                                var x = beds1.position!.0
                                var y = beds1.position!.1
                                
                                if (doors[0].position!.0 == -length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on right wall
                                else if (doors[0].position!.0 == length/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                                // door is on bottom wall -> in last two cases bed could be unplaced
                                else if (doors[0].position!.1 == -width/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                    
                                }
                                // door is on top wall
                                else if (doors[0].position!.1 == width/2) {
                                    beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                                }
                            }
                        }
                    }
                    if !bedFacingDoor {
                        if objectByWindow == "Desk" { // bed has not been placed anywhere yet
                            // door is on the left or right wall, place bed on bottom wall
                            if (doors[0].position!.0 == -length/2 || doors[0].position!.0 == length/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (0, -width/2, 0), facing: Direction.North, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on bottom or top wall, place bed on left wall
                            else if (doors[0].position!.1 == -width/2 && doors[0].position!.1 == width/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (-length/2, 0, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                            }
                        }
                        else if objectByWindow == "Bed" && windowindex != -1 {
                            // object by window is bed, rotate bed if possible away from door, // what would happen if bed hadnt been placed?
                            beds1 = (Furniture(type: FurnitureType.Bed, position: (windows[windowindex].position!.0, windows[windowindex].position!.1, 0), width: beds[0].width, length: beds[0].length))
                            var x = beds1.position!.0
                            var y = beds1.position!.1
                            // door is on left wall
                            if (doors[0].position!.0 == -length/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on right wall
                            else if (doors[0].position!.0 == length/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on bottom wall
                            else if (doors[0].position!.1 == -width/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.West, width: beds[0].width, length: beds[0].length))
                            }
                            // door is on top wall
                            else if (doors[0].position!.1 == width/2) {
                                beds1 = (Furniture(type: FurnitureType.Bed, position: (x, y, 0), facing: Direction.East, width: beds[0].width, length: beds[0].length))
                            }
                        }
                    }
                }
            }
        }
        
        /*
        beds[0] = beds1
        tables[0] = tables1
        if let hasRoommate {
            if hasRoommate {
                beds[1] = beds2
                tables[2] = tables2
            }
        }
         */
        
        // todo: generate an attached record which will be rendered in SceneKit instead of the original capturedroom
        //    func generateResult() ->
    }
}
