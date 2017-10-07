//
//  GameOverScene.swift
//  ZombieConga
//
//  Created by Tbxark on 07/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {

    let won: Bool
    let sound = (win: SKAction.playSoundFileNamed("win.wav", waitForCompletion: false),
                 lose: SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false))
    
    init(size: CGSize, won: Bool) {
        self.won = won
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let nodeBuilder: (Bool) -> SKSpriteNode = { isWin in
            let node = SKSpriteNode(imageNamed: isWin ? "YouWin" : "YouLose")
            return node
        }
        run(won ? sound.win : sound.lose)
        let bgNode = nodeBuilder(won)
        bgNode.position = CGPoint.init(x: size.width / 2, y: size.height / 2)
        addChild(bgNode)
        
        
        let wait = SKAction.wait(forDuration: 3.0)
        let block = SKAction.run {
            let scene = MainMenuScene(size: self.size)
            scene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(scene, transition: reveal)
        }
        run(SKAction.sequence([wait, block]))
    }
}
