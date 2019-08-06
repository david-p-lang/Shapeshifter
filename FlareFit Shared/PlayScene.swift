//
//  StartScene.swift
//  ShapeshifterTV
//
//  Created by David Lang on 8/5/18.
//  Copyright © 2018 David Lang. All rights reserved.
//

import SpriteKit
import SceneKit
import AVFoundation

class PlayScene : SKScene, ButtonDelegate, SKPhysicsContactDelegate {

    var button = Button()
    var heartrateLabel : SKLabelNode = SKLabelNode()
    var hrTimer:Timer!
    var numberPowerPacks:Int = 0
    var powerRack = [PowerPack]()
    var baseHeartrate = 0
    var testHeartRate = 0
    var currentHeartRate = theMonitor.currentHeartRate
    var blockSpeedFactor:CGFloat = 3.5
    var blockSpawnTime = 1.8
    
    var beebSoundEffect: AVAudioPlayer?
    var beepUrl:URL!

    enum GamePhase {
        case build
        case play
        case rest
    }
    
    var gamePhase = GamePhase.build
   
    var block:SKNode!
    var moving:SKNode!
    var blocks:SKNode!
    var cycleBlocks:SKAction!
    var pNode = SK3DNode()
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?
    
    struct CollisionCategory {
            static let world: UInt32 = 1 << 0
            static let player: UInt32 = 1 << 1
            static let block: UInt32 = 1 << 2
            static let wall: UInt32 = 1 << 3

    }
    
