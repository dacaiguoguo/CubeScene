//
//  ConfigView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/6.
//

import SwiftUI


struct ItemColor: Decodable {
    var index:Int = 0
    var colorData:Data = try! NSKeyedArchiver.archivedData(withRootObject: UIColor.black, requiringSecureCoding: false)


    init(index: Int, uicolor: UIColor) {
        self.index = index
        self.colorData = try! NSKeyedArchiver.archivedData(withRootObject: uicolor, requiringSecureCoding: false)
    }

    init(index: Int, color: Color) {
        self.index = index
        self.colorData = try! NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false)
    }

    var uicolor: UIColor {
        do {
            if let colorret = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                // Use the color
                //                print("colorret:\(colorret)")
                return colorret
            } else {
                print("Failed to convert data to UIColor")
            }
        } catch {
            print("Failed to convert data to UIColor: \(error)")
        }
        return UIColor.black
    }
}

extension ItemColor: Identifiable {
    var id: Int {
        index
    }
}


struct ConfigView: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var bgColor = Color.red
    @EnvironmentObject var userData: UserData


    func colors() -> [ItemColor] {
        var ret = userData.colorSaveList.enumerated().map({ index, element in
            ItemColor(index: index, uicolor: element )
        })
        ret.removeFirst()
        return ret
    }

    @State private var counter = 0
    @State private var isPresented = false

    @State var ditem: EnterItem = EnterItem(name: "测试",
                                            matrix: [[[2,4,3], [6,4,1], [6,6,1]],
                                                     [[2,3,3], [6,4,1], [7,4,5]],
                                                     [[2,2,3], [7,5,5], [7,7,5]]], isTaskComplete: false)

    var body: some View {
        VStack(alignment:.leading) {
            ScenekitSingleView(dataModel:ditem,
                               showType: .colorFul,
                               colors: userData.colorSaveList,
                               numberImageList: getTextImageList(),
                               showColor: ditem.orderBlock, focalLength: 50)
            .frame(height: 300)
            .id(counter) // 强制重新创建视图

            Text("点击圆圈来修改块的颜色吧!").foregroundColor(.primary).font(.subheadline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                ForEach(colors()) { item in
                    ConfigItemView(item)
                }
            }
        }.padding().navigationTitle("TitleSetting")
            .navigationBarTitleDisplayMode(.inline).sheet(isPresented: $isPresented) {
                InputView(isPresented: $isPresented, ditem: $ditem, counter: $counter)
            }
            .navigationBarItems(trailing:completeStatus())


    }

    func completeStatus() -> some View {
        Button("自定义") {
            self.isPresented = true
        }
    }

    func ConfigItemView(_ item:ItemColor) -> some View {
        ZStack{
            VStack{
                ColorPicker("\(item.index)", selection: Binding(get: {
                    Color(item.uicolor)
                }, set: {
                    var colorSaveListtemp = userData.colorSaveList;
                    colorSaveListtemp[item.index] = UIColor($0);
                    userData.colorSaveList = colorSaveListtemp;
                })).frame(width: 60, height: 44)
            }
        }.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.blue, lineWidth: 1)
        )
    }

}


struct InputView: View {

    @Binding var isPresented:Bool
    @Binding var ditem: EnterItem
    @Binding var counter:Int
    @State private var message = ""
    @FocusState private var isEditing: Bool
    @State private var debugStr = ""
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $message)
                    .font(.custom("Menlo", size: 18))
                    .lineSpacing(10)
                    .focused($isEditing)
                    .disableAutocorrection(true)
                    .padding()
                    .frame(height: 400)
                    .border(.gray)

                Button("确定输入", action: {
                    // 在这里执行编辑完成的操作
                    // 比如保存文本、关闭键盘等等

                    // 结束编辑状态
                    isEditing = false
                    let input:[EnterItem]
                    if message.hasPrefix("/SOMA") {
                        input = produceData2(stringContent: message)
                    } else {
                        input = produceData2(stringContent: "/SOMA-test\n\(message)")
                    }
                    if input.count > 0 {
                        ditem = input.first!
                        debugStr = "new input\(input)"
                    } else {
                        debugStr = "old input\(input)"
                    }
                    counter += 1
                })
                .padding()
                .disabled(!isEditing)


            }
            .navigationBarItems(trailing:completeStatus())
            .navigationTitle("自定义代码")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func completeStatus() -> some View {
        Button("关闭") {
            // 当按钮被点击时，isPresented 的值就会被设置为 true
            self.isPresented = false
        }
    }
}


struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConfigView()
        }
    }
}
