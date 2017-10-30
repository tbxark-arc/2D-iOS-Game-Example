//
//  PlayerState.swift
//  DropCharge
//
//  Created by Tbxark on 11/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerState {
 
    static func allState(scene: GameScene) -> [GKState] {
        return [ PlayerState.Idle(scene: scene),
                 PlayerState.Jump(scene: scene),
                 PlayerState.Fall(scene: scene),
                 PlayerState.Lava(scene: scene),
                 PlayerState.Dead(scene: scene)
        ]
    }

    class Idle: GKState {
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        override func didEnter(from previousState: GKState?) {
            print("Player is \(NSStringFromClass(self.classForCoder).lowercased())")
            guard let player = scene.player else { return }
            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
            player.physicsBody?.isDynamic = false
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.categoryBitMask = PhysicsCategory.player
            player.physicsBody?.collisionBitMask = 0
        }
    }
    
    class Jump: GKState {
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return true
        }
        override func didEnter(from previousState: GKState?) {
            print("Player is jump")
        }
    }
    class Fall: GKState {
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return true
        }
        override func didEnter(from previousState: GKState?) {
            print("Player is fall")
        }
    }
    
    class Lava: GKState {
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        override func didEnter(from previousState: GKState?) {
            print("Player is lava")
            scene.boostPlayer()
            scene.lives -= 1
        }
    }
    
    class Dead: GKState {
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        override func didEnter(from previousState: GKState?) {
            print("Player is dead")
            scene.player.run(SKAction.group([
                SKAction.rotate(byAngle: CGFloat.pi * 4, duration: 1),
                SKAction.scale(to: 0, duration: 1)
                ])
            )
        }
    }




}
