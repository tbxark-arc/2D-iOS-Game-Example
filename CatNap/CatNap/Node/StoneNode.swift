//
//  StoneNode.swift
//  CatNap
//
//  Created by Tbxark on 10/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

class StoneNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func didMoveToScene() {
        guard let scene = scene,
            let parent = parent,
        scene == parent else { return }
        scene.addChild(StoneNode.makeCompoundNode(inScene: scene))
    }
    
    func interact() {
        isUserInteractionEnabled  = false
        run(SKAction.sequence([
                SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
                SKAction.removeFromParent()
            ]))
    }
    
    static func makeCompoundNode(inScene scene: SKScene) -> SKNode {
        let compound = StoneNode()
        compound.zPosition = -1
        for stone in scene.children.filter({ $0 is StoneNode }) {
            stone.removeFromParent()
            compound.addChild(stone)
        }
        let bodies = compound.children.map { SKPhysicsBody(rectangleOf: $0.frame.size, center: $0.position) }
        let phy = SKPhysicsBody(bodies: bodies)
        phy.collisionBitMask = PhysicsCategory.edge | PhysicsCategory.cat | PhysicsCategory.block
        phy.categoryBitMask = PhysicsCategory.block
        compound.isUserInteractionEnabled = true
        compound.zPosition = 1
        compound.physicsBody = phy
        return compound
    }
    
    
}
