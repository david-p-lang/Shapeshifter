//
//  Player.swift
//  FlareFit
//
//  Created by David Lang on 8/19/18.
//  Copyright © 2018 David Lang. All rights reserved.
//

import SceneKit
import SpriteKit
import Foundation

class Player : SK3DNode {

    override init(viewportSize: CGSize) {
        super.init(viewportSize: viewportSize)
    
        let scnScene: SCNScene = {
            let scnScene = SCNScene()
            let playerGeometry = SCNSphere(radius: 3.0)
            let playerNode = SCNNode(geometry: playerGeometry)
            playerNode.eulerAngles = SCNVector3(x: Float(CGFloat.pi / 2), y: 0, z: 0)
            let material = playerNode.geometry?.firstMaterial
            material?.lightingModel = SCNMaterial.LightingModel.physicallyBased
            material?.diffuse.contents = UIImage(named: "Art")
            scnScene.rootNode.addChildNode(playerNode)
            return scnScene
        }()
        self.alpha = 1.0
        self.scnScene = scnScene
        self.name = "player"
        self.position = CGPoint(x: 300, y: 100)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
