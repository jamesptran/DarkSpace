//
//  EnemyClass.swift
//  spaceGame
//
//  Created by James Tran on 10/23/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

let playerLaserCategory:UInt32 =  0x1 << 1
let enemyShipCategory:UInt32 =  0x1 << 2
let floorCategory:UInt32 = 0x1 << 3
let roofCategory:UInt32 = 0x1 << 4
let playerCategory:UInt32 = 0x1 << 5
let playerShieldCategory:UInt32 = 0x1 << 6
let enemyLaserCategory:UInt32 = 0x1 << 7

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func random() -> Float {
    return (Float(arc4random()) / 0xFFFFFFFF)
}


func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat(random()) * (max - min) + min
}


func random(mid: Float, range: Float) -> Float {
    let max = mid + range
    let min = mid - range
    return random() * (max - min) + min
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}


class PlayerShip: SKSpriteNode {
    var shieldBought = false
    var attackSpeed : Double = 1
    var moveSpeed : Double = 1
    var maxlife : Float = 10
    var armor : Float = 0
    var regen : Float = 0
    
    var life : Float = 10
    
    var shieldBroken = false
    
    var shieldUp = true
    var shieldNode : SKSpriteNode = SKSpriteNode()
}

enum LaserType {
    case normal
    case fast
    case piercing
    case gattling
    case plasma
}

class Ship : SKSpriteNode {
    var hp : Int = 4
    var laserSpawnTime : TimeInterval = 0
    var movementSpeed : Double = 12
    var laserSpeed : Double = 10
    var laserInterval : TimeInterval = 1.5
    
    var laserType : LaserType = .normal
    
    func createPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.categoryBitMask = enemyShipCategory
        self.physicsBody?.contactTestBitMask = playerLaserCategory
        
        self.physicsBody?.mass = 0.1
        self.physicsBody?.linearDamping = 0.9
    }
}

