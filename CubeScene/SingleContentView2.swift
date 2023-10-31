//
//  SingleContentView2.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit

/// 显示类型 单色、彩色、数字
enum ShowType: Hashable {
    case singleColor
    case colorFul
    case number
}

struct Matrix3DPoint {
    let data: Matrix3D
    let position: SCNVector3
    let name: String
    var rotationAngle:SCNVector3
    var offset:SCNVector3
}


extension Matrix3D {
    var formatOutput: String {
        return self.map { item in
            "/" + item.map({ subItem in
                subItem.map({ value in
                    if value == -1 {
                        return  "."
                    } else {
                        return String(value)
                    }
                }).joined()
            }).joined(separator: "/")
        }.joined(separator: "\n")
    }
}

public struct SingleContentView2: View {
    

    
    @EnvironmentObject var userData: UserData

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
    
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isRouteEnabled = true

    @State private var selectedSegment = 3

    @State var dataList:[Matrix3DPoint] = [
        Matrix3DPoint(data: [[[1,-1,-1],],
                             [[1,1,-1], ],
                             [[-1,-1,-1],]],
                      position: SCNVector3(3, 0, -5),
                      name: "Block 1",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(3, 0, -5)),
        Matrix3DPoint(data: [[[3,-1,-1],],
                             [[3,3,-1],],
                             [[3,-1,-1],]],
                      position: SCNVector3(0, 0, -5),
                      name: "Block 3",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(0, 0, -5)),
        Matrix3DPoint(data: [[[4,-1,-1],],
                             [[4,4,-1],],
                             [[-1,4,-1],]],
                      position: SCNVector3(-3, 0, -5),
                      name: "Block 4",
                      rotationAngle: SCNVector3Zero,
                      offset: SCNVector3(-3, 0, -5)),

    ];

    let segments = ["Block 1", "Block 3", "Block 4"]
    @State private var dacai:String = "Block 1"
    
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
                ArrowButtonView(onButtonTapped: decrementStep)
            } else {
                HStack {
                    Stepper("X:", value: Binding(get: {
                        dataList[selectedSegment].offset.x
                    }, set: { newvalue, _ in
                        dataList[selectedSegment].offset.x = newvalue
                    }), in: -5...10)
                    Stepper("Y:", value: Binding(get: {
                        dataList[selectedSegment].offset.y
                    }, set: { newvalue, _ in
                        dataList[selectedSegment].offset.y = newvalue
                    }), in: -5...10)
                    Stepper("Z:", value:Binding(get: {
                        dataList[selectedSegment].offset.z
                    }, set: { newvalue, _ in
                        dataList[selectedSegment].offset.z = newvalue
                    }), in: -5...10)
                }
            }
            HStack{
                Button(action: {
                    isRouteEnabled.toggle()
                }) {
                    Text(isRouteEnabled ? "旋转" : "移动")
                }
            }
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                incrementStep()
            }
        }
        .navigationTitle(dataModel.name)
        .navigationBarItems(trailing:completeStatus())
        .padding()
    }
    
    func completeStatus() -> some View {
        Group {
            HStack {
                Button(action: {
                    isOn.toggle()
                }) {
                    Image(systemName: isOn ? "eye.slash" : "eye.slash").foregroundColor(isOn ? .blue : .gray)
                }
                if isShowItems {
                    Button(action: {
                        dataModel.isTaskComplete.toggle()
                        UserDefaults.standard.set(dataModel.isTaskComplete, forKey: dataModel.name)
                    }) {
                        HStack{
                            Image(systemName: dataModel.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle")
                            if #available(iOS 16, *) {
                                Text(LocalizedStringResource(stringLiteral: "\(dataModel.isTaskComplete ? "Completed" : "ToDo")"))
                            } else {
                                Text("\(dataModel.isTaskComplete ? "Completed" : "ToDo")")
                            }
                        }.foregroundColor(dataModel.isTaskComplete ? .green : Color(uiColor: UIColor(hex: "00bfff")))
                    }
                }
            }
        }
    }
}


