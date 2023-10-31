//
//  ArrowButtonView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/3.
//

import SwiftUI


struct ArrowButtonView2: View {
    var onButtonTapped: ((Direction) -> Void)?  // 定义按钮点击事件的闭包属性

    var body: some View {
        HStack {
            Button(action: {
                onButtonTapped?(.up)  // 调用上按钮点击事件
            }) {Text("Z轴")}
            Button(action: {
                onButtonTapped?(.left)  // 调用左按钮点击事件
            }) {Text("X轴")}
            Button(action: {
                onButtonTapped?(.right)  // 调用右按钮点击事件
            }) {Text("Y轴")}
        }.padding()
    }
}

enum Direction {
    case up
    case left
    case right
}


struct ArrowButtonView2_Previews: PreviewProvider {
    static var previews: some View {
        ArrowButtonView2()
    }
}
