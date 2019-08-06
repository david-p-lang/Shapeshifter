//  GameViewController.swift
//  FlareFit tvOS
//
//  Created by David Lang on 4/29/18.
//  Copyright © 2018 David Lang. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreBluetooth

var theMonitor = HeartRateLEMonitor()


class GameViewController: UIViewController {
    
    var notification = NotificationCenter.default
    var checkPeripherals:Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        theMonitor.startUpCentralManager()
        notification.addObserver(self, selector: Selector(("findMonitors:")), name: NSNotification.Name(rawValue: "findMonitors"), object: nil)

        
        let scene = GameScene.newGameScene()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    func findMonitors(notification: NSNotification) {
        checkPeripherals = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: Selector(("periphCheck")), userInfo: nil, repeats: true)
    }
    func periphCheck() {
        print("checking periph count")
        var connectedDevices = theMonitor.centralManager.retrieveConnectedPeripherals(withServices: [theMonitor.HeartRateService])

            theMonitor.discoverDevices()
       
        if connectedDevices.count > 0 {
            connectedDevices = theMonitor.centralManager.retrieveConnectedPeripherals(withServices: [theMonitor.HeartRateService])
            print(connectedDevices)
            print(connectedDevices.count)
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            switch press.type {
                case .upArrow:
                    print("Up Arrow")
                case .downArrow:
                    print("Down arrow")
                case .leftArrow:
                    print("Left arrow")
                case .rightArrow:
                    print("Right arrow")
                case .select:
                    print("Select")
                case .menu:
                    print("Menu")
                default: break
            }
        }
    }
    
}

#if os(tvOS)
extension GameViewController {
    
    /// Tell GameViewController that the currently presented SKScene should always be the preferred focus environment
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let scene = (view as? SKView)?.scene {
            return [scene]
        }
        return []
    }
}
#endif
