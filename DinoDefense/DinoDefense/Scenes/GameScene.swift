//
//  GameScene.swift
//  DinoDefense
//
//  Created by Toby Stephens on 26/09/2015.
//  Copyright © 2015 razeware. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: GameSceneHelper {
    
    // A GameScene state machine
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        GameSceneReadyState(scene: self),
        GameSceneActiveState(scene: self),
        GameSceneWinState(scene: self),
        GameSceneLoseState(scene: self)
        ])
    
    lazy var componentSystems: [GKComponentSystem] = {
        let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
        let firingStstem = GKComponentSystem(componentClass: FiringComponent.self)
        return [animationSystem, firingStstem]
    }()
    
    private(set) var entities = Set<GKEntity>()
    var lastUpdateTimeInterval: TimeInterval = 0
    
    
    var towerSelectorNodes = [TowerSelectorNode]()
    var isPlacingTower = false
    var placingTowerOnNode = SKNode()
    let obstacleGraph = GKObstacleGraph(obstacles: [], bufferRadius: 32)

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        loadTowerSelectorNodes()
        
        let obstacleSpriteNodes = self["Sprites/Obstacle_*"] as! [SKSpriteNode]
        for obstacle in obstacleSpriteNodes {
            addObstacle(withNode: obstacle)
        }
        stateMachine.enter(GameSceneReadyState.self)

    }
    
    
    

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        guard view != nil else { return }
        let deltaTime = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        if isPaused { return }
        stateMachine.update(deltaTime: deltaTime)
        for componentSystem in componentSystems {
            componentSystem.update(deltaTime: deltaTime)
        }
    }
    
    
    override func didFinishUpdate() {
        super.didFinishUpdate()
        let dinosaurs = entities.flatMap({ $0 as? DinosaurEntity })
        let towers = entities.flatMap({ $0 as? TowerEntity })
        
        for tower in towers {
            var target: DinosaurEntity?
            let rangeDinosaurs = dinosaurs.filter({ distanceBetween(nodeA: $0.spriteComponent.node, nodeB: tower.spriteComponent.node) < tower.towerType.range})
            for dinosaur in rangeDinosaurs {
                if let t = target {
                    if dinosaur.spriteComponent.node.position.x > t.spriteComponent.node.position.x {
                        target = dinosaur
                    }
                } else {
                    target = dinosaur
                }
            }
            tower.firingComponent.currentTarget = target
        }
        
        
        
        // 1
        let ySortedEntities = entities.sorted { (a, b) -> Bool in
            let nodeA = a.component(ofType: SpriteComponent.self)!.node
            let nodeB = b.component(ofType: SpriteComponent.self)!.node
            return nodeA.position.y > nodeB.position.y
        }
        
        var zPosition = GameLayer.zDeltaForSprites
        for entity in ySortedEntities {
            let spriteComponent = entity.component(ofType: SpriteComponent.self)
            let node = spriteComponent!.node
            node.zPosition = zPosition
            zPosition += GameLayer.zDeltaForSprites
        }

        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if let _ = stateMachine.currentState as? GameSceneReadyState {
            stateMachine.enter(GameSceneActiveState.self)
            addDinosaur(dinosaurType: DinosaurType.TRex)
            return
        }
        
        let touchedNodes: [SKNode] = self.nodes(at: touch.location(in: self)).flatMap { node in
            if let nodeName = node.name, nodeName.hasPrefix("Tower_") {
                return node
            }
            return nil
        }
        
        if touchedNodes.count == 0 {
            hideTowerSelector()
            return
        }
        
        let touchedNode = touchedNodes[0]
        
        if isPlacingTower {
            let touchedNodeName = touchedNode.name!
            
            if touchedNodeName == "Tower_Icon_WoodTower" {
                addTower(towerType: .wood, position: placingTowerOnNode.position)
            }
            else if touchedNodeName == "Tower_Icon_RockTower" {
                addTower(towerType: .rock, position: placingTowerOnNode.position)
            }
            
            hideTowerSelector()
        }
        else {
            placingTowerOnNode = touchedNode
            showTowerSelector(atPosition: touchedNode.position)
        }
    }
    
    func startFirstWave() {
//        addTower(type: .wood)
    }
    
    func addEntity(entity: GKEntity) {
        entities.insert(entity)
        for componentSystem in componentSystems {
            componentSystem.addComponent(foundIn: entity)
        }
        if let node = entity.component(ofType: SpriteComponent.self)?.node {
            addNode(node: node, toGameLayer: GameLayer.sprites)
            if let shadow = entity.component(ofType: ShadowComponent.self)?.node {
                addNode(node: shadow, toGameLayer: GameLayer.shadows)
                let xRange = SKRange.init(constantValue: shadow.position.x)
                let yRange = SKRange.init(constantValue: shadow.position.y)
                let c = SKConstraint.positionX(xRange, y: yRange)
                c.referenceNode = node
                shadow.constraints = [c]
            }
        }
        
    }
    
}


extension GameScene {
    
    
    func addDinosaur(dinosaurType: DinosaurType) {

        let startPosition = CGPoint(x: -200, y:  384)
        let endPosition = CGPoint(x:1224, y: 384)
        
        let dinosaur = DinosaurEntity(dinosaurType: dinosaurType)
        let dinoNode = dinosaur.spriteComponent.node
        dinoNode.position = startPosition
        setDinosaurOnPath(dinosaur: dinosaur, toPoint: endPosition)
        
        addEntity(entity: dinosaur)
        
        dinosaur.animationComponent.requestAnimationState = .walk
    }
    
