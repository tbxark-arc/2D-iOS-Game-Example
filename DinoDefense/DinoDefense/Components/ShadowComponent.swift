//
//  ShadowComponent.swift
//  DinoDefense
//
//  Created by Tbxark on 12/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class ShadowComponent: GKComponent {
    let node: SKShapeNode
    let size: CGSize
    init(size: CGSize, offset: CGPoint) {
        self.size = size
        node = SKShapeNode.init(ellipseOf: size)
        node.fillColor = SKColor.black
        node.strokeColor = SKColor.black
        node.alpha = 0.2
        node.position = offset
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createObstaclesAtPosition(position: CGPoint) -> [GKPolygonObstacle] {
        let centerX = position.x + node.position.x
        let centerY = position.y + node.position.y
        let left = float2(CGPoint(x: centerX - size.width/2, y: centerY))
        let top = float2(CGPoint(x: centerX, y: centerY + size.height/2))
        let right = float2(CGPoint(x: centerX + size.width/2, y : centerY))
        let bottom = float2(CGPoint(x: centerX, y: centerY - size.height/2))
        var vertices = [left, bottom, right, top]
        
        let obstacle = GKPolygonObstacle(__points: &vertices, count: 4)
        return [obstacle]
    }

}
