//
//  GameScene.swift
//  SideScroller
//
//  Created by Abhineet Sharma on 3/6/17.
//  Copyright © 2017 Abhineet Sharma. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene ,SKPhysicsContactDelegate{

    var ship :SKSpriteNode = SKSpriteNode()
    var shipMoveUp:SKAction = SKAction()
    var shipMoveDown : SKAction = SKAction()
    
    var lastBombAdded:TimeInterval = 0
    var fireRate:TimeInterval = 0.5
    var timeSinceFire:TimeInterval = 0
    var lastTime:TimeInterval = 0
    var lastItemAdded:TimeInterval = 0;
    
    
    let backgroundVelocity :CGFloat = 3.0
    let bombVelocity: CGFloat = 6.0
    let itemVelocity: CGFloat = 4.0
    
    let noCategory:UInt32 = 0
    let playerCategory : UInt32 = 0b1
    let itemCategory:UInt32 = 0b1 << 1
    let laserCategory : UInt32 = 0b1 << 2
    let bombCategory : UInt32 = 0b1 << 3
    
    var spawnLaserFlag:Bool = true;
    
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        self.addBackGround()
        self.addShip()
        self.addBomb()
        self.addItem()
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        do
        {
            let sounds:[String] = ["explosion","laser"]
            for sound in sounds{
                let path :String = Bundle.main.path(forResource: sound, ofType: "wav")!
                let url :URL = URL(fileURLWithPath: path)
                let player:AVAudioPlayer = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
            }
                    
        }
        catch{}

    }

    
    func addShip(){
        ship = SKSpriteNode(imageNamed: "Spaceship")
        ship.setScale(0.25)
        ship.zRotation = CGFloat(-M_PI/2)
        let shipTexture = SKTexture(imageNamed: "SpaceShip")
        ship.physicsBody = SKPhysicsBody(texture: shipTexture, size: ship.size)//SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.isDynamic = true
        ship.name = "ship"
        ship.physicsBody?.categoryBitMask = UInt32(playerCategory)
        ship.physicsBody?.contactTestBitMask = UInt32(bombCategory)
        ship.physicsBody?.collisionBitMask = 0
        ship.position = CGPoint(x: 120, y: 160)
        
        shipMoveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.2)
        shipMoveDown = SKAction.moveBy(x: 0, y: -30, duration: 0.2)
        
        
       // let bg:SKAudioNode = SKAudioNode(fileNamed: "music.m4a")
        //bg.autoplayLooped = true
       // self.addChild(bg)

        
        self.addChild(ship)
        
