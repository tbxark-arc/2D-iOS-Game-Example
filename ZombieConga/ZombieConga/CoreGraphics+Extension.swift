//
//  CoreGraphics+Extension.swift
//  ZombieConga
//
//  Created by Tbxark on 04/10/2017.
//  Copyright © 2017 Tbxark. All rights reserved.
//

import UIKit

extension CGPoint {
    var length: CGFloat {
        return sqrt( x * x  + y * y)
    }
    var anagle: CGFloat {
        return atan2(y, x)
    }
    
    func normalizing() -> CGPoint {
        return self / length
    }
    
    func toVector() -> CGVector {
        return CGVector(dx: x, dy: y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
}

extension CGFloat {
    var sign: CGFloat {
        return self >= 0 ? 1 : -1
    }
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return random() * ( max - min) + min
    }
}

func shortestAngleBetween(_ A: CGFloat, _ B: CGFloat) -> CGFloat {
    let c = (B - A).truncatingRemainder(dividingBy: (CGFloat.pi * 2))
    if c >= CGFloat.pi {
        return c - (CGFloat.pi * 2)
    } else if c <= -CGFloat.pi {
        return (CGFloat.pi * 2) + c
    } else {
        return c
    }
}

