//
//  BlockNode.swift
//  CatNap
//
//  Created by Tbxark on 09/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

class BlockNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    
    func didMoveToScene() {
        isUserInteractionEnabled = true
        physicsBody?.categoryBitMask = PhysicsCategory.block
        physicsBody?.collisionBitMask = PhysicsCategory.block | PhysicsCategory.cat | PhysicsCategory.edge
    }
    
    func interact() {
        isUserInteractionEnabled = false
        run(SKAction.sequence([SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
                               SKAction.scale(to: 0.8, duration: 0.1),
                               SKAction.removeFromParent()]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
}
