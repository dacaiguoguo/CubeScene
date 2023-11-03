//
//  ScenekitSingleView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/17.
//

import SwiftUI
import SceneKit


struct ScenekitSingleView2 : UIViewRepresentable {

    let scene : SCNScene = {
        let ret = SCNScene();
        // 添加照相机
        let camera = SCNCamera()
        camera.focalLength = 30;
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(-10.5, 7.5, 20)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        ret.rootNode.addChildNode(cameraNode)

//        // 创建地面
//        let groundGeometry = SCNBox.init(width: 10, height: 10, length: 1, chamferRadius: 0.05)
//        let groundNode = SCNNode(geometry: groundGeometry)
//        groundNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi * 3 / 2)
//        groundNode.position = SCNVector3Make(0, -1, 0)
//        ret.rootNode.addChildNode(groundNode)
//
//        // 设置地面材质
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.lightGray
////        Image(uiImage: UIImage(named: "wenli5")!)
////            .resizable(resizingMode: .tile)
//        groundGeometry.firstMaterial = material

        // let env = UIImage(named: "dijon_notre_dame.jpg")
        ret.background.contents = UIColor(hex: "00bfff");
        return ret;
    } ()


    @Binding var nodeList: [SCNNode]

    // 创建坐标轴节点的函数
    func createAxisNode(color: UIColor, vector: SCNVector4) -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.01, height: 100)
        cylinder.firstMaterial?.diffuse.contents = color

        let axisNode = SCNNode(geometry: cylinder)
        axisNode.rotation = vector;
        axisNode.position = SCNVector3Zero
        return axisNode
    }

    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()

        // 创建坐标轴节点
        let xAxis = createAxisNode(color: .red, vector: SCNVector4(1, 0, 0, Float.pi/2))
        let yAxis = createAxisNode(color: .green, vector: SCNVector4(0, 1, 0, Float.pi/2))
        let zAxis = createAxisNode(color: .blue, vector: SCNVector4(0, 0, 1, Float.pi/2))

        scene.rootNode.addChildNode(xAxis)
        scene.rootNode.addChildNode(yAxis)
        scene.rootNode.addChildNode(zAxis)

        nodeList.forEach { item in
            scene.rootNode.addChildNode(item)
        }
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        
        return scnView
    }
    

    func updateUIView(_ scnView: SCNView, context: Context) {}
}

struct ScenekitSingleView2_Previews: PreviewProvider {
    static private var nodeList:[SCNNode] = []

    static var previews: some View {
        NavigationView {
            ScenekitSingleView2(nodeList: .constant(nodeList))
            .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("iPhone SE")
        
    }
}
