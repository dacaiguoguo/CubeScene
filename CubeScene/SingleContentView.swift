//
//  SingleContentView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import Mixpanel

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
    
    @Binding var dataModel: Product
    
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
            // 用来生成正方形的切图的时候 需要去掉 alignment，居中用模拟器手势方便 一些
            ZStack(alignment: .bottomLeading) {
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
                            Text("SomaDes").font(.subheadline).foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                    
                    ScenekitSingleView(dataModel:dataModel,
                                       showType: showType,
                                       colors: userData.colorSaveList,
                                       numberImageList: userData.textImageList,
                                       showColor: showColor,
                                       focalLength: 45)
                    // 用来生成正方形的切图的
                    // .frame(width: 300.0, height: 300.0).border(Color.purple)
                }.background(blueColor)
                

                if showType == .colorFul {
                    HStack {
                        Button(action: {
                            Mixpanel.mainInstance().track(event: "isTimerRunning.toggle", properties: ["Signup": dataModel.name])
                            isTimerRunning.toggle()
                        }) {
                            Text(isTimerRunning ? "Pause Playback" : "Auto Play")
                                .font(.custom("Menlo", size: 18))
                                .foregroundColor(.white)
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .background(isTimerRunning ? Color.red : Color.green)
                                .cornerRadius(8)
                        }.frame(height: 44.0).padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 5))
                        Spacer()
                        Stepper("\("StepSm".i18n()) \(value)", onIncrement: incrementStep, onDecrement: decrementStep)
                            .padding(5)
                            .background(Color.white)
                    }
                    .background(Color.white)

                }
            }
           
            if isShowItems {
                Picker("Display Mode", selection: $showType) {
                    Text("Colorful Answers").tag(ShowType.colorFul)
                    Text("Question Mode").tag(ShowType.singleColor)
                    Text("Number Mode").tag(ShowType.number)
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
                NavigationLink("GoAction") {
                    SingleContentView2(nodeList: makeNode(with: dataModel.matrix))
                }
//                Button(action: {
//                    isOn.toggle()
//                }) {
//                    Image(systemName: isOn ? "eye.slash" : "eye.slash").foregroundColor(isOn ? .blue : .gray)
//                }
                if isShowItems {
                    Button(action: {
                        Mixpanel.mainInstance().track(event: "isTaskComplete.toggle", properties: ["Signup": dataModel.name])
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


