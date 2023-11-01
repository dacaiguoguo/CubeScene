//
//  ScenekitSingleView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/17.
//

import SwiftUI
import SceneKit


struct ScenekitSingleView2 : UIViewRepresentable {
    let colors:[UIColor] = [UIColor(hex: "000000"),
                           UIColor(hex: "5B5B5B"),
                           UIColor(hex: "C25C1D"),
                           UIColor(hex: "2788e7"),
                           UIColor(hex: "FA2E34"),
                           UIColor(hex: "FB5BC2"),
                           UIColor(hex: "FCC633"),
                           UIColor(hex: "178E20")]
    let scene : SCNScene = {
        let ret = SCNScene();
        // 添加照相机
        let camera = SCNCamera()
        camera.focalLength = 50;
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(-10.5, 7.5, 20)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        ret.rootNode.addChildNode(cameraNode)
        // let env = UIImage(named: "dijon_notre_dame.jpg")
        ret.background.contents = UIColor(hex: "00bfff");
        return ret;
    } ()


    @Binding var nodeList: [SCNNode]

    // 创建坐标轴节点的函数
    func createAxisNode(color: UIColor, vector: SCNVector4) -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.05, height: 10)
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
    

    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene?.rootNode.childNodes.forEach({ node in
            node.childNodes.forEach { subNode in
                if let nodename = subNode.name, let value = Int(nodename) {
                    subNode.geometry?.firstMaterial?.diffuse.contents =  colors[value];
                } else {
                    subNode.geometry?.firstMaterial?.diffuse.contents =  UIColor.blue;
                }
            }
        })
    }
}

struct ScenekitSingleView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScenekitSingleView(dataModel:EnterItem(name: "测试", matrix: [[[2,4,3], [6,4,1], [6,6,1]],
                                                                        [[2,3,3], [6,4,1], [7,4,5]],
                                                                        [[2,2,3], [7,5,5], [7,7,5]]],
                                                   isTaskComplete: true),
                               colors: [UIColor(hex: "000000"),
                                        UIColor(hex: "5B5B5B"),
                                        UIColor(hex: "C25C1D"),
                                        UIColor(hex: "2788e7"),
                                        UIColor(hex: "FA2E34"),
                                        UIColor(hex: "FB5BC2"),
                                        UIColor(hex: "FCC633"),
                                        UIColor(hex: "178E20")],
                               numberImageList: getTextImageList())
            .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("iPhone SE")
        
    }
}
