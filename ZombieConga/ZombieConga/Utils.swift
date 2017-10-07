//
//  Utils.swift
//  ZombieConga
//
//  Created by Tbxark on 06/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import AVFoundation

class Utils {

}

class Media {
    class Player {
        private let player: AVAudioPlayer
        init?(fileName: String, autoPlay: Bool = true) {
            guard let path = Bundle.main.url(forResource: fileName, withExtension: nil),
                let avPlayer = try? AVAudioPlayer(contentsOf: path)
            else { return nil }
            player = avPlayer
            player.numberOfLoops = -1
            player.prepareToPlay()
            if autoPlay {
                play()
            }
        }
        func play() {
            player.play()
        }
        func stop() {
            player.stop()
        }
    }
}
