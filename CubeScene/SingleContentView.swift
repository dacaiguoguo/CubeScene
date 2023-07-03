//
//  SingleContentView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit

extension SCNVector3: Equatable {
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

public struct SingleContentView: View {

    @State private var isOn = false
    @State private var colorFull:ShowType = .colorFul
    @State private var viewOffset = CGSize.zero

    /// 解析结果
    /// - Returns: 返回三维数组
    let result: Matrix3D


    func resultDes() -> String {
        return result.map { item in
            "/" + item.map({ subItem in
                subItem.map({ value in
                    if value == -1 {
                        return  "."
                    } else {
                        return String(value)
                    }
                }).joined()
            }).joined(separator: "/")
        }.joined(separator: "\n")
    }
    func handleButtonTapped(_ direction: Direction) {
        // 在此处处理按钮点击事件
        switch direction {
        case .up:
            withAnimation {
                viewOffset.height -= 10
            }
        case .down:
            withAnimation {
                viewOffset.height += 10
            }
        case .left:
            withAnimation {
                viewOffset.width -= 10
            }
        case .right:
            withAnimation {
                viewOffset.width += 10
            }
        }
    }
    public var body: some View {
        VStack {

            ZStack{
                Image(uiImage: UIImage(named: "wenli4")!)
                    .resizable(resizingMode: .tile)
                ScenekitSingleView(colorFull: colorFull, result: result, colors: colorsDefault)
                    .frame(width: UIScreen.main.currentMode?.size.width)
                    .offset(viewOffset)
            }
            .clipped()
            Picker("显示模式", selection: $colorFull) {
                Text("彩色").tag(ShowType.colorFul)
                Text("单色").tag(ShowType.singleColor)
                Text("数字").tag(ShowType.number)
            }.pickerStyle(.segmented)
            HStack{
                if isOn {
                    Text(resultDes()).font(.custom("Menlo", size: 18)).frame(maxWidth: .infinity).background(Color.white)
                }
                Spacer()
                Toggle("显示代码", isOn: $isOn)
                    .padding()
            }
            CustomView(onButtonTapped: handleButtonTapped)  // 将按钮点击事件传递给自定义视图

        }.padding()
    }
}


struct CustomView: View {
    var onButtonTapped: ((Direction) -> Void)?  // 定义按钮点击事件的闭包属性

    var body: some View {
//        VStack {
//            Button(action: {
//                onButtonTapped?(.up)  // 调用上按钮点击事件
//            }) {
//                Image(systemName: "arrow.up")
//            }
//            .padding()
//
//            HStack {
//                Button(action: {
//                    onButtonTapped?(.left)  // 调用左按钮点击事件
//                }) {
//                    Image(systemName: "arrow.left")
//                }
//                .padding()
//
//                Button(action: {
//                    onButtonTapped?(.right)  // 调用右按钮点击事件
//                }) {
//                    Image(systemName: "arrow.right")
//                }
//                .padding()
//            }
//
//            Button(action: {
//                onButtonTapped?(.down)  // 调用下按钮点击事件
//            }) {
//                Image(systemName: "arrow.down")
//            }
//            .padding()
//        }
        HStack {
            Button(action: {
                onButtonTapped?(.left)  // 调用左按钮点击事件
            }) {
                Image(systemName: "arrow.left")
            }
            .padding()

            Button(action: {
                onButtonTapped?(.right)  // 调用右按钮点击事件
            }) {
                Image(systemName: "arrow.right")
            }
            .padding()
        }

    }
}

enum Direction {
    case up
    case down
    case left
    case right
}

struct ScenekitSingleView : UIViewRepresentable {

    let colorFull:ShowType;
    let result: Matrix3D
    let colors:[UIColor]
    init(colorFull: ShowType = .colorFul, result: Matrix3D, colors:[UIColor] = colorsDefault ) {
        self.colorFull = colorFull
        self.result = result
        self.colors = colors
    }

    let scene : SCNScene = {
        let ret = SCNScene();
        // 添加照相机
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(-10, 3, 15)
//        cameraNode.eulerAngles = SCNVector3Make(0, 0, Float.pi/2) // 设置相机的旋转角度，这里是将场景绕 X 轴逆时针旋转 45 度
        cameraNode.eulerAngles = SCNVector3Make(-Float.pi/6, -Float.pi/9, Float.pi/6) // 设置相机的旋转角度，这里是将场景绕 X 轴逆时针旋转 45 度

        ret.rootNode.addChildNode(cameraNode)
        return ret;
    }()


    let colorImages:[UIImage] = [
        UIImage(named: "1")!,
        UIImage(named: "1")!,
        UIImage(named: "2")!,
        UIImage(named: "3")!,
        UIImage(named: "4")!,
        UIImage(named: "5")!,
        UIImage(named: "6")!,
        UIImage(named: "7")!,
    ] // bottom

    func makeUIView(context: Context) -> SCNView {
        // retrieve the SCNView
        let scnView = SCNView()
        let countOfRow = result.count
        let countOfLayer = result.first?.count ?? -1
        let countOfColum = result.first?.first?.count ?? -1

        for z in 0..<countOfRow {
            for y in 0..<countOfLayer {
                for x in 0..<countOfColum {
                    // 盒子
                    let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                    let value = result[z][y][x];
                    if value == -1 {
                        continue
                    }
                    let boxNode2 = SCNNode()
                    boxNode2.geometry = box2
                    // 由于默认y朝向上的，所以要取负值
                    boxNode2.position = SCNVector3Make(Float(x), Float(-y+3), Float(z))
                    scene.rootNode.addChildNode(boxNode2)
                }
            }
        }
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.backgroundColor = .clear
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        let countOfRow = result.count
        let countOfLayer = result.first?.count ?? -1
        let countOfColum = result.first?.first?.count ?? -1

        for z in 0..<countOfRow {
            for y in 0..<countOfLayer {
                for x in 0..<countOfColum {
                    // 盒子
                    let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                    let value = result[z][y][x];
                    if value == -1 {
                        continue
                    }
                    let material = SCNMaterial()

                    switch colorFull {
                    case .singleColor:
                        //                        material.diffuse.contents = colors[1]
                        material.diffuse.contents = UIImage(named: "border")!
                    case .colorFul:
                        material.diffuse.contents = colors[value]
                    case .number:
                        material.diffuse.contents = colorImages[value]
                    }
                    material.locksAmbientWithDiffuse = true
                    box2.firstMaterial = material;

                    if let boxNodes = scnView.scene?.rootNode.childNodes(passingTest: { node, _ in
                        node.position == SCNVector3Make(Float(x), Float(-y+3), Float(z))
                    }) {
                        // 输出符合条件的节点名称
                        for boxNode in boxNodes {
                            boxNode.geometry?.firstMaterial = material
                        }
                    }

                }
            }
        }
    }

}


//struct SingleContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SingleContentView(result:[[[2,4,3], [6,4,1], [6,6,1]],
//                                      [[2,3,3], [6,4,1], [7,4,5]],
//                                      [[2,2,3], [7,5,5], [7,7,5]]])
//            .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
//
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//
//    }
//}
struct ScenekitSingleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScenekitSingleView(result:[[[2,4,3], [6,4,1], [6,6,1]],
                                      [[2,3,3], [6,4,1], [7,4,5]],
                                      [[2,2,3], [7,5,5], [7,7,5]]])
            .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)

        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
}