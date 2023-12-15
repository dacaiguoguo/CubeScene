//
//  SingleContentView2.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit

enum LVAxis {
    case x
    case y
    case z
}

extension PointInfo {
    var location: SCNVector3 {
        SCNVector3(x, y, z)
    }
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
    var result:Matrix3D  = []
    result2.forEach { inner in
        result.append(inner.reversed())
    }
    return result
}

func mapColorIndex(_ index:Int) -> Int {
    switch (index) {
    case 86:// V
        return 1
    case 76:// L
        return 2;
    case 84:// T
        return 3;
    case 90:// Z
        return 4;
    case 65:// A
        return 5;
    case 66:// B
        return 6;
    case 80:// P
        return 7;
    default:
        return index
    }
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

func makeCombinedMatrix(order:[(String, Float)], position:SCNVector3) -> SCNMatrix4 {
    // 绕Z轴旋转180度
    // 定义绕Z轴和X轴的旋转角度
    var vvv = SCNMatrix4Identity;
    for somex in order {
        if somex.0 == "x" , somex.1 > 0 {
            // 创建绕X轴的旋转矩阵
            vvv = SCNMatrix4Mult(vvv, SCNMatrix4MakeRotation(Float.pi / 2 * somex.1, 1, 0, 0))
        }
        if somex.0 == "y" , somex.1 > 0 {
            // 创建绕X轴的旋转矩阵
            vvv = SCNMatrix4Mult(vvv, SCNMatrix4MakeRotation(Float.pi / 2 * somex.1, 0, 1, 0))
        }
        if somex.0 == "z" , somex.1 > 0 {
            // 创建绕X轴的旋转矩阵
            vvv = SCNMatrix4Mult(vvv, SCNMatrix4MakeRotation(Float.pi / 2 * somex.1, 0, 0, 1))
        }
    }
    vvv.m41 = position.x
    vvv.m42 = position.y
    vvv.m43 = position.z
    return vvv
}

// 这里有个问题 就是三维数组 最前面的是最底层了，但是 其实应该是最上层。
// 解决方法 最好是处理数据。
// todo 自定义顺序
func makeNode(with result2: Matrix3D) -> [SCNNode] {
    // let result = transMatrix(with: result2)
    
    let pointInfo3DArray = mapTo3DPointInfo(array3d: result2);
    let lResult:[PointInfo] = hasContinuousEqualValues(pointInfo3DArray: pointInfo3DArray)
    print(lResult)
    
    
    func v3Add(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    let maped =  lResult.map { lpoint in
        let value = lpoint.value
        let location = lpoint.location
        print("boxNode2.position value:\(value) \(location)")
        
        // 这是初始位置
        let positionOrgList = [[4,0,-4],[4,0,0],[4,0,4],[0,0,4],[-4,0,4],[-4,0,0],[-4,0,-4],[0,0,-4]].map{SCNVector3($0[0], $0[1], $0[2])}
        let colors:[UIColor] = [
            UIColor(hex: "000000"),
            UIColor(hex: "5B5B5B"),
            UIColor(hex: "C25C1D"),
            UIColor(hex: "2788e7"),
            UIColor(hex: "FA2E34"),
            UIColor(hex: "FB5BC2"),
            UIColor(hex: "FCC633"),
            UIColor(hex: "178E20"),
        ]
        
        
        //         let yuan = SCNSphere(radius: 0.5)
        let yuan = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
        
        let indexValue = mapColorIndex(value)
        if value > colors.count - 1 {
            yuan.firstMaterial?.diffuse.contents = colors[indexValue].withAlphaComponent(0.85)
        } else {
            yuan.firstMaterial?.diffuse.contents = colors[indexValue].withAlphaComponent(1.0)
        }
        let yuanNode = SCNNode(geometry: yuan)
        yuanNode.positionTo = v3Add(left:location, right:SCNVector3Make(Float(-1), Float(-1), Float(-1)))
        yuanNode.position = v3Add(left:positionOrgList[indexValue], right:SCNVector3Make(Float(-1), Float(-1), Float(-1)))
        yuanNode.orgPosition = yuanNode.position
        yuanNode.name = "块 \(value)"
        if lpoint.value == 2 {
            if lpoint.des == "up, left" {
                yuanNode.rotationTo = SCNVector4(x: 0.0, y: 0.0, z: 1.0, w: .pi)
            }
            
            if lpoint.des == "front, left" {
                yuanNode.transform = makeCombinedMatrix(order: [("y", 1.0), ("x", 2.0),], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "back, up" {
                yuanNode.transform = makeCombinedMatrix(order: [("z", 3.0), ("x", 1.0),], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "left, up" {
                yuanNode.transform = makeCombinedMatrix(order: [("x", 1.0), ], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "left, back" {
                yuanNode.transform = makeCombinedMatrix(order: [("z", 1.0),("y", 1.0), ], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "left, front" {
                yuanNode.transform = makeCombinedMatrix(order: [("y", 3.0),("x", 1.0), ], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "left, down" {
                yuanNode.transform = makeCombinedMatrix(order: [("y", 2.0),("x", 1.0), ], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "right, up" {
                yuanNode.transform = makeCombinedMatrix(order: [("z", 2.0),("x", 1.0), ], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "right, back" {
                yuanNode.transform = makeCombinedMatrix(order: [("x", 3.0),("z", 1.0), ], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
            if lpoint.des == "right, down" {
                yuanNode.rotationTo = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: -.pi/2)
            }
            if lpoint.des == "right, front" {
                yuanNode.transform = makeCombinedMatrix(order: [("y", 1.0),("x", 3.0), ], position: yuanNode.position);
                yuanNode.transformTo = yuanNode.transform
            }
        }
        if let rt = yuanNode.rotationTo {
            yuanNode.rotation = rt
        }
        lpoint.children.forEach { child in
            // 根据keypath查找下一个点
            let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
            if value > colors.count - 1 {
                box2.firstMaterial?.diffuse.contents = colors[indexValue].withAlphaComponent(0.85)
            } else {
                box2.firstMaterial?.diffuse.contents = colors[indexValue].withAlphaComponent(0.71)
            }
            let boxNode2 = SCNNode()
            boxNode2.geometry = box2
            boxNode2.name = "\(value)"
            
            boxNode2.position = SCNVector3(x: Float(child.x - Int(location.x)),
                                           y: Float(child.y - Int(location.y)),
                                           z: Float(child.z - Int(location.z)));
            print("boxNode21.position  value:\(value) \(boxNode2.position)")
            yuanNode.addChildNode(boxNode2)
            
        }
        
        print("boxNode2.position over")
        
        return yuanNode
    }
    return maped
    
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
            node2.rotation = node2.rotationTo ?? node2.rotation
            node2.transform = node2.transformTo ?? node2.transform;
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
        let destPosition = nodeList[index].positionTo!;
        actionList.append(SCNAction.rotate(toAxisAngle: SCNVector4Zero, duration: 0.2));
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

extension SCNNode {
    private struct AssociatedKeys {
        static var orgPosition: UInt8 = 0
        static var positionTo: UInt8 = 0
        static var rotationTo: UInt8 = 0
        static var transformTo: UInt8 = 0
    }
    
    var orgPosition: SCNVector3? {
        get {
            return withUnsafePointer(to: &AssociatedKeys.orgPosition) { pointer in
                return objc_getAssociatedObject(self, pointer) as? SCNVector3
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.orgPosition) { pointer in
                objc_setAssociatedObject(self, pointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var rotationTo: SCNVector4? {
        get {
            return withUnsafePointer(to: &AssociatedKeys.rotationTo) { pointer in
                return objc_getAssociatedObject(self, pointer) as? SCNVector4
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.rotationTo) { pointer in
                objc_setAssociatedObject(self, pointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var transformTo: SCNMatrix4? {
        get {
            return withUnsafePointer(to: &AssociatedKeys.transformTo) { pointer in
                return objc_getAssociatedObject(self, pointer) as? SCNMatrix4
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.transformTo) { pointer in
                objc_setAssociatedObject(self, pointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var positionTo: SCNVector3? {
        get {
            return withUnsafePointer(to: &AssociatedKeys.positionTo) { pointer in
                return objc_getAssociatedObject(self, pointer) as? SCNVector3
            }
        }
        set {
            withUnsafePointer(to: &AssociatedKeys.positionTo) { pointer in
                objc_setAssociatedObject(self, pointer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
