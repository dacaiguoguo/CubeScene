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

//如果两个节点的旋转轴和角度都不同，那么你需要执行更复杂的计算来旋转一个节点以匹配另一个节点的方向。下面是一种通用的方法，可以帮助你实现这一目标：
//
//```swift
//import SceneKit
//
//// 创建第一个节点
//let node1 = SCNNode()
//let rotation1 = SCNQuaternion(x: 0, y: 1, z: 0, w: Float.pi / 4) // 旋转45度
//node1.orientation = rotation1
//
//// 创建第二个节点
//let node2 = SCNNode()
//let rotation2 = SCNQuaternion(x: 1, y: 0, z: 0, w: -Float.pi / 4) // 旋转-45度
//node2.orientation = rotation2
//
//// 计算从第一个节点到第二个节点的四元数旋转差异
//let rotationDifference = node2.orientation * node1.orientation.inverted()
//
//// 使用四元数旋转差异来旋转第一个节点以匹配第二个节点的方向
//node1.orientation = rotationDifference * node1.orientation
//
//// 你现在可以将 node1 添加到场景中
//```
//
//在这个示例中，我们首先创建了两个 `SCNNode`，每个节点都具有不同的旋转轴和角度。然后，我们计算了从第一个节点到第二个节点的四元数旋转差异，将其应用于第一个节点，以使其方向匹配第二个节点。
//
//这个示例中使用了四元数来处理旋转，四元数对于处理复杂的旋转操作非常有用，因为它们可以避免万向锁等问题。请确保了解四元数的基本概念，以更好地理解这个示例。这个方法适用于不同旋转轴和不同角度的情况，但需要小心处理节点之间的坐标系和父子节点关系。

public struct SingleContentView2: View {

    static let colors:[UIColor] = [UIColor(hex: "000000"),
                                   UIColor(hex: "5B5B5B"),
                                   UIColor(hex: "C25C1D"),
                                   UIColor(hex: "2788e7"),
                                   UIColor(hex: "FA2E34"),
                                   UIColor(hex: "FB5BC2"),
                                   UIColor(hex: "FCC633"),
                                   UIColor(hex: "178E20")]
    
    static var dataList:[Block] = [
        Block(data: [[[1,-1,-1],],
                     [[1,1,-1], ],
                     [[-1,-1,-1],]],
              name: "块 1",
              rotation: SCNVector3Zero,
              position: SCNVector3(6, 0, -5)),
        Block(data: [[[2,-1,-1],],
                     [[2,-1,-1],],
                     [[2,2,-1],]],
              name: "块 2",
              rotation: SCNVector3Zero,
              position: SCNVector3(3, 0, -5)),
        Block(data: [[[3,-1,-1],],
                     [[3,3,-1],],
                     [[3,-1,-1],]],
              name: "块 3",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 0, -5)),
        Block(data: [[[4,-1,-1],],
                     [[4,4,-1],],
                     [[-1,4,-1],]],
              name: "块 4",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 0, -5)),
        Block(data: [[[5, -1,-1],[5,  5,-1], ],
                     [[-1,-1,-1],[-1, 5,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 5",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 3, -5)),
        Block(data: [[[-1, 6,-1],[ 6, 6,-1], ],
                     [[-1,-1,-1],[ 6,-1,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 6",
              rotation: SCNVector3Zero,
              position: SCNVector3(3, 3, -5)),
        Block(data: [[[ 7,-1,-1],[ 7, 7,-1], ],
                     [[-1,-1,-1],[ 7,-1,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 7",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 3, -5)),

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
                    nodeList.forEach{ node2 in
                        node2.position = node2.customProperty ?? node2.position
                        node2.rotation = SCNVector4(0, 0, 0, 1)
                    }
                }, label: {
                    Text("重置\(counter)")
                })
                Text("步数:\(stepcount)")
            }
        }
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
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.routeXPI_2(duration: 0.2))
            }
            CustomButton(title: "旋转Y") {
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.routeYPI_2(duration: 0.2))
            }
            CustomButton(title: "旋转Z") {
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.routeZPI_2(duration: 0.2))
            }
        }.padding()
    }

    func stepperView() -> some View {
        VStack(alignment: .trailing) {
            Stepper {
                Text("X")
            } onIncrement :{
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(1.0, 0, 0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(-1.0, 0, 0), duration: 0.1))
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

    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
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
    }

    var customProperty: SCNVector3? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customProperty) as? SCNVector3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customProperty, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
