//
//  ObstacleEntity.swift
//  DinoDefense
//
//  Created by Tbxark on 15/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit

class ObstacleEntity: GKEntity {
    
    var spriteComponent: SpriteComponent!
    var shadowComponent: ShadowComponent!
    
    
    init(withNode node: SKSpriteNode) {
        super.init()
        spriteComponent = SpriteComponent(entity: self, texture: node.texture!, size: node.size)
        addComponent(spriteComponent)
        
        let shadowSize = CGSize(width: node.size.width*1.1, height: node.size.height * 0.6)
        shadowComponent = ShadowComponent(size: shadowSize, offset: CGPoint(x: 0.0, y: -node.size.height*0.35))
        addComponent(shadowComponent)
        
        spriteComponent.node.position = node.position
        node.position = CGPoint.zero
        spriteComponent.node.addChild(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



