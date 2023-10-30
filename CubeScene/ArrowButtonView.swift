//
//  ArrowButtonView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/3.
//

import SwiftUI


struct ArrowButtonView: View {
    var onButtonTapped: ((Direction) -> Void)?  // 定义按钮点击事件的闭包属性

    var body: some View {
                VStack {
                    Button(action: {
                        onButtonTapped?(.up)  // 调用上按钮点击事件
                    }) {
                        Image(systemName: "arrow.up")
                    }
                    .padding()
        
                    HStack {
                        Button(action: {
                            onButtonTapped?(.left)  // 调用左按钮点击事件
                        }) {
                            Image(systemName: "arrow.left")
                        }
                        .padding()
        
                        Button(action: {
                            onButtonTapped?(.right)  // 调用右按钮点击事件
                        }) {
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                    }
        
                    Button(action: {
                        onButtonTapped?(.down)  // 调用下按钮点击事件
                    }) {
                        Image(systemName: "arrow.down")
                    }
                    .padding()
        //        }
//        HStack {
//            Button(action: {
//                onButtonTapped?(.left)  // 调用左按钮点击事件
//            }) {
//                Image(systemName: "arrow.left")
//            }
//            .padding()
//
//            Button(action: {
//                onButtonTapped?(.right)  // 调用右按钮点击事件
//            }) {
//                Image(systemName: "arrow.right")
//            }
//            .padding()
        }

    }
}

enum Direction {
    case up
    case down
    case left
    case right
}




struct ArrowButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowButtonView()
    }
}
