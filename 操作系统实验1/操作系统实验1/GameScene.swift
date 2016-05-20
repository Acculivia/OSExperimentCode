import SpriteKit

class GameScene: SKScene {
    
    enum DispatchMethod{
        case Priority
        case TimeSlice
    }
    
    enum ControlState{
        case Running
        case Modifying
    }
    
    static var currentScene:GameScene? = nil
    
    var dispatch = DispatchMethod.Priority
    var currentState = ControlState.Running
    
    var readyPCB = PCB()//就绪进程队列头指针
    var blockedPCB = PCB()//阻塞进程队列头指针
    
    var currentPCB: PCB? = nil
    var maxTimeDuration = 5
    var timeLeft = 0
    
    var needRefreash = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.blackColor()
        GameScene.currentScene = self
        self.timeLeft = self.maxTimeDuration
        
        
        /************************************/
        
        self.dispatch = .Priority
        
        /************************************/
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        let location = touches.first!.locationInNode(self)
        
        switch(self.currentState){
        case .Running:
            spawnControlItems(location)
        case .Modifying:
            if(self.nodeAtPoint(location).name == nil){deleteControlItems()}
            else{
                let node = self.childNodeWithName("Control")!
                switch self.nodeAtPoint(location).name! {
                case "block":
                    blockPCB(node.position)
                case "add":
                    addPriority(node.position)
                case "sub":
                    subPriority(node.position)
                case "delete":
                    let l = CGPointMake(node.position.x + 1, node.position.y + 1)
                    let pcb = self.nodeAtPoint(l) as! PCB
                    deletePCB(pcb, fromQueue: readyPCB)
                    deletePCB(pcb, fromQueue: blockedPCB)
                    pcb.removeFromParent()
                default:
                    break
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if(self.currentState == .Running){self.runPCB()}
    }
    
    func runPCB(){
        switch dispatch{
        case .Priority:
            
            //优先级调度算法 按照优先级从队列中抽取优先级最高的一个进程运行
            if let pcb = self.currentPCB{
                
                pcb.run()
                
                if(pcb.state == .Finished){
                    deletePCB(pcb, fromQueue: readyPCB)
                    if(needRefreash == false){
                        self.currentPCB = pcb.next
                    }else{
                        self.currentPCB = self.readyPCB.next
                        needRefreash = false
                    }
                }
            }
            
            
        case .TimeSlice:
            
            //时间片轮转调度算法 在一个时间片中按照队列中进程顺序执行一个进程
            if let pcb = self.currentPCB{
                
                pcb.run()
                self.timeLeft -= 1
                
                if(pcb.state == .Finished || self.timeLeft <= 0){
                    self.timeLeft = self.maxTimeDuration
                    if(pcb.state == .Finished){
                        deletePCB(pcb, fromQueue: readyPCB)
                    }
                    pcb.state = .Ready
                    
                    if(!needRefreash){self.currentPCB = pcb.next}
                    else{
                        self.currentPCB = readyPCB.next
                        needRefreash = false
                    }
                    if(self.currentPCB == nil){self.currentPCB = readyPCB.next}
                    
                }
            }
        }
    }
    
    func spawnControlItems(position: CGPoint){
        self.currentState = .Modifying
        
        if(self.nodeAtPoint(position).name == nil){
            let pcb = PCB()
            pcb.counter = 60
            var p = self.readyPCB
            while(p.next != nil){p = p.next!}
            p.next = pcb
            self.addChild(pcb)
            if(self.currentPCB == nil){self.currentPCB = pcb}
            pcb.position = position
        }
        
        let node = SKNode()
        let block = SKLabelNode(text: "block")
        let add = SKLabelNode(text: "add")
        let sub = SKLabelNode(text: "sub")
        let delete = SKLabelNode(text: "delete")
        let addExtraTime = SKLabelNode(text:"addExtraTime")
        
        let priority = SKLabelNode(text:"\((self.nodeAtPoint(position) as! PCB).priority)")
        
        func setAttribute(s: SKLabelNode){
            s.fontColor = UIColor.whiteColor()
            s.fontSize = 40
            s.name = s.text
            s.zPosition = 3
            s.verticalAlignmentMode = .Center
            node.addChild(s)
        }
        
        setAttribute(block); setAttribute(add); setAttribute(sub); setAttribute(delete); setAttribute(priority)
        block.position = CGPointMake(-60, 50)
        add.position = CGPointMake(-50, -50)
        sub.position = CGPointMake(50, -50)
        delete.position = CGPointMake(60, 50)
        priority.position = CGPointMake(0, -100)
        priority.name = "priority"
        
        node.name = "Control"
        self.addChild(node)
        node.position = position
    }
    
    func blockPCB(location: CGPoint){
        var location = CGPointMake(location.x + 1, location.y + 1)
        if(self.nodeAtPoint(location).name == "PCB"){
            let pcb = self.nodeAtPoint(location) as! PCB
            if(pcb.state == .Blocked){
                pcb.state = .Running
                deletePCB(pcb, fromQueue: blockedPCB)
                insertPCB(pcb, toQueue: readyPCB)
                
            }else{
                pcb.state = .Blocked
                deletePCB(pcb, fromQueue: readyPCB)
                insertPCB(pcb, toQueue: blockedPCB)
            }
        }
    }
    
    func addPriority(location: CGPoint){
        var location = CGPointMake(location.x + 1, location.y + 1)
        let p = self.nodeAtPoint(location)
        if(p.name == "PCB"){
            (p as! PCB).priority += 1
            (self.childNodeWithName("Control")!.childNodeWithName("priority") as! SKLabelNode).text = "\((p as! PCB).priority)"
            let pcb = p as! PCB
            switch pcb.state {
            case .Running, .Ready:
                deletePCB(pcb, fromQueue: readyPCB)
                insertPCB(pcb, toQueue: readyPCB)
            case .Blocked:
                deletePCB(pcb, fromQueue: blockedPCB)
                insertPCB(pcb, toQueue: blockedPCB)
            default:
                print("?")
            }
        }
    }
    
    func subPriority(location: CGPoint){
        var location = CGPointMake(location.x + 1, location.y + 1)
        let p = self.nodeAtPoint(location)
        if(p.name == "PCB"){
            if((p as! PCB).priority > 0){
                (p as! PCB).priority -= 1
                (self.childNodeWithName("Control")!.childNodeWithName("priority") as! SKLabelNode).text = "\((p as! PCB).priority)"
                let pcb = p as! PCB
                switch pcb.state {
                case .Running, .Ready:
                    deletePCB(pcb, fromQueue: readyPCB)
                    insertPCB(pcb, toQueue: readyPCB)
                case .Blocked:
                    deletePCB(pcb, fromQueue: blockedPCB)
                    insertPCB(pcb, toQueue: blockedPCB)
                default:
                    print("?")
                }
            }
        }
    }
    
    func insertPCB(pcb: PCB, toQueue: PCB) -> PCB{
        var p = toQueue
        if(toQueue.next == nil){toQueue.next = pcb}
        else{
            while(p.next != nil && p.next!.priority >= pcb.priority){
                p = p.next!
            }
            pcb.next = p.next
            p.next = pcb
        }
        self.needRefreash = true
        return pcb
    }
    
    func deletePCB(pcb: PCB, fromQueue: PCB) -> PCB{
        var p = fromQueue
        while(p.next != pcb){
            if(p.next == nil){
                return pcb
            }
            p = p.next!
        }
        p.next = pcb.next
        self.needRefreash = true
        return pcb
    }

    func deleteControlItems(){
        self.childNodeWithName("Control")?.removeFromParent()
        self.currentState = .Running
    }
    
    
    
}
