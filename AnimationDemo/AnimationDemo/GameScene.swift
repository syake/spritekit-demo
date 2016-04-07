//
//  GameScene.swift
//  AnimationDemo
//
//  Created by Hiroaki Komatsu on 2015/05/13.
//  Copyright (c) 2015年 Hiroaki Komatsu. All rights reserved.
//

import SpriteKit

enum State {
    case wait
    case run
    case crouch
    case walk
    case attack
    case jump
}

class GameScene: SKScene {
    
    private var chara: SKSpriteNode!
    
    private var wait_action: SKAction!
    private var crouch1_action: SKAction!
    private var crouch2_action: SKAction!
    private var jump_action: SKAction!
    private var walk_action: SKAction!
    private var run1_action: SKAction!
    private var run2_action: SKAction!
    private var attack1_action: SKAction!
    private var attack2_action: SKAction!
    private var attack3_action: SKAction!
    private var magic1_action: SKAction!
    private var magic2_action: SKAction!
    private var magic3_action: SKAction!
    private var magic4_action: SKAction!
    private var magic5_action: SKAction!
    
    private var jump_count = 0
    
    private var _state: State! = State.wait
    var state: State {
        get {
            return _state
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = UIColor.clearColor()
        
        // Copyright by http://www.geocities.jp/zassoh2/index.htm
        let textrues01 = createTextures(imageNamed: "tewi_material01.png", col: 10, row: 5)
        let textrues02 = createTextures(imageNamed: "tewi_material02.png", col: 10, row: 2)
        let textrues03 = createTextures(imageNamed: "tewi_material03.png", col: 10, row: 3)
        let textrues08 = createTextures(imageNamed: "tewi_material08.png", col: 10, row: 3)
        let textrues27 = createTextures(imageNamed: "tewi_material27.png", col: 10, row: 4)
        
        // 各アニメーション生成
        let wait_animation = createAnimation(order: [0,1,2,3,4,5,6,7,8,9,10,11], textures: textrues01)
        let crouch1_animation = createAnimation(order: [20,21,22,23,24], textures: textrues01)
        let crouch2_animation = createAnimation(order: [26,27,28,29], textures: textrues01)
        let jump_animation = createAnimation(order: [30,31,32,33,34,35,36,37,38,39,40,41,42], textures: textrues01)
        let walk_animation = createAnimation(order: [0,1,2,3,4,5,6,7,8,9], textures: textrues02)
        let run1_animation = createAnimation(order: [0], textures: textrues03)
        let run2_animation = createAnimation(order: [2,3,4,5,6,7], textures: textrues03)
        let run3_animation = createAnimation(order: [10,11,12,13], textures: textrues03)
        let attack1_animation = createAnimation(order: [0,1,2,3,4], textures: textrues08)
        let attack2_animation = createAnimation(order: [10,11,12,13,14,15], textures: textrues08)
        let attack3_animation = createAnimation(order: [20,21,22,23,24,25,26,27], textures: textrues08)
        let magic1_animation = createAnimation(order: [0,1,2,3,4,5,6], textures: textrues27)
        let magic2_animation = createAnimation(order: [7,6], textures: textrues27)
        let magic3_animation = createAnimation(order: [8,9], textures: textrues27)
        let magic4_animation = createAnimation(order: [0,1,2,3,4,5,16], textures: textrues27)
        let magic5_animation = createAnimation(order: [17,16], textures: textrues27)
        let magic6_animation = createAnimation(order: [18,19], textures: textrues27)
        let magic7_animation = createAnimation(order: [20,21,22,23,24,25,26], textures: textrues27)
        let magic8_animation = createAnimation(order: [27,26], textures: textrues27)
        let magic9_animation = createAnimation(order: [28,29], textures: textrues27)
        let magic10_animation = createAnimation(order: [30,31,32,33,34,35,36,37,38,39], textures: textrues27)
        
        // アクション生成
        wait_action = SKAction.repeatActionForever(wait_animation)
        crouch1_action = crouch1_animation
        crouch2_action = crouch2_animation
        jump_action = jump_animation
        walk_action = SKAction.repeatActionForever(walk_animation)
        run1_action = SKAction.sequence([
            run1_animation,
            SKAction.repeatActionForever(run2_animation)
        ])
        run2_action = run3_animation
        attack1_action = attack1_animation
        attack2_action = attack2_animation
        attack3_action = attack3_animation
        magic1_action = SKAction.sequence([
            magic1_animation,
            magic3_animation
        ])
        magic2_action = SKAction.sequence([
            magic1_animation,
            SKAction.repeatAction(magic2_animation, count: 5),
            magic3_animation
        ])
        magic3_action = SKAction.sequence([
            magic4_animation,
            SKAction.repeatAction(magic5_animation, count: 5),
            magic6_animation
        ])
        magic4_action = SKAction.sequence([
            magic7_animation,
            SKAction.repeatAction(magic8_animation, count: 5),
            magic9_animation
        ])
        magic5_action = magic10_animation
        
        // キャラクター生成
        chara = SKSpriteNode(texture: textrues01.first)
        chara.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        chara.physicsBody = SKPhysicsBody(circleOfRadius: chara.size.height / 2.0)
        chara.physicsBody?.allowsRotation = false
        chara.physicsBody?.resting = true
        chara.physicsBody?.mass = 0.01
        chara.physicsBody?.linearDamping = 1.0
        self.addChild(chara)
        
        // setup physics
        let y = (self.frame.maxY - self.frame.minY - chara.size.height ) / 2
        self.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(self.frame.minX, y), toPoint: CGPointMake(self.frame.maxX, y))
        
        // 待機アクションを実行
        wait()
    }
    
