//
//  ToolsFunc.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/12/18.
//

import Foundation
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

extension UIColor {
    func darker(by percentage: CGFloat = 20.0) -> UIColor {
        return adjust(by: -abs(percentage))
    }

    func lighter(by percentage: CGFloat = 20.0) -> UIColor {
        return adjust(by: abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return UIColor(hue: h,
                           saturation: s,
                           brightness: min(max(b + percentage/100.0, 0.0), 1.0),
                           alpha: a)
        } else {
            return self
        }
    }
}

//// 使用示例
//let originalColor = UIColor(hex: "5B5B5B")
//let darkerColor = originalColor.darker(by: 20.0)
//let lighterColor = originalColor.lighter(by: 20.0)

extension SCNVector3 {
    static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
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

// TODO: 这里要找出再底部层 最多的一个，按照由多到少排序
func findUniqueValues(in result: Matrix3D) -> [Int] {
    let rows = result.count  // 第一维
    let columns = result.first?.count ?? 0  // 第二维
    let depth = result.first?.first?.count ?? 0 // 第三维
    
    var uniqueValues:[Int]  = []
    // 遍历三维数组
    for j in 0..<columns {
        let y = columns - 1 - j;
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

// todo 自定义顺序
func makeNode(with result2: Matrix3D) -> [SCNNode] {
    let rows = result2.count  // 第一维

    let pointInfo3DArray = mapTo3DPointInfo(array3d: result2);
    let lResulttemp:[PointInfo] = hasContinuousEqualValues(pointInfo3DArray: pointInfo3DArray)
    // assert(lResult.count == 7)
    let sort = findUniqueValues(in:result2);
    
    let lResult = lResulttemp.sorted { ap, bp in
        (sort.firstIndex(of: ap.value) ?? 0) < (sort.firstIndex(of: bp.value) ?? 0);
    }
    
    func v3Add(left:SCNVector3, right:SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, -left.y + right.y, left.z + right.z)
    }
    let maped =  lResult.map { lpoint in
        let value = lpoint.value
        let location = lpoint.location
        // print("boxNode2.position value:\(value) \(location)")
        
        // 这是初始位置
        let positionOrgList = [[5,0,-5],
                               [5,-5,-5],
                               [5,0,-5],
                               [10,0,-5],
                               [0,5,-5],
                               [5,5,-5],
                               [10,5,-5],
                               [0,0,-5]].map{SCNVector3($0[0], $0[1], $0[2])}
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
        
        let indexValue = mapColorIndex(value)
        let yuanNode = SCNNode()
        yuanNode.positionTo = v3Add(left:location, right:SCNVector3Make(Float(-1), Float(rows-1), Float(-1)))
        yuanNode.position = v3Add(left:positionOrgList[indexValue], right:SCNVector3Make(Float(-1), Float(rows-1), Float(-1)))
        yuanNode.name = "yuanNode"
        yuanNode.orgPosition = yuanNode.position
        
        let yuanInner = SCNSphere(radius: 0.55)
        yuanInner.firstMaterial?.diffuse.contents = UIColor.black //colors[indexValue].darker()
        let yuanNodeInner = SCNNode(geometry: yuanInner)
        yuanNode.addChildNode(yuanNodeInner)
        
        yuanNode.name = lpoint.name
        zhuanNode(lpoint, yuanNode: yuanNode)
        
        lpoint.children.forEach { child in
            // 根据keypath查找下一个点
            let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
            if value > colors.count - 1 {
                box2.firstMaterial?.diffuse.contents = colors[indexValue].withAlphaComponent(0.85)
            } else {
                box2.firstMaterial?.diffuse.contents = colors[indexValue].withAlphaComponent(1.0)
            }
            
            let yuanInner = SCNSphere(radius: 0.55)
            yuanInner.firstMaterial?.diffuse.contents = colors[indexValue].darker()
            let yuanNodeInner = SCNNode(geometry: yuanInner)
            
            let boxNode2 = SCNNode()
            boxNode2.addChildNode(yuanNodeInner)

            boxNode2.geometry = box2
            boxNode2.name = "\(value)"
            
            boxNode2.position = SCNVector3(x: Float(child.x - Int(location.x)),
                                           y: -Float(child.y - Int(location.y)),
                                           z: Float(child.z - Int(location.z)));
            // print("boxNode21.position  value:\(value) \(boxNode2.position)")
            yuanNode.addChildNode(boxNode2)
            
        }
        
        // print("boxNode2.position over")
        
        return yuanNode
    }
    return maped
    
}


func zhuanNode(_ lpoint: PointInfo, yuanNode: SCNNode) -> Void {
    
    if lpoint.value == 2 {
        if lpoint.des == "up, left" {
            yuanNode.rotationTo = SCNVector4(x: 0.0, y: 0.0, z: 1.0, w: .pi)
        }
        
        if lpoint.des == "front, left" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("y", 1.0), ("x", 2.0),], position: yuanNode.position);
        }
        if lpoint.des == "back, up" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("z", 3.0), ("x", 1.0),], position: yuanNode.position);
        }
        if lpoint.des == "left, up" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("x", 1.0), ], position: yuanNode.position);
        }
        if lpoint.des == "left, back" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("z", 1.0),("y", 1.0), ], position: yuanNode.position);
        }
        if lpoint.des == "left, front" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("y", 3.0),("x", 1.0), ], position: yuanNode.position);
        }
        if lpoint.des == "left, down" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("y", 2.0),("x", 1.0), ], position: yuanNode.position);
        }
        if lpoint.des == "right, up" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("z", 2.0),("x", 1.0), ], position: yuanNode.position);
        }
        if lpoint.des == "right, back" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("x", 3.0),("z", 1.0), ], position: yuanNode.position);
        }
        if lpoint.des == "down, back" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("x", 3.0),("z", 1.0), ], position: yuanNode.position);
        }
        
        if lpoint.des == "right, down" {
            yuanNode.rotationTo = SCNVector4(x: 1.0, y: 0.0, z: 0.0, w: -.pi/2)
        }
        if lpoint.des == "right, front" {
            yuanNode.transformTo = makeCombinedMatrix(order: [("y", 1.0),("x", 3.0), ], position: yuanNode.position);
        }
    } else {
        yuanNode.rotationTo = SCNVector4(x: 0.0, y: 0.0, z: 1.0, w: .pi / 2 )
    }
    if let rt = yuanNode.rotationTo {
        yuanNode.rotation = rt
    }
    if let rt = yuanNode.transformTo {
        yuanNode.transform = rt
    }
}
