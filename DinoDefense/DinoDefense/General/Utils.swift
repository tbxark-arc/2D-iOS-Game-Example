//
//  Utils.swift
//  VillageDefense
//
//  Created by Toby Stephens on 27/07/2015.
//  Copyright © 2015 razeware. All rights reserved.
//

import CoreGraphics
import simd
import SpriteKit

// MARK: Points and vectors
extension CGPoint {
    init(_ point: float2) {
        x = CGFloat(point.x)
        y = CGFloat(point.y)
    }
}
extension float2 {
    init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
    
    func distanceTo(point: float2) -> Float {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        return sqrt((xDist*xDist) + (yDist*yDist))
    }
}

// MARK: Rotate node to face another node
extension SKNode {
    func rotateToFaceNode(targetNode: SKNode, sourceNode: SKNode) {
        print("Source position: \(sourceNode.position)")
        print("Target position: \(targetNode.position)")
        let angle = atan2(targetNode.position.y - sourceNode.position.y, targetNode.position.x - sourceNode.position.x) - (CGFloat.pi / 2)
        print("Angle: \(angle)")
        self.run(SKAction.rotate(toAngle: angle, duration: 0))
    }
}

// MARK: Delay closure
func delay(delay: Double, closure:@escaping ()-> Void) {
    let time =  DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + UInt64(delay * 100) * NSEC_PER_SEC / 100)
    DispatchQueue.main.asyncAfter(deadline: time, execute: closure)
}

// MARK: Distance between nodes
func distanceBetween(nodeA: SKNode, nodeB: SKNode) -> CGFloat {
    return CGFloat(hypotf(Float(nodeB.position.x - nodeA.position.x), Float(nodeB.position.y - nodeA.position.y)));
}



