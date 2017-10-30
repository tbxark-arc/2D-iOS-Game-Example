//
//  ProjectileEntity.swift
//  DinoDefense
//
//  Created by Tbxark on 13/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class ProjectileEntity: GKEntity {
    var spriteComponent: SpriteComponent!
    init(towerType: TowerType) {
        super.init()
        let texture = SKTexture.init(imageNamed: "\(towerType.rawValue)Projectile")
        spriteComponent = SpriteComponent.init(entity: self, texture: texture, size: texture.size())
        addComponent(spriteComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
