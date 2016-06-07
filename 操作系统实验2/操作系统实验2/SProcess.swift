//
//  SProcess.swift
//  操作系统实验2
//
//  Created by AlterTaceo on 16/6/6.
//  Copyright © 2016年 test. All rights reserved.
//

import Foundation
import SpriteKit

class SProcess: SKNode{
    
    private static var distance = 60
    
    static var dimension:Int = 2
    
    var pMax = [SKNode]()
    var pAllocation = [SKNode]()
    var pNeed = [SKNode]()
    
    static func getProcess(position: CGPoint) -> SProcess{
        let process = SProcess()
        process.position = position
        let length = distance * (dimension - 1) / 2
        for i in 0..<dimension{
            let max = ValueNode.getValueNode(CGPointMake(CGFloat(i * distance - length), -200), value:1)
            let allocation = ValueNode.getValueNode(CGPointMake(CGFloat(i * distance - length), -400), value:1)
            let need = ValueNode.getValueNode(CGPointMake(CGFloat(i * distance - length), -600), value:1)
            
            process.addChild(max)
            process.addChild(allocation)
            process.addChild(need)
            
            process.pMax.append(max)
            process.pAllocation.append(allocation)
            process.pNeed.append(need)
            
        }
        
        //print((process.pMax[1] as! ValueNode).value)
        return process
    }
    
    override init(){
        super.init()
        let node = SKShapeNode(circleOfRadius: 30)
        node.fillColor = UIColor.grayColor()
        node.alpha = 0.7
        node.name = "Process"
        self.addChild(node)
        
            
        func setAttributes(label: SKLabelNode){
            label.fontSize = 30
            label.verticalAlignmentMode = .Center
            label.fontColor = UIColor.yellowColor()
            self.addChild(label)
        }
    
        let lMax = SKLabelNode(text: "Max")
        let lAllocation = SKLabelNode(text: "Allocation")
        let lNeed = SKLabelNode(text: "Need")
        
        setAttributes(lMax);setAttributes(lAllocation);setAttributes(lNeed)
        
        lMax.position = CGPointMake(0, -100)
        lAllocation.position = CGPointMake(0, -300)
        lNeed.position = CGPointMake(0, -500)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ValueNode: SKNode{
    var value:Int = 0
    
    let plus = SKLabelNode(text: "Add")
    let minus = SKLabelNode(text: "Sub")
    let val = SKLabelNode(text: "0")
    
    static func getValueNode(position: CGPoint, value:Int = 0) -> ValueNode{
        let v = ValueNode()
        v.position = position
        v.value = value
        v.val.text = "\(value)"
        return v
    }
    
    override init(){
        super.init()
        
        func setAttributes(label: SKLabelNode){
            label.name = "ValueControl"
            label.fontSize = 30
            label.verticalAlignmentMode = .Center
            self.addChild(label)
        }
        
        setAttributes(plus)
        setAttributes(minus)
        setAttributes(val)
        
        minus.position = CGPointMake(0, -40)
        plus.position = CGPointMake(0, 40)
    }
    
    func changeValueAccordingTo(labelNode: SKNode){
        switch labelNode{
        case plus:
            value = value + 1
            val.text = "\(value)"
        case minus:
            value = value - 1
            val.text = "\(value)"
        default:
            break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}