//
//  SingleContentView2.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit

struct Block {
    let data: Matrix3D
    let name: String
    var rotation:SCNVector3
    var position:SCNVector3
    var rotationTo:SCNVector4
    var positionTo:SCNVector3
}

extension SCNAction {
    public class func routeXPI_2(duration: TimeInterval) -> SCNAction {
        return SCNAction.rotate(by: .pi / 2, around: SCNVector3(1, 0, 0), duration: duration)
    }
    public class func routeYPI_2(duration: TimeInterval) -> SCNAction {
        return SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 1, 0), duration: duration)
    }
    public class func routeZPI_2(duration: TimeInterval) -> SCNAction {
        return SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 0, 1), duration: duration)
    }
}

public struct SingleContentView2: View {

    static let colors:[UIColor] = [UIColor(hex: "000000"),
                                   UIColor(hex: "5B5B5B"),
                                   UIColor(hex: "C25C1D"),
                                   UIColor(hex: "2788e7"),
                                   UIColor(hex: "FA2E34"),
                                   UIColor(hex: "FB5BC2"),
                                   UIColor(hex: "FCC633"),
                                   UIColor(hex: "178E20")]
    // node:Optional("块 1"),rotation:SCNVector4(x: 0.5773504, y: -0.5773503, z: -0.5773501, w: 4.1887903), position:SCNVector3(x: 1.0, y: 0.0, z: 1.0)
    // node:Optional("块 2"),rotation:SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954), position:SCNVector3(x: 1.0, y: 2.0, z: 1.0000001)
    // node:Optional("块 3"),rotation:SCNVector4(x: 0.0, y: 0.0, z: 0.99999994, w: 1.5707964), position:SCNVector3(x: -1.0, y: 0.0, z: -1.0)
    // node:Optional("块 4"),rotation:SCNVector4(x: 0.5773504, y: 0.57735056, z: -0.5773499, w: 4.18879), position:SCNVector3(x: 1.0, y: 0.0, z: -1.0)
    // node:Optional("块 5"),rotation:SCNVector4(x: 0.0, y: 0.99999994, z: 0.0, w: 1.5707964), position:SCNVector3(x: 0.0, y: 1.0, z: 1.0)
    // node:Optional("块 6"),rotation:SCNVector4(x: 1.0, y: 1.2665981e-07, z: 1.0803336e-07, w: 3.1415927), position:SCNVector3(x: -1.0, y: 1.0, z: 0.0)
    // node:Optional("块 7"),rotation:SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954), position:SCNVector3(x: 1.0, y: 2.0, z: 0.0)
    static var dataList:[Block] = [
        Block(data: [[[1,-1,-1],],
                     [[1,1,-1], ],
                     [[-1,-1,-1],]],
              name: "块 1",
              rotation: SCNVector3Zero,
              position: SCNVector3(6, 0, -5),
              rotationTo: SCNVector4(x: 0.5773504, y: -0.5773503, z: -0.5773501, w: 4.1887903),
              positionTo: SCNVector3(x: 1, y: 0.0, z: 1)),
        Block(data: [[[2,-1,-1],],
                     [[2,-1,-1],],
                     [[2,2,-1],]],
              name: "块 2",
              rotation: SCNVector3Zero,
              position: SCNVector3(3, 0, -5),
              rotationTo: SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954),
              positionTo: SCNVector3(x: 1, y: 2, z: 1)),
        Block(data: [[[3,-1,-1],],
                     [[3,3,-1],],
                     [[3,-1,-1],]],
              name: "块 3",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 0, -5),
              rotationTo: SCNVector4(x: 0.0, y: 0.0, z: 0.99999994, w: 1.5707964),
              positionTo: SCNVector3(x: -1, y: 0.0, z: -1)),
        Block(data: [[[4,-1,-1],],
                     [[4,4,-1],],
                     [[-1,4,-1],]],
              name: "块 4",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 0, -5),
              rotationTo: SCNVector4(x: 0.5773504, y: 0.57735056, z: -0.5773499, w: 4.18879),
              positionTo: SCNVector3(x: 1, y: 0.0, z: -1)),
        Block(data: [[[5, -1,-1],[5,  5,-1], ],
                     [[-1,-1,-1],[-1, 5,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 5",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 3, -5),
              rotationTo: SCNVector4(x: 0.0, y: 0.99999994, z: 0.0, w: 1.5707964),
              positionTo: SCNVector3(x: 0, y: 1, z: 1)),
        Block(data: [[[-1, 6,-1],[ 6, 6,-1], ],
                     [[-1,-1,-1],[ 6,-1,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 6",
              rotation: SCNVector3Zero,
              position: SCNVector3(3, 3, -5),
              rotationTo: SCNVector4(x: 1.0, y: 1.2665981e-07, z: 1.0803336e-07, w: 3.1415927),
              positionTo: SCNVector3(x: -1, y: 1.0, z: 0)),
        Block(data: [[[ 7,-1,-1],[ 7, 7,-1], ],
                     [[-1,-1,-1],[ 7,-1,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 7",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 3, -5),
              rotationTo: SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954),
              positionTo: SCNVector3(x: 1, y: 2, z: 0)),

    ];
    let segments = {dataList.map { $0.name }}()
    @State private var counter = 0
    @State private var selectedSegment = 0
    @State private var nodeList:[SCNNode] = { dataList.map { addNode($0)} }()

    @State private var stepcount = 0 {
        didSet {
            triggerHapticFeedback()
        }
    }

    static func addNode(_ item: Block) -> SCNNode {
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
                    boxNode2.geometry?.firstMaterial?.diffuse.contents =  colors[value];
                    parNode2.addChildNode(boxNode2)
                }
            }
        }
        parNode2.position = item.position;
        parNode2.customProperty = item.position;
        parNode2.customProperty2 = item.rotationTo;
        parNode2.customProperty3 = item.positionTo;
        parNode2.name = item.name;
        return parNode2
    }

    public var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                ScenekitSingleView2(nodeList: $nodeList)
                HStack{
                    Spacer()
                    rotationView()
                    stepperView()
                }.frame(height: 150).padding()

            }
            pickerView()
            
        }.navigationBarItems(trailing:completeStatus())
    }
    func completeStatus() -> some View {
        Group {
            HStack {
                Button(action: {
                    counter += 1;
                    //                        node2.position = node2.customProperty ?? node2.position
                    //                        node2.rotation = SCNVector4(0, 0, 0, 1)
                    //                        node2.rotation = node2.customProperty2 ?? SCNVector4(0, 0, 0, 1);
                    //                        node2.position = node2.customProperty3 ?? SCNVector3Zero;
//                    nodeList.forEach{ node2 in
//                        let ra = SCNAction.rotate(toAxisAngle: node2.customProperty2 ?? SCNVector4(0, 0, 0, 1), duration: 0.1);
//                        let rb = SCNAction.move(to: node2.customProperty3 ?? SCNVector3Zero, duration: 0.1);
//                        node2.runAction(SCNAction.group([ra,rb]));
//                    }
                    actionmethod(index: 0)
                }, label: {
                    Text("重置\(counter)")
                })
                Text("步数:\(stepcount)")
            }
        }
    }

    func actionmethod(index: Int) -> Void {
        guard index < nodeList.count else {
            print("over....\(index)")
            return
        }
        let ra = SCNAction.rotate(toAxisAngle: nodeList[index].customProperty2 ?? SCNVector4(0, 0, 0, 1), duration: 1);
        let rb = SCNAction.move(to: nodeList[index].customProperty3 ?? SCNVector3Zero, duration: 1);
        nodeList[index].runAction(SCNAction.group([ra, rb]), completionHandler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                actionmethod(index: index + 1);
            }
        })

    }

    var blockName:String {
        segments[selectedSegment]
    }

    func pickerView() -> some View {
        Picker("", selection: Binding(get: {selectedSegment}, set: { newValue in triggerHapticFeedback(); selectedSegment = newValue})) {
            ForEach(0 ..< segments.count, id: \.self) {
                Text(segments[$0])
            }
        }.pickerStyle(.segmented).padding(.horizontal)
    }

    func rotationView() -> some View {
        VStack {
            CustomButton(title: "旋转X") {
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.routeXPI_2(duration: 0.2))
                stepcount += 1;
            }
            CustomButton(title: "旋转Y") {
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.routeYPI_2(duration: 0.2))
                stepcount += 1;
            }
            CustomButton(title: "旋转Z") {
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.routeZPI_2(duration: 0.2))
                stepcount += 1;
            }
        }.padding()
    }

    func stepperView() -> some View {
        VStack(alignment: .trailing) {
            Stepper {
                Text("X")
            } onIncrement :{
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(1.0, 0, 0), duration: 0.1))
                stepcount += 1;
            } onDecrement: {
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(-1.0, 0, 0), duration: 0.1))
                stepcount += 1;
            }

            Stepper {
                Text("Y")
            } onIncrement :{
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 1.0, 0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, -1.0, 0), duration: 0.1))
            }

            Stepper {
                Text("Z")
            } onIncrement :{
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 0, 1.0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 0, -1.0), duration: 0.1))
            }
        }.frame(width: 120)
    }

    func lognodeInfo() -> Void {
        nodeList.forEach { node in
            print("node:\(node.name),rotation:\(node.rotation), position:\(node.position)")
        }
    }

    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        lognodeInfo()

//        // 创建一个SCNVector4对象
//        let vector = SCNVector4(x: 1.0, y: 2.0, z: 3.0, w: 4.0)
//
//        // 获取文档目录路径
//        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            // 拼接文件路径
//            let filePath = documentsDirectory.appendingPathComponent("vectorData.dat")
//
//            do {
//                // 归档SCNVector4对象并将其写入文件
//                let data = try NSKeyedArchiver.archivedData(withRootObject: vector, requiringSecureCoding: false)
//                try data.write(to: filePath)
//                print("Vector data written to file")
//            } catch {
//                print("Error writing to file: \(error)")
//            }
//        }
    }
}


struct CustomButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        } .background(Color.yellow)
            .cornerRadius(8)
    }
}


// 创建一个扩展以为 SCNNode 添加自定义属性
extension SCNNode {
    private struct AssociatedKeys {
        static var customProperty = "customProperty"
        static var customProperty2 = "customProperty2"
        static var customProperty3 = "customProperty3"

    }

    var customProperty: SCNVector3? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customProperty) as? SCNVector3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customProperty, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var customProperty2: SCNVector4? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customProperty2) as? SCNVector4
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customProperty2, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var customProperty3: SCNVector3? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customProperty3) as? SCNVector3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customProperty3, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
