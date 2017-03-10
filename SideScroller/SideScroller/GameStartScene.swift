//
//  GameStartScene.swift
//  SideScroller
//
//  Created by Abhineet Sharma on 3/8/17.
//  Copyright © 2017 Abhineet Sharma. All rights reserved.
//

import SpriteKit

class GameStartScene :SKScene{
    override init(size : CGSize){
        super.init(size: size)
        
        self.backgroundColor = .white
        
        let label = SKLabelNode(fontNamed : "Cochin")
        label.text = "Game Over"
        label.fontSize = 40
        label.fontColor = .black
        label.position = CGPoint(x: self.size.width/2, y:self.size.height/2)
        self.addChild(label)
        
        let replyButton = SKLabelNode(fontNamed : "Cochin")
        replyButton.text =  "Play Again"
        replyButton.fontColor = .black
        replyButton.position = CGPoint(x:self.size.width/2,y:50)
        replyButton.name = "replay"
        self.addChild(replyButton)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let location = touch.location(in: self)
            let node = self.nodes(at: location).first
            if node?.name == "replay"{
                let reveal: SKTransition = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.view!.bounds.size)
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene,transition :reveal)
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
