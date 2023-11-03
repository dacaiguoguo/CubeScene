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
    var rotationTo3:SCNVector3
    var positionTo:SCNVector3
}

enum LVAxis {
    case x
    case y
    case z
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
// rotationTo 可以简化为x几次y几次z几次，用SCNVector3 记录就可以了
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

    static let colors:[UIColor] = [UIColor(hex: "000000").withAlphaComponent(0.95),
                                   UIColor(hex: "5B5B5B").withAlphaComponent(0.95),
                                   UIColor(hex: "C25C1D").withAlphaComponent(0.95),
                                   UIColor(hex: "2788e7").withAlphaComponent(0.95),
                                   UIColor(hex: "FA2E34").withAlphaComponent(0.95),
                                   UIColor(hex: "FB5BC2").withAlphaComponent(0.95),
                                   UIColor(hex: "FCC633").withAlphaComponent(0.95),
                                   UIColor(hex: "178E20").withAlphaComponent(0.95),
    ]
    // 算出来的第一个点就是块的位置，有了位置也就进一步确定方向，时左还是右，上还是下，是否是镜像的
    // 然后在把rotationTo改成x、y,z 旋转次数，再根据初始位置
    // 用四元数算出旋转所需，，既然用四元数计算，那就不用上一步了，再就是要把一开始的遍历创建，改成按块，按角度创建，意思
    // 就是创建一个空白的，在算两个node之间的旋转四元数
    // action上再增加一个先移动到上方，再向下移动，防止互相穿过
    // node:Optional("块 1"),rotation:SCNVector4(x: 0.5773504, y: -0.5773503, z: -0.5773501, w: 4.1887903), position:SCNVector3(x: 1.0, y: 0.0, z: 1.0)
    // node:Optional("块 2"),rotation:SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954), position:SCNVector3(x: 1.0, y: 2.0, z: 1.0000001)
    // node:Optional("块 3"),rotation:SCNVector4(x: 0.0, y: 0.0, z: 0.99999994, w: 1.5707964), position:SCNVector3(x: -1.0, y: 0.0, z: -1.0)
    // node:Optional("块 4"),rotation:SCNVector4(x: 0.5773504, y: 0.57735056, z: -0.5773499, w: 4.18879), position:SCNVector3(x: 1.0, y: 0.0, z: -1.0)
    // node:Optional("块 5"),rotation:SCNVector4(x: 0.0, y: 0.99999994, z: 0.0, w: 1.5707964), position:SCNVector3(x: 0.0, y: 1.0, z: 1.0)
    // node:Optional("块 6"),rotation:SCNVector4(x: 1.0, y: 1.2665981e-07, z: 1.0803336e-07, w: 3.1415927), position:SCNVector3(x: -1.0, y: 1.0, z: 0.0)
    // node:Optional("块 7"),rotation:SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954), position:SCNVector3(x: 1.0, y: 2.0, z: 0.0)

