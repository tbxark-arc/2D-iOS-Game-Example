//: Playground - noun: a place where people can play

import UIKit
import SpriteKit
import PlaygroundSupport


func delay(sec: UInt64, complete: @escaping () -> Void) {
    let popTime = DispatchTime(uptimeNanoseconds: sec * NSEC_PER_SEC)
    DispatchQueue.global().asyncAfter(deadline: popTime, execute: complete)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(CGFloat(arc4random())/CGFloat(UInt32.max) * (max - min)) + min
}

func spawnSand(size: CGSize) -> SKSpriteNode {
    let sand = SKSpriteNode.init(imageNamed: "sand")
    sand.position = CGPoint.init(x: random(min: 0, max: size.width),
                                 y: random(min: 0, max: size.height))
    sand.physicsBody = SKPhysicsBody.init(circleOfRadius: sand.size.width/2)
    sand.physicsBody?.restitution = 1
    sand.physicsBody?.density = 20
    sand.name = "sand"
    return sand
}

func shake(scene: SKScene) {
    print("Shake")
    scene.enumerateChildNodes(withName: "sand") { (node, _) in
        node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: random(min: 20, max: 40)))
    }
    scene.enumerateChildNodes(withName: "shape") { (node, _) in
        node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: random(min: 20, max: 60)))
    }
    delay(sec: 3) {
        shake(scene: scene)
    }
}


let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 480, height: 320))
let scene = SKScene(size: sceneView.frame.size)
scene.physicsWorld.gravity.dy = 0
scene.physicsBody = SKPhysicsBody(edgeLoopFrom: sceneView.bounds)

sceneView.showsFPS = true
sceneView.showsPhysics = true
sceneView.presentScene(scene)



let square = SKSpriteNode(imageNamed: "square")
square.name = "shape"
square.position = CGPoint(x: scene.size.width / 4, y: scene.size.height / 2)
square.physicsBody = SKPhysicsBody(rectangleOf: square.size)
scene.addChild(square)


let triangle = SKSpriteNode(imageNamed: "triangle")
triangle.name = "shape"
triangle.position = CGPoint(x: scene.size.width / 4 * 3, y: scene.size.height / 2)
let path: CGMutablePath = {
    let size = triangle.size
    let path = CGMutablePath()
    path.move(to: CGPoint(x: -size.width/2, y: -size.height/2))
    path.addLine(to: CGPoint(x: size.width/2, y: -size.height/2))
    path.addLine(to: CGPoint(x: 0, y: size.height/2))
    path.addLine(to: CGPoint(x: -size.width/2, y: -size.height/2))
    return path
}()
triangle.physicsBody = SKPhysicsBody(polygonFrom: path)
scene.addChild(triangle)


let circle = SKSpriteNode(imageNamed: "circle")
circle.name = "shape"
circle.position = CGPoint(x: scene.size.width / 2, y:  circle.size.height)
circle.physicsBody = SKPhysicsBody(circleOfRadius: circle.size.width/2)
circle.physicsBody?.isDynamic = false
scene.addChild(circle)

let action = SKAction.move(by: CGVector(dx: 100, dy: 0), duration: 1)
let action2 = SKAction.move(by: CGVector(dx: -100, dy: 0), duration: 1)

circle.run(SKAction.repeat(SKAction.sequence([action, action2, action2, action]), count: 50)) 

let l = SKSpriteNode(imageNamed: "L")
l.name = "shape"
l.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 4 * 3)
l.physicsBody = SKPhysicsBody(texture: l.texture!, size: l.size)
scene.addChild(l)


PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

delay(sec: 4) {
    scene.physicsWorld.gravity.dy = -9.8
    scene.run(SKAction.sequence([
        SKAction.repeat(SKAction.sequence([
            SKAction.run {
                scene.addChild(spawnSand(size: scene.size))
            },
            SKAction.wait(forDuration: 0.1)
            ]), count: 100)
        ]))
}


