//
//  PointInfo.swift
//  FindBlock
//
//  Created by yanguo sun on 2023/11/2.
//

import Foundation

enum Direction {
    case up
    case down
    case left
    case right
    case forward
    case backward
    case bottomRotation90Degrees(BottomRotationDirection)

    enum BottomRotationDirection {
        case clockwise
        case counterclockwise
        case forward
        case backward
    }

    static var allCases: [Direction] {
        return [.up, .down, .left, .right, .forward, .backward] +
            BottomRotationDirection.allCases.map { .bottomRotation90Degrees($0) }
    }
}

extension Direction.BottomRotationDirection: CaseIterable {}


class PointInfo : CustomDebugStringConvertible  {
    let x: Int
    let y: Int
    let z: Int
    let value: Int
    var up: PointInfo?
    var down: PointInfo?
    var left: PointInfo?
    var right: PointInfo?
    var front: PointInfo?
    var back: PointInfo?
    
    var des: String = ""
    var children: [PointInfo] = []
    
    static let preList = [[\PointInfo.up,
                            \PointInfo.down,],
                          [\PointInfo.left,
                            \PointInfo.right],
                          [\PointInfo.front,
                            \PointInfo.back,]]
    
    static let allKeyList = [\PointInfo.up,
                              \PointInfo.down,
                              \PointInfo.left,
                              \PointInfo.right,
                              \PointInfo.front,
                              \PointInfo.back,]
    class func checkList(_ ss:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> [ ReferenceWritableKeyPath<PointInfo, PointInfo?>] {
        var ret:[ReferenceWritableKeyPath<PointInfo, PointInfo?>] = []
        for aa in preList {
            if !aa.contains(ss) {
                ret.append(contentsOf: aa)
            }
        }
        return ret
    }
    
    class func checkList3(_ ss:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> [[ReferenceWritableKeyPath<PointInfo, PointInfo?>]] {
        var ret:[[ReferenceWritableKeyPath<PointInfo, PointInfo?>]] = []
        for aa in preList {
            if !aa.contains(ss) {
                ret.append(aa)
            }
        }
        return ret
    }
    class func checkList4(_ ss:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> ReferenceWritableKeyPath<PointInfo, PointInfo?> {
        for aa in preList {
            if aa.contains(ss) {
                if let temp = aa.filter({ ap in
                    ap != ss
                }).first {
                    return temp
                }
            }
        }
        assert(false)
        return \PointInfo.up
    }
    
    
    // 根据两个 KeyPath 计算第三个 KeyPath 的方法
    class func calculateThirdKeyPath5(_ firstKeyPath: ReferenceWritableKeyPath<PointInfo, PointInfo?>,
                                      _ secondKeyPath: ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> ReferenceWritableKeyPath<PointInfo, PointInfo?>? {
        switch (firstKeyPath, secondKeyPath) {
        case (\PointInfo.up, \PointInfo.right):
            return \PointInfo.back
        case (\PointInfo.up, \PointInfo.left):
            return \PointInfo.front
        case (\PointInfo.up, \PointInfo.front):
            return \PointInfo.right
        case (\PointInfo.up, \PointInfo.back):
            return \PointInfo.left
            
        case (\PointInfo.down, \PointInfo.right):
            return \PointInfo.front
        case (\PointInfo.down, \PointInfo.left):
            return \PointInfo.back
        case (\PointInfo.down, \PointInfo.front):
            return \PointInfo.left
        case (\PointInfo.down, \PointInfo.back):
            return \PointInfo.right
            
        case (\PointInfo.left, \PointInfo.up):
            return \PointInfo.back
        case (\PointInfo.left, \PointInfo.down):
            return \PointInfo.front
        case (\PointInfo.left, \PointInfo.front):
            return \PointInfo.up
        case (\PointInfo.left, \PointInfo.back):
            return \PointInfo.down
            
        case (\PointInfo.right, \PointInfo.up):
            return \PointInfo.front
        case (\PointInfo.right, \PointInfo.down):
            return \PointInfo.back
        case (\PointInfo.right, \PointInfo.front):
            return \PointInfo.down
        case (\PointInfo.right, \PointInfo.back):
            return \PointInfo.up
            
        case (\PointInfo.front, \PointInfo.up):
            return \PointInfo.left
        case (\PointInfo.front, \PointInfo.down):
            return \PointInfo.right
        case (\PointInfo.front, \PointInfo.left):
            return \PointInfo.down
        case (\PointInfo.front, \PointInfo.right):
            return \PointInfo.up
            
        case (\PointInfo.back, \PointInfo.up):
            return \PointInfo.right
        case (\PointInfo.back, \PointInfo.down):
            return \PointInfo.left
        case (\PointInfo.back, \PointInfo.left):
            return \PointInfo.up
        case (\PointInfo.back, \PointInfo.right):
            return \PointInfo.down
            
        default:
            return nil
        }
    }
    
    // 根据两个 KeyPath 计算第三个 KeyPath 的方法（右手定则）
    class func calculateThirdKeyPath6(_ firstKeyPath: ReferenceWritableKeyPath<PointInfo, PointInfo?>,
                                      _ secondKeyPath: ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> ReferenceWritableKeyPath<PointInfo, PointInfo?>? {
        switch (firstKeyPath, secondKeyPath) {
        case (\PointInfo.up, \PointInfo.right):
            return \PointInfo.front
        case (\PointInfo.up, \PointInfo.left):
            return \PointInfo.back
        case (\PointInfo.up, \PointInfo.front):
            return \PointInfo.left
        case (\PointInfo.up, \PointInfo.back):
            return \PointInfo.right
            
        case (\PointInfo.down, \PointInfo.right):
            return \PointInfo.back
        case (\PointInfo.down, \PointInfo.left):
            return \PointInfo.front
        case (\PointInfo.down, \PointInfo.front):
            return \PointInfo.right
        case (\PointInfo.down, \PointInfo.back):
            return \PointInfo.left
            
        case (\PointInfo.left, \PointInfo.up):
            return \PointInfo.front
        case (\PointInfo.left, \PointInfo.down):
            return \PointInfo.back
        case (\PointInfo.left, \PointInfo.front):
            return \PointInfo.down
        case (\PointInfo.left, \PointInfo.back):
            return \PointInfo.up
            
        case (\PointInfo.right, \PointInfo.up):
            return \PointInfo.back
        case (\PointInfo.right, \PointInfo.down):
            return \PointInfo.front
        case (\PointInfo.right, \PointInfo.front):
            return \PointInfo.up
        case (\PointInfo.right, \PointInfo.back):
            return \PointInfo.down
            
        case (\PointInfo.front, \PointInfo.up):
            return \PointInfo.right
        case (\PointInfo.front, \PointInfo.down):
            return \PointInfo.left
        case (\PointInfo.front, \PointInfo.left):
            return \PointInfo.up
        case (\PointInfo.front, \PointInfo.right):
            return \PointInfo.down
            
        case (\PointInfo.back, \PointInfo.up):
            return \PointInfo.left
        case (\PointInfo.back, \PointInfo.down):
            return \PointInfo.right
        case (\PointInfo.back, \PointInfo.left):
            return \PointInfo.down
        case (\PointInfo.back, \PointInfo.right):
            return \PointInfo.up
            
        default:
            return nil
        }
    }
    
    init(x: Int, y: Int, z: Int, value: Int) {
        self.x = x
        self.y = y
        self.z = z
        self.value = value
    }
    
    var debugDescription: String {
        "(x:\(x), y:\(y), z:\(z), value:\(value))"
    }
}


func mapTo3DPointInfo(array3d: [[[Int]]]) -> [[[PointInfo]]] {
    let rows = array3d.count
    let cols = array3d[0].count
    let depth = array3d[0][0].count
    
    var pointInfoArray: [[[PointInfo]]] = Array(repeating: Array(repeating: Array(repeating: PointInfo(x: 0, y: 0, z: 0, value: 0), count: depth), count: cols), count: rows)
    
    for i in 0..<rows {
        for j in 0..<cols {
            for k in 0..<depth {
                let value = array3d[i][j][k]
                // 注意 这里 k是x， i 是z，反了就镜像了 而且旋转了
                pointInfoArray[i][j][k] = PointInfo(x: k, y: j, z: i, value: value)
            }
        }
    }
    
    // 设置每个点的上、下、左、右、前、后指向
    for i in 0..<rows {
        for j in 0..<cols {
            for k in 0..<depth {
                let currentPoint = pointInfoArray[i][j][k]
                
                if i > 0 {
                    currentPoint.up = pointInfoArray[i - 1][j][k]
                }
                
                if i < rows - 1 {
                    currentPoint.down = pointInfoArray[i + 1][j][k]
                }
                
                if j > 0 {
                    currentPoint.left = pointInfoArray[i][j - 1][k]
                }
                
                if j < cols - 1 {
                    currentPoint.right = pointInfoArray[i][j + 1][k]
                }
                
                if k > 0 {
                    currentPoint.front = pointInfoArray[i][j][k - 1]
                }
                
                if k < depth - 1 {
                    currentPoint.back = pointInfoArray[i][j][k + 1]
                }
            }
        }
    }
    
    return pointInfoArray
}

func hasContinuousEqualValues(pointInfo3DArray: [[[PointInfo]]]) -> [PointInfo] {
    let rows = pointInfo3DArray.count
    let cols = pointInfo3DArray[0].count
    let depth = pointInfo3DArray[0][0].count
    var retlist:[PointInfo] = []
    for i in 0..<rows {
        for j in 0..<cols {
            for k in 0..<depth {
                let currentPoint = pointInfo3DArray[i][j][k]
                let value = currentPoint.value
                if value < 0 {
                    continue
                }
                for akey in PointInfo.allKeyList {// 检查当前点在up方向上是否存在L
                    // allKeyList 也就是要检查6个方向，akey 就是当前检查的方向
                    // 根据当前检查的方向获取到 其他4个方向，也就是说检查上的时候，不用检查上和下拐弯的情况 L
                    // checkPoint再根据当前value 和 akey方向上连续两个，加起来也就是三个点的Value相等
                    // 再用checkList来遍历也就获取到了 L 形状。至此 L形状判断和方向都已经获取到了。
                    let ret = checkPoint1(currentPoint, with: 1, akeyPath: akey)
                    if ret.0, let aa = ret.1 {
                        aa.des = ret.2
                        aa.children = ret.3
                        retlist.append(aa)
                        break
                    }
                }
                for akey in PointInfo.allKeyList {
                    let ret = checkPoint2(currentPoint, with: 2, akeyPath: akey)
                    if ret.0, let aa = ret.1 {
                        aa.des = ret.2
                        aa.children = ret.3
                        retlist.append(aa)
                        break
                    }
                }
                for akey in PointInfo.allKeyList {
                    let ret = checkPoint3(currentPoint, with: 3, akeyPath: akey)
                    if ret.0, let aa = ret.1 {
                        aa.des = ret.2
                        aa.children = ret.3
                        retlist.append(aa)
                        break
                    }
                }
                for akey in PointInfo.allKeyList {
                    let ret = checkPoint4(currentPoint, with: 4, akeyPath: akey)
                    if ret.0, let aa = ret.1 {
                        aa.des = ret.2
                        aa.children = ret.3
                        if retlist.filter({ ap in
                            ap.value == 4
                        }).first == nil {
                            retlist.append(aa)
                        }
                        break
                    }
                }
                for akey in PointInfo.allKeyList {
                    let ret = checkPoint5(currentPoint, with: 5, akeyPath: akey)
                    if ret.0, let aa = ret.1 {
                        aa.des = ret.2
                        aa.children = ret.3
                        if retlist.filter({ ap in
                            ap.value == 5
                        }).first == nil {
                            retlist.append(aa)
                        }
                        break
                    }
                }
                for akey in PointInfo.allKeyList {
                    let ret = checkPoint6(currentPoint, with: 6, akeyPath: akey)
                    if ret.0, let aa = ret.1 {
                        aa.des = ret.2
                        aa.children = ret.3
                        if retlist.filter({ ap in
                            ap.value == 6
                        }).first == nil {
                            retlist.append(aa)
                        }
                        break
                    }
                }
                for akey in PointInfo.allKeyList {
                    let ret = checkPoint7(currentPoint, with: 7, akeyPath: akey)
                    if ret.0, let aa = ret.1 {
                        aa.des = ret.2
                        aa.children = ret.3
                        if retlist.filter({ ap in
                            ap.value == 7
                        }).first == nil {
                            retlist.append(aa)
                        }
                        break
                    }
                }
            }
        }
    }
    
    return retlist
}

extension ReferenceWritableKeyPath where Root == PointInfo {
    var stringValue: String {
        switch self {
        case \PointInfo.right: return "right"
        case \PointInfo.left: return "left"
        case \PointInfo.down: return "down"
        case \PointInfo.up: return "up"
        case \PointInfo.front: return "front"
        case \PointInfo.back: return "back"
            
        default: fatalError("Unexpected key path")
        }
    }
}
func checkPoint2(_ currentPoint:PointInfo, with checkValue: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [PointInfo]) {
    if currentPoint.value != checkValue {
        return (false, nil, "none", [])
    }
    let clist = PointInfo.checkList(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] {
        if let back2 = back1[keyPath:akeyPath] {
            if back1.value == checkValue && back2.value == checkValue {
                for akey in clist {
                    if let back3 = back2[keyPath:akey], back3.value == checkValue {
                        print("\(currentPoint) \(back1) \(back2) \(back3)")
                        return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back2, back3])
                    }
                }
            }
        }
    }
    return (false, nil, "none", [])
}

func checkPoint1(_ currentPoint:PointInfo, with checkValue: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [PointInfo]) {
    if currentPoint.value != checkValue {
        return (false, nil, "none", [])
    }
    let clist = PointInfo.checkList(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] , back1.value == checkValue {
        for akey in clist {
            if let back3 = currentPoint[keyPath:akey], back3.value == checkValue {
                print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back3)")
                return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back3])
            }
        }
        
    }
    return (false, nil, "none", [])
}

