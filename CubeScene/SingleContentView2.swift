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

    static let colors:[UIColor] = [UIColor(hex: "000000").withAlphaComponent(0.65),
                                   UIColor(hex: "5B5B5B").withAlphaComponent(0.65),
                                   UIColor(hex: "C25C1D").withAlphaComponent(0.65),
                                   UIColor(hex: "2788e7").withAlphaComponent(0.65),
                                   UIColor(hex: "FA2E34").withAlphaComponent(0.65),
                                   UIColor(hex: "FB5BC2").withAlphaComponent(0.65),
                                   UIColor(hex: "FCC633").withAlphaComponent(0.65),
                                   UIColor(hex: "178E20").withAlphaComponent(0.65),
    ]
    // 这里是块的位置，注意，z是第一个？？0，    1       2       3       4       5       6
    static let positionlist = [[0,0,0],[2,0,0],[1,0,0],[0,2,1],[1,2,1],[1,0,2],[1,2,0]];
    static let result =  [[[0,0,0],[2,3,0],[2,3,3]],[[2,5,5],[2,4,5],[6,4,4]],[[1,1,1],[6,1,5],[6,6,4]]];
    // 0 是形状2, 1是形状3， 2是4， 3是1， 4是5， 5是6，6是7
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

    static let rotation = [[1,1,1],[1,1,1],[2,2,3],[1,2,2],[1,2,2],[1,4,4],[1,1,3]].map{SCNVector3($0[0], $0[1], $0[2])}
    static let positionDestlist = [[4,0,0],[4,4,0],[0,4,0],[-4,4,0],[-4,0,0],[-4,-4,0],[0,-4,0]].map{SCNVector3($0[0], $0[1], $0[2])}

    static var dataList:[Block] = {
        let zippedArray = zip(zip(nodata, positionlist),rotation)
        return zippedArray.map {(tuple, rotai) in
            let (data, posi) = tuple
            return Block(data: data,
                  name: "块 1",
                  rotation: SCNVector3Zero,
                  position: SCNVector3(posi[0], posi[1], posi[2]),
                  rotationTo3: rotai,
                  positionTo: SCNVector3(x: 1, y: 0.0, z: 1))
        }
    }()
    // 两个长度相同的数组 同时map到一个对象里
    let segments = {dataList.map { $0.name }}()
    @State private var counter = 0
    @State private var selectedSegment = 0
    @State private var nodeList:[SCNNode] = { positionlist.enumerated().map { index, item in
        let yuan = SCNSphere(radius: 0.5)
        yuan.firstMaterial?.diffuse.contents = colors[index].withAlphaComponent(1)
        let yuanNode = SCNNode(geometry: yuan)
        yuanNode.positionTo = SCNVector3(item[0], item[1], item[2])
        yuanNode.position = positionDestlist[index]
        let rows = result.count  // 第一维
        let columns = result.first?.count ?? 0  // 第二维
        let depth = result.first?.first?.count ?? 0 // 第三维
        
        // 遍历三维数组
        for i in 0..<rows {
            for j in 0..<columns {
                for k in 0..<depth {
                    let value = result[k][j][i]
                    if value == index {
                        let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                        box2.firstMaterial?.diffuse.contents = colors[index]
                        let boxNode2 = SCNNode()
                        boxNode2.geometry = box2
                        boxNode2.name = "\(value)"
                        boxNode2.position = SCNVector3(x: Float(k - item[0]), y: Float(j - item[1]), z: Float(i - item[2]));
//                        SCNVector3(k,j,i) - SCNVector3Zero;
                        yuanNode.addChildNode(boxNode2)
                    }
                    print("Element at (\(i), \(j), \(k)) is \(value)")
                }
            }
        }
        return yuanNode;
    }}()

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
                    if value == -1 || value > 7 {
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

                    actionmethod2(index: 0)
                }, label: {
                    Text("演示")
                })
            }
        }
    }


    func actionmethod2(index: Int) -> Void {
        guard index < nodeList.count else {
            print("over....\(index)")
            return
        }
        let rotai = SingleContentView2.rotation[index];
        let posi = nodeList[index].positionTo;

        var rolist:[SCNAction] = []

//        if rotai.z > 1 {
//            rolist.append(SCNAction.rotate(by: -.pi/2 * CGFloat(rotai.z - 1), around: SCNVector3(0, 0, 1), duration: 0.2));
//        }
//
//        if rotai.y > 1 {
//            rolist.append(SCNAction.rotate(by: -.pi/2 * CGFloat(rotai.y - 1), around: SCNVector3(0, 1, 0), duration: 0.2));
//        }
//        // 增加x,y,z旋转动作
//        if rotai.x > 1 {
//            rolist.append(SCNAction.rotate(by: -.pi/2 * CGFloat(rotai.x - 1), around: SCNVector3(1, 0, 0), duration: 0.1));
//        }
        var posi0 = nodeList[index].positionTo;
        posi0.y += 5;
        let rb0 = SCNAction.move(to: posi0, duration: 0.1);
        rolist.append(rb0);

        let rb = SCNAction.move(to: posi, duration: 0.1);
        rolist.append(rb);

        nodeList[index].runAction(SCNAction.sequence(rolist), completionHandler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                actionmethod2(index: index + 1);
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