//       //
        
        
    }
    
    func addBackGround(){
        for index in 0..<2
        {
            let bg:SKSpriteNode = SKSpriteNode(imageNamed: "back")
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 0)
            bg.anchorPoint = CGPoint(x: 0, y: 0)
            bg.name = "background"
            
            self.addChild(bg);
        }
    
    }
    
    func moveBackground(){
        self.enumerateChildNodes(withName: "background", using: {(node,stop)-> Void in
            if let bg = node as? SKSpriteNode{
                bg.position = CGPoint(x: bg.position.x - self.backgroundVelocity, y :bg.position.y)
                
                if bg.position.x <= -bg.size.width{
                    bg.position = CGPoint(x:bg.position.x + bg.size.width * 2, y : bg.position.y)
                }
            }
        })
    }
    
    
    
    func addItem() {
        let item = SKSpriteNode(imageNamed: "item")
        //item.setScale(0.15)
       
        item.zRotation = CGFloat(M_PI/2)
        let shipTexture = SKTexture(imageNamed: "item")
        item.physicsBody = SKPhysicsBody(texture: shipTexture, size: item.size)
        //item.physicsBody = SKPhysicsBody(texture: <#T##SKTexture#>, size: <#T##CGSize#>)//SKPhysicsBody(rectangleOf: item.size)
        item.physicsBody?.isDynamic = true;
        item.name = "item"
        item.physicsBody?.categoryBitMask = itemCategory
        item.physicsBody?.contactTestBitMask = playerCategory
        item.physicsBody?.collisionBitMask = noCategory
        item.physicsBody?.usesPreciseCollisionDetection = true
        
        let random :CGFloat = CGFloat(arc4random_uniform(300))
        
        item.position = CGPoint(x: self.frame.size.width+20, y: random)
        
        self.addChild(item)
    }
    func moveItem(){
        self.enumerateChildNodes(withName: "item", using: {(node,stop)-> Void in
            if let item = node as? SKSpriteNode{
                item.position = CGPoint(x: item.position.x - self.itemVelocity, y: item.position.y)
                if item.position.x < 0{
                    item.removeFromParent()
                }
            }
        })
    }
    
    func addBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.setScale(0.15)
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.isDynamic = true;
        bomb.name = "bomb"
        bomb.physicsBody?.categoryBitMask = UInt32(bombCategory)
        bomb.physicsBody?.contactTestBitMask = UInt32(playerCategory)
        bomb.physicsBody?.collisionBitMask = 0
        bomb.physicsBody?.usesPreciseCollisionDetection = true
        
        let random :CGFloat = CGFloat(arc4random_uniform(300))
        
        bomb.position = CGPoint(x: self.frame.size.width+20, y: random)
        
        self.addChild(bomb)
    }
    func moveBomb(){
        self.enumerateChildNodes(withName: "bomb", using: {(node,stop)-> Void in
            if let bomb = node as? SKSpriteNode{
                bomb.position = CGPoint(x: bomb.position.x - self.bombVelocity, y: bomb.position.y)
                if bomb.position.x < 0{
                    bomb.removeFromParent()
                }
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if location.y > ship.position.y {
                if ship.position.y < 300 {
                    ship.run(shipMoveUp)
                }
            }else if ship.position.y > 50 {
                    ship.run(shipMoveDown)
                
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var BodyA:SKPhysicsBody
        var BodyB:SKPhysicsBody
    
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            BodyA = contact.bodyA
            BodyB = contact.bodyB
        }
        else{
            BodyA = contact.bodyB
            BodyB = contact.bodyA
        }
        
        
        
        if BodyA.categoryBitMask & playerCategory != 0 && (BodyB.categoryBitMask & bombCategory != 0){
            let explosion :SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
            
            
            explosion.position = contact.bodyA.node!.position
            
            self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
            self.addChild(explosion)
            spawnLaserFlag = false
            contact.bodyA.node?.removeFromParent()
            
            contact.bodyB.node?.removeFromParent()
            
            
            let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                let gameOverScene = GameOverScene(size: self.size)
                self.view?.presentScene(gameOverScene, transition : .doorway(withDuration: 1))
            }
            
            
           
        }
        else if BodyA.categoryBitMask & laserCategory != 0 && (BodyB.categoryBitMask & bombCategory != 0){
        
            let explosion :SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
            
            
            explosion.position = contact.bodyA.node!.position
            
            self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
            self.addChild(explosion)
            //spawnLaserFlag = false
            contact.bodyA.node?.removeFromParent()
            
            contact.bodyB.node?.removeFromParent()

        
        }
        else if BodyA.categoryBitMask & playerCategory != 0 && (BodyB.categoryBitMask & itemCategory != 0 ) {
            
           
            
            contact.bodyB.node?.removeFromParent()
        }

        
    }
    
    func checkLaser(_ frameRate:TimeInterval)
    {
        timeSinceFire += frameRate
        if timeSinceFire < fireRate {
            return
        }
        
        spawnLaser()
        
        timeSinceFire = 0
    }
    
    func spawnLaser()
    {
        let scene:SKScene = SKScene(fileNamed: "laser")!
        let laser = scene.childNode(withName: "laser")!
        
        laser.position = ship.position
        laser.move(toParent: self)
        
        laser.physicsBody?.categoryBitMask = laserCategory
        laser.physicsBody?.collisionBitMask = noCategory
        laser.physicsBody?.contactTestBitMask = bombCategory
        self.run(SKAction.playSoundFileNamed("laser", waitForCompletion: false))
        
        let waitAction = SKAction.wait(forDuration: 1.2)
        let removeAction = SKAction.removeFromParent()
        laser.run(SKAction.sequence([waitAction,removeAction]))
        
        
        
    }
    override func update(_ currentTime: TimeInterval) {
        self.moveBackground()
        self.moveBomb()
        self.moveItem()
        if spawnLaserFlag
        {
            checkLaser(currentTime - lastTime)
            lastTime = currentTime
        }

        if currentTime - self.lastBombAdded > 0.5{
            self.lastBombAdded = currentTime + 1
            self.addBomb()
        }
        
        if currentTime - self.lastItemAdded > 10{
            self.lastItemAdded = currentTime + 1
            self.addItem()
        }
        
        
    }
  
        
}
    /*
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}*/
