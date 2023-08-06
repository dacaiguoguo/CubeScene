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
    @State private var debugStr = ""

    @State private var message = """
    /SOMA-YA001
/.66/461
/4.6/411
/43./333
    """

    func colors() -> [ItemColor] {
        var ret = userData.colorSaveList.enumerated().map({ index, element in
            ItemColor(index: index, uicolor: element )
        })
        ret.removeFirst()
        return ret
    }
    let configData = [[[0,0,0],[2,3,0],[2,3,3]],[[2,5,5],[2,4,5],[6,4,4]],[[1,1,1],[6,1,5],[6,6,4]]].map { item in
        item.map { item2 in
            item2.map { item3 in
                if item3 == 0 {return 2}
                if item3 == 1 {return 3}
                if item3 == 2 {return 4}
                if item3 == 3 {return 1}
                if item3 == 4 {return 5}
                if item3 == 5 {return 6}
                if item3 == 6 {return 7}
                return item3
            }
        }
    }
    @FocusState private var isEditing: Bool

    @State var ditem: EnterItem = EnterItem(name: "测试",
                                                   matrix: [[[2,2,3], [5,3,3], [5,4,3]], [[2,1,1], [5,5,6], [7,4,4]], [[2,6,1], [7,6,6], [7,7,4]]],isTaskComplete: false)

    var body: some View {
        VStack(alignment:.leading) {
            ScenekitSingleView(dataModel:ditem,
                               showType: .colorFul,
                               colors: userData.colorSaveList,
                               numberImageList: getTextImageList(),
                               showColor: [1,2,3,4,5,6,7],focalLength: 50)
            .frame(height: 500)
             HStack{
                TextEditor(text: $message)
                .font(.custom("Menlo", size: 18))
                .lineSpacing(20)
                .focused($isEditing)
                .disableAutocorrection(true)
                .padding()
                .frame(height: 100)
                Button("完成", action: {
                    // 在这里执行编辑完成的操作
                    // 比如保存文本、关闭键盘等等
                    
                    // 结束编辑状态
                    isEditing = false
                    let input = produceData2(stringContent: message)
                    if input.count > 0 {
                        ditem = input.first!
                        debugStr = "new input\(input)"                
                    } else {
                        debugStr = "old input\(input)"                
                    }
                })
                .padding()
                .disabled(!isEditing)
            }
            Text("debugStr:\(debugStr)")
            Text("点击圆圈来修改块的颜色吧!").foregroundColor(.primary).font(.subheadline)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                ForEach(colors()) { item in
                    ConfigItemView(item)
                }
            }
        }.padding().navigationTitle("TitleSetting")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:closeButton())

    }

    func closeButton() -> some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: { Image(systemName: "xmark") })
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

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConfigView()
        }
    }
}
