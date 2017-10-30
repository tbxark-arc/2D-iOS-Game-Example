//
//  GameViewController.swift
//  DinoDefense
//
//  Created by Toby Stephens on 26/09/2015.
//  Copyright © 2015 razeware. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetGame()
    }
    
    func resetGame() {
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = SKView.init(frame: view.bounds)
            view.addSubview(skView)
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.showsPhysics = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        }
    }
    
    override var shouldAutorotate: Bool { return true}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override var prefersStatusBarHidden: Bool { return true}
}

