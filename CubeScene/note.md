#  <#Title#>

    // 算出来的第一个点就是块的位置，有了位置也就进一步确定方向，时左还是右，上还是下，是否是镜像的
    // 然后在把rotationTo改成x、y,z 旋转次数，再根据初始位置
    // 用四元数算出旋转所需，，既然用四元数计算，那就不用上一步了，再就是要把一开始的遍历创建，改成按块，按角度创建，意思
    // 就是创建一个空白的，在算两个node之间的旋转四元数
    // action上再增加一个先移动到上方，再向下移动，防止互相穿过
    // node:Optional("块 1"),rotation:SCNVector4(x: 0.5773504, y: -0.5773503, z: -0.5773501, w: 4.1887903), position:SCNVector3(x: 1.0, y: 0.0, z: 1.0)
    // node:Optional("块 2"),rotation:SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954), position:SCNVector3(x: 1.0, y: 2.0, z: 1.0000001)
    // node:Optional("块 3"),rotation:SCNVector4(x: 0.0, y: 0.0, z: 0.99999994, w: 1.5707964), position:SCNVector3(x: -1.0, y: 0.0, z: -1.0)
    // node:Optional("块 4"),rotation:SCNVector4(x: 0.5773504, y: 0.57735056, z: -0.5773499, w: 4.18879), position:SCNVector3(x: 1.0, y: 0.0, z: -1.0)
    // node:Optional("块 5"),rotation:SCNVector4(x: 0.0, y: 0.99999994, z: 0.0, w: 1.5707964), position:SCNVector3(x: 0.0, y: 1.0, z: 1.0)
    // node:Optional("块 6"),rotation:SCNVector4(x: 1.0, y: 1.2665981e-07, z: 1.0803336e-07, w: 3.1415927), position:SCNVector3(x: -1.0, y: 1.0, z: 0.0)
    // node:Optional("块 7"),rotation:SCNVector4(x: 0.5773504, y: -0.57735014, z: -0.5773502, w: 2.0943954), position:SCNVector3(x: 1.0, y: 2.0, z: 0.0)

    //node:块 1,rotation:SCNVector3(x: 0.0, y: 1.0, z: 1.0), position:SCNVector3(x: 1.0000011, y: 0.0, z: 0.99999976)
    //node:块 2,rotation:SCNVector3(x: 1.0, y: 0.0, z: 3.0), position:SCNVector3(x: 0.99999964, y: 1.9999999, z: 0.99999964)
    //node:块 3,rotation:SCNVector3(x: 0.0, y: 0.0, z: 1.0), position:SCNVector3(x: -0.99999964, y: 0.0, z: -1.0000001)
    //node:块 4,rotation:SCNVector3(x: 3.0, y: 0.0, z: 1.0), position:SCNVector3(x: -0.9999999, y: 1.0000001, z: -1.0000001)
    //node:块 5,rotation:SCNVector3(x: 0.0, y: 1.0, z: 0.0), position:SCNVector3(x: 3.874302e-07, y: 0.99999964, z: 0.99999964)
    //node:块 6,rotation:SCNVector3(x: 0.0, y: 3.0, z: 2.0), position:SCNVector3(x: -3.5762787e-07, y: 0.99999964, z: -1.4901161e-07)
    //node:块 7,rotation:SCNVector3(x: 0.0, y: 0.0, z: 2.0), position:SCNVector3(x: 1.0, y: 0.99999964, z: -1.0000001)

// rotationTo 可以简化为x几次y几次z几次，用SCNVector3 记录就可以了
//如果两个节点的旋转轴和角度都不同，那么你需要执行更复杂的计算来旋转一个节点以匹配另一个节点的方向。下面是一种通用的方法，可以帮助你实现这一目标：
//
//```swift
//import SceneKit
//
//// 创建第一个节点
//let node1 = SCNNode()
//let rotation1 = SCNQuaternion(x: 0, y: 1, z: 0, w: Float.pi / 4) // 旋转45度
//node1.orientation = rotation1
//
//// 创建第二个节点
//let node2 = SCNNode()
//let rotation2 = SCNQuaternion(x: 1, y: 0, z: 0, w: -Float.pi / 4) // 旋转-45度
//node2.orientation = rotation2
//
//// 计算从第一个节点到第二个节点的四元数旋转差异
//let rotationDifference = node2.orientation * node1.orientation.inverted()
//
//// 使用四元数旋转差异来旋转第一个节点以匹配第二个节点的方向
//node1.orientation = rotationDifference * node1.orientation
//
//// 你现在可以将 node1 添加到场景中
//```
//
//在这个示例中，我们首先创建了两个 `SCNNode`，每个节点都具有不同的旋转轴和角度。然后，我们计算了从第一个节点到第二个节点的四元数旋转差异，将其应用于第一个节点，以使其方向匹配第二个节点。
//
//这个示例中使用了四元数来处理旋转，四元数对于处理复杂的旋转操作非常有用，因为它们可以避免万向锁等问题。请确保了解四元数的基本概念，以更好地理解这个示例。这个方法适用于不同旋转轴和不同角度的情况，但需要小心处理节点之间的坐标系和父子节点关系。


    [
        
        Block(data: [[[1,-1,-1],],
                     [[1,1,-1], ],
                     [[-1,-1,-1],]],
              name: "块 1",
              rotation: SCNVector3Zero,
              position: SCNVector3(6, 0, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 1.0, z: 1.0),
              positionTo: SCNVector3(x: 1, y: 0.0, z: 1)),

        Block(data: [[[2,-1,-1],],
                     [[2,-1,-1],],
                     [[2,2,-1],]],
              name: "块 2",
              rotation: SCNVector3Zero,
              position: SCNVector3(3, 0, -5),
              rotationTo3: SCNVector3(x: 1.0, y: 0.0, z: 3.0),
              positionTo: SCNVector3(x: 1, y: 2, z: 1)),
        Block(data: [[[3,-1,-1],],
                     [[3,3,-1],],
                     [[3,-1,-1],]],
              name: "块 3",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 0, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 0.0, z: 1.0),
              positionTo: SCNVector3(x: -1, y: 0.0, z: -1)),
        Block(data: [[[4,-1,-1],],
                     [[4,4,-1],],
                     [[-1,4,-1],]],
              name: "块 4",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 0, -5),
              rotationTo3: SCNVector3(x: 3.0, y: 0.0, z: 1.0),
              positionTo: SCNVector3(x: 1, y: 0.0, z: -1)),
        Block(data: [[[5, -1,-1],[5,  5,-1], ],
                     [[-1,-1,-1],[-1, 5,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 5",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 3, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 1.0, z: 0.0),
              positionTo: SCNVector3(x: 0, y: 1, z: 1)),
        Block(data: [[[6, -1,-1],[ 6,-1,-1], ],
                     [[-1,-1,-1],[ 6, 6,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 6",
              rotation: SCNVector3Zero,
              position: SCNVector3(-3, 3, 5),
              rotationTo3: SCNVector3(x: 0.0, y: 1.0, z: 2.0),
              positionTo: SCNVector3(x: 0, y: 1.0, z: 0)),
        Block(data: [[[ 7,-1,-1],[ 7, 7,-1], ],
                     [[-1,-1,-1],[ 7,-1,-1],],
                     [[-1,-1,-1],[-1,-1,-1],]],
              name: "块 7",
              rotation: SCNVector3Zero,
              position: SCNVector3(0, 3, -5),
              rotationTo3: SCNVector3(x: 0.0, y: 0.0, z: 2.0),
              positionTo: SCNVector3(x: 1, y: 1, z: -1)),

    ];
