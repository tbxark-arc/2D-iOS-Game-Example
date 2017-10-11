//
//  HookNode.swift
//  CatNap
//
//  Created by Tbxark on 10/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit


class HookNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    private var hookNode = SKSpriteNode.init(imageNamed: "hook")
    private var ropeNode = SKSpriteNode.init(imageNamed: "rope")
    private var hookJoint: SKPhysicsJointFixed!
    var isHooked: Bool {
        return hookJoint != nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func interact() {
        
    }

    func didMoveToScene() {
        isUserInteractionEnabled = true
        guard let scene = scene else { return }
        let ceillingFix = SKPhysicsJointFixed.joint(withBodyA: scene.physicsBody!,
                                                    bodyB: physicsBody!,
                                                    anchor: CGPoint.zero)
        scene.physicsWorld.add(ceillingFix)
        
        ropeNode.anchorPoint = CGPoint.init(x: 0, y: 0.5)
        ropeNode.zRotation = CGFloat(270).degreesToRadians()
        ropeNode.position = position
        scene.addChild(ropeNode)
        
        
        hookNode.position = CGPoint(x: position.x, y: position.y - ropeNode.size.width)
        hookNode.physicsBody = SKPhysicsBody(circleOfRadius: hookNode.size.width/2)
        hookNode.physicsBody?.categoryBitMask = PhysicsCategory.hook
        hookNode.physicsBody?.contactTestBitMask = PhysicsCategory.cat
        hookNode.physicsBody?.collisionBitMask = PhysicsCategory.none
        scene.addChild(hookNode)
        
        let hookPosition = CGPoint(x: hookNode.position.x, y: hookNode.position.y + hookNode.size.height/2)
        let repoJoin = SKPhysicsJointSpring.joint(withBodyA: physicsBody!, bodyB: hookNode.physicsBody!, anchorA: position, anchorB: hookPosition)
        scene.physicsWorld.add(repoJoin)
        
        let range = SKRange.init(lowerLimit: 0, upperLimit: 0)
        let orientConstraint = SKConstraint.orient(to: hookNode, offset: range)
        ropeNode.constraints = [orientConstraint]
        hookNode.physicsBody?.applyImpulse(CGVector.init(dx: 50, dy: 0))
        
        NotificationCenter.default.addObserver(forName: kCatTappedNotification, object: nil, queue: OperationQueue.main) {[weak self] (_) in
            guard let `self` = self, self.isHooked else { return }
            self.releaseCat()
        }
    }

    func hookCat(cat: SKNode) {
        hookNode.physicsBody?.velocity = CGVector.zero
        hookNode.physicsBody?.angularVelocity = 0

        cat.parent!.physicsBody?.velocity = CGVector.zero
        cat.parent!.physicsBody?.angularVelocity = 0
        
        let pinPoint = CGPoint(x: hookNode.position.x, y: hookNode.position.y + hookNode.size.height/2)
        hookJoint  = SKPhysicsJointFixed.joint(withBodyA: cat.parent!.physicsBody!, bodyB: hookNode.physicsBody!, anchor: pinPoint)
        scene?.physicsWorld.add(hookJoint)
        hookNode.physicsBody?.contactTestBitMask = PhysicsCategory.none
    }

    
    
    func releaseCat() {
        hookNode.physicsBody?.categoryBitMask = PhysicsCategory.none
        hookNode.physicsBody?.contactTestBitMask = PhysicsCategory.none
        hookJoint.bodyA.node?.zRotation = 0
        hookJoint.bodyB.node?.zRotation = 0
        scene?.physicsWorld.remove(hookJoint)
        hookJoint = nil
    }

}