func checkPoint3(_ currentPoint:PointInfo, with checkValue: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [PointInfo]) {
    if currentPoint.value != checkValue {
        return (false, nil, "none", [])
    }
    let clist = PointInfo.checkList3(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] , back1.value == checkValue {
        for akey3 in clist {
            if akey3.allSatisfy({ akey in
                if let back3 = currentPoint[keyPath:akey], back3.value == checkValue {
                    return true
                } else {
                    return false
                }
            }) {
                var children = [currentPoint]
                let sidepoint:[PointInfo] = akey3.map { akey in
                    currentPoint[keyPath: akey]!
                }
                children.append(back1)
                children.append(contentsOf: sidepoint)
                
                return (true, currentPoint, "\(akeyPath.stringValue))", children)
                
            }
            for akey in akey3 {
                if let back3 = currentPoint[keyPath:akey], back3.value == checkValue {
                    print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back3)")
                }
            }
        }
        
    }
    return (false, nil, "none", [])
}


func checkPoint4(_ currentPoint:PointInfo, with checkValue: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [PointInfo]) {
    if currentPoint.value != checkValue {
        return (false, nil, "none", [])
    }
    let clist = PointInfo.checkList(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] , back1.value == checkValue {
        for akey in clist {
            if let back2 = currentPoint[keyPath:akey], back2.value == checkValue {
                if let back4 = back2[keyPath:PointInfo.checkList4(akeyPath)], back4.value == checkValue {
                    print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back2)")
                    return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back2, back4])
                }
            }
        }
    }
    return (false, nil, "none", [])
}



