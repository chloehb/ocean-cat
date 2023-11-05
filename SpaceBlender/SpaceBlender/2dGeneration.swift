//
//  2dGeneration.swift
//  SpaceBlender
//
//  Created by 周晓玮 on 10/29/23.
//

//import Foundation
//import RoomPlan
//
//class Walls: SKNode {
//
//  init() {
//    for wall in CapturedRoom.walls {
//      let wallNode = SKNode()
//      addChild(wallNode)
//
//      // Position wallNode
//      wallNode.position.x = -CGFloat(wall.transform.position.x) * 200
//      wallNode.position.y = CGFloat(wall.transform.position.z) * 200
//      wallNode.zRotation = -CGFloat(wall.transform.eulerAngles.z - wall.transform.eulerAngles.y)
//
//      // Create the path for the wall
//      let surfacePath = CGMutablePath()
//      let span = CGFloat(wall.dimensions.x) * 200 / 2
//      surfacePath.move(to: CGPoint(x: -span, y: 0))
//      surfacePath.addLine(to: CGPoint(x: span, y: 0))
//
//      // Draw the wall using an SKShapeNode and the path
//      let wallShape = SKShapeNode(path: surfacePath)
//      wallShape.strokeColor = .white
//      wallShape.lineWidth = 5
//      wallShape.lineCap = .square
//      
//      wallNode.addChild(wallShape)
//    }
//  }
//}
