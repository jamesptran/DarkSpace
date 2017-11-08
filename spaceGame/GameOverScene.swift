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
    var totalPawns : Int = 0
    var totalKnights : Int = 0
    var totalBishops : Int = 0
    var totalRooks : Int = 0
    var totalQueens : Int = 0
    var totalKings : Int = 0
    
    let scoreLabel = SKLabelNode(text: "Score: 0")
    let restartButton = SKLabelNode(text: "Restart")
    let menuButton = SKLabelNode(text: "Menu")
    let infoLabelTop = SKLabelNode(text: "")
    let infoLabelBottom = SKLabelNode(text: "")
    
    var killedBy : LaserType = .normal
    var isDestroyed : Bool = false
    var levelID : Int = -1
    let defaults:UserDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        print("Move to game over scene")
        self.backgroundColor = UIColor.black
        let maxScore = totalPawns + totalKnights * 3 + totalBishops * 3 + totalRooks * 5 + totalQueens * 9 + totalKings * 100
        print(score)
        print(maxScore)
        
        let percentCompletion = Int(Float(score) / Float(maxScore) * 100.0)
        let scoreString = String(format: "Score: %i%% destruction", percentCompletion)
        
        scoreLabel.text = scoreString
        
        infoLabelBottom.fontSize = 40
        infoLabelBottom.fontName = "AvenirNext-Medium"
        infoLabelBottom.fontColor = UIColor.white
        
        infoLabelTop.fontSize = 50
        infoLabelTop.fontName = "AvenirNext-Medium"
        infoLabelTop.fontColor = UIColor.white
        
        if isDestroyed {
            switch killedBy {
            case .normal:
                infoLabelTop.text = "Destroyed by MK I"
                infoLabelBottom.text = "Mark Is are average in all aspects"
            case .fast:
                infoLabelTop.text = "Destroyed by MK II"
                infoLabelBottom.text = "Mark IIs are fast with high fire rate"
            case .piercing:
                infoLabelTop.text = "Destroyed by Type P"
                infoLabelBottom.text = "Type Ps pierce through shield easily"
            case .gattling:
                infoLabelTop.text = "Destroyed by Type G"
                infoLabelBottom.text = "Type Gs are fast but cannot pierce shield"
            case .plasma:
                infoLabelTop.text = "Destroyed by Type O"
                infoLabelBottom.text = "Don't ever get hit by Type O"
            }
        } else if percentCompletion < 70 {
            infoLabelTop.text = "Mission failed"
            infoLabelBottom.text = "Too many of them escaped..."
        } else if percentCompletion < 90 {
            infoLabelTop.text = "Mission success"
            infoLabelBottom.text = "You destroyed the majority of them."
            
            let levelUnlocked = defaults.integer(forKey: "LevelUnlocked")
            if levelUnlocked == levelID {
                defaults.set(levelID + 1, forKey: "LevelUnlocked")
            }
            
        } else {
            infoLabelTop.text = "Almost perfect"
            if percentCompletion == 100 {
                infoLabelTop.text = "Perfect!"
            }
            infoLabelBottom.text = "They don't stand a chance."
            
            let levelUnlocked = defaults.integer(forKey: "LevelUnlocked")
            if levelUnlocked == levelID {
                defaults.set(levelID + 1, forKey: "LevelUnlocked")
            }
        }

        
        scoreLabel.fontSize = 40
        scoreLabel.fontName = "AvenirNext-Medium"
        scoreLabel.fontColor = UIColor.white

        
        restartButton.fontSize = 30
        restartButton.fontName = "AvenirNext-Medium"
        restartButton.fontColor = UIColor.white
        
        
        menuButton.fontSize = 30
        menuButton.fontName = "AvenirNext-Medium"
        menuButton.fontColor = UIColor.white
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            infoLabelTop.fontSize = 20
            infoLabelBottom.fontSize = 15
            scoreLabel.fontSize = 15
            restartButton.fontSize = 25
            menuButton.fontSize = 25
        }
        
        
        
        infoLabelBottom.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 + infoLabelBottom.frame.size.height)
            
        infoLabelTop.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 + infoLabelBottom.frame.size.height + infoLabelTop.frame.size.height)
        
        scoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - scoreLabel.frame.size.height)
        
        restartButton.position = CGPoint(x: self.frame.size.width/2, y: scoreLabel.position.y - scoreLabel.frame.size.height/2 - restartButton.frame.size.height)
        
        menuButton.position = CGPoint(x: menuButton.frame.size.width, y: self.frame.size.height - menuButton.frame.size.height * 2)
        

        addChild(infoLabelTop)
        addChild(infoLabelBottom)
        addChild(scoreLabel)
        addChild(restartButton)
        addChild(menuButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        if restartButton.contains(touchLocation) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = GameScene(size: self.size)

            scene.totalPawnsCount = self.totalPawns
            scene.totalBishopsCount = self.totalBishops
            scene.totalKnightsCount = self.totalKnights
            scene.totalRooksCount = self.totalRooks
            scene.totalQueensCount = self.totalQueens
            scene.totalKingsCount = self.totalKings
            
            self.view?.presentScene(scene, transition: reveal)
        }
        if menuButton.contains(touchLocation) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = MainMenuScene(size: self.size)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
}
