//
//  TowerSelectorNode.swift
//  DinoDefense
//
//  Created by Tbxark on 13/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TowerSelectorNode: SKNode {
    var costLabel: SKLabelNode { return childNode(withName: "CostLabel") as! SKLabelNode }
    var towerIcon: SKSpriteNode { return childNode(withName: "TowerIcon") as! SKSpriteNode }
    
    private var showAction = SKAction()
    private var hideAction = SKAction()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setTower(towerType: TowerType, angle: CGFloat) {
        towerIcon.texture = SKTexture(imageNamed: towerType.rawValue)
        towerIcon.name = "Tower_Icon_\(towerType.rawValue)"
        costLabel.text = "\(towerType.cost)"
        
        let rotateAction = SKAction.rotate(byAngle:
            CGFloat.pi * 2,
            duration: 0.2)
        
        let moveAction = SKAction.moveBy(
            x: cos(angle) * 50,
            y: sin(angle) * 50,
            duration: 0.2)
        
        showAction = SKAction.group([rotateAction, moveAction])
        hideAction = showAction.reversed()
    }
    
    
    func show() {
        run(showAction)
    }
    
    func hide(complete: @escaping () -> Void) {
        run(SKAction.sequence([
                hideAction,
                SKAction.run(complete)
            ]))
    }
    
}

