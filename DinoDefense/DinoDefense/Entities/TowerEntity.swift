//
//  TowerEntity.swift
//  DinoDefense
//
//  Created by Tbxark on 12/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


enum TowerType: String {
    
    static let allValues =  [wood, rock]
    case wood = "WoodTower"
    case rock = "RockTower"
    
    var fireRate: TimeInterval {
        switch self {
        case .wood: return 1
        case .rock: return 1.5
        }
    }
    
    var damage: Int {
        switch self {
        case .wood: return 20
        case .rock: return 50
        }
    }

    var range: CGFloat {
        switch self {
        case .wood: return 200
        case .rock: return 250
        }
    }

    var cost: Int {
        switch self {
        case .wood: return 50
        case .rock: return 85
        }
    }

    
    static let allValue = [wood, rock]
    
    
}



class TowerEntity: GKEntity {

    let towerType: TowerType
    private(set) var spriteComponent: SpriteComponent!
    private(set) var animationComponent: AnimationComponent!
    private(set) var shadowComponent: ShadowComponent!
    private(set) var firingComponent: FiringComponent!
    
    
    init(towerType: TowerType) {
        self.towerType = towerType
        super.init()
        
        let textureAtlas = SKTextureAtlas.init(named: towerType.rawValue)
        let defaultTexture = textureAtlas.textureNamed("Idle__000")
        let textureSize = CGSize.init(width: 98, height: 140)
        let shadowSize = CGSize.init(width: 98, height: 44)
        
        let animations = AnimationComponent.loadAnimation(textureAtlas: textureAtlas,
                                                          states: [AnimationState.idle : false,
                                                                   AnimationState.attacking : false])


        spriteComponent = SpriteComponent(entity: self, texture: defaultTexture, size: textureSize)
        shadowComponent = ShadowComponent(size: shadowSize, offset: CGPoint(x: 0, y: -textureSize.height/2 + shadowSize.height/2))
        animationComponent = AnimationComponent(node: spriteComponent.node, textureSize: textureSize, animations: animations)
        firingComponent = FiringComponent(towerType: towerType, parentNode: spriteComponent.node)
        
        addComponent(spriteComponent)
        addComponent(shadowComponent)
        addComponent(animationComponent)
        addComponent(firingComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