func checkPoint5(_ currentPoint:PointInfo, with checkValue: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [PointInfo]) {
    if currentPoint.value != checkValue {
        return (false, nil, "none", [])
    }
    let clist = PointInfo.checkList(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] , back1.value == checkValue {
        for akey in clist {
            if let back2 = currentPoint[keyPath:akey], back2.value == checkValue {
                if let zuo = PointInfo.calculateThirdKeyPath5(akeyPath, akey), let back4 = back2[keyPath:zuo] {
                    if back4.value == checkValue {
                        print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back2)")
                        return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back2, back4])
                    }
                }
                if let zuo = PointInfo.calculateThirdKeyPath5(akey, akeyPath), let back4 = back1[keyPath:zuo] {
                    if back4.value == checkValue {
                        print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back2)")
                        return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back2, back4])
                    }
                }
            }
        }
    }
    return (false, nil, "none", [])
}



func checkPoint6(_ currentPoint:PointInfo, with checkValue: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [PointInfo]) {
    if currentPoint.value != checkValue {
        return (false, nil, "none", [])
    }
    let clist = PointInfo.checkList(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] , back1.value == checkValue {
        for akey in clist {
            if let back2 = currentPoint[keyPath:akey], back2.value == checkValue {
                if let zuo = PointInfo.calculateThirdKeyPath6(akeyPath, akey), let back4 = back2[keyPath:zuo], back4.value == checkValue{
                    print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back2)")
                    return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back2, back4])
                }
                if let zuo = PointInfo.calculateThirdKeyPath6(akey, akeyPath), let back4 = back1[keyPath:zuo], back4.value == checkValue{
                    print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back2)")
                    return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back2, back4])
                }
            }
        }
    }
    return (false, nil, "none", [])
}


func checkPoint7(_ currentPoint:PointInfo, with checkValue: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [PointInfo]) {
    if currentPoint.value != checkValue {
        return (false, nil, "none", [])
    }
    let clist = PointInfo.checkList(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] , back1.value == checkValue {
        for akey in clist {
            if let back2 = currentPoint[keyPath:akey], back2.value == checkValue {
                if let zuo = PointInfo.calculateThirdKeyPath6(akeyPath, akey), 
                    let back4 = currentPoint[keyPath:zuo],
                   back4.value == checkValue {
                    print("currentPoint: value-\(checkValue), \(currentPoint) \(back1) \(back2)")
                    return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [currentPoint, back1, back2, back4])
                }
            }
        }
    }
    return (false, nil, "none", [])
}
