//
//  ContentView.swift
//  Route4
//
//  Created by yanguo sun on 2023/11/1.
//

import SwiftUI

import SwiftUI
import SceneKit


struct ContentView: View {
    @State private var node:[SCNNode] = {
        let box = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        // 创建6种不同颜色的材质
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .orange, .purple]
        var materials: [SCNMaterial] = []

        for color in colors {
            let material = SCNMaterial()
            material.diffuse.contents = color
            materials.append(material)
        }

        // 将材质分配给SCNBox的各个面
        box.materials = materials

        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3Make(-2, 0, 0)
        boxNode.name = "boxNode";
        let box2 = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        // 将材质分配给SCNBox的各个面
        box2.materials = materials
        let boxNode2 = SCNNode(geometry: box2)
        boxNode2.position = SCNVector3Make(2, 0, 0)
        boxNode2.name = "boxNode2";


        return [boxNode, boxNode2]
    }()
    

    var body: some View {
        VStack {
            SceneKitView(nodeList: $node)
                .frame(width: 300, height: 300)
            HStack {
                Button("Rotate X") {
                    let rotationAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(1, 0, 0), duration: 0.2)
                    node.filter({ node in
                        node.name == "boxNode"
                    }).first?.runAction(rotationAction)
                }
                Button("Rotate Y") {
                    let rotationAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 1, 0), duration: 0.2)
                    node.filter({ node in
                        node.name == "boxNode2"
                    }).first?.runAction(rotationAction)
                }
                Button("Rotate Z") {
                    let rotationAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 0, 1), duration: 0.2)
                    node.filter({ node in
                        node.name == "boxNode"
                    }).first?.runAction(rotationAction)
                }
            }
        }
    }
}

struct SceneKitView: UIViewRepresentable {
    @Binding var nodeList: [SCNNode]

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let scene = SCNScene()
        scene.background.contents = UIColor(hex: "00bfff");
        let camera = SCNCamera()
        camera.focalLength = 50;
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(-10.5, 7.5, 20)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        nodeList.forEach { item in
            scene.rootNode.addChildNode(item);
        }
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        print("updateUIView")
    }
}

//struct ContentView: View {
//
//
//    @State var rotationTransform:SCNMatrix4 = SCNMatrix4Identity
//
//
//    var body: some View {
//        VStack {
//            // 在SwiftUI视图中嵌套SceneKit视图
//            SceneKitView(xRotation: rotationTransform)
//                .frame(width: 300, height: 300)
//
//            HStack {
//                Button("X") {
//                    rotationTransform = SCNMatrix4Mult(SCNMatrix4MakeRotation(.pi / 2, 1, 0, 0), rotationTransform)
//                }
//                Button("Y") {
//                    rotationTransform = SCNMatrix4Mult(SCNMatrix4MakeRotation(.pi / 2, 0, 1, 0), rotationTransform)
//                }
//                Button("Z") {
//                    rotationTransform = SCNMatrix4Mult(SCNMatrix4MakeRotation(.pi / 2, 0, 0, 1), rotationTransform)
//                }
//            }
//        }
//    }
//}
//
//
//
//struct SceneKitView: UIViewRepresentable {
//
//    let xRotation: SCNMatrix4
//    func makeUIView(context: Context) -> SCNView {
//        let sceneView = SCNView()
//
//        let scene = SCNScene()
//        scene.background.contents = UIColor(hex: "00bfff");
//        let camera = SCNCamera()
//        camera.focalLength = 50;
//        let cameraNode = SCNNode()
//        cameraNode.camera = camera
//        cameraNode.position = SCNVector3Make(-10.5, 7.5, 20)
//        cameraNode.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
//        scene.rootNode.addChildNode(cameraNode)
//        let box = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
//        // 创建6种不同颜色的材质
//        let colors: [UIColor] = [.red, .green, .blue, .yellow, .orange, .purple]
//        var materials: [SCNMaterial] = []
//
//        for color in colors {
//            let material = SCNMaterial()
//            material.diffuse.contents = color
//            materials.append(material)
//        }
//
//        // 将材质分配给SCNBox的各个面
//        box.materials = materials
//        let boxNode = SCNNode(geometry: box)
//
//        boxNode.name = "boxNode"
//
//        scene.rootNode.addChildNode(boxNode)
//        sceneView.scene = scene
//        sceneView.autoenablesDefaultLighting = true
//        sceneView.allowsCameraControl = true
//        return sceneView
//    }
//
//    func updateUIView(_ uiView: SCNView, context: Context) {
//        // 更新视图
//
//        // 使用四元数创建旋转变换
//        if let node = uiView.scene?.rootNode.childNode(withName: "boxNode", recursively: true) {
////            node.rotation = xRotation
//            // 创建一个绕X轴旋转90度的四元数
//
//            // 将旋转四元数应用于节点的当前旋转
////            node.simdOrientation = simd_mul(node.simdOrientation, xRotation)
//// 创建一个绕X轴旋转90度的旋转变换
//
//            // 将旋转变换应用于节点的当前变换
////            node.transform = xRotation
//            let rotationAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 1, 0), duration: 1.0)
//            node.runAction(rotationAction)
//
//
//        }
//
//
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIColor {
    public convenience init(hex: String) {
        let r, g, b, a: CGFloat
        let hex2 = "#\(hex)ff"
        let start = hex2.index(hex2.startIndex, offsetBy: 1)
        let hexColor = String(hex2[start...])

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255

                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }

        self.init(red: 0, green: 0, blue: 0, alpha: 1)
        return
    }
}
