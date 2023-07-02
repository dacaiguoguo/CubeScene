//
//  SwiftUIView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//


import SwiftUI
import SceneKit

struct ContentView2: View {
    var body: some View {
        SceneKitView2()
            .frame(width: 300, height: 300)
    }
}

struct SceneKitView2: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()

        // 创建一个场景
        let scene = SCNScene()

        // 创建一个立方体节点
        let box2 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "border")!
        material.locksAmbientWithDiffuse = true
        box2.firstMaterial = material;
        let cubeNode = SCNNode(geometry: box2)
        // 设置节点的位置
        cubeNode.position = SCNVector3(x: 0, y: 0, z: 0)

        // 将立方体节点添加到场景的根节点
        scene.rootNode.addChildNode(cubeNode)

        // 设置场景视图的场景
        sceneView.scene = scene

        // 设置场景视图的背景颜色
        sceneView.backgroundColor = UIColor.white

        // 旋转坐标系
        let rotationAngle = 60.0 // 设置旋转角度（以度为单位）
        let rotationRadians = rotationAngle * .pi / 180.0 // 将角度转换为弧度
        let rotation = SCNAction.rotateBy(x: 30.0, y: CGFloat(rotationRadians), z: 0, duration: 0) // 创建旋转动作

        // 应用旋转动作到场景根节点
        scene.rootNode.runAction(rotation)

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // 更新视图
    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
