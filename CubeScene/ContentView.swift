//
//  ContentView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/1.
//

import SwiftUI
import SceneKit


/// 显示类型 单色、彩色、数字
enum ShowType: Hashable {
    case singleColor
    case colorFul
    case number
}

// public是为了Playgrounds代码通用

public struct ContentView: View {
    @State private var centerOffset = CGPoint.zero

    public init(){}
    @State private var isOn = false
    @State private var showModal = false

    @State private var colorFull:ShowType = .colorFul
    enum Field: Hashable {
        case dataIndexField
        case dataInputField
    }
    @FocusState private var focusItem: Field?
    @State var dataIndex:Int = 0

    let trimmingSet:CharacterSet = {
        var triSet = CharacterSet.whitespacesAndNewlines
        triSet.insert("/")
        return triSet
    }()

    let firstArray: [String] = {
        let stringContent = try! String(contentsOf: Bundle.main.url(forResource: "SOMA101", withExtension: "txt")!, encoding: .utf8)
        let firstArray = stringContent.components(separatedBy: "/SOMA")
        return firstArray.filter { item in
            item.lengthOfBytes(using: .utf8) > 5
        }
    }()


    /// 用计算属性 不能使用 lazy var
    var numberOfSoma:Int {
        firstArray.count
    }


    /// 解析结果
    /// - Returns: 返回三位数组
    func result() -> Matrix3D {
        let currentData = firstArray[dataIndex]

        let parsedData = currentData.trimmingCharacters(in: trimmingSet).split(separator: "\n").dropFirst().filter { item in
            item.hasPrefix("/")
        }.map({ item in
            item.trimmingCharacters(in: trimmingSet)
        })

        let separatorItem = Character("/")
        // 非数字都解析成-1
        let result = parsedData.map { item in
            item.split(separator: separatorItem).map { subItem in
                subItem.map { subSubItem in
                    Int(String(subSubItem)) ?? -1
                }
            }
        }
         print(result)
        return result
    }

    let moveStep = 5.0;
    public var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // 向上移动
                    centerOffset.y += moveStep
                    print(centerOffset)
                }) {
                    Image(systemName: "arrow.up")
                }
                
                Button(action: {
                    // 向左移动
                    centerOffset.x -= moveStep
                    print(centerOffset)

                }) {
                    Image(systemName: "arrow.left")
                }
                
                Button(action: {
                    // 向右移动
                    centerOffset.x += moveStep
                    print(centerOffset)

                }) {
                    Image(systemName: "arrow.right")
                }
                
                Button(action: {
                    // 向下移动
                    centerOffset.y -= moveStep
                    print(centerOffset)

                }) {
                    Image(systemName: "arrow.down")
                }
                
            }
            Toggle("显示代码", isOn: $isOn)
                .padding()
            if isOn {
                Text(firstArray[dataIndex].trimmingCharacters(in: trimmingSet))
                    .font(.custom("Menlo", size: 18))
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
            }
            ZStack{
                Image(uiImage: UIImage(named: "wenli4")!)
                    .resizable(resizingMode: .tile)
                ScenekitView(colorFull: colorFull, result: result(), colors: colorsDefault)
//                    .frame(width: 1000, height: 1000)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .position(x: UIScreen.main.bounds.width/2 + centerOffset.x, y: UIScreen.main.bounds.height/2 - 200 + centerOffset.y)
            }

            HStack {
                ZStack{
                    Rectangle().background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.clear).cornerRadius(5)
                    Text("上一个").foregroundColor(.white).font(.headline)
                }.frame(height: 44).onTapGesture {
                    focusItem = nil
                    dataIndex = (dataIndex - 1 + numberOfSoma) % numberOfSoma
                }
                Spacer()
                TextField("关卡", text: Binding(get: {
                    "\(dataIndex)"
                }, set: {
                    let intValue = Int($0) ?? 0
                    self.dataIndex = intValue % numberOfSoma
                }), prompt: Text("关卡号"))
                .focused($focusItem, equals: .dataIndexField)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.center)
                .padding()
                Spacer()
                ZStack{
                    Rectangle().background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.clear).cornerRadius(5)
                    Text("下一个").foregroundColor(.white).font(.headline)
                }.frame(height: 44).onTapGesture {
                    focusItem = nil
                    dataIndex = (dataIndex + 1) % numberOfSoma
                }
            }
            Picker("显示模式", selection: $colorFull) {
                Text("彩色").tag(ShowType.colorFul)
                Text("单色").tag(ShowType.singleColor)
                Text("数字").tag(ShowType.number)
            }.pickerStyle(.segmented)
        }.padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
            .previewDisplayName("iPhone 14")
    }
}
