//
//  TestEnter.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/11/5.
//

import SwiftUI

struct TestEnterModel {
    let name: String
    let matrix: Matrix3D
    
    init(name: String, matrix: Matrix3D) {
        self.name = name
        self.matrix = matrix
    }
    init(_ name: String, _ matrix: Matrix3D) {
        self.name = name
        self.matrix = matrix
    }
}

extension TestEnterModel : Identifiable {
    var id : String {
        name
    }
}

// 集成到这里有点问题。。。。 2的原点不都是第一个点。。。，导致旋转方向不可靠
struct TestEnter: View {
    
    let items:[TestEnterModel] = [
       
        TestEnterModel("right, up",
                       transMatrix(with:
                                    [[[2,4,3], [6,4,1], [6,6,1]],
                                     [[2,3,3], [6,4,1], [7,4,5]],
                                     [[2,2,3], [7,5,5], [7,7,5]]])),
//        TestEnterModel("right, up",
//                       transMatrix(with:
//                                    [[[-1, 2, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                                     [[1, 1, -1], [3, 3, 3], [-1, 3, -1]],])),
//        TestEnterModel("right, down",
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[-1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                                     [[-1, 2, -1], [-1, -1, -1], [-1, -1, -1]],])),
//        TestEnterModel("right, back",
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[-1, 2, 2], [-1, 2, -1], [-1, 2, -1]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],])),
//        TestEnterModel("right, front",
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[2, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],])),
//        TestEnterModel("left, up",
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, 2, -1]],
//                                     [[-1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],])),
//        TestEnterModel("left, down",
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[-1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, 2, -1]],])),
//        TestEnterModel("left, back",
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[-1, 2, -1], [-1, 2, -1], [-1, 2, 2]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],])),
//        TestEnterModel("left, front",
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[-1, 2, -1], [-1, 2, -1], [2, 2, -1]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],])),
//        TestEnterModel("front, left",
//                       //        (x:1, y:1, z:2, value:2) (x:1, y:1, z:1, value:2) (x:1, y:1, z:0, value:2) (x:1, y:0, z:0, value:2)
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                                     [[-1, -1, -1], [2, 2, 2], [2, -1, -1]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],])),
//        TestEnterModel("back, up",
//                       //        (true, Optional((x:1, y:1, z:0, value:2)), "back, up")
//                       transMatrix(with:
//                                    [[[-1, -1, -1], [-1, -1, 2], [-1, -1, -1]],
//                                     [[-1, -1, -1], [2, 2, 2],    [-1, -1, -1]],
//                                     [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],])),
    ]
    
    var body: some View {
        List(items) { item in
            NavigationLink {
                SingleContentView2(nodeList: makeNode(with: item.matrix))
            } label: {
                Text("\(item.name) L的方向")
            }
            
        }
    }
}


struct TestEnter_Previews: PreviewProvider {
    static var previews: some View {
        TestEnter()
    }
}
