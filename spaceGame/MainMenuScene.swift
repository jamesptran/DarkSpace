//
//  MenuScene.swift
//  spaceGame
//
//  Created by James Tran on 2/27/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

//
//  GameOverUI.swift
//  spaceGame
//
//  Created by James Tran on 2/25/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class MainMenuScene: SKScene {
    let startButton = SKLabelNode(text: "Start")
    let optionButton = SKLabelNode(text: "Option")
    
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
    
    
    func addSmallStar(){
        var smallStar = SKSpriteNode()
        let starNum = random(min: 0, max: 4)
        if (starNum <= 2.5){
            smallStar = SKSpriteNode(imageNamed: "starBig1")
        } else {
            smallStar = SKSpriteNode(imageNamed: "starBig2")
        }
        smallStar.setScale(0.25)
        let speed = 100
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
        let speed = 150
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
    
    func addControlPad(){
        let rightControlNode = SKSpriteNode(color: UIColor.white, size: CGSize(width: self.frame.size.width/2.1, height: self.self.frame.size.width/2.1))
        rightControlNode.name = "rightControl"
        rightControlNode.position = CGPoint(x: self.frame.size.width/4, y: rightControlNode.frame.size.height/2)
        rightControlNode.zPosition = 10
        rightControlNode.alpha = 0.1
        
        
        let leftControlNode = SKSpriteNode(color: UIColor.white, size: CGSize(width: self.frame.size.width/2.1, height: self.frame.size.width/2.1))
        leftControlNode.name = "leftControl"
        leftControlNode.position = CGPoint(x: self.frame.size.width*3/4, y: leftControlNode.frame.size.height/2)
        leftControlNode.zPosition = 10
        leftControlNode.alpha = 0.1
        
        addChild(rightControlNode)
        addChild(leftControlNode)
        
        let rightControlLabel = SKLabelNode(text: "Touch here to go right")
        rightControlLabel.fontSize = 30
        rightControlLabel.position = rightControlNode.position
        
        let leftControlLabel = SKLabelNode(text: "Touch here to go left")
        leftControlLabel.fontSize = 30
        leftControlLabel.position = leftControlNode.position
        
        addChild(rightControlLabel)
        addChild(leftControlLabel)
    }
    
    
    
    override func didMove(to view: SKView) {
        addControlPad()
        
        self.backgroundColor = UIColor.black
        startButton.fontSize = 70
        startButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        startButton.fontColor = UIColor.white
        startButton.zPosition = 1
        addChild(startButton)
        
        /*optionButton.fontSize = 40
        optionButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - startButton.frame.size.height)
        optionButton.fontColor = UIColor.white
        optionButton.zPosition = 1
        addChild(optionButton)*/
        
        
        
        // Generating random timing, environment objects
        let generateSmallStar = SKAction.sequence([SKAction.run(addSmallStar),SKAction.wait(forDuration: TimeInterval(random(mid: 0.2, range: 0.1)))]) // 0.3s mid
        let generateBigStar = SKAction.sequence([SKAction.run(addBigStar),SKAction.wait(forDuration: TimeInterval(random(mid: 0.5, range: 0.2)))]) // 0.7s mid
        
        run(SKAction.repeatForever(generateSmallStar))
        run(SKAction.repeatForever(generateBigStar))
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        if startButton.contains(touchLocation) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: reveal)
        }
        
    }
}
