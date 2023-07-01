//
//  ArrayTool.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/1.
//

import Foundation

// Define the dimensions of the 3D array
let size = 3

// Create the initial 3D array
//var array = [[[Int]]](repeating: [[Int]](repeating: [Int](repeating: 0, count: size), count: size), count: size)
//
//// Initialize the array with some values for demonstration
//for i in 0..<size {
//    for j in 0..<size {
//        for k in 0..<size {
//            array[i][j][k] = i * size * size + j * size + k
//        }
//    }
//}
//var array = [[[2,4,3], [6,4,1], [6,6,1]],
//                         [[2,3,3], [6,4,1], [7,4,5]],
//                         [[2,2,3], [7,5,5], [7,7,5]]
//
//]

// Function to rotate the 3D array
func rotateArray(_ array: [[[Int]]]) -> [[[Int]]] {
    var result = [[[Int]]]()
    
    // Rotate around x-axis
    for i in 0..<size {
        let rotated = array[i].reversed() as [[Int]]
        result.append(rotated)
    }
    
    // Rotate around y-axis
    for i in 0..<size {
        var rotated = [[Int]]()
        for j in 0..<size {
            let column = array[j].map { $0[i] }
            rotated.append(column)
        }
        result.append(rotated)
    }
    
    // Rotate around z-axis
    var rotated = [[Int]]()
    for i in 0..<size {
        rotated.append(contentsOf: array[i])
    }
    rotated.reverse()
    for _ in 0..<size {
        result.append(rotated)
        rotated = rotated.map { $0.rotateRight() }
    }
    
    return result
}

// Helper extension to rotate an array to the right
extension Array {
    func rotateRight() -> [Element] {
        var array = self
        let lastElement = array.removeLast()
        array.insert(lastElement, at: 0)
        return array
    }
}

//// Calculate all 24 rotations
//let rotations = rotateArray(array)
//
//// Print the rotated arrays
//for i in 0..<rotations.count {
//    print("Rotation \(i + 1):")
//    for j in 0..<size {
//        print(rotations[i][j])
//    }
//    print("\n")
//}
