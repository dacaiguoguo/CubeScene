//
//  SingleContentView2.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit

struct Matrix3DPoint {
    let data: Matrix3D
    let name: String
    var rotationAngle:SCNVector3
    var offset:SCNVector3
}

public struct SingleContentView2: View {

    @EnvironmentObject var userData: UserData

    @State private var isRouteEnabled = true

    @State private var selectedSegment = 0

    @State var dataList:[Matrix3DPoint] = [
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
                      offset: SCNVector3(-3, 0, -5)),
        Matrix3DPoint(data: [[[-1, 6,-1],[ 6, 6,-1], ],
                             [[-1,-1,-1],[ 6,-1,-1],],
                             [[-1,-1,-1],[-1,-1,-1],]],
                      name: "B 6",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(-6, 0, -5)),
        Matrix3DPoint(data: [[[ 7,-1,-1],[ 7, 7,-1], ],
                             [[-1,-1,-1],[ 7,-1,-1],],
                             [[-1,-1,-1],[-1,-1,-1],]],
                      name: "B 7",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(-9, 0, -5)),

    ];

    let segments = ["B 1", "B 2", "B 3", "B 4", "B 5", "B 6", "B 7"]
    @State private var dacai:String = "B 1"
    
    public var body: some View {
        VStack {
            ScenekitSingleView2(colors: userData.colorSaveList,
                                dacai: $dacai,
                                dataList: dataList
            )
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
            if (isRouteEnabled) {
                StepperViewR()
            } else {
                StepperView()
            }
            HStack{
                Button(action: {
                    isRouteEnabled.toggle()
                }) {
                    Text(isRouteEnabled ? "旋转" : "移动")
                }
            }
        }
        .padding()
    }

    func decrementStep(a: Direction) {
        if (isRouteEnabled) {
            switch a {
            case .left:
                dataList[selectedSegment].rotationAngle.x += .pi / 2
            case .right:
                dataList[selectedSegment].rotationAngle.y += .pi / 2
            case .up:
                dataList[selectedSegment].rotationAngle.z += .pi / 2
            }
        }
    }


    func StepperViewR() -> some View {
        HStack {
            Stepper("X:", value: Binding(get: {
                dataList[selectedSegment].rotationAngle.x / (.pi / 2)
            }, set: { newvalue, _ in
                dataList[selectedSegment].rotationAngle.x = newvalue * (.pi / 2)
            }), in: 0...4)
            Stepper("Y:", value: Binding(get: {
                dataList[selectedSegment].rotationAngle.y / (.pi / 2)
            }, set: { newvalue, _ in
                dataList[selectedSegment].rotationAngle.y = newvalue * (.pi / 2)
            }), in: 0...4)
            Stepper("Z:", value:Binding(get: {
                dataList[selectedSegment].rotationAngle.z / (.pi / 2)
            }, set: { newvalue, _ in
                dataList[selectedSegment].rotationAngle.z = newvalue * (.pi / 2)
            }), in: 0...4)
        }
    }
    func StepperView() -> some View {
        HStack {
            Stepper("X:", value: Binding(get: {
                dataList[selectedSegment].offset.x
            }, set: { newvalue, _ in
                dataList[selectedSegment].offset.x = newvalue
            }), in: -10...10)
            Stepper("Y:", value: Binding(get: {
                dataList[selectedSegment].offset.y
            }, set: { newvalue, _ in
                dataList[selectedSegment].offset.y = newvalue
            }), in: -10...10)
            Stepper("Z:", value:Binding(get: {
                dataList[selectedSegment].offset.z
            }, set: { newvalue, _ in
                dataList[selectedSegment].offset.z = newvalue
            }), in: -10...10)
        }
    }
}


