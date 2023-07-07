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
        userData.colorSaveList.enumerated().map({ index, element in
            ItemColor(index: index, uicolor: element )
        })
    }


    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                ForEach(colors()) { item in
                    ConfigItemView(item)
                }
            }.padding()
        }.navigationTitle("设置")
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
                ColorPicker("\(item.index+1)", selection: Binding(get: {
                    Color(item.uicolor)
                }, set: {
                    var colorSaveListtemp = userData.colorSaveList;
                    colorSaveListtemp[item.index] = UIColor($0);
                    userData.colorSaveList = colorSaveListtemp;
                }))
                    .frame(width: 60, height: 30)
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
