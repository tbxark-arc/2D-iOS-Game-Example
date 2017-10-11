//
//  GameScene.swift
//  CatNap
//
//  Created by Tbxark on 07/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let none: UInt32   = 0
    static let cat:  UInt32   = 0b1      // 1
    static let block: UInt32  = 0b10     // 2
    static let bed: UInt32    = 0b100    // 4
    static let edge: UInt32   = 0b1000   // 8
    static let label: UInt32  = 0b10000  // 16
    static let spring: UInt32 = 0b100000 // 32
    static let hook: UInt32   = 0b1000000 // 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var currentLevel = 0
    private var catNode: CatNode!
    private var bedNode: BedNode!
    private var hookNode: HookNode?
    
    private var playable: Bool = true
    private var playableRect = CGRect.zero
    
    static func newScene(withLevel level: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed:"Level\(level)") else { return nil }
        scene.currentLevel = level
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        
        let maxAspectRatio: CGFloat = 16 / 9.0
        let maxAspectRatioHeight: CGFloat  = size.width / maxAspectRatio
        let playableMaigin: CGFloat = (size.height - maxAspectRatioHeight) / 2
        playableRect = CGRect(x: 0, y: playableMaigin, width: size.width, height: size.height - playableMaigin * 2)

        super.didMove(to: view)
        
        view.showsPhysics = true
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        physicsBody?.categoryBitMask = PhysicsCategory.edge
        
        enumerateChildNodes(withName: "//*") { (node, _) in
            (node as? CustomNodeEvents)?.didMoveToScene()
        }
        
        catNode = childNode(withName: "//catBody")! as! CatNode
        bedNode = childNode(withName: "catBed")! as! BedNode
        hookNode = childNode(withName: "hookBase") as? HookNode
        
        physicsWorld.contactDelegate = self

        //SKTAudio.sharedInstance().playBackgroundMusic(filename: "backgroundMusic.mp3")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collistion = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch collistion {
        case PhysicsCategory.cat | PhysicsCategory.bed:
            win()
        case PhysicsCategory.cat | PhysicsCategory.edge:
            guard abs(contact.contactPoint.y - playableRect.minY) < 2 else { return }
            lose()
        case PhysicsCategory.cat | PhysicsCategory.hook:
            guard let hook = hookNode , !hook.isHooked else { return }
            hook.hookCat(cat: catNode)
        default:
            print("None")
        }
    }
    
    
    private func inGameMessage(text: String) {
        let msg = MessageNode(message: text)
        msg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(msg)
    }
    
    @objc private func newGame(nextLevel: Bool) {
        let level = nextLevel ? (currentLevel + 1) : currentLevel
        guard let scene = GameScene.newScene(withLevel: level)  else { return }
        view?.presentScene(scene)
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        guard  playable, ((hookNode?.isHooked ?? false) != true)  else {
            return
        }
        if abs(catNode.parent!.zRotation) > CGFloat(25).degreesToRadians() {
            lose()
        }
    }
    
    
    private func lose() {
        guard playable  else {
            return
        }
        playable = false
        SKTAudio.sharedInstance().backgroundMusicPlayer?.pause()
        run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        inGameMessage(text: "Try again")
        catNode.wakeUp()
        let time = DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds +  2 * NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time)  {
            self.newGame(nextLevel: false)
        }
    }
    
    
    private func win() {
        guard playable  else {
            return
        }
        playable = false
        SKTAudio.sharedInstance().backgroundMusicPlayer?.pause()
        run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        inGameMessage(text: "Nice job")
        catNode.sleep(at: bedNode.position)
        let time = DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + 2 * NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.newGame(nextLevel: true)
        }
    }
}



