//
//  Button.swift
//  ShapeshifterTV


import Foundation
import SpriteKit

protocol ButtonDelegate: class {
    func buttonClicked(sender: Button)
}

class Button: SKSpriteNode {
    
    //weak so that you don't create a strong circular reference with the parent
    weak var delegate: ButtonDelegate!
    var labelText:String = ""
    var isFocusable = true
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        
        super.init(texture: texture, color: color, size: size)
        
        setup()
    }
    
    init(name: String, texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.labelText = name
        let label = SKLabelNode(text: labelText)
        label.fontName = "Helvetica Neue UltraLight"
        label.fontSize = 50
        label.verticalAlignmentMode = .center
        self.focusBehavior = .focusable
        self.setScale(0.9)
        self.alpha = 0.8
        self.addChild(label)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        isUserInteractionEnabled = true
        
    }
    #if os(tvOS)
    override var canBecomeFocused: Bool {
        return isFocusable
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        if context.previouslyFocusedItem === self {
            print("previous focus on \(self.labelText)")
            self.setScale(0.9)
            self.alpha = 0.7

        }
    
        
        if context.nextFocusedItem === self {
            print("next focus on \(self.labelText)")
            self.setScale(1.0)
            self.alpha = 1.0

        }
    }
    
    #endif

    
    #if os(iOS) || os(tvOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.setScale(0.9)
        self.alpha = 1.0
        self.delegate.buttonClicked(sender: self)
        print("touches began")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        setScale(1.0)
        self.alpha = 0.8
    }
    
    //#elif TARGET_OS_TV
    #endif
}