class Pawn: Ship {
    init() {
        let texture = SKTexture(imageNamed: "redPawn")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.hp = 2
        self.laserInterval = 1.2
        self.laserSpeed = 3.0
        //self.movementSpeed = 12
        self.movementSpeed = 16
        
        self.setScale(0.5)
        
        let afterburner = SKSpriteNode(imageNamed: "fire06")
        afterburner.setScale(1.5)
        afterburner.position = CGPoint(x: 0, y: self.position.y + self.frame.size.height + afterburner.size.height*0.5)
        afterburner.zPosition = -1
        self.addChild(afterburner)
        
        self.name = "Pawn"
        self.laserType = .normal
        
        createPhysicsBody()
        
        // add invisible gun sprite
        let gun0 = SKSpriteNode()
        gun0.position = CGPoint(x: 0, y: 0)
        gun0.name = "Gun"
        self.addChild(gun0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Bishop : Ship {
    init() {
        let texture = SKTexture(imageNamed: "redBishop")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.hp = 10
        self.laserInterval = 1.6
        self.laserSpeed = 2.5
        //self.movementSpeed = 8
        self.movementSpeed = 9
        self.physicsBody?.mass = 0.2
        
        self.setScale(0.6)
        
        let afterburner = SKSpriteNode(imageNamed: "fire06")
        afterburner.setScale(1.5)
        afterburner.position = CGPoint(x: 0, y: self.position.y + self.frame.size.height*0.5 + afterburner.size.height)
        afterburner.zPosition = -1
        self.addChild(afterburner)
        
        self.name = "Bishop"
        self.laserType = .piercing
        
        createPhysicsBody()
        
        // add invisible gun sprite
        let gun0 = SKSpriteNode()
        gun0.position = CGPoint(x: 0, y: 0)
        gun0.name = "Gun"
        self.addChild(gun0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Knight : Ship {
    init() {
        let texture = SKTexture(imageNamed: "redKnight")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.hp = 4
        self.laserInterval = 0.8
        self.laserSpeed = 4.0
        //self.movementSpeed = 16
        self.movementSpeed = 21
        self.physicsBody?.mass = 0.2
        
        self.setScale(0.6)
        
        
        let afterburner0 = SKSpriteNode(imageNamed: "fire06")
        
        afterburner0.setScale(1.5)
        afterburner0.position = CGPoint(x: -19, y: self.frame.size.height*0.5 + afterburner0.size.height*0.8)
        afterburner0.zPosition = -1
        
        let afterburner1 = SKSpriteNode(imageNamed: "fire06")
        
        afterburner1.setScale(1.5)
        afterburner1.position = CGPoint(x: 19, y: self.frame.size.height*0.5 + afterburner1.size.height*0.8)
        afterburner1.zPosition = -1
        
        
        self.addChild(afterburner0)
        self.addChild(afterburner1)
        
        self.name = "Knight"
        self.laserType = .fast
        
        createPhysicsBody()
        
        // add invisible gun sprite
        let gun0 = SKSpriteNode()
        gun0.position = CGPoint(x: -40, y: 0)
        gun0.name = "Gun"
        
        let gun1 = SKSpriteNode()
        gun1.position = CGPoint(x: 40, y: 0)
        gun1.name = "Gun"
        
        self.addChild(gun0)
        self.addChild(gun1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Rook : Ship {
    init() {
        let texture = SKTexture(imageNamed: "redRook")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.hp = 30
        self.laserInterval = 0.4
        self.laserSpeed = 2.5
        //self.movementSpeed = 3
        self.movementSpeed = 10
        self.physicsBody?.mass = 0.5
        
        self.setScale(0.6)
        
        let afterburner0 = SKSpriteNode(imageNamed: "fire06")
        
        afterburner0.setScale(1.5)
        afterburner0.position = CGPoint(x: -36, y: self.frame.size.height*0.5 + afterburner0.size.height*0.9)
        afterburner0.zPosition = -1
        
        let afterburner1 = SKSpriteNode(imageNamed: "fire06")
        
        afterburner1.setScale(1.5)
        afterburner1.position = CGPoint(x: 36, y: self.frame.size.height*0.5 + afterburner1.size.height*0.9)
        afterburner1.zPosition = -1
        
        
        self.addChild(afterburner0)
        self.addChild(afterburner1)
        
        self.name = "Rook"
        self.laserType = .gattling
        
        createPhysicsBody()
        
        // add invisible gun sprite
        let gun0 = SKSpriteNode()
        gun0.position = CGPoint(x: -40, y: 0)
        gun0.name = "Gun"
        
        let gun1 = SKSpriteNode()
        gun1.position = CGPoint(x: 40, y: 0)
        gun1.name = "Gun"
        
        self.addChild(gun0)
        self.addChild(gun1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class Queen : Ship {
    var switchGunTime: TimeInterval = 0
    var switchGunInterval: TimeInterval = 3
    
    init() {
        let texture = SKTexture(imageNamed: "redQueen")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.hp = 120
        self.movementSpeed = 16
        self.physicsBody?.mass = 0.4
        
        self.setScale(0.5)
        
        let afterburner = SKSpriteNode(imageNamed: "fire06")
        afterburner.setScale(1.5)
        afterburner.position = CGPoint(x: 0, y: self.position.y + self.frame.size.height*0.5 + afterburner.size.height*0.5)
        afterburner.zPosition = -1
        self.addChild(afterburner)
        
        self.name = "Queen"
        
        createPhysicsBody()
    }
    
    func switchToRandomGunType() {
        let seed = random(min: 0, max: 100)
        var type : LaserType = .normal
        if seed < 80 {
            type = .normal
        } else if seed < -1 {
            type = .piercing
        } else if seed < -1 {
            type = .gattling
        } else {
            type = .plasma
        }
        if type == self.laserType {
            switchToRandomGunType()
        } else {
            switchGunType(to: type)
        }
    }
    
    
    func switchGunType(to type: LaserType) {
        // add visible gun sprite
        self.laserType = type
        
        self.removeAllChildren()
        var gunLeft : SKSpriteNode = SKSpriteNode()
        var gunRight : SKSpriteNode = SKSpriteNode()
        var gunMid : SKSpriteNode = SKSpriteNode()
        
        var isUsingGunMid : Bool = false
        
        switch type {
        case .normal:
            gunLeft = SKSpriteNode(imageNamed: "gunNormalMid")
            gunRight = SKSpriteNode(imageNamed: "gunNormalMid")
            
            self.laserInterval = 1.0
            self.laserSpeed = 4.0
            self.movementSpeed = 34
            self.physicsBody?.mass = 0.2

        case .gattling:
            gunLeft = SKSpriteNode(imageNamed: "gunGattlingLeft")
            gunRight = SKSpriteNode(imageNamed: "gunGattlingRight")
            
            self.laserInterval = 0.4
            self.laserSpeed = 2.5
            self.movementSpeed = 26
            self.physicsBody?.mass = 0.5
            
        case .piercing:
            isUsingGunMid = true
            gunMid = SKSpriteNode(imageNamed: "gunPiercingMid")
            
            self.laserInterval = 1.6
            self.laserSpeed = 3.5
            self.movementSpeed = 28
            self.physicsBody?.mass = 0.2
            
        case .plasma:
            isUsingGunMid = true
            gunMid = SKSpriteNode(imageNamed: "gunPlasmaMid")
            gunMid.setScale(2.0)
            
            self.laserInterval = 3
            self.laserSpeed = 1.0
            self.movementSpeed = 28
            self.physicsBody?.mass = 0.2
            
        default:
            break
        }
        
        if isUsingGunMid {
            gunMid.name = "Gun"
            gunMid.position = CGPoint(x: 0, y: -20)
            
            gunMid.zPosition = -1
            
            self.addChild(gunMid)
        } else {
            gunLeft.name = "Gun"
            gunRight.name = "Gun"
            
            gunLeft.position = CGPoint(x: -40, y: -60)
            gunRight.position = CGPoint(x: 40, y: -60)
            
            gunLeft.zPosition = -1
            gunRight.zPosition = -1
            
            self.addChild(gunLeft)
            self.addChild(gunRight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class King : Ship {
    var shieldUp : Bool = true {
        didSet {
            if shieldUp == false {
                self.enumerateChildNodes(withName: "Shield") {
                    (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
                    node.removeFromParent()
                }
            }
        }
    }
    init() {
        let texture = SKTexture(imageNamed: "redKing")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.hp = 8
        self.laserInterval = 1.5
        self.laserSpeed = 2.5
        self.movementSpeed = 4
        
        self.setScale(0.6)
        
        let afterburner = SKSpriteNode(imageNamed: "fire06")
        afterburner.setScale(1.5)
        afterburner.position = CGPoint(x: 0, y: self.position.y + self.frame.size.height*0.5 + afterburner.size.height*0.5)
        afterburner.zPosition = -1
        self.addChild(afterburner)
        
        let shield = SKSpriteNode(imageNamed: "shield2")
        shield.zRotation = CGFloat.pi
        shield.position = CGPoint(x: 0, y: 0)
        shield.zPosition = 1
        shield.name = "Shield"
        self.addChild(shield)
        
        self.name = "King"
        
        createPhysicsBody()
    }
    
    // Returns ship type name and quantity
    func summonShip() -> (String, Int) {
        let seed = random(min: 0, max: 100)
        var type : String = "Pawn"
        var quantity : Int = 0
        if seed < 79 {
            type = "Pawn"
            quantity = 5
        } else if seed < 89 {
            type = "Bishop"
            quantity = 1
        } else if seed < 99 {
            type = "Knight"
            quantity = 1
        } else {
            type = "Rook"
            quantity = 1
        }
        
        return (type, quantity)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
