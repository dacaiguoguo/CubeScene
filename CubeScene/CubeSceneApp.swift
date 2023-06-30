//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
//

import SwiftUI


struct ItemColor: Decodable {
    var index:Int = 0
    var colorData:Data = try! NSKeyedArchiver.archivedData(withRootObject: UIColor.black, requiringSecureCoding: false)


    init(index: Int, uicolor: UIColor) {
        self.index = index
        self.colorData = try! NSKeyedArchiver.archivedData(withRootObject: uicolor, requiringSecureCoding: false)
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
                        }, set: { colors[index.index] = ItemColor(index: index.index, uicolor: UIColor($0))}))
                            .padding()
                    }
                }
            }
            .navigationBarTitle("List")
        }
    }
}

@main
struct CubeSceneApp: App {
    @State private var isPresented = false

    var body: some Scene {
        WindowGroup {
//            if #available(iOS 16.0, *) {
//                NavigationStack {
//                    ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
//                }
//            } else {
                TabView {
                    NavigationView {
                        ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline).navigationBarItems(trailing: Button(action: {
                            // 执行按钮1的操作
                            isPresented = true
                        }) {
                            Image(systemName: "gear.circle")
                        }) .sheet(isPresented: $isPresented) {
                            ModalView()
                        }
                    }.tabItem {
                        Image(systemName: "gamecontroller")
                        Text("练习")
                    }.tag(0)
                    NavigationView {
                        ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                    }.tabItem {
                        Image(systemName: "scribble.variable")
                        Text("自定义")
                    }.tag(0)
                    NavigationView {
                        SettingView().navigationTitle("设置").navigationBarTitleDisplayMode(.inline)
                    }.tabItem {
                        Image(systemName: "gear.circle")
                        Text("设置")
                    }.tag(0)
                }
            }
//        }
    }
}
