//
//  GameViewController.swift
//  DropCharge
//
//  Created by Tbxark on 11/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let scene = GameScene(fileNamed: "GameScene"),
            let skView = view as? SKView {
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }

}
