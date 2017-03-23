//
//  GameViewController.swift
//  3D_sckit
//
//  Created by jdavin on 3/19/17.
//  Copyright © 2017 jdavin. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var gmView:SCNView!
    var gmScene:SCNScene!
    var gmCam:SCNNode!
    var t:TimeInterval = 0
    var t1:TimeInterval = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        init_view()
        init_scene()
        add_plane()
        add_light()
    }

    func init_view()
    {
        gmView = self.view as! SCNView
        gmView.allowsCameraControl = true
        gmView.autoenablesDefaultLighting = false
        gmView.delegate = self
        gmView.showsStatistics = true
    }
    
    func init_scene()
    {
        gmScene = SCNScene()
        gmView.scene = gmScene
        gmView.isPlaying = true
        gmCam = SCNNode()
        gmCam.camera = SCNCamera()
        gmCam.position = SCNVector3Make(0, 10, 20)
        gmScene.rootNode.addChildNode(gmCam)
        let ship_scene = SCNScene(named: "art.scnassets/smooth_sship.scn")
        let ship = ship_scene?.rootNode.childNode(withName: "ship", recursively: true)!
        let canette_scene = SCNScene(named: "art.scnassets/canette.scn")
        let canette = canette_scene?.rootNode.childNode(withName: "canette", recursively: true)!
        ship?.position = SCNVector3Make(0, 6, -1)
        canette?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        gmScene.rootNode.addChildNode(ship!)
        gmScene.rootNode.addChildNode(canette!)
    }
    
    func add_plane()
    {
        let sol:SCNGeometry = SCNFloor()
        let solNode = SCNNode(geometry: sol)
    
        sol.materials.first?.diffuse.contents = UIColor.orange
        solNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        gmScene.rootNode.addChildNode(solNode)
    }
    
    func add_light()
    {
        let light = SCNNode()

        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.spot
        light.position = SCNVector3Make(0, 40, 20)
        light.eulerAngles = SCNVector3Make(-89, 0, 0)
        light.light?.castsShadow = true
        gmScene.rootNode.addChildNode(light)
    }
    
    func add_objects()
    {
        let obj:SCNGeometry = rand_shape()
        let randcolor = rand_color()
        let objNode = SCNNode(geometry: obj)
        let force = SCNVector3(0, 0, -14)
        
        obj.materials.first?.diffuse.contents = randcolor
        obj.materials.first?.specular.contents = UIColor.white
        objNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        objNode.position = SCNVector3Make(0, 5, -3)
        gmScene.rootNode.addChildNode(objNode)
        objNode.physicsBody?.applyForce(force, at: SCNVector3(0, 0.0, 0.0), asImpulse: true)
        objNode.physicsBody?.isAffectedByGravity = false
    }
    
    func rand_shape() -> SCNGeometry
    {
        let i = arc4random_uniform(5)
        var obj = SCNGeometry()

        if i == 0{
            obj = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        }else if i == 1{
            obj = SCNPyramid(width: 1, height: 1, length: 1)
        }else if i == 2{
            obj = SCNPyramid(width: 1, height: 1, length: 1)
        }else if i == 3{
            obj = SCNSphere(radius: 0.5)
        }else if i == 4{
            obj = SCNCylinder(radius: 0.5, height: 1)
        }
        return obj
    }
    
    func rand_color() -> UIColor
    {
        var randcolor:UIColor!
        let rand = arc4random_uniform(10)

        if rand == 0{
            randcolor = UIColor.clear
        }else if rand == 1{
            randcolor = UIColor.orange
        }else if rand == 2{
            randcolor = UIColor.green
        }else if rand == 3{
            randcolor = UIColor.red
        }else if rand == 4{
            randcolor = UIColor.yellow
        }else if rand == 5{
            randcolor = UIColor.black
        }else if rand == 6{
            randcolor = UIColor.white
        }else if rand == 7{
            randcolor = UIColor.gray
        }else if rand == 8{
            randcolor = UIColor.cyan
        }else if rand == 9{
            randcolor = UIColor.orange
        }
        return randcolor
    }
    
    func add_canette(time: TimeInterval)
    {
        if (time > t1)
        {
            let canette_scene = SCNScene(named: "art.scnassets/canette.scn")
            let canette = canette_scene?.rootNode.childNode(withName: "canette", recursively: true)!
            canette?.position = SCNVector3Make(0, 20, -8)
            t1 = time + 10;
            canette?.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            canette?.physicsBody?.mass = 3.5;
            gmScene.rootNode.addChildNode(canette!)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        if time > t
        {
            add_objects()
            t = time + 0.01
            cleanup()
        }
        add_canette(time: time)
    }
    
    func cleanup()
    {
        for node in gmScene.rootNode.childNodes
        {
            if node.presentation.position.z < -25
            {
                node.removeFromParentNode()
            }
        }
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .allButUpsideDown
        }
        else
        {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
