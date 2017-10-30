//
//  GameScene.swift
//  DropCharge
//
//  Created by Tbxark on 11/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


struct PhysicsCategory {
    static let node: UInt32             = 0
    static let player: UInt32           = 0b1
    static let platformNormal: UInt32   = 0b10
    static let platformBreak: UInt32    = 0b100
    static let coinNormal: UInt32       = 0b1000
    static let coinSpecial: UInt32      = 0b10000
    static let edges: UInt32            = 0b100000
}

class GameScene: SKScene {
    
    enum OverlayName: String {
        static let all: [OverlayName] = [
            OverlayName.breakArrow,
            OverlayName.breakDiagonal,
            OverlayName.brokenPlatform,
            OverlayName.coin5Across,
            OverlayName.coinArrow,
            OverlayName.coinDiagonal,
            OverlayName.coinS5Across,
            OverlayName.coinSCross,
            OverlayName.coinSDiagonal,
            OverlayName.coinSpecial,
            OverlayName.collectNormal,
            OverlayName.collectSpecial,
            OverlayName.platform5Across
        ]
        case breakArrow = "BreakArrow"
        case breakDiagonal = "BreakDiagonal"
        case brokenPlatform = "BrokenPlatform"
        case coin5Across = "Coin5Across"
        case coinArrow = "CoinArrow"
        case coinCross = "CoinCross"
        case coinDiagonal = "CoinDiagonal"
        case coinS5Across = "CoinS5Across"
        case coinSCross = "CoinSCross"
        case coinSDiagonal = "CoinSDiagonal"
        case coinSpecial = "CoinSpecial"
        case collectNormal = "CollectNormal"
        case collectSpecial = "CollectSpecial"
        case platform5Across = "Platform5Across"
    }

    lazy var gameState: GKStateMachine = GKStateMachine(states: GameState.allState(scene: self))
    lazy var playerState: GKStateMachine = GKStateMachine(states: PlayerState.allState(scene: self))
    
    // Node
    var bgNode: SKNode!
    var fgNode: SKNode!
    
    
    var background: SKNode!
    var player: SKSpriteNode!
    var lavaNode: SKSpriteNode!
    let cameraNode = SKCameraNode()
    lazy var overlayArray: [SKSpriteNode] = OverlayName.all.flatMap { GameScene.loadOverlayNode(fileName: $0.rawValue)}
    
    // Calcualate
    var lastItemPosition = CGPoint.zero
    var lastItemHeight: CGFloat = 0
    var levelY: CGFloat = 0
    var backHeight: CGFloat = 0
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    lazy var xRange: (min: CGFloat, max: CGFloat) = {
        let scale = self.view!.bounds.size.height / self.size.height
        let scaledWidth = self.size.width * scale
        let scaledOverlap = scaledWidth - self.view!.bounds.size.width
        let inset =  (scaledOverlap / scale ) / 2
        return (inset, self.size.width - inset)
    }()
    
    // Flag
    var lives = 3
    
    
    // Motion
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupNode()
        setupLava()
        setupLevel()
        setupCoreMotion()
        physicsWorld.contactDelegate = self
        
