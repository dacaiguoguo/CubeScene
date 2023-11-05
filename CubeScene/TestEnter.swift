//
//  TestEnter.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/11/5.
//

import SwiftUI


struct TestEnter: View {

    let items = [
//        "right, up"
//        transMatrix(with:
//                        [[[-1, 2, -1], [-1, -1, -1], [-1, -1, -1]],
//                         [[-1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                         [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],]),
//        "right, down"
//        transMatrix(with:
//                        [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                         [[-1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                         [[-1, 2, -1], [-1, -1, -1], [-1, -1, -1]],]),
//        "right, back"
//        transMatrix(with:
//                        [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                         [[-1, 2, 2], [-1, 2, -1], [-1, 2, -1]],
//                         [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],]),
//        "right, front"
//        transMatrix(with:
//                        [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                         [[2, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                         [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],]),
//        "left, up"
//        transMatrix(with:
//                        [[[-1, -1, -1], [-1, -1, -1], [-1, 2, -1]],
//                         [[-1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
//                         [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],]),
//        "left, down"
        transMatrix(with:
                        [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
                         [[-1, 2, -1], [-1, 2, -1], [-1, 2, -1]],
                         [[-1, -1, -1], [-1, -1, -1], [-1, 2, -1]],]),
//        transMatrix(with:
//                        [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                         [[-1, 2, -1], [-1, 2, -1], [-1, 2, 2]],
//                         [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],]),
//        transMatrix(with:
//                        [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                         [[-1, 2, -1], [-1, 2, -1], [2, 2, -1]],
//                         [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],]),
    ]

    var body: some View {
        List(items, id: \.self) { item in
            NavigationLink {
                SingleContentView2(nodeList: makeNode(with: item))
            } label: {
                Text("\(items.firstIndex(of: item).debugDescription)")
            }

        }
    }
}


struct TestEnter_Previews: PreviewProvider {
    static var previews: some View {
        TestEnter()
    }
}
