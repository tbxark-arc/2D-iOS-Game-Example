//
//  BedNode.swift
//  CatNap
//
//  Created by Tbxark on 09/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

class BedNode: SKSpriteNode, CustomNodeEvents {
    func didMoveToScene() {
        if let phy = childNode(withName: "bedPhy") {
            phy.physicsBody?.categoryBitMask = PhysicsCategory.bed
            phy.physicsBody?.collisionBitMask = PhysicsCategory.none
            phy.physicsBody?.isDynamic = false
        } else {
            let bedBodySize = CGSize(width: 40, height: 30.0)
            let phy = SKPhysicsBody(rectangleOf: bedBodySize)
            phy.isDynamic = false
            phy.categoryBitMask = PhysicsCategory.bed
            phy.collisionBitMask = PhysicsCategory.none
            physicsBody = phy
        }
    }
}
