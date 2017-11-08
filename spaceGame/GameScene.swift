//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by James Tran on 11/26/16.
//  Copyright © 2016 James Tran. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = PlayerShip(imageNamed: "player")
    let score1 = SKSpriteNode(imageNamed: "numeral0")
    let score2 = SKSpriteNode(imageNamed: "numeral0")
    let score3 = SKSpriteNode(imageNamed: "numeral0")
    
    var levelID : Int = -1
    
    // Below is for healthbar
    let hpBarLeft = SKSpriteNode(imageNamed: "barHorizontal_green_left")
    let hpBarMid = SKSpriteNode(imageNamed: "barHorizontal_green_mid")
    let hpBarRight = SKSpriteNode(imageNamed: "barHorizontal_green_right")
    
    var totalPawnsCount = 0
    var totalPawnsRemoved = 0
    
    var totalKnightsCount = 0
    var totalKnightsRemoved = 0
    
    var totalBishopsCount = 0
    var totalBishopsRemoved = 0
    
    var totalRooksCount = 0
    var totalRooksRemoved = 0
    
    var totalQueensCount = 0
    var totalQueensRemoved = 0
    
    var totalKingsCount = 0
    var totalKingsRemoved = 0
    
    var generatePawnsInterval : TimeInterval = 3.0
    var generateKnightsInterval : TimeInterval = 3.0
    var generateBishopsInterval : TimeInterval = 3.0
    var generateRooksInterval : TimeInterval = 3.0
    var generateQueensInterval : TimeInterval = 3.0
    var generateKingsInterval : TimeInterval = 3.0
    
    var score : Int = 0
    // Current system time taken from update function
    var currentSystemTime : TimeInterval = 0.0

    var motionManager = CMMotionManager()
    var touchLocationX: CGFloat? = nil
    var touchLocationY: CGFloat? = nil
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }

    
    func showGameOverScene(destroyed: Bool, by type: LaserType){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.score = self.score
        gameOverScene.totalPawns = self.totalPawnsCount
        gameOverScene.totalKnights = self.totalKnightsCount
        gameOverScene.totalBishops = self.totalBishopsCount
        gameOverScene.totalRooks = self.totalRooksCount
        gameOverScene.totalQueens = self.totalQueensCount
        gameOverScene.totalKings = self.totalKingsCount
        
        gameOverScene.isDestroyed = destroyed
        gameOverScene.killedBy = type
        gameOverScene.levelID = self.levelID

        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func screenFlashesRed(){
        let redScreen = SKSpriteNode(color: UIColor.red, size: self.frame.size)
        redScreen.alpha = 0.2
        redScreen.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        addChild(redScreen)
        redScreen.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
    }
    
    
    /*func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        var playerForceVector : CGVector
        if let data = motionManager.accelerometerData {
            if fabs(data.acceleration.x) > 0.1 {
                player.physicsBody?.applyForce(CGVector(dx: 40*CGFloat(data.acceleration.x), dy: 0))
                playerShield.physicsBody?.applyForce(CGVector(dx: 40*CGFloat(data.acceleration.x), dy: 0))
                if (data.acceleration.x > 0){
                    player.texture = SKTexture(imageNamed: "playerRight")
                } else {
                    player.texture = SKTexture(imageNamed: "playerLeft")
                }
            }
        }
    }*/
    
    func detectOutOfBounds(){
        if player.position.x > (self.frame.size.width - player.shieldNode.size.width/4) {
            right = false
        }
        if player.position.x < player.shieldNode.size.width/4 {
            left = false
        }
    }
    
    var right : Bool = false
    var left : Bool = false
    override func update(_ currentTime: TimeInterval) {
        // Show Game Over view when player's life = 0 (dies when having 0 life)
        // Or when the last enemy ship is destroyed
        if (totalPawnsCount == totalPawnsRemoved &&
            totalBishopsCount == totalBishopsRemoved &&
            totalKnightsCount == totalKnightsRemoved &&
            totalRooksCount == totalRooksRemoved &&
            totalQueensCount == totalQueensRemoved &&
            totalKingsCount == totalKingsRemoved) {
            showGameOverScene(destroyed: false, by: .normal)
        }
        
        if totalQueensCount == totalQueensRemoved {
            self.enumerateChildNodes(withName: "King", using: {
                (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
                (node as! King).shieldUp = false
            })
        }
        
        
        // Assign the currentSystemTime as currentTime to calculate spawn time
        currentSystemTime = currentTime
        
        // Update player's position looking at touchLocationX
        //processUserMotion(forUpdate: currentTime)
        
        let playerSpeed : Int = 350
        
        detectOutOfBounds()
        if !right && !left {
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.texture = SKTexture(imageNamed: "player")
            player.shieldNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        } else if right && !left {
            player.physicsBody?.velocity = CGVector(dx: playerSpeed, dy: 0)
            player.texture = SKTexture(imageNamed:"playerRight")
            player.shieldNode.physicsBody?.velocity = CGVector(dx: playerSpeed, dy: 0)
        } else if left && !right {
            player.physicsBody?.velocity = CGVector(dx: -playerSpeed, dy: 0)
            player.texture = SKTexture(imageNamed:"playerLeft")
            player.shieldNode.physicsBody?.velocity = CGVector(dx: -playerSpeed, dy: 0)
        }
        
        // Add laser fire to enemy based on last laser spawn time.
        let shipTypeArray = ["Pawn", "Bishop", "Knight", "Rook", "Queen", "King"]
        for type in shipTypeArray {
            enumerateChildNodes(withName: type, using: {(node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
                if let enemyNode = node as? Ship {
                    if ((currentTime - enemyNode.laserSpawnTime) > enemyNode.laserInterval){
                        enemyNode.laserSpawnTime = currentTime
                        self.addEnemyLaser(ship: enemyNode)
                    }

                    enemyNode.physicsBody?.applyForce(CGVector(dx: 0, dy: -enemyNode.movementSpeed))
                }
            })
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody,secondBody : SKSpriteNode
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA.node != nil ? contact.bodyA.node as! SKSpriteNode : SKSpriteNode()
            secondBody = contact.bodyB.node != nil ? contact.bodyB.node as! SKSpriteNode : SKSpriteNode()
        }
        else {
            firstBody = contact.bodyB.node != nil ? contact.bodyB.node as! SKSpriteNode : SKSpriteNode()
            secondBody = contact.bodyA.node != nil ? contact.bodyA.node as! SKSpriteNode : SKSpriteNode()
        }
        
        if (firstBody.physicsBody == nil || secondBody.physicsBody == nil) {
            return
        }
        
        // If playerLaser contact enemy Ship
        if ((((firstBody.physicsBody?.categoryBitMask)! & playerLaserCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyShipCategory) != 0))
        {
            if let enemyNode = secondBody as? Ship {
                if (enemyNode.hp == 1){
                    if (enemyNode as? Pawn) != nil {
                        score += 1
                    }
                    if (enemyNode as? Knight) != nil {
                        score += 3
                    }
                    if (enemyNode as? Bishop) != nil {
                        score += 3
                    }
                    if (enemyNode as? Rook) != nil {
                        score += 5
                    }
                    if (enemyNode as? Queen) != nil {
                        score += 9
                    }
                    if (enemyNode as? King) != nil {
                        score += 100
                    }
                    
                    updateScore()
                    enemyNode.hp -= 1
                    let actionFade = SKAction.fadeOut(withDuration: 0.2)
                    let actionDone = SKAction.run {
                        secondBody.removeFromParent()
                        switch enemyNode.name {
                        case "Pawn"?:
                            self.totalPawnsRemoved += 1
                        case "Knight"?:
                            self.totalKnightsRemoved += 1
                        case "Bishop"?:
                            self.totalBishopsRemoved += 1
                        case "Rook"?:
                            self.totalRooksRemoved += 1
                        case "Queen"?:
                            self.totalQueensRemoved += 1
                        case "King"?:
                            self.totalKingsRemoved += 1
                        default:
                            self.totalPawnsRemoved += 1
                        }
                        
                    }
                    
                    secondBody.run(SKAction.sequence([actionFade, actionDone]))
                } else if let enemy = enemyNode as? King {
                    if !enemy.shieldUp {
                        enemyNode.hp -= 1
                    }
                } else {
                    enemyNode.hp -= 1
                    enemyNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1.0))
                }
                playerLaserExplode(x: (firstBody.position.x), y: (firstBody.position.y))
                firstBody.removeFromParent()
            }
        }
            
        // If playerLaser contact roof
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerLaserCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & roofCategory) != 0)){
            firstBody.removeFromParent()
        }
        // If enemyShip contact roof, start shooting laser
        else if ((((firstBody.physicsBody?.categoryBitMask)! & enemyShipCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & roofCategory) != 0)){
            if let enemyNode = firstBody as? Ship {
                enemyNode.laserSpawnTime = currentSystemTime + 0.3 - enemyNode.laserInterval
            }
        }
        // If enemyShip contact floor
        else if ((((firstBody.physicsBody?.categoryBitMask)! & enemyShipCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & floorCategory) != 0)){
            firstBody.removeFromParent()
            if let enemyNode = firstBody as? Ship {
                if enemyNode.name == "Queen" || enemyNode.name == "King" {
                    let shipY = self.frame.size.height*1.2
                    let shipX = random(min: enemyNode.size.width/2, max: self.frame.size.width - enemyNode.size.width/2)
                    
                    enemyNode.position = CGPoint(x: shipX, y: shipY)
                    if let queen = enemyNode as? Queen {
                        queen.switchToRandomGunType()
                    } else if let king = enemyNode as? King {
                        let summonResult = king.summonShip()
                        
                        let shipType : String = summonResult.0
                        let quantity : Int = summonResult.1
                        
                        let generateShips = SKAction.sequence([SKAction.run({self.addShip(type: shipType)}),SKAction.wait(forDuration: 1.0)])
                        switch shipType {
                        case "Pawn":
                            self.totalPawnsCount += quantity
                        case "Bishop":
                            self.totalBishopsCount += quantity
                        case "Knight":
                            self.totalKnightsCount += quantity
                        case "Rook":
                            self.totalRooksCount += quantity
                        default:
                            break
                        }
                        
                        self.run(SKAction.repeat(generateShips, count: quantity))

                        
                        let summonLabel = SKLabelNode(text: "Enemy King called for reinforcements of " + shipType + "s.")
                        summonLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
                        summonLabel.fontSize = 14
                        summonLabel.fontName = "AvenirNext-Medium"
                        summonLabel.zPosition = 10
                        
                        summonLabel.alpha = 0
                        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                        let fadeOut = SKAction.fadeOut(withDuration: 2)
                        let remove = SKAction.removeFromParent()
                        
                        self.addChild(summonLabel)
                        summonLabel.run(SKAction.sequence([fadeIn, fadeOut, remove]))
                    }

                    enemyNode.laserSpawnTime = currentSystemTime + 999
                    addChild(enemyNode)
                    
                } else {
                    switch enemyNode.name {
                    case "Pawn"?:
                        self.totalPawnsRemoved += 1
                    case "Knight"?:
                        self.totalKnightsRemoved += 1
                    case "Bishop"?:
                        self.totalBishopsRemoved += 1
                    case "Rook"?:
                        self.totalRooksRemoved += 1
                    default:
                        self.totalPawnsRemoved += 1
                    }
                }
            }
        }
            
        // If enemyLaser contact floor
        else if ((((firstBody.physicsBody?.categoryBitMask)! & floorCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            secondBody.removeFromParent()
        }
            
        // If enemyLaser contact playerShield or player
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerShieldCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            if (player.shieldUp){
                switch secondBody.name ?? "" {
                case "Normal":
                    player.shieldUp = false
                    player.shieldNode.isHidden = true
                    player.shieldNode.physicsBody?.contactTestBitMask = 0
                    secondBody.removeFromParent()
                case "Piercing":
                    break
                case "Gattling":
                    enemyLaserExplode(x: secondBody.position.x, y: secondBody.position.y)
                    secondBody.removeFromParent()
                case "Plasma":
                    break
                default:
                    break
                }
            }
        }
        // Switch case for setting laser damage values
        else if ((((firstBody.physicsBody?.categoryBitMask)! & playerCategory) != 0) && (((secondBody.physicsBody?.categoryBitMask)! & enemyLaserCategory) != 0)){
            if (!player.shieldUp || secondBody.name == "Piercing" || player.shieldBroken){
                switch secondBody.name {
                case "Normal"?:
                    (firstBody as! PlayerShip).life -= 1
                    if (firstBody as! PlayerShip).life <= 0 {
                        showGameOverScene(destroyed: true, by: .normal)
                    }
                case "Fast"?:
                    (firstBody as! PlayerShip).life -= 1
                    if (firstBody as! PlayerShip).life <= 0 {
                        showGameOverScene(destroyed: true, by: .fast)
                    }
                case "Piercing"?:
                    (firstBody as! PlayerShip).life -= 2
                    if (firstBody as! PlayerShip).life <= 0 {
                        showGameOverScene(destroyed: true, by: .piercing)
                    }
                case "Gattling"?:
                    (firstBody as! PlayerShip).life -= 0.25
                    if (firstBody as! PlayerShip).life <= 0 {
                        showGameOverScene(destroyed: true, by: .gattling)
                    }
                case "Plasma"?:
                    let actionFade = SKAction.fadeOut(withDuration: 1.5)
                    let showGameOver = SKAction.run({
                        self.showGameOverScene(destroyed: true, by: .plasma)
                    })
                    
                    let gameOverSequence = SKAction.sequence([actionFade, showGameOver])
                    
                    player.run(gameOverSequence)
                default:
                    break
                }
                
                updateHealthbar()
                screenFlashesRed()
                enemyLaserExplode(x: secondBody.position.x, y: secondBody.position.y)
                secondBody.removeFromParent()
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        touchLocationX = touchLocation.x
        touchLocationY = touchLocation.y
        
        let node : SKNode = self.atPoint(touchLocation)
        if node.name == "leftControl" {
            left = true
            right = false
        } else if node.name == "rightControl" {
            right = true
            left = false
        } else {
            right = false
            left = false
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        touchLocationX = touchLocation.x
        touchLocationY = touchLocation.y
        
        let node : SKNode = self.atPoint(touchLocation)
        if node.name == "leftControl" {
            left = true
            right = false
        } else if node.name == "rightControl" {
            right = true
            left = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        player.texture = SKTexture(imageNamed:"player")
        touchLocationX = player.position.x
        touchLocationY = player.position.y
        
        let node : SKNode = self.atPoint(touchLocation)
        if node.name == "leftControl" {
            left = false
        } else if node.name == "rightControl" {
            right = false
        } else {
            left = false
            right = false
        }
        if node.name == "pauseButton" {
            if self.isPaused == false {
                addMenuButton()
                addResumeButton()
                self.isPaused = true
            }
        } else if node.name == "resumeButton" {
            self.isPaused = false
            node.removeFromParent()
            childNode(withName: "menuButton")?.removeFromParent()
        } else if node.name == "menuButton" {
            let reveal = SKTransition.doorsCloseVertical(withDuration: 0.5)
            let scene = LevelPickerScene(size: self.size)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    func addShip(type: String) {
        var ship : Ship = Ship()
        
        switch type {
        case "Pawn":
            ship = Pawn()
        case "Bishop":
            ship = Bishop()
        case "Knight":
            ship = Knight()
        case "Rook":
            ship = Rook()
        case "Queen":
            ship = Queen()
            (ship as! Queen).switchToRandomGunType()
        case "King":
            ship = King()
        default:
            break
        }
        ship.laserSpawnTime = currentSystemTime + 999
        
        ship.zPosition = 1
        let shipY = self.frame.size.height*1.5
        let shipX = random(min: ship.size.width/2, max: self.frame.size.width - ship.size.width/2)
        
        ship.position = CGPoint(x: shipX, y: shipY)
        addChild(ship)
        
        // Add physics body and movements
        //ship.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -ship.movementSpeed))
        
    }
    
    func addQueens(quantity number: Int) {
        for i in 1...number {
            let ship: Queen = Queen()
            ship.zPosition = 1
            let shipY = self.frame.size.height + ship.size.height/2
            let shipX = (self.frame.size.width / CGFloat(number+1)) * CGFloat(i)
            
            ship.position = CGPoint(x: shipX, y: shipY)
            addChild(ship)
        }
    }
    
    
    func addEnemyLaser(ship: Ship){
        ship.enumerateChildNodes(withName: "Gun", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            
            var laser = SKSpriteNode()
            switch ship.laserType {
            case .normal:
                laser = SKSpriteNode(imageNamed: "enemyLaserNormal")
                laser.setScale(0.5)
                laser.name = "Normal"
                
            case .fast:
                laser = SKSpriteNode(imageNamed: "enemyLaserNormalFast")
                laser.setScale(0.5)
                laser.name = "Normal"
                
            case .piercing:
                laser = SKSpriteNode(imageNamed: "enemyLaserPiercing")
                laser.setScale(0.5)
                laser.name = "Piercing"
                
            case .gattling:
                laser = SKSpriteNode(imageNamed: "enemyLaserGattling")
                laser.setScale(0.8)
                laser.name = "Gattling"
            case .plasma:
                laser = SKSpriteNode(imageNamed: "enemyLaserPlasma")
                laser.setScale(0.8)
                laser.name = "Plasma"
            }
            
            laser.position = CGPoint(x: ship.position.x + node.position.x/2, y: ship.position.y + node.position.y)
            if ship.laserType == .plasma {
                laser.physicsBody = SKPhysicsBody(circleOfRadius: laser.size.height/2)
            } else {
                laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width, height: laser.size.height))
            }
            
            laser.physicsBody?.categoryBitMask = enemyLaserCategory
            laser.physicsBody?.collisionBitMask = 0
            laser.physicsBody?.contactTestBitMask = floorCategory
            
            laser.physicsBody?.linearDamping = 0
            laser.physicsBody?.mass = 0.003
            
            self.addChild(laser)
            
            laser.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -ship.laserSpeed))
        })
     }
    
    
    func addPlayerLaser(){
        // Create a laser for each gun the player has
        self.player.enumerateChildNodes(withName: "playerGun", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            let laser = SKSpriteNode(imageNamed: "laserBlue15")
            let speed: Double = 2.5
            
            laser.setScale(0.5)
            laser.zPosition = 2
            laser.position = CGPoint(x: self.player.position.x + node.position.x/2, y: self.player.position.y + node.position.y)
            
            laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width,
                                                                  height: laser.size.height))
            laser.physicsBody?.categoryBitMask = playerLaserCategory
            laser.physicsBody?.contactTestBitMask = enemyShipCategory
            laser.physicsBody?.collisionBitMask = 0
            laser.physicsBody?.linearDamping = 0
            laser.physicsBody?.mass = 0.003
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
    
    func enemyLaserExplode(x: CGFloat, y: CGFloat){
        let shot = SKSpriteNode(imageNamed: "laserRed08")
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
    
    
    func addPlayerLivesBoard(){
        let playerMiniImage = SKSpriteNode(imageNamed:"playerLife1_red")
        
        let charSizeWidth = playerMiniImage.size.width
        let charSizeHeight = playerMiniImage.size.height + 22
        
        playerMiniImage.position = CGPoint(x: 48*1.5+charSizeWidth, y: self.frame.height - charSizeHeight)
        
        generateHealthbar(at: CGPoint(x: 48*1.5+charSizeWidth*2, y: self.frame.height - charSizeHeight), for: self.player)
        
        playerMiniImage.zPosition = 10
        addChild(playerMiniImage)
    }
    
    func updateHealthbar() {
        let progress : CGFloat = CGFloat(player.life) / CGFloat(player.maxlife)
        
        hpBarMid.size = CGSize(width: 150*progress, height: hpBarMid.size.height)
        
        hpBarMid.position = CGPoint(x: hpBarLeft.position.x + hpBarLeft.size.width/2 + hpBarMid.size.width/2, y: hpBarLeft.position.y)
        hpBarRight.position = CGPoint(x: hpBarMid.position.x + hpBarMid.size.width/2 + hpBarRight.size.width/2, y: hpBarLeft.position.y)
    }
    
    func generateHealthbar(at position: CGPoint, for player: PlayerShip) {
        hpBarLeft.position = CGPoint(x: position.x + hpBarLeft.size.width, y: position.y)
        updateHealthbar()
        
        hpBarLeft.zPosition = 10
        hpBarMid.zPosition = 10
        hpBarRight.zPosition = 10
        
        
        addChild(hpBarLeft)
        addChild(hpBarMid)
        addChild(hpBarRight)
    }
    
    
    func addPauseButton(){
        let pauseButton = SKSpriteNode(imageNamed: "flatLight12")
        pauseButton.position = CGPoint(x: pauseButton.size.width, y: self.frame.height - pauseButton.size.height)
        
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 10
        addChild(pauseButton)
    }
    
    
    func addMenuButton() {
        let menuButton = SKLabelNode(text: "Back to level")
        menuButton.fontSize = 40
        menuButton.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - menuButton.frame.size.height - 10)
        menuButton.fontName = "AvenirNext-Medium"
        menuButton.isHidden = false
        menuButton.name = "menuButton"
        menuButton.zPosition = 10
        
        addChild(menuButton)
    }
    
    
    func addResumeButton() {
        let resumeButton = SKLabelNode(text: "Resume")
        resumeButton.fontSize = 40
        resumeButton.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + resumeButton.frame.size.height/2 + 10)
        resumeButton.fontName = "AvenirNext-Medium"
        resumeButton.isHidden = false
        resumeButton.name = "resumeButton"
        resumeButton.zPosition = 10
        
        addChild(resumeButton)
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
        nebula.setScale(0.7)
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
        if (!player.shieldUp){
            shieldCount += 1
        }
        
        if (shieldCount >= 18 && player.shieldBroken == false){
            player.shieldNode.physicsBody?.contactTestBitMask = enemyLaserCategory
            player.shieldUp = true
            player.shieldNode.isHidden = false
            shieldCount = 0
        } else if player.shieldBroken {
            if !player.shieldNode.hasActions() {
                let FadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.3)
                let FadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
                
                let Flicker = SKAction.sequence([FadeOut, FadeIn])
                
                player.shieldNode.run(SKAction.repeatForever(Flicker))
                player.shieldNode.isHidden = false
                player.shieldNode.physicsBody?.contactTestBitMask = 0
                player.physicsBody?.contactTestBitMask = enemyLaserCategory
                shieldCount = 0
            }
        }
    }
    
    
    func addControlPad(){
        let rightControlNode = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.frame.size.width/2, height: self.frame.size.width*1.5))
        rightControlNode.name = "rightControl"
        rightControlNode.position = CGPoint(x: self.frame.size.width/2 + rightControlNode.frame.size.width/2, y: rightControlNode.frame.size.height/2)
        rightControlNode.zPosition = 10
        rightControlNode.alpha = 0.01
        
        
        let leftControlNode = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.frame.size.width/2, height: self.frame.size.width*1.5))
        leftControlNode.name = "leftControl"
        leftControlNode.position = CGPoint(x: self.frame.size.width/2 - leftControlNode.frame.size.width/2, y: leftControlNode.frame.size.height/2)
        leftControlNode.zPosition = 10
        leftControlNode.alpha = 0.01
        
        addChild(rightControlNode)
        addChild(leftControlNode)
    }
    
    override func didMove(to view: SKView) {
        print("Move to game scene, begin making scene")
        
        addScoreBoard()
        addPlayerLivesBoard()
        addControlPad()
        addPauseButton()
 
        // These are for accelerometer movement.
//        if (motionManager.isAccelerometerAvailable) {
//            motionManager.startAccelerometerUpdates()
//        }
        
        
        self.backgroundColor = UIColor.black
        player.setScale(0.5)
        player.zPosition = 2
        player.position = CGPoint(x: self.frame.size.width * 0.5, y: player.size.height * 1.5)
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = enemyLaserCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.mass = 0.02
        
        addPlayerItems()
        
        let playerShield = SKSpriteNode(imageNamed: "shield2")

        playerShield.zPosition = 0
        playerShield.physicsBody = SKPhysicsBody(circleOfRadius: playerShield.size.height/2)
        playerShield.physicsBody?.categoryBitMask = playerShieldCategory
        playerShield.physicsBody?.contactTestBitMask = enemyLaserCategory
        playerShield.physicsBody?.collisionBitMask = 0
        playerShield.physicsBody?.linearDamping = 0
        playerShield.physicsBody?.mass = 0.02
        
        player.addChild(playerShield)
        player.shieldNode = playerShield
    
        touchLocationX = player.position.x
        
        let roof = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.size.width, height: 2.0))
        roof.position = CGPoint(x: self.frame.size.width/2,  y:self.frame.size.height + roof.size.height)
        roof.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:roof.size.width, height: roof.size.height))
        roof.physicsBody?.isDynamic = false
        roof.physicsBody?.categoryBitMask = roofCategory
        roof.physicsBody?.contactTestBitMask = playerLaserCategory + enemyShipCategory
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
        let generatePawns = SKAction.sequence([SKAction.run({self.addShip(type: "Pawn")}),SKAction.wait(forDuration: generatePawnsInterval)]) // 1.0s mid
        let generateKnights = SKAction.sequence([SKAction.run({self.addShip(type: "Knight")}),SKAction.wait(forDuration: generateKnightsInterval)])
        let generateBishops = SKAction.sequence([SKAction.run({self.addShip(type: "Bishop")}),SKAction.wait(forDuration: generateBishopsInterval)])
        let generateRooks = SKAction.sequence([SKAction.run({self.addShip(type: "Rook")}),SKAction.wait(forDuration: generateRooksInterval)])
        let generateQueens = SKAction.sequence([SKAction.run({self.addShip(type: "Queen")}),SKAction.wait(forDuration: generateQueensInterval)])
        let generateKings = SKAction.sequence([SKAction.run({self.addShip(type: "King")}),SKAction.wait(forDuration: generateKingsInterval)])
        
        let generatePlayerLaser = SKAction.sequence([SKAction.run(addPlayerLaser), SKAction.wait(forDuration: 0.3)]) // 0.2s mid
        // Generate shield every 6s after shield is gone
        let generateShield = SKAction.sequence([SKAction.run(resetShield), SKAction.wait(forDuration: 0.5)])
        
        // Generating random timing, environment objects
        let generateSmallStar = SKAction.sequence([SKAction.run(addSmallStar),SKAction.wait(forDuration: TimeInterval(random(mid: 0.3, range: 0.1)))]) // 0.3s mid
        let generateBigStar = SKAction.sequence([SKAction.run(addBigStar),SKAction.wait(forDuration: TimeInterval(random(mid: 0.7, range: 0.2)))]) // 0.7s mid
        let generateNebula = SKAction.sequence([SKAction.run(addNebula), SKAction.wait(forDuration: TimeInterval(random(mid: 6.0, range: 2.0)))]) // 6.0s mid
        
        
        run(SKAction.repeatForever(generateSmallStar))
        run(SKAction.repeatForever(generateBigStar))
        run(SKAction.repeatForever(generatePlayerLaser))
        run(SKAction.repeatForever(generateNebula))
        run(SKAction.repeatForever(generateShield))
        
        // Wait 3s before deploying enemies
        let when = DispatchTime.now() + 5
        // Generate troops in sequence, Pawns -> Bishops -> Knights
        // Rooks generate during other troops deployments
        DispatchQueue.main.asyncAfter(deadline: when) {
            //var actionArray : [SKAction] = []
            let deployPawns : SKAction = SKAction.repeat(generatePawns, count: self.totalPawnsCount)
            let deployBishops : SKAction = SKAction.repeat(generateBishops, count: self.totalBishopsCount)
            let deployKnights : SKAction = SKAction.repeat(generateKnights, count: self.totalKnightsCount)
            let deployRooks : SKAction = SKAction.repeat(generateRooks, count: self.totalRooksCount)
            let deployQueens : SKAction = SKAction.repeat(generateQueens, count: self.totalQueensCount)
            let deployKings : SKAction = SKAction.repeat(generateKings, count: self.totalKingsCount)
            
            if self.totalPawnsCount > 0 {
                self.run(deployPawns)
            }
            if self.totalBishopsCount > 0 {
                self.run(deployBishops)
            }
            if self.totalKnightsCount > 0 {
                self.run(deployKnights)
            }
            if self.totalRooksCount > 0 {
                self.run(deployRooks)
            }
            if self.totalQueensCount > 0 {
                self.run(deployQueens)
            }
            if self.totalKingsCount > 0 {
                self.run(deployKings)
            }
        }
    }
}
