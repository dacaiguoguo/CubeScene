//
//  SingleContentView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
public struct SingleContentView: View {

    @State private var isOn = false
    @State private var colorFull:ShowType = .colorFul
    /// 解析结果
    /// - Returns: 返回三维数组
    let result: Matrix3D

    init(isOn: Bool = false, result: Matrix3D) {
        self.isOn = isOn
        self.result = result
    }

    func resultDes() -> String {
        return result.map { item in
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

    public var body: some View {
        VStack {
            Toggle("显示代码", isOn: $isOn)
                .padding()
            if isOn {
                Text(resultDes()).font(.custom("Menlo", size: 18)).frame(maxWidth: .infinity).background(Color.white)
            }
            ZStack{
                Image(uiImage: UIImage(named: "wenli4")!)
                    .resizable(resizingMode: .tile)
                ScenekitView(colorFull: colorFull, result: result, colors: colorsDefault)
            }
//            HStack {
//                ZStack{
//                    Rectangle().background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
//                        .foregroundColor(.clear).cornerRadius(5)
//                    Text("上一个").foregroundColor(.white).font(.headline)
//                }.frame(height: 44).onTapGesture {
//                    focusItem = nil
//                    dataIndex = (dataIndex - 1 + numberOfSoma) % numberOfSoma
//                }
//                Spacer()
//                ZStack{
//                    Rectangle().background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
//                        .foregroundColor(.clear).cornerRadius(5)
//                    Text("下一个").foregroundColor(.white).font(.headline)
//                }.frame(height: 44).onTapGesture {
//                    focusItem = nil
//                    dataIndex = (dataIndex + 1) % numberOfSoma
//                }
//            }
            Picker("显示模式", selection: $colorFull) {
                Text("彩色").tag(ShowType.colorFul)
                Text("单色").tag(ShowType.singleColor)
                Text("数字").tag(ShowType.number)
            }.pickerStyle(.segmented)
        }.padding()
    }
}


struct SingleContentView_Previews: PreviewProvider {
    static var previews: some View {
        SingleContentView(result:[[[2,4,3], [6,4,1], [6,6,1]],
                           [[2,3,3], [6,4,1], [7,4,5]],
                           [[2,2,3], [7,5,5], [7,7,5]]])
    }
}
