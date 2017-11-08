//
//  LevelPickerScene.swift
//  spaceGame
//
//  Created by James Tran on 10/19/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class LevelPickerScene: SKScene {
    var levelNodeList : [SKSpriteNode] = []
    let backButton = SKLabelNode(text: "Back")
    var levelUnlocked : Int = 0
    let defaults:UserDefaults = UserDefaults.standard
    
    override func sceneDidLoad() {
        if defaults.object(forKey: "LevelUnlocked") == nil {
            defaults.set(0, forKey: "LevelUnlocked")
        } else {
            levelUnlocked = defaults.integer(forKey: "LevelUnlocked")
        }
    }
    
    func addLevelNodes(nodeList: [SKSpriteNode]) {
        let totalWidth = UIScreen.main.bounds.width
        let width = totalWidth / 5
        let thirdTotalWidth = totalWidth / 3
        var posArray : [CGPoint] = []
        for i in 0...2 {
            for j in 0...2 {
                let newPos : CGPoint = CGPoint(x: thirdTotalWidth*CGFloat(j) + thirdTotalWidth/2, y: thirdTotalWidth*CGFloat(2-i) + thirdTotalWidth/2 + 100)
                posArray.append(newPos)
            }
        }
        for node in nodeList {
            node.size.width = width
            node.size.height = width
            
            node.position = posArray[nodeList.index(of: node) ?? 0]
            addChild(node)
        }
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        
        let levelPickerLabel : SKLabelNode = SKLabelNode(text: "Pick a level")
        levelPickerLabel.fontSize = 30
        levelPickerLabel.fontName = "AvenirNext-Medium"
        levelPickerLabel.zPosition = 10
        levelPickerLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - levelPickerLabel.frame.size.height*5)
        addChild(levelPickerLabel)
        
        backButton.fontSize = 25
        backButton.fontName = "AvenirNext-Medium"
        backButton.zPosition = 10
        backButton.position = CGPoint(x: backButton.frame.size.width, y: self.frame.size.height - backButton.frame.size.height*2)
        addChild(backButton)
        
        let totalWidth = UIScreen.main.bounds.width
        let width = totalWidth / 5
        
        for i in 1...9 {
            let newSprite : SKSpriteNode = SKSpriteNode()
            let newLabel : SKLabelNode = SKLabelNode(text: String(format: "Level %i", i))
            newLabel.fontColor = .white
            newLabel.horizontalAlignmentMode = .center
            newLabel.verticalAlignmentMode = .center
            newLabel.fontSize = 20
            newLabel.zPosition = 1
            newLabel.fontName = "AvenirNext-Medium"
            newLabel.position = CGPoint(x: newLabel.position.x, y: newLabel.position.y - width/2 - 10)
            newSprite.addChild(newLabel)
            newSprite.texture = SKTexture(imageNamed: "Planet" + String(i))
            
            if i > self.levelUnlocked + 1 {
                newSprite.alpha = 0.5
                newLabel.alpha = 0.5
            }
            
            levelNodeList.append(newSprite)
        }
        addLevelNodes(nodeList: levelNodeList)
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        if backButton.contains(touchLocation) {
            let reveal = SKTransition.reveal(with: .up, duration: 0.5)
            let mainMenu = MainMenuScene(size: self.size)
            
            self.view?.presentScene(mainMenu, transition: reveal)
        }
        
        for i in 0...(levelNodeList.count-1) {
            if levelNodeList[i].contains(touchLocation) {
                if i < self.levelUnlocked + 1 {
                    let reveal = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
                    let levelViewScene = LevelViewScene(size: self.size)
                    levelViewScene.level = i
                    
                    self.view?.presentScene(levelViewScene, transition: reveal)
                } else {
                    let lockedLabel = SKLabelNode(text: "This level is currently locked!")
                    lockedLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
                    lockedLabel.fontSize = 14
                    lockedLabel.fontName = "AvenirNext-Medium"
                    lockedLabel.zPosition = 10
                    
                    lockedLabel.alpha = 0
                    let fadeIn = SKAction.fadeIn(withDuration: 0.5)
                    let fadeOut = SKAction.fadeOut(withDuration: 2)
                    let remove = SKAction.removeFromParent()
                    
                    self.addChild(lockedLabel)
                    lockedLabel.run(SKAction.sequence([fadeIn, fadeOut, remove]))
                }
            }
        }
    }
}
