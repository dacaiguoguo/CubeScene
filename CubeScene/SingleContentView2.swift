//
//  SingleContentView2.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit

enum Direction {
  case               left;
  case               up;
  case               right;
}

struct Matrix3DPoint {
    let data: Matrix3D
    let name: String
    var rotationAngle:SCNVector3
    var offset:SCNVector3
}

public struct SingleContentView2: View {

    static var dataList:[Matrix3DPoint] = [
        Matrix3DPoint(data: [[[1,-1,-1],],
                             [[1,1,-1], ],
                             [[-1,-1,-1],]],
                      name: "B 1",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(9, 0, -5)),
        Matrix3DPoint(data: [[[2,-1,-1],],
                             [[2,-1,-1],],
                             [[2,2,-1],]],
                      name: "B 2",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(6, 0, -5)),
        Matrix3DPoint(data: [[[3,-1,-1],],
                             [[3,3,-1],],
                             [[3,-1,-1],]],
                      name: "B 3",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(3, 0, -5)),
        Matrix3DPoint(data: [[[4,-1,-1],],
                             [[4,4,-1],],
                             [[-1,4,-1],]],
                      name: "B 4",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(0, 0, -5)),
        Matrix3DPoint(data: [[[5, -1,-1],[5,  5,-1], ],
                             [[-1,-1,-1],[-1, 5,-1],],
                             [[-1,-1,-1],[-1,-1,-1],]],
                      name: "B 5",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(3, 3, -5)),
        Matrix3DPoint(data: [[[-1, 6,-1],[ 6, 6,-1], ],
                             [[-1,-1,-1],[ 6,-1,-1],],
                             [[-1,-1,-1],[-1,-1,-1],]],
                      name: "B 6",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(6, 3, -5)),
        Matrix3DPoint(data: [[[ 7,-1,-1],[ 7, 7,-1], ],
                             [[-1,-1,-1],[ 7,-1,-1],],
                             [[-1,-1,-1],[-1,-1,-1],]],
                      name: "B 7",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(9, 3, -5)),

    ];

    @EnvironmentObject var userData: UserData
    @State private var selectedSegment = 0


    @State private var nodeList:[SCNNode] = {
        dataList.map { item in
            addNode(item)
        }
    }()

    static func addNode(_ item: Matrix3DPoint) -> SCNNode {
        let countOfRow = item.data.count
        let countOfLayer = item.data.first?.count ?? -1
        let countOfColum = item.data.first?.first?.count ?? -1
        let parNode2 = SCNNode()
        for z in 0..<countOfRow {
            for y in 0..<countOfLayer {
                for x in 0..<countOfColum {
                    // 盒子
                    let box2 = SCNBox.init(width: 1, height: 1, length: 1, chamferRadius: 0.05)
                    let value = item.data[z][y][x];
                    if value == -1 {
                        continue
                    }
                    let boxNode2 = SCNNode()
                    boxNode2.geometry = box2
                    boxNode2.name = "\(value)"
                    // 由于默认y朝向上的，所以要取负值
                    boxNode2.position = SCNVector3Make(Float(x), Float(-y), Float(z))
                    parNode2.addChildNode(boxNode2)
                }
            }
        }
        parNode2.position = item.offset;
        parNode2.name = item.name;
        return parNode2
    }


    let segments = ["B 1", "B 2", "B 3", "B 4", "B 5", "B 6", "B 7"]
    @State private var dacai:String = "B 1"
    
    public var body: some View {
        VStack {
            ScenekitSingleView2(nodeList: $nodeList)
            Picker("", selection: $selectedSegment) {
                ForEach(0 ..< segments.count, id: \.self) {
                    Text(segments[$0])
                }
            }.pickerStyle(SegmentedPickerStyle()).padding(.horizontal)
                .onChange(of: selectedSegment) { newValue in
                    // 在选项变化时执行操作
                    print("Selected fruit: \(segments[newValue])")
                    dacai = segments[newValue];
                }
            HStack {
                CustomButton(title: "旋转X") {
                    stepcount += 1;
                    let rotationAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(1, 0, 0), duration: 0.2)
                    nodeList.filter({ node in
                        node.name == dacai
                    }).first?.runAction(rotationAction)
                }
                CustomButton(title: "旋转Y") {
                    stepcount += 1;
                    let rotationAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 1, 0), duration: 0.2)
                    nodeList.filter({ node in
                        node.name == dacai
                    }).first?.runAction(rotationAction)
                }
                CustomButton(title: "旋转Z") {
                    stepcount += 1;
                    let rotationAction = SCNAction.rotate(by: .pi / 2, around: SCNVector3(0, 0, 1), duration: 0.2)
                    nodeList.filter({ node in
                        node.name == dacai
                    }).first?.runAction(rotationAction)
                }
                Spacer()
                Text("步数:\(stepcount)")
            }
            StepperView()
        }
        .padding()
    }
    @State private var stepcount = 0 {
        didSet {
            triggerHapticFeedback()
        }
    }

    func StepperView() -> some View {
        HStack {
            Stepper {
                Text("X")
            } onIncrement :{
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == dacai
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(1.0, 0, 0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == dacai
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(-1.0, 0, 0), duration: 0.1))
            }

            Stepper {
                Text("Y")
            } onIncrement :{
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == dacai
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 1.0, 0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == dacai
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, -1.0, 0), duration: 0.1))
            }

            Stepper {
                Text("Z")
            } onIncrement :{
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == dacai
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 0, 1.0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;

                nodeList.filter({ node in
                    node.name == dacai
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 0, -1.0), duration: 0.1))
            }
        }
    }

    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}


struct CustomButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        } .background(Color.yellow)
            .cornerRadius(8)
    }
}
