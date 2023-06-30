//
//  ModalView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/30.
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
                print(colorret)
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

struct ModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedColor = Color.red

    @State var colors:[ItemColor] = [
        ItemColor(index: 0, uicolor: .black),
        ItemColor(index: 1, uicolor: UIColor(hex: "FF8800")),
        ItemColor(index: 2, uicolor: UIColor(hex: "0396FF")),
        ItemColor(index: 3, uicolor: UIColor(hex: "EA5455")),
        ItemColor(index: 4, uicolor: UIColor(hex: "7367F0")),
        ItemColor(index: 5, uicolor: UIColor(hex: "32CCBC")),
        ItemColor(index: 6, uicolor: UIColor(hex: "28C76F")),
        ItemColor(index: 7, uicolor: UIColor.purple),
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(colors) { index in
                    HStack{
                        Text("Item \(index.index)").foregroundColor(Color(index.uicolor))
                        ColorPicker("Select a color", selection: Binding(get: {
                            Color(index.uicolor)
                        }, set: { colors[index.index] = ItemColor(index: index.index, color: $0)}))
                        .padding()
                    }
                }
            }
            .navigationBarTitle("List")
        }
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView()
    }
}
