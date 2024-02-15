//
//  CubeSceneTests.swift
//  CubeSceneTests
//
//  Created by yanguo sun on 2023/11/5.
//

import XCTest

final class CubeSceneTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func atestExampleBack() throws {
//        // 三维数组
//        let array3dList = [
//            [
//                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                [[-1, -1, 2], [2, 2, 2], [-1, -1, -1]],
//                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            ],[
//                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                [[-1, -1, -1], [2, 2, 2], [-1, -1, 2]],
//                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            ],
//            [
//                [[-1, -1, -1], [-1, -1, 2], [-1, -1, -1]],
//                [[-1, -1, -1], [2, 2, 2], [-1, -1, -1]],
//                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            ],[
//                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//                [[-1, -1, -1], [2, 2, 2], [-1, -1, -1]],
//                [[-1, -1, -1], [-1, -1, 2], [-1, -1, -1]],
//            ]
//        ]
//
//        array3dList.forEach { array3d in
//            // 映射成三维 PointInfo 类的实例
//            let pointInfo3DArray = mapTo3DPointInfo(array3d: array3d)
//            let ret = hasContinuousEqualValues(pointInfo3DArray: pointInfo3DArray)
//            print(ret)
//            XCTAssert(ret.0)
//        }
    }

    func atestExampleFront() throws {
//        // 三维数组
//        let array3dList = [
//            //            [
//            //                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            //                [[2, -1, -1], [2, 2, 2], [-1, -1, -1]],
//            //                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            //            ],[
//            //                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            //                [[-1, -1, -1], [2, 2, 2], [2, -1, -1]],
//            //                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            //            ],
//            //            [
//            //                [[-1, -1, -1], [2, -1, -1], [-1, -1, -1]],
//            //                [[-1, -1, -1], [2, 2, 2], [-1, -1, -1]],
//            //                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            //            ],[
//            //                [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
//            //                [[-1, -1, -1], [2, 2, 2], [-1, -1, -1]],
//            //                [[-1, -1, -1], [2, -1, -1], [-1, -1, -1]],
//            //            ]
//            //        这是起点
//            //        (true, Optional((x:2, y:1, z:1, value:2)), "up, left")
//            [[[-1, 2, -1], [-1, 2, -1], [-1, -1, -1]],
//             [[-1, -1, -1], [-1, 2, -1], [-1, -1, -1]],
//             [[-1, -1, -1], [-1, 2, -1], [-1, -1, -1]],],
//            //            (true, Optional((x:2, y:1, z:1, value:2)), "up, right") 绕z轴转180度也就时pi。
//            [[[-1, -1, -1], [-1, 2, -1], [-1, 2, -1]],
//             [[-1, -1, -1], [-1, 2, -1], [-1, -1, -1]],
//             [[-1, -1, -1], [-1, 2, -1], [-1, -1, -1]],]
//            // 2 "up, right" z pi
//        ]
//
//
//        array3dList.forEach { array3d in
//            // 映射成三维 PointInfo 类的实例
//            let pointInfo3DArray = mapTo3DPointInfo(array3d: array3d)
//            let ret = hasContinuousEqualValues(pointInfo3DArray: pointInfo3DArray)
//            print(ret)
//            XCTAssert(ret.0)
//        }
    }

}
