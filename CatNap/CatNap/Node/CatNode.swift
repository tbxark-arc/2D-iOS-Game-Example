//
//  CatNode.swift
//  CatNap
//
//  Created by Tbxark on 09/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit


let kCatTappedNotification = Notification.Name("kCatTappedNotification")

class CatNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    let phybody: SKPhysicsBody = {
        let catBgTexture = SKTexture(imageNamed: "cat_body_outline")
        let phyb = SKPhysicsBody(texture: catBgTexture, size: catBgTexture.size())
        phyb.categoryBitMask = PhysicsCategory.cat
        phyb.collisionBitMask = PhysicsCategory.bed | PhysicsCategory.block  | PhysicsCategory.edge | PhysicsCategory.spring
        phyb.contactTestBitMask = PhysicsCategory.bed | PhysicsCategory.edge
        phyb.isDynamic = true
        return phyb
    }()
    
    private var isDoingTheDance = false
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func interact() {
        NotificationCenter.default.post(name: kCatTappedNotification, object: nil)
        if DiscoBallNode.isDiscoTime && !isDoingTheDance {
            isDoingTheDance = true
            let move = SKAction.sequence([
                    SKAction.moveBy(x: 80, y: 0, duration: 0.5),
                    SKAction.wait(forDuration: 0.5),
                    SKAction.moveBy(x: -30, y: 0, duration: 0.5)
                ])
            let dance = SKAction.repeat(move, count: 3)
            parent?.run(dance, completion: {
                self.isDoingTheDance = false
            })
        }
    }
    
    
    func didMoveToScene() {
        isUserInteractionEnabled = true
        parent?.physicsBody = phybody
    }
    
    func wakeUp() {

        children.forEach({ $0.removeFromParent() })
        texture = nil
        color = UIColor.clear

        let catWakeUp = SKSpriteNode(fileNamed: "CatWakeUp")!.childNode(withName: "catWakeUp")! as! SKSpriteNode
        catWakeUp.run(SKAction.repeatForever(SKAction.animate(with: [SKTexture(imageNamed: "cat_awake"), SKTexture(imageNamed: "cat_sleepy")], timePerFrame: 0.5)))
        catWakeUp.move(toParent: self)
        catWakeUp.position = CGPoint(x: -30, y: 100)
    }
    
    func sleep(at scenePoint: CGPoint) {
        parent?.physicsBody = nil
        children.forEach({ $0.removeFromParent() })
        texture = nil
        color = UIColor.clear

        let catSleep = SKSpriteNode(fileNamed: "CatCurl")!.childNode(withName: "catCurl")! as! SKSpriteNode
        catSleep.move(toParent: self)
        catSleep.position = CGPoint(x: -30, y: 100)

        
        var localPoint = parent!.convert(scenePoint, from: scene!)
        localPoint.y += frame.size.height/3
        
        run(SKAction.group([
            SKAction.move(to: localPoint, duration: 0.66),
            SKAction.rotate(toAngle: -parent!.zRotation, duration: 0.5),
            SKAction.run({
                print("The cat is fuckking sleep")
            })
            ]))
    }
}
