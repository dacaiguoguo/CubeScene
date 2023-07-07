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


    var body: some View {
        VStack(alignment:.leading) {
            ScenekitSingleView(showType: .colorFul,
                               dataItem:[[[2,2,3], [5,3,3], [5,4,3]], [[2,1,1], [5,5,6], [7,4,4]], [[2,6,1], [7,6,6], [7,7,4]]],
                               colors: userData.colorSaveList)
            .frame(height: 500)
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
                }))
                    .frame(width: 60, height: 44)
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
