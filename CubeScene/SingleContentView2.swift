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
    // 这里是块的位置，注意，z是第一个？？？，
    static let positionlist = [[0,0,0],[2,0,0],[1,0,0],[0,2,1],[1,2,1],[1,0,2],[1,2,0]];
    // [[[0,0,0],[2,3,0],[2,3,3]],
    //  [[2,5,5],[2,4,5],[6,4,4]],
    //  [[1,1,1],[6,1,5],[6,6,4]]],
    // 0 是形状2, 1是形状3， 2是4， 3是1
    static let nodata = [
        [[[0,0,0],[9,9,0]],
         [[9,9,9],[9,9,0]]],
        [[[1,1,1],[9,1,9]],
         [[9,9,9],[9,9,9]]],
        [[[2,9,9],[9,9,9]],
         [[2,2,9],[9,9,9]],
         [[9,2,9],[9,9,9]]
        ],
        [[[3,3,9],[9,9,9]],
         [[3,9,9],[9,9,9]]],
    ];
    static let rotation = [[1,1,1],[1,1,1],[2,2,3],[1,2,2],[1,2,2],[1,4,4],[1,1,3]];

    
    static var dataList:[Block] = {
        let zippedArray = zip(zip(nodata, positionlist),rotation)
        return zippedArray.map {(tuple, rotai) in
            let (data, posi) = tuple
            return Block(data: data,
                  name: "块 1",
                  rotation: SCNVector3Zero,
                  position: SCNVector3(posi[0], posi[1], posi[2]),
                  rotationTo3: SCNVector3(rotai[0], rotai[1], rotai[2]),
                  positionTo: SCNVector3(x: 1, y: 0.0, z: 1))
        }
    }()
    // 两个长度相同的数组 同时map到一个对象里
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
                    boxNode2.position = SCNVector3Make(Float(z), Float(y), Float(x))
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