        _ = gameState.enter(GameState.WaitingForTap.self)
        _ = playerState.enter(PlayerState.Idle.self)
    }
    
    private func setupNode() {
        let worldNode = childNode(withName: "World")!
        bgNode = worldNode.childNode(withName: "Background")!
        background = bgNode.childNode(withName: "Overlay")!.copy() as! SKNode
        backHeight = background.calculateAccumulatedFrame().height
        fgNode = worldNode.childNode(withName: "Foreground")!
        player = fgNode.childNode(withName: "Player")! as! SKSpriteNode
        fgNode.childNode(withName: "Bomb")?.run(SKAction.hide())
        
        addChild(cameraNode)
        camera = cameraNode
        cameraPosition = CGPoint(x: size.width/2, y: size.height/2)
    }
    
    private func setupLevel() {
        let initPlatform = GameScene.loadOverlayNode(fileName: OverlayName.platform5Across.rawValue)!.copy() as! SKSpriteNode
        var itemPosition = player.position
        itemPosition.y = player.position.y - (player.size.height/2 + initPlatform.size.height/5)
        initPlatform.position = itemPosition
        fgNode.addChild(initPlatform)
        lastItemPosition = itemPosition
        lastItemHeight = initPlatform.size.height
        
        // Create radom level
        levelY = bgNode.childNode(withName: "Overlay")!.position.y + backHeight
        while lastItemPosition.y < levelY {
            addRadomOverlayerNode()
        }
    }
    
    private func setupLava() {
        lavaNode = fgNode.childNode(withName: "Lava") as! SKSpriteNode
        let emitter = SKEmitterNode.init(fileNamed: "Lava.sks")
        emitter?.particlePositionRange = CGVector.init(dx: size.width * 1.125, dy: 0)
        emitter?.advanceSimulationTime(1)
        emitter?.zPosition = 4
        lavaNode.addChild(emitter!)
        
    }

    private func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        let queue = OperationQueue()
        motionManager.startAccelerometerUpdates(to: queue, withHandler:
            {
                accelerometerData, error in
                guard let accelerometerData = accelerometerData else {
                    return
                }
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = (CGFloat(acceleration.x) * 0.75) +
                    (self.xAcceleration * 0.25)
        })
    }
    
    
    // MARK: Platform/Coin overlay nodes
    
    static func explosion(intensity: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let paricileTexture = SKTexture(imageNamed: "spark")
        emitter.zPosition = 2
        emitter.particleTexture = paricileTexture
        emitter.particleBirthRate = 400 * intensity
        emitter.numParticlesToEmit = Int(400 * intensity)
        emitter.particleLifetime = 2
        emitter.emissionAngle = CGFloat(90).degreesToRadians()
        emitter.emissionAngleRange = CGFloat(360).degreesToRadians()
        emitter.particleSpeed = 600 * intensity
        emitter.particleSpeedRange = 600 * intensity
        emitter.particleAlpha = 1.0
        emitter.particleSpeedRange = 0.25
        emitter.particleScale = 1.2
        emitter.particleScaleRange = 2
        emitter.particleScaleSpeed = -1.5
        emitter.particleColor = SKColor.orange
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = .add
        emitter.run(SKAction.removeFromParentAfterDelay(2))
        let kf = SKKeyframeSequence()
        kf.addKeyframeValue(SKColor.white, time: 0)
        kf.addKeyframeValue(SKColor.yellow, time: 0.1)
        kf.addKeyframeValue(SKColor.orange, time: 0.15)
        kf.addKeyframeValue(SKColor.red, time: 0.75)
        kf.addKeyframeValue(SKColor.black, time: 0.95)
        emitter.particleColorSequence = kf
        return emitter
    }
    
    private static func loadOverlayNode(fileName: String) -> SKSpriteNode? {
        guard let overlayScene = SKScene(fileNamed: fileName),
            let node = overlayScene.childNode(withName: "Overlay") else { return nil }
        return node as? SKSpriteNode
    }
    
    // make coin and platform
    private func createOverlayNode(nodeType: SKSpriteNode, flipX: Bool) {
        let platform = nodeType.copy() as! SKSpriteNode
        lastItemPosition.y = lastItemPosition.y + (lastItemHeight + platform.size.height/2)
        lastItemHeight = platform.size.height/2
        platform.position = lastItemPosition
        if flipX {
            platform.xScale = -1
        }
        fgNode.addChild(platform)
    }
    
    private func createBackgroundNode() {
        let bgn = background.copy() as! SKNode
        bgn.position = CGPoint.init(x: 0, y: levelY)
        levelY += backHeight
        bgNode.addChild(bgn)
    }
    
    private func addRadomOverlayerNode() {
        let overlayerNode = overlayArray[Int.random(min: 0, max: overlayArray.count - 1)]
        createOverlayNode(nodeType: overlayerNode, flipX: false)
    }
    
    
    // MARK: Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        switch gameState.currentState {
        case is GameState.WaitingForTap:
            gameState.enter(GameState.WaitingForBomb.self)
            run(SKAction.wait(forDuration: 2), completion: {
                self.gameState.enter(GameState.Playing.self)
            })
        case is GameState.GameOver:
            let newScene = GameScene.init(fileNamed: "GameScene")
            newScene?.scaleMode = scaleMode
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            view?.presentScene(newScene!, transition: reveal)
        default:
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        deltaTime = lastUpdateTimeInterval > 0 ? 0 : currentTime -  lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        if isPaused { return }
        gameState.update(deltaTime: deltaTime)
    }
    
}


