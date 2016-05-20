enum PcbState{
    case Ready
    case Blocked
    case Running
    case Finished
}

import Foundation
import SpriteKit

class PCB:SKShapeNode{
    
    var priority = 0
    var state = PcbState.Ready
    {
        didSet{
            switch self.state{
            case .Ready:
                self.fillColor = UIColor.grayColor()
            case .Blocked:
                self.fillColor = UIColor.redColor()
            case .Running:
                self.fillColor = UIColor.whiteColor()
            case .Finished:
                self.fillColor = UIColor.greenColor()
            }
        }
    }
    var counter = 60
    var next:PCB? = nil
    
    override init(){
        super.init()
        let shape = CGPathCreateMutable()
        CGPathAddArc(shape, nil, 0,0, 20, 0, CGFloat( M_PI * 2.0 ), true)
        self.path = shape
        self.alpha = 0.5
        self.fillColor = UIColor.grayColor()
        self.name = "PCB"
        
        let count = SKLabelNode()
        count.verticalAlignmentMode = .Center
        count.name = "count"
        count.position = CGPointMake(0, 30)
        self.addChild(count)
    }
    
    static func deletePCB(pcb: PCB){
        pcb.removeFromParent()
    }
    
    func run(){
        self.state = .Running
        self.counter -= 1
        (self.childNodeWithName("count") as! SKLabelNode).text = "\(self.counter)"
        if(self.counter <= 0){
            self.state = .Finished
            self.runAction(
                SKAction.scaleTo(1.5, duration: 1.0),completion:{
                    PCB.deletePCB(self)
            })
        }
    }
    
    func getExtraTime(){//未使用
        self.counter += 10
    }
    
    func getNextPCB(){
        if(self.next != nil){
            self.next = self.next!.next
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}