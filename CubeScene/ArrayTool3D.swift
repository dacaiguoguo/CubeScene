//
//  ArrayTool.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/1.
//

// 定义一个表示三维矩阵的类型别名
typealias Matrix3D = [[[Int]]]

// 实现 rot90 函数
func rot90(_ matrix: Matrix3D, k: Int = 1, axes: (Int, Int) = (1, 2)) -> Matrix3D {
    let depth = matrix.count
    let rows = matrix[0].count
    let cols = matrix[0][0].count
    
    let rotations = (k % 4 + 4) % 4  // 处理次数超过4次的情况
    
    var rotatedMatrix = matrix
    
    for _ in 0..<rotations {
        rotatedMatrix = rotateOnce(rotatedMatrix, axes: axes, depth: depth, rows: rows, cols: cols)
    }
    
    return rotatedMatrix
}

// 旋转一次
func rotateOnce(_ matrix: Matrix3D, axes: (Int, Int), depth: Int, rows: Int, cols: Int) -> Matrix3D {
    let axis1 = axes.0
    let axis2 = axes.1
    
    var rotatedMatrix = Matrix3D(repeating: [[Int]](repeating: [Int](repeating: 0, count: rows), count: cols), count: depth)
    
    for i in 0..<depth {
        for j in 0..<rows {
            for k in 0..<cols {
                switch (axis1, axis2) {
                case (0, 1): // 沿着第一个轴和第二个轴旋转
                    rotatedMatrix[i][j][k] = matrix[i][k][rows - j - 1]
                case (0, 2): // 沿着第一个轴和第三个轴旋转
//                    rotatedMatrix[i][j][k] = matrix[i][rows - k - 1][j]
                    rotatedMatrix[i][j][k] = matrix[rows - k - 1][j][i]
                case (1, 2): // 沿着第二个轴和第三个轴旋转
                    rotatedMatrix[i][j][k] = matrix[rows - j - 1][i][k]
                default:
                    fatalError("Invalid axes. Must be a pair of two different values among 0, 1, and 2.")
                }
            }
        }
    }
    
    return rotatedMatrix
}

// 测试
let matrix: Matrix3D = [[[2,4,3], [6,4,1], [6,6,1]],
                        [[2,3,3], [6,4,1], [7,4,5]],
                        [[2,2,3], [7,5,5], [7,7,5]]]
func getAll24(_ matrix: Matrix3D) ->[Matrix3D] {
    
    var result24:[Matrix3D] = []

    let rotatedMatrixy1 = matrix
    let rotatedMatrixy2 = rot90(matrix, k: 1, axes: (0, 2))
    let rotatedMatrixy3 = rot90(matrix, k: 2, axes: (0, 2))
    let rotatedMatrixy4 = rot90(matrix, k: 3, axes: (0, 2))


    result24.append(rotatedMatrixy1)
    result24.append(rotatedMatrixy2)
    result24.append(rotatedMatrixy3)
    result24.append(rotatedMatrixy4)

    let matrix1 = rotateOnce(matrix, axes: (0, 1), depth: 3, rows: 3, cols: 3)
    let rotatedMatrixyb1 = matrix1
    let rotatedMatrixyb2 = rot90(matrix1, k: 1, axes: (0, 2))
    let rotatedMatrixyb3 = rot90(matrix1, k: 2, axes: (0, 2))
    let rotatedMatrixyb4 = rot90(matrix1, k: 3, axes: (0, 2))

    result24.append(rotatedMatrixyb1)
    result24.append(rotatedMatrixyb2)
    result24.append(rotatedMatrixyb3)
    result24.append(rotatedMatrixyb4)

    let matrix2 = rotateOnce(matrix1, axes: (0, 1), depth: 3, rows: 3, cols: 3)
    let rotatedMatrixyc1 = matrix2
    let rotatedMatrixyc2 = rot90(matrix2, k: 1, axes: (0, 2))
    let rotatedMatrixyc3 = rot90(matrix2, k: 2, axes: (0, 2))
    let rotatedMatrixyc4 = rot90(matrix2, k: 3, axes: (0, 2))

    result24.append(rotatedMatrixyc1)
    result24.append(rotatedMatrixyc2)
    result24.append(rotatedMatrixyc3)
    result24.append(rotatedMatrixyc4)

    let matrix3 = rotateOnce(matrix2, axes: (0, 1), depth: 3, rows: 3, cols: 3)
    let rotatedMatrixyd1 = matrix3
    let rotatedMatrixyd2 = rot90(matrix3, k: 1, axes: (0, 2))
    let rotatedMatrixyd3 = rot90(matrix3, k: 2, axes: (0, 2))
    let rotatedMatrixyd4 = rot90(matrix3, k: 3, axes: (0, 2))

    result24.append(rotatedMatrixyd1)
    result24.append(rotatedMatrixyd2)
    result24.append(rotatedMatrixyd3)
    result24.append(rotatedMatrixyd4)

    let matrix4 = rotateOnce(matrix, axes: (1, 2), depth: 3, rows: 3, cols: 3)
    let rotatedMatrixye1 = matrix4
    let rotatedMatrixye2 = rot90(matrix4, k: 1, axes: (0, 2))
    let rotatedMatrixye3 = rot90(matrix4, k: 2, axes: (0, 2))
    let rotatedMatrixye4 = rot90(matrix4, k: 3, axes: (0, 2))

    result24.append(rotatedMatrixye1)
    result24.append(rotatedMatrixye2)
    result24.append(rotatedMatrixye3)
    result24.append(rotatedMatrixye4)

    let matrix5 = rot90(matrix, k: 3, axes: (1, 2))
    let rotatedMatrixyf1 = matrix5
    let rotatedMatrixyf2 = rot90(matrix5, k: 1, axes: (0, 2))
    let rotatedMatrixyf3 = rot90(matrix5, k: 2, axes: (0, 2))
    let rotatedMatrixyf4 = rot90(matrix5, k: 3, axes: (0, 2))

    result24.append(rotatedMatrixyf1)
    result24.append(rotatedMatrixyf2)
    result24.append(rotatedMatrixyf3)
    result24.append(rotatedMatrixyf4)
//    result24.count
    return result24;
}
