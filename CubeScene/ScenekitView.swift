//
//  ContentView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
//

import SwiftUI
import SceneKit


struct ContentView: View {
    @State private var colorFull = true
    let data:String = try! String(contentsOf: Bundle.main.url(forResource: "data", withExtension: "txt")!, encoding: .utf8)
    var body: some View {
        VStack {
            Text(data)
                .font(.custom("Menlo", size: 18))
            ScenekitView(colorFull: colorFull)
            Toggle("显示答案", isOn: $colorFull)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ScenekitView : UIViewRepresentable {

    var colorFull = true;

    init(colorFull: Bool = true) {
        self.colorFull = colorFull
    }

    let scene : SCNScene = {
        let ret = SCNScene();
        // 添加照相机
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(1, 1, 15)
        ret.rootNode.addChildNode(cameraNode)
        return ret;
    }()

    let result = {
        let path: URL = Bundle.main.url(forResource: "data", withExtension: "txt")!
        var triSet = CharacterSet.whitespacesAndNewlines
        triSet.insert("/")
        let data = try! String(contentsOf: path, encoding: .utf8).trimmingCharacters(in: triSet).split(separator: "\n").map({ item in
            item.trimmingCharacters(in: triSet)
        })

        let result = data.map { item in
            item.split(separator: "/").map { subItem in
                subItem.split(separator: "").map { subSubItem in
                    Int(subSubItem) ?? -1
                }
            }
        }
        print(result)
        return result
    }()


    let colors = [
        UIColor.black,
        UIColor.systemCyan, // front
        UIColor.green, // right
        UIColor.red, // back
        UIColor.systemPink, // left
        UIColor.blue, // top
        UIColor.purple,
        UIColor.yellow,
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


        // create and add a camera to the scene
        for z in 0..<countOfRow {
            for y in 0..<countOfLayer {
                for x in 0..<countOfColum {
                    // 盒子
                    let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.1)
                    let value = result[z][y][x];
                    if value == -1 {
                        continue
                    }
                    let material = SCNMaterial()
                    if colorFull {
                        material.diffuse.contents = colors[value]
                    } else {
                        material.diffuse.contents = colors[1]
                    }
                    material.locksAmbientWithDiffuse = true
                    box2.firstMaterial = material;
                    let boxNode2 = SCNNode()
                    boxNode2.geometry = box2
                    // 由于默认y朝向上的，所以要取负值
                    boxNode2.position = SCNVector3Make(Float(x), Float(-y), Float(z))
                    scene.rootNode.addChildNode(boxNode2)
                }
            }
        }

        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.backgroundColor = .lightGray
    }

}
