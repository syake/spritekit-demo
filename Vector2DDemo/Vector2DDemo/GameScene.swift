//
//  GameScene.swift
//  Vector2DDemo
//
//  Created by Hiroaki Komatsu on 2015/05/31.
//  Copyright (c) 2015年 Hiroaki Komatsu. All rights reserved.
//

import SpriteKit

enum GameStatus {
    case none
    case wait
    case drug
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let slideVectorName = "slide"
    let reflectVectorName = "reflect"
    
    private var sprite1: SKShapeNode!
    private var sprite2: SKShapeNode!
    private var drugLine: SKShapeNode!
    private var vectorLine: SKShapeNode!
    
    private var status: GameStatus! = GameStatus.none
    private var beganLocation: CGPoint!
    private var drugTarget: SKNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        createWall()
        
        sprite1 = SKShapeNode(circleOfRadius: 30.0)
        sprite1.fillColor = UIColor.whiteColor()
        sprite1.lineWidth = 0.0
        sprite1.name = slideVectorName
        sprite1.userData = NSMutableDictionary()
        sprite1.physicsBody = SKPhysicsBody(circleOfRadius: 30.0)
        sprite1.physicsBody!.affectedByGravity = false
        sprite1.physicsBody!.linearDamping = 0.0
        sprite1.physicsBody!.friction = 0.0
        sprite1.physicsBody!.restitution = 0.0
        sprite1.physicsBody!.usesPreciseCollisionDetection = true
        sprite1.physicsBody!.categoryBitMask = 0x1 << 1
        sprite1.physicsBody!.collisionBitMask = 0x1 << 0 | 0x1 << 1
        sprite1.physicsBody!.contactTestBitMask = 0x1 << 0 | 0x1 << 1
        self.addChild(sprite1)
        
        sprite2 = SKShapeNode(circleOfRadius: 30.0)
        sprite2.fillColor = UIColor.whiteColor()
        sprite2.lineWidth = 0.0
        sprite2.name = reflectVectorName
        sprite2.userData = NSMutableDictionary()
        sprite2.physicsBody = SKPhysicsBody(circleOfRadius: 30.0)
        sprite2.physicsBody!.affectedByGravity = false
        sprite2.physicsBody!.linearDamping = 0.0
        sprite2.physicsBody!.friction = 0.0
        sprite2.physicsBody!.restitution = 0.0
        sprite2.physicsBody!.usesPreciseCollisionDetection = true
        sprite2.physicsBody!.categoryBitMask = 0x1 << 1
        sprite2.physicsBody!.collisionBitMask = 0x1 << 0 | 0x1 << 1
        sprite2.physicsBody!.contactTestBitMask = 0x1 << 0 | 0x1 << 1
        self.addChild(sprite2)
        
        drugLine = SKShapeNode()
        drugLine.strokeColor = UIColor.greenColor()
        drugLine.lineWidth = 2.0
        self.addChild(drugLine)
        
        vectorLine = SKShapeNode()
        vectorLine.strokeColor = UIColor.orangeColor()
        vectorLine.lineWidth = 2.0
        self.addChild(vectorLine)
        
        self.backgroundColor = UIColor.blackColor()
        self.physicsWorld.contactDelegate = self
        
