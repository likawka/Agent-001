//
//  GameScene.swift
//  Agent 001
//
//  Created by Iryna Zinko on 10/28/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
        
    let player = SKSpriteNode(imageNamed: "playerCat")
    let bulletSound = SKAction.playSoundFileNamed("pewPoP.mp3", waitForCompletion: true)
    
    
    struct PhysicsCategories{
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1 binary
        static let Bullet : UInt32 = 0b10 //2 binary
        static let Enemy : UInt32 = 0b100 //4 binary
    }
    
    
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    

    var gameArea: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = (19.0/15.0)
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
        
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
    
    
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        
        self.addChild(player)
        
        startNewLevel()
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // якщо гравець влупився лицем в ворога
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            
            spawnExplosion(spawnPosition: body1.node!.position)
            spawnExplosion(spawnPosition: body2.node!.position)
            
            if body1.node != nil{
                body1.node?.removeFromParent()
            }
            
            if body2.node != nil{
                body2.node?.removeFromParent()
            }
        
        
        // якщо у ворога попали кігтиками
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
//            && body2.node?.position.y < self.size.height (Part 3 25:00) - add next time
            
            spawnExplosion(spawnPosition: body2.node!.position)

            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
 
        }
    }
    }
    
    
    func spawnExplosion(spawnPosition: CGPoint ){
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        self.addChild(explosion)
        
    }
    
    
    func startNewLevel(){
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        
        self.run(spawnForever)
        
    }
    
    // розробка кігтиків і атаки + звук
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([moveBullet,bulletSound, deleteBullet])
        
        bullet.run(bulletSequence)
        
    }
    
    func spawnEnemy() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height*1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*1.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyVase")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy .size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        
        
        
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 10) // замінити на менше число!!
        
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amoundToRotate = atan2(dx, dy)
        
        enemy.zRotation = amoundToRotate
        
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
           
            if player.position.x > gameArea.maxX - player.size.width*1.5 {
                player.position.x = gameArea.maxX - player.size.width*1.5
                
            }
            if player.position.x < gameArea.minX + player.size.width*1.5{
                player.position.x = gameArea.minX + player.size.width*1.5
                
            }
                
        }
    }
    

}


