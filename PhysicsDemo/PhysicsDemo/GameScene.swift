//
//  GameScene.swift
//  PhysicsDemo
//
//  Created by Hiroaki Komatsu on 2015/05/16.
//  Copyright (c) 2015年 Hiroaki Komatsu. All rights reserved.
//

import SpriteKit
import CoreMotion

struct Ball {
    var sprite: SKShapeNode!
    var interval: CFTimeInterval!
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var lastUpdateTime: CFTimeInterval!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // setup physics
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.categoryBitMask = 0x1 << 1
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.blackColor()
    }
    
    func onMotionUpdate(data: CMAccelerometerData!) {
        self.physicsWorld.gravity.dx = CGFloat(data.acceleration.x * 9.8)
        self.physicsWorld.gravity.dy = CGFloat(data.acceleration.y * 9.8)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            let r = CGFloat(arc4random() % 20 + 10)
            let color = UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
            let sprite = SKShapeNode(circleOfRadius: r)
            sprite.fillColor = color
            sprite.strokeColor = color
            sprite.lineWidth = 0.0
            sprite.position = location
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: r)
            
            // 密度（Kg/m2）
            let mass = sprite.physicsBody?.mass
            
            // エネルギーの設定
            sprite.userData = NSMutableDictionary()
            sprite.userData!.setObject(CGFloat(10000.0 * mass!), forKey: "energy")
            sprite.userData!.setObject(CFTimeInterval(0.1), forKey: "interval")
            
            // 跳ね返りの指定
            sprite.physicsBody!.friction = 0.5
            sprite.physicsBody!.restitution = 0.8
            
            // 衝突判定メソッド
            sprite.physicsBody!.categoryBitMask = 0x1 << 0
            sprite.physicsBody!.collisionBitMask = 0x1 << 0 | 0x1 << 1
            sprite.physicsBody!.contactTestBitMask = 0x1 << 1
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if lastUpdateTime == nil {
            lastUpdateTime = currentTime
        }
        let time = CFTimeInterval(currentTime - lastUpdateTime)
        lastUpdateTime = currentTime
        
        for child in children {
            let sprite = child 
            if sprite.userData?.objectForKey("energy") == nil {
                // 時間で消える
                let interval = sprite.userData?.objectForKey("interval") as! CFTimeInterval - time
                sprite.userData?["interval"] = interval
                if interval < 0 {
                    child.removeFromParent()
                }
            }
        }
    }
    
    // 衝突メソッド
    func didBeginContact(contact: SKPhysicsContact) {
        let sprite = contact.bodyB.node! as! SKShapeNode
        if sprite.userData?.objectForKey("energy") != nil {
            let energy = sprite.userData?.objectForKey("energy") as! CGFloat - contact.collisionImpulse
            sprite.userData?["energy"] = energy
            if energy < 0 {
                sprite.fillColor = UIColor.clearColor()
                sprite.lineWidth = 1.0
                sprite.userData!.removeObjectForKey("energy")
            }
        }
    }
}
