//
//  SingleContentView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI


/// 显示类型 单色、彩色、数字
enum ShowType: Hashable {
    case singleColor
    case colorFul
    case number
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

public struct SingleContentView: View {
    
    
    @State private var isOn = false
#if DEBUG
    @State var showType:ShowType = .singleColor
#else
    @State var showType:ShowType = .singleColor
#endif
    
    @Binding var dataModel: EnterItem
    
    @State var isShowItems = true
    
    @EnvironmentObject var userData: UserData
    
    let imageSize = 40.0
    @State var showColor:[Int] = []
    @State private var value = 0
   

    func incrementStep() {
        value += 1
        if value > dataModel.orderBlock.count { value = 0 }
        if value == 0 {
            showColor = []
        } else {
            showColor = Array(dataModel.orderBlock[0 ..< value])
        }
    }
    
    func decrementStep() {
        value -= 1
        if value < 0 { value = dataModel.orderBlock.count }
        if value == 0 {
            showColor = []
        } else {
            showColor = Array(dataModel.orderBlock[0 ..< value])
        }

    }
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    public var body: some View {
        VStack {
            ZStack() {
                Image(uiImage: UIImage(named: "wenli7")!)
                    .resizable(resizingMode: .tile)
                ZStack {
                    VStack {
                        HStack{
                            ForEach(dataModel.usedBlock.indices, id: \.self) { index in
                                let value = dataModel.usedBlock[index]
                                Image(uiImage: UIImage(named: "c\(value)")!).resizable(resizingMode: .stretch).frame(width: imageSize, height: imageSize)
                            }
                        }
                        if isOn {
                            HStack{
                                Text(dataModel.matrix.formatOutput).font(.custom("Menlo", size: 18)).frame(maxWidth: .infinity).foregroundColor(.primary)
                            }.disabled(false)
                        }
                        Spacer()
                        HStack{
                            Text("单指旋转\n双指滑动来平移\n双指捏合或张开来放大缩小").font(.subheadline).foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                    
                    ScenekitSingleView(dataModel:dataModel,
                                       showType: showType,
                                       colors: userData.colorSaveList,
                                       numberImageList: userData.textImageList,
                                       showColor: showColor)
                }
//                .frame(width: 300.0, height: 300.0).border(Color.purple)

                if showType == .colorFul {
                    HStack {
                        Button(action: {
                            isTimerRunning.toggle()
                        }) {
                            Text(isTimerRunning ? "暂停播放" : "自动播放")
                                .font(.custom("Menlo", size: 18))
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .background(isTimerRunning ? Color.red : Color.green)
                                .cornerRadius(8)
                        }.frame(height: 44.0)
                        Spacer()
                        Stepper("步骤\(value)", onIncrement: incrementStep, onDecrement: decrementStep)
                            .padding(5)
                            .background(Color.white)
                    }
                    .background(Color.white)

                }
            }
           
            if isShowItems {
                Picker("显示模式", selection: $showType) {
                    Text("彩色答案").tag(ShowType.colorFul)
                    Text("出题模式").tag(ShowType.singleColor)
                    Text("数字模式").tag(ShowType.number)
                }.pickerStyle(.segmented)
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
                        showColor.append(showColor.count)
                        print("showColor\(showColor)")
                        dataModel.isTaskComplete.toggle()
                        UserDefaults.standard.set(dataModel.isTaskComplete, forKey: dataModel.name)
                        
                    }) {
                        HStack{
                            Image(systemName: dataModel.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle")
                            Text("\(dataModel.isTaskComplete ? "已完成" : "待完成")")
                        }.foregroundColor(dataModel.isTaskComplete ? .green : .gray)
                    }
                }
            }
        }
    }
}


