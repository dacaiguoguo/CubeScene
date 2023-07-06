//
//  ConfigView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/6.
//

import SwiftUI

struct ConfigView: View {

    @Environment(\.presentationMode) var presentationMode
    var colors:[ItemColor] = {colorsDefault.dropFirst().enumerated().map({ index, element in
        ItemColor(index: index+1, uicolor: element)
    })}()


    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                ForEach(colors) { item in
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
    @State private var bgColor = Color.red

    func ConfigItemView(_ item:ItemColor) -> some View {
        ZStack{
            VStack{
                ColorPicker("\(item.index)", selection: $bgColor)
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
