//
//  WaitingForTap.swift
//  DropCharge
//
//  Created by Tbxark on 11/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameState {
    static func allState(scene: GameScene) -> [GKState] {
        return [ GameState.WaitingForTap(scene: scene),
                 GameState.WaitingForBomb(scene: scene),
                 GameState.Playing(scene: scene),
                 GameState.GameOver(scene: scene)]
    }
    class WaitingForTap: GKState {
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        
        override func didEnter(from previousState: GKState?) {
            guard let ready = scene.fgNode?.childNode(withName: "Ready") else { return }
            let scale = SKAction.scale(to: 1.0, duration: 0.5)
            ready.run(scale)
        }
        
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass is WaitingForBomb.Type
        }
    }

    
    class WaitingForBomb: GKState {
        
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        
        override func didEnter(from previousState: GKState?) {
            guard let state = previousState else {
                return
            }
            if state is WaitingForTap {
                let scale = SKAction.scale(to: 0, duration: 0.4)
                scene.fgNode.childNode(withName: "Title")!.run(scale)
                scene.fgNode.childNode(withName: "Ready")!.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.2),
                    scale
                    ]))
                
                let scaleUp = SKAction.scale(to: 1.25, duration: 0.25)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.25)
                let sequence = SKAction.sequence([scaleUp, scaleDown])
                let repeatSeq = SKAction.repeatForever(sequence)
                scene.fgNode.childNode(withName: "Bomb")!.run(SKAction.unhide())
                scene.fgNode.childNode(withName: "Bomb")!.run(repeatSeq)
                
            }
        }
        
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass is Playing.Type
        }
        
        override func willExit(to nextState: GKState) {
            if nextState is Playing, let bomb = scene.fgNode.childNode(withName: "Bomb") {
//                !.removeFromParent()
                let explosion = GameScene.explosion(intensity: 2)
                explosion.position = bomb.position
                scene.fgNode.addChild(explosion)
                bomb.removeFromParent()
            }
        }
    }
    
    
    class Playing: GKState {
        
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        
        override func didEnter(from previousState: GKState?) {
            guard let state = previousState else { return }
            if state is WaitingForBomb {
                scene.player.physicsBody?.isDynamic = true
                scene.superBoostPlayer()
            }
        }
        
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass is GameOver.Type
        }
        
        override func update(deltaTime seconds: TimeInterval) {
            scene.updateCamera()
            scene.updatePlayer()
            scene.updateLava(dt: seconds)
            scene.updateCollisionLava()
            scene.updateLevel()
        }
    }

    
    class GameOver: GKState {
        
        unowned let scene: GameScene
        init(scene: GameScene) {
            self.scene = scene
            super.init()
        }
        
        
        override func didEnter(from previousState: GKState?) {
            guard let state = previousState else { return }
            if state is Playing {
                scene.physicsWorld.contactDelegate = nil
                scene.player.physicsBody?.isDynamic = false
                
                let moveUpAction = SKAction.moveBy(x: 0, y: scene.size.height / 2, duration: 0.5)
                moveUpAction.timingMode = SKActionTimingMode.easeOut
                let moveDownAction = SKAction.moveBy(x: 0, y: -(scene.size.height * 1.5), duration: 1)
                moveDownAction.timingMode = SKActionTimingMode.easeIn
                let  seq = SKAction.sequence([moveUpAction, moveDownAction])
                scene.player.run(seq)
                
                let gameOver = SKSpriteNode.init(imageNamed: "GameOver")
                gameOver.position = scene.cameraPosition
                gameOver.zPosition = 10
                scene.addChild(gameOver)
            }
        }
        
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass is WaitingForTap.Type
        }
    }
}

