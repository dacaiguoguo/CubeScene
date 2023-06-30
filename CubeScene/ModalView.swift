//
//  ModalView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/30.
//

import SwiftUI
import SceneKit


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

    let result: [[[Int]]] = [[[2,4,3], [6,4,1], [6,6,1]],
                             [[2,3,3], [6,4,1], [7,4,5]],
                             [[2,2,3], [7,5,5], [7,7,5]]

    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                ForEach(colors) { index in
                    ZStack{
                        Image(uiImage: UIImage(named: "c\(index.index)")!).resizable()
                        ColorPicker("", selection: Binding(get: {
                            Color(index.uicolor)
                        }, set: {
                            colors[index.index] = ItemColor(index: index.index, color: $0)
                            colorsDefault = colors.map({$0.uicolor})
                        }))
                    }
                    .background(Color.gray)
                    .frame(width: 80, height: 80)
                }
            }
            .padding()
            ScenekitView(colorFull: ShowType.colorFul, result: result, colors: colors.map({$0.uicolor}))
        }
        .padding()
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView()
    }
}
