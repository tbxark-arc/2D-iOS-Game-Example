//
//  MessageNode.swift
//  CatNap
//
//  Created by Tbxark on 09/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

class MessageNode: SKLabelNode {
     init(message: String) {
        let name = UIFont.boldSystemFont(ofSize: 50).fontName
        super.init()
        fontName = name
        text = message
        fontSize = 256
        fontColor = SKColor.gray
        zPosition = 100
        
        let front = SKLabelNode(fontNamed: name)
        front.text = message
        front.fontSize = 256
        front.fontColor = SKColor.white
        front.position = CGPoint.init(x: -2, y: -2)
        addChild(front)
        
        physicsBody = SKPhysicsBody.init(circleOfRadius: 10)
        physicsBody?.collisionBitMask = PhysicsCategory.edge
        physicsBody?.categoryBitMask = PhysicsCategory.label
        physicsBody?.restitution = 0.7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