    //node:块 1,rotation:SCNVector3(x: 0.0, y: 1.0, z: 1.0), position:SCNVector3(x: 1.0000011, y: 0.0, z: 0.99999976)
    //node:块 2,rotation:SCNVector3(x: 1.0, y: 0.0, z: 3.0), position:SCNVector3(x: 0.99999964, y: 1.9999999, z: 0.99999964)
    //node:块 3,rotation:SCNVector3(x: 0.0, y: 0.0, z: 1.0), position:SCNVector3(x: -0.99999964, y: 0.0, z: -1.0000001)
    //node:块 4,rotation:SCNVector3(x: 3.0, y: 0.0, z: 1.0), position:SCNVector3(x: -0.9999999, y: 1.0000001, z: -1.0000001)
    //node:块 5,rotation:SCNVector3(x: 0.0, y: 1.0, z: 0.0), position:SCNVector3(x: 3.874302e-07, y: 0.99999964, z: 0.99999964)
    //node:块 6,rotation:SCNVector3(x: 0.0, y: 3.0, z: 2.0), position:SCNVector3(x: -3.5762787e-07, y: 0.99999964, z: -1.4901161e-07)
    //node:块 7,rotation:SCNVector3(x: 0.0, y: 0.0, z: 2.0), position:SCNVector3(x: 1.0, y: 0.99999964, z: -1.0000001)

    
    static var dataList:[Block] = [
        Block(data: [[[1,-1,-1],],
                     [[1,1,-1], ],
                     [[-1,-1,-1],]],
              name: "块 1",
              rotation: SCNVector3Zero,
              position: SCNVector3(6, 0, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 1.0, z: 1.0),
              positionTo: SCNVector3(x: 1, y: 0.0, z: 1)),

        Block(data: [[[2,-1,-1],],
                     [[2,-1,-1],],
                     [[2,2,-1],]],
              name: "块 2",
              rotation: SCNVector3Zero,
              position: SCNVector3(3, 0, -5),
              rotationTo3: SCNVector3(x: 1.0, y: 0.0, z: 3.0),
              positionTo: SCNVector3(x: 1, y: 2, z: 1)),
        Block(data: [[[3,-1,-1],],
                     [[3,3,-1],],
                     [[3,-1,-1],]],
              name: "块 3",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 0, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 0.0, z: 1.0),
              positionTo: SCNVector3(x: -1, y: 0.0, z: -1)),
        Block(data: [[[4,-1,-1],],
                     [[4,4,-1],],
                     [[-1,4,-1],]],
              name: "块 4",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 0, -5),
              rotationTo3: SCNVector3(x: 3.0, y: 0.0, z: 1.0),
              positionTo: SCNVector3(x: 1, y: 0.0, z: -1)),
        Block(data: [[[5, -1,-1],[5,  5,-1], ],
                     [[-1,-1,-1],[-1, 5,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 5",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 3, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 1.0, z: 0.0),
              positionTo: SCNVector3(x: 0, y: 1, z: 1)),
        Block(data: [[[6, -1,-1],[ 6,-1,-1], ],
                     [[-1,-1,-1],[ 6, 6,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 6",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 3, 5),
              rotationTo3: SCNVector3(x: 0.0, y: 1.0, z: 2.0),
              positionTo: SCNVector3(x: 0, y: 1.0, z: 0)),
        Block(data: [[[ 7,-1,-1],[ 7, 7,-1], ],
                     [[-1,-1,-1],[ 7,-1,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 7",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 3, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 0.0, z: 2.0),
              positionTo: SCNVector3(x: 1, y: 1, z: -1)),

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
        let yuan = SCNSphere(radius: 0.5)
        yuan.firstMaterial?.diffuse.contents = UIColor.black
        let yuanNode = SCNNode(geometry: yuan)
        yuanNode.position = SCNVector3(0, 0, 0)
        parNode2.addChildNode(yuanNode)
        parNode2.orgPosition = item.position;
        parNode2.rotationTo3 = item.rotationTo3;
        parNode2.positionTo = item.positionTo;
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

        }.navigationBarItems(trailing:completeStatus()).navigationTitle(Text("步数:\(stepcount)"))
    }
    func completeStatus() -> some View {
        Group {
            HStack {
                Button(action: {
                    counter += 1;
                    nodeList.forEach { node2 in
                        node2.position = node2.orgPosition ?? node2.position
                        node2.rotation = SCNVector4(0, 0, 0, 1)
                    }

                }, label: {
                    Text("重置\(counter)")
                })
                Button(action: {
                    actionmethod(index: 0)
                }, label: {
                    Text("演示")
                })
            }
        }
    }

    func actionmethod(index: Int) -> Void {
        guard index < nodeList.count else {
            print("over....\(index)")
            return
        }
        let reIndex = [3,4,5,1,7,6,2][index] - 1

        var rolist:[SCNAction] = []
        // 先移动到目标位置上方
        let rb0 = SCNAction.move(to: SCNVector3(nodeList[reIndex].positionTo.x, nodeList[reIndex].positionTo.y + 2, nodeList[reIndex].positionTo.z), duration: 1);
        rolist.append(rb0);

        // 增加x,y,z旋转动作
        if nodeList[reIndex].rotationTo3.x > 0 {
            rolist.append(SCNAction.rotate(by: .pi/2 * CGFloat(nodeList[reIndex].rotationTo3.x), around: SCNVector3(1, 0, 0), duration: 0.1));
        }
        if nodeList[reIndex].rotationTo3.y > 0 {
            rolist.append(SCNAction.rotate(by: .pi/2 * CGFloat(nodeList[reIndex].rotationTo3.y), around: SCNVector3(0, 1, 0), duration: 0.2));
        }
        if nodeList[reIndex].rotationTo3.z > 0 {
            rolist.append(SCNAction.rotate(by: .pi/2 * CGFloat(nodeList[reIndex].rotationTo3.z), around: SCNVector3(0, 0, 1), duration: 0.3));
        }
        // 再移动到目标位置
        let rb = SCNAction.move(to: nodeList[reIndex].positionTo, duration: 1);
        rolist.append(rb);
        // 只能用sequence，group 就不对了
        nodeList[reIndex].runAction(SCNAction.sequence(rolist), completionHandler: {
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
    func zhuan(_ des: LVAxis) {
        if let aa = nodeList.filter({ node in
            node.name == blockName
        }).first {

            switch des {
            case .x:
                aa.rotationTo3.x += 1;
                aa.runAction(SCNAction.routeXPI_2(duration: 0.1))
            case .y:
                aa.rotationTo3.y += 1;
                aa.runAction(SCNAction.routeYPI_2(duration: 0.1))
            case .z:
                aa.rotationTo3.z += 1;
                aa.runAction(SCNAction.routeZPI_2(duration: 0.1))
            }
        }
        stepcount += 1;
    }

    func rotationView() -> some View {
        VStack {
            CustomButton(title: "旋转X") {zhuan(.x)}
            CustomButton(title: "旋转Y") {zhuan(.y)}
            CustomButton(title: "旋转Z")  {zhuan(.z)}
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
            print("node:\(node.name ?? ""),rotation:\(node.rotationTo3), position:\(node.position)")
        }
    }

    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
         lognodeInfo()
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
        static var orgPosition = "orgPosition"
        static var rotationTo3 = "rotationTo3"
        static var positionTo = "positionTo"
    }

    var orgPosition: SCNVector3? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.orgPosition) as? SCNVector3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.orgPosition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    var rotationTo3: SCNVector3 {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rotationTo3) as! SCNVector3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rotationTo3, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var positionTo: SCNVector3 {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.positionTo) as! SCNVector3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.positionTo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
