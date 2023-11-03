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

func makeNode(destPosition:[SCNVector3], result: Matrix3D) -> [SCNNode] {

    func findFirstOccurrence(of value: Int, in array: Matrix3D) -> (x: Int, y: Int, z: Int)? {
        for (x, outerArray) in array.enumerated() {
            for (y, middleArray) in outerArray.enumerated() {
                for (z, innerArray) in middleArray.enumerated() {
                    if innerArray == value {
                        return (x, y, z)
                    }
                }
            }
        }
        return nil
    }
    func findUniqueValues(in array: Matrix3D) -> [(Int, SCNVector3)] {
        var uniqueValues:[(Int, SCNVector3)]  = []
        for (x, outerArray) in array.enumerated() {
            for (y, middleArray) in outerArray.enumerated() {
                for (z, value) in middleArray.enumerated() {
                    if uniqueValues.first(where: {item in item.0 == value}) == nil {
                        uniqueValues.append((value, SCNVector3(z,y,x)))
                    }
                }
            }
        }
        return uniqueValues
    }
    let findResult = findUniqueValues(in: result);
    print("findUniqueValues(in: result)\(findResult.count)")
    return findResult.map { (value, location) in
        // 这是初始位置
        let positionOrgList = [[4,0,0],[4,4,0],[0,4,0],[-4,4,0],[-4,0,0],[-4,-4,0],[0,-4,0]].map{SCNVector3($0[0], $0[1], $0[2])}


        let colors:[UIColor] = [UIColor(hex: "000000").withAlphaComponent(0.95),
                                UIColor(hex: "5B5B5B").withAlphaComponent(0.95),
                                UIColor(hex: "C25C1D").withAlphaComponent(0.95),
                                UIColor(hex: "2788e7").withAlphaComponent(0.95),
                                UIColor(hex: "FA2E34").withAlphaComponent(0.95),
                                UIColor(hex: "FB5BC2").withAlphaComponent(0.95),
                                UIColor(hex: "FCC633").withAlphaComponent(0.95),
                                UIColor(hex: "178E20").withAlphaComponent(0.95),
        ]

        let yuan = SCNSphere(radius: 0.5)
        yuan.firstMaterial?.diffuse.contents = colors[value].withAlphaComponent(1)
        let yuanNode = SCNNode(geometry: yuan)
        yuanNode.positionTo = location
        yuanNode.position = positionOrgList[value]
        yuanNode.orgPosition = positionOrgList[value]
        yuanNode.name = "块 \(value)"
        yuanNode.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: .pi / 2)
        let rows = result.count  // 第一维
        let columns = result.first?.count ?? 0  // 第二维
        let depth = result.first?.first?.count ?? 0 // 第三维

        // 遍历三维数组
        for i in 0..<rows {
            for j in 0..<columns {
                for k in 0..<depth {
                    let value2 = result[k][j][i]
                    if value2 == value {
                        let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                        box2.firstMaterial?.diffuse.contents = colors[value]
                        let boxNode2 = SCNNode()
                        boxNode2.geometry = box2
                        boxNode2.name = "\(value)"
                        boxNode2.position = SCNVector3(x: Float(k - Int(location.x)), y: Float(j - Int(location.y)), z: Float(i - Int(location.z)));
                        yuanNode.addChildNode(boxNode2)
                    }
                }
            }
        }
        return yuanNode

    }
}


public struct SingleContentView2: View {


    // 这里是块的位置，注意，z是第一个？？0，    1       2       3       4       5       6
    // 目标postion好像并不重要。
    static let positionlist = [[0,0,0],[2,0,0],[1,0,0],[0,2,1],[1,2,1],[1,0,2],[1,2,0]].map{SCNVector3($0[0], $0[1], $0[2])}
    static let result =  [[[0,0,0],[2,3,0],[2,3,3]],
                          [[2,5,5],[2,4,5],[6,4,4]],
                          [[1,1,1],[6,1,5],[6,6,4]]];

    // 两个长度相同的数组 同时map到一个对象里
    let segments = {positionlist.enumerated().map { index, fruit in
        print("\(index + 1)")
        return "块 \(index + 1)"
    }}()

    @State private var counter = 0
    @State private var selectedSegment = 0
    @State private var nodeList:[SCNNode] = { makeNode(destPosition: positionlist, result: result)}()

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
                    counter += 1;
                    nodeList.forEach { node2 in
                        node2.position = node2.orgPosition ?? node2.position
                        node2.rotation = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: .pi / 2)
                    }
                }, label: {
                    Text("重置\(counter)")
                })
                Button(action: {
                    actionRunAt(index: 0)
                }, label: {
                    Text("演示")
                })
            }
        }
    }


    func actionRunAt(index: Int) -> Void {
        guard index < nodeList.count else {
            print("over....\(index)")
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
        }.pickerStyle(.segmented).padding(.horizontal)
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