// MARK: - Level
extension GameScene {
    func updateLevel() {
        let cameraPos = cameraPosition
        if cameraPos.y > levelY - (size.height * 0.55) {
            createBackgroundNode()
            while lastItemPosition.y < levelY {
                addRadomOverlayerNode()
            }
        }
    }
}

// MARK: - Player
extension GameScene {
    
    func updatePlayer() {
        
        let playerPosition = convert(player.position, from: fgNode)
        if playerPosition.x < xRange.min {
            player.position.x =  convert(CGPoint(x: xRange.min, y: 0), to: fgNode).x
            xAcceleration *= -1
        } else if playerPosition.x > xRange.max {
            player.position.x =  convert(CGPoint(x: xRange.max, y: 0), to: fgNode).x
            xAcceleration *= -1
        }
        
        player.physicsBody?.velocity.dx = xAcceleration * 1000.0

        
        if player.physicsBody!.velocity.dy < 0 {
            playerState.enter(PlayerState.Fall.self)
        } else {
            playerState.enter(PlayerState.Jump.self)
        }

        
    }
    
    private func setPlayerVelocity(amount: CGFloat) {
        let gain: CGFloat = 2.5
        player.physicsBody?.velocity.dy = max(player.physicsBody!.velocity.dy, amount * gain)
    }
    
    private func jumpPlayer() {
        setPlayerVelocity(amount: 650)
    }
    
    func boostPlayer() {
        setPlayerVelocity(amount: 1200)
    }
    
    func superBoostPlayer() {
        setPlayerVelocity(amount: 1700)
    }
}

// MARK: Lava
extension GameScene {
    func updateLava(dt: TimeInterval) {
        let lowerLeft = CGPoint(x: 0, y: cameraNode.position.y - (size.height / 2.5))
        let visibleMinYFg = scene!.convert(lowerLeft, to: fgNode).y
        let lavaVelocity = CGPoint(x: 0, y: 120)
        let lavaStep = lavaVelocity * CGFloat(dt)
        var newPosition = lavaNode.position + lavaStep
        newPosition.y = max(newPosition.y, (visibleMinYFg - 125.0))
        lavaNode.position = newPosition
    }
    
    func updateCollisionLava() {
        if player.position.y <= lavaNode.position.y + 180 {
            playerState.enter(PlayerState.Lava.self)
            if lives <= 0 {
                playerState.enter(PlayerState.Dead.self)
                gameState.enter(GameState.GameOver.self)
            }
        }
    }
}

// MARK: SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.coinNormal:
            guard let coin = other.node as? SKSpriteNode else { return }
            coin.removeFromParent()
            jumpPlayer()
        case PhysicsCategory.platformNormal:
            guard let _ = other.node as? SKSpriteNode,
                player.physicsBody!.velocity.dy < 0 else { return }
            jumpPlayer()
        default:
            break
        }
        
    }
}


// MARK: Camera
extension GameScene {
    var overlayAmount: CGFloat {
        if #available(iOS 10, *) {
            return 0
        }
        guard let view = self.view else { return 0 }
        let scale = view.bounds.size.height / self.size.height
        let scaledWidth = self.size.width * scale
        let scaledOverlap = scaledWidth - view.bounds.size.width
        return scaledOverlap / scale
    }
    var cameraPosition: CGPoint {
        get {
            return CGPoint(x: cameraNode.position.x + overlayAmount/2, y: cameraNode.position.y)
        }
        set(position) {
            cameraNode.position = CGPoint(x: position.x - overlayAmount/2, y: position.y)
        }
    }
    func updateCamera() {
        let cameraTarget = convert(player.position, from: fgNode)
        var targetPosition = CGPoint(x: cameraPosition.x, y: cameraTarget.y - (scene!.view!.bounds.height * 0.4))
        
        let lavaPos = convert(lavaNode.position, from: fgNode)
        targetPosition.y = max(targetPosition.y, lavaPos.y)
        
        let deff = targetPosition - cameraPosition
        let lerpValue = CGFloat(0.2)
        let lerpDiff = deff * lerpValue
        cameraPosition = cameraPosition + lerpDiff
    }
}