    class func newScene() -> PlayScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "PlayScene") as? PlayScene else {
            print("Failed to load PlayScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(PlayScene.rightSwipe))
        rightSwipeRecognizer.direction = .right
        self.view?.addGestureRecognizer(rightSwipeRecognizer)

        let upSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(PlayScene.upSwipe))
        upSwipeRecognizer.direction = .up
        self.view?.addGestureRecognizer(upSwipeRecognizer)
        
        let downSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(PlayScene.downSwipe))
        downSwipeRecognizer.direction = .down
        self.view?.addGestureRecognizer(downSwipeRecognizer)
        
        setUpScene()
        
        let bPath = Bundle.main.path(forResource: "beep", ofType:"mid")!
        beepUrl = URL(fileURLWithPath: bPath)
        
    }

    func buildBlocks() {
        block = SKNode()
        if let viewBounds = self.view?.bounds {
            let blockY = Int.random(in: 50...Int(viewBounds.height - 50.0))
            block.position = CGPoint( x: viewBounds.width + 50, y: CGFloat(blockY))
        }
        block.zPosition = -5
        
        let height = UInt32(self.frame.size.height / 1.3)
        let y = CGFloat(arc4random_uniform(height))
        
        let blockSprite = SKSpriteNode(texture: nil, color: SKColor.cyan, size: CGSize(width: 75, height: 75))
        blockSprite.setScale(2.0)
        blockSprite.name = "block"
        blockSprite.position = CGPoint(x: 0.0, y: blockSprite.size.height)
        
        blockSprite.physicsBody = SKPhysicsBody(rectangleOf: blockSprite.size)
        blockSprite.physicsBody?.isDynamic = true
        blockSprite.physicsBody?.categoryBitMask = CollisionCategory.block
        blockSprite.physicsBody?.contactTestBitMask = CollisionCategory.player
        block.addChild(blockSprite)
        self.addChild(block)
        block.run(cycleBlocks)
    }
    
    @objc func updateHR() {
       // heartrateLabel.text = String(theMonitor.currentHeartRate)
        heartrateLabel.text = String(testHeartRate)
        testHeartRate = testHeartRate + 1
        currentHeartRate = testHeartRate
      
        // if current heart rate is lower than baseline reset baseHeartrate
        
        if  currentHeartRate < baseHeartrate {
            baseHeartrate = currentHeartRate
        }
        print("number powerpacks \(numberPowerPacks) -- baseheartrate \(baseHeartrate) -- currentHeartRate \(currentHeartRate)-- GamePhase \(gamePhase)")
        if gamePhase == GamePhase.build && numberPowerPacks < 20 {
        numberPowerPacks = currentHeartRate - baseHeartrate
        // Needs sound, animation
            
        for i in 0...19 {
            if i <= numberPowerPacks {
                    powerRack[i].setPower(isOn: true)
                    playBeep()
                } else {
                    powerRack[i].setPower(isOn: false)

                }
            }
            
        } else if gamePhase == GamePhase.build && numberPowerPacks >= 20 {
            gamePhase = GamePhase.play
            startPlay()
        }

    }
    func startPlay() {
        
        print("play mode")
        self.physicsWorld.gravity = CGVector( dx: 0.0, dy: 0.0 )
        let distanceToMove = CGFloat((self.view?.bounds.width)! * blockSpeedFactor)
        let moveBlocks = SKAction.moveBy(x: -distanceToMove - 100, y:0.0, duration:TimeInterval(0.005 * distanceToMove))
        let removeBlocks = SKAction.removeFromParent()
        cycleBlocks = SKAction.sequence([moveBlocks, removeBlocks])
        
        let build = SKAction.run(buildBlocks)
        let buildInterval = SKAction.wait(forDuration: TimeInterval(blockSpawnTime))
        let buildSequence = SKAction.sequence([build, buildInterval])
        let buildRepeat = SKAction.repeatForever(buildSequence)
        self.run(buildRepeat)
    }
    
    func setUpScene() {
        self.physicsWorld.gravity = CGVector( dx: 0.0, dy: 0.0 )
        self.physicsWorld.contactDelegate = self
        scene?.size = (self.view?.bounds.size)!
        
        // TODO update wall with SK3DNode
//        let wallColor = SKColor(red: 192.0/255.0, green: 5.0/255.0, blue: 120.0/255.0, alpha: 1.0)
//        self.backgroundColor = wallColor
//
//
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [UIColor.red.cgColor,
//                                UIColor.yellow.cgColor,
//                                UIColor.green.cgColor,
//                                UIColor.blue.cgColor]
//
//        gradientLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
     
        moving = SKNode()
        self.addChild(moving)
        blocks = SKNode()
        moving.addChild(blocks)
        
        heartrateLabel.text = "HR"
        if let viewBounds = view?.bounds {
            heartrateLabel.position = CGPoint(x: 100 + heartrateLabel.frame.maxX, y: (viewBounds.height) - heartrateLabel.frame.maxY * 6)
            heartrateLabel.color = SKColor.magenta
            addChild(heartrateLabel)
            
            let size = CGSize(width: (self.view?.bounds.width)!,height: (self.view?.bounds.height)!)
            UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
            let context = UIGraphicsGetCurrentContext()
            
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.blue.cgColor,
                               UIColor.cyan.cgColor,
                               UIColor.blue.cgColor]
        
            gradient.frame = CGRect(origin: CGPoint(x: viewBounds.width, y: viewBounds.height), size: size)
            gradient.render(in: context!)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let texture = SKTexture(image:image!)
            let node = SKSpriteNode(texture:texture)
            node.anchorPoint = CGPoint(x: 0, y: 0)
            node.zPosition = -10.0
            self.addChild(node)
            
            let edge = SKPhysicsBody(edgeLoopFrom: scene!.frame)
            edge.categoryBitMask = CollisionCategory.wall
            edge.contactTestBitMask = CollisionCategory.player
            edge.collisionBitMask = CollisionCategory.player
        }
        
        //Set the baseline heart rate from the HRLEMonitor
        //baseHeartrate = theMonitor.currentHeartRate
        baseHeartrate = testHeartRate
        
//        let scnScene: SCNScene = {
//            let scnScene = SCNScene()
//            let playerGeometry = SCNSphere(radius: 3.0)
//            let playerNode = SCNNode(geometry: playerGeometry)
//            playerNode.eulerAngles = SCNVector3(x: Float(CGFloat.pi / 2), y: 0, z: 0)
//            let material = playerNode.geometry?.firstMaterial
//            material?.lightingModel = SCNMaterial.LightingModel.physicallyBased
//            material?.diffuse.contents = UIImage(named: "Art")
//            scnScene.rootNode.addChildNode(playerNode)
//            return scnScene
//        }()
        
        pNode = Player(viewportSize: CGSize(width: 150, height: 100))
        
//
//        pNode.alpha = 1.0
//        pNode.scnScene = Player()
//        pNode.name = "player"
//        pNode.position = CGPoint(x: 300, y: 100)
        
        self.addChild(pNode)
        
        pNode.physicsBody = SKPhysicsBody(circleOfRadius: pNode.frame.height / 2.0)
        pNode.physicsBody?.isDynamic = true
        pNode.physicsBody?.allowsRotation = false
        pNode.physicsBody?.usesPreciseCollisionDetection = true
        pNode.physicsBody?.categoryBitMask = CollisionCategory.player
        pNode.physicsBody?.collisionBitMask = CollisionCategory.world | CollisionCategory.block | CollisionCategory.wall
        pNode.physicsBody?.contactTestBitMask = CollisionCategory.world | CollisionCategory.block | CollisionCategory.wall
        
        for i in 1...20 {
            var powerPack = PowerPack(number: i, texture: nil, color: SKColor.white, size: CGSize(width: 90, height: 40))
            powerPack.position = CGPoint(x: 10 + powerPack.frame.maxX, y: (50 * CGFloat(i)))
            if powerRack.count < 21 && gamePhase == GamePhase.build {
                powerRack.append(powerPack)

            }
            self.addChild(powerPack)
        }
        

        hrTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateHR), userInfo: nil, repeats: true)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
            // For watch we just periodically create one of these and let it spin
            // For other platforms we let user touch/mouse events create these
            spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
            spinnyNode.strokeColor = SKColor.red
            self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                               SKAction.run({
                                                                let n = spinnyNode.copy() as! SKShapeNode
                                                                self.addChild(n)
                                                               })])))
            #endif
        }
    }
    
    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    @objc func rightSwipe() {
        print("right swipe")
        pNode.physicsBody?.applyImpulse(CGVector(dx: 40, dy: 0.0))
        numberPowerPacks = numberPowerPacks - 1
        powerRack[numberPowerPacks].setPower(isOn: false)
    }
    
    @objc func upSwipe() {
        print("up swipe")
        pNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 125.0))
        
    }
    
    @objc func downSwipe() {
        print("down swipe")
        pNode.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: -125.0))

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if moving.speed > 0  {
            for _ in touches { // do we need all touches?
                //pNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                //pNode.physicsBody?.applyImpulse(CGVector(dx: 0.1, dy: 200))
                print("Event \(String(describing: event))")
                
            }
        } //else if canRestart {
          //  self.resetScene()
        //}
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gamePhase == GamePhase.build {
            
        } else if gamePhase == GamePhase.play {
            
        }
    }
    
    func buttonClicked(sender: Button) {
        print("you clicked the button named \(sender.name!)")

    }
    

    
    func didBegin(_ contact: SKPhysicsContact) {
        print("did begin contact")
        if let bodyAName = contact.bodyA.node?.name {
            if bodyAName == "block" {
                contact.bodyA.node?.removeFromParent()
                playBeep()
                print("beep")
            }
            
        }
        if let bodyBName = contact.bodyB.node?.name {
            if bodyBName == "block" {
                contact.bodyB.node?.removeFromParent()
            }
        }
        
        print(" contact - Contact BodyA \(contact.bodyA.node?.name ?? "none") Contact BodyB \(contact.bodyB.node?.name ?? "none")")
    }
    
    func playBeep() {
        run(SKAction.playSoundFileNamed("beep.mp3", waitForCompletion: false))
        //        let url = Bundle.main.url(forResource: "beep", withExtension: "mid")!
//
//        do {
//            beebSoundEffect = try AVAudioPlayer(contentsOf: url)
//            //guard let bplayer = player else { return }
//
//            beebSoundEffect?.prepareToPlay()
//            beebSoundEffect?.play()
//        } catch let error as NSError {
//            print(error.description)
//        }
    }
    

}

class PowerPack:SKSpriteNode {
    var isPowered = false
    var number = 0
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    init(number: Int,texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.color = color
        self.size = size
        self.number = number
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPower (isOn: Bool) {
        self.isPowered = isOn
        if isOn == true {
            self.color = SKColor.magenta
            self.alpha = 1.0
        } else {
            self.color = SKColor.magenta
            self.alpha = 0.5
        }
    }
}
