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

    let mmlist = [
        [
            0,
            0,
            0
        ],
        [
            2,
            0,
            0
        ],
        [
            1,
            0,
            0
        ],
        [
            0,
            2,
            1
        ],
        [
            1,
            2,
            1
        ],
        [
            1,
            0,
            2
        ],
        [
            1,
            2,
            0
        ]
    ];
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()

        // 创建坐标轴节点
        let xAxis = createAxisNode(color: .red, vector: SCNVector4(1, 0, 0, Float.pi/2))
        let yAxis = createAxisNode(color: .green, vector: SCNVector4(0, 1, 0, Float.pi/2))
        let zAxis = createAxisNode(color: .blue, vector: SCNVector4(0, 0, 1, Float.pi/2))

        scene.rootNode.addChildNode(xAxis)
        scene.rootNode.addChildNode(yAxis)
        scene.rootNode.addChildNode(zAxis)
//        nodeList.forEach { item in
//            scene.rootNode.addChildNode(item)
//        }// 看起来是每一个形状 都有一个原点了，接下来就是理解rotation,看起来是某个形状在x。y。z 旋转的次数，，就是没有理解4？？
        // 4 不就是转 一整圈了吗？？？position不重要，重要的是理解旋转，
        // 接下来把它拆开 找到初始位置和方向，也就是123，变成321的顺序 转回去，就找到初始角度了。
        // 
        let rotation =  [
            [
                1,
                1,
                1
            ],
            [
                1,
                1,
                1
            ],
            [
                2,
                2,
                3
            ],
            [
                1,
                2,
                2
            ],
            [
                1,
                2,
                2
            ],
            [
                1,
                4,
                4
            ],
            [
                1,
                1,
                3
            ]
        ];
        mmlist.forEach { item in
            let yuan = SCNSphere(radius: 0.5)
            yuan.firstMaterial?.diffuse.contents = UIColor.black
            let yuanNode = SCNNode(geometry: yuan)
            yuanNode.position = SCNVector3(item[2], item[1], item[0])
            scene.rootNode.addChildNode(yuanNode)
        }
        let nodata =     [
            [
                [
                    0,
                    0,
                    0
                ],
                [
                    2,
                    3,
                    0
                ],
                [
                    2,
                    3,
                    3
                ]
            ],
            [
                [
                    2,
                    5,
                    5
                ],
                [
                    2,
                    4,
                    5
                ],
                [
                    6,
                    4,
                    4
                ]
            ],
            [
                [
                    1,
                    1,
                    1
                ],
                [
                    6,
                    1,
                    5
                ],
                [
                    6,
                    6,
                    4
                ]
            ]
        ];
        let colors:[UIColor] =        [UIColor(hex: "000000").withAlphaComponent(0.85),
                                       UIColor(hex: "5B5B5B").withAlphaComponent(0.85),
                                       UIColor(hex: "C25C1D").withAlphaComponent(0.85),
                                       UIColor(hex: "2788e7").withAlphaComponent(0.85),
                                       UIColor(hex: "FA2E34").withAlphaComponent(0.85),
                                       UIColor(hex: "FB5BC2").withAlphaComponent(0.85),
                                       UIColor(hex: "FCC633").withAlphaComponent(0.85),
                                       UIColor(hex: "178E20").withAlphaComponent(0.85),
        ]
        // 遍历三维数组
        let rows = 3  // 第一维
        let columns = 3  // 第二维
        let depth = 3  // 第三维
        for z in 0..<rows {
            for y in 0..<columns {
                for x in 0..<depth {
                    let value = nodata[z][y][x]
                    let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                    if value == -1 {
                        continue
                    }
                    let boxNode2 = SCNNode()
                    boxNode2.geometry = box2
                    boxNode2.name = "\(value)"
                    // 由于默认y朝向上的，所以要取负值
                    boxNode2.position = SCNVector3Make(Float(x), Float(y), Float(z))
                    boxNode2.geometry?.firstMaterial?.diffuse.contents =  colors[value];
                    scene.rootNode.addChildNode(boxNode2)
                }
            }
        }
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        return scnView
    }
    

    func updateUIView(_ scnView: SCNView, context: Context) {}
}

struct ScenekitSingleView2_Previews: PreviewProvider {
    static private var nodeList:[SCNNode] = { SingleContentView2.dataList.map { SingleContentView2.addNode($0)} }()

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
