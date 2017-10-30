//
//  DinosaurEntity.swift
//  DinoDefense
//
//  Created by Tbxark on 12/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

enum DinosaurType: String {
    case TRex = "T-Rex"
    case Triceratops = "Triceratops"
    case TRexBoss = "T-RexBoss"
    
    var health: Int {
        switch self {
        case .TRex: return 60
        case .Triceratops: return 40
        case .TRexBoss: return 1000
        }
    }
    
    var speed: Float {
        switch self {
        case .TRex: return 100
        case .Triceratops: return 150
        case .TRexBoss: return 50
        }
    }
    
    var size: CGSize {
        switch self {
        case .TRex, .TRexBoss:
            return CGSize.init(width: 203, height: 110)
        case .Triceratops:
            return CGSize.init(width: 142, height: 74)
        }
    }
}

class DinosaurEntity: GKEntity {
    let dinosaurType: DinosaurType
    private(set) var spriteComponent: SpriteComponent!
    private(set) var animationComponent: AnimationComponent!
    private(set) var shadowComponent: ShadowComponent!
    private(set) var healthComponent: HealthComponent!
    
    init(dinosaurType: DinosaurType) {
        self.dinosaurType = dinosaurType
        super.init()
        let textureAtlas = SKTextureAtlas(named: dinosaurType.rawValue)
        let defaultTexture = textureAtlas.textureNamed("Walk__01.png")
        let textureSize = dinosaurType.size
        let shadowSize = CGSize(width: textureSize.width, height: textureSize.height * 0.3)
        let animations = AnimationComponent.loadAnimation(textureAtlas: textureAtlas,
                                                          states: [AnimationState.dead : false,
                                                                   AnimationState.walk : true,
                                                                   AnimationState.hit  : false])
        
        shadowComponent = ShadowComponent(size: shadowSize, offset: CGPoint(x: 0, y: -textureSize.height/2 + shadowSize.height/2))
        spriteComponent = SpriteComponent(entity: self, texture: defaultTexture, size: textureSize)
        animationComponent = AnimationComponent(node: spriteComponent.node, textureSize: textureSize, animations: animations)
        healthComponent = HealthComponent(parentNode: spriteComponent.node, barWidth: textureSize.width, barOffset: textureSize.height/2 + 10, health: dinosaurType.health)
        addComponent(spriteComponent)
        addComponent(shadowComponent)
        addComponent(animationComponent)
        
        
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
