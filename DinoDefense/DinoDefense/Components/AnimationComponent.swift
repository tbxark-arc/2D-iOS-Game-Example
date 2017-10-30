//
//  AnimationComponent.swift
//  DinoDefense
//
//  Created by Tbxark on 12/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


enum AnimationState: String {
    case idle = "Idle"
    case walk = "Walk"
    case hit = "Hit"
    case dead = "Dead"
    case attacking = "Attacking"

    static let allStates: [AnimationState] = [.idle, .walk, .hit, .dead, .attacking]
}

struct Animation {
    let animationStete: AnimationState
    let textures: [SKTexture]
    let repeatTextureForever: Bool
}

class AnimationComponent: GKComponent {
    let node: SKSpriteNode
    private var animations: [AnimationState: Animation]
    private(set) var currentAnimation: Animation?
    var requestAnimationState: AnimationState?
    
    init(node: SKSpriteNode, textureSize: CGSize, animations: [AnimationState: Animation]) {
        self.node = node
        self.animations = animations
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func runAnimationForAnimationState(_ state: AnimationState) {
        let key = "Animation"
        let timePerFrame = TimeInterval(1/30.0)
        if let c = currentAnimation, c.animationStete == state {
            return
        }
        guard let animation = animations[state] else { return }
        node.removeAction(forKey: key)
        var action = SKAction.animate(with: animation.textures, timePerFrame: timePerFrame)
        if animation.repeatTextureForever {
            action = SKAction.repeatForever(action)
        }
        node.run(action, withKey: key)
        currentAnimation = animation
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        if let state = requestAnimationState {
            runAnimationForAnimationState(state)
            requestAnimationState = nil
        }
    }
    
    
    static func animationFromAtlas(altas: SKTextureAtlas,
                                   withImageIdentifier identifier: String,
                                   forAnimationState state: AnimationState,
                                   repeatForever: Bool) -> Animation {
        let texture = altas.textureNames
            .filter({ $0.hasPrefix("\(identifier)__")})
            .sorted()
            .map( { altas.textureNamed($0) } )
        
        return Animation(animationStete: state, textures: texture, repeatTextureForever: repeatForever)
    }
    
    static func loadAnimation(textureAtlas: SKTextureAtlas, states: [AnimationState: Bool]) -> [AnimationState: Animation] {
        var temp = [AnimationState: Animation]()
        for (state, repeatFlag) in states {
            let animations = AnimationComponent.animationFromAtlas(altas: textureAtlas,
                                                                   withImageIdentifier: state.rawValue,
                                                                   forAnimationState: state,
                                                                   repeatForever: repeatFlag)
            if animations.textures.isEmpty { continue }
            temp[state] = animations
        }
        return temp
    }

}
