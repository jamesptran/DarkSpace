//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by James Tran on 11/26/16.
//  Copyright © 2016 James Tran. All rights reserved.
//

import SpriteKit
import GameplayKit

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


extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}


class enemyShip: SKSpriteNode {
    var hp = 4
    var laserSpawnTime : TimeInterval = 0
}

class playerShip: SKSpriteNode {
    var life = 3
    func loseALife(){
        life -= 1
        
        let FadeOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let FadeIn = SKAction.fadeAlpha(to: 0.5, duration: 0.3)
            
        let Flicker = SKAction.sequence([FadeOut, FadeIn])
        let Appear = SKAction.fadeIn(withDuration: 0)
        self.run(SKAction.sequence([SKAction.run(invulnerable), Flicker, Flicker, Flicker, Appear, SKAction.run(vulnerable)]))
    }
    
    func invulnerable(){
        self.physicsBody?.contactTestBitMask = 0
    }
    
    func vulnerable(){
        self.physicsBody?.contactTestBitMask = enemyLaserCategory
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = playerShip(imageNamed: "player")
    let playerShield = SKSpriteNode(imageNamed: "shield2")
    let score1 = SKSpriteNode(imageNamed: "numeral0")
    let score2 = SKSpriteNode(imageNamed: "numeral0")
    let score3 = SKSpriteNode(imageNamed: "numeral0")
    let playerLifeNum = SKSpriteNode(imageNamed: "numeral0")
    var shield = true
    
    let totalEnemyShipsCount = 50
    var totalEnemyShipsRemoved = 0
    
    var restartButton : UIButton!
    var score : Int = 0
    var currentSystemTime : TimeInterval = 0.0

    var touchLocationX: CGFloat? = nil
    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
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

    
    func showGameOverScene(){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.score = self.score
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    
    var right = false
    var left = false
    var timeOfLastLaser: TimeInterval = 0.0
    override func update(_ currentTime: TimeInterval) {
        // Show Game Over view when player's life = -1 (dies when having 0 life left)
        // Or when last ship is destroyed
        if (player.life == -1) || (totalEnemyShipsRemoved >= totalEnemyShipsCount){
            showGameOverScene()
        }
        
        
        // Assign the currentSystemTime as currentTime to calculate spawn time
        currentSystemTime = currentTime
        
        
        // Update player's position looking at touchLocationX
        let playerSpeed : Int = 300
        
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
                player.texture = SKTexture(imageNamed: "player")
                playerShield.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
        
        // Add laser fire to enemy based on last laser spawn time.
        enumerateChildNodes(withName: "enemy1", using: {(node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            
            if ((currentTime - (node as! enemyShip).laserSpawnTime) > 1.5){
                (node as! enemyShip).laserSpawnTime = currentTime
                self.addEnemyLaser(ship: (node as! enemyShip))
            }
        })
    }
    
    
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
            if ((secondBody as! enemyShip).hp == 1){
                score += 1
                updateScore()
                (secondBody as! enemyShip).hp -= 1
                let actionFade = SKAction.fadeOut(withDuration: 0.2)
                let actionDone = SKAction.run {
                    secondBody.removeFromParent()
                    self.totalEnemyShipsRemoved += 1
                }
                
                secondBody.run(SKAction.sequence([actionFade, actionDone]))
            } else {
                (secondBody as! enemyShip).hp -= 1
            }
            playerLaserExplode(x: (firstBody.position.x), y: (firstBody.position.y))
            firstBody.removeFromParent()
            
            
        }
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerLaserCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & roofCategory) != 0)){
            firstBody.removeFromParent()
        }
            
        else if ((((firstBody.physicsBody?.categoryBitMask)! & enemyShipCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & floorCategory) != 0)){
            firstBody.removeFromParent()
            totalEnemyShipsRemoved += 1
        }
            
        else if ((((firstBody.physicsBody?.categoryBitMask)! & floorCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            secondBody.removeFromParent()
        }
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerShieldCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            if (shield){
                shield = false
                firstBody.isHidden = true
                firstBody.physicsBody?.contactTestBitMask = 0
                player.physicsBody?.contactTestBitMask = enemyLaserCategory
                secondBody.removeFromParent()
            }
        }
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            if (!shield){
                (firstBody as! playerShip).loseALife()
                secondBody.removeFromParent()
                updatePlayerLives()
            }
        }
    }
    
    
    func addEnemyShip(){
        let speed: Double = 12
        let ship = enemyShip(imageNamed: "enemyBlack3")
        ship.setScale(0.5)
        ship.zPosition = 1
        let shipY = self.frame.size.height + ship.size.height/2
        let shipX = random(min: ship.size.width/2, max: self.frame.size.width - ship.size.width/2)
        
        ship.position = CGPoint(x: shipX, y: shipY)
        ship.name = "enemy1"
        addChild(ship)
        ship.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ship.size.width,
                                                             height: ship.size.height))
        
        let afterburner = SKSpriteNode(imageNamed: "fire06")
        afterburner.setScale(1.5)
        afterburner.position = CGPoint(x: 0, y: ship.frame.size.height + afterburner.size.height/2.0)
        afterburner.zPosition = 0
        ship.addChild(afterburner)
        
        ship.physicsBody?.collisionBitMask = 0
        ship.physicsBody?.categoryBitMask = enemyShipCategory
        ship.physicsBody?.contactTestBitMask = playerLaserCategory
        ship.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -speed))
        ship.physicsBody?.mass = 70
        ship.physicsBody?.linearDamping = 0
        addEnemyLaser(ship: ship)
        ship.laserSpawnTime = currentSystemTime
    }
    
    
    func addEnemyLaser(ship: SKSpriteNode){
        let laser = SKSpriteNode(imageNamed: "laserRed05")
        laser.setScale(0.5)
        laser.position = ship.position
        laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width, height: laser.size.height))
        laser.physicsBody?.categoryBitMask = enemyLaserCategory
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.contactTestBitMask = floorCategory
        addChild(laser)
        laser.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -3.0))
        
        laser.physicsBody?.linearDamping = 0
     }
    
    
    func addPlayerLaser(){
        // Create a laser for each gun the player has
        self.player.enumerateChildNodes(withName: "playerGun", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            let laser = SKSpriteNode(imageNamed: "laserBlue15")
            laser.setScale(0.5)
            let speed: Double = 5
            laser.zPosition = 2
            laser.position = CGPoint(x: self.player.position.x + node.position.x/2, y: self.player.position.y + node.position.y)
            
            laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width,
                                                                  height: laser.size.height))
            laser.physicsBody?.categoryBitMask = playerLaserCategory
            laser.physicsBody?.contactTestBitMask = enemyShipCategory
            laser.physicsBody?.collisionBitMask = 0
            laser.physicsBody?.linearDamping = 0
            self.addChild(laser)
            laser.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: speed))
        })
    }
    
    
    func playerLaserExplode(x: CGFloat, y: CGFloat){
        let shot = SKSpriteNode(imageNamed: "laserBlue08")
        shot.setScale(0.5)
        shot.position = CGPoint(x: x, y: y)
        addChild(shot)
        let actionFade = SKAction.fadeOut(withDuration: 0.4)
        let actionDone = SKAction.removeFromParent()
        shot.run(SKAction.sequence([actionFade, actionDone]))
    }

    func updateScore(){
        let charInt1 : Int = Int(score / 100)
        let charInt2: Int = Int((score - charInt1*100) / 10)
        let charInt3: Int = Int(score - charInt1 * 100 - charInt2 * 10)
        putNumToNode(scoreChar: String(charInt1), charNode: score1)
        putNumToNode(scoreChar: String(charInt2), charNode: score2)
        putNumToNode(scoreChar: String(charInt3), charNode: score3)
    }
    
    //scoreChar needs to be less than 10
    func putNumToNode(scoreChar: String, charNode: SKSpriteNode){
        let fileName = "numeral" + scoreChar
        charNode.texture = SKTexture(imageNamed: fileName)
    }
    
    
    func addScoreBoard(){
        let charSizeWidth = score3.size.width
        let charSizeHeight = score3.size.height
        score3.position = CGPoint(x: self.frame.width - charSizeWidth, y: self.frame.height - charSizeHeight)
        score2.position = CGPoint(x: self.frame.width - charSizeWidth*2.1, y: self.frame.height - charSizeHeight)
        score1.position = CGPoint(x: self.frame.width - charSizeWidth*3.2, y: self.frame.height - charSizeHeight)
        score1.zPosition = 10
        score2.zPosition = 10
        score3.zPosition = 10
        addChild(score1)
        addChild(score2)
        addChild(score3)
    }

    
    func updatePlayerLives(){
        putNumToNode(scoreChar: String(player.life), charNode: playerLifeNum)
    }
    
    
    func addPlayerLivesBoard(){
        let playerMiniImage = SKSpriteNode(imageNamed:"playerLife1_red")
        let multiplySymbol = SKSpriteNode(imageNamed: "numeralX")
        
        let charSizeWidth = playerMiniImage.size.width
        let charSizeHeight = playerMiniImage.size.height
        
        updatePlayerLives()
        
        playerMiniImage.position = CGPoint(x: charSizeWidth, y: self.frame.height - charSizeHeight)
        multiplySymbol.position = CGPoint(x: charSizeWidth*2, y: self.frame.height - charSizeHeight)
        playerLifeNum.position = CGPoint(x: charSizeWidth*3, y: self.frame.height - charSizeHeight)
        
        playerMiniImage.zPosition = 10
        multiplySymbol.zPosition = 10
        playerLifeNum.zPosition = 10
        addChild(playerMiniImage)
        addChild(multiplySymbol)
        addChild(playerLifeNum)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        touchLocationX = touchLocation.x
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        touchLocationX = touchLocation.x
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        player.texture = SKTexture(imageNamed:"player")
        touchLocationX = player.position.x
    }
    
    
    func addPlayerItems(){
        let engine = SKSpriteNode(imageNamed: "engine3")
        let gunRight = SKSpriteNode(imageNamed: "gun02")
        let gunLeft = SKSpriteNode(imageNamed: "gun02")
        let afterburner = SKSpriteNode(imageNamed: "fire16")
        
        gunRight.name = "playerGun"
        gunLeft.name = "playerGun"
        
        engine.setScale(0.5)
        engine.position = CGPoint(x: 0, y: -player.size.height - engine.size.height/2)
        
        gunRight.position = CGPoint(x: player.size.width, y: 0)
        gunLeft.position = CGPoint(x: -player.size.width, y: 0 )
        
        gunRight.zPosition = -1
        gunLeft.zPosition = -1
        
        
        afterburner.position = CGPoint(x: 0, y: -player.size.height - engine.size.height/2 - afterburner.size.height/2)
        
        player.addChild(engine)
        player.addChild(gunRight)
        player.addChild(gunLeft)
        player.addChild(afterburner)
    }
    
    
    func addSmallStar(){
        var smallStar = SKSpriteNode()
        let starNum = random(min: 0, max: 4)
        if (starNum <= 2.5){
            smallStar = SKSpriteNode(imageNamed: "starBig1")
        } else {
            smallStar = SKSpriteNode(imageNamed: "starBig2")
        }
        smallStar.setScale(0.25)
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
        var bigStar = SKSpriteNode()
        let starNum = random(min: 0, max: 4)
        if (starNum <= 2.5){
            bigStar = SKSpriteNode(imageNamed: "starBig1")
        } else {
            bigStar = SKSpriteNode(imageNamed: "starBig2")
        }
        
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
    
    
    func addNebula(){
        let nebula = SKSpriteNode(imageNamed:"nebula")
        nebula.setScale(0.8)
        let speed = 50
        let nebulaX = random(min: nebula.size.width / 2, max: self.frame.size.width - nebula.size.width / 2)
        let nebulaY = self.frame.size.height + nebula.size.height / 2
        
        nebula.position = CGPoint(x: nebulaX, y: nebulaY)
        nebula.zPosition = 5
        
        addChild(nebula)
        
        let actualDuration = Float(self.frame.size.height) / Float(speed)
        let actionMove = SKAction.move(to: CGPoint(x: nebulaX, y: -nebula.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        nebula.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    var shieldCount = 0
    func resetShield(){
        if (!shield){
            shieldCount += 1
        }
        
        if (shieldCount >= 12){
            player.physicsBody?.contactTestBitMask = 0
            playerShield.physicsBody?.contactTestBitMask = enemyLaserCategory
            shield = true
            playerShield.isHidden = false
            shieldCount = 0
        }
    }
    
    
    override func didMove(to view: SKView) {
        print("Move to game scene, begin making scene")
        
        addScoreBoard()
        addPlayerLivesBoard()
        
        self.backgroundColor = UIColor.black
        player.setScale(0.5)
        player.zPosition = 2
        player.position = CGPoint(x: self.frame.size.width * 0.5, y: player.size.height * 1.5)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = 0
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.linearDamping = 0
        
        addPlayerItems()

        playerShield.zPosition = 0
        player.addChild(playerShield)
        
        playerShield.physicsBody = SKPhysicsBody(circleOfRadius: playerShield.size.height/2)
        playerShield.physicsBody?.categoryBitMask = playerShieldCategory
        playerShield.physicsBody?.contactTestBitMask = enemyLaserCategory
        playerShield.physicsBody?.collisionBitMask = 0
        playerShield.physicsBody?.linearDamping = 0

        touchLocationX = player.position.x
        
        let roof = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.size.width, height: 2.0))
        roof.position = CGPoint(x: self.frame.size.width/2,  y:self.frame.size.height*2 + roof.size.height)
        roof.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:roof.size.width, height: roof.size.height))
        roof.physicsBody?.isDynamic = false
        roof.physicsBody?.categoryBitMask = roofCategory
        roof.physicsBody?.contactTestBitMask = playerLaserCategory
        roof.physicsBody?.collisionBitMask = 0
        addChild(roof)
        
        let floor = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.size.width, height: 2.0))
        floor.position = CGPoint(x: self.frame.size.width/2,  y: -self.frame.size.height*0.15)
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:floor.size.width, height: floor.size.height))
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = floorCategory
        floor.physicsBody?.contactTestBitMask = enemyShipCategory
        floor.physicsBody?.collisionBitMask = 0
        addChild(floor)
        
        
        // Generating non-random, ship objects
        let generateEnemyShip = SKAction.sequence([SKAction.run(addEnemyShip),SKAction.wait(forDuration: 1.2)]) // 1.0s mid
        let generatePlayerLaser = SKAction.sequence([SKAction.run(addPlayerLaser), SKAction.wait(forDuration: 0.2)]) // 0.2s mid
        // Generate shield every 6s after shield is gone
        let generateShield = SKAction.sequence([SKAction.run(resetShield), SKAction.wait(forDuration: 0.5)])
        
        // Generating random timing, environment objects
        let generateSmallStar = SKAction.sequence([SKAction.run(addSmallStar),SKAction.wait(forDuration: TimeInterval(random(mid: 0.3, range: 0.1)))]) // 0.3s mid
        let generateBigStar = SKAction.sequence([SKAction.run(addBigStar),SKAction.wait(forDuration: TimeInterval(random(mid: 0.7, range: 0.2)))]) // 0.7s mid
        let generateNebula = SKAction.sequence([SKAction.run(addNebula), SKAction.wait(forDuration: TimeInterval(random(mid: 6.0, range: 2.0)))]) // 6.0s mid
        
        // Generate last ship with detection for Game Over
        
        run(SKAction.repeatForever(generateSmallStar))
        run(SKAction.repeatForever(generateBigStar))
        run(SKAction.repeatForever(generatePlayerLaser))
        run(SKAction.repeatForever(generateNebula))
        run(SKAction.repeatForever(generateShield))
        // Count should be equal to total ships - 1, since last ship is spawn separately
        run(SKAction.sequence([SKAction.repeat(generateEnemyShip, count: totalEnemyShipsCount)]))
        
    }
}
