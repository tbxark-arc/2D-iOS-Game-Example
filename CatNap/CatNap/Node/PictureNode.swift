//
//  PictureNode.swift
//  CatNap
//
//  Created by Tbxark on 10/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

class PictureNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {

    func didMoveToScene() {
        isUserInteractionEnabled = true
        
        let picNode = SKSpriteNode.init(imageNamed: "picture")
        let maskNode = SKSpriteNode.init(imageNamed: "picture-frame-mask")
        
        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.addChild(picNode)
        addChild(cropNode)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func interact() {
        isUserInteractionEnabled = false
        physicsBody?.isDynamic = true
    }
}
