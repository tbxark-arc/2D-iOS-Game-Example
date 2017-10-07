//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Tbxark on 07/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenuScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "MainMenu")
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(bg)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneTap()
    }
    
    private func sceneTap() {
        let scene = GameScene(size: size)
        scene.scaleMode = scaleMode
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
        view?.presentScene(scene, transition: reveal)
    }
}
