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

    var enemy :SKSpriteNode = SKSpriteNode()
    var ship :SKSpriteNode = SKSpriteNode()
    var slife : SKSpriteNode = SKSpriteNode()
    var lifeLabel : SKLabelNode = SKLabelNode()
    var scoreLabel : SKLabelNode = SKLabelNode()
    
    var shipMoveUp:SKAction = SKAction()
    var shipMoveDown : SKAction = SKAction()
    
    var lastBombAdded:TimeInterval = 0
    var fireRate:TimeInterval = 0.8
    var timeSinceFire:TimeInterval = 0
    var lastTime:TimeInterval = 0
    var lastItemAdded:TimeInterval = 0;
    var lastMissileFired : TimeInterval = 0
    var timeSinceEnemyFire: TimeInterval = 0
    var lastEnemyAdded: TimeInterval = 0
    var cTime : TimeInterval = 0
    
    
    
    var backgroundVelocity :CGFloat = 3.0
    var bombVelocity: CGFloat = 6.0
    var itemVelocity: CGFloat = 4.0
    let EnemyHover : CGFloat = 3.0
    
    let noCategory:UInt32 = 0
    let playerCategory : UInt32 = 0b1
    let itemCategory:UInt32 = 0b1 << 1
    let laserCategory : UInt32 = 0b1 << 2
    let bombCategory : UInt32 = 0b1 << 3
    let enemyCategory : UInt32 = 0b1 << 4
    
    var spawnLaserFlag:Bool = true
    var isEnemyAdded:Bool = false
    var GameLoadFlag:Bool = true
    var soundFlag : Bool = true
    var powerGiven:Bool = true
    
    var powerUp:Int = 0
    var score: Int = 0
    var enemyLife : Int = 20
   
    
    override func didMove(to view: SKView) {
        GameLoadFlag = true
        self.backgroundColor = .white
        self.addBackGround()
        self.addShip()
        self.addBomb()
        self.addItem()
        self.addScoreBoard()
        self.powerUp = 0
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        if soundFlag
        {
            let bg:SKAudioNode = SKAudioNode(fileNamed: "music.m4a")
            bg.autoplayLooped = true
            self.addChild(bg)
        }
        
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
    
    func power(num :Int){
        
        switch (num) {
        case 1:
            fireRate -= 0.2
            break
        case 2:
            powerUp = 1
            break
        case 3:
            var lifeLeft = ship.userData?["life"]! as! Int
            lifeLeft += 1
            ship.userData?.setValue(lifeLeft, forKey: "life")
            slife.removeFromParent()
            lifeLabel.removeFromParent()
            self.addShipLife()
            break
        case 4:
            fireRate = 0.8
            break
        case 5:
            self.enumerateChildNodes(withName: "bomb", using: {(node,stop)-> Void in
                if let item = node as? SKSpriteNode{
                    
                        item.removeFromParent()
                    
                }
            })
            self.enumerateChildNodes(withName: "missile", using: {(node,stop)-> Void in
                if let item = node as? SKSpriteNode{
                    
                    item.removeFromParent()
                    
                }
            })

            break
            
        default:
            spawnLaser(0)
            break;
        }
    
    }
    func updateScore(num : Int)
    {
    
    }
    
    
    //-----------------------------------------------ADDING ITEMS TO SCREEN -----------------------------------------------
    
    
    
    func addBackGround(){
        for index in 0..<2
        {
            let bg:SKSpriteNode = SKSpriteNode(imageNamed: "backgrd1")
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 0)
            bg.anchorPoint = CGPoint(x: 0, y: 0)
            bg.name = "background"
            
            self.addChild(bg);
        }
        
    }
    func addScoreBoard(){
        scoreLabel = SKLabelNode(fontNamed : "Cochin")
        //let lifeLeft:String = String(ship.userData?["life"]! as! Int)
        scoreLabel.text = "Score : " + String(score)
        scoreLabel.fontSize = 17
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 600 , y:self.size.height-30 )
        self.addChild(scoreLabel)
    }
    func addShipLife(){
        slife = SKSpriteNode(imageNamed: "Spaceship")
        slife.setScale(0.10)
        slife.zRotation = CGFloat(-M_PI/2)
        slife.position = CGPoint(x: 75, y: self.size.height-30)
        
        lifeLabel = SKLabelNode(fontNamed : "Cochin")
        let lifeLeft:String = String(ship.userData?["life"]! as! Int)
        lifeLabel.text = "x " + lifeLeft
        lifeLabel.fontSize = 17
        lifeLabel.fontColor = .white
        lifeLabel.position = CGPoint(x: slife.position.x + 40 , y:slife.position.y - 5 )
        self.addChild(lifeLabel)
        self.addChild(slife)
        
    }
    
    func addShip(){
        
        ship = SKSpriteNode(imageNamed: "Spaceship")
        ship.setScale(0.25)
        ship.zRotation = CGFloat(-M_PI/2)
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.isDynamic = true
        ship.name = "ship"
        ship.physicsBody?.categoryBitMask = UInt32(playerCategory)
        ship.physicsBody?.contactTestBitMask = bombCategory | itemCategory
        ship.physicsBody?.collisionBitMask = 0
        ship.position = CGPoint(x: 120, y: 160)
        
        shipMoveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.2)
        shipMoveDown = SKAction.moveBy(x: 0, y: -30, duration: 0.2)
        
        ship.userData = NSMutableDictionary()
        ship.userData?.setValue(3, forKey: "life")
        
        spawnLaserFlag = true
        self.addChild(ship)
        self.addShipLife()
        
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
    
    func addBomb() {
        let name:String = "enemyShip" + String(arc4random_uniform(2) + 1)
        let bomb = SKSpriteNode(imageNamed: name)
        print(name)
        bomb.setScale(0.2)
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
    
    func addMissile() {
        let missile = SKSpriteNode(imageNamed: "bomb")
        missile.setScale(0.15)
        //missile.zRotation = CGFloat(M_PI)
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.isDynamic = true;
        missile.name = "missile"
        missile.physicsBody?.categoryBitMask = UInt32(bombCategory)
        missile.physicsBody?.contactTestBitMask = UInt32(playerCategory)
        missile.physicsBody?.collisionBitMask = 0
        missile.physicsBody?.usesPreciseCollisionDetection = true
        
        // let random :CGFloat = CGFloat(arc4random_uniform(300))
        
        missile.position = enemy.position
        
        self.addChild(missile)
    }
    
    func addEnemy(){
        let name:String = "enemy" + String(Int(arc4random_uniform(3)) + 1)
        print(name)
        isEnemyAdded = true;
        enemy = SKSpriteNode(imageNamed: name )
        //enemy.setScale(0.2)
        enemy.size = CGSize(width: self.size.height/2, height: self.size.width/3)
        enemy.zRotation = CGFloat(M_PI/2)
        //let EnemyTexture = SKTexture(imageNamed: "Enemy")
        enemy.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        enemy.physicsBody?.isDynamic = true
        enemy.name = "Enemy"
        enemy.physicsBody?.categoryBitMask = UInt32(enemyCategory)
        enemy.physicsBody?.contactTestBitMask = UInt32(laserCategory)
        enemy.physicsBody?.collisionBitMask = 0
        enemy.position = CGPoint(x: self.size.width, y: self.size.height-100)
        
        enemy.userData = NSMutableDictionary()
        
        enemy.userData?.setValue(self.enemyLife , forKey: "life")
        
        let moveAction:SKAction = SKAction.moveBy(x: 0, y: -200, duration:2);
        moveAction.timingMode = .easeInEaseOut
        
        let reversedAction : SKAction = moveAction.reversed()
        
        let sequence : SKAction = SKAction.sequence([moveAction,reversedAction])
        
        let repeatAction : SKAction = SKAction.repeatForever(sequence)
        enemy.run(repeatAction, withKey: "EnemyMove")//set as a constant
        let moveActionIntoView : SKAction = SKAction.moveBy(x: -150, y: 0, duration:1);
        moveActionIntoView.timingMode = .easeInEaseOut
        enemy.run(moveActionIntoView);
        self.addChild(enemy)
        
    }
    
    //------------------------------------------MOVING ITEMS TO SCREEN -----------------------------------------------
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
    func moveMissile(){
        self.enumerateChildNodes(withName: "missile", using: {(node,stop)-> Void in
            if let bomb = node as? SKSpriteNode{
                bomb.position = CGPoint(x: bomb.position.x - self.bombVelocity, y: bomb.position.y)
                if bomb.position.x < 0{
                    bomb.removeFromParent()
                }
            }
        })
    }
    
    
    
    //-----------------------------------------------SCREEN TOUCHES-----------------------------------------------
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
    
    //------------------------------------------------PHYSICS CONTACT-----------------------------------------------

    func didBegin(_ contact: SKPhysicsContact) {
        var BodyA:SKPhysicsBody
        var BodyB:SKPhysicsBody
        
        self.enumerateChildNodes(withName: "exe", using: {(node,stop)-> Void in
            if let bg = node as? SKSpriteNode{
                bg.removeFromParent()
            }
        })
    
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            BodyA = contact.bodyA
            BodyB = contact.bodyB
        }
        else{
            BodyA = contact.bodyB
            BodyB = contact.bodyA
        }
        
        
        
        if BodyA.categoryBitMask & playerCategory != 0 && (BodyB.categoryBitMask & bombCategory != 0){//PLAYER VS ENEMY FIRE
            
            if soundFlag
            {
                self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
            }
            let explosion :SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
            explosion.position = contact.bodyA.node!.position
            explosion.name = "exe"
            self.addChild(explosion)

            spawnLaserFlag = false
            var lifeLeft = ship.userData?["life"]! as! Int
            print("ship life ",lifeLeft)
            
            
            if lifeLeft > 0
            {
                lifeLeft -= 1
                
                ship.userData?.setValue(lifeLeft, forKey: "life")
                slife.removeFromParent()
                lifeLabel.removeFromParent()
                BodyB.node?.removeFromParent()
                self.addShipLife()
                spawnLaserFlag = true
                self.powerUp = 4
                self.power(num: 4)
                
               
                
            }
            else
            {
                
                let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
               
                
                let explosion :SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
                explosion.position = contact.bodyA.node!.position
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                if soundFlag{
                    self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
                }
                self.addChild(explosion)
                
                DispatchQueue.main.asyncAfter(deadline: when) {
                    let gameOverScene = GameOverScene(size: self.size)
                    self.view?.presentScene(gameOverScene, transition : .doorway(withDuration: 1))
                }
            }
        }
        else if BodyA.categoryBitMask & laserCategory != 0 && (BodyB.categoryBitMask & bombCategory != 0){//PLAYER LASER VS ENEMY FIRE
        
            
            let explosion :SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
            explosion.name = "exe"
            if BodyB.node != nil
            {
                explosion.position = BodyB.node!.position
                self.addChild(explosion)
            }
            if soundFlag{
                self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
            }
            
            BodyA.node?.removeFromParent()
            BodyB.node?.removeFromParent()
            
            self.score += 5
            scoreLabel.text = "Score : " + String(score)

        
        }
        else if BodyA.categoryBitMask & playerCategory != 0 && (BodyB.categoryBitMask & itemCategory != 0 ) {//PLAYER LASER COLLECTING POWER UP
            BodyB.node?.removeFromParent()
            var num : Int = Int(arc4random_uniform(5))
            num += 1
            if powerGiven{
                print(num)
                self.power(num: num)
                self.powerGiven = false
            }
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
               self.powerGiven = true
            }
            
        }
        else if BodyA.categoryBitMask & laserCategory != 0 && (BodyB.categoryBitMask & enemyCategory != 0){//Enemy vs player
            var lifeLeft = enemy.userData?["life"]! as! Int
            print(lifeLeft)
            self.score += 10
            scoreLabel.text = "Score : " + String(score)
            if lifeLeft > 0
            {
                lifeLeft -= 1
            
                enemy.userData?.setValue(lifeLeft, forKey: "life")
                
                BodyA.node?.removeFromParent()
                
            }
            else
            {
                
                
                let explosion :SKEmitterNode = SKEmitterNode(fileNamed: "Explosion")!
                explosion.position = contact.bodyA.node!.position
                explosion.name = "exe"
                if soundFlag{
                    self.run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
                }
                self.addChild(explosion)
                contact.bodyA.node?.removeFromParent()
                
                contact.bodyB.node?.removeFromParent()
                
                let when = DispatchTime.now() + 4 // change 2 to desired number of seconds
                
                DispatchQueue.main.asyncAfter(deadline: when) {
                    
                    self.lastEnemyAdded = self.cTime
                    self.isEnemyAdded = false
                }
               
            }
            
            
            
            
            
        }

        
    }
    
    //--------------------------------------TIME INTERVAL INVENTS--------------------------------------------------------------
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        self.moveBackground()
        self.moveBomb()
        self.moveItem()
        self.moveMissile()
        cTime = currentTime
        
        if spawnLaserFlag{
            checkLaser(currentTime - lastTime)
            lastTime = currentTime
        }

        if(GameLoadFlag ){
            self.lastBombAdded = currentTime
            self.lastItemAdded = currentTime
            self.lastEnemyAdded  = currentTime
            GameLoadFlag = false
            
        }
        if currentTime - self.lastBombAdded > 0.5{
            self.lastBombAdded = currentTime + 1
            self.addBomb()
        }
        
        if currentTime - self.lastItemAdded > 8{
            self.lastItemAdded = currentTime + 1
            self.addItem()
        }
        
        if currentTime - self.lastEnemyAdded > 12 && !self.isEnemyAdded
        {
            self.isEnemyAdded = true
            self.lastEnemyAdded = currentTime + 1
            
            
            
            self.addEnemy()
            backgroundVelocity += 1.0
            bombVelocity += 1.0
            itemVelocity += 1.0
            self.enemyLife *= 2

        }
        if(self.isEnemyAdded){
            if currentTime - self.lastItemAdded > 1
            {
                self.lastItemAdded = currentTime + 1
                self.addMissile()
            }
        }
        
        
    }
    func checkLaser(_ frameRate:TimeInterval)
    {
        timeSinceFire += frameRate
        if timeSinceFire < fireRate {
            return
        }
        
        
        switch self.powerUp {
        case 1:
            spawnLaser(30)
            spawnLaser(-30)
            spawnLaser(0)
            break
            
        default:
            spawnLaser(0)
        }
        //spawnEnemyLaser()
        
        timeSinceFire = 0
    }
    
    
    
    func spawnLaser(_ pos:CGFloat){
        let scene:SKScene = SKScene(fileNamed: "laser")!
        let laser = scene.childNode(withName: "laser")!
        
        let ypos:CGFloat = ship.position.y+pos
        laser.position = CGPoint(x: ship.position.x, y: ypos)
        laser.move(toParent: self)
        
        laser.physicsBody?.categoryBitMask = laserCategory
        laser.physicsBody?.collisionBitMask = noCategory
        laser.physicsBody?.contactTestBitMask = bombCategory
        if soundFlag{
            self.run(SKAction.playSoundFileNamed("laser", waitForCompletion: false))
        }
        let waitAction = SKAction.wait(forDuration: 1.2)
        let removeAction = SKAction.removeFromParent()
        laser.run(SKAction.sequence([waitAction,removeAction]))
        
        
        
    }
    
    func spawnEnemyLaser(){
        let missile:SKSpriteNode = SKSpriteNode(imageNamed: "missile1")
        
        missile.setScale(0.1)
        missile.zRotation = CGFloat(-M_PI)
        
        missile.position = enemy.position
        
        missile.physicsBody?.categoryBitMask = laserCategory
        missile.physicsBody?.collisionBitMask = noCategory
        missile.physicsBody?.contactTestBitMask = playerCategory
        
        
        
        missile.physicsBody?.velocity = CGVector(dx: -100, dy: 0)
        let waitAction = SKAction.wait(forDuration: 6)
        let removeAction = SKAction.removeFromParent()
        missile.run(SKAction.sequence([waitAction,removeAction]))
        self.addChild(missile)
        
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
