//
//  PointInfo.swift
//  FindBlock
//
//  Created by yanguo sun on 2023/11/2.
//

import Foundation
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
                pointInfoArray[i][j][k] = PointInfo(x: i, y: j, z: k, value: value)
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

func hasContinuousEqualValues(pointInfo3DArray: [[[PointInfo]]]) -> (Bool, PointInfo?, String, [ReferenceWritableKeyPath<PointInfo, PointInfo?>]) {
    let rows = pointInfo3DArray.count
    let cols = pointInfo3DArray[0].count
    let depth = pointInfo3DArray[0][0].count

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
                    let ret = checkPoint(currentPoint, with: value, akeyPath: akey)
                    if ret.0  {
                        return ret
                    }
                }
            }
        }
    }

    return (false, nil, "none", [])
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
func checkPoint(_ currentPoint:PointInfo, with value: Int, akeyPath:ReferenceWritableKeyPath<PointInfo, PointInfo?>) -> (Bool, PointInfo?, String, [ReferenceWritableKeyPath<PointInfo, PointInfo?>]) {
    let clist = PointInfo.checkList(akeyPath)
    if let back1 = currentPoint[keyPath:akeyPath] {
        if let back2 = back1[keyPath:akeyPath] {
            if back1.value == value && back2.value == value {
                for akey in clist {
                    if let back3 = back2[keyPath:akey], back3.value == value {
                        print("\(currentPoint) \(back1) \(back2) \(back3)")
                        return (true, currentPoint, "\(akeyPath.stringValue), \(akey.stringValue)", [akeyPath, akeyPath, akey])
                    }
                }
            }
        }
    }
    return (false, nil, "none", [])
}
