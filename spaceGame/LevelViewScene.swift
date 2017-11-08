//
//  LevelViewScene.swift
//  spaceGame
//
//  Created by James Tran on 10/26/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class LevelViewScene: SKScene {
    var level : Int = 0
    
    let startButton = SKLabelNode(text: "Start Mission")
    let backButton = SKLabelNode(text: "Back")
    
    func addTitleLabel(name: String) {
        let planetLabel : SKLabelNode = SKLabelNode(text: name)
        planetLabel.fontSize = 34
        planetLabel.fontColor = .white
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        planetLabel.position = CGPoint(x: width/2, y: height - planetLabel.frame.size.height - 90)
        planetLabel.fontName = "AvenirNext-Medium"
        
        self.addChild(planetLabel)
    }
    
    func addInfo(atSlot slot: Int, for unit: String){
        var spriteNode : SKSpriteNode = SKSpriteNode()
        let labelNode : SKLabelNode = SKLabelNode(text: "")
        let infoNode : SKLabelNode = SKLabelNode(text: "")
        var position : CGPoint = CGPoint()
        switch slot {
        case 0:
            position = CGPoint(x: 0, y: UIScreen.main.bounds.height - 200)
        case 1:
            position = CGPoint(x: 0, y: UIScreen.main.bounds.height - 300)
        case 2:
            position = CGPoint(x: 0, y: UIScreen.main.bounds.height - 400)
        case 3:
            position = CGPoint(x: 0, y: UIScreen.main.bounds.height - 500)
        default:
            break
        }
        
        switch unit {
        case "Pawn":
            spriteNode = SKSpriteNode(imageNamed: "redPawn")
            labelNode.text = "Pawn"
            infoNode.text = "Pawns are very fragile, armed with standard laser."
            spriteNode.setScale(0.5)
            
        case "Knight":
            spriteNode = SKSpriteNode(imageNamed: "redKnight")
            labelNode.text = "Knight"
            infoNode.text = "Knights attack quickly and move fast."
            spriteNode.setScale(0.5)
            
        case "Bishop":
            spriteNode = SKSpriteNode(imageNamed: "redBishop")
            labelNode.text = "Bishop"
            infoNode.text = "Bishops piercing laser goes through shield."
            spriteNode.setScale(0.5)
            
        case "Rook":
            spriteNode = SKSpriteNode(imageNamed: "redRook")
            labelNode.text = "Rook"
            infoNode.text = "Rooks gattling gun cannot damage shield."
            spriteNode.setScale(0.5)
            
        case "Queen":
            spriteNode = SKSpriteNode(imageNamed: "redQueen")
            labelNode.text = "Queen"
            infoNode.text = "Queens' plasma weapon evaporates anything."
            spriteNode.setScale(0.4)
            
        case "King":
            spriteNode = SKSpriteNode(imageNamed: "redKing")
            labelNode.text = "King"
            infoNode.text = "Kings can call his army to battle."
            spriteNode.setScale(0.5)
            
        default:
            break
        }
        
        
        let spriteNodeXPosition = position.x + 45
        spriteNode.position = CGPoint(x: spriteNodeXPosition, y: position.y)
        
        labelNode.fontSize = 20
        labelNode.horizontalAlignmentMode = .left
        labelNode.fontName = "AvenirNext-Medium"
        let labelNodeXPosition = position.x + 90
        labelNode.position = CGPoint(x: labelNodeXPosition, y: position.y + 8)
        
        
        infoNode.fontSize = 12
        infoNode.horizontalAlignmentMode = .left
        infoNode.fontName = "AvenirNextCondensed-Medium"
        let infoNodeXPosition = labelNodeXPosition
        infoNode.position = CGPoint(x: infoNodeXPosition, y: position.y - 15)
        
        addChild(spriteNode)
        addChild(labelNode)
        addChild(infoNode)
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.backgroundColor = .black
        startButton.fontSize = 40
        startButton.fontName = "AvenirNextCondensed-Medium"
        startButton.position = CGPoint(x: self.frame.size.width/2, y: 50)
        startButton.fontColor = UIColor.white
        addChild(startButton)
        
        backButton.fontSize = 25
        backButton.fontName = "AvenirNext-Medium"
        backButton.zPosition = 10
        backButton.position = CGPoint(x: backButton.frame.size.width, y: self.frame.size.height - backButton.frame.size.height*2)
        addChild(backButton)
        
        // Customize level name and enemy type display
        addTitleLabel(name: "Enemies info")
        switch level {
        case 0:
            addInfo(atSlot: 0, for: "Pawn")
        case 1:
            addInfo(atSlot: 0, for: "Bishop")
        case 2:
            addInfo(atSlot: 0, for: "Knight")
        case 3:
            addInfo(atSlot: 0, for: "Pawn")
            addInfo(atSlot: 1, for: "Bishop")
        case 4:
            addInfo(atSlot: 0, for: "Pawn")
            addInfo(atSlot: 1, for: "Knight")
        case 5:
            addInfo(atSlot: 0, for: "Bishop")
            addInfo(atSlot: 1, for: "Knight")
        case 6:
            addInfo(atSlot: 0, for: "Pawn")
            addInfo(atSlot: 1, for: "Rook")
        case 7:
            addInfo(atSlot: 0, for: "Pawn")
            addInfo(atSlot: 1, for: "Queen")
        case 8:
            addInfo(atSlot: 0, for: "Queen")
            addInfo(atSlot: 1, for: "King")
        default:
            break
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        if backButton.contains(touchLocation) {
            let reveal = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let levelPicker = LevelPickerScene(size: self.size)
            
            self.view?.presentScene(levelPicker, transition: reveal)
        }
        
        if startButton.contains(touchLocation) {
            let reveal = SKTransition.doorsOpenVertical(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            
            // Customize level enemies count and intervals
            switch level {
            case 0:
                gameScene.totalPawnsCount = 40
                gameScene.generatePawnsInterval = 1.0
            case 1:
                gameScene.totalBishopsCount = 20
                gameScene.generateBishopsInterval = 4.5
            case 2:
                gameScene.totalKnightsCount = 20
                gameScene.generateKnightsInterval = 3.0
            case 3:
                gameScene.totalPawnsCount = 48
                gameScene.generatePawnsInterval = 2.5
                
                gameScene.totalBishopsCount = 15
                gameScene.generateBishopsInterval = 8.0
            case 4:
                gameScene.totalPawnsCount = 55
                gameScene.generatePawnsInterval = 3.0
                
                gameScene.totalKnightsCount = 30
                gameScene.generateKnightsInterval = 5.5
            case 5:
                gameScene.totalKnightsCount = 30
                gameScene.generateKnightsInterval = 6.0
                
                gameScene.totalBishopsCount = 20
                gameScene.generateBishopsInterval = 9.0
            case 6:
                gameScene.totalPawnsCount = 40
                gameScene.generatePawnsInterval = 2.5

                gameScene.totalRooksCount = 10
                gameScene.generateRooksInterval = 10.0
            case 7:
                // Level 8 features the boss, Queen of the Chess Army
                // totalQueensCount is 1, though Queen spawns in pairs.
                gameScene.totalPawnsCount = 60
                gameScene.generatePawnsInterval = 3
                
                gameScene.totalQueensCount = 2
                gameScene.generateQueensInterval = 4
            case 8:
                // The final level boss, the King of the Chess Army
                gameScene.totalQueensCount = 2
                gameScene.generateQueensInterval = 4
                
                gameScene.totalKingsCount = 1
                gameScene.generateKingsInterval = 0
            default:
                break
            }
            gameScene.levelID = level
            
            self.view?.presentScene(gameScene, transition: reveal)
        }
    }
}