    func addTower(towerType: TowerType, position: CGPoint) {
        placingTowerOnNode.removeFromParent()
        self.run(SKAction.playSoundFileNamed("BuildTower.mp3", waitForCompletion: false))
        
        let towerEntity = TowerEntity(towerType: towerType)
        towerEntity.spriteComponent.node.position = position
        towerEntity.animationComponent.requestAnimationState = .idle
        addEntity(entity: towerEntity)
        
        addObstaclesToObstacleGraph(
            newObstacles: towerEntity.shadowComponent.createObstaclesAtPosition(position: position))
        
        recalculateDinosaurPaths()
    }
    
    func addObstacle(withNode node: SKSpriteNode) {
        // 1 - Store nodes's position
        let nodePosition = node.position
        
        // 2 - Remove node from parent
        node.removeFromParent()
        
        // 3 - Create obstacle entity
        let obstacleEntity = ObstacleEntity(withNode: node)
        
        // 4 - Add obstacle entity to scene
        addEntity(entity: obstacleEntity)
        
        // 5 - Create obstacles from shadow component
        let obstacles = obstacleEntity.shadowComponent.createObstaclesAtPosition(position: nodePosition)
        
        // 6 - Add obstacles to obstacle graph
        addObstaclesToObstacleGraph(newObstacles: obstacles)
    }
    
    func setDinosaurOnPath(dinosaur: DinosaurEntity, toPoint point: CGPoint) {
        let dinosaurNode = dinosaur.spriteComponent.node
        
        // 1
        let startNode = GKGraphNode2D(
            point: vector_float2(dinosaurNode.position))
        obstacleGraph.connectUsingObstacles(node: startNode)
        
        // 2
        let endNode = GKGraphNode2D(point: vector_float2(point))
        obstacleGraph.connectUsingObstacles(node: endNode)
        
        // 3
        let pathNodes = obstacleGraph.findPath(
            from: startNode, to: endNode) as! [GKGraphNode2D]
        
        // 4
        obstacleGraph.remove([startNode, endNode])
        
        // 1
        dinosaurNode.removeAction(forKey: "move")
        
        // 2
        var pathActions = [SKAction]()
        var lastNodePosition = startNode.position
        for node2D in pathNodes {
            // 3
            let nodePosition = CGPoint(node2D.position)
            // 4
            let actionDuration =
                TimeInterval(lastNodePosition.distanceTo(point: node2D.position)
                    / dinosaur.dinosaurType.speed)
            // 5
            let pathNodeAction = SKAction.move(
                to: nodePosition, duration: actionDuration)
            // 6
            pathActions.append(pathNodeAction)
            lastNodePosition = node2D.position
        }
        // 7
        dinosaurNode.run(SKAction.sequence(pathActions), withKey: "move")
    }
    
    func recalculateDinosaurPaths() {
        // 1
        let endPosition = CGPoint(x: 1224, y: 384)
        
        // 2
        let dinosaurs: [DinosaurEntity] = entities.flatMap { entity in
            if let dinosaur = entity as? DinosaurEntity {
                if dinosaur.healthComponent.health <= 0 {return nil}
                return dinosaur
            }
            return nil
        }
        
        // 3
        for dinosaur in dinosaurs {
            setDinosaurOnPath(dinosaur: dinosaur, toPoint: endPosition)
        }
    }
    
    func addObstaclesToObstacleGraph(newObstacles: [GKPolygonObstacle]) {
        obstacleGraph.addObstacles(newObstacles)
    }
    
    func loadTowerSelectorNodes() {
        // 1
        let towerTypeCount = TowerType.allValues.count

        // 2
        let towerSelectorNodePath: String = Bundle.main.path(forResource: "TowerSelector", ofType: "sks")!
        let towerSelectorNodeScene = NSKeyedUnarchiver.unarchiveObject(withFile: towerSelectorNodePath) as! SKScene
        for t in 0..<towerTypeCount {
            // 3
            let towerSelectorNode = (towerSelectorNodeScene.childNode(
                withName: "MainNode"))!.copy() as! TowerSelectorNode
            // 4
            towerSelectorNode.setTower(towerType: TowerType.allValues[t],
                                       angle: ((2*π)/CGFloat(towerTypeCount))*CGFloat(t))
            // 5
            towerSelectorNodes.append(towerSelectorNode)
        }
    }
    
    func showTowerSelector(atPosition position: CGPoint) {
        // 1
        if isPlacingTower == true {return}
        isPlacingTower = true
        
        // 2
        self.run(SKAction.playSoundFileNamed("Menu.mp3", waitForCompletion: false))
        
        for towerSelectorNode in towerSelectorNodes {
            // 3
            towerSelectorNode.position = position
            // 4
            gameLayerNodes[.hud]!.addChild(towerSelectorNode)
            // 5
            towerSelectorNode.show()
        }
    }
    
    func hideTowerSelector() {
        if isPlacingTower == false { return }
        isPlacingTower = false
        
        self.run(SKAction.playSoundFileNamed("Menu.mp3", waitForCompletion: false))
        
        for towerSelectorNode in towerSelectorNodes {
            towerSelectorNode.hide {
                towerSelectorNode.removeFromParent()
            }
        }
    }

}