    // テクスチャ配列生成
    private func createTextures( imageNamed name: String, col col_max: Int, row row_max: Int ) -> Array<SKTexture> {
        let basetexture = SKTexture(imageNamed: name)
        var textures = [SKTexture]()
        let width = 1 / CGFloat(col_max)
        let height = 1 / CGFloat(row_max)
        for var row = row_max - 1; row >= 0; row-- {
            let y = CGFloat(row) * height
            for var col = 0; col < col_max; col++ {
                let x = CGFloat(col) * width
                let textture = SKTexture(rect: CGRectMake(x, y, width, height), inTexture: basetexture)
                textures.append(textture)
            }
        }
        return textures
    }
    
    // アニメーション生成
    private func createAnimation(order o: Array<Int>, textures t: Array<SKTexture>, duration sec: NSTimeInterval = 0.1 ) -> SKAction {
        var textures = [SKTexture]()
        for i in o {
            let textture = t[i]
            textures.append(textture)
        }
        return SKAction.animateWithTextures(textures, timePerFrame: sec)
    }
    
    // 待機アクションを実行
    func wait() {
        reset()
        chara.runAction(wait_action)
        _state = State.wait
    }
    
    func run() {
        if (state == State.crouch || state == State.walk) {
            stop(completion: run)
        } else {
            reset()
            chara.runAction(run1_action)
        }
        _state = State.run
    }
    
    func crouch() {
        if (state == State.run || state == State.walk) {
            stop(completion: crouch)
        } else {
            reset()
            chara.runAction(crouch1_action)
        }
        _state = State.crouch
    }
    
    func walk() {
        if (state == State.run || state == State.crouch) {
            stop(completion: walk)
        } else {
            reset()
            chara.runAction(walk_action)
        }
        _state = State.walk
    }
    
    func jump() {
        if jump_count >= 2 {
            return
        }
        jump_count++
        
        chara.removeAllActions()
        chara.physicsBody?.affectedByGravity = true
        if (state == State.crouch || state == State.walk) {
            stop(completion: jump)
        } else {
            chara.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            chara.runAction(jump_action, completion: wait)
            if jump_count == 0 {
                chara.runAction(SKAction.waitForDuration(0.1), completion: jumpin)
            } else {
                jumpin()
            }
            _state = State.jump
        }
    }
    
    private func jumpin() {
        chara.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 5.0))
        chara.runAction(SKAction.waitForDuration(0.3), completion: jumping)
    }
    
    private func jumping() {
        chara.physicsBody?.affectedByGravity = false
        chara.runAction(SKAction.waitForDuration(0.5), completion: jumpout)
    }
    
    private func jumpout() {
        chara.physicsBody?.affectedByGravity = true
    }
    
    private func reset() {
        jump_count = 0
        chara.removeAllActions()
        chara.physicsBody?.affectedByGravity = true
    }
    
    func attack() {
        reset()
        if (state == State.run || state == State.crouch || state == State.walk) {
            stop(completion: attack)
        } else {
            let i = Int(arc4random_uniform(UInt32(3)))
            let action = [attack1_action, attack2_action, attack3_action][i]
            chara.runAction(action, completion: wait)
        }
        _state = State.attack
    }
    
    func magic() {
        reset()
        if (state == State.run || state == State.crouch || state == State.walk) {
            stop(completion: magic)
        } else {
            let i = Int(arc4random_uniform(UInt32(5)))
            let action = [magic1_action, magic2_action, magic3_action, magic4_action, magic5_action][i]
            chara.runAction(action, completion: wait)
        }
        _state = State.attack
    }
    
    func stop(completion block: (() -> Void)! = nil) {
        let old_state = state
        _state = State.wait
        
        reset()
        let completion = (block != nil) ? block : wait
        switch old_state {
        case State.run:
            chara.runAction(run2_action, completion: completion)
        case State.crouch:
            chara.runAction(crouch2_action, completion: completion)
        case State.walk:
            completion()
        default:
            break
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
