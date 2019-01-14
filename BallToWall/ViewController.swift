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
