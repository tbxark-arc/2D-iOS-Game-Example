//
//  SpringNode.swift
//  CatNap
//
//  Created by Tbxark on 10/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

class SpringNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    func didMoveToScene() {
        isUserInteractionEnabled = true
        physicsBody?.categoryBitMask = PhysicsCategory.spring
        
    }
    func interact() {
        isUserInteractionEnabled = false
        guard let phy = physicsBody else { return }
        
        run(SKAction.sequence([
            SKAction.group([
                SKAction.sequence([
                    SKAction.scaleY(to: 0.8, duration: 0.2),
                    SKAction.scaleY(to: 1.2, duration: 0.2),
                    SKAction.scaleY(to: 1, duration: 0.2)
                    ]),
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.2),
                    SKAction.run {
                        phy.applyImpulse(CGVector(dx: 0, dy: 300),
                                         at: CGPoint(x: self.size.width/2, y: self.size.height))
                    }
                    ])
                ]),
            SKAction.wait(forDuration: 1),
            SKAction.removeFromParent()
            ]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
}