        reset()
    }
    
    // 壁を生成
    func createWall() {
        let width = self.size.width
        let width_2 = width / 2
        let heigth = self.size.height
        let height_2 = heigth / 2
        let height_3 = heigth / 3
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 10.0, 20.0)
        CGPathAddLineToPoint(path, nil, width_2, 50.0)
        CGPathAddLineToPoint(path, nil, width - 10.0, 20.0)
        CGPathAddLineToPoint(path, nil, width - 30.0, height_3)
        CGPathAddLineToPoint(path, nil, width - 10.0, height_2)
        CGPathAddLineToPoint(path, nil, width - 30.0, height_3 * 2)
        CGPathAddLineToPoint(path, nil, width - 10.0, heigth - 20.0)
        CGPathAddLineToPoint(path, nil, 10.0, heigth - 20.0)
        CGPathAddLineToPoint(path, nil, 30.0, height_3 * 2)
        CGPathAddLineToPoint(path, nil, 10.0, height_2)
        CGPathAddLineToPoint(path, nil, 30.0, height_3)
        CGPathCloseSubpath(path)
        
        let wall = SKShapeNode(path: path)
        wall.strokeColor = UIColor.whiteColor()
        wall.lineWidth = 5.0
        self.addChild(wall)
        
        wall.physicsBody = SKPhysicsBody(edgeLoopFromPath: path)
        wall.physicsBody!.affectedByGravity = false
        wall.physicsBody!.usesPreciseCollisionDetection = true
        wall.physicsBody!.categoryBitMask = 0x1 << 0
    }
    
    // リセット
    func reset() {
        let width_3 = self.size.width / 3
        let height_2 = self.size.height / 2
        
        sprite1.position = CGPoint(x: width_3, y: height_2)
        sprite2.position = CGPoint(x: width_3 * 2, y: height_2)
        
        status = GameStatus.wait
        
        vectorLine.path = nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if status != GameStatus.wait {
            return
        }
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            let node:SKNode! = self.nodeAtPoint(location)
            if node != nil {
                if node.name == slideVectorName || node.name == reflectVectorName {
                    beganLocation = location
                    drugTarget = node
                    drugTarget.removeAllActions()
                    status = GameStatus.drug
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if status != GameStatus.drug {
            return
        }
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            drugTarget.position = location
            
            // 進行ベクトルを描画
            let vector = CGVector(dx: beganLocation.x - location.x, dy: beganLocation.y - location.y)
            let path = getArrowPath(vector, location: location)
            drugLine.path = path
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if status != GameStatus.drug {
            return
        }
        
        status = GameStatus.wait
        drugLine.path = nil
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            
            // 進行ベクトルの登録
            let dx = beganLocation.x - location.x
            let dy = beganLocation.y - location.y
            let radian = atan2(dy, dx)
            let vector = CGVector(dx: CGFloat(cos(radian)) * 30.0, dy: CGFloat(sin(radian)) * 30.0)
            drugTarget.userData!.setObject([vector.dx, vector.dy], forKey: "vector")
            drugTarget.userData!.setObject(10, forKey: "energy")
            drugTarget = nil
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        for child in children {
            let sprite = child 
            if sprite.userData?["vector"] != nil {
                let vector_arr = sprite.userData?["vector"] as! Array<CGFloat>
                let vector = CGVector(dx: vector_arr[0], dy: vector_arr[1])
                let action = SKAction.moveBy(vector, duration: 0.1)
                action.timingMode = .EaseOut
                sprite.runAction(action)
            }
        }
    }
    
    // 衝突メソッド
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            _ = contact.bodyA.node! as SKNode
            let spriteB = contact.bodyB.node! as SKNode
            let normal = contact.contactNormal
            spriteB.removeAllActions()
            
            // 内側へちょっと戻す
            let restitution = CGVector(dx: normal.dx * 3, dy: normal.dy * 3)
            spriteB.runAction(SKAction.moveBy(restitution, duration: 0.0))
            
            if spriteB.userData?["vector"] != nil {
                let vector_arr = spriteB.userData?["vector"] as! Array<CGFloat>
                spriteB.userData!.removeObjectForKey("vector")
                let vector = CGVector(dx: vector_arr[0], dy: vector_arr[1])
                
                // 進行ベクトル（vectorP）を切り替える
                var vectorP: CGVector?
                if spriteB.name == slideVectorName {
                    vectorP = vector2DSlide(vector: vector, normal: normal)
                } else if spriteB.name == reflectVectorName {
                    vectorP = vector2DReflect(vector: vector, normal: normal)
                }
                
                if vectorP != nil {
                    // 進行ベクトルを登録
                    spriteB.userData!.setObject([vectorP!.dx, vectorP!.dy], forKey: "vector")
                    
                    // ベクトル方向の視覚化
                    let path = getArrowPath(vectorP!, location: CGPoint(x: self.view!.bounds.width - 100.0, y: self.view!.bounds.height - 100.0))
                    vectorLine.path = path
                    
                    // 停止処理
                    if spriteB.userData?["energy"] != nil {
                        var energy = spriteB.userData?["energy"] as! Int
                        energy--
                        spriteB.userData!.setObject(energy, forKey: "energy")
                        
                        if energy < 0 {
                            spriteB.userData!.removeObjectForKey("vector")
                            let action = SKAction.moveBy(vectorP!, duration: 0.1)
                            action.timingMode = .EaseOut
                            spriteB.runAction(action)
                        }
                    }
                }
            }
        }
    }
    
    // 2D反射ベクトル
    private func vector2DReflect(vector v: CGVector, normal n: CGVector) -> CGVector {
        let t = -(n.dx * v.dx + n.dy * v.dy) / (n.dx * n.dx + n.dy * n.dy)
        return CGVector(dx: v.dx + t * n.dx * 2.0, dy: v.dy + t * n.dy * 2.0)
    }
    
    // 2D滑りベクトル
    private func vector2DSlide(vector v: CGVector, normal n: CGVector) -> CGVector {
        let t = -(n.dx * v.dx + n.dy * v.dy) / (n.dx * n.dx + n.dy * n.dy)
        return CGVector(dx: v.dx + t * n.dx, dy: v.dy + t * n.dy)
    }
    
    // 進行ベクトルを視覚的に描画するパスを取得
    private func getArrowPath(vector: CGVector, location: CGPoint) -> CGMutablePath {
        // 進行ベクトルを描画
        let radian = Double(atan2(vector.dy, vector.dx))
        var distance = sqrt(pow(vector.dx, 2) + pow(vector.dy, 2))
        distance += 40.0
        let point1 = CGPointMake(location.x + CGFloat(cos(radian)) * distance, location.y + CGFloat(sin(radian)) * distance)
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, location.x, location.y)
        CGPathAddLineToPoint(path, nil, point1.x, point1.y)
        CGPathCloseSubpath(path)
        
        // 矢印描画
        let radian2 = radian - 30 * M_PI / 180
        let point2 = CGPointMake(point1.x - CGFloat(cos(radian2)) * 15.0, point1.y - CGFloat(sin(radian2)) * 15.0)
        let radian3 = radian + 30 * M_PI / 180
        let point3 = CGPointMake(point1.x - CGFloat(cos(radian3)) * 15.0, point1.y - CGFloat(sin(radian3)) * 15.0)
        
        CGPathMoveToPoint(path, nil, point2.x, point2.y)
        CGPathAddLineToPoint(path, nil, point1.x, point1.y)
        CGPathAddLineToPoint(path, nil, point3.x, point3.y)
        
        return path
    }
}
