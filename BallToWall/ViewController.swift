//
//  ViewController.swift
//  BallToWall
//
//  Created by 本多俊之 on 2019/01/14.
//  Copyright © 2019年 da351hon. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // デバッグ用に特徴点を表示
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // ライトを追加
        sceneView.autoenablesDefaultLighting = true
        
        // タップの検出
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:
            #selector(onTapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // 垂直面検出を指定
        configuration.planeDetection = .vertical

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // タップ検出時に呼び出される
    @objc func onTapped(recognizer: UIGestureRecognizer) {
        throwBall()
    }
    
    // 球を投げる
    func throwBall() {
        // カメラ座標が取得できなければ何もしない
        guard let camera = sceneView.pointOfView else { return }

        // ノードの生成
        let sphereNode = SCNNode()
        // ジオメトリ(物体)として球を指定
        sphereNode.geometry = SCNSphere(radius: 0.01)
        sphereNode.geometry?.materials.first?.diffuse.contents = UIColor.yellow
        // カメラから見て10cm先、1cm上の座標に球を配置
        let position = SCNVector3(x: 0, y: 0.01, z: -0.1)
        // ワールド座標系に変換
        let convertedPosition = camera.convertPosition(position, to: nil)
        sphereNode.position = convertedPosition

        // PhysicsBodyの設定
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        sphereNode.physicsBody?.mass = 0.2                  // 質量 0.2kg
        sphereNode.physicsBody?.isAffectedByGravity = true  // 重力の影響を受ける
        
        // 初速を設定
        // カメラから見て上に2m/s、奥に10m/sの初速を設定
        let initialVector = SCNVector3(x: 0, y: 2.0, z: -10.0)
        // ワールド座標系に変換
        let convertedVector = camera.convertVector(initialVector, to: nil)
        sphereNode.physicsBody?.velocity = convertedVector
        
        // ノードを追加
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }

    // MARK: - ARSCNViewDelegate
    
    // 垂直面検出時に呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor:
        ARAnchor) {
        // anchorがARPlaneAnchor以外なら何もしない
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        // ノードを作成
        let planeNode = SCNNode()
        // ジオメトリ(物体)として平面を指定
        planeNode.geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                height: CGFloat(planeAnchor.extent.z))
        // 色を指定
        planeNode.geometry?.materials.first?.diffuse.contents =
            UIColor.cyan.withAlphaComponent(0.3)
        // x軸方向に-90度回転(立てる)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic,
                                               shape: SCNPhysicsShape(geometry: planeNode.geometry!, options: nil))
        
        // 検出されたノードの子要素とする
        node.addChildNode(planeNode)
    }
    
    // 垂直面更新時に呼び出される
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for
        anchor: ARAnchor) {
        // anchorがARPlaneAnchor以外なら何もしない
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        // ジオメトリが平面でなければ何もしない
        guard let planeNode = node.childNodes.first,
            let planeGeometory = planeNode.geometry as? SCNPlane else
        { return }
        
        // ジオメトリを更新
        planeGeometory.width  = CGFloat(planeAnchor.extent.x)
        planeGeometory.height = CGFloat(planeAnchor.extent.z)
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic,
                                               shape: SCNPhysicsShape(geometry: planeGeometory, options: nil))
        planeNode.simdPosition = float3(planeAnchor.center.x, 0,
                                                planeAnchor.center.z)
    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
