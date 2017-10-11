//
//  GameViewController.swift
//  CatNap
//
//  Created by Tbxark on 07/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let scene = GameScene.newScene(withLevel: 6),
            let view = self.view as! SKView? {
            view.presentScene(scene)
            view.ignoresSiblingOrder = false
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}
