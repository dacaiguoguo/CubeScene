

func multiply3DArrays(_ arrayA: [[[Int]]], _ arrayB: [[[Int]]]) -> [[[Int]]] {
    let count = arrayA.count
    let rowsA = arrayA[0].count
    let colsA = arrayA[0][0].count
    let rowsB = arrayB[0].count
    let colsB = arrayB[0][0].count

    // Check if arrays can be multiplied
    guard colsA == rowsB else {
        fatalError("The number of columns in array A must be equal to the number of rows in array B.")
    }

    // Create a result array filled with zeros
    var result = [[[Int]]](repeating: [[Int]](repeating: [Int](repeating: 0, count: colsB), count: rowsA), count: count)

    // Perform matrix multiplication for each slice using nested loops
    for k in 0..<count {
        for i in 0..<rowsA {
            for j in 0..<colsB {
                for m in 0..<colsA {
                    result[k][i][j] += arrayA[k][i][m] * arrayB[k][m][j]
                }
            }
        }
    }

    return result
}


typealias Matrix3D = [[[Int]]]

let matrixA2: Matrix3D = [[[2,4,3], [6,4,1], [6,6,1]],
                          [[2,3,3], [6,4,1], [7,4,5]],
                          [[2,2,3], [7,5,5], [7,7,5]]]
//0    0    1
//0    1    0
//-1    0    0
let matrixB2: Matrix3D = [[[0,0,1],
                           [0,1,0],
                           [1,0,0]],
                          [[0,0,1],
                           [0,1,0],
                           [1,0,0]],
                          [[0,0,1],
                           [0,1,0],
                           [1,0,0]],]

//1 0  0
//0 0 -1
//0 1  0
let result = multiply3DArrays(matrixA2, matrixB2)
print(result)
