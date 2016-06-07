//
//  GameScene.swift
//  操作系统实验2
//
//  Created by AlterTaceo on 16/6/6.
//  Copyright (c) 2016年 test. All rights reserved.
//


////Banker's Algorithm


import SpriteKit

class GameScene: SKScene {
    
    static var currentScene:GameScene?
    
    let processAmount = 5
    let resourceDimension = 3
    
    let request = SKLabelNode(text: "Request")
    let reset = SKLabelNode(text:"Reset")
    let selectCircle = SKShapeNode(circleOfRadius: 50)
    
    var baseline:CGFloat = 0
    
    var processes = [SKNode]()
    var resourceVector = [SKNode]()
    
    var requestVector = [SKNode]()
    
    var selectedIndex:Int? = nil
    
    override func didMoveToView(view: SKView) {
        GameScene.currentScene = self
        
        baseline = size.height - 50
        
        getControls()
        SProcess.dimension = resourceDimension
        
        selectCircle.alpha = 0
        self.addChild(selectCircle)
        
        let distance = 200
        for i in 0..<processAmount{
            let p = SProcess.getProcess(CGPointMake(100 + CGFloat(i * distance), baseline))
            self.addChild(p)
            processes.append(p)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        if(nodeAtPoint(location).name == nil){
        }else{
            let node = nodeAtPoint(location)
            switch(node.name!){
            case "Request":
                startRequest()
                break
            case "ValueControl":
                (nodeAtPoint(location).parent as! ValueNode).changeValueAccordingTo(node)
            case "Process":
                selectedIndex = processes.indexOf(node.parent!)
                selectCircle.alpha = 1
                selectCircle.position = nodeAtPoint(location).parent!.position
            case "Reset":
                for p in processes{
                    p.position.y = baseline
                }
            default:
                break
            }
        }
    }
    
    func getControls(){
        
        let available = SKLabelNode(text: "Available")
        let requestAmount = SKLabelNode(text: "Request Vector")
        
        available.position = CGPointMake(150, 170)
        requestAmount.position = CGPointMake(size.width / 2, 170)
        
        available.fontSize = 30
        requestAmount.fontSize = 30
        
        available.fontColor = UIColor.greenColor()
        requestAmount.fontColor = UIColor.greenColor()
        
        self.addChild(available)
        self.addChild(requestAmount)
        
        request.position = CGPointMake(size.width - 100, 100)
        request.name = "Request"
        request.fontSize = 50
        request.verticalAlignmentMode = .Center
        self.addChild(request)
        
        reset.position = CGPointMake(size.width - 100, size.height / 2)
        reset.name = "Reset"
        reset.fontSize = 50
        reset.verticalAlignmentMode = .Center
        self.addChild(reset)
        
        for i in 0..<resourceDimension{
            let node = ValueNode.getValueNode(CGPointMake(CGFloat(i) * 70 + 50, 100))
            self.addChild(node)
            resourceVector.append(node)
        }
        
        for i in 0..<resourceDimension{
            let node = ValueNode.getValueNode(CGPointMake(size.width / 2 + CGFloat(i) * 70, 100))
            self.addChild(node)
            requestVector.append(node)
        }
        
        
        
    }
    
    func startRequest(){
        guard let index = selectedIndex
        else{
            print("No selected process")
            return
        }
        
        let getValue = {(n: SKNode) -> Int in (n as! ValueNode).value}
        
        //The resources currently available
        let availableV = resourceVector.map(getValue)
        
        //The resources the process requests
        let requestV = requestVector.map(getValue)
        
        //The matrix that stores things about processes
        let resourceM = processes.map({(n: SKNode) -> (max:[Int], need:[Int], allocation:[Int]) in
            let n = n as! SProcess
            return (max: n.pMax.map(getValue),
                need: n.pAllocation.map(getValue),
                allocation: n.pNeed.map(getValue))
        })
        
        if let sequence = bankerAlgorithm(index, availableV, requestV, resourceM){
            if(sequence != [-1]){
                if(sequence.count != processes.count){
                    print("Not safe")
                }else{
                    for i in sequence{
                        processes[i].position.y = baseline - CGFloat(i) * 20
                    }
                }
            }else{
                print("No enough resources to distribute")
            }
        }else{
            print("The declared request amount makes more allocation than max amount")
        }
        
        selectCircle.alpha = 0
        selectedIndex = nil
    }
    
    func bankerAlgorithm(
        processIndex: Int,
        _ availableResources: [Int],
        _ requestResources: [Int],
        _ resourceMatrix: [(max:[Int], need:[Int], allocation:[Int])]
        ) -> [Int]?{
        
        var safeSequence = [Int]()
        
        func plus(a:[Int], _ b:[Int]) -> [Int]{
            var c = [Int]()
            for i in 0..<a.count{
                c += [a[i]+b[i]]
            }
            return c
        }
        
        func minus(a:[Int], _ b:[Int]) -> [Int]{
            var c = [Int]()
            for i in 0..<a.count{
                c.append(a[i]-b[i])
            }
            return c
        }
        
        func checkNegative(a:[Int]) -> Bool{
            for i in a{
                if(i < 0){return true}
            }
            return false
        }
        
        let p = resourceMatrix[processIndex]
        
        //The declared request amount makes more allocation than max amount
        if(checkNegative(minus(p.need, requestResources))){
            return nil
        }
        
        //No enough resources to distribute
        if(checkNegative(minus(availableResources, requestResources))){
            return [-1]
        }
        
        //Start to try to find out a safe sequence
        let availableResources = minus(availableResources, requestResources)
        var resourceMatrix = resourceMatrix
        resourceMatrix[processIndex].allocation = plus(
            resourceMatrix[processIndex].allocation, requestResources
        )
        resourceMatrix[processIndex].need = minus(
            resourceMatrix[processIndex].need , requestResources
        )
        
        
        //SafeCheck algorithm
        var work = availableResources
        
        var r = [(max:[Int], need:[Int], allocation:[Int], finish:Bool, index:Int)]()
        for i in 0..<resourceMatrix.count{
            let v = resourceMatrix[i]
            r.append(
                (max:v.max, need:v.need, allocation:v.allocation, finish:false, index:i)
            )
        }
        
        for _ in 1...r.count{
            if let v = r.filter(
                {(v:(max: [Int], need: [Int], allocation: [Int], finish: Bool, index: Int)) -> Bool in
                if (v.finish == false && checkNegative(minus(work, v.need)) == false){
                    return true
                }else{
                    return false
                }
            }).first{
                let i = v.index
                safeSequence.append(i)
                r[i].finish = true
                work = plus(work, v.allocation)
            }else{
                return safeSequence//Not safe
            }
        }
        
        return safeSequence//Safe
    }
}
