//
//  ScenekitSingleView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/17.
//

import SwiftUI
import SceneKit

extension SCNVector3: Equatable {
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

struct ScenekitSingleView : UIViewRepresentable {
    private let dataModel: EnterItem
    private let showType:ShowType;
    private let colors:[UIColor]
    private let numberImageList: [UIImage]
    private let showColor:[Int]
    private let scene : SCNScene

   
    
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
        let env = UIImage(named: "shinyRoom.jpg")
        ret.background.contents = env
        self.scene = ret
    }
    

    func makeUIView(context: Context) -> SCNView {
        // retrieve the SCNView
        let scnView = SCNView()


        let countOfRow = dataItem.count
        let countOfLayer = dataItem.first?.count ?? -1
        let countOfColum = dataItem.first?.first?.count ?? -1
        let parNode2 = SCNNode()

        for z in 0..<countOfRow {
            for y in 0..<countOfLayer {
                for x in 0..<countOfColum {
                    // 盒子
                    let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                    let value = dataItem[z][y][x];
                    if value == -1 {
                        continue
                    }
                    let boxNode2 = SCNNode()
                    boxNode2.geometry = box2
                    // 由于默认y朝向上的，所以要取负值
                    boxNode2.position = SCNVector3Make(Float(x), Float(-y), Float(z))
                    parNode2.addChildNode(boxNode2)
                }
            }
        }
        parNode2.position = SCNVector3Make(Float(-1), Float(1), Float(1))
        // 旋转此节点会导致 用手势旋转时有偏轴现象
        // parNode2.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        scene.rootNode.addChildNode(parNode2)
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.backgroundColor = .clear


        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)

        return scnView
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject {
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            if let view = gesture.view as? SCNView {
                let location = gesture.location(in: view)
                let hitResults = view.hitTest(location, options: nil)
                if let hitNode = hitResults.first?.node {
                    // 用户选择了对象，可以在此处处理高亮逻辑
                    // 恢复其他对象的材质以取消高亮
                    for node in view.scene?.rootNode.childNodes.first?.childNodes ?? [] {
                        node.geometry?.firstMaterial?.emission.contents = UIColor.black
                    }
                    // 高亮选定的对象
                    hitNode.geometry?.firstMaterial?.emission.contents = UIColor.yellow
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
        let countOfRow = dataItem.count
        let countOfLayer = dataItem.first?.count ?? -1
        let countOfColum = dataItem.first?.first?.count ?? -1
        
        for z in 0..<countOfRow {
            for y in 0..<countOfLayer {
                for x in 0..<countOfColum {
                    let value = dataItem[z][y][x];
                    if value == -1 {
                        continue
                    }
                    if let boxNodes = scnView.scene?.rootNode.childNodes(passingTest: { node, _ in
                        node.position == SCNVector3Make(Float(x), Float(-y), Float(z))
                    }) {
                        // 输出符合条件的节点名称
                        for boxNode in boxNodes {
                            switch showType {
                            case .singleColor:
                                //                                boxNode.geometry?.firstMaterial = nil
                                //                                boxNode.geometry?.materials = singleMaterial()
                                let material = SCNMaterial()
                                material.diffuse.contents = UIImage(named: "border")!
                                boxNode.geometry?.firstMaterial = material
                            case .colorFul:
                                let material = SCNMaterial()
                                if showColor.contains(value) {
                                    switch value {
                                    case 86:
//                                        return 1
                                        material.diffuse.contents = colors[1].withAlphaComponent(0.81)
                                    case 76:
//                                        return 2;
                                        material.diffuse.contents = colors[2].withAlphaComponent(0.81)
                                    case 84:
//                                        return 3;
                                        material.diffuse.contents = colors[3].withAlphaComponent(0.81)

                                    case 90:
//                                        return 4;
                                        material.diffuse.contents = colors[4].withAlphaComponent(0.81)

                                    case 65:
//                                        return 5;
                                        material.diffuse.contents = colors[5].withAlphaComponent(0.81)

                                    case 66:
//                                        return 6;
                                        material.diffuse.contents = colors[6].withAlphaComponent(0.81)

                                    case 80:
//                                        return 7;
                                        material.diffuse.contents = colors[7].withAlphaComponent(0.81)

                                    default:
                                        material.diffuse.contents = colors[value]
                                    }

                                } else {
                                    material.diffuse.contents = UIColor.clear
                                }
                                //                                material.diffuse.contents = colors[value]
                                material.locksAmbientWithDiffuse = true
                                boxNode.geometry?.materials = [];
                                boxNode.geometry?.firstMaterial = material
                            case .number:
                                let material = SCNMaterial()
                                switch value {
                                case 86:
                                    //                                        return 1
                                    material.diffuse.contents = generateImage(color: colors[1].withAlphaComponent(0.8), text: "V")
                                case 76:
                                    //                                        return 2;
                                    material.diffuse.contents = generateImage(color: colors[2].withAlphaComponent(0.8), text: "L")
                                case 84:
                                    //                                        return 3;
                                    material.diffuse.contents = generateImage(color: colors[3].withAlphaComponent(0.8), text: "T")

                                case 90:
                                    //                                        return 4;
                                    material.diffuse.contents = generateImage(color: colors[4].withAlphaComponent(0.8), text: "Z")

                                case 65:
                                    //                                        return 5;
                                    material.diffuse.contents = generateImage(color: colors[5].withAlphaComponent(0.8), text: "A")

                                case 66:
                                    //                                        return 6;
                                    material.diffuse.contents = generateImage(color: colors[6].withAlphaComponent(0.8), text: "B")

                                case 80:
                                    //                                        return 7;
                                    material.diffuse.contents = generateImage(color: colors[7].withAlphaComponent(0.8), text: "P")

                                default:
                                    material.diffuse.contents = numberImageList[value]
                                }
                                material.locksAmbientWithDiffuse = true
                                boxNode.geometry?.materials = [];
                                boxNode.geometry?.firstMaterial = material
                            }
                        }
                    }
                    
                }
            }
        }
        //        TODO: 改成由变量控制，点击按钮生成图像
        //        辅助任务 保存图片到document 为了性能优化
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        //     // 在此处执行您的任务
        //     let sss = scnView.snapshot()
        //     saveImageToDocumentDirectory(image:sss, fileName: imageName)
        // }
    }
    
}

//func saveImageToDocumentDirectory(image: UIImage, fileName: String) {
//    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//        return
//    }
//
//    guard let imageData = image.pngData() else {
//        return
//    }
//
//    let fileURL = documentsDirectory.appendingPathComponent("\(fileName).png")
//
//    do {
//        try imageData.write(to: fileURL)
//        // print("Image saved successfully. File path: \(fileURL)")
//    } catch {
//        print("Error saving image: \(error)")
//    }
//}
//

struct ScenekitSingleView_Previews: PreviewProvider {
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
