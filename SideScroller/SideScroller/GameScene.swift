//
//  GameScene.swift
//  SideScroller
//
//  Created by Abhineet Sharma on 3/6/17.
//  Copyright © 2017 Abhineet Sharma. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var ship :SKSpriteNode = SKSpriteNode()
    var shipMoveUp:SKAction = SKAction()
    var shipMoveDown : SKAction = SKAction()
    
    
    let backgroundVelocity :CGFloat = 3.0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .white
        self.addBackGround()
        self.addShip()
        self.addBomb()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        
    }

    
    func addShip(){
        ship = SKSpriteNode(imageNamed: "Spaceship")
        ship.setScale(0.25)
        ship.zRotation = CGFloat(-M_PI/2)
        ship.physicsBody = SKPhysicsBody(rectangleOf: ship.size)
        ship.physicsBody?.isDynamic = true
        ship.name = "ship"
        ship.position = CGPoint(x: 120, y: 160)
        
        shipMoveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.2)
        shipMoveDown = SKAction.moveBy(x: 0, y: -30, duration: 0.2)
        
        self.addChild(ship)
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
    
    func addBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.setScale(0.15)
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.isDynamic = true;
        bomb.name = "bomb"
        
        let random :CGFloat = CGFloat(arc4random_uniform(300))
        
        bomb.position = CGPoint(x: self.frame.size.width+20, y: random)
        
        self.addChild(bomb)
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

    override func update(_ currentTime: TimeInterval) {
        self.moveBackground()
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
