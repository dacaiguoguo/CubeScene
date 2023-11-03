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

func transMatrix(with result2: Matrix3D) -> Matrix3D {
    let resulttmp = result2.map { mid in
        mid.map { innter in
            innter.map {value in return value - 1}
        }
    }
    let rows = resulttmp.count  // 第一维

    var result:Matrix3D  = []
    // 遍历三维数组
    for j in 0..<rows {
        let y = rows - 1 - j;
        result.append(Array(resulttmp[y].reversed()))
    }
    return result
}

// 这里有个问题 就是三维数组 最前面的是最底层了，但是 其实应该是最上层。
// 解决方法 最好是处理数据。
// todo 自定义顺序
func makeNode(with result: Matrix3D) -> [SCNNode] {
    // let result = transMatrix(with: result2)
    func findFirstOccurrence(of value: Int, in array: Matrix3D) -> SCNVector3 {
        let rows = result.count  // 第一维
        let columns = result.first?.count ?? 0  // 第二维
        let depth = result.first?.first?.count ?? 0 // 第三维

        // 遍历三维数组
        for j in 0..<columns {
            let y = j;//columns - 1 - j;
            for i in 0..<rows {
                for k in 0..<depth {
                    let innerArray = result[i][y][k]
                    if innerArray == value {
                        return SCNVector3(k, y, i)
                    }
                }
            }
        }
        return SCNVector3Zero
    }
    func findUniqueValues(in result: Matrix3D) -> [Int] {
        let rows = result.count  // 第一维
        let columns = result.first?.count ?? 0  // 第二维
        let depth = result.first?.first?.count ?? 0 // 第三维

        var uniqueValues:[Int]  = []
        // 遍历三维数组
        for j in 0..<columns {
            let y = j;//columns - 1 - j;
            for i in 0..<rows {
                for k in 0..<depth {
                    let thenumber = result[i][y][k]
                    if thenumber >= 0 && !uniqueValues.contains(thenumber) {
                        uniqueValues.append(thenumber)
                    }
                }
            }
        }
        return uniqueValues
    }
    let findResult = findUniqueValues(in: result).map { item in
        (item, findFirstOccurrence(of: item, in: result))
    };
    return findResult.map { (value, location) in
        // 这是初始位置
        let positionOrgList = [[4,0,0],[4,0,4],[0,0,4],[-4,0,4],[-4,0,0],[-4,0,-4],[0,0,-4]].map{SCNVector3($0[0], $0[1], $0[2])}


        let colors:[UIColor] = [
                                UIColor(hex: "5B5B5B").withAlphaComponent(0.85),
                                UIColor(hex: "C25C1D").withAlphaComponent(0.85),
                                UIColor(hex: "2788e7").withAlphaComponent(0.85),
                                UIColor(hex: "FA2E34").withAlphaComponent(0.85),
                                UIColor(hex: "FB5BC2").withAlphaComponent(0.85),
                                UIColor(hex: "FCC633").withAlphaComponent(0.85),
                                UIColor(hex: "178E20").withAlphaComponent(0.85),
                                UIColor(hex: "000000").withAlphaComponent(0.85),
        ]

        let yuan = SCNSphere(radius: 0.5)
        yuan.firstMaterial?.diffuse.contents = colors[value].withAlphaComponent(1)
        let yuanNode = SCNNode(geometry: yuan)
        yuanNode.positionTo = location
        yuanNode.position = positionOrgList[value]
        yuanNode.orgPosition = positionOrgList[value]
        yuanNode.name = "块 \(value + 1)"
        yuanNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: .pi / 2)
        let rows = result.count  // 第一维
        let columns = result.first?.count ?? 0  // 第二维
        let depth = result.first?.first?.count ?? 0 // 第三维

        // 遍历三维数组
        for i in 0..<rows {
            for j in 0..<columns {
                for k in 0..<depth {
                    let value2 = result[i][j][k]
                    if value2 == value {
                        let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                        box2.firstMaterial?.diffuse.contents = colors[value]
                        let boxNode2 = SCNNode()
                        boxNode2.geometry = box2
                        boxNode2.name = "\(value)"
//                        boxNode2.position = SCNVector3(x: Float(k - Int(location.x)), y: Float(j - Int(location.y)), z: Float(i - Int(location.z)));
                        boxNode2.position = SCNVector3(x: Float(k - Int(location.x)),
                                                       y: Float(j - Int(location.y)),
                                                       z: Float(i - Int(location.z)));
                        yuanNode.addChildNode(boxNode2)
                    }
                }
            }
        }
        return yuanNode

    }
}


public struct SingleContentView2: View {

    let segments = {[1,2,3,4,5,6,7].map { index in
        return "块 \(index)"
    }}()

    @State private var counter = 0
    @State private var selectedSegment = 0
    @State var nodeList:[SCNNode]
//    { makeNode(with result: result)}()

    @State private var stepcount = 0 {
        didSet {
            triggerHapticFeedback()
        }
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
                    reset()
                }, label: {
                    Text("重置\(counter)")
                })
                Button(action: {
                    reset()
                    actionRunAt(index: 0)
                }, label: {
                    Text("演示")
                })
            }
        }
    }

    func reset() {
        counter += 1;
        nodeList.forEach { node2 in
            node2.position = node2.orgPosition ?? node2.position
            node2.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: .pi / 2)
        }
    }

    func actionRunAt(index: Int) -> Void {
        guard index < nodeList.count else {
            return
        }
        var actionList:[SCNAction] = []
        var topPosition = nodeList[index].positionTo!;
        topPosition.y += 5;
        actionList.append(SCNAction.move(to: topPosition, duration: 0.2));
        actionList.append(SCNAction.rotate(by: -.pi / 2, around: SCNVector3(1, 0, 0), duration: 0.2))
        let destPosition = nodeList[index].positionTo!;
        actionList.append(SCNAction.move(to: destPosition, duration: 0.2));
        nodeList[index].runAction(SCNAction.sequence(actionList), completionHandler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                actionRunAt(index: index + 1);
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
        }.pickerStyle(.segmented).padding()
    }

    func rotationMethod(_ axis: LVAxis) {
        if let cnode = nodeList.filter({ node in
            node.name == blockName
        }).first {
            switch axis {
            case .x:
                cnode.runAction(SCNAction.routeXPI_2(duration: 0.1))
            case .y:
                cnode.runAction(SCNAction.routeYPI_2(duration: 0.1))
            case .z:
                cnode.runAction(SCNAction.routeZPI_2(duration: 0.1))
            }
        }
        stepcount += 1;
    }

    func rotationView() -> some View {
        VStack {
            CustomButton(title: "旋转X") {rotationMethod(.x)}
            CustomButton(title: "旋转Y") {rotationMethod(.y)}
            CustomButton(title: "旋转Z")  {rotationMethod(.z)}
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
            print("node:\(node.name ?? ""),rotation:\(node.rotation), position:\(node.position)")
        }
    }

    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        // lognodeInfo()
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


    var positionTo: SCNVector3? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.positionTo) as? SCNVector3
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.positionTo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
