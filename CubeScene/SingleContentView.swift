//
//  SingleContentView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit


/// 显示类型 单色、彩色、数字
enum ShowType: Hashable {
    case singleColor
    case colorFul
    case number
}

extension SCNVector3: Equatable {
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}


extension Matrix3D {
    var formatOutput: String {
        return self.map { item in
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
}

public struct SingleContentView: View {

    @State private var isOn = false
    @State private var showType:ShowType = .singleColor
    @State private var viewOffset = CGSize.zero

    let dataModel: EnterItem


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
    let imageSize = 100.0;
    public var body: some View {
        VStack {
            ZStack{
                Image(uiImage: UIImage(named: "wenli4")!)
                    .resizable(resizingMode: .tile)
                ZStack(alignment: .bottom) {
                    ScenekitSingleView(showType: showType, dataItem: dataModel.matrix, colors: colorsDefault)
                        .frame(maxWidth: .infinity)
                        .offset(viewOffset)
                    HStack{
                        Image(uiImage: UIImage(named: "c1")!).resizable(resizingMode: .stretch).frame(width: imageSize, height: imageSize)
                        Image(uiImage: UIImage(named: "c3")!).resizable(resizingMode: .stretch).frame(width: imageSize, height: imageSize)
                        Image(uiImage: UIImage(named: "c4")!).resizable(resizingMode: .stretch).frame(width: imageSize, height: imageSize)
                    }
                }
            }
            .clipped()
            Picker("显示模式", selection: $showType) {
                Text("彩色答案").tag(ShowType.colorFul)
                Text("出题模式").tag(ShowType.singleColor)
                Text("数字模式").tag(ShowType.number)
            }.pickerStyle(.segmented)
            if isOn {
                HStack{
                    Text(dataModel.matrix.formatOutput).font(.custom("Menlo", size: 18)).frame(maxWidth: .infinity).background(Color.white)
                }
            }
            Toggle("显示代码", isOn: $isOn)
                .padding().frame(maxWidth: .infinity)
            // ArrowButtonView(onButtonTapped: handleButtonTapped)  // 将按钮点击事件传递给自定义视图
        }.padding().navigationTitle(dataModel.name)
    }
}


struct ScenekitSingleView : UIViewRepresentable {

    let showType:ShowType;
    let dataItem: Matrix3D
    let colors:[UIColor]
    let imageName:String
    init(showType: ShowType = .singleColor, dataItem: Matrix3D, colors:[UIColor] = colorsDefault, imageName:String = "" ) {
        self.showType = showType
        self.dataItem = dataItem
        self.colors = colors
        self.imageName = imageName
    }



    let scene : SCNScene = {
        let ret = SCNScene();
        // 添加照相机
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(5, 13, 8)
        cameraNode.eulerAngles = SCNVector3Make(-Float.pi/4, Float.pi/9, 0) // 设置相机的旋转角度，这里是将场景绕 X 轴逆时针旋转 45 度
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
        let countOfRow = dataItem.count
        let countOfLayer = dataItem.first?.count ?? -1
        let countOfColum = dataItem.first?.first?.count ?? -1

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
                        node.position == SCNVector3Make(Float(x), Float(-y+3), Float(z))
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
                                material.diffuse.contents = colors[value]
                                material.locksAmbientWithDiffuse = true
                                boxNode.geometry?.materials = [];
                                boxNode.geometry?.firstMaterial = material
                            case .number:
                                let material = SCNMaterial()
                                material.diffuse.contents = colorImages[value]
                                material.locksAmbientWithDiffuse = true
                                boxNode.geometry?.materials = [];
                                boxNode.geometry?.firstMaterial = material
                            }
                        }
                    }

                }
            }
        }
//        辅助任务 保存图片到document 为了性能优化
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            // 在此处执行您的任务
//            let sss = scnView.snapshot()
//            saveImageToDocumentDirectory(image:sss, fileName: imageName)
//        }
    }

}

func saveImageToDocumentDirectory(image: UIImage, fileName: String) {
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }

    guard let imageData = image.pngData() else {
        return
    }

    let fileURL = documentsDirectory.appendingPathComponent("\(fileName)@3x.png")

    do {
        try imageData.write(to: fileURL)
        print("Image saved successfully. File path: \(fileURL)")
    } catch {
        print("Error saving image: \(error)")
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
            ScenekitSingleView(dataItem:[[[2,4,3], [6,4,1], [6,6,1]],
                                       [[2,3,3], [6,4,1], [7,4,5]],
                                       [[2,2,3], [7,5,5], [7,7,5]]])
            .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("iPhone SE")

    }
}
