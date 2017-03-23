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

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        init_view()
        init_scene()
        add_plane()
        add_light()
        init_static_objects()
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
        gmCam.position = SCNVector3Make(0, 5, 15)
        gmScene.rootNode.addChildNode(gmCam)
    }
    
    func init_static_objects()
    {
        let ship_scene = SCNScene(named: "art.scnassets/Avion.scn")
        let canette_scene = SCNScene(named: "art.scnassets/coca_can.scn")
        let ship = ship_scene?.rootNode.childNode(withName: "Avion", recursively: true)!
        let canette = canette_scene?.rootNode.childNode(withName: "canette", recursively: true)!
        let lookat = SCNLookAtConstraint(target: canette)
        
        ship?.position = SCNVector3Make(0, 5, 1)
        canette?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        canette?.name = "canette"
        gmScene.rootNode.addChildNode(ship!)
        gmScene.rootNode.addChildNode(canette!)
        gmCam.constraints = [lookat]
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
        let light2 = SCNNode()

        light.light = SCNLight()
        light.light?.type = SCNLight.LightType.spot
        light.position = SCNVector3Make(0, 80, 40)
        light.eulerAngles = SCNVector3Make(-89, 0, 0)
        light.light?.castsShadow = true
        light2.light = SCNLight()
        light2.light?.type = SCNLight.LightType.directional
        light2.light?.intensity = 300
        light2.position = SCNVector3Make(0, 1, -8)
        light2.eulerAngles = SCNVector3Make(0, 0, 0)
        gmScene.rootNode.addChildNode(light)
        gmScene.rootNode.addChildNode(light2)
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
        let rand = arc4random_uniform(7)

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
            randcolor = UIColor.gray
        }else if rand == 6{
            randcolor = UIColor.orange
        }
        return randcolor
    }
    
    func can_anim(time: TimeInterval)
    {
        let moveTo = SCNAction.move(to: SCNVector3Make(0, 15, -8), duration: 2)
        let moveTo2 = SCNAction.move(to: SCNVector3Make(0, 3, -8), duration: 0.5)
    
        for node in gmScene.rootNode.childNodes
        {
            if node.name == "canette"
            {
                let canette2 = node
                
                let tmp = time.truncatingRemainder(dividingBy: 8)
                if (tmp < 5){
                    canette2.runAction(moveTo)
                }else if (tmp >= 5){
                    canette2.runAction(moveTo2)
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        if time > t
        {
            add_objects()
            t = time + 0.015
            cleanup()
        }
        can_anim(time: time)
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
