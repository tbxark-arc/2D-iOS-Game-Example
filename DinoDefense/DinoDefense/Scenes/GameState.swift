//
//  GameState.swift
//  VillageDefense
//
//  Created by Toby Stephens on 25/07/2015.
//  Copyright © 2015 razeware. All rights reserved.
//

import Foundation
import GameplayKit

class GameSceneState: GKState {
    unowned let scene: GameScene
    init(scene: GameScene) {
        self.scene = scene
    }
    
}

class GameSceneReadyState: GameSceneState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == GameSceneActiveState.self
    }
}

class GameSceneActiveState: GameSceneState {
    override func didEnter(from previousState: GKState?) {
        // Hide the ready state
        // Ready
        scene.showReady(show: false)
        
        // Start the first wave
        scene.startFirstWave()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == GameSceneWinState.self || stateClass == GameSceneLoseState.self
    }
}

class GameSceneWinState: GameSceneState {
    override func didEnter(from previousState: GKState?) {
        // Show the win!
        scene.showWin()
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == GameSceneReadyState.self
    }
}

class GameSceneLoseState: GameSceneState {
    override func didEnter(from previousState: GKState?) {
        // Show the lose!
        scene.showLose()
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == GameSceneReadyState.self
    }
}

