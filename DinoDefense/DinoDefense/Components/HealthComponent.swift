//
//  HealthComponent.swift
//  DinoDefense
//
//  Created by Tbxark on 13/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class HealthComponent: GKComponent {

    let fullHealth: Int
    var health: Int
    let healthBarFullWidth: CGFloat
    let healthBar: SKShapeNode
    let soundAction = SKAction.playSoundFileNamed("Hit.mp3", waitForCompletion: false)
    
    init(parentNode: SKNode, barWidth: CGFloat, barOffset: CGFloat, health: Int) {
        self.fullHealth = health
        self.health = health
        self.healthBarFullWidth = barWidth
        healthBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: 4), cornerRadius: 2)
        healthBar.fillColor = UIColor.green
        healthBar.strokeColor = UIColor.green
        healthBar.position = CGPoint.init(x: 0, y: barOffset)
        parentNode.addChild(healthBar)
        healthBar.isHidden = true
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func takeDamage(damage: Int) -> Bool {
        health = max(0, health - damage)
        healthBar.isHidden = false
        let scale = CGFloat(health)/CGFloat(fullHealth)
        let scaleAction = SKAction.scaleX(to: scale, duration: 0.5)
        healthBar.run(SKAction.group([scaleAction, soundAction]))
        return health == 0
    }
}
