//
//  FiringComponent.swift
//  DinoDefense
//
//  Created by Tbxark on 13/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class FiringComponent: GKComponent {
    let towerType: TowerType
    let parentNode: SKNode
    var currentTarget: DinosaurEntity?
    var timeTillNextShot: TimeInterval = 0
    init(towerType: TowerType, parentNode: SKNode) {
        self.towerType = towerType
        self.parentNode = parentNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let target = currentTarget else { return }
        timeTillNextShot -= seconds
        if timeTillNextShot > 0 { return }
        timeTillNextShot = TimeInterval(towerType.fireRate)
        
        
        let projectile = ProjectileEntity.init(towerType: towerType)
        let projectileNode = projectile.spriteComponent.node
        projectileNode.position = CGPoint.init(x: 0, y: 50)
        parentNode.addChild(projectileNode)
        
        let targetNode = target.spriteComponent.node
        projectileNode.rotateToFaceNode(targetNode: targetNode, sourceNode: parentNode)
        
        let fireVector = CGVector(dx: targetNode.position.x - parentNode.position.x, dy: targetNode.position.y - parentNode.position.y)
        
        let soundAction = SKAction.playSoundFileNamed("\(towerType.rawValue)Fire.mp3", waitForCompletion: false)
        let fireAction = SKAction.move(by: fireVector, duration: 0.4)
        let removeAction = SKAction.run(projectileNode.removeFromParent)
        let damageAction = SKAction.run {
            _ = target.healthComponent.takeDamage(damage: self.towerType.damage)
        }
        
        projectileNode.run(SKAction.sequence([soundAction, fireAction, damageAction, removeAction]))
        
    }
}

