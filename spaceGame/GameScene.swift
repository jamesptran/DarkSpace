//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by James Tran on 11/26/16.
//  Copyright © 2016 James Tran. All rights reserved.
//

import SpriteKit
import GameplayKit



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


extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "player")
    let playerShield = SKSpriteNode(imageNamed: "shield")
    
    let playerLaserCategory:UInt32 =  0x1 << 1
    let enemyShipCategory:UInt32 =  0x1 << 2
    let floorCategory:UInt32 = 0x1 << 3
    let roofCategory:UInt32 = 0x1 << 4
    let playerCategory:UInt32 = 0x1 << 5
    let playerShieldCategory:UInt32 = 0x1 << 6
    let enemyLaserCategory:UInt32 = 0x1 << 7
    
    var restartButton : UIButton!
    var score : Int = 0
    var scoreLabel : UILabel!

    
    var touchLocationX: CGFloat? = nil
    
    var starBackgroundPause: Double = 0
    /*override init() {
        super.init()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }*/
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    var background = SKSpriteNode(imageNamed: "Background/backgroundColor")
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func addSmallStar(){
        let smallStar = SKSpriteNode(imageNamed: "Background/starSmall")
        smallStar.setScale(0.5)
        let speed = 50 //random(min: 50, max: 150)
        let smallStarX = random(min: smallStar.size.width / 2, max: self.frame.size.width - smallStar.size.width / 2)
        let smallStarY = self.frame.size.height + smallStar.size.height / 2
        
        smallStar.position = CGPoint(x: smallStarX, y: smallStarY)
        smallStar.zPosition = 0
        
        addChild(smallStar)
        
        let actualDuration = Float(self.frame.size.height) / Float(speed)
        let actionMove = SKAction.move(to: CGPoint(x: smallStarX, y: -smallStar.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        smallStar.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    func addBigStar(){
        let bigStar = SKSpriteNode(imageNamed: "Background/starBig")
        bigStar.setScale(0.5)
        let speed = 75
        let bigStarX = random(min: bigStar.size.width / 2, max: self.frame.size.width - bigStar.size.width / 2)
        let bigStarY = self.frame.size.height + bigStar.size.height / 2
        
        bigStar.position = CGPoint(x: bigStarX, y: bigStarY)
        bigStar.zPosition = 0
        
        addChild(bigStar)
        
        let actualDuration = Float(self.frame.size.height) / Float(speed)
        let actionMove = SKAction.move(to: CGPoint(x: bigStarX, y: -bigStar.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        bigStar.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    func addEnemyShip(){
        let speed: Double = 12.0
        let ship = SKSpriteNode(imageNamed: "enemyShip")
        ship.setScale(0.5)
        ship.zPosition = 2
        let shipY = self.frame.size.height + ship.size.height/2
        let shipX = random(min: ship.size.width/2, max: self.frame.size.width - ship.size.width/2)
        
        ship.position = CGPoint(x: shipX, y: shipY)
        
        addChild(ship)
        ship.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ship.size.width,
                                                             height: ship.size.height))
        ship.physicsBody?.collisionBitMask = playerLaserCategory
        ship.physicsBody?.categoryBitMask = enemyShipCategory
        ship.physicsBody?.contactTestBitMask = playerLaserCategory
        ship.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -speed))
        ship.physicsBody?.mass = 70
        
        addEnemyLaser(ship: ship)
        
        //let actualDuration = 5
        //let actionMove = SKAction.move(to: CGPoint(x: shipX, y: -ship.size.height/2), duration: TimeInterval(actualDuration))
        //let actionMoveDone = SKAction.removeFromParent()
        //ship.run(SKAction.sequence([actionMove, actionMoveDone]))
        //addEnemyLaser(ship: ship)
    }
    
    
    func addEnemyLaser(ship: SKSpriteNode){
        let laser = SKSpriteNode(imageNamed: "laserRed")
        laser.setScale(0.5)
        laser.position = ship.position
        laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width, height: laser.size.height))
        laser.physicsBody?.categoryBitMask = enemyLaserCategory
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.contactTestBitMask = playerCategory + playerShieldCategory + floorCategory
        addChild(laser)
        laser.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -1.0))
        //let actualDuration = 5
        //let actionMove = SKAction.move(to: CGPoint(x: ship.position.x, y: -laser.size.height/2), duration: TimeInterval(actualDuration))
        //let actionDone = SKAction.removeFromParent()
        
     }
    
    
    /*func updatePlayerPos(x: CGFloat){
        
        
        let speed: CGFloat = 250.0
        
        let actualDuration : Float = Float(abs(x - player.position.x)) / Float(speed)
        if ((x - player.position.x) > 0){
            player.texture = SKTexture(imageNamed:"playerRight")
        } else if ((x - player.position.x) < 0) {
            player.texture = SKTexture(imageNamed:"playerLeft")
        } else if ((x - player.position.x) == 0) {
            player.texture = SKTexture(imageNamed:"player")
        }
        
        
        let ActionMove = SKAction.move(to: CGPoint(x: x, y: player.position.y), duration: TimeInterval(actualDuration))
        player.run(ActionMove)
        playerShield.run(ActionMove)
        
    }*/
    
    var right = false
    var left = false
    override func update(_ currentTime: TimeInterval) {
        let playerSpeed : Int = 110
        if (player.position.x < touchLocationX! - 5){
            if (!right){
                player.physicsBody?.velocity = CGVector(dx: playerSpeed, dy: 0)
                player.texture = SKTexture(imageNamed:"playerRight")
                playerShield.physicsBody?.velocity = CGVector(dx: playerSpeed, dy: 0)
                right = true
                left = false
            }
        } else if (player.position.x > touchLocationX! + 5){
            if (!left){
                player.physicsBody?.velocity = CGVector(dx: -playerSpeed, dy: 0)
                player.texture = SKTexture(imageNamed:"playerLeft")
                playerShield.physicsBody?.velocity = CGVector(dx: -playerSpeed, dy: 0)
                left = true
                right = false
            }
        } else {
            if (right || left){
                right = false
                left = false
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                player.texture = SKTexture(imageNamed:"player")
                playerShield.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
    }
    
    
    func addPlayerLaser(){
        let laser = SKSpriteNode(imageNamed: "laserGreen")
        laser.setScale(0.5)
        let speed: Double = 1.5
        laser.zPosition = 2
        let laserX = player.position.x
        let laserY = player.position.y + player.size.height / 2
        laser.position = CGPoint(x: laserX, y: laserY)
        addChild(laser)
        laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width,
                                                              height: laser.size.height))
        laser.physicsBody?.categoryBitMask = playerLaserCategory
        laser.physicsBody?.contactTestBitMask = enemyShipCategory
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: speed))
        laser.physicsBody?.mass = 0.1
    }
    
    
    func playerLaserExplode(x: CGFloat, y: CGFloat){
        let shot = SKSpriteNode(imageNamed: "laserGreenShot")
        shot.setScale(0.5)
        shot.position = CGPoint(x: x, y: y)
        addChild(shot)
        let actionFade = SKAction.fadeOut(withDuration: 0.4)
        let actionDone = SKAction.removeFromParent()
        shot.run(SKAction.sequence([actionFade, actionDone]))
    }
    
    /*func addExplodeEmitter() -> SKEmitterNode? {
        return SKEmitterNode(fileNamed: "enemyShipExplode.sks")
    }*/
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody,secondBody : SKSpriteNode
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA.node as! SKSpriteNode
            secondBody = contact.bodyB.node as! SKSpriteNode
        }
        else
        {
            firstBody = contact.bodyB.node as! SKSpriteNode
            secondBody = contact.bodyA.node as! SKSpriteNode
        }
        
        if ((((firstBody.physicsBody?.categoryBitMask)! & playerLaserCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyShipCategory) != 0))
        {
            score += 1
            scoreLabel.text = "Score: " + String(score)
            let actionFade = SKAction.fadeOut(withDuration: 0.1)
            let actionDone = SKAction.removeFromParent()
            firstBody.removeAllActions()
            firstBody.removeFromParent()
            playerLaserExplode(x: (firstBody.position.x), y: (firstBody.position.y))
            secondBody.removeAllActions()
            secondBody.run(SKAction.sequence([actionFade, actionDone]))
            //let myEmitter = addExplodeEmitter
            //myEmitter()?.particleScale = 0.3;
            //myEmitter()?.particleScaleRange = 0.2;
            //myEmitter()?.particleScaleSpeed = -0.1;
            //myEmitter()?.position = CGPoint(x: 500, y: 500)
            //myEmitter()?.name = "explosion"
            //myEmitter()?.targetNode = self.scene
            //secondBody.scene?.addChild((myEmitter())!)
        }
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerLaserCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & roofCategory) != 0)){
            firstBody.removeFromParent()
        }
        
        else if ((((firstBody.physicsBody?.categoryBitMask)! & enemyShipCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & floorCategory) != 0)){
            firstBody.removeFromParent()
        }
        
        else if ((((firstBody.physicsBody?.categoryBitMask)! & floorCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            secondBody.removeFromParent()
        }
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerShieldCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            firstBody.removeFromParent()
            secondBody.removeFromParent()
        }
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            firstBody.removeFromParent()
            secondBody.removeFromParent()
        }
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        touchLocationX = touchLocation.x
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        touchLocationX = touchLocation.x
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        player.texture = SKTexture(imageNamed:"player")
        touchLocationX = player.position.x
    }
    
    
    override func didMove(to view: SKView) {
        scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width/4, height: self.frame.height*0.05))
        scoreLabel.adjustsFontForContentSizeCategory = true
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.center = CGPoint(x: self.frame.width/2, y: self.frame.height*0.025)
        scoreLabel.textColor = UIColor.white
        scoreLabel.text = "Score: 0"
        self.view?.addSubview(scoreLabel)
        
        
        background.size = self.frame.size
        background.zPosition = -1
        background.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        addChild(background)
        player.setScale(0.5)
        player.zPosition = 3
        player.position = CGPoint(x: self.frame.size.width * 0.5, y: player.size.height)
        addChild(player)
        
        playerShield.setScale(0.5)
        playerShield.zPosition = 2
        playerShield.position = CGPoint(x: self.frame.size.width * 0.5, y: player.size.height)
        addChild(playerShield)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = 0
        player.physicsBody?.collisionBitMask = 0

        playerShield.physicsBody = SKPhysicsBody(circleOfRadius: playerShield.size.height/2)
        playerShield.physicsBody?.categoryBitMask = playerShieldCategory
        playerShield.physicsBody?.contactTestBitMask = 0
        playerShield.physicsBody?.collisionBitMask = 0

        touchLocationX = player.position.x
        
        let roof = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.size.width, height: 2.0))
        roof.position = CGPoint(x: self.frame.size.width/2,  y:self.frame.size.height*1.3)
        roof.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:roof.size.width, height: roof.size.height))
        roof.physicsBody?.isDynamic = false
        roof.physicsBody?.categoryBitMask = roofCategory
        roof.physicsBody?.contactTestBitMask = playerLaserCategory
        roof.physicsBody?.collisionBitMask = 0
        addChild(roof)
        
        let floor = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.size.width, height: 2.0))
        floor.position = CGPoint(x: self.frame.size.width/2,  y: -self.frame.size.height*0.3)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:floor.size.width, height: floor.size.height))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = floorCategory
        floor.physicsBody?.contactTestBitMask = enemyShipCategory
        floor.physicsBody?.collisionBitMask = 0
        addChild(floor)
        
        
        let generateEnemyShip = SKAction.sequence([SKAction.run(addEnemyShip),SKAction.wait(forDuration: 1.0)])
        let generateSmallStar = SKAction.sequence([SKAction.run(addSmallStar),SKAction.wait(forDuration: 0.3)])
        let generateBigStar = SKAction.sequence([SKAction.run(addBigStar),SKAction.wait(forDuration: 0.7)])
        let generateLaser = SKAction.sequence([SKAction.run(addPlayerLaser), SKAction.wait(forDuration: 0.6)])
        run(SKAction.repeat(generateEnemyShip, count: 50))
        run(SKAction.repeatForever(generateSmallStar))
        run(SKAction.repeatForever(generateBigStar))
        run(SKAction.repeatForever(generateLaser))
    }
    
}
