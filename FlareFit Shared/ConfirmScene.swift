//
//  ConfirmScene.swift
//  FlareFit iOS
//
//  Created by David Lang on 4/30/18.
//  Copyright © 2018 David Lang. All rights reserved.
//

//import Foundation
//import SpriteKit
//import SceneKit
//import MapKit
//
//class ConfirmScene: SKScene {
//    
//    var playButton: SKNode! = nil
//    var checkMonitorLabel: SKNode! = nil
//
//    var buttonWidth: CGFloat!
//    var buttonHeight: CGFloat!
//    
//    var mapContainerView: UIView!
//    var mapView: MKMapView!
//    
//    private let locationManager = LocationManager.shared
//    private var seconds = 0
//    private var timer: Timer?
//    private var distance = Measurement(value: 0, unit: UnitLength.meters)
//    private var locationList: [CLLocation] = []
//
//    
//    
//    override func didMove(to view: SKView) {
//        buttonWidth = self.frame.width/0.2
//        buttonHeight = self.frame.height/7
//        
//    
//        
//        backgroundColor = SKColor.black
//        
//        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.frame.maxX, height: 400))
//                mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5031135, -6.572772100000066), MKCoordinateSpanMake(0.05, 0.05)), animated: true)
//        mapView.delegate = self
//        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.5031135, -6.572772100000066), MKCoordinateSpanMake(0.05, 0.05)), animated: true)
//
//        self.view?.addSubview(mapView)
//        mapView.layer.zPosition = -1
//        
//        var hudWindow : SKView = SKView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        
//        displayPlayer()
//        
//        playButton = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: buttonWidth , height: buttonHeight))
//        playButton.position = CGPoint(x:self.frame.midX, y:self.frame.midY-buttonHeight)
//        playButton.alpha = 0.9
//        playButton.zPosition = 100
//        
//        self.addChild(playButton)
//        let playLabel = SKLabelNode(text: "Start Run")
//        playLabel.fontName = "Helvetica Neue UltraLight"
//        playLabel.fontSize = 30
//        playButton.addChild(playLabel)
//        view.layer.zPosition = 0
//    }
//    
//    func displayPlayer() {
//        let scnScene: SCNScene = {
//            let scnScene = SCNScene()
//            
//            let pyramidGeometry = SCNPyramid(width: 0.15, height: 0.13, length: 0.17)
//            pyramidGeometry.firstMaterial?.diffuse.contents = UIColor.magenta
//            pyramidGeometry.firstMaterial?.reflective.contents = 0.2
//            pyramidGeometry.firstMaterial?.transparency = 0.07
//            let pyramidNode = SCNNode(geometry: pyramidGeometry)
//            
//            let iUPyramidGeometry = SCNPyramid(width: 0.07, height: 0.07, length: 0.07)
//            iUPyramidGeometry.firstMaterial?.diffuse.contents = UIColor.red
//            iUPyramidGeometry.firstMaterial?.reflective.contents = 1
//            iUPyramidGeometry.firstMaterial?.transparency = 0.1
//            let iUPyramidNode = SCNNode(geometry: iUPyramidGeometry)
//            
//            pyramidNode.addChildNode(iUPyramidNode)
//            scnScene.rootNode.addChildNode(pyramidNode)
//            
//            return scnScene
//        }()
//        
//        let node = SK3DNode(viewportSize: CGSize(width: self.size.width / 4, height: self.size.width / 4))
//        node.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//        node.scnScene = scnScene
//        node.zPosition = 100
//        self.addChild(node)
//    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            let location = t.location(in: self)
//            if playButton.contains(location) {
//                print("play button moved")
//                displayPlayer()
//            }
//        }
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//    }
//}
//
//extension ConfirmScene: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        for newLocation in locations {
//            let howRecent = newLocation.timestamp.timeIntervalSinceNow
//            guard newLocation.horizontalAccuracy < 15 && abs(howRecent) < 10 else { continue }
//            if let lastLocation = locationList.last {
//                let delta = newLocation.distance(from: lastLocation)
//                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
//                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
//                mapView.add(MKPolyline(coordinates: coordinates, count: 2))
//                let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500, 500)
//                mapView.setRegion(region, animated: true)
//            }
//            locationList.append(newLocation)
//        }
//    }
//}
//
//extension ConfirmScene: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        guard let polyline = overlay as? MKPolyline else {
//            return MKOverlayRenderer(overlay: overlay)
//        }
//        let renderer = MKPolylineRenderer(polyline: polyline)
//        renderer.strokeColor = .blue
//        renderer.lineWidth = 3
//        return renderer
//    }
//}
