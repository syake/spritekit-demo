//
//  GameScene.swift
//  FlickDemo
//
//  Created by Hiroaki Komatsu on 2015/10/13.
//  Copyright (c) 2015年 Hiroaki Komatsu. All rights reserved.
//

import SpriteKit

enum Direction {
    case Nil
    case UP
    case DOWN
    case RIGHT
    case LEFT
}

enum State {
    case Nil
    case wait
    case run
    case crouch
    case walk
    case back
    case fall
}

class GameScene: SKScene {
    
    // flick property
    private let FLICK_JUDGE_TIME_INTERVAL = 0.3
    private let FLICK_DIFFERENCE: CGFloat = 50.0
    private var timestampBegan: NSTimeInterval = 0.0
    private var pointBegan: CGPoint?
    
    // spritekit property
    private var world: SKNode!
    private var effects: SKNode!
    private var hero: SKSpriteNode!
    private var backWidth: CGFloat!
    private var backNode: SKNode!
    private var backPoint: CGFloat = 0
    private var fontsWhite = [String: SKTexture]()
    private var fontsYellow = [String: SKTexture]()
    
    // action property
    private var waitAction: SKAction!
    private var waitToRunAction: SKAction!
    private var waitToCrouchAction: SKAction!
    private var waitToFallAction: SKAction!
    private var walkAction: SKAction!
    private var walkToCrouchAction: SKAction!
    private var walkToFallAction: SKAction!
    private var runAction: SKAction!
    private var backAction: SKAction!
    private var backToCrouchAction: SKAction!
    private var backToFallAction: SKAction!
    private var crouchAction: SKAction!
    private var crouchToStandupAction: SKAction!
    private var fallAction: SKAction!
    private var jumpAction: SKAction!
    private var flightAction: SKAction!
    private var backflipAction: SKAction!
    
    private var attack1Action: SKAction!
    private var attack2Action: SKAction!
    private var attack3Action: SKAction!
    private var crouchAttack1Action: SKAction!
    private var crouchAttack2Action: SKAction!
    private var crouchAttack3Action: SKAction!
    private var jumpAttackAction: SKAction!
    private var jumpToRunAttackAction: SKAction!
    private var runAttackAction: SKAction!
    
    private var kick1Action: SKAction!
    private var kick2Action: SKAction!
    private var kick3Action: SKAction!
    private var crouchKick1Action: SKAction!
    private var crouchKick2Action: SKAction!
    private var crouchKick3Action: SKAction!
    private var jumpKickAction: SKAction!
    private var jumpToRunKickAction: SKAction!
    private var runKickAction: SKAction!
    
    // attack propery
    private let ATTACK_JUDGE_DELAY_INTERVAL = 0.2
    private let ATTACK_JUDGE_WAIT_INTERVAL = 0.4
    private var attackJudgeFlag = false
    private var attackLevel: Int = 0
    private var jumpAttacked = false
    
