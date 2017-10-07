//
//  GameScene.swift
//  ZombieConga
//
//  Created by Tbxark on 27/09/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit
import ARKit

class GameScene: SKScene {
    
    let player = Media.Player(fileName: "backgroundMusic1.mp3")

    let cameraNode = SKCameraNode()
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let livesLabelNode = SKLabelNode(fontNamed: UIFont.boldSystemFont(ofSize: 50).fontName)
    let trainsLabelNode = SKLabelNode(fontNamed: UIFont.boldSystemFont(ofSize: 50).fontName)

    var dt: TimeInterval = 0
    var lastTimeInterval: TimeInterval = 0
    let zomebieDidMovePerSec: CGFloat = 480
    let zomebieRotateRadiusPerSec: CGFloat = CGFloat.pi * 4
    let zombieAnimation: SKAction
    var zombieIsProtect = false
    
    var lives = 3
    var trainCount = 0
    var gameOver: Bool = false
    
    
    let catDidMovePerSec: CGFloat =  480
    let camraMovePointPerSec: CGFloat = 200.0
    
    
    var velocity = CGPoint.zero
    let playRect: CGRect
    var lastTouchLocation: CGPoint?
    
    let playHitCatSound = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let playHitCatLadySound = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    
    var overlapAmount: CGFloat {
        if #available(iOS 11.0, *) {
            return 0
        } else {
            guard let view = self.view else {
                return 0
            }
            let scale = view.bounds.size.width / self.size.width
            let scaledHeight = self.size.height * scale
            let scaledOverlap = scaledHeight - view.bounds.size.height
            return scaledOverlap / scale
        }
        

    }
    var cameraPosition: CGPoint {
        get {
            return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount)
        }
        set(position) {
            cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount)
        }
    }
    var cameraRect: CGRect {
        return CGRect(x: cameraPosition.x - (size.width / 2) + (size.width - playRect.width) / 2 ,
                       y: cameraPosition.y - (size.height / 2) + (size.height - playRect.height) / 2,
                       width: playRect.width,
                       height: playRect.height)
    }
    
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16 / 9.0
        let playableHeight: CGFloat = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - playableHeight) / 2
        playRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        zombie.name = "zombie"
        let textures = [1, 2, 3, 4, 3, 2].map({ SKTexture(imageNamed: "zombie\($0)")})
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        super.init(size: size)
        scaleMode = .aspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: override
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        let backgroundNodeBuilder: () -> SKSpriteNode = {
            let main = SKSpriteNode()
            main.anchorPoint = CGPoint.zero
            main.name = "background"
            
            let bg1 = SKSpriteNode(imageNamed: "background1")
            bg1.anchorPoint = CGPoint.zero
            bg1.position = CGPoint.zero
            main.addChild(bg1)
            
            let bg2 = SKSpriteNode(imageNamed: "background2")
            bg2.anchorPoint = CGPoint.zero
            bg2.position = CGPoint(x: bg1.size.width, y: 0)
            main.addChild(bg2)
            
            main.size = CGSize(width: bg1.size.width + bg2.size.width, height: bg1.size.height)
            main.zPosition = -1
            
            return main
        }
        
        for i in 0...1 {
            let bg = backgroundNodeBuilder()
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            addChild(bg)
        }
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 1000
        addChild(zombie)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnEnemy), SKAction.wait(forDuration: 2.0)])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnCat), SKAction.wait(forDuration: 1.0)])))
        player?.play()
        
        
        
        addChild(cameraNode)
        camera = cameraNode
        cameraPosition = size.center
        
        
        livesLabelNode.color = SKColor.black
        livesLabelNode.fontSize = 100
        livesLabelNode.zPosition = 50
        livesLabelNode.verticalAlignmentMode = .bottom
        livesLabelNode.horizontalAlignmentMode = .left
        livesLabelNode.position = CGPoint(x: -playRect.width/2 + 20, y: -playRect.height/2  + 20 + overlapAmount/2)
        cameraNode.addChild(livesLabelNode)
        
        
        trainsLabelNode.color = SKColor.black
        trainsLabelNode.fontSize = 100
        trainsLabelNode.zPosition = 50
        trainsLabelNode.verticalAlignmentMode = .bottom
        trainsLabelNode.horizontalAlignmentMode = .right
        trainsLabelNode.position = CGPoint(x: playRect.width/2 - 20, y: -playRect.height/2 + 20 + overlapAmount/2)
        cameraNode.addChild(trainsLabelNode)

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        dt = lastTimeInterval > 0 ? (currentTime - lastTimeInterval) : 0
        lastTimeInterval = currentTime
