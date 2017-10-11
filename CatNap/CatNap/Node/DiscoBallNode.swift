//
//  DiscoBallNode.swift
//  CatNap
//
//  Created by Tbxark on 10/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class DiscoBallNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    static private(set) var isDiscoTime = false
    var isDiscoTime = false {
        didSet {
            DiscoBallNode.isDiscoTime = isDiscoTime
            videoNode.isHidden = !isDiscoTime
            if isDiscoTime {
                videoNode.play()
                run(spinAction)
            } else {
                videoNode.pause()
                removeAllActions()
            }
            SKTAudio.sharedInstance().playBackgroundMusic(filename: isDiscoTime ? "disco-sound.m4a" : "backgroundMusic.mp3")
        }
    }
    private var player: AVPlayer!
    private var videoNode: SKVideoNode!
    
    private let spinAction = SKAction.repeatForever(SKAction.animate(with: [
            SKTexture.init(imageNamed: "discoball1"),
            SKTexture.init(imageNamed: "discoball2"),
            SKTexture.init(imageNamed: "discoball3")
        ], timePerFrame: 0.2))
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func didMoveToScene() {
        guard let url = Bundle.main.url(forResource: "discolights-loop", withExtension: "mov") else { return }
        player = AVPlayer(url: url)
        videoNode = SKVideoNode(avPlayer: player)
        videoNode.size = scene!.size
        videoNode.position = CGPoint(x: scene!.size.width/2, y: scene!.size.height/2)
        videoNode.zPosition = -1
        videoNode.alpha = 0.75
        scene?.addChild(videoNode)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: OperationQueue.main) { (_) in
            self.player.currentItem?.seek(to: kCMTimeZero)
        }
        videoNode.pause()
        videoNode.isHidden = true
        isUserInteractionEnabled = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interact()
    }
    
    func interact() {
        isDiscoTime = !isDiscoTime
    }
    
}
