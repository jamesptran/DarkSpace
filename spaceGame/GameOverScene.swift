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


class GameOverScene: SKScene {
    var score : Int = 0
    
    let gameOverLabel = SKLabelNode(text: "Game Over")
    let scoreLabel = SKLabelNode(text: "Score: 0")
    let restartButton = SKLabelNode(text: "Restart")
    
    override func didMove(to view: SKView) {
        print("Move to game over scene")
        self.backgroundColor = UIColor.black        
        let scoreString = "Score: " + String(score)
        scoreLabel.text = scoreString
        
        gameOverLabel.fontSize = 100
        scoreLabel.fontSize = 40
        
        gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        scoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - gameOverLabel.frame.size.height/2 - scoreLabel.frame.size.height)
        
        gameOverLabel.fontColor = UIColor.white
        scoreLabel.fontColor = UIColor.white
        
        restartButton.fontSize = 30
        restartButton.position = CGPoint(x: self.frame.size.width/2, y: scoreLabel.position.y - scoreLabel.frame.size.height/2 - restartButton.frame.size.height)
        restartButton.fontColor = UIColor.white
        
        
        addChild(gameOverLabel)
        addChild(scoreLabel)
        addChild(restartButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        if restartButton.contains(touchLocation) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: reveal)
        }
    }
}