//        if let last = lastTouchLocation {
//            if (zombie.position -  last).length < CGFloat(dt) * zomebieDidMovePerSec {
//                velocity = CGPoint.zero
//                stopZombieAnimation()
//            }
//        }
        if velocity != CGPoint.zero {
            startZombieAnimation()
        }
        move(sprite: zombie, velocity: velocity)
        moveTrain()
        moveCamera()
        rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zomebieRotateRadiusPerSec)
        boundsCheckZombie()
        
        if !gameOver {
            var isWon: Bool?
            if lives <= 0 {
                isWon = false
                gameOver = true
            } else if trainCount >= 15 {
                isWon = true
                gameOver = true
            }
            if let w = isWon {
                let gameOverScene = GameOverScene(size: size, won: w)
                gameOverScene.scaleMode = scaleMode
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                view?.presentScene(gameOverScene, transition: reveal)
                player?.stop()
            }
        }
        livesLabelNode.text = "lives: \(lives)"
        trainsLabelNode.text = "cats: \(trainCount)"
    }
    
    override func didEvaluateActions() {
        super.didEvaluateActions()
        checkCollision()
    }
    
    
    // MARK: Spawn
    private func spawnEnemy() {
        let enemyNode = SKSpriteNode(imageNamed: "enemy")
        enemyNode.name = "enemy"
        enemyNode.zPosition = 50
        enemyNode.position = CGPoint(x: cameraRect.maxX + enemyNode.size.width / 2,
                                     y: CGFloat.random(min: cameraRect.minY + enemyNode.size.height / 2,
                                                       max: cameraRect.maxY - enemyNode.size.height / 2))
        addChild(enemyNode)
        let moveAction = SKAction.moveTo(x: -enemyNode.size.width/2, duration: 2)
        let removeAction = SKAction.removeFromParent()
        enemyNode.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    private func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.zPosition = 50
        cat.position = CGPoint(x: CGFloat.random(min: cameraRect.minX, max: cameraRect.maxX),
                               y: CGFloat.random(min: cameraRect.minY, max: cameraRect.maxY))
        cat.zRotation = -CGFloat.pi / 16
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 1, duration: 0.5)
        let wait: SKAction = {
            let rotate = SKAction.rotate(byAngle: CGFloat.pi / 8, duration: 0.5)
            let rotateAction = SKAction.sequence([rotate, rotate.reversed()])
            let waitScale = SKAction.scale(by: 1.2, duration: 0.25)
            let waitScaleReversed = waitScale.reversed()
            let groupWait = SKAction.group([SKAction.sequence([waitScale, waitScaleReversed, waitScale, waitScaleReversed]), rotateAction])
            return SKAction.repeat(groupWait, count: 10)
        }()
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let remove = SKAction.removeFromParent()
        
        cat.run(SKAction.sequence([appear,
                                   wait,
                                   disappear,
                                   remove]))
        
    }
    
    // MARK: Animation
    private func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    private func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    private func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position 
        velocity = offset.normalizing() * zomebieDidMovePerSec
    }
    
    private func sceneTouched(touchLocation: CGPoint) {
        moveZombieToward(location: touchLocation)
    }
    
    
    private func boundsCheckZombie() {
        let bounds = UIEdgeInsets(top: cameraRect.minY, left: cameraRect.minX, bottom: cameraRect.maxY, right: cameraRect.maxX)
        if zombie.position.x <= bounds.left {
            zombie.position.x = bounds.left
            velocity.x *= -1
        }
        if zombie.position.x >= bounds.right {
            zombie.position.x = bounds.right
            velocity.x *= -1
        }
        if zombie.position.y <= bounds.top {
            zombie.position.y = bounds.top
            velocity.y *= -1
        }
        if zombie.position.y >= bounds.bottom {
            zombie.position.y = bounds.bottom
            velocity.y *= -1
        }
    }
    
    private func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position = sprite.position + amountToMove
    }
    
    private func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        if direction == CGPoint.zero { return }
        let shortest = shortestAngleBetween(sprite.zRotation, direction.anagle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        zombie.zRotation += amountToRotate * shortest.sign
    }
    
    
    private func moveTrain() {
        var targetPosiztion = zombie.position
        enumerateChildNodes(withName: "train") { (node, _) in
            if !node.hasActions() {
                let actionDuration: TimeInterval = 0.3
                let offset = targetPosiztion - node.position
                let direction = offset.normalizing()
                let amountToMovePerSec = self.catDidMovePerSec * CGFloat(actionDuration)
                let amountToMove = direction * amountToMovePerSec
                let moveAction = SKAction.move(by: amountToMove.toVector(), duration: actionDuration)
                node.run(moveAction)
            }
            targetPosiztion = node.position
        }
    }
    
    
    private func moveCamera() {
        let bgV = CGPoint(x: camraMovePointPerSec, y: 0)
        let amountToMove = bgV * CGFloat(dt)
        cameraNode.position = cameraNode.position + amountToMove
        enumerateChildNodes(withName: "background") { (node, _) in
            guard let bg = node as? SKSpriteNode,
                bg.position.x + bg.size.width < self.cameraRect.minX else { return }
            bg.position.x = bg.position.x  + bg.size.width * 2
        }
    }

    
    
    // MARK: - Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self) else { return }
        sceneTouched(touchLocation: touchLocation)
        lastTouchLocation = touchLocation
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self) else { return }
        sceneTouched(touchLocation: touchLocation)
        lastTouchLocation = touchLocation
    }
    
    
    // MARK: - Hit

    private func lostCat() {
        var lostCount = 0
        enumerateChildNodes(withName: "train") { (node, stop) in
            var radomSpot = node.position
            radomSpot.x += CGFloat.random(min: -100, max: 100)
            radomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            node.run(SKAction.sequence([
                SKAction.group([
                        SKAction.rotate(byAngle: CGFloat.pi * 4, duration: 1),
                        SKAction.move(to: radomSpot, duration: 1),
                        SKAction.scale(to: 0, duration: 1)
                    ]),
                SKAction.removeFromParent()
                ]))
            lostCount += 1
            self.trainCount -= 1
            if lostCount >= 2 {
                stop.initialize(to: true)
            }
            
        }
    }
    
    private func zombieHitCat(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        let greenAction = SKAction.colorize(with: UIColor.green, colorBlendFactor: 1, duration: 0.2)
        cat.run(greenAction)
        run(playHitCatSound)
        trainCount += 1
    }
    
    private func zombieHitEnemy(enemy: SKSpriteNode) {
        guard !zombieIsProtect else { return }
        zombieIsProtect = true
        run(playHitCatLadySound)
        lives -= 1
        let blink: SKAction = {
            let blinkTimes = 10.0
            let duration = 3.0
            return SKAction.customAction(withDuration: duration, actionBlock: { (node, time) in
                let slice = duration / blinkTimes
                let remider = time.truncatingRemainder(dividingBy: CGFloat(slice))
                node.isHidden = remider > CGFloat(slice) / 2
            })
        }()
        let finish = SKAction.run {
            self.zombie.isHidden = false
            self.zombieIsProtect = false
        }
        zombie.run(SKAction.sequence([blink, finish]))
        lostCat()
        
    }
    
    private func checkCollision() {
        var cats = [SKSpriteNode]()
        enumerateChildNodes(withName: "cat") {[weak self] (cat, stop) in
            guard let `self` = self, let catNode = cat as? SKSpriteNode else { return }
            if catNode.frame.intersects(self.zombie.frame) {
                cats.append(catNode)
            }
        }
        cats.forEach(zombieHitCat)
        
        
        var enemies = [SKSpriteNode]()
        enumerateChildNodes(withName: "enemy") {[weak self] (enemy, stop) in
            guard let `self` = self, let enemyNode = enemy as? SKSpriteNode else { return }
            if enemyNode.frame.insetBy(dx: 30, dy: 30).intersects(self.zombie.frame) {
                enemies.append(enemyNode)
            }
        }
        enemies.forEach(zombieHitEnemy)
    }
}


