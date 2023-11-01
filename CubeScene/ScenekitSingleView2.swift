//
//  ScenekitSingleView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/17.
//

import SwiftUI
import SceneKit


extension SCNAction {
    class func rotate(to location: SCNVector3, duration: TimeInterval) -> SCNAction {
         print(location)
        return SCNAction.rotateTo(x: CGFloat(location.x), y: CGFloat(location.y), z: CGFloat(location.z), duration: duration)
//        let rotationVector =  // 绕Y轴旋转45度
//        SCNAction.rotate(toX: CGFloat(location.x), y: CGFloat(location.y), z: CGFloat(location.z), duration: duration)
//        SCNAction.rotate(toAxisAngle: SCNVector4(x: location.x, y: location.y, z: location.z, w: Float.pi / 2), duration: duration)

    }

}

struct ScenekitSingleView2 : UIViewRepresentable {
    let colors:[UIColor]
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
    @Binding var dacai:String
    let dataList:[Matrix3DPoint]

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
        dataList.forEach { item in
            addNode(item)
        }
        // 创建坐标轴节点
        let xAxis = createAxisNode(color: .red, vector: SCNVector4(1, 0, 0, Float.pi/2))
        let yAxis = createAxisNode(color: .green, vector: SCNVector4(0, 1, 0, Float.pi/2))
        let zAxis = createAxisNode(color: .blue, vector: SCNVector4(0, 0, 1, Float.pi/2))

        scene.rootNode.addChildNode(xAxis)
        scene.rootNode.addChildNode(yAxis)
        scene.rootNode.addChildNode(zAxis)

        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        return scnView
    }
    
    func addNode(_ item: Matrix3DPoint) -> Void {
        let countOfRow = item.data.count
        let countOfLayer = item.data.first?.count ?? -1
        let countOfColum = item.data.first?.first?.count ?? -1
        let parNode2 = SCNNode()
        for z in 0..<countOfRow {
            for y in 0..<countOfLayer {
                for x in 0..<countOfColum {
                    // 盒子
                    let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                    let value = item.data[z][y][x];
                    if value == -1 {
                        continue
                    }
                    let boxNode2 = SCNNode()
                    boxNode2.geometry = box2
                    boxNode2.name = "\(value)"
                    // 由于默认y朝向上的，所以要取负值
                    boxNode2.position = SCNVector3Make(Float(x), Float(-y), Float(z))
                    parNode2.addChildNode(boxNode2)
                }
            }
        }
        parNode2.position = item.offset;
        parNode2.name = item.name;
        // 旋转此节点会导致 用手势旋转时有偏轴现象
        // parNode2.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        scene.rootNode.addChildNode(parNode2)
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
        let somd = self.dacai;
        var indexofdacai = 0;
        for (index, number) in dataList.enumerated() {
            if number.name == somd {
                indexofdacai = index;
            }
        }

        let rotateAction =  SCNAction.rotate(to: dataList[indexofdacai].rotationAngle, duration: 0.1)
        let moveAction = SCNAction.move(to: dataList[indexofdacai].offset, duration: 0.1);
        let groupAction = SCNAction.group([moveAction, rotateAction])
        scnView.scene?.rootNode.childNode(withName: somd , recursively: true)?.runAction(groupAction)
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
