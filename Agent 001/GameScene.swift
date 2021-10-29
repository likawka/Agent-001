//
//  GameScene.swift
//  Agent 001
//
//  Created by Iryna Zinko on 10/28/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
        
    let player = SKSpriteNode(imageNamed: "playerCat")
    let bulletSound = SKAction.playSoundFileNamed("pewPoP.mp3", waitForCompletion: true)
    
    
    // не працює? 1*
    var gameArea: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = (16.0/9.0)
        let playebleWigth = (size.height / maxAspectRatio)
        let margin = ((size.width - playebleWigth) / 2)
        
        gameArea = CGRect(x: margin, y: 0, width:playebleWigth, height:size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  
    
    // розміщення бекграунда + гравець
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
    
    
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)
        
    }
    
    // розробка кігтиків і атаки + звук
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet,bulletSound, deleteBullet])
        
        bullet.run(bulletSequence)
        
    }
    
    func spawnEnemy() {
        
    }
    
    // стріляє, коли тикаєш
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    
    // заставляє кота ворушитись за пальцем
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            player.position.x += amountDragged
           
            
            // не працює? 1*
            if player.position.x > gameArea.maxX - player.size.width*1.5 {
                player.position.x = gameArea.maxX - player.size.width*1.5
                
            }
            if player.position.x < gameArea.minX + player.size.width*1.5{
                player.position.x = gameArea.minX + player.size.width*1.5
                
            }
                
        }
    }
    

}
