//
//  ArrayTool.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/1.
//

// 定义一个表示三维矩阵的类型别名
typealias Matrix3D = [[[Int]]]

enum Axis {
    case x
    case y
    case z
}


// 实现 rot90 函数
func rot90(_ matrix: Matrix3D, k: Int = 1, axes: Axis = .y) -> Matrix3D {
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
func rotateOnce(_ matrix: Matrix3D, axes: Axis, depth: Int, rows: Int, cols: Int) -> Matrix3D {

    var rotatedMatrix = Matrix3D(repeating: [[Int]](repeating: [Int](repeating: 0, count: rows), count: cols), count: depth)
    
    for i in 0..<depth {
        for j in 0..<rows {
            for k in 0..<cols {
                switch (axes) {
                case .x: // 沿着第x轴旋转
                    rotatedMatrix[i][j][k] = matrix[rows - j - 1][i][k]
                case .y: // 沿着第y轴旋转
                    rotatedMatrix[i][j][k] = matrix[rows - k - 1][j][i]
                case .z: // 沿着第z轴旋转
                    rotatedMatrix[i][j][k] = matrix[i][k][rows - j - 1]
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
    let rotatedMatrixy2 = rot90(matrix, k: 1, axes: .y)
    let rotatedMatrixy3 = rot90(matrix, k: 2, axes: .y)
    let rotatedMatrixy4 = rot90(matrix, k: 3, axes: .y)


    result24.append(rotatedMatrixy1)
    result24.append(rotatedMatrixy2)
    result24.append(rotatedMatrixy3)
    result24.append(rotatedMatrixy4)

    let matrix1 = rotateOnce(matrix, axes: .z, depth: 3, rows: 3, cols: 3)
    let rotatedMatrixyb1 = matrix1
    let rotatedMatrixyb2 = rot90(matrix1, k: 1, axes: .y)
    let rotatedMatrixyb3 = rot90(matrix1, k: 2, axes: .y)
    let rotatedMatrixyb4 = rot90(matrix1, k: 3, axes: .y)

    result24.append(rotatedMatrixyb1)
    result24.append(rotatedMatrixyb2)
    result24.append(rotatedMatrixyb3)
    result24.append(rotatedMatrixyb4)

    let matrix2 = rotateOnce(matrix1, axes: .z, depth: 3, rows: 3, cols: 3)
    let rotatedMatrixyc1 = matrix2
    let rotatedMatrixyc2 = rot90(matrix2, k: 1, axes: .y)
    let rotatedMatrixyc3 = rot90(matrix2, k: 2, axes: .y)
    let rotatedMatrixyc4 = rot90(matrix2, k: 3, axes: .y)

    result24.append(rotatedMatrixyc1)
    result24.append(rotatedMatrixyc2)
    result24.append(rotatedMatrixyc3)
    result24.append(rotatedMatrixyc4)

    let matrix3 = rotateOnce(matrix2, axes: .z, depth: 3, rows: 3, cols: 3)
    let rotatedMatrixyd1 = matrix3
    let rotatedMatrixyd2 = rot90(matrix3, k: 1, axes: .y)
    let rotatedMatrixyd3 = rot90(matrix3, k: 2, axes: .y)
    let rotatedMatrixyd4 = rot90(matrix3, k: 3, axes: .y)

    result24.append(rotatedMatrixyd1)
    result24.append(rotatedMatrixyd2)
    result24.append(rotatedMatrixyd3)
    result24.append(rotatedMatrixyd4)

    let matrix4 = rotateOnce(matrix, axes: .x, depth: 3, rows: 3, cols: 3)
    let rotatedMatrixye1 = matrix4
    let rotatedMatrixye2 = rot90(matrix4, k: 1, axes: .y)
    let rotatedMatrixye3 = rot90(matrix4, k: 2, axes: .y)
    let rotatedMatrixye4 = rot90(matrix4, k: 3, axes: .y)

    result24.append(rotatedMatrixye1)
    result24.append(rotatedMatrixye2)
    result24.append(rotatedMatrixye3)
    result24.append(rotatedMatrixye4)

    let matrix5 = rot90(matrix, k: 3, axes: .x)
    let rotatedMatrixyf1 = matrix5
    let rotatedMatrixyf2 = rot90(matrix5, k: 1, axes: .y)
    let rotatedMatrixyf3 = rot90(matrix5, k: 2, axes: .y)
    let rotatedMatrixyf4 = rot90(matrix5, k: 3, axes: .y)

    result24.append(rotatedMatrixyf1)
    result24.append(rotatedMatrixyf2)
    result24.append(rotatedMatrixyf3)
    result24.append(rotatedMatrixyf4)

    for (index, value) in result24.enumerated() {
        print("索引: \(index)------")
        print(value)
    }
//    result24.count
    return result24;
}

/*
 索引: 0------
 [[[2, 4, 3], [6, 4, 1], [6, 6, 1]],
 [[2, 3, 3], [6, 4, 1], [7, 4, 5]],
 [[2, 2, 3], [7, 5, 5], [7, 7, 5]]]
 索引: 1------
 [[[2, 2, 2], [7, 6, 6], [7, 7, 6]],
 [[2, 3, 4], [5, 4, 4], [7, 4, 6]],
 [[3, 3, 3], [5, 1, 1], [5, 5, 1]]]
 索引: 2------
 [[[3, 2, 2], [5, 5, 7], [5, 7, 7]],
 [[3, 3, 2], [1, 4, 6], [5, 4, 7]],
 [[3, 4, 2], [1, 4, 6], [1, 6, 6]]]
 索引: 3------
 [[[3, 3, 3], [1, 1, 5], [1, 5, 5]],
 [[4, 3, 2], [4, 4, 5], [6, 4, 7]],
 [[2, 2, 2], [6, 6, 7], [6, 7, 7]]]
 索引: 4------
 [[[3, 1, 1], [4, 4, 6], [2, 6, 6]],
 [[3, 1, 5], [3, 4, 4], [2, 6, 7]],
 [[3, 5, 5], [2, 5, 7], [2, 7, 7]]]
 索引: 5------
 [[[3, 3, 3], [2, 3, 4], [2, 2, 2]],
 [[5, 1, 1], [5, 4, 4], [7, 6, 6]],
 [[5, 5, 1], [7, 4, 6], [7, 7, 6]]]
 索引: 6------
 [[[5, 5, 3], [7, 5, 2], [7, 7, 2]],
 [[5, 1, 3], [4, 4, 3], [7, 6, 2]],
 [[1, 1, 3], [6, 4, 4], [6, 6, 2]]]
 索引: 7------
 [[[1, 5, 5], [6, 4, 7], [6, 7, 7]],
 [[1, 1, 5], [4, 4, 5], [6, 6, 7]],
 [[3, 3, 3], [4, 3, 2], [2, 2, 2]]]
 索引: 8------
 [[[1, 6, 6], [1, 4, 6], [3, 4, 2]],
 [[5, 4, 7], [1, 4, 6], [3, 3, 2]],
 [[5, 7, 7], [5, 5, 7], [3, 2, 2]]]
 索引: 9------
 [[[5, 5, 1], [5, 1, 1], [3, 3, 3]],
 [[7, 4, 6], [5, 4, 4], [2, 3, 4]],
 [[7, 7, 6], [7, 6, 6], [2, 2, 2]]]
 索引: 10------
 [[[7, 7, 5], [7, 5, 5], [2, 2, 3]],
 [[7, 4, 5], [6, 4, 1], [2, 3, 3]],
 [[6, 6, 1], [6, 4, 1], [2, 4, 3]]]
 索引: 11------
 [[[6, 7, 7], [6, 6, 7], [2, 2, 2]],
 [[6, 4, 7], [4, 4, 5], [4, 3, 2]],
 [[1, 5, 5], [1, 1, 5], [3, 3, 3]]]
 索引: 12------
 [[[6, 6, 2], [6, 4, 4], [1, 1, 3]],
 [[7, 6, 2], [4, 4, 3], [5, 1, 3]],
 [[7, 7, 2], [7, 5, 2], [5, 5, 3]]]
 索引: 13------
 [[[7, 7, 6], [7, 4, 6], [5, 5, 1]],
 [[7, 6, 6], [5, 4, 4], [5, 1, 1]],
 [[2, 2, 2], [2, 3, 4], [3, 3, 3]]]
 索引: 14------
 [[[2, 7, 7], [2, 5, 7], [3, 5, 5]],
 [[2, 6, 7], [3, 4, 4], [3, 1, 5]],
 [[2, 6, 6], [4, 4, 6], [3, 1, 1]]]
 索引: 15------
 [[[2, 2, 2], [4, 3, 2], [3, 3, 3]],
 [[6, 6, 7], [4, 4, 5], [1, 1, 5]],
 [[6, 7, 7], [6, 4, 7], [1, 5, 5]]]
 索引: 16------
 [[[2, 2, 3], [2, 3, 3], [2, 4, 3]],
 [[7, 5, 5], [6, 4, 1], [6, 4, 1]],
 [[7, 7, 5], [7, 4, 5], [6, 6, 1]]]
 索引: 17------
 [[[7, 7, 2], [7, 6, 2], [6, 6, 2]],
 [[7, 5, 2], [4, 4, 3], [6, 4, 4]],
 [[5, 5, 3], [5, 1, 3], [1, 1, 3]]]
 索引: 18------
 [[[5, 7, 7], [5, 4, 7], [1, 6, 6]],
 [[5, 5, 7], [1, 4, 6], [1, 4, 6]],
 [[3, 2, 2], [3, 3, 2], [3, 4, 2]]]
 索引: 19------
 [[[3, 5, 5], [3, 1, 5], [3, 1, 1]],
 [[2, 5, 7], [3, 4, 4], [4, 4, 6]],
 [[2, 7, 7], [2, 6, 7], [2, 6, 6]]]
 索引: 20------
 [[[6, 6, 1], [7, 4, 5], [7, 7, 5]],
 [[6, 4, 1], [6, 4, 1], [7, 5, 5]],
 [[2, 4, 3], [2, 3, 3], [2, 2, 3]]]
 索引: 21------
 [[[2, 6, 6], [2, 6, 7], [2, 7, 7]],
 [[4, 4, 6], [3, 4, 4], [2, 5, 7]],
 [[3, 1, 1], [3, 1, 5], [3, 5, 5]]]
 索引: 22------
 [[[3, 4, 2], [3, 3, 2], [3, 2, 2]],
 [[1, 4, 6], [1, 4, 6], [5, 5, 7]],
 [[1, 6, 6], [5, 4, 7], [5, 7, 7]]]
 索引: 23------
 [[[1, 1, 3], [5, 1, 3], [5, 5, 3]],
 [[6, 4, 4], [4, 4, 3], [7, 5, 2]],
 [[6, 6, 2], [7, 6, 2], [7, 7, 2]]]
 */
