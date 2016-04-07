//
//  ViewController.swift
//  AnimationDemo
//
//  Created by Hiroaki Komatsu on 2015/05/13.
//  Copyright (c) 2015年 Hiroaki Komatsu. All rights reserved.
//

import UIKit
import SpriteKit

struct Button {
    let defaultColor:UIColor = UIColor(red: 19.0/255.0, green: 144.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    var target: UIButton
    var value1: String!
    var value2: String!
    init(target t: UIButton, value1 v1: String, value2 v2: String = "") {
        target = t
        value1 = v1
        value2 = (v2 != "") ? v2 : v1
        target.layer.borderColor = defaultColor.CGColor
        deselect()
        
        if (v2 == "") {
            target.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        }
        
    }
    func select() {
        target.setTitle(value2, forState: UIControlState.Normal)
        target.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        target.backgroundColor = defaultColor
        target.layer.borderWidth = 0.0
    }
    func deselect() {
        target.setTitle(value1, forState: UIControlState.Normal)
        target.setTitleColor(defaultColor, forState: UIControlState.Normal)
        target.backgroundColor = UIColor.whiteColor()
        target.layer.borderWidth = 1.0
    }
}

class ViewController: UIViewController {
    
    private var scene: GameScene!
    private var button1: Button!
    private var button2: Button!
    private var button3: Button!
    private var button4: Button!
    private var button5: Button!
    private var button6: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        let x_radius = self.view.frame.width / 3.0
        let y_radius = self.view.frame.height / 4.0
        
        let radian = Double(360 / 6) * M_PI / 180.0
        
        let uibutton1 = createUIButton(tag: 1, position: CGPoint(
            x: CGFloat(cos(radian * 4)) * x_radius + center.x,
            y: CGFloat(sin(radian * 4)) * y_radius + center.y
            ))
        let uibutton2 = createUIButton(tag: 2, position: CGPoint(
            x: CGFloat(cos(radian * 5)) * x_radius + center.x,
            y: CGFloat(sin(radian * 5)) * y_radius + center.y
            ))
        let uibutton3 = createUIButton(tag: 3, position: CGPoint(
            x: CGFloat(cos(radian * 6)) * x_radius + center.x,
            y: CGFloat(sin(radian * 6)) * y_radius + center.y
            ))
        let uibutton4 = createUIButton(tag: 4, position: CGPoint(
            x: CGFloat(cos(radian * 1)) * x_radius + center.x,
            y: CGFloat(sin(radian * 1)) * y_radius + center.y
            ))
        let uibutton5 = createUIButton(tag: 5, position: CGPoint(
            x: CGFloat(cos(radian * 2)) * x_radius + center.x,
            y: CGFloat(sin(radian * 2)) * y_radius + center.y
            ))
        let uibutton6 = createUIButton(tag: 6, position: CGPoint(
            x: CGFloat(cos(radian * 3)) * x_radius + center.x,
            y: CGFloat(sin(radian * 3)) * y_radius + center.y
            ))
        
        self.view.addSubview(uibutton1)
        self.view.addSubview(uibutton2)
        self.view.addSubview(uibutton3)
        self.view.addSubview(uibutton4)
        self.view.addSubview(uibutton5)
        self.view.addSubview(uibutton6)
        
        button1 = Button(target: uibutton1, value1: "走る", value2: "走る")
        button2 = Button(target: uibutton2, value1: "しゃがむ", value2: "しゃがむ")
        button3 = Button(target: uibutton3, value1: "歩く", value2: "歩く")
        button4 = Button(target: uibutton4, value1: "ジャンプ")
        button5 = Button(target: uibutton5, value1: "攻撃")
        button6 = Button(target: uibutton6, value1: "魔法")
        
        scene = GameScene()
        scene.size = view.frame.size
        scene.scaleMode = .AspectFill
        
        let skView = SKView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.allowsTransparency = true
        skView.userInteractionEnabled = false
        skView.presentScene(scene)
        self.view.addSubview(skView)
        
        sync()
    }
    
    // ボタン生成
    private func createUIButton(tag t: Int, position p: CGPoint) -> UIButton {
        let button = UIButton()
        button.tag = t
        button.frame = CGRectMake(0,0,80.0,80.0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 40.0
        button.layer.position = p
        button.backgroundColor = UIColor.lightGrayColor()
        button.addTarget(self, action: "click:", forControlEvents: .TouchUpInside)
        return button
    }
    
    internal func click(sender: UIButton) {
        var action = false
        switch sender.tag {
        case 1:
            if (scene.state != State.run) {
                scene.run()
                action = true
            }
            
        case 2:
            if (scene.state != State.crouch) {
                scene.crouch()
                action = true
            }
            
        case 3:
            if (scene.state != State.walk) {
                scene.walk()
                action = true
            }
            
        case 4:
            scene.jump()
            action = true
            
        case 5:
            scene.attack()
            action = true
            
        case 6:
            scene.magic()
            action = true
            
        default:
            break
        }
        
        if (action == false) {
            scene.stop()
        }
        
        sync()
    }
    
    private func sync() {
        if (scene.state == State.run) {
            button1.select()
        } else {
            button1.deselect()
        }
        
        if (scene.state == State.crouch) {
            button2.select()
        } else {
            button2.deselect()
        }
        
        if (scene.state == State.walk) {
            button3.select()
        } else {
            button3.deselect()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

