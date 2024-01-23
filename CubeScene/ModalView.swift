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

struct ModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedColor = Color.red

    @State var colors:[ItemColor] = {colorsDefault.enumerated().map({ index, element in
        ItemColor(index: index, uicolor: element)
    })}()

    let result: Matrix3D = [[[2,4,3], [6,4,1], [6,6,1]],
                             [[2,3,3], [6,4,1], [7,4,5]],
                             [[2,2,3], [7,5,5], [7,7,5]]

    ]
    
    func currentResult() -> Matrix3D {
        let array24 = getAll24(result)
        return array24[dataIndex]
    }
    @State var dataIndex:Int = 0
    @State private var defaultCameraPosition = SCNVector3(x: 2, y: 2, z: 15)

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
            ZStack{
                Image(uiImage: UIImage(named: "wenli4")!)
                    .resizable(resizingMode: .tile)
                ScenekitSingleView(showType: ShowType.colorFul, dataItem: currentResult(), colors: colors.map({$0.uicolor}))
            }
            HStack {
                ZStack{
                    Rectangle().background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.clear).cornerRadius(5)
                    Text("上一个").foregroundColor(.white).font(.headline)
                }.frame(height: 44).onTapGesture {
                    dataIndex = (dataIndex + 1) % 24;
                }
                
            }
        }
        .padding()
    }
}

struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView()
    }
}
