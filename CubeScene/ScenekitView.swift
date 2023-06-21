//
//  ContentView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
//

import SwiftUI
import SceneKit


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

enum ShowType: Hashable {
    case secret
    case color
    case number
}

struct ContentView: View {
    @State private var colorFull:ShowType = .color
    @State private var dataIndexInput = ""
    @State var dataIndex:Int = 0
    let triSet:CharacterSet = {
        var triSet = CharacterSet.whitespacesAndNewlines
        triSet.insert("/")
        return triSet
    }()

    let firstArray: [String] = {
        let stringContent = try! String(contentsOf: Bundle.main.url(forResource: "SOMA101", withExtension: "txt")!, encoding: .utf8)
        let firstArray = stringContent.components(separatedBy: "/SOMA")
        return firstArray.filter { item in
            item.lengthOfBytes(using: .utf8) > 5
        }
    }()

    func data(at: Int) -> String {
        return String(firstArray[at])
    }

    var numberOfSoma:Int {
        firstArray.count
    }

    func result() -> [[[Int]]] {
        let dataStr = data(at: dataIndex)

        let data = dataStr.trimmingCharacters(in: triSet).split(separator: "\n").dropFirst().filter { item in
            item.hasPrefix("/")
        }.map({ item in
            item.trimmingCharacters(in: triSet)
        })

        let charitem = Character("/")
        let result = data.map { item in
            item.split(separator: charitem).map { subItem in
                subItem.map { subSubItem in
                    Int(String(subSubItem)) ?? -1
                }
            }
        }
         print(result)
        return result
    }


    var body: some View {
        VStack {
            Text(data(at: dataIndex))
                .font(.custom("Menlo", size: 18))
            ScenekitView(colorFull: colorFull, result: result())
            HStack {
                ZStack{
                    Rectangle().background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.clear).cornerRadius(5)
                    Text("上一个").foregroundColor(.white).font(.headline)
                }.frame(height: 44).onTapGesture {
                    dataIndex = (dataIndex - 1 + numberOfSoma) % numberOfSoma
                }
                Spacer()
                TextField("关卡", text: $dataIndexInput, prompt: Text("关卡号"))
                    .onSubmit {
                        if let inputIndex = Int(dataIndexInput) {
                            dataIndex = (inputIndex) % numberOfSoma
                            print("dataIndexInput22:\(dataIndex)")
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .padding()
                Spacer()
                ZStack{
                    Rectangle().background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.clear).cornerRadius(5)
                    Text("下一个").foregroundColor(.white).font(.headline)
                }.frame(height: 44).onTapGesture {
                    dataIndex = (dataIndex + 1) % numberOfSoma
                }
            }
            Picker("What is your favorite color?", selection: $colorFull) {
                Text("彩色").tag(ShowType.color)
                Text("单色").tag(ShowType.secret)
                Text("数字").tag(ShowType.number)
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}


struct ScenekitView : UIViewRepresentable {

    let colorFull:ShowType;
    let result: [[[Int]]]

    init(colorFull: ShowType = .color, result: [[[Int]]] ) {
        self.colorFull = colorFull
        self.result = result
    }

    let scene : SCNScene = {
        let ret = SCNScene();
        // 添加照相机
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 0, 15)
        ret.rootNode.addChildNode(cameraNode)
        return ret;
    }()


    let colors:[UIColor] = [
//        UIColor.black,
//        UIColor.systemCyan, // front
//        UIColor.green, // right
//        UIColor.red, // back
//        UIColor.systemIndigo, // left
//        UIColor.blue, // top
//        UIColor.purple,
//        UIColor.yellow,
        UIColor(hex: "000000"),
        UIColor(hex: "FF8800"),
        UIColor(hex: "0396FF"),
        UIColor(hex: "EA5455"),
        UIColor(hex: "7367F0"),
        UIColor(hex: "32CCBC"),
        UIColor(hex: "28C76F"),
//        UIColor(hex: "360940"),
        UIColor.purple
    ] // bottom

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
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        let countOfRow = result.count
        let countOfLayer = result.first?.count ?? -1
        let countOfColum = result.first?.first?.count ?? -1
        // print("count:\(scene.rootNode.childNodes.count)")

        // create and add a camera to the scene
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
                    case .secret:
                        material.diffuse.contents = colors[1]
                    case .color:
                        material.diffuse.contents = colors[value]
                    case .number:
                        material.diffuse.contents = colorImages[value]
                    }
                    material.locksAmbientWithDiffuse = true
                    box2.firstMaterial = material;
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
        scnView.backgroundColor = .lightGray
//        let immm = UIImage(named: "wenli")!;
//        let ccc = UIColor(patternImage: immm)
//        scnView.backgroundColor = ccc

    }

}
