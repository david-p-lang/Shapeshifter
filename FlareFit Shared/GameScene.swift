//
//  GameScene.swift
//  FlareFit Shared
//
//  Created by David Lang on 4/29/18.
//  Copyright © 2018 David Lang. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, ButtonDelegate{
    
    func buttonClicked(sender: Button) {
        if let name = sender.name {
            print("you clicked the button named...\(name)")
        }
    }
    
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?
    
    var playButton: Button!
    var optionsButton: Button!
    var creditsButton: Button!
    
    var buttonWidth: CGFloat!
    var buttonHeight: CGFloat!


    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        buttonWidth = self.frame.width/3
        buttonHeight = self.frame.height/12
        
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
            label.focusBehavior = .none
        }
        playButton = Button(name: "Start", texture: nil, color: SKColor.blue, size: CGSize(width: buttonWidth , height: buttonHeight))
        playButton.position = CGPoint(x:self.frame.midX, y:self.frame.midY-buttonHeight)
        playButton.delegate = self
        self.addChild(playButton)
        
        optionsButton = Button(name: "Options", texture: nil, color: SKColor.blue, size: CGSize(width: buttonWidth , height: buttonHeight))
        optionsButton.position = CGPoint(x:self.frame.midX, y:self.frame.midY-(buttonHeight * 2+2))
        optionsButton.delegate = self
        self.addChild(optionsButton)

        
        creditsButton = Button(name: "Credits", texture: nil, color: SKColor.blue, size: CGSize(width: buttonWidth , height: buttonHeight))
        creditsButton.position = CGPoint(x:self.frame.midX, y:self.frame.midY-(buttonHeight * 3+4))
        self.addChild(creditsButton)



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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GameScene.tap))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)];
        self.view?.addGestureRecognizer(tapRecognizer)
        
    }
    @objc func tap() {
        print("tapped")
        if playButton.isFocused {
            self.view?.presentScene(PlayScene(size: self.size))
            print("start button was focused and selected")

        } else if optionsButton.isFocused {
            print("options button focused and selected")
        }
    }
    
    func startPlay() {
        print("start play?")
        let scene:SKScene = PlayScene(size: self.size)
        self.view?.presentScene(scene)
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scale = SKAction.scaleX(to: 1.1, duration: 0.5)

        for t in touches {
            let location = t.location(in: self)
            print(location)
            if playButton.contains(location) {
                print("play button t-begin")
                playButton.run(scale)
                startPlay()
                
            } else if (optionsButton.contains(location)){
                print("options")
            } else if (creditsButton.contains(location)) {
                print("credits")
            }
        }
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches {
            let location = t.location(in: self)
            if playButton.contains(location) {
                print("play button moved")
            } else if (optionsButton.contains(location)){
                
            } else if (creditsButton.contains(location)) {
                
            }
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scale = SKAction.scaleX(to: 1, duration: 0)

        for t in touches {
            let location = t.location(in: self)
            if playButton.contains(location) {
                print("play button tap")
                playButton.run(scale)
                let scene:SKScene = PlayScene(size: self.size)
                self.view?.presentScene(scene)

            } else if (optionsButton.contains(location)){
                print("options button tap")

            } else if (creditsButton.contains(location)) {
                print("credits button tap")

            }
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scale = SKAction.scale(to: 1, duration: 0)

        for t in touches {
            let location = t.location(in: self)
            if playButton.contains(location) {
                print("play button cancelled")
                playButton.run(scale)
      
            }
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(tvOS)
extension GameScene {
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [playButton, optionsButton, creditsButton]
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

