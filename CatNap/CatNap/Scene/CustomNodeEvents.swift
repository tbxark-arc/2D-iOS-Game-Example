//
//  CustomNodeEvents.swift
//  CatNap
//
//  Created by Tbxark on 09/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit
import SpriteKit

protocol CustomNodeEvents {
    func didMoveToScene()
}

protocol InteractiveNode {
    func interact()
}