    private var _state: State! = State.Nil
    var state: State {
        get {
            return _state
        }
    }
    private var _jumping: Bool = false
    var jumping: Bool {
        get {
            return _jumping
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        // フォント生成
        let fontsYellowAtlas = SKTextureAtlas(named: "AthelasYellow.atlas")
        for i in 0...9 {
            fontsYellow[String(i)] = fontsYellowAtlas.textureNamed("\(i).png")
        }
        let fontsWhiteAtlas = SKTextureAtlas(named: "AthelasWhite.atlas")
        for i in 0...9 {
            fontsWhite[String(i)] = fontsWhiteAtlas.textureNamed("\(i).png")
        }
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        world = SKNode()
        world.zPosition = 0
        self.addChild(world)
        
        // 透過地面を生成
        let ground = SKSpriteNode(color: UIColor.blueColor(), size: CGSizeMake(64.0, 64.0))
        ground.position = CGPoint(x: 0.0, y: -64.0)
        ground.zPosition = 1
//        ground.hidden = true
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = 0x1 << 0
//        self.addChild(ground)
        world.addChild(ground)
        
        // エフェクト用レイヤーを生成
        effects = SKNode()
        effects.zPosition = 2
        self.addChild(effects)
        
        // 背景テクスチャ生成
        let backTexture = SKTexture(imageNamed: "3a31908edfd4e5c8610f734e480b838737485087c94e9c6b2a5230ea7d674bce_5402500_450_6863968.jpg")
        backTexture.filteringMode = .Nearest
        
//        var width = self.frame.height / backTexture.size().height * backTexture.size().width
        
        for i in 0...2 {
            let texture = SKTexture(rect: CGRectMake(CGFloat(1 / 3 * i), 0.0, 1 / 3, 1.0), inTexture: backTexture)
            let backSprite = SKSpriteNode(texture: texture)
            backSprite.zPosition = -100.0
//            backSprite.size = CGSize(width: backWidth, height: self.frame.height)
        }
        print(self.frame.height)
        
        let backNumber = 2.0 + (self.frame.size.width / backTexture.size().width)
        backWidth = self.frame.height / backTexture.size().height * backTexture.size().width
        
        backNode = SKNode()
        for var i:CGFloat = 0; i < backNumber; ++i {
            let backSprite = SKSpriteNode(texture: backTexture)
            backSprite.zPosition = -100.0
            backSprite.size = CGSize(width: backWidth, height: self.frame.height)
            backSprite.position = CGPoint(x: i * backWidth + (backWidth - self.frame.width) / 2, y: 0.0)
            backNode.addChild(backSprite)
        }
        world.addChild(backNode)
        
        // キャラクターテクスチャ生成
        // Copyright by http://www.geocities.jp/zassoh2/index.htm
        let size = CGSize(width: 96.0 + 16.0, height: 96.0)
        let textrues01 = createTextures(imageNamed: "tewi_material01.png", col: 10, row: 5, size: size)
        let textrues02 = createTextures(imageNamed: "tewi_material02.png", col: 10, row: 2, size: size)
        let textrues03 = createTextures(imageNamed: "tewi_material03.png", col: 10, row: 3, size: size)
        let textrues05 = createTextures(imageNamed: "tewi_material05.png", col: 10, row: 3, size: size)
        let textrues06 = createTextures(imageNamed: "tewi_material06.png", col: 10, row: 2, size: size)
        let textrues08 = createTextures(imageNamed: "tewi_material08.png", col: 10, row: 3, size: size)
        let textrues091 = createTextures(imageNamed: "tewi_material09.png", col: 10, row: 2, size: size)
        let textrues092 = createTextures(imageNamed: "tewi_material09.png", col: 10, row: 2, size: size, offset: CGPointMake(8.0, 0.0))
        let textrues10 = createTextures(imageNamed: "tewi_material10.png", col: 8, row: 2, size: size, offset: CGPointMake(16.0, 0.0))
        let textrues11 = createTextures(imageNamed: "tewi_material11.png", col: 10, row: 2, size: size)
        let textrues12 = createTextures(imageNamed: "tewi_material12.png", col: 7, row: 2, size: size)
        let textrues13 = createTextures(imageNamed: "tewi_material13.png", col: 8, row: 2, size: size)
        let textrues14 = createTextures(imageNamed: "tewi_material14.png", col: 5, row: 1, size: size)
        let textrues15 = createTextures(imageNamed: "tewi_material15.png", col: 8, row: 3, size: size)
        let textrues16 = createTextures(imageNamed: "tewi_material16.png", col: 8, row: 4, size: size)
        let textrues17 = createTextures(imageNamed: "tewi_material17.png", col: 8, row: 4, size: size)
        
        // キャラクターアクション生成
        waitAction = SKAction.repeatActionForever(anim(order: [0,1,2,3,4,5,6,7,8,9,10,11], textures: textrues01))
        waitToRunAction = SKAction.sequence([
            anim(order: [10,11,12,13], textures: textrues03),
            waitAction
            ])
        waitToCrouchAction = SKAction.sequence([
            anim(order: [26,27,28,29], textures: textrues01),
            waitAction
            ])
        waitToFallAction = SKAction.sequence([
            anim(order: [7], textures: textrues06),
            anim(order: [27,28,29], textures: textrues01),
            waitAction
            ])
        walkAction = SKAction.group([
            SKAction.repeatActionForever(anim(order: [0,1,2,3,4,5,6,7,8,9], textures: textrues02)),
            SKAction.repeatActionForever(SKAction.moveByX(100.0, y: 0.0, duration: 1.5))
            ])
        walkToCrouchAction = SKAction.sequence([
            anim(order: [26,27,28,29], textures: textrues01),
            walkAction
            ])
        walkToFallAction = SKAction.sequence([
            anim(order: [7], textures: textrues06),
            anim(order: [27,28,29], textures: textrues01),
            walkAction
            ])
        runAction = SKAction.sequence([
            anim(order: [0], textures: textrues03),
            SKAction.group([
                SKAction.repeatActionForever(anim(order: [2,3,4,5,6,7], textures: textrues03)),
                SKAction.repeatActionForever(SKAction.moveByX(500.0, y: 0.0, duration: 1.5))
                ])
            ])
        backAction = SKAction.group([
            SKAction.repeatActionForever(anim(order: [10,11,12,13,14,15], textures: textrues02)),
            SKAction.repeatActionForever(SKAction.moveByX(-40.0, y: 0.0, duration: 1.5))
            ])
        backToCrouchAction = SKAction.sequence([
                anim(order: [26,27,28,29], textures: textrues01),
                backAction
            ])
        backToFallAction = SKAction.sequence([
            SKAction.group([
                SKAction.sequence([
                    anim(order: [7,17], textures: textrues06),
                    anim(order: [44,45,46,47,48,49], textures: textrues01),
                    anim(order: [19], textures: textrues06),
                    anim(order: [40,41,42], textures: textrues01)
                    ]),
                SKAction.moveByX(-30.0, y: 0.0, duration: 1.2)
                ]),
            backAction
            ])
        crouchAction = SKAction.repeatActionForever(anim(order: [24,24,24,24,24,24,16,17,25,25,25,25,25,25,19,18,24,24,24,24,24,24], textures: textrues01))
        crouchToStandupAction = SKAction.sequence([
            anim(order: [20,21,22,23,24], textures: textrues01),
            crouchAction
            ])
        fallAction = SKAction.sequence([
            anim(order: [10], textures: textrues05),
            anim(order: [0,1,2,3,4,5], textures: textrues06)
            ])
        jumpAction = anim(order: [30,31,32,33,34,35,36,37,38,39,40,41,42], textures: textrues01)
        flightAction = SKAction.sequence([
            anim(order: [0,1,3,4,5,3,4,5,9,10,11,12,13,14], textures: textrues13),
            anim(order: [0], textures: textrues01),
            anim(order: [0], textures: textrues03)
            ])
        backflipAction =  SKAction.sequence([
            anim(order: [17], textures: textrues06),
            anim(order: [44,45,46,47,48,49], textures: textrues01),
            anim(order: [19], textures: textrues06),
            anim(order: [40,41], textures: textrues01)
            ])
        
        attack1Action = anim(order: [0,1,2,3,4], textures: textrues08)
        attack2Action = anim(order: [10,11,12,13,14,15], textures: textrues08)
        attack3Action = anim(order: [20,21,22,23,24,25,26,27], textures: textrues08)
        crouchAttack1Action = anim(order: [0,1,2,3,4], textures: textrues091)
        crouchAttack2Action = anim(order: [10,11,12,13,14,15,16,17], textures: textrues092)
        crouchAttack3Action = anim(order: [0,1,2,3,4,5,6,7,8], textures: textrues10)
        jumpAttackAction = anim(order: [10,11,12,13,14,15], textures: textrues11)
        jumpToRunAttackAction = anim(order: [0,1,2,3,4,5,6,7], textures: textrues12)
        runAttackAction = anim(order: [0,1,2,10,11,5,6,7], textures: textrues12)
        
        kick1Action = anim(order: [0,1,2,3,4], textures: textrues14)
        kick2Action = anim(order: [0,1,2,3,4,5,6], textures: textrues15)
        kick3Action = anim(order: [9,10,11,12,13,14,15,16,17], textures: textrues15)
        crouchKick1Action = anim(order: [0,1,2,3,4], textures: textrues16)
        crouchKick2Action = anim(order: [8,9,10,11,12,13,14,15], textures: textrues16)
        crouchKick3Action = anim(order: [16,17,18,19,21,22,21,22,21,22,21,24,25,26,27,28,29], textures: textrues16)
        jumpKickAction = anim(order: [8,9,10,11,12,13,14,15,16,17], textures: textrues17)
        jumpToRunKickAction = anim(order: [24,25,26,27,28,29,30], textures: textrues17)
        runKickAction = SKAction.sequence([
            anim(order: [10,11], textures: textrues03),
            SKAction.group([
                anim(order: [19,21,22,21,22,21,22,21,24,26], textures: textrues16),
                SKAction.moveByX(100.0, y: 0.0, duration: 1.0)
            ]),
            anim(order: [12], textures: textrues03)
            ])
        
        // キャラクター生成
        hero = SKSpriteNode(texture: textrues01.first)
        hero.xScale = 1.2
        hero.yScale = 1.2
        hero.physicsBody = SKPhysicsBody(rectangleOfSize: hero.size)
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.affectedByGravity = true
        hero.physicsBody?.pinned = false
        hero.physicsBody?.mass = 1.0
        hero.zPosition = 1
        hero.anchorPoint = CGPointMake(80 / hero.frame.size.width / 2, 0.5)
        world.addChild(hero)
        wait()
    }
    
    
    // テクスチャ配列生成
    private func createTextures(imageNamed name: String, col: Int, row: Int, size: CGSize? = nil, offset: CGPoint! = CGPointZero) -> Array<SKTexture> {
        let basetexture = SKTexture(imageNamed: name)
        var textures = [SKTexture]()
        let width = 1 / CGFloat(col)
        let height = 1 / CGFloat(row)
        
        for i in (0..<row).reverse() {
            let y = CGFloat(i) * height
            for j in 0..<col {
                let x = CGFloat(j) * width
                let texture = SKTexture(rect: CGRectMake(x, y, width, height), inTexture: basetexture)
                if size != nil {
                    let resizedSize = CGSize(width: size!.width + offset!.x, height: size!.height + offset!.y)
                    let image = UIImage(CGImage: texture.CGImage())
                    UIGraphicsBeginImageContext(resizedSize)
                    let context = UIGraphicsGetCurrentContext()
                    CGContextTranslateCTM(context, offset!.x, offset!.y)
                    CGContextScaleCTM(context, resizedSize.width / size!.width, resizedSize.height / size!.height)
                    image.drawInRect(CGRectMake(0.0, 0.0, texture.size().width, texture.size().height))
                    let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    textures.append(SKTexture(CGImage: resizeImage.CGImage!))
                } else {
                    textures.append(texture)
                }
            }
        }
        return textures
    }
    
    // アニメーション生成
    private func anim(order o: Array<Int>, textures t: Array<SKTexture>, duration sec: NSTimeInterval = 0.1) -> SKAction {
        var textures = [SKTexture]()
        for i in o {
            let textture = t[i]
            textures.append(textture)
        }
        return SKAction.animateWithTextures(textures, timePerFrame: sec)
    }
    
    private func reset() {
        hero!.removeAllActions()
        _jumping = false
        attackLevel = 0
        attackJudgeFlag = false
        jumpAttacked = false
    }
    
    func wait() -> Bool {
        if state == State.wait {
            if hero!.actionForKey("repeat") == nil {
                hero!.runAction(waitAction!, withKey: "repeat")
                return true
            }
            return false
        }
        reset()
        switch state {
        case State.run:
            hero!.runAction(waitToRunAction!, withKey: "repeat")
        case State.crouch:
            hero!.runAction(waitToCrouchAction!, withKey: "repeat")
        case State.fall:
            hero!.runAction(waitToFallAction!, withKey: "repeat")
        default:
            hero!.runAction(waitAction!, withKey: "repeat")
        }
        _state = State.wait
        return true
    }
    
    func walk() -> Bool {
        if state == State.walk {
            if hero!.actionForKey("repeat") == nil {
                hero!.runAction(walkAction!, withKey: "repeat")
                return true
            }
            return false
        }
        reset()
        switch state {
        case State.crouch:
            hero!.runAction(walkToCrouchAction!, withKey: "repeat")
        case State.fall:
            hero!.runAction(walkToFallAction!, withKey: "repeat")
        default:
            hero!.runAction(walkAction!, withKey: "repeat")
        }
        _state = State.walk
        return true
    }
    
    func run() -> Bool {
        if state == State.run {
            if hero!.actionForKey("repeat") == nil {
                hero!.runAction(runAction!, withKey: "repeat")
                return true
            }
            return false
        }
        reset()
        hero!.runAction(runAction!, withKey: "repeat")
        _state = State.run
        return true
    }
    
    func back() -> Bool {
        if state == State.back {
            if hero!.actionForKey("repeat") == nil {
                hero!.runAction(backAction!, withKey: "repeat")
                return true
            }
            return false
        }
        reset()
        switch state {
        case State.crouch:
            hero!.runAction(backToCrouchAction!, withKey: "repeat")
        case State.fall:
            hero!.runAction(backToFallAction!, withKey: "repeat")
        default:
            hero!.runAction(backAction!, withKey: "repeat")
        }
        _state = State.back
        return true
    }
    
    func crouch() -> Bool {
        if state == State.crouch {
            if hero!.actionForKey("repeat") == nil {
                hero!.runAction(crouchAction!, withKey: "repeat")
                return true
            }
            return false
        }
        reset()
        hero!.runAction(crouchToStandupAction!, withKey: "repeat")
        _state = State.crouch
        return true
    }
    
    func fall() -> Bool {
        if state == State.fall {
            return false
        }
        reset()
        hero!.runAction(fallAction!, withKey: "repeat")
        _state = State.fall
        return true
    }
    
    func jump() -> Bool {
        if jumping {
            return false
        }
        let completion = {() -> Void in
            self._jumping = false
            self.jumpAttacked = false
        }
        switch state {
        case State.run:
            hero!.runAction(flightAction!, completion: completion)
            hero!.runAction(flightAction!, completion: completion)
        default:
            hero!.runAction(jumpAction!, completion: completion)
        }
        hero!.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 700.0))
        _jumping = true
        return true
    }
    
    func backflip() -> Bool {
        if jumping {
            return false
        }
        let completion = {() -> Void in
            self._jumping = false
        }
        hero!.runAction(backflipAction!, completion: completion)
        _jumping = true
        return true
    }
    
    func attack(kick: Bool = false) -> Bool {
        if !attackJudgeFlag {
            attackLevel = 0
        }
        
        var action: SKAction? = nil
        var completion: (() -> Void)? = {}
        
        if kick {
            if jumping {
                if !jumpAttacked && hero!.physicsBody?.velocity.dy > -50.0 {
                    switch state {
                    case State.run:
                        action = jumpToRunKickAction
                        attackLevel = 3
                        let mass = self.hero!.physicsBody?.mass
                        self.hero!.physicsBody?.mass = 0.1
                        self.hero!.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 50.0))
                        self.hero!.physicsBody?.mass = mass!
                    default:
                        action = jumpKickAction
                        attackLevel = 2
                        let mass = self.hero!.physicsBody?.mass
                        self.hero!.physicsBody?.mass = 0.1
                        self.hero!.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 50.0))
                        self.hero!.physicsBody?.mass = mass!
                        break
                    }
                    jumpAttacked = true
                }
            } else {
                switch state {
                case State.wait, State.walk, State.back:
                    switch attackLevel {
                    case 0:
                        action = kick1Action
                    case 1:
                        action = kick2Action
                    case 2:
                        action = kick3Action
                    default:
                        break
                    }
                case State.crouch:
                    switch attackLevel {
                    case 0:
                        action = crouchKick1Action
                    case 1:
                        action = crouchKick2Action
                    case 2:
                        action = crouchKick3Action
                    default:
                        break
                    }
                case State.run:
                    switch attackLevel {
                    case 0:
                        action = runKickAction
                        attackLevel = 2
                    default:
                        break
                    }
                default:
                    break
                }
            }
        } else {
            if jumping {
                if !jumpAttacked && hero!.physicsBody?.velocity.dy > -50.0 {
                    switch state {
                    case State.run:
                        action = jumpToRunAttackAction
                        attackLevel = 3
                        let mass = self.hero!.physicsBody?.mass
                        self.hero!.physicsBody?.mass = 0.1
                        self.hero!.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 40.0))
                        self.hero!.physicsBody?.mass = mass!
                    default:
                        action = jumpAttackAction
                        attackLevel = 2
                        let mass = self.hero!.physicsBody?.mass
                        self.hero!.physicsBody?.mass = 0.1
                        self.hero!.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 20.0))
                        self.hero!.physicsBody?.mass = mass!
                        break
                    }
                    jumpAttacked = true
                }
            } else {
                switch state {
                case State.wait, State.walk, State.back:
                    switch attackLevel {
                    case 0:
                        action = attack1Action
                    case 1:
                        action = attack2Action
                    case 2:
                        action = attack3Action
                    default:
                        break
                    }
                case State.crouch:
                    switch attackLevel {
                    case 0:
                        action = crouchAttack1Action
                    case 1:
                        action = crouchAttack2Action
                    case 2:
                        action = crouchAttack3Action
                    default:
                        break
                    }
                case State.run:
                    switch attackLevel {
                    case 0:
                        action = runAttackAction
                        attackLevel = 2
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        
        if action == nil {
            return false
        }
        ++attackLevel
        
        switch state {
        case State.walk:
            hero!.removeActionForKey("repeat")
            completion = {() -> Void in
                self.walk()
            }
        case State.back:
            hero!.removeActionForKey("repeat")
            completion = {() -> Void in
                self.back()
            }
        case State.crouch:
            hero!.removeActionForKey("repeat")
            completion = {() -> Void in
                self.crouch()
            }
        default:
            break
        }
        hero!.removeActionForKey("attack")
        hero!.removeActionForKey("judge")
        hero!.runAction(SKAction.sequence([
            action!,
            SKAction.runBlock(completion!)
            ]), withKey: "attack")
        
        attackJudgeFlag = false
        hero!.runAction(SKAction.sequence([
            SKAction.waitForDuration(ATTACK_JUDGE_DELAY_INTERVAL),
            SKAction.runBlock({() -> Void in
                self.attackJudgeFlag = true
            }),
            SKAction.waitForDuration(ATTACK_JUDGE_WAIT_INTERVAL),
            SKAction.runBlock({() -> Void in
                self.attackJudgeFlag = false
                self.attackLevel = 0
            })
            ]), withKey: "judge")
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if let touch = touches.first {
            timestampBegan = event!.timestamp
            pointBegan = touch.locationInNode(self)
            
            let ripple = SKEmitterNode(fileNamed: "Ripple.sks")
            ripple!.position = pointBegan!
            ripple!.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.removeFromParent()]))
            effects!.addChild(ripple!)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let twinkle = SKEmitterNode(fileNamed: "Twinkle.sks")
            twinkle!.position = touch.locationInNode(self)
            twinkle!.runAction(SKAction.sequence([SKAction.waitForDuration(2), SKAction.removeFromParent()]))
            effects!.addChild(twinkle!)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var point = CGPointZero
        var direction = Direction.Nil
        var difference = CGPointZero
        var active = false
        
        let timeBeganToEnded = event!.timestamp - timestampBegan
        if (FLICK_JUDGE_TIME_INTERVAL > timeBeganToEnded) {
            if let touch = touches.first {
                point = touch.locationInNode(self)
                difference = CGPointMake(point.x - pointBegan!.x, point.y - pointBegan!.y)
                direction = detectSwipeDirection(difference)
            }
        }
        
        switch direction {
        case Direction.UP:
            if (state == State.crouch || state == State.fall) {
                active = wait()
            } else {
                active = jump()
            }
        case Direction.RIGHT:
            if (state == State.run || state == State.walk) {
                active = run()
            } else {
                active = walk()
            }
        case Direction.DOWN:
            if (state == State.run) {
                active = fall()
            } else {
                active = crouch()
            }
        case Direction.LEFT:
            if (state == State.run) {
                active = wait()
            } else if (state == State.back) {
                active = backflip()
            } else {
                active = back()
            }
        default:
            active = attack(self.frame.height / point.y < 0)
            break;
        }
        
        if !active {
            return
        }
        
        // 文字を表示
        var n: Int = 0
        var fonts: Dictionary = [String: SKTexture]()
        var action: SKAction? = nil
        var position: CGPoint? = nil
        
        if (direction != Direction.Nil) {
            // フリックイベント
            
            if (direction == Direction.UP || direction == Direction.DOWN) {
                n = Int(abs(difference.y))
            }
            if (direction == Direction.LEFT || direction == Direction.RIGHT) {
                n = Int(abs(difference.x))
            }
            
            let pos = self.frame.size.width / 4
            switch direction {
            case Direction.UP:
                position = CGPoint(x: 0.0, y: pos)
            case Direction.RIGHT:
                position = CGPoint(x: pos, y: 0.0)
            case Direction.DOWN:
                position = CGPoint(x: 0.0, y: -pos)
            case Direction.LEFT:
                position = CGPoint(x: -pos, y: 0.0)
            default:
                break;
            }
            
        } else {
            // タッチイベント
            
            switch attackLevel {
            case 1:
                n = Int(arc4random() % 50) + 50
            case 2:
                n = Int(arc4random() % 100) + 100
            case 3:
                n = Int(arc4random() % 200) + 200
            case 4:
                n = Int(arc4random() % 400) + 400
            default:
                break;
            }
            
            let x = 50.0 + 20.0 * CGFloat(attackLevel)
            if jumping {
                let y = 200.0 + 10.0 * CGFloat(attackLevel)
                position = CGPoint(x: x, y: y)
            } else {
                let y = 15.0 + 10.0 * CGFloat(attackLevel)
                position = CGPoint(x: x, y: y)
            }
        }
        
        if n > 200 {
            fonts = fontsYellow
            let swellAction = SKAction.scaleXTo(4.0, y: 4.0, duration: 0.1)
            swellAction.timingMode = .EaseInEaseOut
            let shrinkAction = SKAction.scaleXTo(1.0, y: 1.0, duration: 0.3)
            shrinkAction.timingMode = .EaseOut
            action = SKAction.sequence([
                SKAction.group([
                    SKAction.fadeAlphaTo(0.0, duration: 0),
                    SKAction.scaleTo(3.0, duration: 0)
                    ]),
                SKAction.group([
                    SKAction.fadeAlphaTo(1.0, duration: 0.5),
                    SKAction.sequence([swellAction, shrinkAction])
                    ])
                ])
        } else {
            fonts = fontsWhite
            let swellAction = SKAction.scaleXTo(4.0, y: 4.0, duration: 0.2)
            swellAction.timingMode = .EaseInEaseOut
            let shrinkAction = SKAction.scaleXTo(1.0, y: 1.0, duration: 0.4)
            shrinkAction.timingMode = .EaseOut
            action = SKAction.sequence([
                SKAction.fadeAlphaTo(0.0, duration: 0),
                SKAction.fadeAlphaTo(1.0, duration: 0.5)
                ])
        }
        
        let str: String = String(n)
        let labelNode = createCharactersLabel(str, fonts: fonts, kerning: -6, action: action)
        labelNode.xScale = 0.5
        labelNode.yScale = 0.5
        if position != nil {
            labelNode.position = position!
        }
        
        let fadeOutAction = SKAction.fadeAlphaTo(0.0, duration: 1.0)
        fadeOutAction.timingMode = .EaseInEaseOut
        labelNode.runAction(SKAction.sequence([
            SKAction.group([
                SKAction.moveByX(0.0, y: 20.0, duration: 1.5),
                SKAction.sequence([
                    SKAction.waitForDuration(0.5),
                    fadeOutAction
                    ])
                ]),
            SKAction.removeFromParent()
            ]))
        
        var z: CGFloat = 0.0
        for child in effects.children {
            if (z < child.zPosition) {
                z = child.zPosition
            }
        }
        labelNode.zPosition = z + 1
        effects!.addChild(labelNode)
    }
    
    private func detectSwipeDirection(difference:CGPoint) -> Direction {
        if (sqrt(difference.x * difference.x + difference.y * difference.y) < FLICK_DIFFERENCE) {
            return Direction.Nil
        }
        
        var degree: Int = 0
        if (difference.x != 0) {
            let radian = atan(difference.y/fabs(difference.x))
            degree = Int(radian * CGFloat(180 * M_1_PI))
        } else {
            degree = difference.y > 0 ? 90 : -90
        }
        
        switch degree {
        case -90 ..< -45:
            return Direction.DOWN
        case -45 ..< 45:
            if (difference.x >= 0) {
                return Direction.RIGHT
            } else {
                return Direction.LEFT
            }
        case 45 ..< 90:
            return Direction.UP
        default:
            return Direction.UP
        }
    }
    
    private func createCharactersLabel(str: String, fonts: Dictionary<String, SKTexture>, kerning: CGFloat = 0.0, action: SKAction? = nil) -> SKSpriteNode {
        let labelNode = SKSpriteNode()
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var delay: NSTimeInterval = 0.0
        for character in str.characters {
            if let font = fonts[String(character)] {
                let label = SKSpriteNode(texture: font)
                if (x > 0) {
                    x += (font.size().width + kerning) / 2
                }
                label.position = CGPoint(x: x, y: 0.0)
                x += (font.size().width + kerning) / 2
                if y < font.size().height {
                    y = font.size().height
                }
                
                if action != nil {
                    label.hidden = true
                    label.runAction(SKAction.waitForDuration(delay), completion: {
                        label.hidden = false
                        label.runAction(action!)
                    })
                    delay += 0.05
                }
                labelNode.addChild(label)
            }
        }
        let dx = x / 2
        for child in labelNode.children {
            child.position.x -= dx
        }
        labelNode.size = CGSize(width: x, height: y)
        return labelNode
    }
    
    private func outlinedSKLabelNode(label: SKLabelNode, width: CGFloat = 1.0, color: SKColor = SKColor.blackColor()) {
        let offsets = [CGPoint(x: 1, y: 0),CGPoint(x: -1, y: 0),CGPoint(x: 0, y: 1),CGPoint(x: 0, y: -1)]
        for (index, point) in EnumerateSequence(offsets) {
            let border = label.copy() as! SKLabelNode
            border.fontColor = color
            border.zPosition = label.zPosition - CGFloat(index + 1)
            border.position = CGPoint(x: border.position.x + point.x * width, y: border.position.y + point.y * width)
            label.addChild(border)
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func centerOnNode(node: SKNode) {
        let cameraPositionInScene:CGPoint = self.convertPoint(node.position, fromNode: node.parent!)
        node.parent!.position = CGPoint(x: node.parent!.position.x - cameraPositionInScene.x, y: 0)
    }
    
    override func didSimulatePhysics() {
        self.centerOnNode(hero!)
        
        
        let p = world.position.x / backWidth
        
//        print(p)
//        print(backPoint)
        if (p  < (backPoint + 1) * -1) {
            backPoint++
            backNode.position.x = backWidth * backPoint
            
        } else if (world.position.x / backWidth > backPoint) {
            backPoint--
            backNode.position.x = backWidth * backPoint
            
        }
    }
}
