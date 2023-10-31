//
//  ScenekitSingleView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/17.
//

import SwiftUI
import SceneKit


struct ScenekitSingleView2 : UIViewRepresentable {
    private let dataModel: EnterItem
    private let showType:ShowType;
    private let colors:[UIColor]
    private let numberImageList: [UIImage]
    private let showColor:[Int]
    private let scene : SCNScene
    
    
    struct Matrix3DPoint {
        let data: Matrix3D
        let pos: SCNVector3
    }
    
    var dataItemlist:[Matrix3DPoint] = [ Matrix3DPoint(data: [[[2,-1,-1],],
                                                              [[2,-1,-1], ],
                                                              [[2,2,-1],  ]], pos: SCNVector3(-2, 0, -5)),
                                         Matrix3DPoint(data: [[[1,-1,-1],],
                                                              [[1,1,-1], ],
                                                              [[-1,-1,-1],]], pos: SCNVector3(2, 0, -5))];
    
    private var imageName:String {
        dataModel.name
    }
    private var dataItem: Matrix3D {
        dataModel.matrix
    }
    
    init(dataModel: EnterItem, showType: ShowType = .singleColor, colors: [UIColor], numberImageList: [UIImage], showColor: [Int] = [], focalLength: CGFloat = 110) {
        self.dataModel = dataModel
        self.showType = showType
        self.colors = colors
        self.numberImageList = numberImageList
        self.showColor = showColor
        let ret = SCNScene();
        // 添加照相机
        let camera = SCNCamera()
        camera.focalLength = focalLength;
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(-10.5, 7.5, 20)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        ret.rootNode.addChildNode(cameraNode)
        let env = UIImage(named: "dijon_notre_dame.jpg")
        ret.background.contents = UIColor(hex: "00bfff");
        self.scene = ret
    }
    
    
    func makeUIView(context: Context) -> SCNView {
        // retrieve the SCNView
        let scnView = SCNView()
        
        dataItemlist.forEach { item in
            addNode(item)
        }
        
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.backgroundColor = .clear
        
        
//        // 添加点击手势
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
//        scnView.addGestureRecognizer(tapGesture)
//        // 添加上下手势识别器
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.panGestureHandler(_:)))
//        scnView.addGestureRecognizer(panGesture)
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
        parNode2.position = item.pos; // SCNVector3Make(Float(-1), Float(1), Float(1))
        // 旋转此节点会导致 用手势旋转时有偏轴现象
        // parNode2.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        scene.rootNode.addChildNode(parNode2)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject {
        var selectedNode: SCNNode?
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if let view = gesture.view as? SCNView {
                let location = gesture.location(in: view)
                let hitResults = view.hitTest(location, options: nil)
                if let hitNode = hitResults.first?.node {
                    selectedNode = hitNode.parent;
                    // 用户选择了对象，可以在此处处理高亮逻辑
                    // 恢复其他对象的材质以取消高亮
                    for node in selectedNode?.childNodes ?? [] {
                        node.geometry?.firstMaterial?.emission.contents = UIColor.yellow
                    }
                    // 高亮选定的对象
                }
            }
            
        }
        @objc func panGestureHandler(_ gesture: UIPanGestureRecognizer) {
            if let view = gesture.view as? SCNView {
                
                if let node = selectedNode {
                    if gesture.state == .changed {
                        let translation = gesture.translation(in: view)

                        // 计算位移
                        let deltaX = Float(translation.x) / 100.0
                        let deltaY = -Float(translation.y) / 100.0  // Y轴反向
                        let deltaZ = 0.0;//Float(translation.x - translation.y) / 100.0  // 使用X和Y位移来移动Z轴
                        
                        // 更新节点的位置
                        var newPosition = SCNVector3(
                            x: node.position.x + deltaX,
                            y: node.position.y + deltaY,
                            z: node.position.z
                        )
                        
//                        // 四舍五入到最接近的整数值
//                        newPosition.x = round(newPosition.x)
//                        newPosition.y = round(newPosition.y)
//                        newPosition.z = round(newPosition.z)
                        
                        node.position = newPosition
                        
                        
                        gesture.setTranslation(.zero, in: view)
                    }
                    if gesture.state == .ended {
                        // 在手势结束时，将节点的位置四舍五入到最接近的整数
                        let roundedX = round(node.position.x)
                        let roundedY = round(node.position.y)
                        let roundedZ = round(node.position.z)

                        node.position = SCNVector3(roundedX, roundedY, roundedZ)
                    }
                }
            }
        }
    }
    
    /// 单色时用的 效果不太好，改成切图了
    /// - Returns: 各个面的颜色，上下白色，侧边灰色
    func singleMaterial() -> [SCNMaterial] {
        let materialFront = SCNMaterial()
        materialFront.diffuse.contents = UIColor.lightGray
        
        let materialBack = SCNMaterial()
        materialBack.diffuse.contents = UIColor.lightGray
        
        let materialLeft = SCNMaterial()
        materialLeft.diffuse.contents = UIColor.lightGray
        
        let materialRight = SCNMaterial()
        materialRight.diffuse.contents = UIColor.lightGray
        
        let materialTop = SCNMaterial()
        materialTop.diffuse.contents = UIColor.white
        
        let materialBottom = SCNMaterial()
        materialBottom.diffuse.contents = UIColor.white
        return [materialFront, materialBack, materialLeft, materialRight, materialTop, materialBottom]
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        scnView.scene?.rootNode.childNodes.forEach({ node in
            node.childNodes.forEach { subNode in
                print("subNode.name \(subNode.name)")
                if let value = Int(subNode.name ?? "") {
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
